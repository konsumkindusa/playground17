/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Andy Ognenoff - Cloud Sherpas/Mathworks
 *@date Original:   26 June 2015, Last Modified: 24 March 2017
 *@description:     This is a Handler class for Class Object.
 */
public class ClassTriggerHandler {
    
    ClassDml classDmlObj = new ClassDml();
    //get training Agreement Settings instance
    Training_Agreement_Settings__c settings = Training_Agreement_Settings__c.getInstance();
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Andy Ognenoff - Cloud Sherpas/Mathworks
     *@date Original: 29 June 2015, Last Modified: 07 July 2015
     *@description: Method that handles Before Delete trigger event on the Class__c object.
     */
    public void onBeforeDelete(List<Class__c>clssLst){
        Logger.push('onBeforeDelete','ClassTriggerHandler');
        //instantiating the Set of class id 
        Set<Id> classId = new Set<Id>();
        //instantiating the List which contains list of class records
        List<Class__c> classList = new List<Class__c>();
        for(Class__c classObj : clssLst){
            classId.add(classObj.Id);
        }
        //query the Class records with the related enrollments
        classList = [Select Id,Name, Publish_To_Web__c, (Select Id,Class__c From Class_Enrollees__r) From Class__c Where Id IN :classId];
        //check list is not empty
        if(!classList.isEmpty()){
            //send class list and enrollment list      
            classDmlObj.preventDelClassesWithEnrollments(classList);
        }
        Logger.pop();
      
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 June 2015, Last Modified: 24 March 2017
     *@description: Method that handles Before insert trigger event on the Class__c object.
     */
    public void onBeforInsert(List<Class__c>clssLst){
        Logger.push('onBeforInsert','ClassTriggerHandler');
        set<Id> spOfficeId = new set<Id> ();      
        List<Sponsor_Office__c> spOfficeList = new List<Sponsor_Office__c>();       
        Map<Id,Sponsor_Office__c> spOfficeMap = new Map<Id,Sponsor_Office__c>();       
        set<String> courselangId= new set<String> ();       
        List<Course_Language__c> courselangList = new List<Course_Language__c>();      
        Map<String,Course_Language__c > courseLangMap = new Map<String,Course_Language__c >();
        List<Class__c> primInstClasslst = new List<Class__c>();

        ClassDMLObj.classTimeZone(clssLst);
        
        //SS 3/24/2017 Populate Primary Instructor User Id which will be used for survey record ownership
         for(Class__c classObj : clssLst){
        	if(classObj.Primary_Instructor__c !=null){
                primInstClasslst.add(classObj);
            }
        }
        
        ClassDMLObj.classsetInstructorUser(primInstClasslst); //SS 3/24/2017
       
        if (!settings.Class_Prevent_Defaults__c){
                   
        ClassDMLObj.classclone(clssLst);

          //iterate over the class list
        for(Class__c classObj : clssLst){
            if(classObj.Sponsor_Office__c !=null){
                spOfficeId.add(classObj.Sponsor_Office__c);
            }
        }
              
        if(!spOfficeId.isEmpty()){
            //query for getting Sponsor list which belongs to trigger context.
            spOfficeList = [Select Id,Class_Default_End_Time__c,Class_Default_Start_Time__c,Default_Class_Language__c,Class_Default_Time_Zone__c, CurrencyIsoCode From Sponsor_Office__c where Id IN :spOfficeId];
            //iterate over sponsor list to populate the map of sponsor office
            for(Sponsor_Office__c  spObj : spOfficeList ){
                if(!spOfficeMap.containsKey(spObj.Id)){
                    spOfficeMap.put(spObj.Id,spObj);
                }
            }
            //iterate over the class list so we can set language,start time,end time.
            for(Class__c clsObj : clssLst){
                if (!clsObj.isClone()){
                clsObj.Language__c = spOfficeMap.get(clsObj.Sponsor_Office__c).Default_Class_Language__c;
                clsObj.CurrencyIsoCode = spOfficeMap.get(clsObj.Sponsor_Office__c).CurrencyIsoCode;
                if (clsObj.Class_Format__c != 'Self-Paced Online')
                {
                    clsObj.Start_Time__c = spOfficeMap.get(clsObj.Sponsor_Office__c).Class_Default_Start_Time__c;
                	clsObj.End_Time__c = spOfficeMap.get(clsObj.Sponsor_Office__c).Class_Default_End_Time__c;  
                }
            }
            }           
        }
        
        
        
        //logic for inserting class name automatically from course language
        for(Class__c classObj : clssLst){
            if(classObj.Course__c != null && classObj.Language__c != null){
                courselangId.add(classObj.Course__c +''+ classObj.Language__c);
            }
         }
         
        if(!courselangId.isEmpty()){
            //query  for getting course language records
            courselangList = [Select Id,Course__c,Course_Language__c,Localized_Course_Name__c,UniqueCourseLanguage__c From Course_Language__c Where UniqueCourseLanguage__c In :courselangId];
        }
        if(!courselangList.isEmpty()){
            //iterate over the course language for getting the UniqueCourseLanguage__c 
            //which is a unique key for identification of course and respective language
            for(Course_Language__c  courslangObj : courselangList ){
                //fill the map with UniqueCourseLanguage__c as key
                if(!courseLangMap.containsKey(courslangObj.UniqueCourseLanguage__c )){
                    courseLangMap.put(courslangObj.UniqueCourseLanguage__c,courslangObj);
                }
            }
        }
        //iterate over the class list so we can set Class name.
        for(Class__c clsObj : clssLst){
            if (!clsObj.isClone()){
                String uniqueCourseLang = clsObj.Course__c +''+ clsObj.Language__c;
                if(!courseLangMap.isEmpty()){
                    clsObj.Name= courseLangMap.get(uniqueCourseLang).Localized_Course_Name__c;
                }
        }     
        }
        }
       Logger.pop();
    }
    
    /**
     *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 
     *@description: Method that handles After insert trigger event on the Class__c object.
     */
    
    public void onAfterInsert(List<Class__c> clssLst){
        Set<Id> activeClsSet = new Set<Id>();
        List<Class__c> activeClsLst = new List<Class__C>();
        List<Class__c> newClsLst = new List<Class__c>();
        
        if(!clssLst.IsEmpty()){   
          
            for(Class__c clsObj : clssLst){
                activeClsSet.add(clsObj.Id);
            }   
            //Quering the Triggered Class Record     
            newClsLst = [SELECT Name, Id, Status__c, RecordType.Name FROM Class__c WHERE Id IN: activeClsSet];
            
            for(Class__c clssObj : newClsLst){
                //If the Class Status Is Active and it Record Type is Self-Paced.
                if(clssObj.Status__c == 'Active' && clssObj.RecordType.Name == 'Self-Paced'){
                    activeClsLst.add(clssObj);
                }
            }
        }
        //added switch for Auto create Auto create class assoiciation records
        if(settings.Auto_Create_Class_Association__c){
            classDmlObj.insertTrainingAgreementClassRelationship(activeClsLst);
        }
        
    }
  
    /**
     *@author Original: Shweta Shanbhag
     *@date Original: February 1 2017
     *@description: Method that handles before update trigger event on the Class__c object.
     */
    public void onBeforeUpdate(Map<Id, Class__c> clssNewMap, Map<Id, Class__c> clssOldMap){
        Logger.push('onBeforeUpdate','ClassTriggerHandler');
        List<Class__c> classupdlst = new List<Class__C>();
        List<Class__c> classinstUserlst = new List<Class__C>();
        
        for (Class__c clss:clssNewMap.values()){
            if (clssOldMap.get(clss.Id).Training_Location__c != clss.Training_Location__c)
            {              
              classupdlst.add(clss);
            }
            else if (clssOldMap.get(clss.Id).Time_Zone__c != clss.Time_Zone__c)
            {
               clss.Time_Zone_Canonical__c = classDmlObj.calctimezoneCanonical(clss.Time_Zone__c);
            }
        }
        
        for (Class__c clss:clssNewMap.values()){
            if (clssOldMap.get(clss.Id).Primary_Instructor__c != clss.Primary_Instructor__c)             
            {  
                if (clss.Primary_Instructor__c != null)
                {	classinstUserlst.add(clss); }
                else
                { clss.Instructor_User__c = null;}   
            }
        }
        classDmlObj.classTimeZone(classupdlst); 
        classDmlObj.classsetInstructorUser(classinstUserlst); //SS 3/24/2017 Populate Primary Instructor User Id 
    }
    /**
     *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 
     *@description: Method that handles After update trigger event on the Class__c object.
     */
    
    public void onAfterUpdate(List<Class__c> clssLst, Map<id,Class__c> clssMap){
        List<Class__c> activeClsLst = new List<Class__C>();
        List<Class__c> classlocupdList = new List<Class__c>();
        List<Class__c> classtzupdList = new List<Class__c>();
        List<Class__c> newClsLst = new List<Class__c>();
        Set<Id> activeClsSet = new Set<Id>();
        
        //Check if the List is Empty or not.
        if(!clssLst.IsEmpty()){   
            for(Class__c clsObj : clssLst){
                activeClsSet.add(clsObj.Id);    
            }   
            
            //Quering the Triggered Class Record     
            newClsLst = [SELECT Name, Id, Status__c, Training_Location__c, RecordType.Name FROM Class__c WHERE Id IN: activeClsSet];
            
            for(Class__c clsObj : newClsLst){          
                Class__c clsOldObj = clssMap.get(clsObj.Id);            
                if(clsOldObj.Status__c == 'Inactive' && clsObj.Status__c == 'Active'){                
                    if(clsOldObj.Status__c != clsObj.Status__c && clsObj.RecordType.Name == 'Self-Paced'){
                            activeClsLst.add(clsObj);
                    }//End of if.
                }//End of Active and Inactive If.   
                if(clsOldObj.Training_Location__c != clsObj.Training_Location__c ){
                    classlocupdList.add(clsObj);
                }
                
            }//End of For Loop
        }//End of List Check "If"
       
        if(settings.Auto_Create_Class_Association__c){
            classDmlObj.insertTrainingAgreementClassRelationship(activeClsLst);
        }
     	
        if (!classlocupdList.isEmpty()){
       //    classDmlObj.classTimeZone(classlocupdList);
        }
            
        
    }
    
    
}