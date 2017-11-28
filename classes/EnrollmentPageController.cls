/**
* @author       Pranav Raulkar
* @date         27-May-2016
* @description  
* @revision     Initial version
*/
public with sharing class EnrollmentPageController {
    public Boolean isError      { get; set; }

    public Boolean showETALookup    { get; set; }
    public Boolean showClassLookup  { get; set; }

    public Enrollment__c enrollment                 { get; set; }
    public Enrollment_Request__c enrollmentRequest  { get; set; }

    // URL Parameters
    public String retURL        { get; set; }
    public String enrolleeId    { get; set; }
    public String etaId         { get; set; }
    public String classId       { get; set; }
    public String errorMessage  { get; set; }

    // Table maps
    public Map<Id, RequestWrapper> enrolledClassesMap   { get; set; }
    public Map<Id, RequestWrapper> availableClassesMap  { get; set; }

    // Wrapper for listing classes associated witl ETA and available for enrollment
    @testvisible
    class RequestWrapper implements Comparable {
        public Boolean isNewEnrollment { get; set; }
        public Enrollment__c enrollment { get; set; }
        public Class__c etaclass { get; set; }
        public Course__c course { get; set; }
        public Course_Language__c courseLanguage { get; set; }

        public Integer compareTo(Object compareTo) {
            RequestWrapper rw = (RequestWrapper) compareTo;
            if(this.courseLanguage.Localized_Course_Name__c == rw.courseLanguage.Localized_Course_Name__c) return 0; 
            if(this.courseLanguage.Localized_Course_Name__c > rw.courseLanguage.Localized_Course_Name__c) return 1; 
            return -1;
        }
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  Constructor.
    * @revision     Initial version
    */
    public EnrollmentPageController() {
        Logger.push('EnrollmentPageController', 'EnrollmentPageController');

        readURLParams();
        initVars(); 
        updateVisibility(); 

        Logger.pop();
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  This method intializes variables.
    * @revision     Initial version
    */
    private void initVars() {
        Logger.push('EnrollmentPageController', 'initVars');

        // Initialize enrollmrnt assuming we have a Enrollee and a specific Class selected
        enrollment = new Enrollment__c();
        
        // Initialize Enrollment Request assuming we have a Enrollee and ETA with multiple Classes selected
        // The lookups on the page are controlled by enrollmentRequest, hence initializing them on load if 
        // the id's are passed via URL 
        enrollmentRequest = new Enrollment_Request__c();
        enrollmentRequest.Contact__c = enrolleeId;
        enrollmentRequest.Enterprise_Training_Agreement__c = etaId;
        enrollmentRequest.Class__c = classId;

        enrolledClassesMap = new Map<Id, RequestWrapper>();
        availableClassesMap = new Map<Id, RequestWrapper>();

        isError = false;
        errorMessage = '';

        Logger.pop();
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  This method reads the URL parameters and inits class variables.
    * @revision     Initial version
    */
    private void readURLParams() {
        Logger.push('EnrollmentPageController', 'readURLParams');

        Map<String, String> pageParams = ApexPages.currentPage().getParameters();

        // In case we have come from the tab, return URL is home page
        retURL      = (pageParams.get('retURL') == null ? '/home/home.jsp' : pageParams.get('retURL'));
        enrolleeId  = pageParams.get('en');
        etaId       = pageParams.get('ea');
        classId     = pageParams.get('cl');

        Logger.pop();
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  This method updates the variables controlling the visibility of ETA and Class content on page
    * @revision     Initial version
    */
    public void updateVisibility() {
        Logger.push('EnrollmentPageController', 'updateVisibility');

        isError = false;
        errorMessage = '';
        
        enrolledClassesMap.clear();
        availableClassesMap.clear();

        if(enrollmentRequest.Enterprise_Training_Agreement__c == null && enrollmentRequest.Class__c == null) {
            showETALookup = true;
            showClassLookup = true;
        } else if(enrollmentRequest.Enterprise_Training_Agreement__c != null && enrollmentRequest.Class__c == null) {
            showETALookup = true;
            showClassLookup = false;
            
            if(enrollmentRequest.Contact__c!= null){
                // Check for allowed domain and blacklist
                Boolean isBlacklisted = isEnrolleBlacklisted();
                Boolean isAllowedDomain = isEnrolleFromAllowedDomain();
    
                if(isBlacklisted) {
                    isError = true;
                    errorMessage = System.Label.CP_ENROLL_BlacklistedEnrollee;
                } 
    
                if(!isAllowedDomain) {
                    Enterprise_Training_Agreement__c eta = getETARecord();
                    isError = true;
                    errorMessage = String.format(System.Label.CP_ENROLL_EmailNotInAllowedDomain, new List<String> { eta.Account_Name__r.Name, eta.Account_Name__r.Name });
                } 
    
                if(!isBlacklisted && isAllowedDomain && enrollmentRequest.Contact__c != null) {
                    Map<Id, RequestWrapper> allClassesMap = getAllETAClasses();
                    loadAvailableAndEnrolledClasses(allClassesMap);
                }
            }
        } else if(enrollmentRequest.Enterprise_Training_Agreement__c == null && enrollmentRequest.Class__c != null) {
            showETALookup = false;
            showClassLookup = true;
        }

        Logger.pop();
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  This method creates a new enrollment.
    * @revision     Initial version
    */
    public PageReference createNewEnrollment() {
         
        Logger.push('EnrollmentPageController', 'createNewEnrollment');

        PageReference returnPage = null;

        isError = false;
        errorMessage = '';

        enrollment.Enrollee_Name__c = enrollmentRequest.Contact__c;
        enrollment.Class__c = enrollmentRequest.Class__c;
        enrollment.Source__c = 'Manual Enrollment'; //SS 11/7/16 #1747653 - Set the source when creating enrollment manually


        if(String.isEmpty(enrollment.Enrollee_Name__c) || String.isEmpty(enrollment.Enrollment_Status__c)) {
            isError = true;
            errorMessage = System.Label.CP_ENROLL_RequiredFieldsMissing;
            return null;
        }
       try {
        
            insert enrollment;
            
            if(enrollment.Enterprise_Training_Agreement__c == null){
                returnPage = new PageReference('/'+enrollment.Id);
               
            }
            System.debug('## enrollment: ' + enrollment);
        
            //returnPage = gotoReturnURL();
        } catch(DmlException dmlEx) {
            Logger.debugException(dmlEx);

            isError = true;
            errorMessage = (dmlEx.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,','')).replace(': []', '');
          
        }

        Logger.pop();

       return returnPage;
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  This method creates new enrollment requests for selected classes.
    * @revision     Initial version
    */
    public PageReference createNewEnrollmentRequest() {
        Logger.push('EnrollmentPageController', 'createNewEnrollmentRequest');

        PageReference returnPage = null;

        isError = false;
        errorMessage = '';

        if(String.isEmpty(enrollmentRequest.Contact__c)) {
            isError = true;
            errorMessage = System.Label.CP_ENROLL_RequiredFieldsMissing;
            return null;
        }

        Contact contact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :enrollmentRequest.Contact__c LIMIT 1];

        List<Enrollment_Request__c> newenrollmentRequestList = new List<Enrollment_Request__c>();

        for(RequestWrapper cw : availableClassesMap.values()) {
            if(cw.isNewEnrollment) {
                Enrollment_Request__c eReq = new Enrollment_Request__c();

                eReq.First_Name__c      = contact.FirstName;
                eReq.Last_Name__c       = contact.LastName;
                eReq.Email__c           = contact.Email;
                eReq.Contact__c         = enrollmentRequest.Contact__c;
                eReq.Status__c          = 'New';
                eReq.Source__c          = 'Manual Enrollment';
                eReq.Class__c           = cw.etaclass.Id;
                eReq.Class_Format__c    = cw.etaclass.Format_Of_Class__c;
                eReq.Course_Code__c     = cw.etaclass.Course_Code__c;
                eReq.Language_Code__c   = cw.etaclass.Language__r.Language_Code__c;
                eReq.Enterprise_Training_Agreement__c = enrollmentRequest.Enterprise_Training_Agreement__c;

                newenrollmentRequestList.add(eReq);
            }
        }

        try {
            insert newenrollmentRequestList;

            returnPage = gotoReturnURL();
        } catch(DmlException dmlEx) {
            Logger.debugException(dmlEx);

            isError = true;
            errorMessage = dmlEx.getMessage();
        }
        Logger.pop();

        return returnPage;
    }

    /**
    * @author       Pranav Raulkar
    * @date         27-May-2016
    * @description  Navigates back to the originating place/home page on cancel operation
    * @revision     Initial version
    */
    public PageReference gotoReturnURL() {
        Logger.push('EnrollmentPageController', 'gotoReturnURL');

        PageReference returnPage = new PageReference(retURL);
        returnPage.setRedirect(true);

        Logger.pop();

        return returnPage;
    }

    public Map<Id, RequestWrapper> getAllETAClasses() {
        Logger.push('EnrollmentPageController', 'getAllETAClasses');

        Map<Id, Id> classCourseMap = new Map<Id, Id>();
        Map<Id, Id> courseClassMap = new Map<Id, Id>();
        Map<Id, RequestWrapper> requestWrapperMap = new Map<Id, RequestWrapper>();

        Enterprise_Training_Agreement__c eta = getETARecord();
        
        for(Training_Agreement_Class_Relationship__c tacr : TrainingUtil.getTrainingAgreementClassRelationForETA(new Set<Id> { eta.Id })) {
            courseClassMap.put(tacr.Class__r.Course__c, tacr.Class__c);
            classCourseMap.put(tacr.Class__c, tacr.Class__r.Course__c);
        }

        Map<Id, Class__c> classMap = new Map<Id, Class__c>([SELECT Id, Course__c,Course_Code__c, CreatedDate, Open_Seats__c, 
                                                                Format_Of_Class__c, Language__r.Language_Code__c, 
                                                                Language__r.Name, Language__r.Language_Display_Name__c, Total_Seats_Taken__c 
                                                            FROM Class__c 
                                                            WHERE Id IN :classCourseMap.keySet()
                                                            AND Status__c = :TrainingUtil.STATUS_ACTIVE]);
        Map<Id, Course__c> courseMap = new Map<Id, Course__c>([SELECT Id 
                                                                FROM Course__c 
                                                                WHERE Id IN :courseClassMap.keySet()]);
        Map<Id, Course_Language__c> courseLanguageMap = new Map<Id, Course_Language__c>();

        for(Course_Language__c courseLanguage : [SELECT Id, Localized_Course_Name__c, Localized_Short_Description__c,
                                                    Localized_Pre_Requisite__c, Course__c, 
                                                    Course_Language__r.Name, Course_Language__r.SF_ISO_Code__c,
                                                    Course_Language__r.Language_Display_Name__c
                                                FROM Course_Language__c 
                                                WHERE Course__c IN :courseClassMap.keySet() 
                                                AND Course_Language__r.SF_ISO_Code__c = 'en_US']) {
            courseLanguageMap.put(courseLanguage.Course__c, courseLanguage);
        }

        for(Id classId : classMap.keySet()) {
            Class__c etaclass = classMap.get(classId);
            Course__c course = courseMap.get(etaclass.Course__c);
            Course_Language__c courseLanguage = courseLanguageMap.get(course.Id);

            RequestWrapper rw = new RequestWrapper();
            rw.isNewEnrollment = false;
            rw.etaclass = etaclass;
            rw.course = course;
            rw.courseLanguage = courseLanguage;

            requestWrapperMap.put(etaclass.Id, rw);
        }

        Logger.pop();

        return requestWrapperMap;
    }

    public void loadAvailableAndEnrolledClasses(Map<Id, RequestWrapper> allClassesMap) {
        Logger.push('EnrollmentPageController' , 'loadAvailableAndEnrolledClasses');

        Enterprise_Training_Agreement__c eta = getETARecord();
        Contact contact = getContactRecord();

        Map<Id, List<Enrollment__c>> etaEnrollmentMap = TrainingUtil.getEnrollmentsForETA(new Set<Id> { eta.Id }, 
                                                                                            new Set<String> { contact.Email },
                                                                                            'Registered');
        
        if(etaEnrollmentMap.size() > 0 && etaEnrollmentMap.containsKey(eta.Id)) {
            Map<Id, Id> classCourseMap = new Map<Id, Id>();
            Map<Id, Id> courseClassMap = new Map<Id, Id>();
            Map<Id, Enrollment__c> enrollmentMap = new Map<Id, Enrollment__c>();

            for(Enrollment__c enrollment : etaEnrollmentMap.get(eta.Id)) {
                courseClassMap.put(enrollment.Class__r.Course__c, enrollment.Class__c);
                classCourseMap.put(enrollment.Class__c, enrollment.Class__r.Course__c);
                enrollmentMap.put(enrollment.Class__c, enrollment);
            }

            Map<Id, Class__c> classMap = new Map<Id, Class__c>([SELECT Id, Course__c, Course_Code__c,Open_Seats__c, 
                                                                    Format_Of_Class__c, Language__r.Name, Language__r.Language_Code__c, 
                                                                    Language__r.Language_Display_Name__c, Total_Seats_Taken__c 
                                                                FROM Class__c 
                                                                WHERE Id IN :classCourseMap.keySet()
                                                                AND Status__c = :TrainingUtil.STATUS_ACTIVE]);
            Map<Id, Course__c> courseMap = new Map<Id, Course__c>([SELECT Id 
                                                                    FROM Course__c 
                                                                    WHERE Id IN :courseClassMap.keySet()]);
            Map<Id, Course_Language__c> courseLanguageMap = new Map<Id, Course_Language__c>();

            for(Course_Language__c courseLanguage : [SELECT Id, Localized_Course_Name__c, Localized_Short_Description__c,
                                                        Course_Language__r.Language_Display_Name__c,
                                                        Localized_Pre_Requisite__c, Course__c, Course_Language__r.Name 
                                                    FROM Course_Language__c 
                                                    WHERE Course__c IN :courseClassMap.keySet() 
                                                    AND Course_Language__r.SF_ISO_Code__c = 'en_US']) {
                courseLanguageMap.put(courseLanguage.Course__c, courseLanguage);
            }

            for(Id classId : classMap.keySet()) {
                Class__c etaclass = classMap.get(classId);
                Course__c course = courseMap.get(etaclass.Course__c);
                Course_Language__c courseLanguage = courseLanguageMap.get(course.Id);

                RequestWrapper rw = new RequestWrapper();
                rw.isNewEnrollment = false;
                rw.etaclass = etaclass;
                rw.course = course;
                rw.courseLanguage = courseLanguage;
                rw.enrollment = enrollmentMap.get(classId);

                enrolledClassesMap.put(etaclass.Id, rw);
            }
        }

        // Get a map of <ETA, <Class, Enrollmentcount>>
        Map<Id, Map<Id, Integer>> etaClassCountMap = TrainingUtil.getConsumedSeatCountForETA(new Set<Id> { eta.Id }, 
                                                                                             allClassesMap.keySet());

        // Get ETA record type ids for Seat Based and Unlimited ETA
        Id seatBasedEtaRtId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
        Id unlimitedEtaRtId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Unlimited').getRecordTypeId();

        for(Id classId : allClassesMap.keySet()) {
            if(!enrolledClassesMap.containsKey(classId)) {
                RequestWrapper rw = allClassesMap.get(classId);
                // Process the class if we have a seat based ETA
                if(seatBasedEtaRtId == eta.RecordTypeId) {
                    Integer seatsTaken = 0;

                    if(etaClassCountMap.get(eta.Id) != null) {
                        seatsTaken = etaClassCountMap.get(eta.Id).get(classId);
                        seatsTaken = (seatsTaken == null ? 0 : seatsTaken);
                    }

                    // add to available class only if the total enrollments for this class < max seats on eta
                    if(seatsTaken == 0 || seatsTaken < eta.Max_Seats__c) {
                        availableClassesMap.put(classId, allClassesMap.get(classId));
                    }
                } else if(unlimitedEtaRtId == eta.RecordTypeId) {
                    // Process the class if we have a unlimited ETA
                    availableClassesMap.put(classId, allClassesMap.get(classId));
                }                
            }
        }

        Logger.pop();
    }

    public List<RequestWrapper> getAvailableClasses() {
        Logger.push('EnrollmentPageController', 'getAvailableClasses');

        List<RequestWrapper> rwList = new List<RequestWrapper>();
        if(!availableClassesMap.isEmpty()) {
            rwList = availableClassesMap.values();
            rwList.sort();
        }

        Logger.pop();

        return rwList;
    }

    private Enterprise_Training_Agreement__c getETARecord() {
        Logger.push('EnrollmentPageController', 'getETARecord');

        Enterprise_Training_Agreement__c eta = null;
        if(enrollmentRequest.Enterprise_Training_Agreement__c != null) {
            eta = [SELECT Max_Seats__c, RecordTypeId, Account_Name__r.Name 
                    FROM Enterprise_Training_Agreement__c
                    WHERE Id = :enrollmentRequest.Enterprise_Training_Agreement__c Limit 1];
        }

        Logger.pop();

        return eta;
    }

    private Contact getContactRecord() {
        Logger.push('EnrollmentPageController', 'getContactRecord');

        Contact contact = null;
        if(enrollmentRequest.Contact__c != null) {
            contact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :enrollmentRequest.Contact__c LIMIT 1];
        }

        Logger.pop();

        return contact;
    }

    private Boolean isEnrolleBlacklisted() {
        Logger.push('EnrollmentPageController', 'isEnrolleBlacklisted');
        Contact contact = getContactRecord();
        Logger.pop();
        return TrainingUtil.isEnrolleeBlacklisted(enrollmentRequest.Enterprise_Training_Agreement__c, contact.Email);
    }

    private Boolean isEnrolleFromAllowedDomain() {
        Logger.push('EnrollmentPageController', 'isEnrolleFromAllowedDomain');

        Boolean isAllowed = true;

        Map<Id,String> etaToEnrolleeEmailMap = new Map<Id,String>();

        Map<id,Map<string,Boolean>> etaToEmailToIsAllowedMap = new Map<id,Map<string,Boolean>>();

        Contact contact = getContactRecord();

        if(enrollmentRequest.Enterprise_Training_Agreement__c != null){
            etaToEnrolleeEmailMap.put(enrollmentRequest.Enterprise_Training_Agreement__c, contact.Email);
            etaToEmailToIsAllowedMap = TrainingUtil.areEnrolleeFromAllowedDomain(etaToEnrolleeEmailMap);

            if(!etaToEmailToIsAllowedMap.containsKey(enrollmentRequest.Enterprise_Training_Agreement__c)){
                isAllowed = false;
            }
        }

        Logger.pop();

        return isAllowed;
    }
}