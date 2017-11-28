@isTest
public class CourseControllerTest {
	private static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    private static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();

    private static List<Account> accountList;
    private static List<Contact> contactList;

    private static List<Language__c> languageList;
    private static List<Enterprise_Training_Agreement__c> etaList;
    private static List<Course__c> courseList;
    private static List<Course_Language__c> courseLangList;
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

    private static testMethod void courseLanguageList_test() {
    	setupData();

    	Test.startTest();

		CourseController controller = new CourseController();
		System.assert(controller.courseLanguageList.size() == 0);

		controller.etAgreementID = etaList[0].Id;
		controller.language = 'en_US';
		System.assert(controller.courseLanguageList.size() != 1);

    	Test.stopTest();
    }
}