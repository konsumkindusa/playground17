/**
 *@author Original: Sagar Talele - Accenture/Mathworks, Last Modified: 
 *@date Original:   1 June 2016, Last Modified: 
 *@description:     Test class to testing the functionality of the EmailToEnrolleesBatch.
 */
 
@isTest 
private class EmailToEnrolleesBatchTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    private static final Integer ETAREEMENT_COUNT = 10;
    private static final Integer CLASS_COUNT = 10;
    private static final Integer LANG_COUNT = 2;
    private static final Integer COURSE_COUNT = 10;
    private static final Integer ETAREL_COUNT = 10;
    private static final Integer ENROL_REQ_COUNT = 10;
    private static final Integer CONTACT_COUNT = 10;
    static CTrainingCustomSettingBuilder CTcustsettbuild = new CTrainingCustomSettingBuilder();
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
        CTcustsettbuild.buildEnrollmentCodeConfiguration();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        System.runAs(usr){
         
          List<Language__c> langLst = new List<Language__c>();
            //create Language__c record from CTrainingTestDataBuilder.
            for(Integer i=0; i<LANG_COUNT; i++){
                Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                langObj.SF_ISO_Code__c = (i==0 ? 'en_US' : 'ja');
                langObj.Language_Code__c=(i==0 ? 'en' : 'ja');
                langObj.ISO_Code__c =(i==0 ? 'en' : 'ja');
                langLst.add(langObj);
            }
            insert langLst;
            
            //Create display language test data
            List<Language_Display_Name__c> dispLangLst = new List<Language_Display_Name__c>();
            
            Language_Display_Name__c dispLangObj = new Language_Display_Name__c();
            dispLangObj.Name = 'en';
            dispLangObj.Language__c = langLst[0].Id;
            dispLangObj.Display_name__c = 'English';
            dispLangObj.language_Code__c = 'en';
            
            dispLangLst.add(dispLangObj);
            
            Language_Display_Name__c dispLangObj1 = new Language_Display_Name__c();
            dispLangObj1.Name = 'ja';
            dispLangObj1.Language__c = langLst[0].id;
            dispLangObj1.Display_name__c = 'Japanese';
            dispLangObj1.language_Code__c = 'ja';
            
            dispLangLst.add(dispLangObj1); 
            
            insert dispLangLst;
            
            //Creating the Enterprise_Training_Agreement__c test data.
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<ETAREEMENT_COUNT;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c eTAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                ETAgreementObj.Language__c = langLst[0].Id;
                if(i < 2){
                    ETAgreementObj.Max_Seats__c = 10;
                }
                else{
                    ETAgreementObj.Max_Seats__c = 10;
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
    @ name    EnrollmentRequestUpdateTest
    @ date    1 June 2016
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description : . 
     */
    
    private static testMethod void EnrollmentRequestUpdateTest(){
        EmailToEnrolleesBatchTest.setupTestData();
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
            
           
           // List<Enrollment__c> enrolList = [SELECT Id, Enterprise_Training_Agreement__c FROM Enrollment__c];
           //h System.assertEquals(enrolList.size(), 10);
            
            List<Enrollment_Request__c> updatedEnrolReqLstSuccess = [SELECT Id, Exception_Reason__c,status__c,Enrollment__c FROM Enrollment_Request__c 
                                                              WHERE Status__c != 'Exception'];
            Set<Id> enrollIdSet = new Set<Id>();
            for(Enrollment_Request__c EnrolReqObj : updatedEnrolReqLstSuccess){
                //System.assertEquals(EnrolReqObj.status__c,'Pending Notification');
                //System.assert(EnrolReqObj.Enrollment__c!=null);
                enrollIdSet.add(EnrolReqObj.Id);
            }
            
            List<Enrollment_Request__c> updatedEnrolReqLst = [SELECT Id, Exception_Reason__c FROM Enrollment_Request__c 
                                                              WHERE Status__c = 'Exception'];
            System.assertEquals(updatedEnrolReqLst.size(), 0);
            for(Enrollment_Request__c errorEnrolReqObj : updatedEnrolReqLst){
               // System.assertEquals(errorEnrolReqObj.Exception_Reason__c, System.Label.Max_Enrollment_Error_Message);
            }
            System.enqueueJob(new EmailToEnrolleesBatch(enrollIdSet));
             Test.stopTest();
            List<Enrollment_Request__c> enrollReqLst = new List<Enrollment_Request__c>();
            enrollReqLst = [Select Id,status__c From Enrollment_Request__c where Id In :enrollIdSet];
            for(Enrollment_Request__c enrollObj : enrollReqLst){
                System.assertEquals(enrollObj.status__c,'Completed');
            }
            
        }//End of RunAs
    }
     /*
    @ name    createTaskTest
    @ date    18 June 2016
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description : . 
    */
    
    private static testMethod void createTaskTest(){
        EmailToEnrolleesBatchTest.setupTestData();
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
            
           
           // List<Enrollment__c> enrolList = [SELECT Id, Enterprise_Training_Agreement__c FROM Enrollment__c];
           //h System.assertEquals(enrolList.size(), 10);
            
            List<Enrollment_Request__c> updatedEnrolReqLstSuccess = [SELECT Id, Exception_Reason__c,status__c,Enrollment__c FROM Enrollment_Request__c 
                                                              WHERE Status__c != 'Exception'];
            Set<Id> enrollIdSet = new Set<Id>();
            for(Enrollment_Request__c EnrolReqObj : updatedEnrolReqLstSuccess){
                //System.assertEquals(EnrolReqObj.status__c,'Pending Notification');
                //System.assert(EnrolReqObj.Enrollment__c!=null);
                enrollIdSet.add(EnrolReqObj.Id);
            }
            
            List<Enrollment_Request__c> updatedEnrolReqLst = [SELECT Id, Exception_Reason__c FROM Enrollment_Request__c 
                                                              WHERE Status__c = 'Exception'];
            System.assertEquals(updatedEnrolReqLst.size(), 0);
            for(Enrollment_Request__c errorEnrolReqObj : updatedEnrolReqLst){
               // System.assertEquals(errorEnrolReqObj.Exception_Reason__c, System.Label.Max_Enrollment_Error_Message);
            }
            System.enqueueJob(new EmailToEnrolleesBatch(enrollIdSet));
             Test.stopTest();
            List<Enrollment_Request__c> enrollReqLst = new List<Enrollment_Request__c>();
            enrollReqLst = [Select Id,status__c From Enrollment_Request__c where Id In :enrollIdSet];
            for(Enrollment_Request__c enrollObj : enrollReqLst){
                System.assertEquals(enrollObj.status__c,'Completed');
            }
            List<Task> taskList = new List<Task>();
            taskList =[Select Id From Task where Status = 'Completed'];
            System.assertEquals(taskList.size(),10);
        }//End of RunAs
    }
    
}