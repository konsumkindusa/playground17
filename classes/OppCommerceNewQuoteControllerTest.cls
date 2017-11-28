/*
 *@author Original: Shweta Shanbhag - Mathworks
 *@Last Modified: Shweta Shanbhag - Mathworks, Faina Gorelik AtTask 1534293, Dennis Atwood 1946380
 *@date Original:2/25/2016
 *@Last Modified: 2/25/2016 | 06/06/2016 | 09/13/2017
 *@description This  is Test class for 'OppCommerceNewQuoteController' class . 
*
* 9-18-2017 Dennis Atwood - Cleaned up white space, 
	insertOpportunityCompleteData(): added custom settings build methods
									 added opty.Master_License_Id__c = '1234'; to test this parameter in the URL
 */

@isTest
public class OppCommerceNewQuoteControllerTest {
    
    public static Account accObj {get; set;}
    public static Contact conObj {get; set;}
    public static QuoteIntegrationSettings__c settings ;
 
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();


    /*
    @ name    TestOpenCreateQuoteURL
    @ date    2/25/2016
    @ author  Shweta Shanbhag
    @ param   none.
    @ return  Void. 
    @ description :Test if all validations pass and quote url is opened
     */
    static testMethod void TestOpenCreateQuoteURL()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        //re-create gener2al Custom Setting
        csb.buildQuoteIntegrationSettings();
    
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
          
        //Fetching date from General custom setting
        settings = QuoteIntegrationSettings__c.getInstance();
        

        System.runAs(usr){

            Opportunity opty=insertOpportunityCompleteData();           

            //set current page 
            PageReference quotePage = Page.OppCommerceNewQuote;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OppCommerceNewQuoteController controller = new OppCommerceNewQuoteController(sc);
            
            Test.startTest();

            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id];
            System.currentPagereference().getParameters().put('contactId',relatedContactsList[0].Contact.id);
            controller.selectContact();
           
            //search contact 
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkQuotePage=controller.validateFields();

            //assert that the page reference is redirected to Contact Detail Page
            //System.assertEquals(settings.CommerceQuoteURL__c+'create?contactId='+relatedContactsList[0].contact.CDS_Contact_Id__c+'&opportunityId='+opty.Id, MathworkQuotePage.getUrl());
            //DMA 1946380 - changing assertion to provide more flexibility for order of parameters in URL (appears that SFDC parses URL and may not keep order of parameters)
            String fullURL = MathworkQuotePage.getUrl();
            System.assert(fullURL.indexOf(settings.CommerceQuoteURL__c) == 0);  //ensure URL begins with string specified in custom settings
            System.assert(fullURL.contains('contactId='+relatedContactsList[0].contact.CDS_Contact_Id__c));
            System.assert(fullURL.contains('opportunityId='+opty.Id));
            System.assert(fullURL.contains('masterLicenseId='+opty.Master_License_Id__c));
            
            Test.stopTest();
            
        }
    }


    /*
    @ name    TestCDSIdMissingOnContact
    @ date    2/25/2016
    @ author  Shweta Shanbhag
    @ param   none.
    @ return  Void. 
    @ description :Test if  contact on Opportunity does not have CDS Contact Id populated
     */
    static testMethod void TestCDSIdMissingOnContact()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        //re-create gener2al Custom Setting
        csb.buildQuoteIntegrationSettings();
    
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();

        System.runAs(usr){

            Opportunity opty=insertOpportunityInCompleteData();

            //set current page 
            PageReference quotePage = Page.OppCommerceNewQuote;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OppCommerceNewQuoteController controller = new OppCommerceNewQuoteController(sc);
            
            Test.startTest();

            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];

            controller.selContactid=relatedContactsList[0].Contact.id; 

            //search contact 
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkQuotePage=controller.validateFields();


            //assert that the page reference is not redirected to Contact Detail Page
            System.assertEquals(null, MathworkQuotePage);

            Test.stopTest();
        }
    }

         /*
        @ name    TestMissingContactonOpp
        @ date    2/25/2016
        @ author  Shweta Shanbhag
        @ param   none.
        @ return  Void. 
        @ description :Test if  contact on Opportunity does not have CDS Contact Id populated
         */
        static testMethod void TestMissingContactonOpp()  {
    
            User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
            
            //re-create gener2al Custom Setting
            csb.buildQuoteIntegrationSettings();
    
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            csb.buildGenSetting();
            
            //Fetching date from General custom setting
            settings = QuoteIntegrationSettings__c.getInstance();
    
            System.runAs(usr){
                
                Integer index=0;
        
            //create Account record from TestDataBuilder.
            accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';
            accObj.name = 'TestAccountOppQuote';
            accObj.Account_Name_Latin__c = 'TestName';
            accObj.BillingCity = 'testCity';
            accObj.Account_City_Latin__c='TestCity';
     
            insert accObj;
    
            Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
            opty.AccountId = accObj.Id;
    
            insert opty;


            //set current page 
            PageReference quotePage = Page.OppCommerceNewQuote;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OppCommerceNewQuoteController controller = new OppCommerceNewQuoteController(sc);
            
            Test.startTest();

            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];

                if (relatedContactsList.size() >0){
                    controller.selContactid=relatedContactsList[0].Contact.id; }

            //search contact 
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkQuotePage=controller.validateFields();


            //assert that the page reference is not redirected to Contact Detail Page
            System.assertEquals(null, MathworkQuotePage);

            Test.stopTest();
        }
    }

    /*
    @ name    insertOpportunityCompleteData
    @ date    2/25/2016
    @ author  Shweta Shanbhag
    @ param   none.
    @ return  Opty
    @ description Method to create test Opp record  and associate with contact and account having complete information                            
     */

    private static Opportunity insertOpportunityCompleteData() {

        Integer index=0;  

        //create Account record from TestDataBuilder.
        accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Beacon';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.CDS_Account_Id__c='C12345';
        
        insert accObj;
        
         //create Contact record from TestDataBuilder.
        conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Buffalo';
        conObj.MailingCountry = 'United States';
        conObj.MailingState ='New York';
        conObj.MailingCountryCode = 'US';
        conObj.MailingStateCode ='NY';
        conObj.MailingPostalCode ='14200';
        conObj.City_Latin__c='testCity';
        conObj.Street_Latin__c='testStreet';
        conObj.MailingStreet = 'Main Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'testcont@mwtest.com';
        conObj.CDS_Contact_Id__c='C3456';
        conObj.First_Name_Latin__c='TestConFN';
        conObj.Last_Name_Latin__c='TestConLN';
        conObj.Job_Title_Latin__c='Manager';
        conObj.Mail_Stop_Latin__c='testmail';
        conObj.Department_Latin__c='Engineering'; 
        
        insert conObj;
       
        Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
        opty.AccountId = accObj.Id;
        opty.Master_License_Id__c = '1234';  //DMA 1946380

        insert opty;
        
        OpportunityContactRole roles=new OpportunityContactRole();
        roles.OpportunityId = opty.id;
        roles.ContactId =conObj.id;
        roles.isPrimary=true;
        insert roles;

        return opty;

    } 

    /*
    @ name    insertOpportunityInCompleteData
    @ date    2/25/2016
    @ author  Shweta Shanbhag
    @ param   none.
    @ return  Opty
    @ description Method to create test Opp record  and associate with contact and account having incomplete information                               
     */

    private static Opportunity insertOpportunityInCompleteData() {

        Integer index=0;   

        //create Account record from TestDataBuilder.
        accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.name = 'TestAccountOppQuote';
        accObj.Account_Name_Latin__c = 'TestName';
        accObj.BillingCity = 'testCity';
        accObj.Account_City_Latin__c='TestCity';
       // accObj.Is_Individual_Account__c=true  fg AtTask 1534293 validation rule prevents opportunity to be saved for individual accounts
        
        insert accObj;

        //create Contact record from TestDataBuilder.
        conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Buffalo';
        conObj.MailingCountry = 'United States';
        conObj.MailingState ='New York';
        conObj.MailingCountryCode = 'US';
        conObj.MailingStateCode ='NY';
        conObj.MailingPostalCode ='14200';
        conObj.City_Latin__c='testCity';
        conObj.Street_Latin__c='testStreet';
        conObj.MailingStreet = 'Main Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'testcont@mwtest.com';
      //  conObj.CDS_Contact_Id__c='C3456';
        conObj.FirstName='ØØØØ';
        conObj.LastName='ØØ';
        insert conObj;

        Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
        opty.AccountId = accObj.Id;
        insert opty;
        OpportunityContactRole roles=new OpportunityContactRole();
        roles.OpportunityId = opty.id;
        roles.ContactId =conObj.id;
        roles.isPrimary=true;
        insert roles;
        return opty;
    } 
}