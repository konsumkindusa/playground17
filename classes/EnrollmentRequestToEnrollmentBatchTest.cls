/**
 *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
 *@date Original:   5 May 2016, Last Modified: 
 *@description:     Test class to testing the functionality of the EnrollmentRequestToEnrollmentBatch.
 */
 
@isTest 
private class EnrollmentRequestToEnrollmentBatchTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
    private static final Integer ETAREEMENT_COUNT = 10;
    private static final Integer CLASS_COUNT = 10;
    private static final Integer LANG_COUNT = 2;
    private static final Integer COURSE_COUNT = 10;
    private static final Integer ETAREL_COUNT = 10;
    private static final Integer ENROL_REQ_COUNT = 10;
    private static final Integer CONTACT_COUNT = 10;
    
     /*
    @ name    setupTestData
    @ date    5 May 2016
    @ author  Abhay Verma
    @ param   none.
    @ return  Void. 
    @ description :Create the setup data for the EnrollmentRequestToEnrollmentBatch. 
     */
    private static User usr;
    private static void setupTestData(){
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        System.runAs(usr){
         
          List<Language__c> langLst = new List<Language__c>();
          //create Language__c record from CTrainingTestDataBuilder.
            for(Integer i=0; i<LANG_COUNT; i++){
                Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                langObj.SF_ISO_Code__c = (i==0 ? 'en_US' : 'ko');
                langObj.Language_Code__c='ENU';
                langLst.add(langObj);
            }
            insert langLst;
            
            
            //Creating the Enterprise_Training_Agreement__c test data.
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<ETAREEMENT_COUNT;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c eTAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                if(i < 2){
                    ETAgreementObj.Max_Seats__c = 0;
                }
                else{
                    ETAgreementObj.Max_Seats__c = 1;
                }
                ETagreeemntLst.add(ETAgreementObj);
            }
            insert ETagreeemntLst;
            
            //Creating the Course__c test data.
            Id courserecTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
            List<Course__c> courseLst = new List<Course__c>();
            for(Integer i=0; i<COURSE_COUNT; i++){
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
            for(Integer i=0;i<CLASS_COUNT;i++){            
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseLst[i].Id, langLst[0].Id);
                clssObj.Max_Seats__c  = 500;
                clssObj.recordTypeId = classrecTypeId;
                clssObj.Status__c='Active';
                clssLst.add(clssObj);
            }
            insert clssLst;
            
             //Creating the Training_Agreement_Class_Relationship__c test data.
            List<Enterprise_Training_Agreement__c> etaLst = [SELECT Id, Is_Active__c FROM Enterprise_Training_Agreement__c];
            List<Training_Agreement_Class_Relationship__c> TACRelLst = new List<Training_Agreement_Class_Relationship__c>(); 
            for(Integer i=0;i<ETAREL_COUNT;i++){
                Training_Agreement_Class_Relationship__c TACRelObj;
                TACRelObj = CTrainingTestDataBuilder.buildTestTAClassRelationship(clssLst[i].Id, ETagreeemntLst[i].Id);
                TACRelLst.add(TACRelObj);
            }
            insert TACRelLst;  
            
            
            Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert acc;
                    
            List<Contact> conList = new List<Contact>();
            for(Integer i=0; i<CONTACT_COUNT; i++){  
                Contact con = TestDataBuilder.buildTestContact(i, usr.Id, acc.Id); 
                con.email = 'test'+i+'@test.com';
                conList.add(con);
            }
            insert conList;
         
        }//End of RunAs
    }//End of Method
    
    /*
    @ name    createEnrollmentOnCreatingEnrollmentRequest
    @ date    5 May 2016
    @ author  Abhay Verma
    @ param   none.
    @ return  Void. 
    @ description : . 
     */
    
    private static testMethod void createEnrollmentOnCreatingEnrollmentRequestTest(){
        EnrollmentRequestToEnrollmentBatchTest.setupTestData();
        System.RunAs(usr){
            List<Contact> conLst = [SELECT Id FROM Contact];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            
            
            System.assertEquals(conLst.size(), 10);
            System.assertEquals(etarList.size(), 10);
            
            Test.startTest();
            
            List<Enrollment_Request__c> enrolReqLst = new List<Enrollment_Request__c>();
            for(Integer i=0;i<ENROL_REQ_COUNT;i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Contact__c = conLst[i].Id;
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqObj.Status__c = 'Processing';
                enrolReqLst.add(enrolReqObj);
            }
            insert enrolReqLst;
            List<Enrollment_Request__c> insertedEnrolReqLst = [SELECT Id FROM Enrollment_Request__c];
            System.assertEquals(insertedEnrolReqLst.size(), 10);
            
            Test.stopTest();
            List<Enrollment__c> enrolList = [SELECT Id, Enterprise_Training_Agreement__c FROM Enrollment__c];
            System.assertEquals(enrolList.size(), 8);
            
            List<Enrollment_Request__c> updatedEnrolReqLstSuccess = [SELECT Id, Exception_Reason__c,status__c,Enrollment__c FROM Enrollment_Request__c 
                                                              WHERE Status__c != 'Exception'];
            for(Enrollment_Request__c EnrolReqObj : updatedEnrolReqLstSuccess){
                System.assertEquals(EnrolReqObj.status__c,'Pending Notification');
                System.assert(EnrolReqObj.Enrollment__c!=null);
            }
            
            List<Enrollment_Request__c> updatedEnrolReqLst = [SELECT Id, Exception_Reason__c FROM Enrollment_Request__c 
                                                              WHERE Status__c = 'Exception'];
            System.assertEquals(updatedEnrolReqLst.size(), 2);
            for(Enrollment_Request__c errorEnrolReqObj : updatedEnrolReqLst){
                System.assertEquals(errorEnrolReqObj.Exception_Reason__c, System.Label.Max_Enrollment_Error_Message);
            }
        }//End of RunAs
    }//End of Method
    
    private static testMethod void createEnrollmentOnUpdatingEnrollmentRequestTest(){
        EnrollmentRequestToEnrollmentBatchTest.setupTestData();
        System.RunAs(usr){
            List<Contact> conLst = [SELECT Id FROM Contact];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            List<Enterprise_Training_Agreement__c> etaLst = [SELECT Id, Max_Seats__c FROM Enterprise_Training_Agreement__c];
            for(Integer i=0;i<10;i++){
                System.debug('ETA LST #### ' +etaLst[i].Max_Seats__c);
            }
            System.assertEquals(conLst.size(), 10);
            System.assertEquals(etarList.size(), 10);
            
            Test.startTest();
            
            List<Enrollment_Request__c> enrolReqLst = new List<Enrollment_Request__c>();
            for(Integer i=0;i<ENROL_REQ_COUNT;i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Contact__c = conLst[i].Id;
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqObj.Status__c = 'New';
                enrolReqLst.add(enrolReqObj);
            }
            
            insert enrolReqLst;
            List<Enrollment_Request__c> insertedEnrolReqLst = [SELECT Id FROM Enrollment_Request__c];
            System.assertEquals(insertedEnrolReqLst.size(), 10);
            
            List<Enrollment_Request__c> updateEnrolReqList = new List<Enrollment_Request__c>();
            for(Enrollment_Request__c obj : insertedEnrolReqLst){
                
                obj.Status__c = 'Processing';
                updateEnrolReqList.add(obj);
            }
            update updateEnrolReqList;
            
            Test.stopTest();
            List<Enrollment__c> enrolList = [SELECT Id, Enterprise_Training_Agreement__c FROM Enrollment__c];
            System.assertEquals(enrolList.size(), 8);
            List<Enrollment_Request__c> updatedEnrolReqLstSuccess = [SELECT Id,status__c,Enrollment__c, Exception_Reason__c FROM Enrollment_Request__c 
                                                              WHERE Status__c != 'Exception'];
            for(Enrollment_Request__c EnrolReqObj : updatedEnrolReqLstSuccess){
                System.assertEquals(EnrolReqObj.status__c,'Pending Notification');
                System.assert(EnrolReqObj.Enrollment__c!=null);
            }
            
            List<Enrollment_Request__c> reprocessEnrolReqLst = [SELECT Id, Exception_Reason__c FROM Enrollment_Request__c WHERE Status__c = 'Exception'];
            System.assertEquals(reprocessEnrolReqLst.size(), 2);
            for(Enrollment_Request__c errEnrolReqObj : reprocessEnrolReqLst){
                System.assertEquals(errEnrolReqObj.Exception_Reason__c, System.Label.Max_Enrollment_Error_Message);
            }
        }//End of RunAs
    }//End of Method
    
}