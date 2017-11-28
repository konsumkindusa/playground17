/**
 * Modified : Faina Gorelik
 * Date modified: 29 Nov 2016 AtTask #1777908 
 * description: This class contains unit tests for validating the behavior of ProjectDML, ProjectTriggerHandler classes
 * and ProjectMasterTrigger trigger.
 */
@isTest (seeAllData = false)
private with sharing class TimecardControllerTest {

	//re-create custom setting test records when running the test class
	static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

	public static string roleAppENGG='Application Engineer';

	//Get Current weekending Date
	private static Date dayOfWeek(Date dt, Integer dd){
		
		Date dtToCompare = Date.newInstance(1900, 1, dd);
		integer Days = Integer.valueOf(dt.daysBetween(dtToCompare.addDays(1)));
		return dt.addDays(6 - Math.abs(Math.mod(Days, 7)));
		
	}

	static testMethod void TestTimeCardController() {

		//Inserting Bypass trigger custom setting
		custsettbuild.buildBypassTriggerSettings();

		custsettbuild.buildTimeCardControllerList();
		custsettbuild.buildGenSetting();

		//Create User Record
		User u = TestDataBuilder.buildTestUser(1);
		u.Functional_Role__c = '';
		insert u;

		system.runAs(u) {

			Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
			acc.Name = 'Smith';
			acc.BillingCity ='Boston';
			acc.BillingCountry = 'United States';
			acc.BillingCountryCode = 'US';
			acc.BillingPostalCode ='400011';
			acc.BillingStateCode ='AK';
			acc.BillingState ='Alaska';
			acc.BillingStreet = 'MG Street';
			acc.County__c = 'abc';
			acc.Siebel_Account_Id__c = '1-CS15';
			insert acc;


			Contact cont= TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),acc.id);
			cont.MailingCity = 'Bombay';
			cont.MailingCountry = 'India';
			cont.MailingCountryCode = 'IN';
			cont.MailingPostalCode ='400011';
			cont.MailingState ='Maharashtra';
			cont.MailingStateCode = 'MH';
			cont.MailingStreet = 'MG Street';
			cont.County_Local__c = 'abc';
			cont.email ='john@gmail.com';
			cont.Siebel_Contact_Id__c = '1-1JAHOZ';
			insert cont;

			Opportunity opp = TestDataBuilder.buildTestOpportunity(0);
			opp.AccountId = acc.Id;
			insert opp;

			//Create Project Record                      
			List <MW_Project__c> projc =  new List<MW_Project__c>();
			MW_Project__c p1 = TestDataBuilder.buildTestProjectRef(1, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), u.Id);
			p1.Customer_Contact__c = cont.Id;
			p1.Opportunity__c = opp.Id;
			//Insert project created 
			projc.add(p1);
			insert projc; 

			//Create Team Member Record 
			Project_Team_Member__c pt1 = TestDataBuilder.buildTestProjectTeamMember(u.Id, p1.id);
			insert pt1;

			//Create Time Card Record
			Project_Time_Card__c ptc1 = TestDataBuilder.buildTestProjectTimeCard(u.id, p1.id);
			ptc1.Status__c = 'Submitted';
			ptc1.Activity_Type__c = 'Customer Interaction';
			ptc1.Product_Group__c = 'MATLAB';
			ptc1.Week_Ending__c = dayOfWeek(Date.today(), 6);
			ptc1.Week_date__c=Date.today();
			ptc1.Hours__c = 0;
			insert ptc1;

			Test.startTest();

			//Test current Page
			PageReference pageRef = Page.ProjectTimecard;
			Test.setCurrentPage(pageRef);

			//Create Time Card Record
			//Project_Time_Card__c ptc = new Project_Time_Card__c();
			ApexPages.StandardController stdTimeCard = new ApexPages.StandardController(ptc1);
			TimecardController tCont = new TimecardController(stdTimeCard);
			tCont.initialise();

			Project_Time_Card__c pp = (Project_Time_Card__c)stdTimeCard.getRecord();
			system.debug(pp.Week_Ending__c);

			Date curDate = Date.today();

			//Test current Date
			system.assertEquals(curDate, pp.Week_date__c);	

			tCont.GotoPrev();
			
			//Test the previous  Date
			system.assertEquals( pp.Week_date__c, curDate.addDays(-1));

			tCont.GotoNext();
			//Test if the  date was reset to the current  date
			system.assertEquals(curDate, pp.Week_date__c);	

			//Test if the weekending date was reset to the current weekending date
			tCont.changeWeekEnding();
			
			system.assertEquals(curDate, pp.Week_date__c);	



			Test.stopTest();		
		}
	}

	static testMethod void TestAddRemRow() {

		//Inserting Bypass trigger custom setting
		custsettbuild.buildBypassTriggerSettings();

		custsettbuild.buildTimeCardControllerList();
		custsettbuild.buildGenSetting();
		//Create User Record
		User u = TestDataBuilder.buildTestUser(1);
		u.Functional_Role__c = roleAppENGG;
		insert u;

		System.runAs(u) {
			Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
			acc.Name = 'Smith';
			acc.BillingCity ='Boston';
			acc.BillingCountry = 'United States';
			acc.BillingCountryCode = 'US';
			acc.BillingPostalCode ='400011';
			acc.BillingStateCode ='AK';
			acc.BillingState ='Alaska';
			acc.BillingStreet = 'MG Street';
			acc.County__c = 'abc';
			acc.Siebel_Account_Id__c = '1-CS15';
			insert acc;


			Contact cont= TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),acc.id);
			cont.MailingCity = 'Bombay';
			cont.MailingCountry = 'India';
			cont.MailingCountryCode = 'IN';
			cont.MailingPostalCode ='400011';
			cont.MailingState ='Maharashtra';
			cont.MailingStateCode = 'MH';
			cont.MailingStreet = 'MG Street';
			cont.County_Local__c = 'abc';
			cont.email ='john@gmail.com';
			cont.Siebel_Contact_Id__c = '1-1JAHOZ';
			insert cont;

			Opportunity opp = TestDataBuilder.buildTestOpportunity(0);
			opp.AccountId = acc.Id;
			insert opp;

			//Create Project Record                      
			List <MW_Project__c> projc =  new List<MW_Project__c>();
			MW_Project__c p1 = TestDataBuilder.buildTestProjectRef(1, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), u.Id);
			p1.Project_Status__c='Open';
			p1.Customer_Contact__c = cont.Id;
			p1.Opportunity__c = opp.Id;
			//Insert project created 
			projc.add(p1);
			insert projc; 

			//Create Team Member Record 
			Project_Team_Member__c pt1 = TestDataBuilder.buildTestProjectTeamMember(u.Id, p1.id);
			insert pt1;

			//Create Time Card Record
			Project_Time_Card__c ptc1 = TestDataBuilder.buildTestProjectTimeCard(u.id, p1.id);
			ptc1.Status__c = 'Submitted';
			ptc1.Activity_Type__c = 'Customer Interaction';
			ptc1.Product_Group__c = 'MATLAB';
			ptc1.Week_Ending__c = dayOfWeek(Date.today(), 6);
			ptc1.Week_date__c=Date.today();
			ptc1.Hours__c = 8;
			insert ptc1;
   
			Test.startTest();

			//Test current Page
			PageReference pageRef = Page.ProjectTimecard;
            pageRef.getParameters().put('projectId',p1.Id);	//DMA 10-31-2017 2263533 adding URL parameter for test coverage
			Test.setCurrentPage(pageRef);

			//Create Time Card Record
			ApexPages.StandardController stdTimeCard = new ApexPages.StandardController(ptc1);
			TimecardController tCont = new TimecardController(stdTimeCard);
			tCont.initialise();


			//Test Add Rows
			tCont.addRow();


			system.assertequals(3, tCont.timecardWrapperList.size());

			ApexPages.currentPage().getParameters().put('index', '1');

			//Test Remove Rows
			tCont.removingRow();
			system.assertequals(2, tCont.timecardWrapperList.size());

			//Add row to test remove of submitted row error
			tCont.addRow();

			ApexPages.currentPage().getParameters().put('index', '1');

			//Update record values
			List <TimecardController.TimecardWrapper> NewLst = new  List <TimecardController.TimecardWrapper>();
			for ( TimecardController.TimecardWrapper aa : tCont.timecardWrapperList){
				aa.timecard.Status__c = 'Submitted';
				NewLst.add(aa);
			}
			tCont.timecardWrapperList = NewLst;
			tCont.removingRow(); 

			//Test Clone
			ApexPages.currentPage().getParameters().put('CloneRow', '0');
			tCont.cloneRow();
	
			system.assertequals(3, tCont.timecardWrapperList.size());

			Test.stopTest();     
		}       
	}
        
              
	static testMethod void TestgetDependentActivityPicklist(){
		
		//Inserting Bypass trigger custom setting
		custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildTimeCardControllerList();
		custsettbuild.buildGenSetting();
		//Create User Record
		User u = TestDataBuilder.buildTestUser(1);
		u.Functional_Role__c = roleAppENGG;
		insert u;

		System.runAs(u) {

			Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
			acc.Name = 'Smith';
			acc.BillingCity ='Boston';
			acc.BillingCountry = 'United States';
			acc.BillingCountryCode = 'US';
			acc.BillingPostalCode ='400011';
			acc.BillingStateCode ='AK';
			acc.BillingState ='Alaska';
			acc.BillingStreet = 'MG Street';
			acc.County__c = 'abc';
			acc.Siebel_Account_Id__c = '1-CS15';
			insert acc;


			Contact cont= TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),acc.id);
			cont.MailingCity = 'Bombay';
			cont.MailingCountry = 'India';
			cont.MailingCountryCode = 'IN';
			cont.MailingPostalCode ='400011';
			cont.MailingState ='Maharashtra';
			cont.MailingStateCode = 'MH';
			cont.MailingStreet = 'MG Street';
			cont.County_Local__c = 'abc';
			cont.email ='john@gmail.com';
			cont.Siebel_Contact_Id__c = '1-1JAHOZ';
			insert cont;

			Opportunity opp = TestDataBuilder.buildTestOpportunity(0);
			opp.AccountId = acc.Id;
			insert opp;

			//Create Project Record                      
			List <MW_Project__c> projc =  new List<MW_Project__c>();
			MW_Project__c p1 = TestDataBuilder.buildTestProjectRef(1, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), u.Id);
			p1.Project_Status__c='Open';
			p1.Customer_Contact__c = cont.Id;
			p1.Opportunity__c = opp.Id;
			//Insert project created 
			projc.add(p1);
			insert projc; 

			//Create Team Member Record 
			Project_Team_Member__c pt1 = TestDataBuilder.buildTestProjectTeamMember(u.Id, p1.id);
			insert pt1;

			//Create Time Card Record
			Project_Time_Card__c ptc1 = TestDataBuilder.buildTestProjectTimeCard(u.id, p1.id);
			ptc1.Status__c = 'Submitted';
			ptc1.Activity_Type__c = 'Customer Interaction';
			ptc1.Product_Group__c = 'MATLAB';
			ptc1.Week_Ending__c = dayOfWeek(Date.today(), 6);
			ptc1.Week_date__c=Date.today();
			ptc1.Hours__c = 8;
			insert ptc1;

			Test.startTest();

			//Test current Page
			PageReference pageRef = Page.ProjectTimecard;
			Test.setCurrentPage(pageRef);

			//Create Time Card Record
			ApexPages.StandardController stdTimeCard = new ApexPages.StandardController(ptc1);
			TimecardController tCont = new TimecardController(stdTimeCard);
			tCont.initialise();
			//Test Add Rows
			tCont.addRow();
			system.assertequals(3, tCont.timecardWrapperList.size());
			ApexPages.currentPage().getParameters().put('rowCounter', '0');
			tCont.getDependentActivityPicklist();
			Test.stopTest();
		}
	}

	static testMethod void TestsaveEntriesError() {

		//Inserting Bypass trigger custom setting
		custsettbuild.buildBypassTriggerSettings();

		custsettbuild.buildTimeCardControllerList();
		custsettbuild.buildGenSetting();
		//Create User Record
		User u = TestDataBuilder.buildTestUser(1);
		u.Functional_Role__c = roleAppENGG;
		insert u;

		system.runAs(u) {

			Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
			acc.Name = 'Smith';
			acc.BillingCity ='Boston';
			acc.BillingCountry = 'United States';
			acc.BillingCountryCode = 'US';
			acc.BillingPostalCode ='400011';
			acc.BillingStateCode ='AK';
			acc.BillingState ='Alaska';
			acc.BillingStreet = 'MG Street';
			acc.County__c = 'abc';
			acc.Siebel_Account_Id__c = '1-CS15';
			insert acc;


			Contact cont= TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),acc.id);
			cont.MailingCity = 'Bombay';
			cont.MailingCountry = 'India';
			cont.MailingCountryCode = 'IN';
			cont.MailingPostalCode ='400011';
			cont.MailingState ='Maharashtra';
			cont.MailingStateCode = 'MH';
			cont.MailingStreet = 'MG Street';
			cont.County_Local__c = 'abc';
			cont.email ='john@gmail.com';
			cont.Siebel_Contact_Id__c = '1-1JAHOZ';
			insert cont;

			Opportunity opp = TestDataBuilder.buildTestOpportunity(0);
			opp.AccountId = acc.Id;
			insert opp;

			//Create Project Record                      
			List <MW_Project__c> projc =  new List<MW_Project__c>();
			MW_Project__c p1 = TestDataBuilder.buildTestProjectRef(1, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), u.Id);
			p1.Project_Status__c='Open';
			p1.Customer_Contact__c = cont.Id;
			p1.Opportunity__c = opp.Id;
			//Insert project created 
			projc.add(p1);
			insert projc; 

			//Create Team Member Record 
			Project_Team_Member__c pt1 = TestDataBuilder.buildTestProjectTeamMember(u.Id, p1.id);
			insert pt1;

			//Create Time Card Record
			Project_Time_Card__c ptc1 = TestDataBuilder.buildTestProjectTimeCard(u.id, p1.id);
			ptc1.Status__c = 'Submitted';
			ptc1.Activity_Type__c = 'Customer Interaction';
			ptc1.Product_Group__c = 'MATLAB';
			ptc1.Week_Ending__c = dayOfWeek(Date.today(), 6);
			ptc1.Week_date__c=Date.today();
			ptc1.Hours__c = 0;
			insert ptc1;

			Test.startTest();

			//Test current Page
			PageReference pageRef = Page.ProjectTimecard;
			Test.setCurrentPage(pageRef);

			//Create Time Card Record
			ApexPages.StandardController stdTimeCard = new ApexPages.StandardController(ptc1);
			TimecardController tCont = new TimecardController(stdTimeCard);
			tCont.initialise();
			tCont.saveEntries();

			//Test warning of cannot edit a submitted record.
			List<ApexPages.Message> msg = ApexPages.getMessages();
			for (ApexPages.Message msgs : msg)
			{
				system.assertEquals(System.Label.Warning_CannotEdit_Msg, msgs.getDetail());
			}

			Test.stopTest();	
		}
	}

	static testMethod void TestsaveEntries() {

		//Inserting Bypass trigger custom setting
		custsettbuild.buildBypassTriggerSettings();

		custsettbuild.buildTimeCardControllerList();

		custsettbuild.buildGenSetting();
		//Create User Record
		User u = TestDataBuilder.buildTestUser(1);
		u.Functional_Role__c = roleAppENGG;
		insert u;

		system.runAs(u) {
			Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
			acc.Name = 'Smith';
			acc.BillingCity ='Boston';
			acc.BillingCountry = 'United States';
			acc.BillingCountryCode = 'US';
			acc.BillingPostalCode ='400011';
			acc.BillingStateCode ='AK';
			acc.BillingState ='Alaska';
			acc.BillingStreet = 'MG Street';
			acc.County__c = 'abc';
			acc.Siebel_Account_Id__c = '1-CS15';
			insert acc;


			Contact cont= TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),acc.id);
			cont.MailingCity = 'Bombay';
			cont.MailingCountry = 'India';
			cont.MailingCountryCode = 'IN';
			cont.MailingPostalCode ='400011';
			cont.MailingState ='Maharashtra';
			cont.MailingStateCode = 'MH';
			cont.MailingStreet = 'MG Street';
			cont.County_Local__c = 'abc';
			cont.email ='john@gmail.com';
			cont.Siebel_Contact_Id__c = '1-1JAHOZ';
			insert cont;

			Opportunity opp = TestDataBuilder.buildTestOpportunity(0);
			opp.AccountId = acc.Id;
			insert opp;

			//Create Project Record                      
			List <MW_Project__c> projc =  new List<MW_Project__c>();
			MW_Project__c p1 = TestDataBuilder.buildTestProjectRef(1, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), u.Id);
			p1.Project_Status__c='Open';
			p1.Customer_Contact__c = cont.Id;
			p1.Opportunity__c = opp.Id;
			//Insert project created 
			projc.add(p1);
			insert projc; 

			//Create Team Member Record 
			Project_Team_Member__c pt1 = TestDataBuilder.buildTestProjectTeamMember(u.Id, p1.id);
			insert pt1;

			//Create Time Card Record
			Project_Time_Card__c ptc1 = TestDataBuilder.buildTestProjectTimeCard(u.id, p1.id);
			ptc1.Status__c = 'New';
			ptc1.Activity_Type__c = 'Customer Interaction';
			ptc1.Product_Group__c = 'MATLAB';
			ptc1.Week_Ending__c = dayOfWeek(Date.today(), 6);
			ptc1.Week_date__c=Date.today();
			ptc1.Hours__c = 8;
			insert ptc1;


			Test.startTest();

			//Test current Page
			PageReference pageRef = Page.ProjectTimecard;
			Test.setCurrentPage(pageRef);

			//Create Time Card Recor
			ApexPages.StandardController stdTimeCard = new ApexPages.StandardController(ptc1);
			TimecardController tCont = new TimecardController(stdTimeCard);
			tCont.initialise();

			//Test os submitting a complete detail record        
			List<ApexPages.Message> msg = ApexPages.getMessages();
			for (ApexPages.Message msgs : msg)
			{
				system.assertEquals(System.Label.Confirm_Save_Msg, msgs.getDetail());
			}

			//Test editing of none Submitted record. 
			List <TimecardController.TimecardWrapper> NewLst = new  List <TimecardController.TimecardWrapper>();
			for ( TimecardController.TimecardWrapper aa : tCont.timecardWrapperList){
				aa.isModified = True;
				aa.timecard.Hours__c = 9;
				NewLst.add(aa);
			}
			tCont.timecardWrapperList = NewLst;

			tCont.saveEntries(); 

			//Test editing of Submitted record. 
			List <TimecardController.TimecardWrapper> NewLst2 = new  List <TimecardController.TimecardWrapper>();
			for ( TimecardController.TimecardWrapper vv : tCont.timecardWrapperList){
				vv.isModified = True;
				vv.timecard.Hours__c = 0;
				NewLst2.add(vv);
			}
			tCont.timecardWrapperList = NewLst2;

			tCont.saveEntries();
			Test.stopTest();	    
		}
	}
}