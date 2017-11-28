/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   21 October 2014, Last Modified: 21 October 2014
 *@description:     This is a test class for ContactViewLicenseController class
 */
@isTest
public with sharing class ContactViewLicenseControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    /*
    @ name    contactRelatedLicenseAndProductTest
    @ date    10.Oct.2014
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that it  will show all the Liceneses related to the contact record. 
     */
    private static testMethod void contactRelatedLicenseAndProductTest() {
    
        custsettbuild.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
       
        system.debug(getSetLicense +'getSetLicense getSetLicense getSetLicense ');
           
        List<Contact> conLst =new List<Contact>();
        List<Account> accLst =new List<Account>();
    
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

       
        custsettbuild.buildIntegrationSetting();
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();

        System.runAs(usr){
        
        
            Account accObj = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
            accObj.BillingCity ='Rio De Janeiro';
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';
            accObj.BillingPostalCode = '1111';
            accObj.BillingStreet = 'aa street';
            insert accObj;
            
            
            //create Contact record from TestDataBuilder.
            
            Contact contL = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accObj.id);
            contL.MailingCity = 'Bombay';
            contL.MailingCountry = 'India';
            contL.MailingCountryCode = 'IN';
            contL.MailingPostalCode ='400011';
            contL.MailingState ='Maharashtra';
            contL.MailingStateCode = 'MH';
            contL.MailingStreet = 'MG Street';
            contL.County_Local__c = 'abc';
            contL.email = 'john@gmail.com';
            contL.MathWorks_Account_ID__c='498836';
            contL.Siebel_Contact_Id__c = '1-1JAHOZ';
            
            insert contL;
            
           
            //set current page 
            PageReference contPage= Page.ContactViewLicenses;
            Test.setCurrentPage(contPage);

            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(contL);
            ContactViewLicenseController controller = new ContactViewLicenseController(standardCtrlCon);

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            
            
            MultiStaticResourceCalloutMock multimockgetLicense= new MultiStaticResourceCalloutMock();
            System.debug(getSetLicense.LicenseMWUrl__c+'?contactId='+ contL.Siebel_Contact_Id__c+'test!!!!!!!1');
            multimockgetLicense.setStaticResource(getSetLicense.LicenseMWUrl__c+'?contactId='+ contL.Siebel_Contact_Id__c, 'mockResponseTestLicense');
            multimockgetLicense.setStatusCode(200);
            multimockgetLicense.setHeader('Content-Type', 'application/json');  
             
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetLicense);
            controller.getLicenseOfRelatedContact();
            controller.setLicenseid='123456';
            controller.showRelatedProducts();
            system.assert(controller.licenseJsonString!=null);
            system.debug('****controller.licenseJsonString***'+controller.licenseJsonString);
            system.assert(controller.LicenseBeanLst.size()!=null);
            system.assert(controller.SelectedLicenseBeanLst.size()!=null);
            
            controller.FirstPage();
            controller.previous();
            controller.next();
            controller.LastPage();
            controller.getMapKeyFound();
            controller.getprevOfLicense();
            controller.getnxtOfLicense();
            controller.getCurrentPageNumber();
            controller.getTotalPages();
            
            Test.stopTest();

        }    
    }
}