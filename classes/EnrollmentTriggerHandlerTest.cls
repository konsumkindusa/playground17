/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:   11 Aug 2015, Last Modified:  
 *@description:     This is a test class for EnrollmentTriggerHandler
 */
 
@isTest
public class EnrollmentTriggerHandlerTest{

     /*
    @ name    checkMaxEnrollmentOnClassforInsertTest
    @ date    11 Aug 2015
    @ author  Abhay Verma
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion of Enrollment it will check 
                   if associted class has reached max seat limit or not.
     */              
     
     //re-create custom setting test records when running the test class
     static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
     private static testMethod void checkMaxEnrollmentOnClassforInsertTest(){
         
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
         insert usr;
         System.runAs(usr){
             
             Integer i;
             List<Enterprise_Training_Agreement__c> eTrainAgmntLst = new List<Enterprise_Training_Agreement__c>();
             //Quering the Unlimited Recordtype Id 
             Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
             //Creating Bulk Data for Enterprise Training Agreement Object. 
             Enterprise_Training_Agreement__c etaObj = CTrainingTestDataBuilder.buildTestETAgreement(1); 
                etaObj.recordTypeId = etraAgrerecTypeId;
                //Max Seat 200.
                etaObj.Max_Seats__c = 200;
                eTrainAgmntLst.add(etaObj); 
             
             insert eTrainAgmntLst;
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
                       
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             //Create Sponsor_Office__c 
             Sponsor_Office__c sponOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj.Id);
             sponOfficeObj.Name = 'BNL';
             insert sponOfficeObj ;
             Sponsor_Office__c sponOfficeInt = [Select Id From Sponsor_Office__c Where Id =:sponOfficeObj.Id];
             System.assert(sponOfficeInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             List<Class__c> clssLst = new List<Class__c>();
            //Creating the test data for Class Object. 
            for(i=0; i<=199; i++){
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseObj.Id,langObj.Id);
                    clssObj.Max_Seats__c  = 500; 
                    clssObj.Additional_Seats_Taken__c = 1; 
                	clssObj.RecordTypeId = ClassRecordtypeId;
                    clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                    clssLst.add(clssObj);
            }       
                insert clssLst;
            
            //Creating the test data for Account, Contact and Training Entitlement Object. 
            Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert accObj;
            List<Contact> conList = new List<Contact>();
            for(i=0;i<=399;i++){
                Contact conObj = TestDataBuilder.buildTestContact(i, usr.Id, accObj.id);
                conList.add(conObj);
            }
            insert conList;
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrolmntDatatLst = new List<Enrollment__c>();
            for(i=0; i<=199; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[0].Id);
                enrolmntObj.Enterprise_Training_Agreement__c = eTrainAgmntLst[0].Id;
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntDatatLst.add(enrolmntObj);
            }
            try{
                insert enrolmntDatatLst;
            }
            catch(DmlException ex){
                 for (i = 0; i < ex.getNumDml(); i++) {
                 Logger.debugException('Error in Creating Enrollment Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                 }
            }
            //start test
            test.startTest();
            //create Enrollment__c record from CTrainingTestDataBuilder.
            
                       
            List<Enrollment__c> enrolmntLst = new List<Enrollment__c>();
            for(i=200; i<=399; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[0].Id);
                enrolmntObj.Enterprise_Training_Agreement__c = eTrainAgmntLst[0].Id;
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntLst.add(enrolmntObj);
            }
            try{
                //Inserting the Enrollment.
                insert enrolmntLst;
            }
            catch(DMLException ex){
                for (i = 0; i < ex.getNumDml(); i++) {
                 Logger.debugException('Error in Creating Enrollment Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                 }
                 System.assert(ex.getMessage().contains(System.Label.Max_Enrollment_Error_Message), True);    
            }
           
            //stop Test
            test.stopTest(); 
           
            
            
         }
     }
   /*
    @ name    CheckAndSendEmailNotificationTest
    @ date    17 Aug 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion of Enrollment it will check 
                   and send the email messages based on business logic.
     */              
     
     private static testMethod void CheckAndSendEmailNotificationTest(){
          //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
         insert usr;
         System.runAs(usr){
             CTrainingCustomSettingBuilder.buildEmailTemplateSelectionSettings();
             CTrainingCustomSettingBuilder.buildEmailAddressForSponsorOfficeSettings();
             
              Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
            
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             //Create Sponsor_Office__c 
             Sponsor_Office__c sponOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj.Id);
             sponOfficeObj.Name = 'BNL';
             insert sponOfficeObj ;
             Sponsor_Office__c sponOfficeInt = [Select Id From Sponsor_Office__c Where Id =:sponOfficeObj.Id];
             System.assert(sponOfficeInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             
             List<Class__c> clssLst = new List<Class__c>();
            //Creating the test data for Class Object. 
            Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(1, courseObj.Id, langObj.Id);
                clssObj.Max_Seats__c  = 500;
             	clssObj.RecordTypeId = ClassRecordtypeId;
                clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                clssLst.add(clssObj);
               
            insert clssLst;
            
            //Creating the test data for Account, Contact and Training Entitlement Object. 
            Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert accObj;
            
            List<Contact> conList = new List<Contact>();
            for(Integer i=0;i<=200;i++){
                Contact conObj = TestDataBuilder.buildTestContact(i, usr.Id, accObj.id);
                conList.add(conObj);
            }
            insert conList;
            
             //create test EmailTemplate records
              EmailTemplate emailTempObj = CTrainingTestDataBuilder.buildTestEmailTemplate();
              insert emailTempObj;
              EmailTemplate emailTempInt = [Select Id From EmailTemplate where Id =: emailTempObj.Id];
              System.assert(emailTempInt != null);
            system.debug('**emailTempObj**'+emailTempObj );
            
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrolmntDataLst = new List<Enrollment__c>();
            List<Enrollment__c> enrolmntDataUpdatedLst = new List<Enrollment__c>();
            for(integer i=0; i<=200; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[0].Id);
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntObj.Test_Flags_1__c = false;
                enrolmntDataLst.add(enrolmntObj);
            }
            insert enrolmntDataLst;
            test.startTest();
                
            List<Enrollment__c> enrolList = [SELECT Id, Test_Flags_1__c FROM Enrollment__c LIMIT 40]; 
            List<Enrollment__c> enrolmntUpdatLst = new List<Enrollment__c>();// = [Select Id,Test_Flags_1__c  From Enrollment__c  where Id : In enrolmntDatatLst];
                for(Enrollment__c enrolObj : enrolList){ 
                    enrolObj.Test_Flags_1__c = true;
                    enrolmntUpdatLst.add(enrolObj);
                    
                }
             Update enrolmntUpdatLst;
               
               enrolmntDataUpdatedLst = [Select Id,Test_Flags_1__c From Enrollment__c where id in :enrolmntUpdatLst];
               for(Enrollment__c enrolmntObj : enrolmntDataUpdatedLst){
                   system.assertEquals(enrolmntObj.Test_Flags_1__c,false);
               }
            test.stopTest();
         }
      }
      
    /*
    @ name    checkMaxEnrollmentOnClassforUpdateTest
    @ date    3 Sep 2015
    @ author  Abhay Verma
    @ param   none.
    @ return  Void. 
    @ description :Expected that on updating of Enrollment Status it will check 
                   if associted class has reached max seat limit or not.
    */         
    
     private static testMethod void checkMaxEnrollmentOnClassforUpdateTest(){
         
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
         insert usr;
         System.runAs(usr){
             
             Integer i;
             //Update Enrollment List
             List<Enrollment__c> updateEnrolList = new List<Enrollment__c>();
             List<Enterprise_Training_Agreement__c> eTrainAgmntLst = new List<Enterprise_Training_Agreement__c>();
             //Quering the Unlimited Recordtype Id 
             Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
             //Creating Bulk Data for Enterprise Training Agreement Object. 
             Enterprise_Training_Agreement__c etaObj = CTrainingTestDataBuilder.buildTestETAgreement(1); 
                etaObj.recordTypeId = etraAgrerecTypeId;
                //Max Seat 200.
                etaObj.Max_Seats__c = 200;
                eTrainAgmntLst.add(etaObj); 
             
             insert eTrainAgmntLst;
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
                       
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             //Create Sponsor_Office__c 
             Sponsor_Office__c sponOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj.Id);
             sponOfficeObj.Name = 'BNL';
             insert sponOfficeObj ;
             Sponsor_Office__c sponOfficeInt = [Select Id From Sponsor_Office__c Where Id =:sponOfficeObj.Id];
             System.assert(sponOfficeInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             
             List<Class__c> clssLst = new List<Class__c>();
            //Creating the test data for Class Object. 
            Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(1, courseObj.Id,langObj.Id);
                clssObj.Max_Seats__c  = 500; 
                clssObj.Additional_Seats_Taken__c = 1; 
             	clssObj.RecordTypeId = ClassRecordtypeId;
                clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                clssLst.add(clssObj);
               
            insert clssLst;
            
            //Creating the test data for Account, Contact and Training Entitlement Object. 
            Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert accObj;
            List<Contact> conList = new List<Contact>();
            for(i=0;i<=399;i++){
                Contact conObj = TestDataBuilder.buildTestContact(i, usr.Id, accObj.id);
                conList.add(conObj);
            }
            insert conList;

            
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrolmntDatatLst = new List<Enrollment__c>();
            for(i=0; i<=199; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[0].Id);
                enrolmntObj.Enterprise_Training_Agreement__c = eTrainAgmntLst[0].Id;
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntDatatLst.add(enrolmntObj);
            }
            try{
                insert enrolmntDatatLst;
            }
            catch(DmlException ex){
                 for (i = 0; i < ex.getNumDml(); i++) {
                 Logger.debugException('Error in Creating Enrollment Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                 }
            }
            //create Enrollment__c record from CTrainingTestDataBuilder.
            List<Enrollment__c> enrolmntLst = new List<Enrollment__c>();
            for(i=200; i<=399; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[0].Id);
                enrolmntObj.Enterprise_Training_Agreement__c = eTrainAgmntLst[0].Id;
                enrolmntObj.Enrollment_Status__c = 'Awaiting Payment';
                enrolmntLst.add(enrolmntObj);
            }
            try{
                //Inserting the Enrollment.
                insert enrolmntLst;
            }
            catch(DMLException ex){
                for (i = 0; i < ex.getNumDml(); i++) {
                    Logger.debugException('Error in Creating Enrollment Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                }
            }
            //start test
            test.startTest();
            //Changing the status Registered - Awaiting Payment.
            for(Enrollment__c enrolObj : enrolmntLst){
                enrolObj.Enrollment_Status__c = 'Registered - Awaiting Payment';
                updateEnrolList.add(enrolObj);
            }
            
            try{
                //Updating the Enrollment List
                update updateEnrolList;
            }
            
            catch(DMLException ex){
                for(i=0; i < ex.getNumDml(); i++){
                    Logger.debugException('Error in Creating Enrollment Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                }
                System.assert(ex.getMessage().contains(System.Label.Max_Enrollment_Error_Message), False);
            }
            //stop Test
            test.stopTest(); 
         }
     }
    
   /*
    @ name    checkDuplicateEnrollmentsTest
    @ date    23 Oct 2015
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :Expected that It will avoid duplicate enrollments for the same contact in a class
   */              
     
    private static testMethod void checkDuplicateEnrollmentsTest(){
        
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
        
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
         insert usr;
         System.runAs(usr){
           
             //Update Enrollment List
             List<Enrollment__c> updateEnrolList = new List<Enrollment__c>();
            
              Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
                       
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             //Create Sponsor_Office__c 
             Sponsor_Office__c sponOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj.Id);
             sponOfficeObj.Name = 'BNL';
             insert sponOfficeObj ;
             Sponsor_Office__c sponOfficeInt = [Select Id From Sponsor_Office__c Where Id =:sponOfficeObj.Id];
             System.assert(sponOfficeInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             
             List<Class__c> clssLst = new List<Class__c>();
             //Creating the test data for Class Object.
             for(Integer i=0; i<=10; i++){ 
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseObj.Id,langObj.Id);
                clssObj.Max_Seats__c  = 500; 
                clssObj.Additional_Seats_Taken__c = 1; 
                clssObj.RecordTypeId = ClassRecordtypeId;
                clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                clssLst.add(clssObj);
             } 
             insert clssLst;
            
            //Creating the test data for Account, Contact and Training Entitlement Object. 
            Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert accObj;
            Contact conObj = TestDataBuilder.buildTestContact(1, usr.Id, accObj.id);
            insert conObj;

            test.startTest();
             
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrolmntDatatLst = new List<Enrollment__c>();
            for(Integer i=0; i<=199; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conObj.id, clssLst[0].Id);
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntDatatLst.add(enrolmntObj);
            }
            try{
                insert enrolmntDatatLst;
            }
            catch(DmlException ex){
                 for ( Integer i = 0; i < ex.getNumDml(); i++) {
                 Logger.debugException('Error in Creating Enrollment Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                 }
                
                 System.assert(ex.getMessage().contains(Label.Do_not_allow_duplicate_enrollments_for_the_same_contact));
            }
         
            //stop Test
            test.stopTest(); 
         }
        
    }
       /*
    @ name    CheckForPreRequisiteExamTest
    @ date    22 Oct 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion of Enrollment it will check 
                   and send the email messages based on business logic.
     */              
     
     private static testMethod void CheckForPreRequisiteExamTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
         insert usr;
         System.runAs(usr){
             
             Integer i;
             //Update Enrollment List
             List<Enrollment__c> updateEnrolList = new List<Enrollment__c>();
             //List<Enterprise_Training_Agreement__c> eTrainAgmntLst = new List<Enterprise_Training_Agreement__c>();
             //Quering the Unlimited Recordtype Id 
             Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
             //Creating Bulk Data for Enterprise Training Agreement Object. 
             /*Enterprise_Training_Agreement__c etaObj = CTrainingTestDataBuilder.buildTestETAgreement(1); 
                etaObj.recordTypeId = etraAgrerecTypeId;
                //Max Seat 200.
                etaObj.Max_Seats__c = 200;
                eTrainAgmntLst.add(etaObj); 
             
             insert eTrainAgmntLst;*/
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Exam') LIMIT 1].Id;
             
             Course__c courseRec = CTrainingTestDataBuilder.buildTestCourse(0);
             courseRec.RecordTypeId = CourseRecordtypeId;
             insert courseRec;
             
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.Prerequisite__c = courseRec.Id;
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
                       
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             //Create Sponsor_Office__c 
             Sponsor_Office__c sponOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj.Id);
             sponOfficeObj.Name = 'BNL';
             insert sponOfficeObj ;
             Sponsor_Office__c sponOfficeInt = [Select Id From Sponsor_Office__c Where Id =:sponOfficeObj.Id];
             System.assert(sponOfficeInt != null);
             
             Training_Location__c trnlocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(0);
             insert trnlocObj;
             
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Exam') LIMIT 1].Id;
             List<Class__c> clssLst = new List<Class__c>();
             for(integer j = 0;j<10;j++){
                //Creating the test data for Class Object. 
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(j, courseObj.Id,langObj.Id);
                    clssObj.Max_Seats__c  = 500; 
                    clssObj.Additional_Seats_Taken__c = 1; 
                 	clssObj.RecordTypeId = ClassRecordtypeId;
                    clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                    clssObj.Training_Location__c = trnlocObj.Id;
                    clssLst.add(clssObj);
            }   
            insert clssLst;
            
            //for pre-requisite courses
             List<Class__c> clssList = new List<Class__c>();
             for( integer j = 0;j<10;j++){
                //Creating the test data for Class Object. 
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(j, courseRec.Id,langObj.Id);
                    clssObj.Max_Seats__c  = 500; 
                 	clssObj.RecordTypeId = ClassRecordtypeId;
                    clssObj.Additional_Seats_Taken__c = 1; 
                 	clssObj.Training_Location__c = trnlocObj.Id;
                    clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                    clssList.add(clssObj);
            }   
            insert clssList;
            
            //for pre-requisite courses
             List<Class__c> classLst = new List<Class__c>();
             for( integer j = 0;j<10;j++){
                //Creating the test data for Class Object. 
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(j, courseRec.Id,langObj.Id);
                    clssObj.Max_Seats__c  = 500; 
                 	clssObj.RecordTypeId = ClassRecordtypeId;
                	clssObj.Training_Location__c = trnlocObj.Id;
                    clssObj.Additional_Seats_Taken__c = 1; 
                    clssObj.Sponsor_Office__c = sponOfficeObj.Id;
                    classLst.add(clssObj);
            }   
            insert classLst;
            
            
            //Creating the test data for Account, Contact and Training Entitlement Object. 
            Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert accObj;
            
            List<Contact> conList = new List<Contact>();
            for(i=0;i<400;i++){
                Contact conObj = TestDataBuilder.buildTestContact(i, usr.Id, accObj.id);
                conList.add(conObj);
            }
            insert conList;
            List<Enrollment__c> enrollList = new List<Enrollment__c>();
            for(i=0; i<10;i++){
                Enrollment__c enrolmntRec = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssList[i].Id);
                enrolmntRec.Passed_Test_Flag__c = 'N';
                enrolmntRec.Enrollment_Status__c = 'Registered';
                enrollList.add(enrolmntRec);
            }
             insert enrollList;
             System.assertEquals(enrollList!= null,true);
        
            String enrollError= System.Label.EnrollmentPreriquisiteError;
            
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrolmntDatatLst = new List<Enrollment__c>();
            for(i=0; i<10; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[i].Id);
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntDatatLst.add(enrolmntObj);
            }
            try{
                insert enrolmntDatatLst;
            }
            catch(Exception ex){
                System.assert(ex.getMessage().contains(enrollError),true);
            }
            List<Enrollment__c> enrollmentList = new List<Enrollment__c>();
            for(i=0; i<10;i++){
                Enrollment__c enrolmntRec = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, classLst[i].Id);
                enrolmntRec.Passed_Test_Flag__c = 'Y';
                enrolmntRec.Enrollment_Status__c = 'Registered';
                enrollmentList.add(enrolmntRec);
            }
             insert enrollmentList;
             System.assertEquals(enrollList!= null,true);
             //reinsert Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrollLst = new List<Enrollment__c>();
            for(i=0; i<10; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conList[i].id, clssLst[i].Id);
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrollLst.add(enrolmntObj);
            }
               insert enrollLst ;
          
     }
     }
}