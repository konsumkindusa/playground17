@isTest
private class EnrollmentPageControllerTest {
    private static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    private static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();

    private static List<Account> accountList;
    private static List<Contact> contactList;

    private static List<Language__c> languageList;
    private static List<Enterprise_Training_Agreement__c> etaList;
    private static List<Course__c> courseList;
    private static List<Class__c> classList;
    private static List<Training_Agreement_Class_Relationship__c> tacRelationshipList;
    private static List<Allowed_Domains__c> allowedDomainsList;
    private static List<Enrollment__c> enrollmentList;
    
    static void setupData() {
        custsettbuild.buildBypassTriggerSettings();
        cTrainSettingBuilder.buildEnrollmentCodeConfiguration();

        // INSERT ACCOUNT
        accountList = new List<Account>();
        for(Integer i = 0; i < 2; i++){
            accountList.add(TestDataBuilder.buildTestAccount(i, UserInfo.getUserId()));            
        }
        insert accountList;

        // INSERT CONTACT
        contactList = new List<Contact>();
        for(Integer i = 0; i < 2; i++) {
            Contact contact = TestDataBuilder.buildTestContact(i, UserInfo.getUserId(), accountList[i].Id);
            contact.Email = 'test_contact_mw' + i + '@testmailtest.com';
            contactList.add(contact);            
        }
        insert contactList;

        // INSERT LANGUAGE
        languageList = new List<Language__c>();
        languageList.add(CTrainingTestDataBuilder.buildTestLanguage(0));
        languageList[0].SF_ISO_Code__c = 'en_US';
        insert languageList;

        // INSERT ENTERPRISE TRAINING AGREEMENT
        Id etaSeatBasedTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();

        etaList = new List<Enterprise_Training_Agreement__c>();
        for(Integer i = 0; i < 2; i++) {
            Enterprise_Training_Agreement__c eta = CTrainingTestDataBuilder.buildTestETAgreement(i);
            eta.Account_Name__c = accountList[i].Id;
            eta.RecordTypeId = etaSeatBasedTypeId;
            eta.Max_Seats__c = 10;
            eta.Language__c = languageList[0].Id;
            etaList.add(eta);
        }
        insert etaList;

        // INSERT COURSE
        Id courseSeatBasedTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();

        courseList = new List<Course__c>();
        for(Integer i = 0; i < 10; i++) {
            Course__c course = CTrainingTestDataBuilder.buildTestCourse(i);
            course.RecordTypeId = courseSeatBasedTypeId;
            course.Course_Code__c = 'CC' + i;
            courseList.add(course);
        }
        insert courseList;

        // INSERT CLASS
        Integer classI = 0;
        Id classSeatBasedTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Self-Paced').getRecordTypeId();
        
        classList = new List<Class__c>();
        for(Course__c course : courseList){
            Class__c cl = CTrainingTestDataBuilder.buildTestClass(classI++, course.Id, languageList[0].Id);
            cl.Max_Seats__c  = 10;
            cl.RecordTypeId = classSeatBasedTypeId;
            classList.add(cl);
        }
        insert classList;

        // INSERT Training Agreement Relationship
        tacRelationshipList = new List<Training_Agreement_Class_Relationship__c>(); 
        for(Enterprise_Training_Agreement__c eta : etaList){
            for(Class__c cl : classList) { 
                Training_Agreement_Class_Relationship__c tacr = CTrainingTestDataBuilder.buildTestTAClassRelationship(cl.Id, eta.Id);
                tacRelationshipList.add(tacr);
            }
        }
        insert tacRelationshipList;

        // INSERT ALLOWED DOMAIN
        allowedDomainsList = new List<Allowed_Domains__c>();
        for(Enterprise_Training_Agreement__c eta : etaList) {
            //String email = (String) UserInfo.getUserEmail();
            String email = contactList[0].email;

            Allowed_Domains__c ad = new Allowed_Domains__c();                
            ad.Enterprise_Training_Agreement__c = eta.Id;
            ad.Name = email.substringAfter('@');
            ad.Allow_Sub_Domain__c = true;
            allowedDomainsList.add(ad);
        }
        insert allowedDomainsList;

        // CREATE ENROLLMENTS
        enrollmentList = new List<Enrollment__c>();
        for(Enterprise_Training_Agreement__c eta : etaList) {
            for(Integer i = 0; i < 5; i++) {
                Enrollment__c en = new Enrollment__c();
                en.Enterprise_Training_Agreement__c = eta.Id;
                en.Class__c = classList[i].Id;
                en.Enrollee_Name__c = contactList[0].Id;
                en.Enrollment_Status__c = 'Registered';
                enrollmentList.add(en);
            }           
        }
        insert enrollmentList;
    }

    static void setupBlacklist() {
        Enrollee_Blacklist__c blacklistedEnrollee = new Enrollee_Blacklist__c();
        blacklistedEnrollee.Contact__c = contactList[0].Id;
        blacklistedEnrollee.Enterprise_Training_Agreement__c = etaList[0].Id;
        insert blacklistedEnrollee;
    }

    static void setupBlockedAllowedDomain() {
        Allowed_Domains__c adList = [SELECT Id FROM Allowed_Domains__c WHERE Enterprise_Training_Agreement__c = :etaList[0].Id];
        delete adList;

        Allowed_Domains__c ad = new Allowed_Domains__c();                
        ad.Enterprise_Training_Agreement__c = etaList[0].Id;
        ad.Name = 'somenonexistentdomain.com';
        ad.Allow_Sub_Domain__c = true;
        insert ad;
    }
    
    @isTest static void testETAInitialization() {
        setupData();

        Test.setCurrentPage(Page.EnrollmentPage);
        ApexPages.currentPage().getParameters().put('en', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('ea', etaList[0].Id);
        //ApexPages.currentPage().getParameters().put('cl', classList[0].Id);

        Test.startTest();
        EnrollmentPageController ec = new EnrollmentPageController();

        System.assertEquals(ec.retURL, '/home/home.jsp');
        System.assertEquals(ec.enrolleeId, contactList[0].Id);
        System.assertEquals(ec.etaId, etaList[0].Id);
        //System.assertEquals(ec.classId, classList[0].Id);

        System.assert(!ec.isError);
        System.assert(String.isEmpty(ec.errorMessage));

        System.assert(ec.enrolledClassesMap.size() == 5);
        System.assert(ec.availableClassesMap.size() == 5);
        System.assert(ec.getAvailableClasses().size() == 5);
        
        System.assert(ec.enrollment != null);
        System.assert(ec.enrollmentRequest != null);

        System.assertEquals(ec.enrollmentRequest.Contact__c, contactList[0].Id);
        System.assertEquals(ec.enrollmentRequest.Enterprise_Training_Agreement__c, etaList[0].Id);
        //System.assertEquals(ec.enrollmentRequest.Class__c, classList[0].Id);

        // Try to create new enrollment request
        Set<Id> enrollmentEtaIdSet = new Set<Id>();
        for(Enrollment__c en : enrollmentList) {
            enrollmentEtaIdSet.add(en.Enterprise_Training_Agreement__c);
        }

        Integer i = 0;
        for(String key : ec.availableClassesMap.keySet()) {
            EnrollmentPageController.RequestWrapper rw = ec.availableClassesMap.get(key);
            if(!enrollmentEtaIdSet.contains(rw.enrollment.Enterprise_Training_Agreement__c)) {
                rw.isNewEnrollment = true;
            }
        }
        ec.createNewEnrollmentRequest();

        List<Enrollment_Request__c> enrollmentReqList = [SELECT Id FROM Enrollment_Request__c WHERE Enterprise_Training_Agreement__c = :etaList[0].Id];
        System.assertEquals(enrollmentReqList.size(), 5);
        System.assert(!ec.isError);
        System.assert(String.isEmpty(ec.errorMessage));

        Test.stopTest();
    }

    @isTest static void testClassInitialization() {
        setupData();

        Test.setCurrentPage(Page.EnrollmentPage);
        ApexPages.currentPage().getParameters().put('en', contactList[0].Id);
        //ApexPages.currentPage().getParameters().put('ea', etaList[0].Id);
        ApexPages.currentPage().getParameters().put('cl', classList[classList.size() - 1].Id);

        Test.startTest();
        EnrollmentPageController ec = new EnrollmentPageController();
        ec.enrollment.Enrollment_Status__c = 'Registered';

        System.assertEquals(ec.retURL, '/home/home.jsp');
        System.assertEquals(ec.enrolleeId, contactList[0].Id);
        //System.assertEquals(ec.etaId, etaList[0].Id);
        System.assertEquals(ec.classId, classList[classList.size() - 1].Id);

        System.assert(!ec.isError);
        System.assert(String.isEmpty(ec.errorMessage));

        System.assert(ec.enrolledClassesMap.size() == 0);
        System.assert(ec.availableClassesMap.size() == 0);
        System.assert(ec.getAvailableClasses().size() == 0);
        
        System.assert(ec.enrollment != null);
        System.assert(ec.enrollmentRequest != null);

        System.assertEquals(ec.enrollmentRequest.Contact__c, contactList[0].Id);
        //System.assertEquals(ec.enrollmentRequest.Enterprise_Training_Agreement__c, etaList[0].Id);
        System.assertEquals(ec.enrollmentRequest.Class__c, classList[classList.size() - 1].Id);

        //Create new enrollment and Store the URL When a enrollment record is created.
        PageReference enrolIdURL = ec.createNewEnrollment();
        List<Enrollment__c> eList = [SELECT Id FROM Enrollment__c WHERE Class__c = :classList[classList.size() - 1].Id AND Enrollee_Name__c = :contactList[0].Id];
        System.assertEquals(eList.size(), 1);
        System.assert(!ec.isError);
        System.assert(String.isEmpty(ec.errorMessage));
        System.assertEquals(enrolIdURL.getUrl(), '/'+eList[0].Id);

        Test.stopTest();
    }

    @isTest static void testBlacklistBlocking() {
        setupData();
        setupBlacklist();

        Test.setCurrentPage(Page.EnrollmentPage);
        ApexPages.currentPage().getParameters().put('en', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('ea', etaList[0].Id);

        Test.startTest();
        EnrollmentPageController ec = new EnrollmentPageController();

        System.assertEquals(ec.retURL, '/home/home.jsp');
        System.assertEquals(ec.enrolleeId, contactList[0].Id);
        System.assertEquals(ec.etaId, etaList[0].Id);
        //System.assertEquals(ec.classId, classList[0].Id);

        System.assert(ec.isError);
        System.assertEquals(ec.errorMessage, System.Label.CP_ENROLL_BlacklistedEnrollee);

        System.assert(ec.enrolledClassesMap.size() == 0);
        System.assert(ec.availableClassesMap.size() == 0);
        System.assert(ec.getAvailableClasses().size() == 0);
        
        System.assert(ec.enrollment != null);
        System.assert(ec.enrollmentRequest != null);

        System.assertEquals(ec.enrollmentRequest.Contact__c, contactList[0].Id);
        System.assertEquals(ec.enrollmentRequest.Enterprise_Training_Agreement__c, etaList[0].Id);
        
        Test.stopTest();
    }

    @isTest static void testAllowedDomainBlocking() {
        setupData();
        setupBlacklist();
        setupBlockedAllowedDomain();

        Test.setCurrentPage(Page.EnrollmentPage);
        ApexPages.currentPage().getParameters().put('en', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('ea', etaList[0].Id);

        Test.startTest();
        EnrollmentPageController ec = new EnrollmentPageController();

        System.assertEquals(ec.retURL, '/home/home.jsp');
        System.assertEquals(ec.enrolleeId, contactList[0].Id);
        System.assertEquals(ec.etaId, etaList[0].Id);
        //System.assertEquals(ec.classId, classList[0].Id);

        System.assert(ec.isError);

        Enterprise_Training_Agreement__c enta = [SELECT Account_Name__r.Name FROM Enterprise_Training_Agreement__c WHERE Id = :etaList[0].Id];
        String eMsg = String.format(System.Label.CP_ENROLL_EmailNotInAllowedDomain, new List<String> { enta.Account_Name__r.Name, enta.Account_Name__r.Name });
        System.assertEquals(ec.errorMessage, eMsg);

        System.assert(ec.enrolledClassesMap.size() == 0);
        System.assert(ec.availableClassesMap.size() == 0);
        System.assert(ec.getAvailableClasses().size() == 0);
        
        System.assert(ec.enrollment != null);
        System.assert(ec.enrollmentRequest != null);

        System.assertEquals(ec.enrollmentRequest.Contact__c, contactList[0].Id);
        System.assertEquals(ec.enrollmentRequest.Enterprise_Training_Agreement__c, etaList[0].Id);
        
        Test.stopTest();
    }
        
       @isTest static void testPageRequiredFields() {
        setupData();
        Test.setCurrentPage(Page.EnrollmentPage);
   
        Test.startTest();
        EnrollmentPageController ec = new EnrollmentPageController();

		PageReference enrolIdURL = ec.createNewEnrollment();           
        PageReference enrolIdURL2 = ec.createNewEnrollmentRequest();
        Test.stopTest();
    }
    
      @isTest static void testEnrollmentValidationRules() {
        setupData();
         classList[classList.size() - 1].Status__c = 'Inactive';
         update(classList[classList.size() - 1]);
          
        Test.setCurrentPage(Page.EnrollmentPage);
        ApexPages.currentPage().getParameters().put('en', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('cl', classList[classList.size() - 1].Id);

        Test.startTest();
        EnrollmentPageController ec = new EnrollmentPageController();
        ec.enrollment.Enrollment_Status__c = 'Registered';

		PageReference enrolIdURL = ec.createNewEnrollment();

        Test.stopTest();
    }
}