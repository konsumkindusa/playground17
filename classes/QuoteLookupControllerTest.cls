/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 17 Feb 2015, Last Modified: 17 Feb 2015
 *@description This is controller for QuoteLookup Page
 */
@isTest
public with sharing class QuoteLookupControllerTest {

	//re-create custom setting test records when running the test class
	static CustomSettingsBuilder csb = new CustomSettingsBuilder();

	public static Account accObj {get; set;}
	public static Contact conObj {get; set;}

	public static QuoteIntegrationSettings__c settings;

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
    @ name    viewQuote
    @ date    20.Feb.2015
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :Expected that contact is found in SFDC Page is redirected to Contact Details 
	 */
	private static testMethod void testViewQuote(){

		User usr = TestDataBuilder.buildTestUser(1);
		insert usr;
		
		//re-create gener2al Custom Setting
		csb.buildQuoteIntegrationSettings();
		
		csb.buildGenSetting();
        QuoteIntegrationSettings__c intsettings = QuoteIntegrationSettings__c.getInstance();

		System.runAs(usr){
			
			//set current page 
            PageReference qlpPage = Page.QuoteLookupPage;
            Test.setCurrentPage(qlpPage);
            
            Opportunity standardCtrlOpp = new Opportunity();
            
            QuoteLookupController controller = new QuoteLookupController(new ApexPages.StandardController(standardCtrlOpp));
            controller.quoteId = '4268895';
            
            
            
            MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
            
            mock.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
            mock.setStaticResource(intsettings.GQOQuoteBaseURL__c+'/'+controller.quoteId,'MockResponseQuote');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, mock); 
            //search contact 
            PageReference returnPage = controller.ViewQuote();
            PageReference returnPage2 = controller.hideQuoteDetailSection();
            
            //System.Debug('QuoteBean:'+controller.quoteObjToShow);
            //System.assert(controller.quoteObjToShow!=null);
            //System.assert(controller.quoteBeanList.size()==1);
            
            Test.stopTest();

		}

	}

}