/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
 *@date Original: 13 May 2016, Last Modified: 15 December 2016
 *@description: This Class getting the value of Eta related values
 */
public Class TCNotificationController{
    public Enterprise_Training_Agreement__c etaObj {get;set;}
    public String etaId {get;set;}
     public String lang {get;set;}
    /**
    *    @author         Sagar Talele
    *    @date           7 July 2016
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
     *@date Original: 5 July 2016, Last Modified: 5 July 2016
     *@description: This method is for getting the value of ETA Record
     */
    public String getEnrollName() {
    String enrolleeName='';
        etaObj = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_End_Date__c,
                  	Term_Start_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c
                    where Id =:etaId ];
        if(etaObj !=null){
            if(etaObj.Language__r.SF_ISO_Code__c == 'ja'){
                enrolleeName = etaObj.Primary_Contact__r.LastName + ' '+etaObj.Primary_Contact__r.FirstName;
            }
            else{
                enrolleeName = etaObj.Primary_Contact__r.Name;
            }             
        }
        System.debug('**etaEnrollName**'+etaObj);
        return enrolleeName;
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag
     *@date Original: 5 July 2016, Last Modified: 15 December 2016,
     *@description: This method is for getting the value of TAH AGREEMENT EXPIRY; SS - changed for Story:1837839
     */
    public String getEtaExpiryDate() {
       String returnDate = '';
       date expiryDate = etaObj.Term_End_Date__c;
         returnDate = DateTime.newInstance(expiryDate.year(), expiryDate.month(), expiryDate.day()).format('dd-MMM-yyyy');
        return returnDate ;
    } 
    
     /**
     *@author Original: Shweta Shanbhag - Mathworks, Last Modified: Shweta Shanbhag - Mathworks
     *@date Original: 12 Sep 2016, Last Modified: 12 Sep 2016
     *@description: This method is for getting the value of ETA Start Date;SS - changed for Story:1837839
     */
    public String getEtaStartDate() {
       String returnStDate = '';
       date StartDate = etaObj.Term_Start_Date__c;
       returnStDate = DateTime.newInstance(StartDate.year(), StartDate.month(), StartDate.day()).format('dd-MMM-yyyy');
       return returnStDate ;
    } 
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - MathWorks
     *@date Original: 5 July 2016, Last Modified: 25 August 2016
     *@description: This method is for getting the value of courses for the related to the eta
     */
    public String getRelatedEtaCourses(){
       List<Training_Agreement_Class_Relationship__c> trainAgrRelList = new List<Training_Agreement_Class_Relationship__c>();
       Map<Id, Id> courseClassMap = new Map<Id, Id>();
       Map<Id, Id> classCourseMap = new Map<Id, Id>();    
       Language_Display_Name__c langDisplayName = new Language_Display_Name__c();
       List<Course_Language__c> courseLangList = new List<Course_Language__c>();
       Map<Id, Course_Language__c> courseLanguageMap = new Map<Id, Course_Language__c>();
       Map<String,List<Language_Display_Name__c>> langCodeTolangDisplayNameMap = new Map<String,List<Language_Display_Name__c>>(); 
       String courseStr = '';
       
        trainAgrRelList = [Select Class__r.Course__r.Name 
                        From Training_Agreement_Class_Relationship__c 
                            Where Enterprise_Training_Agreement__c =:etaId];
        
        
        
        for(Training_Agreement_Class_Relationship__c trainAgrObj : trainAgrRelList){
            courseClassMap.put(trainAgrObj.Class__r.Course__c, trainAgrObj.Class__c);
            classCourseMap.put(trainAgrObj.Class__c, trainAgrObj.Class__r.Course__c);          
        }
        
         Map<Id, Course__c> courseMap = new Map<Id, Course__c>([SELECT Id 
                                                                FROM Course__c 
                                                                WHERE Id IN :courseClassMap.keySet()]);
        
         Map<Id, Class__c> classMap = new Map<Id, Class__c>([SELECT Id, Course__c, Course_Code__c, Language__r.Name,
                                                              Language__r.Language_Code__c, 
                                                              Language__r.Language_Display_Name__c,
                                                              Language__r.ISO_Code__c
                                                              FROM Class__c 
                                                              WHERE Id IN :classCourseMap.keySet()]);
        
        courseLangList = [Select Id,Localized_Course_Name__c, Course__c, Course_Language__c, 
                          Course_Language__r.SF_ISO_Code__c,Course_Language__r.ISO_Code__c, Course_Language__r.Language_Display_Name__c
                          From Course_Language__c 
                          where Course__c IN: courseClassMap.keySet()  
                          And Course_Language__r.SF_ISO_Code__c =:etaObj.Language__r.SF_ISO_Code__c];
        
        
		for(Course_Language__c courseLanObj : courseLangList){
        	courseLanguageMap.put(courseLanObj.Course__c, courseLanObj);	
        }
        system.debug('***ETA Language***'+etaObj.Language__r.SF_ISO_Code__c );
        
         for(Language_Display_Name__c langObj : [Select Id, Display_Name__c,Language__c,Language_code__c,
                                                Language__r.SF_ISO_Code__c,Language__r.ISO_Code__c
                                                From Language_Display_Name__c 
                                                where Language__r.SF_ISO_Code__c =: etaObj.Language__r.SF_ISO_Code__c])
        		{
                if(!langCodeTolangDisplayNameMap.ContainsKey(langObj.Language__r.ISO_Code__c) ){
                    langCodeTolangDisplayNameMap.put(langObj.Language__r.ISO_Code__c,new List<Language_Display_Name__c>{langObj});
                }else{
                    langCodeTolangDisplayNameMap.get(langObj.Language__r.ISO_Code__c).add(langObj);
                }
           
              }
        
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
                      if(obj.Language_code__c == etaclass.Language__r.ISO_Code__c && (obj.Language__r.SF_ISO_Code__c == etaObj.Language__r.SF_ISO_Code__c || obj.Language__r.SF_ISO_Code__c ==TrainingUtil.DEFAULT_LANGUAGE_CODE)){
                        langDisplayName = obj;
                    }
                
                }
             courseStr = courseStr + courseLanguage.Localized_Course_Name__c + ' ('+ langDisplayName.Display_Name__c + ')' + '<br/>';
         }
        
        return courseStr;
    }
}