/*
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar- Cloud Sherpas/Mathworks
 *date Original: 19 Aagust 2014, Last Modified: 19 Aagust 2014
 *description This  is Test class for 'OpportunityTriggerHandler' class . 
 */

@isTest
//@isTest(SeeAllData=true)
public with sharing class OpportunityTriggerHandlerTest {


    public static General_Settings__c settings;
    public static Account accObj;
    public static Contact conObj;

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    /*
      @ name   : testCalculatingUSDAmount 
      @ date   : 19 Aagust 2014,
      @ author : Archana Lohar
      @ param  : none. 
      @ return : Void. 
      @ description : Method to Implement test for cal                            
     */
    static testMethod void testCalculatingUSDAmountInsert() {

        Integer index=0;

        //intialize all variable
        List<Contact> contNLLst =new List<Contact>();
        List<Account> accNLLst =new List<Account>();
        List<Opportunity> optyLst =new List<Opportunity>();

        //re-create general Custom Setting
        csb.buildGenSetting();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();


        //Fetching date from General custom setting
        settings = General_Settings__c.getInstance();   

        //create Account record from TestDataBuilder.
        for(Integer i=0;i<2;i++){
            accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<2;i++){
            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'China';
            contNL.MailingCountryCode = 'CN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = '北京';
            contNL.MailingStateCode ='11';
            contNL.MailingStreet = '宮崎県';
            contNL.County_Local__c = 'xyz';
            //contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        system.debug(contNLLst+'contNLLstcontNLLstcontNLLstcontNLLstcontNLLst');
        insert contNLLst;

        //create Opportunity record from TestDataBuilder.
        for(Integer i=0;i<2;i++){
            Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
            opty.AccountId = accNLLst[i].id;
            opty.amount=20;
            opty.CurrencyIsoCode='INR';

            optyLst.add(opty);
        }

        test.startTest();

        insert optyLst;

        List<Opportunity> optyObjToTest = [select USD_Amount__c,USD_Exchange_Rate__c,amount
                                           from Opportunity 
                                           where id in : optyLst];

        for(Opportunity optyObj:optyObjToTest){

            System.assertEquals(optyObj.USD_Amount__c,(optyObj.amount/optyObj.USD_Exchange_Rate__c));

        }

        Test.stopTest();


    }

    /*
    @ name   : testCalculatingUSDAmount 
    @ date   : 19 Aagust 2014,
    @ author : Archana Lohar
    @ param  : none. 
    @ return : Void. 
    @ description : Method to Implement test for cal                            
     */
    static testMethod void testCalculatingUSDAmountUpdate() {

        Integer index=0;

        //intialize all variable
        List<Contact> contNLLst =new List<Contact>();
        List<Account> accNLLst =new List<Account>();
        List<Opportunity> optyLst =new List<Opportunity>();
        List<Opportunity> optyUpdateLst =new List<Opportunity>();

        //re-create gener2al Custom Setting
        csb.buildGenSetting();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();


        //Fetching date from General custom setting
        settings = General_Settings__c.getInstance();   

        //create Account record from TestDataBuilder.
        for(Integer i=0;i<20;i++){
            accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<20;i++){
            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'China';
            contNL.MailingCountryCode = 'CN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = '北京';
            contNL.MailingStateCode ='11';
            contNL.MailingStreet = '宮崎県';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;

        //create Opportunity record from TestDataBuilder.
        for(Integer i=0;i<20;i++){
            Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
            opty.AccountId = accNLLst[i].id;
            opty.amount=20;
            opty.CurrencyIsoCode='INR';

            optyLst.add(opty);
        }

        insert optyLst;

        for(Integer i=0;i<20;i++){

            Opportunity opty =optyLst[i];
            opty.amount=30;
            opty.Primary_Contact__c = contNLLst[i].Id;
            optyUpdateLst.add(opty);
        }

        test.startTest();

        update optyUpdateLst;

        List<Opportunity> optyObjToTest = [select USD_Amount__c,USD_Exchange_Rate__c,amount
                                           from Opportunity 
                                           where id in : optyUpdateLst];

        for(Opportunity optyObj:optyObjToTest){

            System.assertEquals(optyObj.USD_Amount__c,(optyObj.amount/optyObj.USD_Exchange_Rate__c));

        }

        Test.stopTest();


    }

    /*
    @ name   : testTransferOnlyOldOwnersActivities 
    @ date   : 13 Sep 2016,
    @ author : Haigang Wu
    @ param  : none. 
    @ return : Void. 
    @ description : Method to Implement test for transfer ownership for non MW integration user                            
     */
    //@isTest(SeeAllData=true)
    static void testTransferOnlyOldOwnersActivities(){
        Integer index=0;

        //intialize all variable
        List<Contact> contNLLst =new List<Contact>();
        List<Account> accNLLst =new List<Account>();
        List<Opportunity> optyLst =new List<Opportunity>();
        List<Opportunity> optyUpdateLst =new List<Opportunity>();
        List<Task> openActivityLst =new List<Task>();
        List<Event> eList = new List<Event>();
        //re-create gener2al Custom Setting
        csb.buildGenSetting();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();


        //Fetching date from General custom setting
        settings = General_Settings__c.getInstance();   

        //create Account record from TestDataBuilder.
        for(Integer i=0;i<10;i++){
            accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<10;i++){
             Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'China';
            contNL.MailingCountryCode = 'CN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = '北京';
            contNL.MailingStateCode ='11';
            contNL.MailingStreet = '宮崎県';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;

        //create Opportunity record from TestDataBuilder.
        for(Integer i=0;i<10;i++){
            Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
            opty.accountid=accNLLst[i].id;
            optyLst.add(opty);
        }

        insert optyLst;

        User newOwner = TestDataBuilder.buildTestUser(1);
        insert newOwner;

        for(Integer i=0;i<10;i++){

            Task oa = new Task();
            oa.WhatId = optyLst[i].Id;
            oa.Status = 'Not Started';
            oa.Type = 'To Do';
            oa.Subject = 'Call';
            oa.Priority = 'Medium';
            openActivityLst.add(oa);

            Event e = new Event();
            e.StartDateTime = DateTime.now() + 7;
            e.EndDateTime = DateTime.now() + 14;
            e.WhatId = optyLst[i].Id;

            eList.add(e);

        }
        insert openActivityLst;
        insert eList;

        for(Integer i=0;i<10;i++){

            Opportunity opty =optyLst[i];
            opty.ownerId = newOwner.Id;
            optyUpdateLst.add(opty);
        }

        test.startTest();

        update optyUpdateLst;

        for(Opportunity tempOpty:[select id,ownerId,(select id,ownerId,isTask from OpenActivities) from Opportunity where id in :optyLst]){
			System.Debug('Test class tempOpty: ' + tempOpty);
            for (OpenActivity tempActivity:tempOpty.OpenActivities){
				System.Debug('Test class tempActivity: ' + tempActivity);
                System.assertNotEquals(tempActivity.ownerId,tempOpty.ownerid);
            }

        }

        Test.stopTest();
    }

    /*
    @ name   : testTransferOnlyOldOwnersActivitiesIntegration 
    @ date   : 13 Sep 2016,
    @ author : Haigang Wu
    @ param  : none. 
    @ return : Void. 
    @ description : Method to Implement test for transfer ownership for MW integration user                            
     */
    //@isTest(SeeAllData=true)
    static void testTransferOnlyOldOwnersActivitiesIntegration(){
        Integer index=0;

        //intialize all variable
        List<Contact> contNLLst =new List<Contact>();
        List<Account> accNLLst =new List<Account>();
        List<Opportunity> optyLst =new List<Opportunity>();
        List<Opportunity> optyUpdateLst =new List<Opportunity>();
        List<Task> openActivityLst =new List<Task>();
        List<Event> eList = new List<Event>();
        //re-create gener2al Custom Setting
        csb.buildGenSetting();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();


        //Fetching date from General custom setting
        settings = General_Settings__c.getInstance();   

        User usr = TestDataBuilder.buildTestUser(1);
        usr.firstname = 'MW';
        usr.lastname = 'Integration';
        insert usr;

		system.runAs(usr) {
	        //create Account record from TestDataBuilder.
	        for(Integer i=0;i<10;i++){
	            accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
	            accObj.BillingCountryCode = 'US';
	            accObj.BillingCountry = 'United States';
	            accObj.BillingStateCode = 'NY';
	            accObj.BillingState = 'New York';
	
	            accNLLst.add(accObj);
	        }
	
	        insert accNLLst;
	
	        //create Contact record from TestDataBuilder.
	        for(Integer i=0;i<10;i++){
	             Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
	            contNL.MailingCity ='Ningbo';
	            contNL.MailingCountry = 'China';
	            contNL.MailingCountryCode = 'CN';
	            contNL.MailingPostalCode ='400012';
	            contNL.MailingState = '北京';
	            contNL.MailingStateCode ='11';
	            contNL.MailingStreet = '宮崎県';
	            contNL.County_Local__c = 'xyz';
	            contNL.email = 'bob@gmail.com';
	
	            contNLLst.add(contNL);
	
	        }
	
	        insert contNLLst;
	
	        //create Opportunity record from TestDataBuilder.
	        for(Integer i=0;i<10;i++){
	            Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
	            opty.accountid=accNLLst[i].id;
	            optyLst.add(opty);
	        }
	
	        insert optyLst;
	
	        User newOwner = TestDataBuilder.buildTestUser(2);
	        insert newOwner;
	
	        for(Integer i=0;i<10;i++){
	
	            Task oa = new Task();
	            oa.WhatId = optyLst[i].Id;
	            oa.Status = 'Not Started';
	            oa.Type = 'To Do';
	            oa.Subject = 'Call';
	            oa.Priority = 'Medium';
	            openActivityLst.add(oa);
	
	            Event e = new Event();
	            e.StartDateTime = DateTime.now() + 7;
	            e.EndDateTime = DateTime.now() + 14;
	            e.WhatId = optyLst[i].Id;
	
	            eList.add(e);
	
	        }
	        insert openActivityLst;
	        insert eList;
	
	        for(Integer i=0;i<10;i++){
	
	            Opportunity opty =optyLst[i];
	            opty.ownerId = newOwner.Id;
	            optyUpdateLst.add(opty);
	        }
	
	        test.startTest();
	
	        update optyUpdateLst;
	
	        for(Opportunity tempOpty:[select id,ownerId,(select id,ownerId,isTask from OpenActivities) from Opportunity where id in :optyLst]){
				System.Debug('Test class tempOpty: ' + tempOpty);
	            for (OpenActivity tempActivity:tempOpty.OpenActivities){
					System.Debug('Test class tempActivity: ' + tempActivity);
	                System.assertEquals(tempActivity.ownerId,tempOpty.ownerid);
	            }
	
	        }
	
	        Test.stopTest();
		}
    }

    /** 
     *@Author Original: kishore AN - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 28 Jan 2015     
     *@Description: Test to check the projects are assigned to the existing opportunity when the opty
     * is closed with non-win and the reason is existing opprtunity
     */
    static testMethod void assignProjectstoExistingOppTest(){
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildAddressLatinTranslation();

        List<Account> accNLLst=new List<Account>();
        List<Contact> contNLLst=new List<Contact>();
        List<Opportunity> oppLst=new List<Opportunity>();
        List<Task> taskList = new List<Task>();
        
        for(Integer i=0;i<1;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<1;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);

            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'India';
            contNL.MailingCountryCode = 'IN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = 'Gujarat';
            contNL.MailingStateCode ='GJ';
            contNL.MailingStreet = 'dgfd';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;

        //create Opportunity record from TestDataBuilder.
        for(integer i=0;i<2;i++){
            Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i);
            oppObj.AccountId = accNLLst[0].Id;
            oppObj.amount=20;
            oppObj.CurrencyIsoCode='INR';
            oppLst.add(oppObj);
        }
        insert oppLst;        

        for(integer i=0;i<2;i++){
            Task ta = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'To Do', 'Sales');
            ta.category__c = 'Sales - Qualifications';
            ta.whatId = oppLst[i].Id;
            taskList.add(ta);
        }


        insert taskList;

        

        List<MW_Project__c> recList = new List<MW_Project__c>();

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(3);
        insert usrObj;

        for(Integer i = 0; i < 1; i++){

            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
            rec.Opportunity__c = oppLst[i].id;
           // rec.Purpose__c='SMS Opp Support';
           rec.Purpose__c ='Opportunity Support';
            rec.outcome__c = 'WebEx';
            rec.requester__C=usrObj.id;
            recList.add(rec);

        }

        Test.startTest();
        insert recList;         
        System.assertEquals(1, recList.size());
        oppLst[0].StageName = 'Non-Win';
        oppLst[0].Reason__c = 'Existing Opportunity';
        oppLst[0].Existing_Opportunity__c = oppLst[1].Id;
        update oppLst[0];

        Opportunity opty = [select stagename, reason__c, existing_opportunity__c from opportunity where Id= :oppLst[0].Id];
        System.assertEquals('Non-Win', opty.StageName);

        List<Opportunity_Projects__c> optyprojRec = [select Id, opportunity__c, Duplicate_Opportunity_Association__c from Opportunity_Projects__c where Opportunity__r.Id = :oppLst[1].Id];
        //System.assertEquals(1, optyprojRec.size());

        Test.stopTest();

    }

    /** 
     *@Author Original: kishore AN - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 28 Jan 2015     
     *@Description: Test to check the opportunity project relationship is built only once when the opty
     * is non-win and the reason is existing opprtunity
     */ 
    static testMethod void assignProjectstoExistingOppOnlyOnceTest(){
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildAddressLatinTranslation();

        List<Account> accNLLst=new List<Account>();
        List<Contact> contNLLst=new List<Contact>();
        List<Opportunity> oppLst=new List<Opportunity>();
        List<Task> taskList = new List<Task>();
        
        for(Integer i=0;i<1;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<1;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);

            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'India';
            contNL.MailingCountryCode = 'IN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = 'Gujarat';
            contNL.MailingStateCode ='GJ';
            contNL.MailingStreet = 'dgfd';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;

        //create Opportunity record from TestDataBuilder.
        for(integer i=0;i<2;i++){
            Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i);
            oppObj.AccountId = accNLLst[0].Id;
            oppObj.amount=20;
            oppObj.CurrencyIsoCode='INR';
            oppLst.add(oppObj);
        }
        insert oppLst;        

        for(integer i=0;i<2;i++){
            Task ta = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'To Do', 'Sales');
            ta.category__c = 'Sales - Qualifications';
            ta.whatId = oppLst[i].Id;
            taskList.add(ta);
        }


        insert taskList;

        

        List<MW_Project__c> recList = new List<MW_Project__c>();

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(3);
        insert usrObj;

        for(Integer i = 0; i < 1; i++){

            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
            rec.Opportunity__c = oppLst[i].id;
           // rec.Purpose__c='SMS Opp Support';
            rec.Purpose__c ='Opportunity Support';
            rec.outcome__c = 'WebEx';
            rec.requester__C=usrObj.id;
            recList.add(rec);

        }

        Test.startTest();
        insert recList;         
        System.assertEquals(1, recList.size());
        Opportunity_Projects__c optyProj = new Opportunity_Projects__c();
        optyProj.project__c = recList[0].Id;
        optyProj.Opportunity__c = oppLst[1].Id;
        optyProj.CurrencyIsoCode = recList[0].CurrencyIsoCode;

        insert optyProj;

        oppLst[0].StageName = 'Non-Win';
        oppLst[0].Reason__c = 'Existing Opportunity';
        oppLst[0].Existing_Opportunity__c = oppLst[1].Id;
        update oppLst[0];

        Opportunity opty = [select stagename, reason__c, existing_opportunity__c from opportunity where Id= :oppLst[0].Id];
        System.assertEquals('Non-Win', opty.StageName);

        List<Opportunity_Projects__c> optyprojRec = [select Id, opportunity__c, Duplicate_Opportunity_Association__c from Opportunity_Projects__c where Opportunity__r.Id = :oppLst[1].Id];
        System.assertEquals(1, optyprojRec.size());

        Test.stopTest();

    }

    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified:4 Feb 2015 
     *@Date Original:4 Feb 2015     
     *@Description: Test to check the  primary opportunitycontacRole has been added to Oppotunity.
     */ 
    static testMethod void addPrimaryContactRoleToOptyTest(){

        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildAddressLatinTranslation();

        List<Account> accNLLst=new List<Account>();
        List<Contact> contNLLst=new List<Contact>();
        List<Opportunity> oppLst=new List<Opportunity>();
        List<Opportunity> oppLstToUpdate=new List<Opportunity>();
        List<OpportunityContactRole> oppConLst=new List<OpportunityContactRole>();


        for(Integer i=0;i<10;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<10;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);

            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'India';
            contNL.MailingCountryCode = 'IN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = 'Gujarat';
            contNL.MailingStateCode ='GJ';
            contNL.MailingStreet = 'dgfd';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gyx.zxe';

            contNLLst.add(contNL);

        }

        insert contNLLst;

        Test.startTest();

        //create Opportunity record from TestDataBuilder.
        for(integer i=0;i<10;i++){
            Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i); 
            oppObj.Accountid=accNLLst[i].id;
            oppObj.Primary_Contact__c=contNLLst[i].id;
            oppLst.add(oppObj);
        }
        insert oppLst;


        //Query OpportunityContactRole
        List<Opportunity> optyObjLstInsert=[Select id,
                                      Primary_Contact__c,
                                      (select id,contactid from OpportunityContactRoles where isprimary=true)
                                      From Opportunity where id in:oppLst];

        For(Opportunity opObj:optyObjLstInsert){

            System.assertEquals(opObj.Primary_Contact__c,opObj.OpportunityContactRoles[0].contactid);
        }


        for(integer i=0;i<10;i++){

            OpportunityContactRole roleObj=TestDataBuilder.builOpportunityContactRole(contNLLst[i].id,oppLst[i].id);    
            roleObj.isPrimary=true;
            oppConLst.add(roleObj);
        }
        insert oppConLst;

        //update Opportunity record from TestDataBuilder. 
        Integer j=9;
        for(integer i=0;i<10;i++){
            Opportunity oppObj=oppLst[i];   
            oppObj.Primary_Contact__c=contNLLst[j].id;
            oppLstToUpdate.add(oppObj);
            j--;
        }
        update oppLstToUpdate;

        //Query OpportunityContactRole
        List<Opportunity> optyObjLst=[Select id,
                                      Primary_Contact__c,
                                      (select id,contactid from OpportunityContactRoles where isprimary=true)
                                      From Opportunity where id in:oppLstToUpdate];

        For(Opportunity opObj:optyObjLst){

            System.assertEquals(opObj.Primary_Contact__c,opObj.OpportunityContactRoles[0].contactid);
        }

        Test.stopTest();

    }
      /*
      @ name   : testOpportunityReasonStageUpdate 
      @ date   : 03 March 2016,
      @ author : Neha Mahajan
      @ param  : none. 
      @ return : Void. 
      @ description : Method to Implement test for opportunity                            
     */
    static testMethod void testOpportunityReasonStageUpdate() {
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        //initialize all variables
        List<Account> accNLLst =new List<Account>();
        List<Opportunity> optyLst =new List<Opportunity>();
        List<Opportunity> optyUpdateLst =new List<Opportunity>();   
        List<OpportunityCompetitor> optyCompetitorUpdateLst =new List<OpportunityCompetitor>();
        for(Integer i=0;i<200;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accNLLst.add(accObj);
        }

        insert accNLLst;
    
        //create Opportunity record from TestDataBuilder.
        for(integer i=0;i<200;i++){
            Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i);
            oppObj.AccountId = accNLLst[0].Id;
            oppObj.Probability=42;
            oppObj.CurrencyIsoCode='INR';
            oppObj.StageName  = 'E - Suspect';
            optyLst.add(oppObj);
        }
        insert optyLst;      
        
        for(Integer i=0;i<200;i++){

            Opportunity opty =optyLst[i];
            opty.Reason__c='Competition';
            opty.StageName='Non-Win';
            optyUpdateLst.add(opty);
        }
        
        
        
        for(Integer i=0;i<10;i++){

            OpportunityCompetitor optyCompetitor =TestDataBuilder.buildTestOpportunityCompetitor(i,optyLst[0].id);
           
            optyCompetitorUpdateLst.add(optyCompetitor);
        }
               
        insert optyCompetitorUpdateLst;
        
        test.startTest();
        try{        
        update optyUpdateLst;
        
        System.assertEquals(200, optyUpdateLst.size());
        Opportunity optyRec = [select stagename, reason__c from opportunity where Id= :optyLst[0].Id];
        
        System.assertEquals('Non-Win', optyRec.StageName);
        System.assertEquals('Competition', optyRec.Reason__c);
        }
        catch(Exception e){     
        System.assertEquals(e.getMessage().contains(Label.Competitor_Required),true);
        }
        Test.stopTest();
    
    }
    
    /*
      @ name   : assignTerritoryTeamRoleToOptyOwnerInsertTest
      @ date   : 08 June 2016,
      @ author : Abhay Verma
      @ param  : none. 
      @ return : Void. 
      @ description : Method to Implement test for assignTerritoryTeamRoleToOptyOwner Method
     */
    static testMethod void assignTerritoryTeamRoleToOptyOwnerInsertTest() {
            
           csb.buildBypassTriggerSettings();
           csb.buildGenSetting();

           
           //Create test users.
           List<User> usrList = new List<User>();
           for(Integer i=0;i<50;i++){
               User usr = TestDataBuilder.buildTestUser(i);
               usr.Functional_Role__c = 'Func Role'+i;
               usrList.add(usr);
           }
           insert usrList;
        
        System.runAs(usrList[0]){
            //Creating Territory in Bulk.
            List<Territory2> territory2Lst =new List<Territory2>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            List<Territory2> territory2LstTest =new List<Territory2>();
            Territory2Model model;

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }

            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<200;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);         
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.name='TestTerritory';
                dummyTerritory2.DeveloperName='AMER'+i;
                dummyTerritory2.Global_Region__c='International';
                dummyTerritory2.Region__c='omer';
                dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office_Channel__c='Indirect';
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                //dummyTerritory2.is_Active__c = true;// fg


                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){

                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;

                territory2Lst.add(dummyTerritory2);
            }
            //Insert territory list
            insert territory2Lst;
            
            List<Territory2> territoryLst = [SELECT Id FROM Territory2 WHERE Id IN:territory2Lst];
            System.assertEquals(territoryLst.size(), 200);
            
            List<UserTerritory2Association> UserTerritoryAssociationLst = new List<UserTerritory2Association>();
            //Create territory2Association Object record
            for(Integer i=0;i<200;i++){
                UserTerritory2Association usrTerritoryAssociationObj;
                if(i<50){
                    usrTerritoryAssociationObj = TestDataBuilder.buildTestUserterritory2Association(usrList[i].Id, territory2Lst[i].Id);
                }
                else if(i>=50 && i<100){
                    usrTerritoryAssociationObj = TestDataBuilder.buildTestUserterritory2Association(usrList[i-50].Id, territory2Lst[i].Id);
                }
                else if(i>=100 && i<150){
                    usrTerritoryAssociationObj = TestDataBuilder.buildTestUserterritory2Association(usrList[i-100].Id, territory2Lst[i].Id);
                }
                else if(i>=150 && i<200){
                    usrTerritoryAssociationObj = TestDataBuilder.buildTestUserterritory2Association(usrList[i-150].Id, territory2Lst[i].Id);
                }
                if(i>=50){
                    usrTerritoryAssociationObj.RoleInTerritory2 = 'Territory Role'+i;
                }
                //Adding usrTerritoryAssociationRecord 
                UserTerritoryAssociationLst.add(usrTerritoryAssociationObj);
            }
            //Inserting UserTerritory2Association List
            insert UserTerritoryAssociationLst;
            List<UserTerritory2Association> usrTerr2AssocList = [SELECT Id FROM UserTerritory2Association WHERE Id IN: UserTerritoryAssociationLst];
            System.assertEquals(usrTerr2AssocList.size(), 200); 
            
            //Creating Account Test Data
            List<Account> accList =new List<Account>();
            for(Integer i=0;i<200;i++){
                Account accnObj;
                //Assign 50 User to 200 Account.
                if(i<50){
                    accnObj = TestDataBuilder.buildTestAccount(i,usrList[i].Id);
                }
                else if(i>=50 && i<100){
                    accnObj = TestDataBuilder.buildTestAccount(i,usrList[i-50].Id);
                }
                else if(i>=100 && i<150){
                    accnObj = TestDataBuilder.buildTestAccount(i,usrList[i-100].Id);
                }
                else if(i>=150 && i<200){
                    accnObj = TestDataBuilder.buildTestAccount(i,usrList[i-150].Id);
                }
                accnObj.Siebel_Territory_ID__c = territory2Lst[i].Siebel_Territory_ID__c;
                accList.add(accnObj);    
            }
            //Insert Account List
            insert accList;
            List<Account> accnList = [SELECT Id FROM Account];
            System.assertEquals(accnList.size(), 200);
            
            //Start Test
            test.startTest();
            //Creating Opportunity test data.
            List<Opportunity> optyLst =new List<Opportunity>();
            for(Integer i=0;i<200;i++){
                Opportunity oppObj = TestDataBuilder.buildTestOpportunity(i);
                oppObj.StageName = 'Win';
                oppObj.AccountId = accList[i].Id;
                if(i<50){
                    oppObj.ownerId = usrList[i].Id;
                }
                else if(i>=50 && i<100){
                    oppObj.ownerId = usrList[i-50].Id;
                }
                else if(i>=100 && i<150){
                    oppObj.ownerId = usrList[i-100].Id;
                }
                else if(i>=150 && i<200){
                    oppObj.ownerId = usrList[i-150].Id;
                }
                optyLst.add(oppObj);
            }
            //Insert opportunity List
            insert optyLst;    
            List<Opportunity> insertedOppList = [SELECT Territory_Team_Role__c FROM Opportunity];
            
            for(Integer i=0;i<200;i++){
                if(UserTerritoryAssociationLst[i].RoleInTerritory2 != null){
                    //Asserting the opportunity team role is updated with the user
                    System.assertEquals(insertedOppList[i].Territory_Team_Role__c, UserTerritoryAssociationLst[i].RoleInTerritory2);
                }
                else{
                    //Asserting the opportunity team role is updated with the user
                    System.assertEquals(insertedOppList[i].Territory_Team_Role__c, usrList[i].Functional_Role__c);
                }
            }
            //Stop Test
            test.stopTest();
        }//End of RunAs
    }//End of Method
    
    /*
      @ name   : assignTerritoryTeamRoleToOptyOwnerUpdateTest
      @ date   : 08 June 2016,
      @ author : Abhay Verma
      @ param  : none. 
      @ return : Void. 
      @ description : Method to Implement test for assignTerritoryTeamRoleToOptyOwner Method
     */
    static testMethod void assignTerritoryTeamRoleToOptyOwnerUpdateTest() {
            
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();

        
        //Create test users.
        List<User> usrList = new List<User>();
        for(Integer i=0;i<50;i++){
           User usr = TestDataBuilder.buildTestUser(i);
           usr.Functional_Role__c = 'Func Role'+i;
           usrList.add(usr);
        }
        insert usrList;
        
        System.runAs(usrList[0]){
            //Creating Territory in Bulk.
            List<Territory2> territory2Lst =new List<Territory2>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            List<Territory2> territory2LstTest =new List<Territory2>();
            Territory2Model model;

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }

            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<20;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);         
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.name='TestTerritory';
                dummyTerritory2.DeveloperName='AMER'+i;
                dummyTerritory2.Global_Region__c='International';
                dummyTerritory2.Region__c='omer';
                dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office_Channel__c='Indirect';
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                //dummyTerritory2.is_Active__c = true;// fg


                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){

                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;

                territory2Lst.add(dummyTerritory2);
            }
            //Insert territory list
            insert territory2Lst;
            List<Territory2> territoryLst = [SELECT Id FROM Territory2 WHERE Id IN:territory2Lst];
            System.assertEquals(territoryLst.size(), 20);
            
            List<UserTerritory2Association> UserTerritoryAssociationLst = new List<UserTerritory2Association>();
            //Create territory2Association Object record
            for(Integer i=0;i<20;i++){
                UserTerritory2Association usrTerritoryAssociationObj;
                usrTerritoryAssociationObj = TestDataBuilder.buildTestUserterritory2Association(usrList[i].Id, territory2Lst[i].Id);
                if(i>=15){
                    usrTerritoryAssociationObj.RoleInTerritory2 = 'Territory Role'+i;
                }
                //Adding usrTerritoryAssociationRecord 
                UserTerritoryAssociationLst.add(usrTerritoryAssociationObj);
            }
            //Inserting UserTerritory2Association List
            insert UserTerritoryAssociationLst;
            List<UserTerritory2Association> usrTerr2AssocList = [SELECT Id FROM UserTerritory2Association WHERE Id IN: UserTerritoryAssociationLst];
            System.assertEquals(usrTerr2AssocList.size(), 20);         
            
            //Creating Account Test Data
            List<Account> accList =new List<Account>();
            for(Integer i=0;i<20;i++){
                Account accnObj;
                accnObj = TestDataBuilder.buildTestAccount(i,usrList[i].Id);
                accnObj.Siebel_Territory_ID__c = territory2Lst[i].Siebel_Territory_ID__c;
                accList.add(accnObj);    
            }
            //Insert Account List
            insert accList;
            List<Account> accnList = [SELECT Id FROM Account];
            System.assertEquals(accnList.size(), 20);
            
            //Start Test
            test.startTest();
            //Creating Opportunity test data.
            List<Opportunity> optyLst =new List<Opportunity>();
            for(Integer i=0;i<20;i++){
                Opportunity oppObj = TestDataBuilder.buildTestOpportunity(i);
                oppObj.AccountId = accList[i].Id;
                oppObj.ownerId = userinfo.getuserid();
                optyLst.add(oppObj);
            }
            insert optyLst;    
            List<Opportunity> insertedOppList = [SELECT Territory_Team_Role__c FROM Opportunity WHERE Id IN: optyLst];

            System.assertEquals(insertedOppList.size(), 20);
            
            //Updating the owner of the opportunity.
            List<Opportunity> updateOppList = new List<Opportunity>();
            Integer j=0;
            for(Opportunity oppObj : insertedOppList){

                oppObj.ownerId = usrList[j].Id;
                j++;
                updateOppList.add(oppObj);
            }
            //update opportunity
            update updateOppList;
            List<Opportunity> finalOppList = [SELECT Territory_Team_Role__c FROM Opportunity WHERE Id IN: updateOppList];
            
            for(Integer i=0;i<20;i++){
                if(UserTerritoryAssociationLst[i].RoleInTerritory2 != null){
                    //Asserting the opportunity team role is updated with the user
                    System.assertEquals(finalOppList[i].Territory_Team_Role__c, UserTerritoryAssociationLst[i].RoleInTerritory2);
                }
                else{
                    //Asserting the opportunity team role is updated with the user
                    System.assertEquals(finalOppList[i].Territory_Team_Role__c, usrList[i].Functional_Role__c);
                }
            }
            //Stop Test
            test.stopTest();
            
        }//End of RunAs
    }//End of Method
    
}