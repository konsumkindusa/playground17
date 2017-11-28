@isTest
private class TrainingUtilTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();

    private static final Integer RECORD_COUNT =  200;
    private static User usr;
    
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
            
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<RECORD_COUNT;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c ETAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                ETAgreementObj.Max_Seats__c = 200;
                ETagreeemntLst.add(ETAgreementObj);
            }
            insert ETagreeemntLst;
            
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
            
             //Creating the Training_Agreement_Class_Relationship__c test data.
            List<Training_Agreement_Class_Relationship__c> TACRelLst = new List<Training_Agreement_Class_Relationship__c>(); 
            for(Integer i=0;i<RECORD_COUNT;i++){
                Training_Agreement_Class_Relationship__c TACRelObj;
                TACRelObj = CTrainingTestDataBuilder.buildTestTAClassRelationship(clssLst[i].Id, ETagreeemntLst[i].Id);
                TACRelLst.add(TACRelObj);
            }
            insert TACRelLst;  
            
            //Disable the EnrollmentCode Trigger to create bulk code.
            Bypass_Triggers__c bypassTriggerObj = [SELECT Trigger_Objects__c, Triggers_Disabled__c FROM Bypass_Triggers__c];
            bypassTriggerObj.Triggers_Disabled__c = True;
            bypassTriggerObj.Trigger_Objects__c = 'EnrollmentCode';
            update bypassTriggerObj;   
            
            List<Enrollment_Code__c> enrolCodeLst = new List<Enrollment_Code__c>();
            //Create Test Data for Enrollment Code

            for(Integer i=0; i<RECORD_COUNT; i++){
                Enrollment_Code__c enrolCode = CTrainingTestDataBuilder.buildTestEnrollmentCode(ETagreeemntLst[i].Id);
                enrolCode.code__c = String.valueOf(i);
                enrolCode.Status__c = 'Revoked';
                enrolCodeLst.add(enrolCode);
            }
            insert enrolCodeLst;

            bypassTriggerObj.Triggers_Disabled__c = False;
            bypassTriggerObj.Trigger_Objects__c = 'EnrollmentCode';
            update bypassTriggerObj;
            
            List<Enrollee_Blacklist__c> enroleeBlackLst = new List<Enrollee_Blacklist__c>();
            //Create test data for Enrollee BlackList
            for(Integer i=0;i<RECORD_COUNT;i++){
                Enrollee_Blacklist__c eBlackLstObj = new Enrollee_Blacklist__c();
                eBlackLstObj.Email__c = 'dummyEmail'+i+'@testmail.com';
                eBlackLstObj.Enterprise_Training_Agreement__c = ETagreeemntLst[i].Id;
                eBlackLstObj.Notes__c = 'Test Notes';
                enroleeBlackLst.add(eBlackLstObj);
            }
            insert enroleeBlackLst;
            
            List<Allowed_Domains__c> allowedDomainsLst = new List<Allowed_Domains__c>();
            //Create Test data for the Allowed_Domains__c  Object.
            for(Integer i=0;i<RECORD_COUNT;i++){
                Allowed_Domains__c allowedDomainsObj = new Allowed_Domains__c();
                allowedDomainsObj.Name = 'domain'+i+'.com';
                allowedDomainsObj.Enterprise_Training_Agreement__c = ETagreeemntLst[i].Id;
                allowedDomainsLst.add(allowedDomainsObj);
            }
            insert allowedDomainsLst;
            
            Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert acc;
                
            List<Contact> conList = new List<Contact>();
            for(Integer i=0; i<RECORD_COUNT; i++){  
                Contact con = TestDataBuilder.buildTestContact(i, usr.Id, acc.Id); 
                conList.add(con);
            }
            insert conList;
            
            List<Enrollment__c> enrolmntLst = new List<Enrollment__c>();
            for(Integer i=0; i<RECORD_COUNT; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, TACRelLst[i].class__c);
                enrolmntObj.Enterprise_Training_Agreement__c = TACRelLst[i].Enterprise_Training_Agreement__c;
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntLst.add(enrolmntObj);
            }
            
            insert enrolmntLst;
            
        }//End of Run As User
    }
    
    public static testMethod void generateEnrollmentCodeTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
        
            List<Enterprise_Training_Agreement__c> etAreementLst = [SELECT Id FROM Enterprise_Training_Agreement__c];
            
            //start test
            Test.startTest();     
            
            List<Enrollment_Code__c> enrolCodeLst = new List<Enrollment_Code__c>();
            
            for(Integer i=0;i<25;i++){
                Enrollment_Code__c enrolCode = CTrainingTestDataBuilder.buildTestEnrollmentCode(etAreementLst[i].Id);
                enrolCode.Status__c = 'Active';            
                enrolCodeLst.add(enrolCode);
            }
            insert enrolCodeLst;
            System.assertEquals(enrolCodeLst.size(), 25);          
            //stop test
            Test.stopTest();
             
        }//End of Run As User
    }//End of Method
    
    public static testMethod void regenerateEnrollmentCodeTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
        
            List<Enterprise_Training_Agreement__c> etAreementLst = [SELECT Id FROM Enterprise_Training_Agreement__c];
            
            List<Enrollment_Code__c> createdEnrolCode = [SELECT Code__c, Enterprise_Training_Agreement__c FROM Enrollment_Code__c];
            System.assertEquals(createdEnrolCode.size(), 200);
            
            //start test
            Test.startTest();     
            
            //Setting the test dupe variable True 
            TrainingUtil.testDuplicateSwitch = True;
            Enrollment_Code__c enrolCode = CTrainingTestDataBuilder.buildTestEnrollmentCode(etAreementLst[0].Id);
            enrolCode.Status__c = 'Active';            
            
            insert enrolCode;          
            //stop test
            Test.stopTest();
        }//End of Run As User
    }//End of Method
    
    public testMethod static void getEnrollmentCodeTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
        
            Enrollment_Code__c enrolmntCode = [SELECT Id,Enterprise_Training_Agreement__c,Status__c, Code__c FROM Enrollment_Code__c LIMIT 1];
            
            Enrollment_Code__c eCode1 = TrainingUtil.getEnrollmentCode('TESTECODE123');
            System.assertEquals(eCode1, null);
            
            Enrollment_Code__c eCode2 = TrainingUtil.getEnrollmentCode(enrolmntCode.code__c);
            System.assertEquals(eCode2.Id, enrolmntCode.id);
        }//End of Run As User
    }//End of Method
    
    public testMethod static void isEnrolleeBlacklistedTest(){
         TrainingUtilTest.dummyData();
         System.runAs(usr){
            Enterprise_Training_Agreement__c etAgreementObj = [SELECT Id FROM Enterprise_Training_Agreement__c LIMIT 1];
            Boolean isBlackListed1 = TrainingUtil.isEnrolleeBlacklisted(etAgreementObj.Id,usr.Email);
            System.assertEquals(isBlackListed1, False);
            
            //Update the Enrollee BlackList record to get the User Email for positive Test
            Enrollee_Blacklist__c enrolleeBlackLst = [SELECT Id, Email__c FROM Enrollee_Blacklist__c where Enterprise_Training_Agreement__c =:etAgreementObj.Id LIMIT 1];
            enrolleeBlackLst.Email__c = usr.Email;
            update enrolleeBlackLst;
            
            Boolean isBlackListed2 = TrainingUtil.isEnrolleeBlacklisted(etAgreementObj.Id,usr.Email);
            System.assertEquals(isBlackListed2, True);
        }//End of Run As user 
    }//End of Method
    /*
        @author         Abhay Verma
        @date           23/03/2016
        @description    test method for testing the scenario i.e Enrolle is From Allowed Domain
        @version :      Abhay Verma(Initial version)
                        Sagar Talele(Updated the test case)
        @returns        boolean
    */
    public testMethod static void isEnrolleeFromAllowedDomainTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            Enterprise_Training_Agreement__c etAgreementObj = [SELECT Id FROM Enterprise_Training_Agreement__c LIMIT 1];
            Boolean isAllowedDomailEnrollee1 = TrainingUtil.isEnrolleeFromAllowedDomain(etAgreementObj.id);
            System.assertEquals(isAllowedDomailEnrollee1, False);
            
            //For positive test set the email domain of User.
            Allowed_Domains__c allowedDomailEnrollee = [SELECT Id,Name FROM Allowed_Domains__c 
                                                        WHERE Enterprise_Training_Agreement__c = :etAgreementObj.Id LIMIT 1];
            allowedDomailEnrollee.Name = usr.Email.split('@')[1];
            update allowedDomailEnrollee;
            
            Boolean isAllowedDomailEnrollee2 = TrainingUtil.isEnrolleeFromAllowedDomain(etAgreementObj.id);
            System.assertEquals(isAllowedDomailEnrollee2, True);
            
            //For positive test set the email domain of User.
            Allowed_Domains__c allowedDomailObj = [SELECT Id,Name FROM Allowed_Domains__c 
                                                        WHERE Enterprise_Training_Agreement__c = :etAgreementObj.Id LIMIT 1];
            allowedDomailObj.Name = 'test@allowDomainTest.com'; 
            update allowedDomailObj;
            
            Boolean isAllowedDomailEnrollee3 = TrainingUtil.isEnrolleeFromAllowedDomain(etAgreementObj.id);
            System.assertEquals(isAllowedDomailEnrollee3, False);
           
          
        }//End of RunAs User
        
        
    }//End of Method
    
    /*
        @author         Archana suryawanshi
        @date           8/07/2016
        @description    test method for testing the scenario i.e Enrolle is From Allowed Domain
        @version :      Archana suryawanshi(Initial version)
        @returns        boolean
    */
    public testMethod static void isEnrolleeFromAllowedDomainIfSubdomainTrueTest(){
        TrainingUtilTest.dummyData();
        User usr1 = TestDataBuilder.buildTestUser(100);
        usr1.email = 'archana.suryawanshi@dev.training.mathworks.com';    
        insert usr1;
        System.runAs(usr1){ 
            
            Enterprise_Training_Agreement__c etAgreementObj = [SELECT Id FROM Enterprise_Training_Agreement__c LIMIT 1];
            //For positive test set the email domain of User.
            Allowed_Domains__c allowedDomailEnrollee = [SELECT Id,Name FROM Allowed_Domains__c 
                                                        WHERE Enterprise_Training_Agreement__c = :etAgreementObj.Id LIMIT 1];
            allowedDomailEnrollee.Name = 'mathworks.com';
            allowedDomailEnrollee.Allow_Sub_Domain__c = true;
            update allowedDomailEnrollee;
            
            Boolean isAllowedDomailEnrollee2 = TrainingUtil.isEnrolleeFromAllowedDomain(etAgreementObj.id);
            System.assertEquals(isAllowedDomailEnrollee2, True);
        }
        
        User usr2 = TestDataBuilder.buildTestUser(101);
        usr2.email = 'archana.suryawanshi@mathworks.com.dev';    
        insert usr2;
        System.runAs(usr2){ 
            
            Enterprise_Training_Agreement__c etAgreementObj = [SELECT Id FROM Enterprise_Training_Agreement__c LIMIT 1];
            //For positive test set the email domain of User.
            Allowed_Domains__c allowedDomailEnrollee = [SELECT Id,Name FROM Allowed_Domains__c 
                                                        WHERE Enterprise_Training_Agreement__c = :etAgreementObj.Id LIMIT 1];
            allowedDomailEnrollee.Name = 'mathworks.com';
            allowedDomailEnrollee.Allow_Sub_Domain__c = true;
            update allowedDomailEnrollee;
            
            Boolean isAllowedDomailEnrollee2 = TrainingUtil.isEnrolleeFromAllowedDomain(etAgreementObj.id);
            System.assertEquals(isAllowedDomailEnrollee2, false);
        }
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           25/03/2016
        @description    test method for testing the scenario validate Enrollment Code
        @version :      
        @returns        
    */
    public testMethod static void validateEnrollmentCodeTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            Enrollment_Code__c enrolCode = [SELECT Status__c, Code__c, Enterprise_Training_Agreement__c, Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c LIMIT 1];
            
            TrainingUtil.ValidationStatus revokeStatus = TrainingUtil.validateEnrollmentCode(enrolCode);
            System.assertEquals(revokeStatus, TrainingUtil.ValidationStatus.REVOKED);
            
            enrolCode.Status__c = 'Active';
            update enrolCode;
            
            TrainingUtil.ValidationStatus activeStatus = TrainingUtil.validateEnrollmentCode(enrolCode);
            System.assertEquals(activeStatus, TrainingUtil.ValidationStatus.VALID);
            
            Enrollment_Code__c nonExistantEnrolCode;
            TrainingUtil.ValidationStatus nonExistantStatus = TrainingUtil.validateEnrollmentCode(nonExistantEnrolCode);
            System.assertEquals(nonExistantStatus, TrainingUtil.ValidationStatus.NON_EXISTENT);
            
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           11/05/2016
        @description    test method for testing the doesLanguageExist Method
        @version :      
        @returns        
    */
    
    private testMethod static void doesLanguageExistTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            Boolean langExist; 
            langExist = TrainingUtil.doesLanguageExist('en_US');
            System.assertEquals(langExist, True);
            
            langExist = TrainingUtil.doesLanguageExist('TEST');
            System.assertEquals(langExist, False);
        }//End of RunAs    
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the getLoggedInUserContactId Method
        @version :      
        @returns        
    */
    
    private testMethod static void getLoggedInUserContactIdTest(){
        TrainingUtilTest.dummyData();
        Set<String> customerUserTypes = new Set<String> {'CspLitePortal', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        //Creating Portal User
        Profile p = [SELECT Id, Name, UserType FROM Profile WHERE UserType IN :customerUserTypes LIMIT 1];
                 
        User portalUser = new User(
        profileId = p.id,
        username = 'testPortalUser@mwtest.com',
        email = 'testPorTalUser@mwtest.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
        
        insert portaluser; 
        
        System.runAs(portaluser){
            Id userContactId = TrainingUtil.getLoggedInUserContactId();
            System.assertEquals(userContactId, con.Id);
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the areEnrolleeBlacklisted Method
        @version :      
        @returns        
    */
    //Need to Ask
    private testMethod static void areEnrolleeBlacklistedTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            
            List<Enterprise_Training_Agreement__c> etaLst = [SELECT Id FROM Enterprise_Training_Agreement__c];
            List<Enrollee_Blacklist__c> enrolBlackLst = [SELECT Email__c FROM Enrollee_Blacklist__c];
            Set<String> etaIdSet = new Set<String>();
            Set<String> blackLstEmailSet = new Set<String>();
            
            for(Integer i=0;i<RECORD_COUNT;i++){
                etaIdSet.add(etaLst[i].Id);
                blackLstEmailSet.add(enrolBlackLst[i].Email__c);
            }
            
            Map<id,Map<string,Boolean>> enrolleeBlackLstMap = TrainingUtil.areEnrolleeBlacklisted(etaIdSet, blackLstEmailSet);
            Map<String, Boolean> emailCheckMap = new Map<String, Boolean>();
            
            for(String key : enrolleeBlackLstMap.keySet()) {
                Map<String, Boolean> blMap = enrolleeBlackLstMap.get(key);
                for(String email : blMap.keySet()) {
                    System.assert(blMap.get(email));
                }
            }
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the getTrainingAgreementClassRelationForETA Method
        @version :      
        @returns        
    */
    
    private testMethod static void getTrainingAgreementClassRelationForETATest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
    
            List<Enterprise_Training_Agreement__c> etaLst = [SELECT Id FROM Enterprise_Training_Agreement__c];
            Set<Id> etaIdSet = new Set<Id>();
            
            for(Integer i=0;i<RECORD_COUNT;i++){
                etaIdSet.add(etaLst[i].Id);
            }
            List<Training_Agreement_Class_Relationship__c> tacRelList = TrainingUtil.getTrainingAgreementClassRelationForETA(etaIdSet);
            System.assertEquals(tacRelList.size(), etaLst.size());
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the getEnrollmentsForETA Method
        @version :      
        @returns        
    */
    
    private testMethod static void getEnrollmentsForETATest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            List<Contact> conLst = [SELECT Email FROM Contact];
            List<Enterprise_Training_Agreement__c> etaLst = [SELECT Id FROM Enterprise_Training_Agreement__c];
            Set<Id> etaIdSet = new Set<Id>();
            Set<String> emailIdSet = new Set<String>();
            for(Integer i=0;i<RECORD_COUNT;i++){
                etaIdSet.add(etaLst[i].Id);
                emailIdSet.add(conLst[i].Email);
            }
            
            Map<Id, List<Enrollment__c>> enrollmentListMap = TrainingUtil.getEnrollmentsForETA(etaIdSet, emailIdSet, 'Registered');
            for(Enterprise_Training_Agreement__c etaObj : etaLst){
                System.assertEquals(enrollmentListMap.get(etaObj.Id).size() > 0, True);
            }
        }//End of RunAs
    }//End of Method
        
    /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the getConsumedSeatCountForETA Method
        @version :      
        @returns        
    */
    
    private testMethod static void getConsumedSeatCountForETATest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            
            List<Contact> conList = [SELECT Id FROM Contact];
            List<Training_Agreement_Class_Relationship__c> TACRelLst = [SELECT class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c];
            List<Enrollment__c> enrolmntLst = new List<Enrollment__c>();
            Set<Id> etaIdSet = new Set<Id>();
            Set<Id> classIdSet = new Set<Id>();
            
            for(Integer i=0;i<RECORD_COUNT;i++){
                etaIdSet.add(TACRelLst[i].Enterprise_Training_Agreement__c);
                classIdSet.add(TACRelLst[i].class__c);
            }
            
            for(Integer i=0; i<5; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, TACRelLst[i].class__c);
                if(i>3){
                    enrolmntObj.Enterprise_Training_Agreement__c = TACRelLst[0].Enterprise_Training_Agreement__c;
                }
                else{
                    enrolmntObj.Enterprise_Training_Agreement__c = TACRelLst[i].Enterprise_Training_Agreement__c;
                }
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntLst.add(enrolmntObj);
            }
            
            insert enrolmntLst;
            
            Map<Id, Map<Id, Integer>> consumedSeatCountETAMap = TrainingUtil.getConsumedSeatCountForETA(etaIdSet, classIdSet);
            
        }//End of RunAs
    }//End of Method
    
     /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the generateGUID Method
        @version :      
        @returns        
    */
    
    private testMethod static void generateGUIDTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            String GUIDcode = TrainingUtil.generateGUID();
            System.assertNotEquals(GUIDcode, Null);
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           16/05/2016
        @description    test method for testing the createEnrollmentFromEnrollmentRequest Method
        @version :      
        @returns        
    */
    
    private testMethod static void createEnrollmentFromEnrollmentRequestTest(){
        TrainingUtilTest.dummyData();
        System.runAs(usr){
            
            List<Enrollment_Code__c> enrolCOdeList = [SELECT Code__c FROM Enrollment_Code__c];
            List<Contact> conList = [SELECT Id FROM Contact];
            List<Training_Agreement_Class_Relationship__c> TACRelLst = [SELECT class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c];
            List<Enrollment_Code__c> updateECodeList = new List<Enrollment_Code__c>();
            
            for(Enrollment_Code__c  eCode : enrolCOdeList){
                eCode.Status__c = 'Active';
                updateECodeList.add(eCode);
            }
            update updateECodeList;
            
            List<Enrollment_Request__c> enrolReqList = new List<Enrollment_Request__c>();
            for(Integer i=0;i<RECORD_COUNT;i++){
                Enrollment_Request__c enrollmentReqObj = new Enrollment_Request__c();
                enrollmentReqObj.Enterprise_Training_Agreement__c = TACRelLst[i].Enterprise_Training_Agreement__c;
                enrollmentReqObj.Class__c = TACRelLst[i].class__c;
                enrollmentReqObj.Contact__c = conList[i].id;
                enrollmentReqObj.Enrollment_Code__c = updateECodeList[i].code__c;
                enrollmentReqObj.Source__c = 'Manual Enrollment';
                enrolReqList.add(enrollmentReqObj);
            }
            insert enrolReqList;
                
            List<Enrollment__c> enrolList = TrainingUtil.createEnrollmentFromEnrollmentRequest(enrolReqList);
            
            System.assertEquals(enrolList.size(),enrolReqList.size());
            for(Integer i=0;i<enrolReqList.size(); i++){
                System.assertEquals(enrolReqList[i].Enterprise_Training_Agreement__c, enrolList[i].Enterprise_Training_Agreement__c);
                System.assertEquals(enrolReqList[i].Class__c, enrolList[i].Class__c);
                System.assertEquals(enrolReqList[i].Contact__c, enrolList[i].Enrollee_Name__c);
                System.assertEquals(enrolReqList[i].Source__c, enrolList[i].Source__c);
            }
        
        }//End of RunAs
    }//End of Method    
    
    
}//End of Class