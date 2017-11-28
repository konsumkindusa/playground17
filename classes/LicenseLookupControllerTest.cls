/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   23 Feb 2015, Last Modified: 23 Feb 2015,
 *@description:     This is a test class for LicenseLookupController class
 */
@isTest
public with sharing class LicenseLookupControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
     @testSetup static void setup() {

        //build integration settings
        String token;
        Integration_Settings__c intSett = new Integration_Settings__c();
        intSett.Name = 'MW Integrations';
        intSett.Username__c = 'Salesforce';
        intSett.Password__c = 'TestPassword123'; //do not use real passwords
        intSett.Clientname__c = 'Salesforce';
        intSett.Timeout__c = 60000;
        intSett.Endpoint__c = 'https://sf-ext-dev3.mathworks.com/';
        intSett.Locale__c = 'en_US';
        intSett.Retry_Attempts__c =3;
        intSett.Caller_ID__c ='SFDC';
        intSett.CA_Cert__c= 'SF_UAT2';
        insert intSett;


  }
    /*
    @ name    LicenseLookup
    @ date   23 Feb 2015,
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that it  will show  Liceneses and  related information.
     */
    private static testMethod void viewLicenseLookupTest() {
    
        custsettbuild.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
       
        List<Contact> conLst =new List<Contact>();
        List<Account> accLst =new List<Account>();
    
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
		 
       
        custsettbuild.buildIntegrationSetting();
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        //Inserting Bypass trigger custom setting
       // custsettbuild.buildBypassTriggerSettings();

        System.runAs(usr){
            //set current page 
            PageReference licensePage= Page.LicenseLookupPage;
            Test.setCurrentPage(licensePage);
            
            Contact contL = new Contact();

            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(contL);
            LicenseLookupController controller = new LicenseLookupController(standardCtrlCon);
			controller.licenseID = '149544';
            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            
            
            MultiStaticResourceCalloutMock multimockgetLicense= new MultiStaticResourceCalloutMock();
            multimockgetLicense.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
	        multimockgetLicense.setStaticResource(getSetLicense.LicenseMWUrl__c+'/'+controller.licenseID, 'MockResponseLicenseLookup');
            multimockgetLicense.setStatusCode(200);
            multimockgetLicense.setHeader('Content-Type', 'application/json');  
             
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetLicense);
            controller.viewLicenses();
            controller.hideLicenseDetailSection();
            Test.stopTest();

        }    
    }
}