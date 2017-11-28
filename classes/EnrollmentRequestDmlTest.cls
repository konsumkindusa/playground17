/** 
 *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
 *@date Original: 28 April 2016, Last Modified: 
 *@description This  is handler class for 'EnrollmentRequestMasterTrigger' . 
 */ 

@isTest
private class EnrollmentRequestDmlTest{

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();
    
    private static final Integer ETAREEMENT_COUNT = 200;
    private static final Integer ENROLLMENT_CODE_COUNT = 200;
    private static final Integer CLASS_COUNT = 200;
    private static final Integer LANG_COUNT = 2;
    private static final Integer ENROL_COUNT = 2;
    private static final Integer COURSE_COUNT = 200;
    private static final Integer ETAREL_COUNT = 200;
    private static final Integer ALLOWED_DOMAIN_COUNT = 2;
    private static final Integer ENROL_REQ_COUNT = 200;
    private static final Integer CONTACT_COUNT = 200;
    
     /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method that create the setup test data.
     * @param : 
     */
     private static User usr {get;set;}
    
      static void setUpData(){
        
        usr = TestDataBuilder.buildTestUser(987);
        insert usr;
        
        System.RunAs(usr){
        
            //Inserting Bypass trigger custom setting
            custsettbuild.buildBypassTriggerSettings();
            //re-create the Enrollment Code Configuration Setting
            cTrainSettingBuilder.buildEnrollmentCodeConfiguration();
            
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
                ETAgreementObj.Max_Seats__c = 1;
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
            
            //Creating the Course__c to test Class Not Part of Training Agreement  Exception Reason.
            //Id courserecTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Self-Paced').getRecordTypeId();
            List<Course__c> courseLst1 = new List<Course__c>();
            for(Integer i=0; i<COURSE_COUNT; i++){
                Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(i);
                courseObj.recordTypeId = courserecTypeId;
                courseObj.Course_Code__c = 'TEST'+i;
                courseLst1.add(courseObj);
            }
            insert courseLst1;
            
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
            
            //Creating the Class__c to test Class Not Part of Training Agreement  Exception Reason.
            List<Class__c> clssLst1 = new List<Class__c>();    
            //Id classrecTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Self-Paced').getRecordTypeId();    
            //Creating the test data for Class Object. 
            for(Integer i=0;i<CLASS_COUNT;i++){            
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseLst1[i].Id, langLst[0].Id);
                clssObj.Max_Seats__c  = 500;
                clssObj.recordTypeId = classrecTypeId;
                clssLst1.add(clssObj);
            }
            insert clssLst1;
            
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
            
            
            
            
            System.debug('Con Obj List ## ' +conList);
            List<Enrollee_Blacklist__c> enroleeBlackLst = new List<Enrollee_Blacklist__c>();
            //Create test data for Enrollee BlackList
            for(Enterprise_Training_Agreement__c etaObj : ETagreeemntLst){
                Enrollee_Blacklist__c eBlackLstObj = new Enrollee_Blacklist__c();
                eBlackLstObj.Email__c = 'dummyEmail@testmail.com';
                eBlackLstObj.Enterprise_Training_Agreement__c = etaObj.Id;
                eBlackLstObj.Notes__c = 'Test Notes';
                enroleeBlackLst.add(eBlackLstObj);
            }
            insert enroleeBlackLst;
            
            List<Allowed_Domains__c> allowedDomainsLst = new List<Allowed_Domains__c>();
            //Create Test data for the Allowed_Domains__c  Object.
            for(Enterprise_Training_Agreement__c etaObj : ETagreeemntLst){ 
                Allowed_Domains__c allowedDomainsObj = new Allowed_Domains__c();
                    
                allowedDomainsObj.Enterprise_Training_Agreement__c = etaObj.Id;
                allowedDomainsObj.Name = usr.Email.substringAfter('@');
                allowedDomainsLst.add(allowedDomainsObj);    
            }
            insert allowedDomainsLst; 
            
            //Disable the EnrollmentCode Trigger to create bulk code.
            Bypass_Triggers__c bypassTriggerObj = [SELECT Trigger_Objects__c, Triggers_Disabled__c FROM Bypass_Triggers__c];
            bypassTriggerObj.Triggers_Disabled__c = True;
            bypassTriggerObj.Trigger_Objects__c = 'EnrollmentCode';
            update bypassTriggerObj;            
            
            List<Enrollment_Code__c> enrolCodeLst = new List<Enrollment_Code__c>();
            //Create Test Data for Enrollment Code
            for(Integer i=0; i<ENROLLMENT_CODE_COUNT; i++){
                Enrollment_Code__c enrolCode = CTrainingTestDataBuilder.buildTestEnrollmentCode(ETagreeemntLst[i].Id);
                enrolCode.Status__c = 'Revoked';
                enrolCode.Code__c = String.valueOf(i);
                enrolCodeLst.add(enrolCode);
            }
            insert enrolCodeLst;
            
            bypassTriggerObj.Triggers_Disabled__c = False;
            bypassTriggerObj.Trigger_Objects__c = 'EnrollmentRequest';
            update bypassTriggerObj;
            
        }//End of Run As
    }//End of Method
    
   
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request having the Revoked Code.
     * @param : 
     */
    
    private static testMethod void validateETAOnEnrollmentReqForRevokedCodeTest(){
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
        
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
                                                
            System.assertEquals(eCodeList.size(), 200);
            
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            
            //Create the Enrollment Request
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                //For Revoke Code
                enrolReqObj.Enrollment_Code__c = eCodeList[i].code__c;
                enrolReqList.add(enrolReqObj);
            }
            insert enrolReqList;
            
            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enrollment_Code__c];
            
            System.assertEquals(insertedEnrolReq.size(), 200);
            //Asserting the Enrollment Request is having the Revoked Enrollment Code Exception Reason
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Enrollment Code Revoked');
            }
            test.stopTest();
        }//End of Run As
    }//End of Method
    
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request having the Invalid or not.
     * @param : 
     */
    
    private static testMethod void validateETAOnEnrollmentReqForInvalidCodeTest(){
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
        
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            //Creating the Enrollment Request
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                //For Nonexistent Code
                enrolReqObj.Enrollment_Code__c = i+'EDOC';
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;
            
            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enrollment_Code__c];
            
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting Enrollment Request is having the INVALID ENROLLMENT CODE
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Invalid Enrollment Code');
            }
            test.stopTest();
        }//End of Run As
    }//End of Method
    
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */
    
    private static testMethod void validateETAOnEnrollmentReqForPopulateETATest(){
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            //Quering the Enrollment Code and Enterprise Training Agreement list.
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            System.assertEquals(etarList.size(), 200);
            System.assertEquals(eCodeList.size(), 200);
            
            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enrollment_Code__c = updateECodeLst[i].code__c;
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;
            
            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Enterprise_Training_Agreement__c, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            
            System.assertEquals(insertedEnrolReq.size(), 200);
            //Asserting the Enterprise Training Agreement is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Enterprise_Training_Agreement__c, etarList[i].Enterprise_Training_Agreement__c);
            }
            //Stop Test
            test.stopTest();
        }//End of Run As
    }//End of Method
    
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */
    
    private static testMethod void validateInactiveETATest(){
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            //Quering the Enrollment Code and Enterprise Training Agreement list.
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Enterprise_Training_Agreement__c> etarList = [SELECT Id, Term_End_Date__c, Term_Start_Date__c, Is_Active__c FROM Enterprise_Training_Agreement__c Order By Id];
            
            System.assertEquals(etarList.size(), 200);
            System.assertEquals(eCodeList.size(), 200);
            
            List<Enterprise_Training_Agreement__c> updateETALst = new List<Enterprise_Training_Agreement__c>();
            for(Enterprise_Training_Agreement__c etaObj : etarList){
                etaObj.Term_Start_Date__c = Date.Today().addDays(-2);
                etaObj.Term_End_Date__c = Date.Today().addDays(-1);
                updateETALst.add(etaObj);
            }
            update updateETALst;
            
            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enrollment_Code__c = updateECodeLst[i].Code__c;
                enrolReqList.add(enrolReqObj);
            }
            insert enrolReqList;
            
            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Email__c, Enterprise_Training_Agreement__c, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Inactive Agreement');
            }
        }//End of RunAs
    }//End of Method
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */
     
     private static testMethod void validateInvalidEmailDomainTest(){
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            List<Enrollee_BlackList__c> enrolBlackLst = [SELECT Email__c FROM Enrollee_BlackList__c];
            
            System.assertEquals(etarList.size(), 200);
            
            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Email__c = 'test'+i+'@test.com';
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;
            System.debug('##enrolReqList '+enrolReqList);
            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Email__c, Enterprise_Training_Agreement__c, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            for(Integer i=0;i<200;i++){
                System.debug('&&insertedEnrolReq&& ' +insertedEnrolReq[i].Email__c);
                System.debug('&&insertedEnrolReq&& Reason ' +insertedEnrolReq[i].Exception_Reason__c);
            }
            System.assertEquals(insertedEnrolReq.size(), 200);
            //Asserting the Enterprise Training Agreement is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Invalid Email Domain');
            }
            
            test.stopTest();
        }//End of Run As
    }//End of Method
         
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */

    
    private static testMethod void validateContactBlackListTest(){
        EnrollmentRequestDmlTest.setUpData();
        
        System.RunAs(usr){
        
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            
            List<Enrollee_BlackList__c> enrolBlackLst = [SELECT Email__c, Enterprise_Training_Agreement__c FROM Enrollee_BlackList__c 
                                                        Order By Enterprise_Training_Agreement__c];
            Integer j=0;                                          
            List<Enrollee_BlackList__c> updatedEnrolBlackLst = new List<Enrollee_BlackList__c>();
            for(Enrollee_BlackList__c erolBlackLstObj : enrolBlackLst){
                erolBlackLstObj.Email__c = 'test'+j+'@test.com';
                j++;
                updatedEnrolBlackLst.add(erolBlackLstObj);
            }
            update updatedEnrolBlackLst;
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Email__c = 'test'+i+'@test.com';
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c ;
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;
            
            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Email__c, Enterprise_Training_Agreement__c, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            
            System.assertEquals(insertedEnrolReq.size(), 200);
            //Asserting the Enterprise Training Agreement is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Contact Blacklisted');
            }
        }//End of RunAs
    }//End of Method
    
    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */
    
    private static testMethod void validateNoMWProfileTest(){        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert acc;
                    
            List<Contact> conList = [SELECT Id, Email, MathWorks_Account_ID__c FROM Contact];
            List<Contact> updateContactLst = new List<Contact>();
            for(Contact conObj : conList){  
                conObj.MathWorks_Account_ID__c = null;
                updateContactLst.add(conObj);
            }
            update updateContactLst;

            for(Contact conObj : conList) {
                System.assertEquals(conObj.MathWorks_Account_ID__c, null);
            }
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Email__c = 'test'+i+'@test.com';
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Email__c, Enterprise_Training_Agreement__c, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Enterprise Training Agreement is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'No MW Profile');
            }
            
         }//End of RunAs       
    }//End of Method

    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */
    
    private static testMethod void autoPopulateContactTest(){        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert acc;
                    
            List<Contact> conList = [SELECT Id, Email, MathWorks_Account_ID__c FROM Contact Order By Email];
            
            List<Allowed_Domains__c> updateallowedDomainObj = new List<Allowed_Domains__c>();
            List<Allowed_Domains__c> allowedDomainLst = [SELECT Id, Name FROM Allowed_Domains__c];
            for(Allowed_Domains__c allowedDomainObj : allowedDomainLst){
                allowedDomainObj.Name = 'test.com';
                updateallowedDomainObj.add(allowedDomainObj);
            }
            update updateallowedDomainObj;
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Email__c = 'test'+i+'@test.com';
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Contact__c, Email__c, Exception_Reason__c FROM Enrollment_Request__c ORDER BY Email__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            for(Integer i=0;i<200;i++){
                System.debug('Contact__c@@' +insertedEnrolReq[i].Contact__c);
                System.debug('Contact__c@@' +insertedEnrolReq[i].Exception_Reason__c);
            }
            //Asserting the Enterprise Training Agreement is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Contact__c, conList[i].Id);
            }
            
         }//End of RunAs       
    }//End of Method

    /**
     * @author Original: Abhay Verma 
     * @date Original: , Last Modified: 
     * @description Method to check if the Enrollment Request is populated or not.
     * @param : 
     */
    
    private static testMethod void validateContactNotFoundWithTheEmailTest(){        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
        

            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Email__c = 'test'+i+'@testrequest.com';
                enrolReqObj.Class__c = etarList[i].class__c;
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id, Email__c, Enterprise_Training_Agreement__c, Enrollment_Code__c, Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Enterprise Training Agreement is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Contact not found with the email');
            }

        }//End of RunAs
    }//End of Method
    
    
    /**
     * @author Original: Archana Suryawanshi 
     * @date Original: , Last Modified: 
     * @description Method to check Exception Reason 'InValid class'.
     * @param : 
     */
    
    private static testMethod void validateClassOnEnrollmentReqInValidClassExceptionTest(){        
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
        

            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;

            for(Enrollment_Code__c eCodeObj : eCodeList) {
                System.assertEquals(eCodeObj.Status__c, 'Active');
            }
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Batch_ID__c = updateECodeLst[i].Code__c;
                enrolReqObj.Enrollment_Code__c = updateECodeLst[i].code__c;
                enrolReqObj.Class_Format__c = 'Self-Paced';
                enrolReqObj.Course_Code__c = 'TestCourseCode';
                enrolReqObj.Language_Code__c ='Lan';
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id,Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Exception InValid Class
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'InValid Class');
            }

        }//End of RunAs
    }//End of Method

     /**
     * @author Original: Archana Suryawanshi 
     * @date Original: , Last Modified: 
     * @description Method to check Exception Reason 'Class Not Part of Training Agreement' class
     * @param : 
     */
    
    private static testMethod void validateClassForClassNotPartofTrainingAgreementClassExceptionTest(){        
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.Course_Code__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
        

            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;

            for(Enrollment_Code__c eCodeObj : eCodeList) {
                System.assertEquals(eCodeObj.Status__c, 'Active');
            }
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Batch_ID__c = updateECodeLst[i].Code__c;
                enrolReqObj.Enrollment_Code__c = updateECodeLst[i].code__c;
                enrolReqObj.Class_Format__c = 'Self-Paced';
                enrolReqObj.Course_Code__c = 'TEST'+i;
                enrolReqObj.Language_Code__c ='ENU';
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id,Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Exception Class Not Part of Training Agreement Class
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Class Not Part of Training Agreement');
            }

        }//End of RunAs
    }//End of Method   
    
    /**
     * @author Original: Archana Suryawanshi 
     * @date Original: , Last Modified: 
     * @description Method to check Exception Reason 'InActive' class
     * @param : 
     */
    
    private static testMethod void validateClassForInActiveClassExceptionTest(){        
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.course__r.Course_Code__c,class__r.status__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
        
            //Update class as inActive
            List<id> classLst = new List<id>();
            for(Training_Agreement_Class_Relationship__c etarObj : etarList){
                classLst.add(etarObj.class__c);
            }
            List<Class__c> classObjLst = new List<Class__c>();
            for(Class__c classObj : [select id,status__c from Class__c where id in:classLst]){
                classObj.status__c = 'Inactive';
                classObjLst.add(classObj);
            }
            
            Update classObjLst;
            
            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;

            for(Enrollment_Code__c eCodeObj : eCodeList) {
                System.assertEquals(eCodeObj.Status__c, 'Active');
            }
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Batch_ID__c = updateECodeLst[i].Code__c;
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Class_Format__c = 'Self-Paced';
                enrolReqObj.Course_Code__c = etarList[i].class__r.course__r.Course_Code__c;
                enrolReqObj.Language_Code__c ='ENU';
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id,Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Exception InActive Class
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'InActive Class');
            }

        }//End of RunAs
    }//End of Method   
    
    
    /**
     * @author Original: Archana Suryawanshi 
     * @date Original: , Last Modified: 
     * @description Method to check Exception Reason 'Seat Based Class Is Full' class
     * @param : 
     */
    
    private static testMethod void validateClassForSeatBasedClassIsFullExceptionTest(){        
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.course__r.Course_Code__c,class__r.status__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
           
           
            List<id> ETALst = new List<id>();
            for(Training_Agreement_Class_Relationship__c etarObj : etarList){
                ETALst.add(etarObj.Enterprise_Training_Agreement__c);
            }
            List<Enterprise_Training_Agreement__c> etObjLst = new List<Enterprise_Training_Agreement__c>();
            for(Enterprise_Training_Agreement__c etaObj : [select id,Max_Seats__c from Enterprise_Training_Agreement__c where id in:ETALst]){
                etaObj.Max_Seats__c = 1;
                etObjLst.add(etaObj);
            }
            
            Update etObjLst;
            
            
            
            
            
            //Updating the Status of Enrollment Code for populating the Enterprise Training Agreement
            List<Enrollment_Code__c> updateECodeLst = new List<Enrollment_Code__c>();
            for(Enrollment_Code__c eCodeObj : eCodeList){
                eCodeObj.Status__c = 'Active';
                updateECodeLst.add(eCodeObj);
            }
            update updateECodeLst;
            
            Id conId =[select id from contact limit 1].id;
            
            
            List<Enrollment__c > enrolObjLst= new List<Enrollment__c >();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
              Enrollment__c  enrolObj = CTrainingTestDataBuilder.buildTestEnrollment(conId,etarList[i].Class__c);
              enrolObj.Enterprise_Training_Agreement__c=etarList[i].Enterprise_Training_Agreement__c;
              enrolObj.Enrollment_Status__c='Registered';
              enrolObjLst.add(enrolObj );
            }
            
            insert enrolObjLst;
                        
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c=etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Class_Format__c = 'Self-Paced';
                enrolReqObj.Course_Code__c = etarList[i].class__r.course__r.Course_Code__c;
                enrolReqObj.Language_Code__c ='ENU';
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;
            
            

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id,Exception_Reason__c, Status__c FROM Enrollment_Request__c  ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Exception InActive Class
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Exception_Reason__c, 'Seat-Based Class Is Full');
            }

        }//End of RunAs
    }//End of Method   
    
    
    /**
     * @author Original: Archana Suryawanshi 
     * @date Original: , Last Modified: 
     * @description Method to check if Class has been autopopulated.
     * @param : 
     */
    
    private static testMethod void validateClassForAutoPopulateClassLookupTest(){        
        
        EnrollmentRequestDmlTest.setUpData();
        System.RunAs(usr){
            List<Enrollment_Code__c> eCodeList = [SELECT code__c, Status__c FROM Enrollment_Code__c Order by Code__c];
            List<Training_Agreement_Class_Relationship__c> etarList = [SELECT Id, Enterprise_Training_Agreement__c, Class__c, class__r.Format_Of_Class__c, 
                                                                      class__r.course__r.Course_Code__c,class__r.status__c FROM Training_Agreement_Class_Relationship__c order by Enterprise_Training_Agreement__c];
            
            
            //Start Test
            test.startTest();
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0; i<ENROL_REQ_COUNT; i++){
                Enrollment_Request__c enrolReqObj = new Enrollment_Request__c();
                enrolReqObj.Enterprise_Training_Agreement__c = etarList[i].Enterprise_Training_Agreement__c;
                enrolReqObj.Class_Format__c = 'Self-Paced';
                enrolReqObj.Course_Code__c = etarList[i].class__r.course__r.Course_Code__c;
                enrolReqObj.Language_Code__c ='ENU';
                enrolReqList.add(enrolReqObj);
            }
            //Inserting Enrollment Request List
            insert enrolReqList;

            List<Enrollment_Request__c> insertedEnrolReq = [SELECT Id,Class__c,Exception_Reason__c, Status__c FROM Enrollment_Request__c ORDER BY Enterprise_Training_Agreement__c];
            System.assertEquals(insertedEnrolReq.size(), 200);
            
            //Asserting the Class is populating on the Enrollment Request Object.
            for(Integer i=0;i<200;i++){
                System.assertEquals(insertedEnrolReq[i].Class__c, etarList[i].Class__c);
            }

        }//End of RunAs
    }//End of Method   
     
    
}//End of Class