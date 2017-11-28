/**
 *@author Original: Haigang Wu - Mathworks,
 *@date Original: 04 Mar 2016
 *@description This is test class for ContactViewQuotesCommerceController class
 *             
 */

@isTest 
public class ContactViewQuotesCommerceControllerTest {
    public static Account accObj {get; set;}
    public static Contact conObj {get; set;}  
    public static QuoteIntegrationSettings__c settings ;



    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    static testMethod void TestIfValidationPass()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
       

        System.runAs(usr){

            conObj=createDummyContactWithCompleteData();  
            
            //set current page 
            PageReference quotePage = Page.ContactViewQuotesCommerce;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', conObj.Id);

            Contact standardCtrlCon = new Contact();
            ContactViewQuotesCommerceController controller = new ContactViewQuotesCommerceController(new ApexPages.StandardController(standardCtrlCon));

            Test.startTest();

            PageReference MathworkQuotePage=controller.getContactRecord();
            
            //assert that the page reference is redirected to new quote page
            System.assertEquals(settings.CommerceQuoteURL__c+'list?q='+conObj.CDS_Contact_Id__c,MathworkQuotePage.geturl());

            Test.stopTest();
        }
    }



    static testMethod void TestIfValidationFail()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){

            conObj=createDummyContactWithInCompleteData();           

            //set current page 
            PageReference quotePage = Page.ContactNewQuote;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', conObj.Id);

            Contact standardCtrlCon = new Contact();
            ContactNewQuoteController controller = new ContactNewQuoteController(new ApexPages.StandardController(standardCtrlCon));

            Test.startTest();

            
            //get contact record
            PageReference MathworkQuotePage=controller.getContactRecord();
            
            System.assertEquals(null,MathworkQuotePage);

            Test.stopTest();
        }
    }
    

    private static Contact createDummyContactWithCompleteData(){

        //re-create general Custom Setting
        csb.buildQuoteIntegrationSettings();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Fetching date from General custom setting
         settings = QuoteIntegrationSettings__c.getInstance();  
        
        csb.buildGenSetting();

        //Create Dummy Data
        Integer index=0;

        accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.Siebel_Account_Id__c='C12345';


        insert accObj;

        //create Contact record from TestDataBuilder.
        conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Bombay';
        conObj.MailingCountry = 'India';
        conObj.MailingCountryCode = 'IN';
        conObj.MailingPostalCode ='400011';
        conObj.MailingState = 'Maharashtra';
        conObj.MailingStateCode = 'MH';
        conObj.MailingStreet = 'MG Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'john@gmail.com';
        conObj.CDS_Contact_Id__c='C3456';
        conObj.First_Name_Latin__c='qwerty';
        conObj.Last_Name_Latin__c='qsdfg';

        insert conObj;

        return conObj;
    }    

 

    private static Contact createDummyContactWithInCompleteData(){

        //re-create general Custom Setting
        csb.buildQuoteIntegrationSettings();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        csb.buildGenSetting();
        
        //Fetching date from General custom setting
        settings = QuoteIntegrationSettings__c.getInstance();   

        //Create Dummy Data
        Integer index=0;

        accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';

        insert accObj;

        //create Contact record from TestDataBuilder.
        conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Bombay';
        conObj.MailingCountry = 'India';
        conObj.MailingCountryCode = 'IN';
        conObj.MailingPostalCode ='400011';
        conObj.MailingState ='Maharashtra';
        conObj.MailingStateCode = 'MH';
        conObj.MailingStreet = 'MG Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'john@gmail.com';
        conObj.Siebel_Contact_Id__c='C3456';
        conObj.FirstName='ØØØØ';
        conObj.LastName='ØØ';


        insert conObj;

        return conObj;
    }    

}