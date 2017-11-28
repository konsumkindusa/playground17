/**
 *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: Abhay Verma - 
 *@date Original:   14 April 2016, Last Modified: 
 *@description:     This is a test class for RegisterTrainingController.
 */

@isTest
private class RegisterTrainingControllerTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();
    
    private static final Integer ETAREEMENT_COUNT = 3;
    private static final Integer ENROLLMENT_CODE_COUNT = 2;
    private static final Integer CLASS_COUNT = 7;
    private static final Integer LANG_COUNT = 2;
    private static final Integer ENROL_COUNT = 4;
    private static final Integer COURSE_COUNT = 5;
    private static final Integer ETAREL_COUNT = 5;
    private static final Integer ALLOWED_DOMAIN_COUNT = 2;
    private static User usr;
    private static List<User> portalusrLst;
    private static List<Contact> conList;
    private static List<Account> accLst;
    
    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to setup the portal user.
        @returns        
    */
    
    static void setupUserData(){
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        //re-create the Enrollment Code Configuration Setting
        cTrainSettingBuilder.buildEnrollmentCodeConfiguration();
        
        //Create test user
        Set<String> customerUserTypes = new Set<String> {'CspLitePortal', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        
        usr = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        accLst = new List<Account>();
        for(Integer i=0;i<2;i++){
            Account acc = TestDataBuilder.buildTestAccount(i, usr.Id);
            accLst.add(acc);            
        }
        insert accLst;
        System.debug('###accLst'+accLst);
        conList = new List<Contact>();
        for(Integer i=0; i<2; i++){  
            Contact con = TestDataBuilder.buildTestContact(i, usr.Id, accLst[0].Id); 
            con.email = 'testPorTalUser'+i+'@mwtest.com';
            conList.add(con);
        }
        insert conList;
             
        System.runAs(usr) {
            //Creating Portal User
            Profile p = [SELECT Id, Name, UserType FROM Profile WHERE UserType IN :customerUserTypes LIMIT 1];
            portalusrLst = new List<User>();
            for(Integer i=0;i<2;i++){           
                User portalUser = new User(
                profileId = p.id,
                username = 'testPortalUser'+i+'@mwtest.com',
                email = 'testPorTalUser'+i+'@mwtest.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser'+i,
                lastname='lastname' +i,
                contactId = conList[i].id
                );
                portalusrLst.add(portalUser);
            }
            insert portalusrLst; 
            
            Profile guestUsrProfile = [SELECT Id, Name, UserType FROM Profile WHERE Name =:'Guest License User' LIMIT 1];
            
            User guestUser = new User(
                profileId = guestUsrProfile.id,
                username = 'testGuestUser@mwtest.com',
                email = 'testguestuser@mwtest.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='guser',
                lastname='guestUser'
            );
            insert guestUser;
            
        }//End of RunAs             
    }//End of Method  
    
     /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to setup the test data.
        @returns        
    */
    
    @TestSetup static void setUpData(){
    
        RegisterTrainingControllerTest.setupUserData();
        
        usr = [SELECT Id, username, ContactId FROM User WHERE Id =: portalusrLst[0].Id];
        System.runAs(usr) {
        
            List<Language__c> langLst = new List<Language__c>();
            //create Language__c record from CTrainingTestDataBuilder.
            for(Integer i=0; i<LANG_COUNT; i++){
                Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                langObj.SF_ISO_Code__c = (i==0 ? 'en_US' : 'ko');
                langLst.add(langObj);
            }
            insert langLst;
            
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
        
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<ETAREEMENT_COUNT;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c eTAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                ETAgreementObj.Max_Seats__c = 200;
                System.debug('eTAgreementObj.Term_Start_Date__c'+eTAgreementObj.Term_Start_Date__c);
                if(i==1){
                    //Setting an Inactive ETA.
                    eTAgreementObj.Term_Start_Date__c = Date.Today().addDays(-2);
                    eTAgreementObj.Term_End_Date__c = Date.Today().addDays(-1);
                    System.debug('Come In 1');
                }
                else if(i==2){
                    //Setting an ETA Having language as Korean
                    eTAgreementObj.Language__c = langLst[1].Id;
                    System.debug('Come In 2');
                }
                ETagreeemntLst.add(ETAgreementObj);
            }
            System.debug('$$$$ETagreeemntLst$$$'+ETagreeemntLst);
            insert ETagreeemntLst;
            
            Id courserecTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
            List<Course__c> courseLst = new List<Course__c>();
            for(Integer i=0; i<COURSE_COUNT; i++){
                Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(i);
                courseObj.recordTypeId = courserecTypeId;
                courseObj.Course_Code__c = 'TESTCODE'+i;
                courseLst.add(courseObj);
            }
            insert courseLst;
        
            List<Class__c> clssLst = new List<Class__c>();    
             Id classrecTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Self-Paced').getRecordTypeId();    
            //Creating the test data for Class Object. 
            for(Course__c courseObj1 : courseLst){            
                Integer i=0;
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i++, courseObj1.Id, langLst[0].Id);
                clssObj.Max_Seats__c  = 500;
                clssObj.recordTypeId = classrecTypeId;
                clssLst.add(clssObj);
            }
            insert clssLst;
            
            List<Enterprise_Training_Agreement__c> etaLst = [SELECT Id, Is_Active__c FROM Enterprise_Training_Agreement__c];
            List<Training_Agreement_Class_Relationship__c> TACRelLst = new List<Training_Agreement_Class_Relationship__c>(); 
            for(Enterprise_Training_Agreement__c etaObj : etaLst){
                if(etaObj.Is_Active__c){
                    for(Class__c clsObj : clssLst){                
                        Training_Agreement_Class_Relationship__c TACRelObj;
                        TACRelObj = CTrainingTestDataBuilder.buildTestTAClassRelationship(clsObj.Id, etaObj.Id);
                        TACRelLst.add(TACRelObj);
                    }
                }
            }
            insert TACRelLst;  
        
            List<Enrollment_Code__c> enrolCodeLst = new List<Enrollment_Code__c>();
            //Create Test Data for Enrollment Code
            for(Enterprise_Training_Agreement__c etaObj : ETagreeemntLst){            
                for(Integer i=0; i<ENROLLMENT_CODE_COUNT; i++){
                    Enrollment_Code__c enrolCode = CTrainingTestDataBuilder.buildTestEnrollmentCode(etaObj.Id);
                    enrolCode.Status__c = (i==0 ? 'Active' : 'Revoked');
                    enrolCodeLst.add(enrolCode);
                }
            }
            insert enrolCodeLst;

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
                for(Integer i=0;i<ALLOWED_DOMAIN_COUNT ;i++){
                    Allowed_Domains__c allowedDomainsObj = new Allowed_Domains__c();
                    
                    allowedDomainsObj.Enterprise_Training_Agreement__c = etaObj.Id;
                    allowedDomainsObj.Name = (i==0?portalUsrLst[0].Email.substringAfter('@') : 'alloweddomain.com');
                    allowedDomainsObj.Allow_Sub_Domain__c = (i==0? True : False);
                    allowedDomainsLst.add(allowedDomainsObj);
                }
            }
            insert allowedDomainsLst;
            system.debug('**AllowedDomains***'+allowedDomainsLst);
            
        }//End of RunAs
    }//End of Method

    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test the scenario for validate the enrollment code
                        and create the new enrollment after choosing the class to enrollment.
        @returns        
    */

    private static testMethod void validateAndCreateNewEnrollmentTest(){
        
        usr = [SELECT Id, username, FirstName, LastName, profile.Name, Email, ContactId 
                   FROM User WHERE username = 'testPortalUser0@mwtest.com' LIMIT 1];
        System.RunAs(usr){
        
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c, Enterprise_Training_Agreement__r.Term_End_Date__c FROM Enrollment_Code__c 
                                         LIMIT 1];
            Language__c langObj = [SELECT SF_ISO_Code__c FROM Language__c WHERE SF_ISO_Code__c = 'en_US'];
            
            List<Allowed_Domains__c>  allowList = [Select Id,Name From Allowed_Domains__c ];
            
            PageReference pageRef = Page.RegisterTraining;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            ApexPages.currentPage().getParameters().put(TrainingUtil.LANGUAGE_URL_PARAM_KEY, langObj.SF_ISO_Code__c);

            RegisterTrainingController Obj = new RegisterTrainingController();
            
            Obj.eCode = eCodeObj;
            Obj.language = TrainingUtil.DEFAULT_LANGUAGE_CODE;
            system.assertEquals(Obj.isEnrolleeFromAllowedDomain,true);
            String data = obj.termEndDate;
            Obj.getAllETAClasses();
            
            for(Integer i=0; i < Obj.availableClassesMap.values().size(); i++){
                if(i == 0){
                    Obj.availableClassesMap.values()[i].isNewEnrollment = True;
                }
                else{
                    Obj.availableClassesMap.values()[i].isNewEnrollment = False;
                }
            }
            
            Obj.enrollForNewClasses();
            Obj.getEnrolledClassCount();
            Obj.getAvailableClassCount();
            obj.getAvailableClasses();
            obj.getEnrolledClasses();
            List<Enrollment_Request__c> newEnrollment = new List<Enrollment_Request__c>();
            newEnrollment = [SELECT Id, Batch_ID__c, Contact__c, Class__c, Class_Format__c, Course_Code__c,
                                                   Email__c, Enrollment_Code__c, Enterprise_Training_Agreement__c, 
                                                   First_Name__c, Last_Name__c, Language_Code__c,
                                                   Source__c FROM Enrollment_Request__c WHERE class__c = :Obj.availableClassesMap.values()[0].etaclass.Id LIMIT 1];
            
            System.assertEquals(newEnrollment.isEmpty(),false);
            System.assertEquals(Obj.isEnrolleeFromAllowedDomain, True);
            System.assertEquals(Obj.isValidEnrollmentCode, True);
            System.assertNotEquals(newEnrollment[0].Id, Null);
            System.assertEquals(Obj.availableClassesMap.values()[0].etaclass.Id, newEnrollment[0].Class__c);  
            System.assertEquals(Obj.availableClassesMap.values()[0].etaclass.Format_Of_Class__c, newEnrollment[0].Class_Format__c);
            System.assertEquals(usr.contactId, newEnrollment[0].Contact__c);
            System.assertEquals(Obj.availableClassesMap.values()[0].etaclass.Course_Code__c, newEnrollment[0].Course_Code__c);
            System.assertEquals(usr.Email, newEnrollment[0].Email__c);
            System.assertEquals(Obj.eCode.code__c, newEnrollment[0].Enrollment_Code__c);
            System.assertEquals(Obj.eCode.Enterprise_Training_Agreement__c, newEnrollment[0].Enterprise_Training_Agreement__c);
            System.assertEquals(usr.FirstName, newEnrollment[0].First_Name__c);
            System.assertEquals(usr.LastName, newEnrollment[0].Last_Name__c);
            System.assertEquals(Obj.availableClassesMap.values()[0].etaclass.Language__r.Language_Code__c, newEnrollment[0].Language_Code__c);
            System.assertEquals('Self-Enrollment Portal', newEnrollment[0].Source__c);
            
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test the scenario for giving the invalid enrollment code.
        @returns        
    */
    
    private static testMethod void invalidEnrollmentCodeTest(){
        
        usr = [SELECT Id, username, Email FROM User WHERE username = 'testPortalUser0@mwtest.com' LIMIT 1];
        System.RunAs(usr){
            Language__c langObj = [SELECT SF_ISO_Code__c FROM Language__c WHERE SF_ISO_Code__c = 'en_US'];
            
            ApexPages.currentPage().getParameters().put(TrainingUtil.LANGUAGE_URL_PARAM_KEY, langObj.SF_ISO_Code__c);
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, 'ABCD1234WXYZ');
            
            RegisterTrainingController Obj = new RegisterTrainingController();
            Obj.checkEnrollmentCode();
            System.assertEquals(Obj.isNonExistentEnrollmentCode, True);
            
        }//End of RunAs 
    }//End of Method
    
     /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test the scenario for giving the valid enrollment code.
        @returns        
    */
    
    private static testMethod void validEnrollmentCodeTest(){
        
        usr = [SELECT Id, username, Email FROM User WHERE username = 'testPortalUser0@mwtest.com' LIMIT 1];
        System.RunAs(usr){
            
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c WHERE Status__c = 'Active' LIMIT 1];
            Language__c langObj = [SELECT SF_ISO_Code__c FROM Language__c WHERE SF_ISO_Code__c = 'en_US'];
            
            ApexPages.currentPage().getParameters().put(TrainingUtil.LANGUAGE_URL_PARAM_KEY, langObj.SF_ISO_Code__c);
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            
            RegisterTrainingController Obj = new RegisterTrainingController();
            
            Obj.language = 'en_US';
            Obj.enrollmentCode = eCodeObj.code__c;
            String logoutURL = String.format(System.Label.CP_ENROLL_SSOLogoutURL, new List<String> {eCodeObj.Code__c, langObj.SF_ISO_Code__c});
            Obj.getLogoutURL();
            Obj.checkEnrollmentCode();
            System.assertEquals(logoutURL, Obj.getLogoutURL());
            System.assertEquals(Obj.isNonExistentEnrollmentCode, False);
        }//End of RunAs 
    }//End of Method
    
     /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test the scenario if the blacklisted user try to enroll.
        @returns        
    */
    
    private static testMethod void blackLstTest(){
        
        usr = [SELECT Id, username, Email FROM User WHERE username = 'testPortalUser0@mwtest.com' LIMIT 1];
        System.RunAs(usr){
            
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c WHERE Status__c = 'Active' LIMIT 1];
            
            Enrollee_Blacklist__c enrolBlackLstObj = [SELECT Email__c, Enterprise_Training_Agreement__c FROM Enrollee_Blacklist__c
                                                     WHERE Enterprise_Training_Agreement__c  =: eCodeObj.Enterprise_Training_Agreement__c LIMIT 1];
            enrolBlackLstObj.Email__c = usr.Email;
            update enrolBlackLstObj;
            
            Language__c langObj = [SELECT SF_ISO_Code__c FROM Language__c WHERE SF_ISO_Code__c = 'en_US'];
            System.debug('QUERY!!'+[SELECT Id FROM Course_Language__c]);
            
            PageReference pageRef = Page.RegisterTraining;
            Test.setCurrentPage(pageRef);
            
            
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            RegisterTrainingController Obj = new RegisterTrainingController();
            Obj.language = langObj.SF_ISO_Code__c;
            
            System.assertEquals(Obj.isEnrolleBlacklisted, True);
            
        }//End RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test the scenario for the user not are in allowed domain.
        @returns        
    */
    
    private static testMethod void notInAllowedDomainTest(){
        
        usr = [SELECT Id, username, Email FROM User WHERE  username = 'testPortalUser0@mwtest.com' LIMIT 1];
        System.RunAs(usr){
            
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c LIMIT 1];
            
            Allowed_Domains__c allowedDomainObj = [SELECT Name, Enterprise_Training_Agreement__c FROM Allowed_Domains__c 
                                                  WHERE Enterprise_Training_Agreement__c =: eCodeObj.Enterprise_Training_Agreement__c LIMIT 1];
            
            allowedDomainObj.Name = 'testDomain@notallowed.com'.substringAfter('@');
            update allowedDomainObj;
            system.debug('*****Updated Allowee Domain*****'+ allowedDomainObj);
             
            Language__c langObj = [SELECT SF_ISO_Code__c FROM Language__c WHERE SF_ISO_Code__c = 'en_US'];
            
            PageReference pageRef = Page.RegisterTraining;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            ApexPages.currentPage().getParameters().put(TrainingUtil.LANGUAGE_URL_PARAM_KEY, langObj.SF_ISO_Code__c);
            RegisterTrainingController Obj = new RegisterTrainingController();
            
            System.assertEquals(Obj.isEnrolleeFromAllowedDomain, False);
            
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test for an inactive ETA.
        @returns        
    */
    
    private static testMethod void inActiveETATest(){
        
        //Query the Portal User for RunAs User Enviroment.
        usr = [SELECT Id, UserName, Email FROM User WHERE username = 'testPortalUser0@mwtest.com' LIMIT 1];
        
        System.RunAs(usr){
            //Querying the Enrollment Code.
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c 
                                          WHERE Enterprise_Training_Agreement__r.Is_Active__c = False LIMIT 1];
            
            PageReference pageRef = Page.RegisterTraining;
            Test.setCurrentPage(pageRef);
            //Setting the Enrollment Code on the URL
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            
            RegisterTrainingController Obj = new RegisterTrainingController();
            System.assertEquals(Obj.isInactiveEtaCode, True);
            
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test for revoked Enrollment code Test.
        @returns        
    */
    
    private static testMethod void revokedEnrollmentTest(){
        
        //Query the Portal User for RunAs User Enviroment.
        usr = [SELECT Id, UserName, Email FROM User WHERE username = 'testPortalUser0@mwtest.com' LIMIT 1];
        
        System.RunAs(usr){
            //Querying the Enrollment Code.
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c WHERE Status__c = 'Revoked' LIMIT 1];
            
            PageReference pageRef = Page.RegisterTraining;
            Test.setCurrentPage(pageRef);
            
            //Setting the enrollment code on URL
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            
            RegisterTrainingController Obj = new RegisterTrainingController();
            System.assertEquals(Obj.isEnrollmentCodeRevoked, True);
            
        }//End of RunAs
    }//End of Method
    
    /*
        @author         Abhay Verma
        @date           27/05/2016
        @description    Method to test for the scenario having the profile as guest user
                        so need to redirect to the Self Enrollment Unauthenticated Page.
        @returns        
    */
    
    private static testMethod void checkProfileTypeTest(){
        //Query the Portal User for RunAs User Enviroment.
        usr = [SELECT Id, UserName, Email FROM User WHERE username = 'testGuestUser@mwtest.com' LIMIT 1];
        
            //Querying the Enrollment Code.
            Enrollment_Code__c eCodeObj = [SELECT Id, Code__c, Status__c, Enterprise_Training_Agreement__c, 
                                          Enterprise_Training_Agreement__r.Is_Active__c FROM Enrollment_Code__c WHERE Status__c = 'Revoked' LIMIT 1];
                
            
            //Querying the Training Agreement Settings Custom Setting.
            Training_Agreement_Settings__c enrolTrainingCustomSetting = [SELECT Id, Self_Enrollment_Unauthenticated_URL__c FROM Training_Agreement_Settings__c LIMIT 1];
            
            System.RunAs(usr){
             
            PageReference pageRef = Page.RegisterTraining;
            Test.setCurrentPage(pageRef);
            
            //Setting the enrollment code on URL
            ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, eCodeObj.Code__c);
            
            RegisterTrainingController Obj = new RegisterTrainingController();
            PageReference redirectUrl = obj.checkProfileType();
            
            //Asserting the Url if it is redirecting to the Self Enrollment Unauthenticated Page.
            System.assertEquals(enrolTrainingCustomSetting.Self_Enrollment_Unauthenticated_URL__c + eCodeObj.code__c, redirectUrl.getUrl());
        
        }//End of Run As
    }//End of Method
}//End of Class