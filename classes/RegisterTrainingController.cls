/**
*   @author          Pranav Raulkar
*   @date            26/03/2016   getavailableClasses
*   @description     Enrollee Details Controller
*   @revision        1.0 - Initial version
*/
public without sharing class RegisterTrainingController {
    /** Public variable declaration section */
    public Boolean isEnrolleBlacklisted             { get; set; }
    public Boolean isEnrolleeFromAllowedDomain      { get; set; }
    public Boolean isNonExistentEnrollmentCode      { get; set; }
    public Boolean isInactiveEtaCode                { get; set; }
    public Boolean isEnrollmentCodeRevoked          { get; set; }
    public Boolean isValidEnrollmentCode            { get; set; }
    public Boolean isNewEnrollmentSuccess           { get; set; }

    public String  language                         { get; set; }

    public Enrollment_Code__c eCode                 { get; set; }

    @TestVisible private Map<Id, RequestWrapper> enrolledClassesMap   { get; set; }
    @TestVisible private Map<Id, RequestWrapper> availableClassesMap  { get; set; }
    
    public String enrollmentCode                   { get; set; }
    
    Training_Agreement_Settings__c tASSettings ;

    public String termEndDate  { get {
        String returnDate = '';
        if(eCode != null) {
            Date ted = eCode.Enterprise_Training_Agreement__r.Term_End_Date__c;
            returnDate = DateTime.newInstance(ted.year(), ted.month(), ted.day()).format('dd-MMM-yyyy');
        }
        return returnDate;
    } set; }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    Wrapper to hold class and it's course language details
    */
    without sharing class RequestWrapper implements Comparable {
        public Boolean isNewEnrollment { get; set; }
        public Enrollment__c enrollment { get; set; }
        public Class__c etaclass { get; set; }
        public Course__c course { get; set; }
        public Course_Language__c courseLanguage { get; set; }
        public Language_Display_Name__c lanDisplayName { get;set;}
        public Integer compareTo(Object compareTo) {
            RequestWrapper rw = (RequestWrapper) compareTo;
            //if(this.courseLanguage.Localized_Course_Name__c == rw.courseLanguage.Localized_Course_Name__c) return 0; 
            //if(this.courseLanguage.Localized_Course_Name__c > rw.courseLanguage.Localized_Course_Name__c) return 1; 
            if(this.courseLanguage.Course__r.Display_Sort_Order__c == rw.courseLanguage.Course__r.Display_Sort_Order__c) return 0; 
            if(this.courseLanguage.Course__r.Display_Sort_Order__c > rw.courseLanguage.Course__r.Display_Sort_Order__c) return 1; 
            return -1;
        }
    }
    
    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    Constructor
    */
    public RegisterTrainingController() {
        Logger.push('RegisterTrainingController', 'RegisterTrainingController');
        
        system.debug(UserInfo.getUserType());

        
        initializeVars();
        readURLParams();
        fetchEnrollmentCodeRecord();
        setPageLanguage();
        validateEnrollmentCode(eCode);

        if(isValidEnrollmentCode) {
            checkBlacklist();
            checkAllowedDomain();
            
            if(isEnrolleeFromAllowedDomain && !isEnrolleBlacklisted) {
                Map<Id, RequestWrapper> allClassesMap = getAllETAClasses();
                loadAvailableAndEnrolledClasses(allClassesMap);
            }
        }
        
        Logger.pop();
    }
    
    /**
    *    @author         Archana Suryawanshi
    *    @date           27/05/2016
    *    @description    Method to redirect any user with a Guest User profile to the Unauthenticated Self-Enrollment page if they attempt to browse to it directly
    */
    public Pagereference checkProfileType() {
        Logger.push('RegisterTrainingController', 'checkProfileType');
        
        if(UserInfo.getUserType()=='Guest'){
            
            //Fetching date from Training_Agreement_Settings__c  setting
            tASSettings = Training_Agreement_Settings__c.getInstance();
            PageReference forwardURL = new PageReference(tASSettings.Self_Enrollment_Unauthenticated_URL__c + enrollmentCode);
            forwardURL.setRedirect(true);
            return forwardURL;
            
        }
        else{
            return null;
        }
       
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    Method to initialize the class variables
    */
    private void initializeVars() {
        Logger.push('RegisterTrainingController', 'initializeVars');
        
        isEnrolleBlacklisted = false;
        isEnrolleeFromAllowedDomain = true;
        isNonExistentEnrollmentCode = false;
        isInactiveEtaCode = false;
        isEnrollmentCodeRevoked = false;
        isValidEnrollmentCode = false;
        isNewEnrollmentSuccess = false;

        enrolledClassesMap = new Map<Id, RequestWrapper>();
        availableClassesMap = new Map<Id, RequestWrapper>();

        Logger.pop();
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    Method to initialize the class variables
    */
    private void readURLParams() {
        Logger.push('RegisterTrainingController', 'readURLParams');
        // Get the code from URL
        enrollmentCode = ApexPages.currentPage().getParameters().get(TrainingUtil.ECODE_URL_PARAM_KEY);
        // Get the language from URL
        language = ApexPages.currentPage().getParameters().get(TrainingUtil.LANGUAGE_URL_PARAM_KEY);
        Logger.pop();
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    Method to initialize the class variables
    */
    private void fetchEnrollmentCodeRecord() {
        Logger.push('RegisterTrainingController', 'fetchEnrollmentCodeRecord');
        // Get the enrollment code from database
        eCode = TrainingUtil.getEnrollmentCode(enrollmentCode); 
        Logger.pop();
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    Deduce the language code that needs to be used for the page
    */
    private void setPageLanguage() {
        Logger.push('RegisterTrainingController', 'setPageLanguage');

        if(String.isEmpty(language) && eCode != null) {
            // If the language from URL is empty and we have a enrollment code, get ETA language
            language = eCode.Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c;

            if(String.isEmpty(language)) {
                // If there is no language code from URL or ETA, set default to English
                language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
            }
        } else if(!String.isEmpty(language) && !TrainingUtil.doesLanguageExist(language)) {
            // If there is no language code from URL or ETA, set default to English
            language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
        }

        Logger.pop();
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    This method checks for enrollee blacklisting for the ETA
    */
    private void checkBlacklist() {
        Logger.push('RegisterTrainingController', 'checkBlacklist');

        if(TrainingUtil.isEnrolleeBlacklisted(eCode.Enterprise_Training_Agreement__c, UserInfo.getUserEmail())) {
            isValidEnrollmentCode = false;
            isEnrolleBlacklisted = true;
        }

        Logger.pop();
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           13/04/2016
    *    @description    version: Pranav Raulkar: This method checks for allowed domains for ETA
    *                    version: Sagar Talele :updated for bulkified TrainingUtil method.
    */
    private void checkAllowedDomain() {
        Logger.push('RegisterTrainingController', 'checkAllowedDomain');
        
        //map of eta Id as key to enrollee as a key
        Map<Id,String> etaToEnrolleeEmailMap = new Map<Id,String>();
        //map of eta id as key to Email as key to is From allowed domain as value. 
        
        Map<id,Map<string,Boolean>> etaToEmailToIsAllowedMap = new Map<id,Map<string,Boolean>>();
        if(eCode.Enterprise_Training_Agreement__c != null){
            etaToEnrolleeEmailMap.put(eCode.Enterprise_Training_Agreement__c,UserInfo.getUserEmail());
            etaToEmailToIsAllowedMap = TrainingUtil.areEnrolleeFromAllowedDomain(etaToEnrolleeEmailMap);
            
            if(!etaToEmailToIsAllowedMap.containsKey(eCode.Enterprise_Training_Agreement__c)){
                isValidEnrollmentCode = false;
                isEnrolleeFromAllowedDomain = false;
            }
        }
        
        Logger.pop();
    }
    
    /*
        @author         Pranav Raulkar
        @date           26/03/2016
        @description    The method performs the enrollment code validation as per following -
                        1.  Check if enrollment code exists.
                        2.  Check if the enrollment code is valid (code active)
                        3.  Check if enrollment code's ETA is active
                        4.  Check if enrollment code is revoked
    */
    public void validateEnrollmentCode(Enrollment_Code__c eCode) {
        Logger.push('RegisterTrainingController', 'validateEnrollmentCode');

        TrainingUtil.ValidationStatus status = TrainingUtil.validateEnrollmentCode(eCode);
        
        if(status == TrainingUtil.ValidationStatus.NON_EXISTENT) {
            isNonExistentEnrollmentCode = true;
        } else if(status == TrainingUtil.ValidationStatus.VALID) {
            isValidEnrollmentCode = true;
        } else if(status == TrainingUtil.ValidationStatus.INACTIVE_ETA_CODE) {
            isInactiveEtaCode = true;
        } else if (status == TrainingUtil.ValidationStatus.REVOKED) {
            isEnrollmentCodeRevoked = true;
        }

        Logger.pop();
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           26/03/2016
    *    @description    Get all classes for an ETA assocaited via Training_Agreement_Class_Relationship
    *    @return         Map<Id, RequestWrapper>
    */
    public Map<Id, RequestWrapper> getAllETAClasses() {
        Logger.push('RegisterTrainingController', 'getAllETAClasses');

        Map<Id, Id> classCourseMap = new Map<Id, Id>();
        Map<Id, Id> courseClassMap = new Map<Id, Id>();
        Map<Id, RequestWrapper> requestWrapperMap = new Map<Id, RequestWrapper>();
        
        Map<String,List<Language_Display_Name__c>> langCodeTolangDisplayNameMap = new Map<String,List<Language_Display_Name__c>>();
        Language_Display_Name__c langDiplayName = new Language_Display_Name__c();
        for(Training_Agreement_Class_Relationship__c tacr : TrainingUtil.getTrainingAgreementClassRelationForETA(new Set<Id> { eCode.Enterprise_Training_Agreement__c })) {
            courseClassMap.put(tacr.Class__r.Course__c, tacr.Class__c);
            classCourseMap.put(tacr.Class__c, tacr.Class__r.Course__c);
        }

        Map<Id, Class__c> classMap = new Map<Id, Class__c>([SELECT Id, Course__c,Course_Code__c, CreatedDate, Open_Seats__c, 
                                                                Format_Of_Class__c, Language__r.Language_Code__c, 
                                                                Language__r.Name, Total_Seats_Taken__c, Language__r.Language_Display_Name__c,
                                                                 Language__r.ISO_Code__c
                                                            FROM Class__c 
                                                            WHERE Id IN :classCourseMap.keySet()
                                                            AND Status__c = :TrainingUtil.STATUS_ACTIVE]);
        Map<Id, Course__c> courseMap = new Map<Id, Course__c>([SELECT Id 
                                                                FROM Course__c 
                                                                WHERE Id IN :courseClassMap.keySet()]);
        Map<Id, Course_Language__c> courseLanguageMap = new Map<Id, Course_Language__c>();

        for(Course_Language__c courseLanguage : [SELECT Id, Localized_Course_Name__c, Localized_Short_Description__c,
                                                    Localized_Pre_Requisite__c, Course__c, Course_Language__r.Language_Display_Name__c,
                                                    Course_Language__r.Name, Course_Language__r.SF_ISO_Code__c, Course__r.Display_Sort_Order__c,
                                                    Course_Language__r.ISO_Code__c
                                                    
                                                FROM Course_Language__c 
                                                WHERE Course__c IN :courseClassMap.keySet() 
                                                AND Course_Language__r.SF_ISO_Code__c = :language]) {
            courseLanguageMap.put(courseLanguage.Course__c, courseLanguage);
        }
        
        for(Language_Display_Name__c langObj : [Select Id, Display_Name__c,Language__c,Language_code__c,Language__r.SF_ISO_Code__c,
                                                Language__r.ISO_Code__c
                                                From Language_Display_Name__c where Language__r.SF_ISO_Code__c =:language ]){
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
        system.debug('**language**'+language);
        system.debug('**langCodeTolangDisplayNameMap**'+langCodeTolangDisplayNameMap);
        for(Id classId : classMap.keySet()) {
            Class__c etaclass = classMap.get(classId);
            Course__c course = courseMap.get(etaclass.Course__c);
            Course_Language__c courseLanguage = courseLanguageMap.get(course.Id);
            List<Language_Display_Name__c> langDiplayNameList = NULL;
            langDiplayNameList = langCodeTolangDisplayNameMap.get(courseLanguage.Course_Language__r.ISO_Code__c);
            system.debug('*courseLanguage.Course_Language__r.ISO_Code__c*'+courseLanguage.Course_Language__r.ISO_Code__c);
            system.debug('*langDiplayNameList *'+langDiplayNameList );
            if(langDiplayNameList == NULL){
                langDiplayNameList = langCodeTolangDisplayNameMap.get(TrainingUtil.DEFAULT_LANGUAGE_ISOCODE);
            }
            system.debug('*langDiplayNameList*'+langDiplayNameList);
            for(Language_Display_Name__c obj: langDiplayNameList){
                  if(obj.Language_code__c == etaclass.Language__r.ISO_Code__c && (obj.Language__r.SF_ISO_Code__c == language || obj.Language__r.SF_ISO_Code__c ==TrainingUtil.DEFAULT_LANGUAGE_CODE)){
                    langDiplayName = obj;
                }
            
            }
            system.debug('**langDiplayName**'+langDiplayName);
            RequestWrapper rw = new RequestWrapper();
            rw.isNewEnrollment = false;
            rw.etaclass = etaclass;
            rw.course = course;
            rw.courseLanguage = courseLanguage;
            rw.lanDisplayName = langDiplayName;
            requestWrapperMap.put(etaclass.Id, rw);
        }

        Logger.pop();

        return requestWrapperMap;
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           26/03/2016
    *    @description    Get all enrolled classes for an ETA where the logged in user has registered
    *    @return         Map<Id, RequestWrapper>
    */
    public void loadAvailableAndEnrolledClasses(Map<Id, RequestWrapper> allClassesMap) {
        Logger.push('RegisterTrainingController' , 'loadAvailableAndEnrolledClasses');
        Language_Display_Name__c langDiplayName = new Language_Display_Name__c();
        Map<String,List<Language_Display_Name__c>> langCodeTolangDisplayNameMap = new Map<String,List<Language_Display_Name__c>>();
        Map<Id, List<Enrollment__c>> etaEnrollmentMap = TrainingUtil.getEnrollmentsForETA(new Set<Id> { eCode.Enterprise_Training_Agreement__c }, 
                                                                                            new Set<String> { UserInfo.getUserEmail() },
                                                                                            'Registered');
        
        if(etaEnrollmentMap.size() > 0 && etaEnrollmentMap.containsKey(eCode.Enterprise_Training_Agreement__c)) {
            Map<Id, Id> classCourseMap = new Map<Id, Id>();
            Map<Id, Id> courseClassMap = new Map<Id, Id>();
            Map<Id, Enrollment__c> enrollmentMap = new Map<Id, Enrollment__c>();

            for(Enrollment__c enrollment : etaEnrollmentMap.get(eCode.Enterprise_Training_Agreement__c)) {
                courseClassMap.put(enrollment.Class__r.Course__c, enrollment.Class__c);
                classCourseMap.put(enrollment.Class__c, enrollment.Class__r.Course__c);
                enrollmentMap.put(enrollment.Class__c, enrollment);
            }

            Map<Id, Class__c> classMap = new Map<Id, Class__c>([SELECT Id, Course__c, Course_Code__c,Open_Seats__c, 
                                                                    Format_Of_Class__c, Language__r.Name,Language__r.Language_Code__c, 
                                                                    Total_Seats_Taken__c, Language__r.Language_Display_Name__c,
                                                                    Language__r.ISO_Code__c
                                                                FROM Class__c 
                                                                WHERE Id IN :classCourseMap.keySet()
                                                                AND Status__c = :TrainingUtil.STATUS_ACTIVE]);
            Map<Id, Course__c> courseMap = new Map<Id, Course__c>([SELECT Id 
                                                                    FROM Course__c 
                                                                    WHERE Id IN :courseClassMap.keySet()]);
            Map<Id, Course_Language__c> courseLanguageMap = new Map<Id, Course_Language__c>();

            for(Course_Language__c courseLanguage : [SELECT Id, Localized_Course_Name__c, Localized_Short_Description__c,
                                                        Localized_Pre_Requisite__c, Course__c, Course_Language__r.Name,
                                                        Course_Language__r.Language_Display_Name__c, Course__r.Display_Sort_Order__c,
                                                        Course_Language__r.ISO_Code__c
                                                    FROM Course_Language__c 
                                                    WHERE Course__c IN :courseClassMap.keySet() 
                                                    AND Course_Language__r.SF_ISO_Code__c = :language]) {
                courseLanguageMap.put(courseLanguage.Course__c, courseLanguage);
            }
            
            for(Language_Display_Name__c langObj : [Select Id, Display_Name__c,Language__c,Language_code__c,Language__r.SF_ISO_Code__c,
                                                Language__r.ISO_Code__c
                                                From Language_Display_Name__c where Language__r.SF_ISO_Code__c =:language ]){
                if(!langCodeTolangDisplayNameMap.ContainsKey(langObj.Language__r.ISO_Code__c) ){
                    langCodeTolangDisplayNameMap.put(langObj.Language__r.ISO_Code__c,new List<Language_Display_Name__c>{langObj});
                }else{
                    langCodeTolangDisplayNameMap.get(langObj.Language__r.ISO_Code__c).add(langObj);
                }
            
            
            }
            //if langauge display name dose n0t exist based on eta then use default language
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
        system.debug('**language**'+language);
        system.debug('**langCodeTolangDisplayNameMap**'+langCodeTolangDisplayNameMap);
            for(Id classId : classMap.keySet()) {
                Class__c etaclass = classMap.get(classId);
                Course__c course = courseMap.get(etaclass.Course__c);
                Course_Language__c courseLanguage = courseLanguageMap.get(course.Id);
                List<Language_Display_Name__c> langDiplayNameList = NULL;
                langDiplayNameList = langCodeTolangDisplayNameMap.get(courseLanguage.Course_Language__r.ISO_Code__c);
                system.debug('*courseLanguage.Course_Language__r.ISO_Code__c*'+courseLanguage.Course_Language__r.ISO_Code__c);
                system.debug('*langDiplayNameList *'+langDiplayNameList );
                if(langDiplayNameList == NULL ){
                    langDiplayNameList = langCodeTolangDisplayNameMap.get(TrainingUtil.DEFAULT_LANGUAGE_ISOCODE);
                }
                for(Language_Display_Name__c obj: langDiplayNameList){
                      if(obj.Language_code__c == etaclass.Language__r.ISO_Code__c && (obj.Language__r.SF_ISO_Code__c == language || obj.Language__r.SF_ISO_Code__c ==TrainingUtil.DEFAULT_LANGUAGE_CODE)){
                        langDiplayName = obj;
                    }
                
                }
                system.debug('**langDiplayName**'+langDiplayName);
                RequestWrapper rw = new RequestWrapper();
                rw.isNewEnrollment = false;
                rw.etaclass = etaclass;
                rw.course = course;
                rw.courseLanguage = courseLanguage;
                rw.enrollment = enrollmentMap.get(classId);
                rw.lanDisplayName = langDiplayName;
                enrolledClassesMap.put(etaclass.Id, rw);
            }
        }

        // Get a map of <ETA, <Class, Enrollmentcount>>
        Map<Id, Map<Id, Integer>> etaClassCountMap = TrainingUtil.getConsumedSeatCountForETA(new Set<Id> { eCode.Enterprise_Training_Agreement__c }, 
                                                                                             allClassesMap.keySet());

        // Get ETA record type ids for Seat Based and Unlimited ETA
        Id seatBasedEtaRtId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
        Id unlimitedEtaRtId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Unlimited').getRecordTypeId();

        for(Id classId : allClassesMap.keySet()) {
            if(!enrolledClassesMap.containsKey(classId)) {
                RequestWrapper rw = allClassesMap.get(classId);
                // Process the class if we have a seat based ETA
                if(seatBasedEtaRtId == eCode.Enterprise_Training_Agreement__r.RecordTypeId) {
                    Integer seatsTaken = 0;

                    if(etaClassCountMap.get(eCode.Enterprise_Training_Agreement__c) != null) {
                        seatsTaken = etaClassCountMap.get(eCode.Enterprise_Training_Agreement__c).get(classId);
                        seatsTaken = (seatsTaken == null ? 0 : seatsTaken);
                    }
                    
                    // add to available class only if the total enrollments for this class < max seats on eta
                    if(seatsTaken == 0 || seatsTaken < eCode.Enterprise_Training_Agreement__r.Max_Seats__c) {
                        availableClassesMap.put(classId, allClassesMap.get(classId));
                    }                    
                } else if(unlimitedEtaRtId == eCode.Enterprise_Training_Agreement__r.RecordTypeId) {
                    // Process the class if we have a unlimited ETA
                    availableClassesMap.put(classId, allClassesMap.get(classId));
                }                
            }
        }

        Logger.pop();
    }

    public Integer getEnrolledClassCount() {
        return (enrolledClassesMap == null ? 0 : enrolledClassesMap.keySet().size());
    }

    public Integer getAvailableClassCount() {
        return (availableClassesMap == null ? 0 : availableClassesMap.keySet().size());
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           04-May-2016
    *    @description    Prepares the sorted list of available classes from the available classes map
    *    @return         List<RequestWrapper>
    */
    public List<RequestWrapper> getAvailableClasses() {
        Logger.push('RegisterTrainingController', 'getAvailableClasses');

        List<RequestWrapper> rwList = new List<RequestWrapper>();
        if(!availableClassesMap.isEmpty()) {
            rwList = availableClassesMap.values();
            rwList.sort();
        }

        Logger.pop();

        return rwList;
    }

    /**
    *    @author         Pranav Raulkar
    *    @date           04-May-2016
    *    @description    Prepares the sorted list of enrolled classes from the enrolled classes map
    *    @return         List<RequestWrapper>
    */
    public List<RequestWrapper> getEnrolledClasses() {
        Logger.push('RegisterTrainingController', 'getEnrolledClasses');

        List<RequestWrapper> rwList = new List<RequestWrapper>();
        if(!enrolledClassesMap.isEmpty()) {
            rwList = enrolledClassesMap.values();
            rwList.sort();
        }

        Logger.pop();

        return rwList;
    }

    /*
        @author         Pranav Raulkar
        @date           6/04/2016
        @description    
    */
    public void enrollForNewClasses() {
        Logger.push('RegisterTrainingController', 'enrollForNewClasses');

        isNewEnrollmentSuccess = false;

        Set<String> emailSet = new Set<String>();
        emailSet.add(UserInfo.getUserEmail());

        List<Enrollment_Request__c> newEnrollReqList = new List<Enrollment_Request__c>();
        for(RequestWrapper cw : availableClassesMap.values()) {
            if(cw.isNewEnrollment) {
                Enrollment_Request__c enrollReq = new Enrollment_Request__c();
                enrollReq.Class__c = cw.etaclass.Id;
                enrollReq.First_Name__c = UserInfo.getFirstname();
                enrollReq.Last_Name__c = UserInfo.getLastName();
                enrollReq.Email__c = UserInfo.getUserEmail();
                enrollReq.Enrollment_Code__c = eCode.Code__c;
                enrollReq.Enterprise_Training_Agreement__c = eCode.Enterprise_Training_Agreement__c;
                enrollReq.Status__c = 'New';
                //enrollReq.Batch_ID__c = eCode.Code__c;
                enrollReq.Source__c = 'Self-Enrollment Portal';
                enrollReq.Contact__c = TrainingUtil.getLoggedInUserContactIds(emailSet).get(UserInfo.getUserEmail());
                enrollReq.Class_Format__c = cw.etaclass.Format_Of_Class__c;
                enrollReq.Course_Code__c = cw.etaclass.Course_Code__c;
                enrollReq.Language_Code__c = cw.etaclass.Language__r.Language_Code__c;
                cw.isNewEnrollment = false;

                newEnrollReqList.add(enrollReq);
            }
        }

        if(!newEnrollReqList.isEmpty()) {
            try {
                insert newEnrollReqList;
                isNewEnrollmentSuccess = true;
            } catch(DmlException dmlEx) {
                Logger.debugException(dmlEx);
            }
        }

        Logger.pop();    
    }

    /*
        @author         Pranav Raulkar
        @date           22/04/2016
        @description    This method constructs the logout URL and redirects the user to the URL.
    */
    public String getLogoutURL() {
        Logger.push('RegisterTrainingController', 'getLogoutURL');
        String logoutURL = String.format(System.Label.CP_ENROLL_SSOLogoutURL, new List<String> { enrollmentCode, language });
        Logger.pop();

        return logoutURL;
    }

    /*
        @author         Pranav Raulkar
        @date           26/03/2016
        @description    The method initializes the class variables and performs the enrollment code validation.
    */
    public void checkEnrollmentCode() {
        Logger.push('RegisterTrainingController', 'checkEnrollmentCode');
        
        
        initializeVars();
        fetchEnrollmentCodeRecord();
        setPageLanguage();
        validateEnrollmentCode(eCode);

        if(isValidEnrollmentCode) {
            checkBlacklist();
            checkAllowedDomain();
            
            if(isEnrolleeFromAllowedDomain && !isEnrolleBlacklisted) {
                Map<Id, RequestWrapper> allClassesMap = getAllETAClasses();
                loadAvailableAndEnrolledClasses(allClassesMap);
            }
        }

        Logger.pop();
    }
}