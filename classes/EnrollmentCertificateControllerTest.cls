/*
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original: 16 Sep 2015, Last Modified: 16 Sep 2015
 *@description This is Test class for 'EnrollmentCertificateController' class . 
 */

@isTest
public class EnrollmentCertificateControllerTest{
    //re-create custom setting test records when running the test class
     static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    /*
      @name    testCreateLatinConverForNonLatin 
      @date    16 Sep 2015
      @author  Sagar Talele
      @param   none.
      @return  Void. 
      @description Method Implement test for enrollee name and exam date assignment.                              
     */

    static testMethod void testCreateLatinConverForNonLatin() {
        
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
            Contact conObj = TestDataBuilder.buildTestContact(1, usr.Id, accObj.id);
            insert conObj;

            
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrolmntDatatLst = new List<Enrollment__c>();
            for(i=0; i<=199; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conObj.id, clssLst[0].Id);
                enrolmntObj.Enterprise_Training_Agreement__c = eTrainAgmntLst[0].Id;
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrolmntDatatLst.add(enrolmntObj);
            }
            insert enrolmntDatatLst;
            
            EnrollmentCertificateController controller = new EnrollmentCertificateController();
            controller.enrollId = enrolmntDatatLst[0].Id;
            String enrolleeName = controller.getEnrolleeName();
             String enrolleeNameForCompletionCert = controller.getEnrolleeNameForCompletionCert();
            controller.getEnrollmentRec();
            
            //test for latin name
            Contact contactObj = TestDataBuilder.buildTestContact(2, usr.Id, accObj.id);
            contactObj.LastName = 'ÆTHER';
            insert contactObj ;
            Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(contactObj.id, clssLst[0].Id);
            insert enrolmntObj;
            
            controller.enrollId = enrolmntObj.Id;
            String latinEnrolleeName = controller.getEnrolleeName();
            controller.getEnrollmentRec();
        
           
        }
        
    }
    
      /*
      @name    testSponsorOfficeJp 
      @date    08 Jan 16
      @author  Sagar Talele
      @param   none.
      @return  Void. 
      @description Method Implement test for the sponsor office is Jp so  the certification contains the Japnese
                    context.
     */

    static testMethod void testSponsorOfficeJp() {
    
            // test the scenario where sponsor office equal to JP and
            //send the certificate which contains the Japnese context in certification
            //Inserting Bypass trigger custom setting
             custsettbuild.buildBypassTriggerSettings();
            //Create test user
             User usr = TestDataBuilder.buildTestUser(1);
             insert usr;
             
             //Creating the test data for Account, Contact and Training Entitlement Object. 
            Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
            insert accObj;
            
            //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj1 = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj1;
             
            //Create Sponsor_Office__c 
             Sponsor_Office__c sponOffObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj1.Id);
             sponOffObj.Name = 'JP';
             insert sponOffObj ;
             Sponsor_Office__c sponOffInt = [Select Id From Sponsor_Office__c Where Id =:sponOffObj.Id];
             System.assert(sponOffInt != null);
             
        	 Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj1 = CTrainingTestDataBuilder.buildTestCourse(0);
        	 courseObj1.RecordTypeId = CourseRecordtypeId;
             insert courseObj1;
             
             Course__c courseInt1 = [Select Id, Name From Course__c where id =: courseObj1.Id];
             System.assert(courseInt1 != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
        
             List<Class__c> clssList = new List<Class__c>();
            //Creating the test data for Class Object. 
            Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(1, courseObj1.Id,langObj1.Id);
                clssObj.Max_Seats__c  = 500; 
                clssObj.Additional_Seats_Taken__c = 1; 
        		clssObj.RecordTypeId = ClassRecordtypeId;
                clssObj.Sponsor_Office__c = sponOffObj.Id;
                clssList.add(clssObj);
               
            insert clssList;
            
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
             
            
            Contact conObj = TestDataBuilder.buildTestContact(1, usr.Id, accObj.id);
            insert conObj;
            
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrollList = new List<Enrollment__c>();
            for(integer i=0; i<=99; i++){
                Enrollment__c enrolmntObj = CTrainingTestDataBuilder.buildTestEnrollment(conObj.id, clssList[0].Id);
                enrolmntObj.Enterprise_Training_Agreement__c = eTrainAgmntLst[0].Id;
                enrolmntObj.Enrollment_Status__c = 'Registered';
                enrollList.add(enrolmntObj);
            }
            insert enrollList ;
            
            
            EnrollmentCertificateController controller1= new EnrollmentCertificateController();
            controller1.enrollId = enrollList[0].Id;
            String enrolleeName = controller1.getEnrolleeName();
            String enrolleeNameForCompletionCert = controller1.getEnrolleeNameForCompletionCert();
            controller1.getEnrollmentRec();
            boolean isSponsorOfficeJp = controller1.getIsSponsorOfficeJp();
            System.assertEquals(isSponsorOfficeJp,true);
            
            //Scenario 2 : when Sponsor office not equal to Jp then template content should be english
            
                    
             
             //Create Sponsor_Office__c 
             Sponsor_Office__c sponOffObj1 = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj1.Id);
             sponOffObj1.Name = 'BNL';
             insert sponOffObj1;
             Sponsor_Office__c sponOffInt1 = [Select Id From Sponsor_Office__c Where Id =:sponOffObj1.Id];
             System.assert(sponOffInt1 != null);
             
             
             
             
             List<Class__c> clssList1 = new List<Class__c>();
            //Creating the test data for Class Object. 
            Class__c clssObj1 = CTrainingTestDataBuilder.buildTestClass(1, courseObj1.Id,langObj1.Id);
                clssObj1.Max_Seats__c  = 500; 
                clssObj1.Additional_Seats_Taken__c = 1; 
        		clssObj1.RecordTypeId = ClassRecordtypeId;
                clssObj1.Sponsor_Office__c = sponOffObj1.Id;
                clssList1.add(clssObj1);
               
            insert clssList1;
            
            List<Enterprise_Training_Agreement__c> eTrainAgmntLst1 = new List<Enterprise_Training_Agreement__c>();
            
             //Creating Bulk Data for Enterprise Training Agreement Object. 
             Enterprise_Training_Agreement__c etaObj1 = CTrainingTestDataBuilder.buildTestETAgreement(1); 
                etaObj1.recordTypeId = etraAgrerecTypeId;
                //Max Seat 200.
                etaObj1.Max_Seats__c = 200;
                eTrainAgmntLst1.add(etaObj1); 
             
             insert eTrainAgmntLst1;
             
            
            
            //create Enrollment__c record from CTrainingTestDataBuilder to store the Enrollment Records.
            List<Enrollment__c> enrollList1 = new List<Enrollment__c>();
            for(integer i=0; i<=99; i++){
                Enrollment__c enrolmntObj1 = CTrainingTestDataBuilder.buildTestEnrollment(conObj.id, clssList1[0].Id);
                enrolmntObj1.Enterprise_Training_Agreement__c = eTrainAgmntLst1[0].Id;
                enrolmntObj1.Enrollment_Status__c = 'Registered';
                enrollList1.add(enrolmntObj1);
            }
            insert enrollList1 ;
            
            
            EnrollmentCertificateController controller2= new EnrollmentCertificateController();
            controller2.enrollId = enrollList1[0].Id;
            String enrolleeName1 = controller2.getEnrolleeName();
            String enrolleeNameForCompletionCert1 = controller2.getEnrolleeNameForCompletionCert();
            controller2.getEnrollmentRec();
            boolean isSponsorOfficeJp1 = controller2.getIsSponsorOfficeJp();
            System.assertEquals(isSponsorOfficeJp1,false);
        
           
        
            
    }
}