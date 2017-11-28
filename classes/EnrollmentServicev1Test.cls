/**
 * @author Original: Haigang Wu - Mathworks
 * @date Original: Jan 24 2017
 * @description: Enrollment REST service test.
 * @revision: 
 */ 


@isTest
private class EnrollmentServicev1Test {
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();

    private static final Integer RECORD_COUNT = 5;
    private static User usr;
    private static string enrollId;
    private static string classId;
    private static string contactEmail;
    
    static void dummyData(){
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        //re-create the Enrollment Code Configuration Setting
        cTrainSettingBuilder.buildEnrollmentCodeConfiguration();
        
        //Create test user
        //usr = TestDataBuilder.buildTestUser(1);

        //insert usr;
        usr = [SELECT Id, Email FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs(usr){
        
             List<Language__c> langList = new List<Language__c>();
            //create Language__c record from CTrainingTestDataBuilder.
            for(Integer i=0; i<5; i++){
                Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                langObj.SF_ISO_Code__c = (Math.mod(i,2) == 0 ? 'en_US' : 'ko');
                langList.add(langObj);
            }
            insert langList;
            
            //Creating the Course__c test data.
            Id courserecTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
            List<Course__c> courseLst = new List<Course__c>();
            for(Integer i=0; i<RECORD_COUNT; i++){
                Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(i);
                courseObj.recordTypeId = courserecTypeId;
                courseObj.Course_Code__c = 'TESTCODE'+i;
                courseLst.add(courseObj);
            }
            insert courseLst;
            
             //Creating the Class__c test data.
            List<Class__c> clssLst = new List<Class__c>();    
            Id classrecTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Self-Paced').getRecordTypeId();    
            //Creating the test data for Class Object. 
            for(Integer i=0;i<RECORD_COUNT;i++){            
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseLst[i].Id, langList[0].Id);
                clssObj.Max_Seats__c  = 500;
                clssObj.recordTypeId = classrecTypeId;
                clssObj.Status__c='Active';
                clssLst.add(clssObj);
            }
            insert clssLst;
            
            Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert acc;
                
            List<Contact> conList = new List<Contact>();
            for(Integer i=0; i<RECORD_COUNT; i++){  
                Contact con = TestDataBuilder.buildTestContact(i, usr.Id, acc.Id); 
                conList.add(con);
            }
            insert conList;
            contactEmail = conList[0].Email;
            
            List<Enrollment__c> enrolmntLst = new List<Enrollment__c>();
            for(Integer i=0; i<RECORD_COUNT; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[0].id);
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntLst.add(enrolmntObj);
            }
            
            insert enrolmntLst;
            enrollId = enrolmntLst[0].id;
            classId = clssLst[0].id;
            
        }//End of Run As User
    }
    

    static testMethod void getPingTest1() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/ping';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.getEnrollmentbyId();
		Test.stopTest();
		
		system.assertEquals(200, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals('Working', m.get('message'));        
    }

    static testMethod void getPingTest2() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.getEnrollmentbyId();
		Test.stopTest();
		
		system.assertEquals(200, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals('Working', m.get('message'));        
    }

    static testMethod void getInvalidEnrollmentIdTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/fakeid';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.getEnrollmentbyId();
		Test.stopTest();
		
		system.assertEquals(400, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals(System.Label.Enrollment_not_found, m.get('message'));        
    }

    static testMethod void getValidEnrollmentIdTest() {
		dummyData();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/' + enrollId;
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.getEnrollmentbyId();
		Test.stopTest();
		
		system.assertEquals(200, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals(classId, m.get('classId'));        
    }

    static testMethod void postPingTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/ping';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.newenrollments('cybernetictoday@gmail.com.mwtest','a2f18000000Q5lE','Registered','Credit Terms,','59966','1234','C33211111','20','Manual Enrollment');
		Test.stopTest();
		
		system.assertEquals(200, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals('Working', m.get('message'));        
    }

    static testMethod void postBlankEmailTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.newenrollments('','a2f18000000Q5lE','Registered','Credit Terms,','59966','1234','C33211111','20','Manual Enrollment');
		Test.stopTest();
		
		system.assertEquals(400, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals(System.Label.Enrollment_Required_Fields, m.get('message'));        
    }

    static testMethod void postGlobalContactSearchFailTest() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.newenrollments('test@test.com','a2f18000000Q5lE','Registered','Credit Terms,','59966','1234','C33211111','20','Manual Enrollment');
		Test.stopTest();
		
		system.assertEquals(400, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals(System.Label.Enrollment_Contact_not_found, m.get('message'));        
    }

    static testMethod void postInsertEnrollmentTest() {
		dummyData();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/training/v1/enrollments/';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		EnrollmentServicev1.newenrollments(contactEmail,classId,'Registered','Credit Terms,','59966','1234','C33211111','20','Manual Enrollment');
		Test.stopTest();
		
		system.assertEquals(201, RestContext.response.statuscode);        
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
		system.assertEquals(contactEmail, m.get('enrolleeEmail'));        
    }

}