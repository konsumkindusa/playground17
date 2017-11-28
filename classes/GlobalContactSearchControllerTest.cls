/*
 *    @description: tests the GlobalContactSearchController
 */ 
@isTest
private class GlobalContactSearchControllerTest{

    public static Account acc {get; set;}
    public static Contact con {get; set;}  

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    /*
    @ name    TestContactinSF
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :Expected that contact is found in SFDC Page is redirected to Contact Details 
     */
    private static testMethod void TestContactinSF(){
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
            
            //Create Dummy Data
            createDummyData(usr);            

            //set current page 
            PageReference cdsPage = Page.GlobalContactSearch;
            Test.setCurrentPage(cdsPage);

            Contact standardCtrlCon = new Contact();
            GlobalContactSearchController controller = new GlobalContactSearchController(new ApexPages.StandardController(standardCtrlCon));
            controller.contObj.email = 'TContact1@mathworks.com';
            Test.startTest();

            //search contact 
            PageReference returnPage = controller.searchContact();
            PageReference ContactDetailPage = new PageReference('/' +controller.contList[0].id);

            //assert that the page reference is redirected to Contact Detail Page
            System.assertEquals(ContactDetailPage.getUrl(), returnPage.getUrl());
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email =: controller.contObj.email];
            system.assertEquals(1, conList.size());
            Test.stopTest();
        }
    }
    
    /*
    @ name    TestWebservice
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :Expected that contact is found in SFDC Page is redirected to Contact Details 
     */
     static testMethod void testGlobalContactWSWithEmail(){
           Test.startTest();  
            //Call webservice
               GlobalContactSearchController.SearchContactResponse resp = GlobalContactSearchController.searchContactByEmail('shicy.tulip@gmail.com.mwtest');
           Test.stopTest();  
      }
      static testMethod void testGlobalContactWSWithNoEmail(){
           Test.startTest();  
            //Call webservice
               GlobalContactSearchController.SearchContactResponse resp = GlobalContactSearchController.searchContactByEmail(null);
           Test.stopTest();  
      }
      
    /*
    @ name    TestContactinCDSWithPrimaryAccountID
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Expected that contact is found in CDS has primary AccountId New Account and Contact is created
     */
   private static testMethod void TestContactinCDSWithPrimaryAccountID(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;


        System.runAs(usr){
            //Create Dummy Data
            createDummyData(usr);                         

            Contact c = new Contact();

            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'shicy.tulip@gmail.com.mwtest';
            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            multimock1.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue', 'mockResponseTestContact');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/accounts/C100021?X_MW_WS_securityToken=TestTokenValue', 'mockResponseTestAccount'); //DL 1508448

            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, multimock1);

            controller.conJsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue');

            controller.accJsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/accounts/C100021?X_MW_WS_securityToken=TestTokenValue'); //DL 1508448


            //search contact

            controller.searchContact();                        
            Test.stopTest();

            //assert new contact is created
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email =: controller.contObj.email AND AccountId != null];
            system.assertEquals(1, conList.size());

        }
    }
    /*
    @ name    TestContactinCDSWithoutPrimaryAccountId
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :     Expected that contact is found in CDS and has no primary AccountId
     *              New Contact is created. Dummy Account is created on trigger
     */
    private static testMethod void TestContactinCDSWithoutPrimaryAccountId(){
                 
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
            //Create Dummy Data
            createDummyData(usr);                                                

            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'shicy.tulip@gmail.com.mwtest';


            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            multimock1.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue', 'mockResponseTest'); //DL 1508448 added securityToken

            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest(); 

            Test.setMock(HttpCalloutMock.class, multimock1);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue'); //DL 1508448 added securityToken

            controller.conJsonString=jsonString;

            //search contact

            controller.searchContact();                        
            Test.stopTest();
            //assert new contact is created
            List<Contact> conList = [SELECT Id, mailingcountrycode FROM Contact WHERE Email =:controller.contObj.email ];
            system.assertEquals(1, conList.size());
            system.assertEquals('US', conList[0].mailingcountrycode);

        }
    }
    /*
    @ name    TestContactNotInSFandCDS
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Expected that Page is redirected to New Contact Screen
     */ 
    private static testMethod void TestContactNotInSFandCDS(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        //re-create general Custom Setting
        csb.buildGenSetting();

        
        csb.buildIntegrationSetting();

        System.runAs(usr){                               
            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'TContact2@mathworks.com';

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
            multimock.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=TContact2@mathworks.com&X_MW_WS_securityToken=TestTokenValue', 'mockResponse');



            multimock.setStatusCode(200);
            multimock.setHeader('Content-Type', 'application/json');

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimock);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=TContact2@mathworks.com&X_MW_WS_securityToken=TestTokenValue');

            controller.conJsonString=jsonString;



            //search contact
            PageReference returnPage = controller.searchContact();            
            PageReference newCont = new PageReference('/apex/GlobalContactSearchOptions'); 
            Test.stopTest();
            //assert page is redirected to New Contact Screen Page
            system.assertEquals(newCont.getUrl(), returnPage.getUrl());                         
        }
    }

    /*
    @ name    TestContactinCDSWithAccountIdExsistInSFDC
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Expected that new contact will be created and get associate with exsisting sfdc Account
     */ 
   private static testMethod void TestContactinCDSWithAccountIdExsistInSFDC(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;


        //Create Dummy Data
        Integer index=0;



        System.runAs(usr){   

            //Create Dummy Data
            createDummyData(usr);    

            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'shicy.tulip@gmail.com.mwtest';

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
            multimock.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue', 'mockResponseTestAccountExsistInSFDC');



            multimock.setStatusCode(200);
            multimock.setHeader('Content-Type', 'application/json');

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimock);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue');
                                                          
            controller.conJsonString=jsonString;



            //search contact
            PageReference returnPage = controller.searchContact();            
            //assert new contact is created
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email =:controller.contObj.email And AccountId!=null];
            system.assertEquals(1, conList.size()); 
            Test.stopTest();


                               
        }
    }
    
    /*
    @ name    TestContactinCDSForSelfIdentifiedCountry
    @ date    24.June.2016
    @ author  Donna Latte Story 1499217 - add selfIdentifiedCountry
    @ param   none.
    @ return  Void. 
    @ description :  Expected that contact is found in CDS and has no primary AccountId
     *               set selfIdentifiedCountry as the mailing country code. 
     *               Dummy Account is created on trigger.
     */
    private static testMethod void TestContactinCDSForSelfIdentifiedCountry(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
            //Create Dummy Data
            createDummyData(usr);                                                

            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'nlalande@uw.edu.mwtest';

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            multimock1.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=nlalande@uw.edu.mwtest&X_MW_WS_securityToken=TestTokenValue', 'MockResponseHavingselfIdentifiedCountry');

            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, multimock1);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=nlalande@uw.edu.mwtest&X_MW_WS_securityToken=TestTokenValue');

            controller.conJsonString=jsonString;

            //search contact

            controller.searchContact();                        
            Test.stopTest();         
            
            //assert new contact is created
            List<Contact> conList = [SELECT Id, mailingcountrycode FROM Contact WHERE Email =:controller.contObj.email ];
            system.assertEquals(1, conList.size());
            system.assertEquals('US', conList[0].mailingcountrycode);

        }
    }



 /*
      * DL: Story 1499217 - removed schoolCountryCode
    @ name    TeststandAloneContactinCDSForSchoolCountryCode
    @ date    28.April.2015
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :  Expected that contact is found in CDS and has no primary AccountId
     *               set schoolCountryCode as the mailing country code. 
     *               Dummy Account is created on trigger.
     */
    /*
    private static testMethod void TeststandAloneContactinCDSForSchoolCountryCode(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
            //Create Dummy Data
            createDummyData(usr);                                                

            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'nlalande@uw.edu.mwtest';

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            multimock1.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=nlalande@uw.edu.mwtest&X_MW_WS_securityToken=TestTokenValue', 'MockResponseHavingschoolCountry');

            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, multimock1);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=nlalande@uw.edu.mwtest&X_MW_WS_securityToken=TestTokenValue');

            controller.conJsonString=jsonString;

            //search contact

            controller.searchContact();                        
            Test.stopTest();
            //assert new contact is created
            List<Contact> conList = [SELECT Id, mailingcountrycode FROM Contact WHERE Email =:controller.contObj.email ];
            system.assertEquals(1, conList.size());
            system.assertEquals('US', conList[0].mailingcountrycode);

        }
    }
 */   
    
      /*
    @ name    TeststandAloneContactinCDSAndsetMailingContry
    @ date    3/30/2016
    @ author  Shweta Shanbhag
    @ param   none.
    @ return  Void. 
    @ description :  Expected that contact is found in CDS and has no primary AccountId
     *               set derivedCountryCode as the mailing country code. 
     *               Dummy Account is created on trigger.
     */
    private static testMethod void TeststandAloneContactinCDSForderivedCountryCode(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
            //Create Dummy Data
            createDummyData(usr);                                                

            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'carpemc@byu.edu.mwtest';

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            multimock1.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=carpemc@byu.edu.mwtest&X_MW_WS_securityToken=TestTokenValue', 'MockResponseHavingderivedCountryCode');

            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, multimock1);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=carpemc@byu.edu.mwtest&X_MW_WS_securityToken=TestTokenValue');

            controller.conJsonString=jsonString;

            //search contact

            controller.searchContact();                        
            Test.stopTest();
            //assert new contact is created
            List<Contact> conList = [SELECT Id, mailingcountrycode FROM Contact WHERE Email =:controller.contObj.email ];
            system.assertEquals(1, conList.size());
            system.assertEquals('US', conList[0].mailingcountrycode);

        }
    }
    
   /*
    @ name    TestContactinCDSWithMWAEmailVerified
    @ date    8.Apr.2016
    @ author  Donna Latte Story: 1427895
    @ param   none.
    @ return  Void. 
    @ description : Expected that contact is found in CDS and has verified MWA Email
     *              New Contact is created. Dummy Account is created on trigger.
     *              Story: 1427895
   */
    private static testMethod void TestContactinCDSWithMWAEmailVerified(){
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
            //Create Dummy Data
            createDummyData(usr);                                                

            Contact c = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(c);
            GlobalContactSearchController controller = new GlobalContactSearchController(standardCtrlCon);
            controller.contObj.email = 'shicy.tulip@gmail.com.mwtest';

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            multimock1.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            multimock1.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue', 'mockResponseTest');

            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, multimock1);

            String jsonString = controller.getJasonString('https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=shicy.tulip@gmail.com.mwtest&X_MW_WS_securityToken=TestTokenValue');

            controller.conJsonString=jsonString;

            //search contact

            controller.searchContact();                        
            Test.stopTest();
            //assert new contact is created            
            List<Contact> conList = [SELECT Id, Mathworks_Account_Email_Verified__c FROM Contact WHERE Email =:controller.contObj.email ];
            system.assertEquals(1, conList.size());
            system.assertEquals(true, conList[0].Mathworks_Account_Email_Verified__c);

        }
    } // END DL: 1427895
 
    
    /*
    @ name    createDummyData
    @ date    14.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :This method creates Dummy Contact and Dummy Account
     */ 
    private static void createDummyData(User usr){

        //re-create general Custom Setting
        csb.buildGenSetting();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        
        csb.buildIntegrationSetting();

        //Create Dummy Data
        Integer index=0;

        Account accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.CDS_Account_Id__c='C652149';


        insert accObj;

        //create Contact record from TestDataBuilder.
        Contact conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Bombay';
        conObj.MailingCountry = 'India';
        conObj.MailingCountryCode = 'IN';
        conObj.MailingPostalCode ='400011';
        conObj.MailingState ='Maharashtra';
        conObj.MailingStateCode = 'MH';
        conObj.MailingStreet = 'MG Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'TContact1@mathworks.com';

        insert conObj;
    }    
}