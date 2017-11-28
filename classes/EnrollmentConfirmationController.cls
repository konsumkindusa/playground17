/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
 *@date Original: 13 May 2016, Last Modified: 15 December 2016
 *@description: This method is for getting the value of Enrollment record
 */
public without sharing class EnrollmentConfirmationController {
    public String enrollReqId {get;set;}
    public String lang {get;set;}
    public Enrollment_Request__c enrollReq {get;set;}
    //get value from custom setting for Template Name
    Training_Agreement_Settings__c setting = Training_Agreement_Settings__c.getInstance();
    
    /**
    *    @author         Sagar Talele
    *    @date           23 May 2016
    *    @description    get the language code which is used on Visualforce page to set the language of the page
    */
    public String  language { 
        get{
            If(lang!= null || !String.isEmpty(lang)){
                language = lang;
                if(!String.isEmpty(language) && !TrainingUtil.doesLanguageExist(language)) {
                    // If there is no language code from URL or ETA, set default to English
                    language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
                }
            }else{
                language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
            }
            return language;
        }
        set{
           
        }
    }
   /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 13 May 2016, Last Modified: 13 May 2016
     *@description: This method is for getting the value of Enrollment record
     */
    public String getEnrollName() {
    String enrolleeName='';
        enrollReq = [Select Id,Name,Contact__r.Name,Contact__r.Account.Name,
                            Enterprise_Training_Agreement__c,
                            Batch_ID__c,
                            Status__c,
                            Contact__c,
                            contact__r.LastName, contact__r.FirstName,
                            Enterprise_Training_Agreement__r.Account_Name__r.Name,
                            Enterprise_Training_Agreement__r.Name,Course_Code__c,
                            Enterprise_Training_Agreement__r.Term_End_Date__c,
                            Enterprise_Training_Agreement__r.Sponsor_Office__r.Phone__c,
                            Enterprise_Training_Agreement__r.Sponsor_Office__r.Email__c,
                            Enterprise_Training_Agreement__r.Sponsor_Office__r.Signature__c,
                            Enterprise_Training_Agreement__r.Sponsor_Office__r.Training_URL__c,
                            Enterprise_Training_Agreement__r.Sponsor_Office__r.FAQ_Link__c,
                            Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c,
                            Enterprise_Training_Agreement__r.Sponsor_Office__r.MATLAB_Academy_URL__c,
                            Language_ISO_Code__c
                     From Enrollment_Request__c
                     where Id =:enrollReqId ];
        if(enrollReq!=null){
            if(enrollReq.Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c == 'ja'){
                enrolleeName = enrollReq.contact__r.LastName + ' '+enrollReq.contact__r.FirstName;
            }
            else{
                enrolleeName = enrollReq.Contact__r.Name;
            }             
        }
        System.debug('**EnrollmentConfirmationControllergetEnrollName**'+enrollReq);
        return enrolleeName;
    }
    
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag
     *@date Original: 13 May 2016, Last Modified: 15 December 2016
     *@description: This method is for getting the value of termEndDate; SS - changed for story: 1837839
     */
    public String getTermEndDate() {
       String returnDate = '';
       date termEndDate = enrollReq.Enterprise_Training_Agreement__r.Term_End_Date__c;
         returnDate = DateTime.newInstance(termEndDate.year(), termEndDate.month(), termEndDate.day()).format('dd-MMM-yyyy');
        return returnDate ;
    } 
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
     *@date Original: 13 May 2016, Last Modified: 29 July 2016
     *@description: This method is for getting the value of courses for the related to the eta
     *@Updated: SS 08/02/16- 1613656 - display course names from course lang
     */
     public String getRelatedEtaCourses(){
       List<Enrollment_Request__c> enrollReqList = new List<Enrollment_Request__c>();
       Map<Id, Id> courseClassMap = new Map<Id, Id>();
       Map<Id, Id> classCourseMap = new Map<Id, Id>();
       Language_Display_Name__c langDisplayName = new Language_Display_Name__c();
       Map<Id, Course_Language__c> courseLanguageMap = new Map<Id, Course_Language__c>();
       Map<String,List<Language_Display_Name__c>> langCodeTolangDisplayNameMap = new Map<String,List<Language_Display_Name__c>>(); 
       String courseStr = '';
       Enrollment_Request__c enrollreqobj2; 
         
       enrollReqList = [Select Id,Contact__c,Status__c,Batch_ID__c,Enterprise_Training_Agreement__c,
                        Enterprise_Training_Agreement__r.Language__c, Class__r.Course__c,Class__c,
                        Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c
                        FROM Enrollment_Request__c 
                        Where Contact__c =: enrollReq.Contact__c 
                        AND Status__c = 'Pending Notification'
                        AND  Enterprise_Training_Agreement__c =: enrollReq.Enterprise_Training_Agreement__c 
                        AND Batch_ID__c =: enrollReq.Batch_ID__c];
         
        System.debug('**enrollReqListgetRelatedEtaCourses**'+enrollReqList);
         
        if (enrollReqList.size() >0)
        {
         
        for(Enrollment_Request__c enrollReqObj: enrollReqList){        
            courseClassMap.put(enrollReqObj.Class__r.Course__c, enrollReqObj.Class__c);
            classCourseMap.put(enrollReqObj.Class__c, enrollReqObj.Class__r.Course__c);
        }
 		
         
         enrollreqObj2 = enrollReqList.get(0); //To get training agreement language
                 
         Map<Id, Course__c> courseMap = new Map<Id, Course__c>([SELECT Id 
                                                                FROM Course__c 
                                                                WHERE Id IN :courseClassMap.keySet()]);
         
         Map<Id, Class__c> classMap = new Map<Id, Class__c>([SELECT Id, Course__c, Course_Code__c, Language__r.Name,
                                                              Language__r.Language_Code__c, 
                                                              Language__r.Language_Display_Name__c,
                                                              Language__r.ISO_Code__c
                                                              FROM Class__c 
                                                              WHERE Id IN :classCourseMap.keySet()]);
 
      
         for(Course_Language__c courseLanguage : [SELECT Id, Localized_Course_Name__c, 
                                                  Course__c, Course_Language__r.Language_Display_Name__c,
                                                  Course_Language__r.Name, Course_Language__r.SF_ISO_Code__c, 
                                                  Course_Language__r.ISO_Code__c                                       
                                                  FROM Course_Language__c
                                                  WHERE Course__c IN :courseClassMap.keySet() 
                                                  AND Course_Language__r.SF_ISO_Code__c = :enrollreqObj2.Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c]) 
         {
            courseLanguageMap.put(courseLanguage.Course__c, courseLanguage);
         }
          
        
            
        for(Language_Display_Name__c langObj : [Select Id, Display_Name__c,Language__c,Language_code__c,
                                                Language__r.SF_ISO_Code__c,Language__r.ISO_Code__c
                                                From Language_Display_Name__c 
                                                where Language__r.SF_ISO_Code__c =: enrollreqObj2.Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c])
        		{
                if(!langCodeTolangDisplayNameMap.ContainsKey(langObj.Language__r.ISO_Code__c) ){
                    langCodeTolangDisplayNameMap.put(langObj.Language__r.ISO_Code__c,new List<Language_Display_Name__c>{langObj});
                }else{
                    langCodeTolangDisplayNameMap.get(langObj.Language__r.ISO_Code__c).add(langObj);
                }
           
              }
         
          //if langauge display name dose not exist based on eta then use default language
           // if(langCodeTolangDisplayNameMap== null && langCodeTolangDisplayNameMap.size() == 0){
            if(langCodeTolangDisplayNameMap!= null && langCodeTolangDisplayNameMap.size() == 0){
                
                for(Language_Display_Name__c langObj : [Select Id, Display_Name__c,Language__c,Language_code__c,Language__r.SF_ISO_Code__c,
                                                    Language__r.ISO_Code__c
                                                    From Language_Display_Name__c where Language__r.SF_ISO_Code__c =:TrainingUtil.DEFAULT_LANGUAGE_CODE]){
                    if(!langCodeTolangDisplayNameMap.ContainsKey(langObj.Language__r.ISO_Code__c) ){
                        langCodeTolangDisplayNameMap.put(langObj.Language__r.ISO_Code__c,new List<Language_Display_Name__c>{langObj});
                    }else{
                        langCodeTolangDisplayNameMap.get(langObj.Language__r.ISO_Code__c).add(langObj);
                    }
                 
                }
            }
         System.debug('***langCodeTolangDisplayNameMap***'+langCodeTolangDisplayNameMap);
              
         for(Id classId : classMap.keySet()) {
                Class__c etaclass = classMap.get(classId);
                Course__c course = courseMap.get(etaclass.Course__c);
                Course_Language__c courseLanguage = courseLanguageMap.get(course.Id);
                List<Language_Display_Name__c> langDisplayNameList = NULL;
                langDisplayNameList = langCodeTolangDisplayNameMap.get(courseLanguage.Course_Language__r.ISO_Code__c);
                
                if(langDisplayNameList == NULL ){
                    langDisplayNameList = langCodeTolangDisplayNameMap.get(TrainingUtil.DEFAULT_LANGUAGE_ISOCODE);
                }
                for(Language_Display_Name__c obj: langDisplayNameList){
                      if(obj.Language_code__c == etaclass.Language__r.ISO_Code__c && (obj.Language__r.SF_ISO_Code__c == enrollreqObj2.Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c || obj.Language__r.SF_ISO_Code__c ==TrainingUtil.DEFAULT_LANGUAGE_CODE)){
                        langDisplayName = obj;
                    }
                
                }
             courseStr = courseStr + courseLanguage.Localized_Course_Name__c + ' ('+ langDisplayName.Display_Name__c + ')' + '<br/>';
         }
        }
        return courseStr ;
    }
    /**
    *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
    *@date Original: 13 May 2016, Last Modified: 13 May 2016
    *@description: This method is for getting the value of Training Url
    */
    public String getTrainingUrl(){
        if(enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.Training_URL__c != null && 
                enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.Training_URL__c != '' ){
                return enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.Training_URL__c;
        }else{
                //String s setting.Mw_Local_Training_Url_to_Default_Traini__c;
                return setting.Mw_Local_Training_Url_to_Default_Traini__c;
        }
        
    }
    /**
    *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
    *@date Original: 10 June 2016, Last Modified: 13 May 2016
    *@description: This method is for getting the value of MATLAB Academy URL
    */
    public String getMatlabAcademyUrl(){
        if(enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.MATLAB_Academy_URL__c != null && 
                enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.MATLAB_Academy_URL__c != '' ){
                return enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.MATLAB_Academy_URL__c;
        }else{
                return setting.Account_Academy_Login_Url_to_MATLAB_Acad__c;
        }
    }
      /**
    *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
    *@date Original: 29 July 2016, Last Modified: 29 July 2016
    *@description: This method is for getting the value of FAQ Page URL
    */
    public String getFAQPageUrl(){
        if(enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.FAQ_Link__c != null && 
                enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.FAQ_Link__c != '' ){
                return enrollReq.Enterprise_Training_Agreement__r.Sponsor_Office__r.FAQ_Link__c;
        }else{
                return setting.FAQ_Page_Url__c;
                
        }
    }
}