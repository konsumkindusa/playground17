/**
* @author Original: Jaspreet - Mathworks, 
* @Last Modified: Jaspreet Monga - Mathworks  
* @description this class is used to test CustomJithandler
*/

@isTest(seeAllData = true)
private class CustomJITClassTest {
static testMethod void testCreateUser() {
    
    
    CustomJITClass  jithandler = new CustomJITClass();
  
    Map<String, String> attributes = new Map<String,String>();
   // attributes.put('EmailAddress','shicy.tulip@gmail.com.mwtest'); 
    attributes.put('EmailAddress','sdfdfnded@uw.edu.mwtest'); 
    
    Id samlID = Label.SamlID;
    Id portalId = Label.portalIdFor;
    String federationIdentifier = '34534553';
    String assertion = 'wefrsdfsdfdsf';
    
    // Use MultiStaticResourceCalloutMock to
    // specify fake response for a certain endpoint and 
    // include response body in a static resource.    
       MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
       mock.setStaticResource('https://sf-ext-dev3.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
       mock.setStaticResource(
                    'https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=sdfdfnded@uw.edu.mwtest.mwtest&X_MW_WS_securityToken=TestTokenValue', 'contactJSONforTestClass');
       
       //mock responses for UAT. As the seeAlldata is set to true on the test, it is using the base url for integration using env specific ones than from test data.
       mock.setStaticResource(
                    'https://sf-ext-stage.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=sdfdfnded@uw.edu.mwtest.mwtest&X_MW_WS_securityToken=TestTokenValue', 'contactJSONforTestClass');
       mock.setStaticResource('https://sf-ext-stage.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
      
      //mock responses for PROD. As the seeAlldata is set to true on the test, it is using the base url for integration using env specific ones than from test data.
       mock.setStaticResource('https://sf-ext.mathworks.com/businessprocesstokenws/services/BusinessProcessTokenService','mockBusinessProcessTokenServiceResponse');
       mock.setStaticResource(
                    'https://sf-ext.mathworks.com/customerDataStoreWS/rest/v2/contacts?recordType=CRM&email=sdfdfnded@uw.edu.mwtest&X_MW_WS_securityToken=TestTokenValue', 'contactJSONforTestClass');
       
       
       mock.setStatusCode(200);
       mock.setHeader('Content-Type', 'application/json');
        
    
    Test.StartTest();
    Test.setMock(HttpCalloutMock.class, mock);        
    
        User cpuser0 = jithandler.createUser(samlID ,null,portalId ,federationIdentifier ,attributes,assertion);
   Test.StopTest();
   
   System.assert(cpuser0.IsActive ==true);
   
}
   
}