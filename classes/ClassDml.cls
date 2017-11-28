/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   29 June 2015, Last Modified: 29 June 2015
 *@description:     This is a Handler class for Class Object.
 */
public class ClassDml {
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: ANdy Ognenoff - Cloud Sherpas/Mathworks
     *@date Original: 29 June 2015, Last Modified: 07 July 2015
     *@description: Method that handles Dml events for Class__c object.
     */
    public void preventDelClassesWithEnrollments(List<Class__c>clssLst){
        Logger.push('preventDelClassesWithEnrollments','ClassDml');
        //iterate over the list to test class has enrollement 
        for(Class__c clsObj: clssLst){
            if(clsObj.Class_Enrollees__r.size() > 0 || clsObj.Publish_To_Web__c){
                   Class__c actualRecord =(Class__c ) Trigger.oldMap.get(clsObj.Id);
                   actualRecord.addError(system.label.Class_Before_Delete);
            }
        }
        Logger.pop();
    }
    
    /**
     *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
     *@date Original: 29 July 2015, Last Modified: 
     *@description: Method that handles Dml events for Class__c object.
     */
     
     public void insertTrainingAgreementClassRelationship(List<class__c> clssLst){
         
         Set<Id> clssSet = new Set<Id>();
         List<Enterprise_Training_Agreement__c> etAgreementLst = new List<Enterprise_Training_Agreement__c>();
         List<Training_Agreement_Class_Relationship__c> taClsRelLst = new List<Training_Agreement_Class_Relationship__c>(); 
         Map<Id, Id> clsstaClsRelMap = new Map<Id, Id>();
         List<Training_Agreement_Class_Relationship__c> taClsRelOldLst = new List<Training_Agreement_Class_Relationship__c>();
         
         if(!clssLst.IsEmpty()){
         
             for(Class__c clsObj : clssLst){
                 clssSet.add(clsObj.Id);
             }
             
             etAgreementLst = [SELECT Id, RecordType.Name, Is_Active__c FROM Enterprise_Training_Agreement__c WHERE (RecordType.Name = 'Unlimited') AND (Is_Active__c = True)];
             
             taClsRelOldLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c];
             
             for(Training_Agreement_Class_Relationship__c trAgClsRelObj : taClsRelOldLst){
                 clsstaClsRelMap.put(trAgClsRelObj.class__c, trAgClsRelObj.Enterprise_Training_Agreement__c);
             }
             for(Class__c clssObj : clssLst){
                for(Enterprise_Training_Agreement__c etAgreementObj : etAgreementLst){
                    //Check if the Duplicate Record are Inserting.
                    if((!clsstaClsRelMap.containsKey(clssObj.Id)) && (!(clsstaClsRelMap.get(clssObj.Id) == etAgreementObj.Id))){
                         //Create Training Agreement Class relationship Record Object.
                         Training_Agreement_Class_Relationship__c taClsRelObj = new Training_Agreement_Class_Relationship__c();
                         taClsRelObj.class__c = clssObj.Id;
                         taClsRelObj.Enterprise_Training_Agreement__c = etAgreementObj.Id;
                         taClsRelLst.add(taClsRelObj);
                    }//End of If     
                }//End of Enterprise Training Agreement For Loop    
             }//End of Class For Loop
         }//End of If 
         try{
             insert taClsRelLst;
         }
         catch(DMLException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                 //Process exception here
                Logger.debugException('Error in Creating Training Agreement Class Relationship Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
             }
         }
    }//End of insertTrainingAgreementClassRelationship Method

    
      /**
     *@author Original: Shweta Shanbhag
     *@date Original: 27 January 2017
     *@description: Find the time zone for class from sponsor office or location
     */
    public void classTimeZone(List<Class__c> clsLst){
        Logger.push('classTimeZone','ClassDml');

    	set<Id> trnLocId = new set<Id> (); 
        Map<Id, String> trnLocMap = new Map<Id, String>();
        set<Id> spOfficeId = new set<Id> ();            
        Map<Id,String> spOfficeMap = new Map<Id,String>();   
        
         for(Class__c classObj : clsLst){
            if(classObj.Training_Location__c !=null){
                trnLocId.add(classObj.Training_Location__c);
            } 
             
            if(classObj.Sponsor_Office__c !=null){
                spOfficeId.add(classObj.Sponsor_Office__c);
            }
        }
            
            if(!trnLocId.isEmpty()){
                for (Training_Location__c trnLocObj: [Select Time_Zone__c from Training_Location__c where Id IN: trnLocId]){
                if(!trnLocMap.containsKey(trnLocObj.Id)){
                    trnLocMap.put(trnLocObj.Id,trnLocObj.Time_Zone__c);  }                      
            	}   
            }
            if(!spOfficeId.isEmpty()){
                for(Sponsor_Office__c  spObj : [Select Class_Default_Time_Zone__c From Sponsor_Office__c where Id IN :spOfficeId] ){
                if(!spOfficeMap.containsKey(spObj.Id)){
                    spOfficeMap.put(spObj.Id,spObj.Class_Default_Time_Zone__c);}
            	}    
            }
        
        
            for (Class__c classObj: clsLst ){
                if(!classObj.isClone()){
                if (classObj.Class_Format__c !='Self-Paced Online'){
                    classObj.Time_Zone__c = spOfficeMap.get(classObj.Sponsor_Office__c);               
                	if(classObj.Training_Location__c != null && (!String.isBlank(trnLocMap.get(classObj.Training_Location__c))) )
                	 { 
                         classObj.Time_Zone__c = trnLocMap.get(classObj.Training_Location__c);
                     }
                    classObj.Time_Zone_Canonical__c = calctimezoneCanonical(classObj.Time_Zone__c);
             } 
            }
            }
         Logger.pop();
    }
    
    
     /**
     *@author Original: Shweta Shanbhag
     *@date Original: 27 January 2017
     *@description: Find the canonical timezone value from custom metadata
     */
    public string calctimezoneCanonical(String timezone){
        Logger.push('calctimezoneCanonical','ClassDml');
        String tzcanonical;
    
    	List<Training_Time_Zone_Canonical_Mapping__mdt> timezonecanonicalList = [select Id, Time_Zone__c, Canonical_Name__c from Training_Time_Zone_Canonical_Mapping__mdt where time_Zone__c =: timezone limit 1];
        if (timezonecanonicalList.size() >0)
             tzcanonical = timezonecanonicalList[0].Canonical_Name__c;

        Logger.pop();
        return tzcanonical;

    }
    
     /**
     *@author Original: Shweta Shanbhag
     *@date Original: 7 March 2017
     *@description: Populate read only fields and hidden field during cloning
     */
    public void classclone(List<Class__c> clssLst){
        Logger.push('classclone','ClassDml');
        Map<Id, Class__c> classcloneParentMap = new Map<Id, Class__c>();
        Set <Id> classcloneparentSet = new Set<Id>();
        List<Class__c> classcloneList = new List<Class__c>();
     
        for(Class__c classObj : clssLst){
               if(classObj.isClone())
               {	ClassCloneParentSet.add(classObj.getCloneSourceId() );
                    classcloneList.add(classObj);
               }   
           }
           if (ClassCloneParentSet.size() > 0)
           { 
               for (Class__c classobj: [SELECT Id, Course_Code__c, Class_Format__c FROM Class__c where id in: ClassCloneParentSet ])
            	{classcloneParentMap.put(classobj.id, classobj);}
           }    
          
          for(Class__c classObj : classcloneList){
                classObj.Class_Format__c = classcloneParentMap.get(classObj.getCloneSourceId()).Class_Format__c;
                classObj.Course_Code__c = classcloneParentMap.get(classObj.getCloneSourceId()).Course_Code__c; 
               classObj.Time_Zone_Canonical__c = calctimezoneCanonical(classObj.Time_Zone__c);
            }

        Logger.pop();

    }
    
    /**
     *@author Original: Shweta Shanbhag
     *@date Original: 7 March 2017
     *@description: Populate read only fields and hidden field during cloning
     */
    public void classsetInstructorUser(List<Class__c> clssLst){
        Logger.push('classsetInstructorUser','ClassDml');
 
        Map<Id, String> primaryInstMap = new Map<Id, String>();
        set<String> primaryInstEmails = new set<String>();
        Map<String, Id> InstrEmailUserIdMap = new Map<String, Id> ();       
		  
        for (Class__c classObj: clssLst){
            if(!primaryInstMap.containsKey(classObj.Id)){
                primaryInstMap.put(classObj.Id,classObj.primary_instructor_email__c);  
            }   
            primaryInstEmails.add(classObj.primary_instructor_email__c);
        }   
  
		if (!primaryInstEmails.isEmpty()){
   			 for (User usrObj:[Select Id, Email from User where email IN: primaryInstEmails AND UserType = 'Standard' ]){
    	 		if(!InstrEmailUserIdMap.containsKey(usrObj.email)){
                InstrEmailUserIdMap.put(usrObj.email,usrObj.Id);  
            	} 
    		}
		}      
        
        for(Class__c classObj : clssLst){            
            classObj.Instructor_User__c =   InstrEmailUserIdMap.get(classObj.primary_instructor_email__c);                        
       		 }
      
        Logger.pop();
    }
    
}