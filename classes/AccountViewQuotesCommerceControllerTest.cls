/**
 *@author Original: Haigang Wu - Mathworks,
 *@date Original: 03 Mar 2016
 *@description This is test class for AccountViewQuotesCommerceController class
 *             
 */

@isTest 
public class AccountViewQuotesCommerceControllerTest {
    
    public static Account accObj {get; set;}
    public static Contact conObj {get; set;}  
    public static QuoteIntegrationSettings__c settings ;



    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    static testMethod void TestIfValidationPass()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
       

        System.runAs(usr){

            accObj=createDummyAccountWithCompleteData();  
            
            //set current page 
            PageReference quotePage = Page.AccountViewQuotesCommerce;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', accObj.Id);

            Account standardCtrlAcc= new Account();
            AccountViewQuotesCommerceController controller = new AccountViewQuotesCommerceController(new ApexPages.StandardController(standardCtrlAcc));

            Test.startTest();

            PageReference MathworkQuotePage=controller.getContactRecord();
            
            //assert that the page reference is redirected to new quote page
            System.assertEquals(settings.CommerceQuoteURL__c+'list?q='+accObj.CDS_Account_Id__c,MathworkQuotePage.geturl());

            Test.stopTest();
        }
    }


    static testMethod void TestIfValidationFail()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){

            accObj=createDummyAccountWithInCompleteData();           

            //set current page 
            PageReference quotePage = Page.AccountViewQuotesCommerce;
            Test.setCurrentPage(quotePage);

            //Putting id into URL
            quotePage.getParameters().put('id', accObj.Id);

            Account standardCtrlAcc = new Account();
            AccountViewQuotesCommerceController controller = new AccountViewQuotesCommerceController(new ApexPages.StandardController(standardCtrlAcc));

            Test.startTest();

            
            //get contact record
            PageReference MathworkQuotePage=controller.getContactRecord();
            
            System.assertEquals(null,MathworkQuotePage);

            Test.stopTest();
        }
    }
    
    private static Account createDummyAccountWithCompleteData(){

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
        accObj.CDS_Account_Id__c='C12345';


        insert accObj;

        return accObj;
    }    

 
    private static Account createDummyAccountWithInCompleteData(){

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

        return accObj;
    }    

}