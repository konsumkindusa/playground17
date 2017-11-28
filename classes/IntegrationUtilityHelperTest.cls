/*
 *author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade- Cloud Sherpas/Mathworks
 *date Original: 21 Nov 2014, Last Modified: 25 Nov 2014
 *description This  is Test class for 'IntegrationUtilityHelper' class . 
 */

@isTest
public class IntegrationUtilityHelperTest {
       
     /*
      @ name    testIntegrationRec
      @ date    25 Nov .2014
      @ author  Divya Gawade
      @ param   none.
      @ return  Void. 
      @ description Method Implement test for IntegrationUtility.                              
     */

     static testMethod void testIntegrationRec() {
        
         //build integration settings
         String token;
         Integration_Settings__c intSett = new Integration_Settings__c();
         intSett.Name = 'MW Integrations';
         intSett.Username__c = 'Salesforce';
         intSett.Password__c = 'TestPassword123'; //do not use real passwords
         intSett.Clientname__c = 'Salesforce';
         intSett.Timeout__c = 60000;
         intSett.Endpoint__c = 'https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService';
         intSett.Locale__c = 'en_US';
         intSett.Retry_Attempts__c =3;
         intSett.Caller_ID__c ='SFDC';
         intSett.CA_Cert__c= 'SF_UAT2';
         insert intSett;

         IntegrationUtilityHelper intUtil = new IntegrationUtilityHelper();
         
         //build a mock callout from a static resource that has a valid test response from the business security token service
         StaticResourceCalloutMock mockToken = new StaticResourceCalloutMock();
         mockToken.setStaticResource('mockBusinessProcessTokenServiceResponse');
         mockToken.setStatusCode(200);
         mockToken.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                
         
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, mockToken );
         
         token=intUtil.getBusinessServiceToken();
            
         String callerId=intUtil.getCallerId();
         String locale=intUtil.getLocale();
         String cACertIntegration=intUtil.getCACertIntegration();
         String userName=intUtil.getUserName();
         String password=intUtil.getPassword();
         String endPoint=intUtil.getEndPoint();
         Integer callTimeout = intUtil.getTimeout();
        Test.stopTest();
         system.assertEquals('SFDC',callerId);
         system.assertEquals('en_US',locale);
         system.assertEquals('SF_UAT2',cACertIntegration);
         system.assertEquals('Salesforce',userName);
         system.assertEquals('TestPassword123', password);
         system.assertEquals('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService',endPoint);
         system.assertEquals('TestTokenValue',token);
         System.assertEquals(60000, callTimeout);         
    
    }
    
    /*
      @ name    testIntegrationRecRetry
      @ date    25 Nov .2014
      @ author  Divya Gawade
      @ param   none.
      @ return  Void. 
      @ description Method Implement test for IntegrationUtility.                              
    */ 

     static testMethod void testIntegrationRecRetry() {
                 
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
         intSett.CA_Cert__c= 'MW_SF_SALESDEV_CLIENT';
         insert intSett;

         IntegrationUtilityHelper intUtil = new IntegrationUtilityHelper();
         
         //build a mock callout from a static resource that has a valid test response from the business security token service
         StaticResourceCalloutMock mockToken = new StaticResourceCalloutMock();
         mockToken.setStaticResource('test');
         mockToken.setStatusCode(502);
         mockToken.setHeader('Content-Type', 'application/xml');
 
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, mockToken );
      
         
         token=intUtil.getBusinessServiceToken();
            
         String callerId=intUtil.getCallerId();
         String locale=intUtil.getLocale();
         String cACertIntegration=intUtil.getCACertIntegration();
         String userName=intUtil.getUserName();
         String password=intUtil.getPassword();
         String endPoint=intUtil.getEndPoint();
        
         system.assertEquals('SFDC',callerId);
         system.assertEquals('en_US',locale);
         system.assertEquals('MW_SF_SALESDEV_CLIENT',cACertIntegration);
         system.assertEquals('Salesforce',userName);
         system.assertEquals('TestPassword123', password);
         system.assertEquals('https://sf-ext-dev3.mathworks.com/',endPoint);
         system.assertEquals('SecurityTokenNotFound',token);
         Test.stopTest();
    
    }
    
}