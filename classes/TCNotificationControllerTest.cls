/** 
 *@author Original: Sagar Talele - Accenture/Mathworks, Last Modified: 
 *@date Original: 18 May 2016, Last Modified: 18 May 2016
 *@description This  is handler class for 'EnrollmentConfirmationController' . 
 */ 

@isTest
private class TCNotificationControllerTest{
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();
    
     private static final Integer ETAREEMENT_COUNT = 10;
    private static final Integer ENROLLMENT_CODE_COUNT = 10;
    private static final Integer CLASS_COUNT = 10;
    private static final Integer LANG_COUNT = 2;
    private static final Integer ENROL_COUNT = 2;
    private static final Integer COURSE_COUNT = 10;
    private static final Integer ETAREL_COUNT = 10;
    private static final Integer ALLOWED_DOMAIN_COUNT = 2;
    private static final Integer ENROL_REQ_COUNT = 10;
    private static final Integer CONTACT_COUNT = 10;
    private static User usr {get;set;}
    /**
    * @author Original: Sagar Talele
    * @date Original:18 May 2016 , Last Modified: 18 May 2016
    * @description Method that create the setup test data.
    * @param : 
    */
    static void setUpData(){
        // private static User usr {get;set;}
        usr = TestDataBuilder.buildTestUser(1);
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
            
           //test data list of sponsor office
            List<Sponsor_Office__c > sponsorOffList = new List<Sponsor_Office__c >();
            for(Integer j=0;j<ETAREEMENT_COUNT;j++ ){
                Sponsor_Office__c sponsor = CTrainingTestDataBuilder.buildTestSponsorOffice(j,langLst[0].Id);
                sponsor.Training_URL__c = 'traning@testUrl.com';
                sponsor.MATLAB_Academy_URL__c= 'matlabAcademy@testUrl.com';
                sponsorOffList.add(sponsor);    
               
            }
            insert sponsorOffList;
            
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
            //Creating the Enterprise_Training_Agreement__c test data.
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<ETAREEMENT_COUNT;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c eTAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                ETAgreementObj.Max_Seats__c = 1;
                ETAgreementObj.Term_Start_Date__c = Date.Today().addDays(-2);
                ETAgreementObj.Term_End_Date__c = Date.Today().addDays(-1);
                ETAgreementObj.Sponsor_Office__c = sponsorOffList[i].Id;
                ETAgreementObj.Primary_Contact__c = conList[i].id;
                ETAgreementObj.Account_Name__c = acc.id;
                ETAgreementObj.Language__c = langLst[0].Id;
                ETAgreementObj.Active_Self_Enrollment_URL__c = 'test@url.com';
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

            
            
            
        }//End of Run As
    }//End of Method
    /**
     * @author Original: Saagr Talele 
     * @date Original:18 May 2016 , Last Modified: 18 May 2016
     * @description Method to test controller method EnrollName
     * @param : 
     */
    
    private static testMethod void EnrollNameTest(){
        TCNotificationControllerTest.setUpData();
        Enterprise_Training_Agreement__c etaObj = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_End_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c limit 1];
        System.RunAs(usr){
        System.assertEquals(etaObj!= null,true);
        TCNotificationController controller = new TCNotificationController();
        controller.etaId  = etaObj.Id;
        String enrolleName = controller.getEnrollName();
        System.assertEquals(enrolleName!= null,true);
        controller.lang = 'en_US';
        String lang = controller.language;
        
        }
        
    }
    /**
     * @author Original: Saagr Talele 
     * @date Original:18 May 2016 , Last Modified: 18 May 2016
     * @description Method to test termEndDate controller method
     * @param : 
     */
    
    private static testMethod void etaExpiryDateTest(){
        TCNotificationControllerTest.setUpData();
        Enterprise_Training_Agreement__c etaObj = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_End_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c limit 1];
        System.RunAs(usr){
        System.assertEquals(etaObj!= null,true);
        TCNotificationController controller = new TCNotificationController();
        controller.etaId  = etaObj.Id;
        controller.etaObj = etaObj;
        String termEndDate = controller.getEtaExpiryDate();
        System.assertEquals(termEndDate!= null,true);
        }
    }
    
    
      /**
     * @author Original: Shweta Shanbhag
     * @date Original:12 Sep 2016 , Last Modified: 12 Sep 2016
     * @description Method to test termStartDate controller method
     * @param : 
     */
    
    private static testMethod void etaStartDateTest(){
        TCNotificationControllerTest.setUpData();
        Enterprise_Training_Agreement__c etaObj = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_Start_Date__c,                      
                    Term_End_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c limit 1];
        System.RunAs(usr){
        System.assertEquals(etaObj!= null,true);
        TCNotificationController controller = new TCNotificationController();
        controller.etaId  = etaObj.Id;
        controller.etaObj = etaObj;
        String termStartDate = controller.getEtaStartDate();
        System.assertEquals(termStartDate!= null,true);
        }
    }
    
    
     /**
     * @author Original: Saagr Talele 
     * @date Original:18 May 2016 , Last Modified: 18 May 2016
     * @description Method to test RealatedEtaCourses controller method
     * @param : 
     */
    
    private static testMethod void RealatedEtaCoursesTest(){
        TCNotificationControllerTest.setUpData();
        List<Training_Agreement_Class_Relationship__c> TACRelLst = new List<Training_Agreement_Class_Relationship__c>();
        TACRelLst = [Select id,Class__c,Enterprise_Training_Agreement__c 
                            From Training_Agreement_Class_Relationship__c limit 1 ];
        system.assertEquals(TACRelLst != null,true);
        Enterprise_Training_Agreement__c etaObj = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_End_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c limit 1];
        TCNotificationController controller = new TCNotificationController();
        controller.etaId  = etaObj.Id;
        controller.etaObj = etaObj;
        String course = controller.getRelatedEtaCourses();
        system.assertEquals(course != null,true);
        
        controller.lang = null;
        String lang = controller.language;
        
    }
    
       
    /**
     * @author Original: Shweta Shanbhag
     * @date Original:August 2 2016 , Last Modified: August 2 2016
     * @description Method to test RealatedEtaCourses controller method when the lang record does not exist on language display object
     * @param : 
     */
     private static testMethod void RelatedEtaCoursesTest_DefaultLang(){
        TCNotificationControllerTest.setUpData();
        List<Training_Agreement_Class_Relationship__c> TACRelLst = new List<Training_Agreement_Class_Relationship__c>(); 
        
         
         Enterprise_Training_Agreement__c etaObj = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_End_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c limit 1];
      
        Language__c langdata = [Select Id,Language_Code__c, SF_ISO_Code__c, ISO_Code__c from Language__c where Language_Code__c=: 'ja' limit 1];
         
        etaObj.Language__c = langdata.Id;
       
        update etaObj;
         
        Enterprise_Training_Agreement__c etaObjupd = [Select Id,Primary_Contact__r.Name,
                    Primary_Contact__r.LastName,
                    Primary_Contact__r.FirstName,
                    Account_Name__r.Name,
                    Account_Name__c,
                    Sponsor_Office_Phone__c,
                    Sponsor_Office_Email__c,
                    Sponsor_Office_Signature__c,
                    Term_End_Date__c,
                    Language__r.SF_ISO_Code__c,
                    Active_Self_Enrollment_URL__c
                    From Enterprise_Training_Agreement__c where id=: etaObj.Id];
         
        TACRelLst = [Select id,Class__c,Enterprise_Training_Agreement__c 
                            From Training_Agreement_Class_Relationship__c limit 1 ];
        system.assertEquals(TACRelLst != null,true);
        
        TCNotificationController controller = new TCNotificationController();
        controller.etaId  = etaObjupd.Id;
        controller.etaObj = etaObjupd;
        String course = controller.getRelatedEtaCourses();
        String enrolleName = controller.getEnrollName();
        system.assertEquals(course != null,true);
         
        controller.lang = 'nl';
        String lang = controller.language;
     
    }
     
}