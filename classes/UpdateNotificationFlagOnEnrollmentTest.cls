/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:   9 Sep 2015, Last Modified: 
 *@description:     Test class to testing the functionality of the UpdateNotificationFlagOnEnrollment.
 */
 
@isTest
public class UpdateNotificationFlagOnEnrollmentTest{
	//re-create custom setting test records when running the test class
	static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
	/*
	@ name    noClassSelectedTest
	@ date    9 Sep 2015
	@ author  Abhay Verma
	@ param   none.
	@ return  Void. 
	@ description :Testing Method to test the UpdateNotificationFlagOnEnrollment Class. 
    */
    
    //DMA 	@testSetup method will persist data for future test methods within this class
    //		Scheduled batch apex will begin execution at Test.StopTest() but may not finish before statements immediately after Test.StopTest() (such as assertions)
    //		Placing it in this @testSetup method will ensure the batch apex finishes before this method returns
    //		Assertions can then be performed in a subsequent test method
    //		
	@testSetup static void UpdateNotificationFlagTestSetup() {    
		//Inserting Bypass trigger custom setting
		custsettbuild.buildBypassTriggerSettings();
		//Create test user
		User usr = TestDataBuilder.buildTestUser(1);
		insert usr;
        List<Enrollment__c> enrolLst = new List<Enrollment__c>();
     
		System.runAs(usr){
			//create Training_Entitlement__c record from CTrainingTestDataBuilder.
			List<Enterprise_Training_Agreement__c> eTALst = new List<Enterprise_Training_Agreement__c>();
			for(Integer i=0;i<=1;i++){
				Enterprise_Training_Agreement__c ETAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(0);
				ETAgreementObj.Max_Seats__c = 210;
				eTALst.add(ETAgreementObj);
			}
			insert eTALst;
            
			Enterprise_Training_Agreement__c  ETAgreement = [Select Id,Name From Enterprise_Training_Agreement__c WHERE id =: eTALst[0].Id];
			System.assert(ETAgreement != null);
         
			//create Course__c record from CTrainingTestDataBuilder.
			Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
			insert courseObj;
			Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
			System.assert(courseInt != null);
             
			//create Language__c record from CTrainingTestDataBuilder.
			Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
			insert langObj;
			Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
			System.assert(langInt != null);
			Id RecTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Distance Learning').getRecordTypeId();
            
			//Create Sponsor_Office__c 
			Sponsor_Office__c sponOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(0,langObj.Id);
			sponOfficeObj.Name = 'BNL';
			insert sponOfficeObj ;
			Sponsor_Office__c sponOfficeInt = [Select Id From Sponsor_Office__c Where Id =:sponOfficeObj.Id];
			System.assert(sponOfficeInt != null);
             
            
			//intialize class list to create multiple records for class.
			List<Class__c> classList = new List<Class__c>();
			for(Integer i=0;i<3;i++){
				Class__c classObj =CTrainingTestDataBuilder.buildTestClass(i,courseObj.Id,langObj.Id);
				classObj.Max_Seats__c  = 400; 
				classObj.Start_Date__c = Date.Today() + 10;
				classObj.RecordTypeId = RecTypeId;
				classObj.Sponsor_Office__c = sponOfficeObj.Id;
				classList.add(classObj);
			}
			insert classList;
			Class__c classInt = [Select Id,Name From Class__c Where Id =: classList[0].Id];
			System.assert(classInt != null);
             
			//create Account record from TestDataBuilder.
			Account accObj = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
			insert accObj;
			Account accountInt = [select Id,Name from Account where Id =: accObj.Id];
			system.assert(accountInt != null);   
             
			//create Contact record from TestDataBuilder.
			Contact contL = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accObj.id);
			insert contL;
			Contact conInt = [Select Id,Name From Contact Where Id =: contL.Id];
			system.assert(conInt != null); 
            
			Integer i;
			for(i=0;i<=199;i++){
				Enrollment__c enrolObj =  CTrainingTestDataBuilder.buildTestEnrollment(conInt.Id, classList[0].Id);
				enrolObj.Send_Email__c = True;
				enrolObj.Start_Date__c = Date.Today() + 1;
				enrolObj.Enterprise_Training_Agreement__c = eTALst[0].Id; 
				enrolObj.Enrollment_Status__c = Math.mod(i,2) == 0?'Registered - Awaiting Payment':'Awaiting Payment';
                
				if(i<50){                     
					enrolObj.Enrollment_Status__c = 'Registered';
					enrolObj.Certification_Exam_Agreement__c= 'Awaiting Response';
				}
                
				if(enrolObj.Enrollment_Status__c == 'Registered - Awaiting Payment'){
					enrolObj.Send_Registered_AP_Notification__c = False;
				}
				else if(enrolObj.Enrollment_Status__c == 'Awaiting Payment'){
					enrolObj.Send_Awaiting_Payment_Notification__c = False;
				}
				enrolLst.add(enrolObj);
			}
			insert enrolLst;
        }
		Test.startTest();
		CronTrigger cronTrigger;
		Id jobId;
		String scheduleExpression = '0 5 0 * * ?';
		jobId = System.Schedule('Test Schedule', scheduleExpression, new UpdateNotificationFlagOnEnrollment());
        Test.stopTest();
       	
        //Get the CronTrigger info
		cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
		//Verify that the expressions are the same; Scheduled Job has been added on cronTrigger
		System.assertEquals(scheduleExpression, cronTrigger.CronExpression);
    }
	@isTest static void UpdateNotificationFlagTestAssertions() { 

		//Query the Updated Enrollment Records
		List<Enrollment__c> updatedEnrolLst = [SELECT Id,Send_Registered_Notification__c,Certification_Exam_Agreement__c, Enrollment_Status__c, Send_Registered_AP_Notification__c, Send_Awaiting_Payment_Notification__c FROM Enrollment__c];                                                                                                                                                                                                                                                                                                                                         
		System.debug('___ Enrollment count= '+updatedEnrolLst.size());
        System.debug('updatedEnrolLst **&& ' +updatedEnrolLst);
                         
		for(Enrollment__c enrolObj : updatedEnrolLst){
			if(enrolObj.Enrollment_Status__c == 'Registered - Awaiting Payment'){
				//Assert if the Send_Registered_AP_Notification__c Flag is set true or not.
				System.assert(enrolObj.Send_Registered_AP_Notification__c == True);
			}
			else if(enrolObj.Enrollment_Status__c == 'Awaiting Payment'){
			//Asserting if the Send_Awaiting_Payment_Notification__c Flag is set True or not.
			System.assert(enrolObj.Send_Awaiting_Payment_Notification__c == True);
			}
			else if(enrolObj.Enrollment_Status__c == 'Registered' && enrolObj.Certification_Exam_Agreement__c== 'Awaiting Response'){
				System.assert(enrolObj.Send_Registered_Notification__c== True);
			}
		}
	}
}