/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   21 October 2014, Last Modified: 21 October 2014
 *@description:     This is a test class for AccountViewLicenseController class
 */
@isTest
public with sharing class AccountViewLicenseControllerTest  {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
     
/***
    @ name    accountRelatedLicenseAndProductTest
    @ date    10.Oct.2014
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that it  will show all the Liceneses related to the Account record. 
     ***/
    private static testMethod void accountRelatedLicenseAndProductTest() {
   
    
        custsettbuild.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
       
        List<Account> accLst =new List<Account>();
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
       
        custsettbuild.buildIntegrationSetting();
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        System.runAs(usr){
        
         for(Integer i=0;i<3;i++){
           Account accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCity ='Rio De Janeiro';
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';
            accObj.BillingPostalCode = '1111';
            accObj.BillingStreet = 'aa street';
            accObj.Siebel_Account_Id__c='1-G8I9'+i;
            accLst.add(accObj);
        }

            insert accLst;
            System.AssertEquals(accLst.size(),3);
            //set current page 
            PageReference acctPage= Page.AccountViewLicense;
            Test.setCurrentPage(acctPage);

            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(accLst[1]);
            AccountViewLicenseController controller = new AccountViewLicenseController(standardCtrlCon);

            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.
            MultiStaticResourceCalloutMock multimockgetLicense= new MultiStaticResourceCalloutMock();           
            multimockgetLicense.setStaticResource(getSetLicense.LicenseMWUrl__c+'?accountId='+ accLst[1].Siebel_Account_Id__c, 'mockResponseTestLicense');
            multimockgetLicense.setStatusCode(200);
            multimockgetLicense.setHeader('Content-Type', 'application/json');  
             
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetLicense);
            controller.getLicenseOfRelatedAccount();
            
            controller.setLicenseid='123456';
            controller.showRelatedProducts();
            system.assert(controller.LicenseBeanLst.size()!=null);
            system.assert(controller.SelectedLicenseBeanLst.size()!=null);
            controller.LicenseBeanLst.clear();
            System.assert(controller.LicenseBeanLst!=null);
            ApexPages.CurrentPage().getParameters().put(controller.licenseJsonString,'NotFound');
           
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