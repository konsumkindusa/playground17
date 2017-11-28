/**
 **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Eric Schoenfeld - Cloud Sherpas/Mathworks , Faina Gorelik - MathWorks
 **@date Original: 05 June 2013, Last Modified: 10/15/2014, 10 July 2016
 **@description test class for testing all functionality on CaseDML class
 */
@isTest
private class CaseDMLTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 05 June 2013, Last Modified: 22 October 2013
     **@description test method for testing updating of On Support fields with On Support integration returning a successful response on Insert
     */
    static testMethod void testCheckOnSupportSuccessResponseonInsert() {

        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        Case InsCse = new Case(); 

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       // fg REST API returns CDS Account Id
       	acc.CDS_Account_Id__c = 'B0876123';
        insert acc;
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.Product_Base_Code__c = 'MB';
        cse.License__c = '987123';
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupport');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        insert cse;
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
            //Verify that a Case has been inserted
            system.assertEquals(InsCse.Id, cse.Id, True);
            Test.stopTest();
        //Assertions can not be made for verifying On Support fields because of asynchronous call (CheckOnSupport)

    }
    
    static testMethod void testCheckOnSupportLicenseEligibleProductNotEligible(){
      /*  
     **@author Original: Faina Gorelik - Mathworks
     **@date Original: 14 July 2016, Last Modified: 
     **@description test method for testing insterting of On Support fields with License Eligible Product Not Eligible
	*/ 
        
	
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        Case InsCse = new Case(); 
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       	acc.CDS_Account_Id__c = 'B0876123';
        insert acc;

        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.Product_Base_Code__c = 'MB';
        cse.License__c = '9087123';
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        string EndPoint = 'https://sf-ext-dev3.mathworks.com/';
        multimockgetOnSupport.setStaticResource('MockResponseProductNotEligible');////MockResponseOnSupport;mockResponseTestLicense
        multimockgetOnSupport.setStatusCode(404);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        insert cse;
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
            system.assertEquals(InsCse.Id, cse.Id, true);
            Test.stopTest();        
    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 05 June 2013, Last Modified: 22 October 2013
     **@description test method for testing updating of On Support fields with On Support integration returning an error response on Insert
     */
    static testMethod void testCheckOnSupportErrorResponseonInsert() { 

    
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        Case InsCse = new Case(); 
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       	acc.CDS_Account_Id__c = 'B0876123';
        insert acc;

        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.Product_Base_Code__c = 'MB';
        cse.License__c = '9087123';
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        string EndPoint = 'https://sf-ext-dev3.mathworks.com/';
        multimockgetOnSupport.setStaticResource('MockResponseOnSupport');////MockResponseOnSupport;mockResponseTestLicense
        multimockgetOnSupport.setStatusCode(404);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        insert cse;
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
            system.assertEquals(InsCse.Id, cse.Id, true);
            Test.stopTest();
    }
    static testMethod void testCheckOnSupportSuccessResponseLicenseNotEligibleNoProductSelected(){
    /*  
     **@author Original: Faina Gorelik - Mathworks
     **@date Original: 14 July 2016, Last Modified: 
     **@description test method for testing updating of On Support fields with On Support integration returning success No Product Entered
	*/
        
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        Case InsCse = new Case(); 

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       // fg REST API returns CDS Account Id
       	acc.CDS_Account_Id__c = 'B0876123';
        insert acc;
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '987123';
        
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseLicenseNotEligibleProductNotSelected');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        insert cse;
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
            //Verify that a Case has been inserted
            system.assertEquals(InsCse.Id, cse.Id, True);
            Test.stopTest(); 
        
        
    }
    
    static testMethod void testCheckOnSupportSuccessResponseLicenseEligibleNoProductSelected(){
    /*  
     **@author Original: Faina Gorelik - Mathworks
     **@date Original: 14 July 2016, Last Modified: 
     **@description test method for testing updating of On Support fields with On Support integration returning success No Product Entered
	*/
        
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        Case InsCse = new Case(); 

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       // fg REST API returns CDS Account Id 
       //	acc.CDS_Account_Id__c = 'B0876123';
       // insert acc;
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '987123';
        
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponsLicenseEligibleNoProduct');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        insert cse;
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
            //Verify that a Case has been inserted
            system.assertEquals(InsCse.Id, cse.Id, True);
            Test.stopTest(); 
    } 
    
    static testMethod void testCheckOnSupportSuccesResponseLicenseNotEligible(){    
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        Case InsCse = new Case(); 
              
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.Product_Base_Code__c = 'MB';
        cse.License__c = '9087123';
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        string EndPoint = 'https://sf-ext-dev3.mathworks.com/';
        multimockgetOnSupport.setStaticResource('MockResponseLicenseNotEligible');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        insert cse;
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c,License_Account_Lookup__c From Case Where Id = : cse.Id];
            system.assertEquals(InsCse.Id, cse.Id, true);
            Test.stopTest();
    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Modified: Faina Gorelik - MathWorks
     **@date Original: 05 June 2013, Last Modified: 22 October 2013, 14 July 2016
     **@description test method for testing updating of On Support fields with On Support integration returning a succesfful REST API response on Update
     */
    static testMethod void testCheckOnSupportSuccessResponseonUpdate() {

       //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        
        Case InsCse = new Case();// inserted case
        Case UpCse = new Case();// updated case
        
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        insert cse;
        
       // create test account //07/14/16
      	Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       	acc.CDS_Account_Id__c = 'B0876123';
        Test.startTest();
      	insert acc;   
		Account onsuppAccount = new Account(); 
        onsuppAccount = [Select id from Account where CDS_Account_Id__c = 'B0876123'];
    
        //Retrieve inserted case
       	InsCse = [Select Id, Account.Name, License__c, Product_Base_Code__c, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];

        //Update Case
       	cse.Product_Base_Code__c = 'MB';
        cse.License__c = '987123';
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupport');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
		//Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        update cse;
        //Retrieve updated case 
        UpCse = [Select Id, Account.Name, License__c, Product_Base_Code__c, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
	
      
        
        //Verify that a Case has been updated
        system.assertNotEquals(InsCse.License__c,UpCse.License__c);
        system.assertNotEquals(InsCse.Product_Base_Code__c,UpCse.Product_Base_Code__c);
        system.assertNotEquals(onsuppAccount, null);
        system.assertEquals(InsCse.License_Account__c, null);
        Test.stopTest();


    }
    
      /**
     **@author Original: Shweta Shanbhag - MathWorks
     **@date Original: 25 August 2016, Last Modified: 25 August 2016
     **@description test method for testing updating of On Support fields with On Support integration returning a succesfful REST API response on Update of product from product lookup
     */
    static testMethod void testCheckOnSupportProdlookupUpdate() {

 
        csb.buildIntegrationSetting();
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        
        Case InsCse = new Case();
        Case UpCse = new Case();
        
        Product2 newProduct1 =  new Product2();
        Product2 newProduct2 =  new Product2();

        newProduct1 = TestDataBuilder.buildTestProduct(1);
        newProduct1.ProductCode = 'AE';
        insert newProduct1;

        newProduct2 = TestDataBuilder.buildTestProduct(2);
        newProduct2.ProductCode = 'MB';
        insert newProduct2;
        
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '987123';
        cse.Product_Lookup__c = newProduct1.id;
        insert cse;
        
      
      	Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
       	acc.CDS_Account_Id__c = 'B0876123';
        Test.startTest();
      	insert acc;   
		Account onsuppAccount = new Account(); 
        onsuppAccount = [Select id from Account where CDS_Account_Id__c = 'B0876123'];
    
        //Retrieve inserted case
       	InsCse = [Select Id, Account.Name, License__c, Product_Base_Code__c, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];

        //Update Case
       	cse.Product_Lookup__c = newProduct2.id;
        
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupport');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
		//Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
        update cse;
        //Retrieve updated case 
        UpCse = [Select Id, Account.Name, License__c, Product_Base_Code__c, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case Where Id = : cse.Id];
 
        //Verify that a Case has been updated
        system.assertNotEquals(InsCse.Product_Base_Code__c,UpCse.Product_Base_Code__c);
        system.assertNotEquals(onsuppAccount, null);
        system.assertEquals(InsCse.License_Account__c, null);
        Test.stopTest();


    }


    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 26 June2013, Last Modified: 22 October 2013
     **@description test method for testing updating of Area field on Case with Case Owner's Area field value
     */
    static testMethod void testUpdateCaseArea() {

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        stdUser.Area__c = 'UK - Technical Support';
        insert stdUser;

        //Run as MW standard User
        system.runAs(stdUser){
            list <Case> caselist = new list<Case>();
            list <Case> inscaselist = new list <Case>();
            for (Integer i=0;i<30;i++){
                Case cse = TestDataBuilder.buildTestCase('Open');
                caselist.add(cse);
            }

            Test.startTest();
            insert caselist;

            //Retrieve created Case records
            inscaselist = [Select Area__c From Case Where Id in : caselist];

            Test.stopTest();

            for (Integer i=0; i<30; i++){
                //Verify that Case Owner's Area has been set to Case's Area
                system.assertEquals(inscaselist[i].Area__c,'UK - Technical Support');
            }
        }

    }





    /**
     **@author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
     **@date Original: 27 June 2013, Last Modified: 22 October 2013
     **@description test method to test auto-population of Product Base Code of case upon insert.
     */
    static testMethod void CheckProductBaseCodeIsUpdatedOnInsert() {
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 

        Test.startTest();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        Product2 newProduct =  new Product2();

        newProduct = TestDataBuilder.buildTestProduct(1);
        newProduct.ProductCode = 'AE';
        insert newProduct;


        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = newProduct.id;

        system.assertEquals(cse.Product_Base_Code__c, null, True);
        insert cse;

        //Retrieve inserted case 
        InsCse = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : cse.Id];

        Test.stopTest();

        //Verify that a Case has been inserted
        system.assertEquals(InsCse.Id, cse.Id, True);
        //Verify that a Case Product Base Code is equal to the Product Code of new Product
        system.assert(InsCse.Product_Base_Code__c == 'AE');


    }

    /**
     **@author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
     **@date Original: 27 June 2013, Last Modified: 22 October 2013
     **@description test method test auto population of of Product Base Code upon update. Case Product_Lookup__c field value is null and update without change on Product_Lookup__c.
     */

    static testMethod void CheckProductBaseCodeIsUpdatedOnUpdate0() {
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 
        Case UpdatedCase = new Case(); 

        Test.startTest();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        Product2 newProduct1 =  new Product2();


        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = null;

        system.assertEquals(cse.Product_Base_Code__c, null, True);
        insert cse;

        //Retrieve inserted case 
        InsCse = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : cse.Id];


        //Verify that a Case Product Base Code is null sunce there is no Product look up value.
        system.assertEquals(InsCse.Product_Base_Code__c, null, True);


        Update InsCse;

        UpdatedCase = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : InsCse.Id];

        Test.stopTest();

        //Verify that a Case has been inserted
        system.assertEquals(UpdatedCase.Id, InsCse.Id, True);
        //Verify that a Case Product Base Code is null sunce there is no Product look up value.
        system.assertEquals(UpdatedCase.Product_Base_Code__c, null, True);


    }

    /**
     **@author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
     **@date Original: 27 June 2013, Last Modified: 22 October 2013
     **@description test method test auto population of of Product Base Code upon update. Case Product_Lookup__c field value is change to another product.
     */
    static testMethod void CheckProductBaseCodeIsUpdatedOnUpdate1() {
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();

        Test.startTest();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        Product2 newProduct1 =  new Product2();
        Product2 newProduct2 =  new Product2();

        newProduct1 = TestDataBuilder.buildTestProduct(1);
        newProduct1.ProductCode = 'AE';
        insert newProduct1;

        newProduct2 = TestDataBuilder.buildTestProduct(2);
        newProduct2.ProductCode = 'BI';
        insert newProduct2;


        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = newProduct1.id;

        system.assertEquals(cse.Product_Base_Code__c, null, True);
        insert cse;

        //Retrieve inserted case 
        InsCse = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : cse.Id];


        InsCse.Product_Lookup__c =  newProduct2.id;
        //Verify that a Case Product Base Code is equal to the Product Code of newProduct1 ('AE').
        system.assert(InsCse.Product_Base_Code__c == 'AE');

        Update InsCse;

        UpdatedCase = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : InsCse.Id];

        Test.stopTest();

        //Verify that a Case has been inserted
        system.assertEquals(UpdatedCase.Id, InsCse.Id, True);
        //Verify that a Case Product Base Code is equal to the Product Code of the new product (newProduct2), 'BI'.
        system.assert(UpdatedCase.Product_Base_Code__c == 'BI');

    }

    /**
     **@author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 27 June 2013, Last Modified: 22 October 2013
     **@description test method test auto population of of Product Base Code upon update. Case Product_Lookup__c having a value changed to null
     */
    static testMethod void CheckProductBaseCodeIsUpdatedOnUpdate2() {
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();

        Test.startTest();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        Product2 newProduct1 =  new Product2();
        Product2 newProduct2 =  new Product2();

        newProduct1 = TestDataBuilder.buildTestProduct(1);
        newProduct1.ProductCode = 'AE';
        insert newProduct1;

        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = newProduct1.id;

        system.assertEquals(cse.Product_Base_Code__c, null, True);
        insert cse;

        //Retrieve inserted case 
        InsCse = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : cse.Id];
        //Remove product look up value.
        InsCse.Product_Lookup__c =  null;

        //Verify that a Case Product Base Code is equal to the Product Code of newProduct1 ('AE').
        system.assert(InsCse.Product_Base_Code__c == 'AE');

        Update InsCse;

        UpdatedCase = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : InsCse.Id];

        Test.stopTest();

        //Verify that a Case has been inserted
        system.assertEquals(UpdatedCase.Id, InsCse.Id, True);
        //Verify that a Case Product Base Code is null sunce there is no Product look up value.
        system.assertEquals(UpdatedCase.Product_Base_Code__c, null, True);
    }

    /**
     **@author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 27 June 2013, Last Modified: 22 October 2013
     **@description test method to test auto population of of Product Base Code upon update. Case Product_Lookup__c having no value changed to a product id.
     */
    static testMethod void CheckProductBaseCodeIsUpdatedOnUpdate3() {
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();

        Test.startTest();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        Product2 newProduct1 =  new Product2();

        newProduct1 = TestDataBuilder.buildTestProduct(1);
        newProduct1.ProductCode = 'AE';
        insert newProduct1;

        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = null;

        system.assertEquals(cse.Product_Base_Code__c, null, True);
        insert cse;

        //Retrieve inserted case 
        InsCse = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : cse.Id];
        //Remove product look up value.
        InsCse.Product_Lookup__c =  newProduct1.id;

        //Verify that a Case Product Base Code is null sunce there is no Product look up value.
        system.assertEquals(InsCse.Product_Base_Code__c, null, True);

        Update InsCse;

        UpdatedCase = [Select Id, Account.Name, Support_Status__c, Product_Base_Code__c, Support_Reason__c,Category__c,  On_Support__c, License_Account__c From Case Where Id = : InsCse.Id];

        Test.stopTest();

        //Verify that a Case has been inserted
        system.assertEquals(UpdatedCase.Id, InsCse.Id, True);
        //Verify that a Case Product Base Code is equal to the Product Code of newProduct1 ('AE').
        system.assert(UpdatedCase.Product_Base_Code__c == 'AE');
    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 16 July 2013, Last Modified: 27 October 2013
     **@description test method for testing prevention of creating Cases cause of Email looping
     */
    static testmethod void testEmailToCaseLoopKill(){
        try{
            //Disable On-Support trigger on Case
            CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
            cseTrigHandler.stopTrigger();
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();

            Test.startTest();

            //Create test Case records
            Case newcase1 = new Case(SuppliedEmail = 'test@mathworks.com', subject = 'Test', Origin = 'Email');
            insert newCase1;   
            Case newcase2 = new Case(SuppliedEmail = 'test@mathworks.com', subject = 'Test', Origin = 'Email');
            insert newCase2;   
            Case newcase3 = new Case(SuppliedEmail = 'test@mathworks.com', subject = 'Test', Origin = 'Email');
            insert newCase3;
            Case newcase4 = new Case(SuppliedEmail = 'test@mathworks.com', subject = 'Test', Origin = 'Email');
            insert newCase4;

            Test.stopTest();   
        }
        catch (System.DMLException ex) { //AC - 8.12.2014 : Added catch block statements
            System.assert(ex.getNumDml() > 0);
        }

        //Retrieve created test Cases
        list <Case> createdCases = [Select Id, Subject, SuppliedEmail From Case Where SuppliedEmail = 'test@mathworks.com' AND Subject = 'Test'];

        //Verify email loop and infinite creation of Case has been prevented
        system.assertEquals(createdCases.size(),3);
        system.assertEquals(ApexPages.hasMessages(),true);
        system.assertEquals(String.valueof(ApexPages.getMessages()[0]).contains('Automatic email loop has been terminated'),true);

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 09 October 2013, Last Modified: 22 October 2013
     **@description test method for testing Case Article Check method with Existing Case Article scenario on CaseDML
     */
    static testMethod void testCaseArticleCheckWithExistingCaseArticle() {
        FAQ__kav faqDr;
        FAQ__kav faqOn;
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
            
        User usr = TestDataBuilder.buildTestUser(1);
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, usr.Id);
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;
        
      
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        //create test case
        Case cse = TestDataBuilder.buildTestCase('Open');
        cse.License__c = '491381';
        insert cse;

        //Create test article
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        insert faq;
        System.RunAs(usr){
        //retrieve created test article to get KnowledgeArticleId
        faqDr = [Select Id, ArticleNumber, GeckId__c, SourceID, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];

        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
       
        //retrieve online article
         faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //create test Case Article
        CaseArticle cseart = new CaseArticle();
        cseart.CaseId = cse.Id;
        cseart.KnowledgeArticleId = faqOn.KnowledgeArticleId;
        insert cseart;

        Test.startTest();
        cse.Subject = 'test';
        update cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, Known_vs_New__c From Case Where Id = : cse.Id];

        //Verify that Case's Known vs New picklist field is updated 
        system.assertEquals(upcse.Known_vs_New__c, 'Known');
       }

    }

     /*
     ** @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     ** @date Original: 09 October 2013, Last Modified: 22 October 2013
     ** @description test method for testing Case Article Check method Citation Case scenario on CaseDML
     */
    static testMethod void testCaseArticleCheckCitationCase() {
         FAQ__kav faqDr;
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        //create test user
        User usr = TestDataBuilder.buildTestUser(1);
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;

        //Create test article
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        faq.CreatedById = UserInfo.getUserId();
        insert faq;
        System.runAs(usr) {
        //retrieve created test article to get KnowledgeArticleId
        faqDr = [Select Id, ArticleNumber, GeckId__c, SourceID, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        }
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];

        system.runAs(usr){

            //create test case
            Case cse = TestDataBuilder.buildTestCase('Closed');
            cse.CreatedById = usr.Id;
            cse.License__c = '491381';
            insert cse;

            //create test Case Article
            CaseArticle cseart = new CaseArticle();
            cseart.CaseId = cse.Id;
            cseart.KnowledgeArticleId = faqOn.KnowledgeArticleId;
            insert cseart;

            Test.startTest();
            cse.Subject = 'test';
            update cse;
            Test.stopTest();

            //Retrieve updated Case
            Case upcse = [Select Id, Known_vs_New__c, Citation__c From Case Where Id = : cse.Id];

            //Verify that Case's Citation field is updated 
            system.assertEquals(upcse.Citation__c, true);

        }

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 14 October 2013, Last Modified: 22 October 2013
     **@description test method for testing Case Article Check method Source Case scenario on CaseDML
     */
    static testMethod void testCaseArticleCheckSourceCase() {

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        //create test user
        User usr = TestDataBuilder.buildTestUser(1);
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;

        system.runAs(usr){

            //create test case
            Case cse = TestDataBuilder.buildTestCase('Closed');
            cse.License__c = '491381';
            insert cse;

            //Create test article
            FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
            insert faq;

            //retrieve created test article to get KnowledgeArticleId
            FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, SourceID, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];

            //create test Case Article
            CaseArticle cseart = new CaseArticle();
            cseart.CaseId = cse.Id;
            cseart.KnowledgeArticleId = faqDr.KnowledgeArticleId;
            insert cseart;

            Test.startTest();
            cse.Subject = 'test';
            update cse;

            //publish test draft article
            KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);

            //retrieve online article
            FAQ__kav faqOn = [Select Id, SourceId, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];

            Test.stopTest();

            //Retrieve updated Case
            Case upcse = [Select Id, Known_vs_New__c, Has_Linked_Article__c, Citation__c From Case Where Id = : cse.Id];

            //Verify that Case's Known VS New and Has Linked Article fields were updated
            //system.assertEquals(upcse.Known_vs_New__c, 'New');
            //system.assertEquals(upcse.Has_Linked_Article__c, true);

        }

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 14 October 2013, Last Modified: 22 October 2013
     **@description test method for testing updateCaseAreaSubArea method - Forward Email with Details scenario on CaseDML
     */
    static testMethod void testUpdateCaseAreaSubAreaForwardEmailWithDetails() {

        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@test.com';
        con.Country_Code__c = 'ph';
        insert con;

        //create test product
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.Product_Unique_Identifier__c = 'uniqueproduct';
        prod.Release__c = 'No Release';
        prod.Version__c = '1';
        prod.ProductCode = '12345pcode';
        prod.IsActive = true;
        insert prod;

        //Disable On-Support and Update SubStatus trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopUpdateSubStatus();
        cseTrigHandler.stopTrigger();

        Test.startTest();
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Open');
        cse.License__c = '491381';
        cse.ContactId = con.Id;
        cse.Origin = 'ML_Desktop';
        cse.Product_Lookup__c = prod.Id;
        cse.Platform__c = 'Mac';
        cse.SubStatus__c = null;
        cse.OS__c = 'Mac Any';
        cse.Description = 'test description';
        insert cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, Status, SubStatus__c From Case Where Id = : cse.Id];

        system.assertEquals(upcse.Status,'Open');
        system.assertEquals(upcse.SubStatus__c, 'In Progress'); //set into In Progress because of workflow update

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 14 October 2013, Last Modified: 22 October 2013
     **@description test method for testing updateCaseAreaSubArea method - forward details with empty details scenario on CaseDML
     *///
    static testMethod void testUpdateCaseAreaSubAreaForwardEmailEmptyDetails() {

        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), null);
        con.Email = 'test@test.com';
        con.Country_Code__c = 'ph'; //has no mathworks office
        insert con;

        //create test product
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.Product_Unique_Identifier__c = 'uniqueproduct';
        prod.Release__c = 'No Release';
        prod.Version__c = '1';
        prod.ProductCode = '12345pcode';
        prod.IsActive = true;
        insert prod;

        //Disable On-Support and Update SubStatus trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopUpdateSubStatus();
        cseTrigHandler.stopTrigger();

        Test.startTest();
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Open');
        //cse.License__c = '491381';
        cse.ContactId = con.Id;
        cse.Origin = 'ML_Desktop';
        cse.SubStatus__c = null;
        insert cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, Status, SubStatus__c From Case Where Id = : cse.Id];

        system.assertEquals('Open',upcse.Status);
        system.assertEquals('In Progress',upcse.SubStatus__c); //set into In Progress because of workflow update

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks Last Modified: kishore AN  - Cloud sherpas/Mathworks
     **@date Original: 14 October 2013, Last Modified: 20 January 2015
     **@description test method for testing updateCaseAreaSubArea method - No Mathworks Office scenario on CaseDML. Fixed the test class
     */
    static testMethod void testUpdateCaseAreaSubAreaNoOffice() {

        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        csb.buildGenSetting();
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), null);
        con.Email = 'test@test.com';
        con.MailingCountry='Andorra';
        con.MailingCountrycode='AD';
        con.MailingState='';
        con.MailingStateCode='';        
        con.Country_Code__c = 'ad'; //has mathworks office
        insert con;

        //create test product
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.Product_Unique_Identifier__c = 'uniqueproduct';
        prod.Release__c = 'No Release';
        prod.Version__c = '1';
        prod.ProductCode = '12345pcode';
        prod.IsActive = true;
        insert prod;

        //Disable On-Support and Update SubStatus trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopUpdateSubStatus();
        cseTrigHandler.stopTrigger();

        Test.startTest();
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Open');
        //cse.License__c = '491381';
        cse.ContactId = con.Id;
        cse.Origin = 'ML_Desktop';
        insert cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, Status, Area__c, SubStatus__c From Case Where Id = : cse.Id];

        //verify that Area was updated
        system.assertEquals(upcse.Area__c,'ES - Technical Support');

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 14 October 2013, Last Modified: 22 October 2013
     **@description test method for testing updateCaseAreaSubArea method - no existing records on Forward Rules scenario on CaseDML
     */
    static testMethod void testUpdateCaseAreaSubAreaNatickNoMatch() {

        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), null);
        con.Email = 'test@test.com';
        con.Country_Code__c = 'xx'; //no existing record on forwarding rules
        insert con;

        //create test product
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.Product_Unique_Identifier__c = 'uniqueproduct';
        prod.Release__c = 'No Release';
        prod.Version__c = '1';
        prod.ProductCode = '12345pcode';
        prod.IsActive = true;
        insert prod;

        //Disable On-Support and Update SubStatus trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopUpdateSubStatus();
        cseTrigHandler.stopTrigger();

        Test.startTest();
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Open');
        //cse.License__c = '491381';
        cse.ContactId = con.Id;
        cse.Origin = 'ML_Desktop';
        insert cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, Status, Area__c, SubStatus__c From Case Where Id = : cse.Id];

        //verify that area is updated
        //system.assertEquals(upcse.Area__c,'Natick - Technical Support');

    }

    /**
     **@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     **@date Original: 14 October 2013, Last Modified: 22 October 2013
     **@description test method for testing updateCaseAreaSubArea method - no existing records on Forward Rules scenario on CaseDML
     */
    static testMethod void testUpdateSubStatusChangeOwnership() {

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //create test user
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        Group g1 = new Group();
        QueueSobject queue = new QueueSobject();
        Case cse = new Case();

        System.runAs(usr){
            //create test queue
            g1 = new Group(Name='Unassigned', type='Queue');
            insert g1;
            queue = new QueueSobject(QueueID = g1.id, SobjectType = 'Case');
            insert queue;

            //create test account
            Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
            //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
            acc.Siebel_Account_Id__c = '1-1G82J';
            insert acc;

            //Disable On-Support trigger on Case
            CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
            cseTrigHandler.stopTrigger();

            //create test case
            cse = TestDataBuilder.buildTestCase('Open');
            cse.Origin = 'ML_Desktop';
            cse.SubStatus__c = 'Unassigned';
            cse.OwnerId = g1.Id;
            insert cse; 
        }

        Test.startTest();
        cse.OwnerId = UserInfo.getUserId();
        cse.SubStatus__c = 'In Progress';
        update cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, Status, Area__c, SubStatus__c From Case Where Id = : cse.Id];

        //Verify that Sub Status is updated
        system.assertEquals(upcse.SubStatus__c,'In Progress');

    }

    /**
     **The following two methods test casedml.updateCaseAccount()
     **The first tests the positive (a case is created with an account & opportunity related to it
     **The second tests the negitive (a case is created with no account or opportunity relationships
     */

    /**
     **@author Original: Eric Schoenfeld - Cloud Sherpas/Mathworks
     **@date Original: 14 october 2014, Last Modified: 
     **@description test method for testing updating of Account field on Case with related opportunities Account field value
     */

    static testMethod void testUpdateCaseAccount() {

        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 
        List<Account> accList=new List<Account>();
        List<Opportunity> optyList=new  List<Opportunity>();
        List<Case> caseLst = new List<Case>();
        Map<Id,Case> caseMapToTest = new Map<Id, Case>(); 
        Integer index=0;

        Test.startTest();

        //create test account
        for(Integer i=0;i<10;i++){

            Account acc = TestDataBuilder.buildTestAccount(i, UserInfo.getUserId());
            accList.add(acc);
        }
        insert accList;

        //create test opportunity
        for(Integer i=0;i<10;i++){
            Opportunity opp = TestDataBuilder.buildTestOpportunity(i);
            //set opportunity-Account relationship (relate the opportunity to the account created)
            opp.AccountId = accList[i].Id;
            optyList.add(opp);
        }
        insert optyList;

        //create test case
        for(Integer i=0;i<10;i++){
            Case cse = new Case();
            cse.Status = 'Open';
            cse.Area__c = 'Natick - Revenue Accounting and Controls';
            //set case-opportunity relationship ID (relate the case to the opportunity created)
            cse.Opportunity__c = optyList[i].Id;
            caseLst.add(cse);
        }
        insert caseLst;

        //Retrieve inserted case 
        caseMapToTest = new Map<Id, Case>([Select Id, Account.Name, Opportunity__c,
        Opportunity__r.Accountid   From Case Where Id in: caseLst]);

        Test.stopTest();

        for(Integer i=0;i<5;i++){

            Case cse =caseLst[i];

            //Verify that a Case has been inserted
            system.assertEquals(caseMapToTest.get(cse.id).id, cse.id);
            //Verify that an account name has been added to the case
            system.assertEquals(caseMapToTest.get(cse.id).Accountid,caseMapToTest.get(cse.id).Opportunity__r.Accountid);

        }


    }

    /**
     **@author Original: Eric Schoenfeld - Cloud Sherpas/Mathworks
     **@date Original: 15 october 2014, Last Modified: 
     **@description test method for testing creating cases when there is no related opportunity (and related account)
     *///

    static testMethod void testUpdateCaseNoAccount() {

        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        Case InsCse = new Case(); 
        Map<Id,Case> caseMapToTest = new Map<Id, Case>();   
        List<Case> caseLst = new List<Case>();


        Test.startTest();

        //create test case
        for(Integer i=0;i<5;i++){

            Case cse = new Case();
            cse.Status = 'Open';
            cse.Area__c = 'Natick - Revenue Accounting and Controls';
            caseLst.add(cse);
        }
        insert caseLst;

        //Retrieve inserted case 
        caseMapToTest = new Map<Id, Case>([Select Id, Account.Name, Opportunity__c From Case Where Id in: caseLst]);

        Test.stopTest();

        for(Integer i=0;i<5;i++){

            Case cse =caseLst[i];

            //Verify that a Case has been inserted
            system.assertEquals(caseMapToTest.get(cse.id).id, cse.id);
            //Verify that no account name has been added to the case
            system.assertEquals(caseMapToTest.get(cse.id).Accountid, null);
            //Verify that no opportunity name has been added to the case
            system.assertEquals(caseMapToTest.get(cse.id).Opportunity__c, null);
        }
    }
    
     /**
     **@author Original: Archana Lohar - Cloud Sherpas/Mathworks
     **@date Original: 15 May 2015, Last Modified: 15 May 2015
     **@description test method for testing whether ForwardToDistributor is true
     */
    static testMethod void testUpdateCaseAreaSubAreaCheckForwardToDistributor() {

        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create General Setting
         List<General_Settings__c> genSettings = new List<General_Settings__c>([SELECT Id FROM General_Settings__c WHERE SetupOwnerId =: UserInfo.getOrganizationId()]);
            General_Settings__c getSet = new General_Settings__c();
            if(genSettings != null && !genSettings.IsEmpty()){
                getSet.Id = genSettings[0].Id;
            }            
            getSet.ACE_Url__c = 'http://mathworks.com';
            getSet.Escalate_To_Dev_Email__c = 'devsupp@mathworks.com';
            getSet.SetupOwnerId = UserInfo.getOrganizationId();
            getSet.EmailRoutingRule_Current_ResponseTo__c = 'Response_to_PROD__c';
            getSet.Opportunity_Close_Date__c = Date.valueof('2099-01-01');
            getSet.CDSBaseUrl__c='https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v1/';
            getSet.RegEx_Latin__c='^[\u0000-\u04FF]+';
            User usrObj=TestDataBuilder.buildTestUser(0);
            getSet.Default_Opportunity_Owner__c=usrObj.alias;
            getSet.RTToIncludeAddingProjTeamMemberOnInsert__c='Marketing Request,Sales Request';
            getSet.Batch_Size_For_Territory2Trigger__c = '2000';
            getSet.Batch_Schedule_Time_Territory2Trigge__c = '15';
            getSet.Bypass_Assignment_Of_Account_To_Territor__c = false;
            getSet.CaseDeleteOverride_Excluded_Profile_1__c = 'MathWorks Data Management';
            getSet.CaseDeleteOverride_Excluded_Profile_2__c = 'System Administrator';
            getSet.CDS_IsChanged_Interval__c = 0.0003472220;
            getSet.Current_Domain__c = 'https://mathworks--salesdev.cs15.my.salesforce.com/';
            getSet.Emailaddress_Territory2Dml__c = ' sfdcsupport@mathworks.com';
            getSet.HideCheckBoxForDoNotCreateActivity__c = true;
            getSet.HideCheckBoxForSendEmailNotification__c = true;
            getSet.HideOpportunityOwnerSearchBox__c = true;
            getSet.Open_Preference_Center__c = 'https://go2.mathworks.com/mwint00qe000000431aheay';
            getSet.ORC_Url__c = 'http://inside-apps-dev3.mathworks.com/orclookups/contactDetails.do';
            getSet.RegEx_To_Check_ID__c ='[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ;
            getSet.Research_Team_Owner__c ='mwsadmin';
            getSet.ForwardCToDistributorSchedulableInterval__c = 0;
            getSet.BatchSizeForForwardingCasesToDistributor__c = 80;
            upsert getSet;
        

        //create test account
        Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
        //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
        acc.Siebel_Account_Id__c = '1-1G82J';
        insert acc;

        //create test contact
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.OwnerId = UserInfo.getUserId();
        con.LastName = 'TLastName';
        con.FirstName = 'TFirstname';
        con.MailingStreet = 'test street';
        con.MailingCity = 'test city';
        con.MailingCountryCode = 'PH';
        con.MailingCountry = 'Philippines';
        con.MailingPostalCode = '00000';
        con.Email = 'mwtest@mwtest.com';
        con.MathWorks_Account_ID__c = '12334324';
        con.Siebel_Contact_Id__c = '123234245';
        con.Student__c = false;
        insert con;

        //Disable On-Support and Update SubStatus trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopUpdateSubStatus();
        cseTrigHandler.stopTrigger();

        Test.startTest();
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Open');
        cse.ContactId = con.Id;
        cse.Origin = 'ML_Desktop';
        insert cse;
        Test.stopTest();

        //Retrieve updated Case
        Case upcse = [Select Id, ForwardToDistributor__c,Status,SubStatus__c From Case Where Id = : cse.Id];
system.debug(upcse);
        system.assert(upcse.ForwardToDistributor__c);
       

    }
    /**
     **@author Original: Sagar Talele
     **@date Original: 25 Nov 15
     **@description test method - Test for Functionality :when case is closed all open tasks under the case also closed and excluded those task which having owner has a Advanced Support as  area- 
     */

    static testMethod void checkCaseCLoserUpdateTask(){
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create the Areas Case Task Closure custom setting
        csb.buildAreaTaskClosure();

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(10);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        stdUser.Area__c = 'UK - Technical Support';
        insert stdUser;
        
        //create test User
        User userrec = TestDataBuilder.buildTestUser(1);
        userrec.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        userrec.Area__c = 'UK - Advanced Support';
        insert userrec;
        
        //Run as MW standard User
        system.runAs(stdUser){
            list <Case> caselist = new list<Case>();
            list <Case> caselist1 = new list<Case>();
            list <Case> updatedCaseList = new list <Case>();
            List<Task> taskList = new List<Task>();
            List<Task> tskList = new List<Task>();
            List<Task> updatedTaskList1 = new List<Task>();
            List<Task> updatedTaskList = new List<Task>();
            list <Case> updatedCaseLst = new list <Case>();
            list <Case> updatedCaseLst1 = new list <Case>();
            list <Case> updatedCseLst = new list <Case>();
           
           for (Integer i=0;i<200;i++){
                Case cse = TestDataBuilder.buildTestCase('Open');
                 cse.Area__c = 'FR-Technical Support';
                caselist.add(cse);
            }
            
            insert caselist;
            System.assertEquals(caselist.size(),200);
            
            for(Integer i=0;i<200;i++){
                Task tskObj = TestDataBuilder.buildTestTask(stdUser.Id, 'Not Started', 'To Do', 'TestCaseTrigger');
                tskObj.whatId = caselist[i].Id;
                taskList.add(tskObj);
            }
            insert taskList;
            System.assertEquals(taskList.size(),200);
            
            //Retrieve created Case records
            updatedCaseList = [Select Area__c From Case Where Id in : caselist];
            
            // System.assertEquals(updatedCaseList.size(),200);
            Product2 prod2 = TestDataBuilder.buildTestProduct(2);
            insert prod2;
                        
            for(Case caseObj : updatedCaseList){
               
                caseObj.Status = 'Closed';
                caseObj.SubStatus__c = 'Resolved';
                caseObj.Category__c = 'Code Generation';
                caseObj.License__c = '12345';
                caseObj.OS__c = 'All OS';
                caseObj.Platform__c = 'Windows x32';
                caseObj.Product_Lookup__c = prod2.Id;
                caseObj.Sub_Area__c = 'Customer Service';
                caseObj.Sub_Topic__c = 'A&A';
                caseObj.Topic__c = 'Activation';
                caseObj.Usage_Type__c = 'MATLAB Mobile';
                caseObj.Device__c = 'Phone';
                caseObj.Mobile_OS_Version__c = 'Android 5 (Lollipop)';
                updatedCaseLst.add(caseObj);
            }
            
            Test.startTest();
            
            update updatedCaseLst ;
            
            
            updatedTaskList = [Select Id,WhatId ,Status From Task Where WhatId In:updatedCaseLst];
            System.assertEquals(updatedTaskList.size(),200);
            
            for(Task tsk : updatedTaskList ){
                System.assertEquals(tsk.Status,'Completed');
            }
            //scenario 2
            
             for (Integer i=0;i<200;i++){
                Case cse = TestDataBuilder.buildTestCase('Open');
                 cse.Area__c = 'FR-Technical Support';
                caselist1.add(cse);
            }

            
            insert caselist1;
            System.assertEquals(caselist.size(),200);
            
            for(Integer i=0;i<200;i++){
                Task tskObj1 = TestDataBuilder.buildTestTask(userrec.Id, 'Not Started', 'To Do', 'TestCaseTrigger');
                tskObj1.whatId = caselist1[i].Id;
                tskList.add(tskObj1);
            }
            insert tskList;
            System.assertEquals(tskList.size(),200);
            
            //Retrieve created Case records
            updatedCaseLst1 = [Select Area__c From Case Where Id in : caselist1];
            
            // System.assertEquals(updatedCaseList.size(),200);
            Product2 prod = TestDataBuilder.buildTestProduct(1);
            insert prod;
            
            
            for(Case caseObj1 : updatedCaseLst1){
               
                caseObj1.Status = 'Closed';
                caseObj1.SubStatus__c = 'Resolved';
                caseObj1.Category__c = 'Code Generation';
                caseObj1.License__c = '12345';
                caseObj1.OS__c = 'All OS';
                caseObj1.Platform__c = 'Windows x32';
                caseObj1.Product_Lookup__c = prod.Id;
                caseObj1.Sub_Area__c = 'Customer Service';
                caseObj1.Sub_Topic__c = 'A&A';
                caseObj1.Topic__c = 'Activation';
                caseObj1.Usage_Type__c = 'MATLAB Mobile';
                caseObj1.Device__c = 'Phone';
                caseObj1.Mobile_OS_Version__c = 'Android 5 (Lollipop)';
                updatedCseLst.add(caseObj1);
            }
             update updatedCseLst ;
            
            Test.stopTest();
           updatedTaskList1 = [Select Id,WhatId ,Status From Task Where WhatId In:updatedCseLst ];
            System.assertEquals(updatedTaskList1.size(),200);
            //check task not updated
            for(Task tsk : updatedTaskList1 ){
                System.assertEquals(tsk.Status,'Not Started');
            }
            
      }
        
    }

}