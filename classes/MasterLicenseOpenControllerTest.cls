/**
*@author Original: Faina Gorelik - Mathworks, Last Modified: 
*@date Original:   11 October 2016, Last Modified: 
*@description:     This is a test class for MasterLicenseOpenController class
*/
@isTest
public class MasterLicenseOpenControllerTest {
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
/* test open master license url for opportunity with master license id*/
    private static testMethod void OpenMasterLicenseURLOpptyWithMasterLicenseId(){
        csb.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Sales Manager';
        insert usr;
        System.runAs(usr){
            Account acc = TestDataBuilder.buildTestAccount(1,UserInfo.getUserId());
            acc.BillingCountryCode = 'US';
            acc.BillingCountry = 'United States';
            acc.BillingStateCode = 'NY';
            acc.BillingState = 'New York';
            insert acc;
            
            Contact cont= TestDataBuilder.buildTestContact(1,UserInfo.getUserId(),acc.id);
            cont.Accountid = acc.id;
            insert cont;
            
            Opportunity opt = TestDataBuilder.buildTestOpportunity(1);
            opt.Name = 'master license id Open controller';
            opt.amount=20;
            opt.AccountId = acc.id;
            opt.CurrencyIsoCode='USD';
            opt.Master_License_Id__c ='91';
            insert opt;
            
            PageReference masterlicenseopen = Page.OpenOpportunityMasterLicense;
            masterlicenseopen.getParameters().put('id',opt.id);
            Test.setCurrentPage(masterlicenseopen);
            ApexPages.StandardController openlicensecontr = new ApexPages.StandardController(opt);
            MasterLicenseOpenController  controller =  new MasterLicenseOpenController(openlicensecontr);
            
            test.startTest();  
            PageReference OpenLicenseLink = controller.redirectToMasterLicenseApp();
            System.assertNotEquals(null, OpenLicenseLink);
            test.stopTest();
            
        }
        
    }  
    
    
/* test open master license url for opportunity without master license id*/
    private static testMethod void OpenMasterLicenseURLOpptyWithoutMasterLicenseID(){
        csb.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Sales Manager';
        insert usr;
        
        System.runAs(usr){
            Account acc = TestDataBuilder.buildTestAccount(1,UserInfo.getUserId());
            acc.BillingCountryCode = 'US';
            acc.BillingCountry = 'United States';
            acc.BillingStateCode = 'NY';
            acc.BillingState = 'New York';
            insert acc;
            
            Contact cont= TestDataBuilder.buildTestContact(1,UserInfo.getUserId(),acc.id);
            cont.Accountid = acc.id;
            insert cont;
            
            Opportunity opt = TestDataBuilder.buildTestOpportunity(1);
            opt.Name = 'master license Open controller';
            opt.amount=20;
            opt.AccountId = acc.id;
            opt.CurrencyIsoCode='USD';
            insert opt;
            
            PageReference masterlicenseopen = Page.OpenOpportunityMasterLicense;
            masterlicenseopen.getParameters().put('id',opt.id);
            Test.setCurrentPage(masterlicenseopen);
            ApexPages.StandardController openlicensecontr = new ApexPages.StandardController(opt);
            MasterLicenseOpenController  controller =  new MasterLicenseOpenController(openlicensecontr);
            
            test.startTest();  
            PageReference OpenLicenseLink = controller.redirectToMasterLicenseApp();
            System.assertEquals(null, OpenLicenseLink);
            test.stopTest();
            
        }
        
    }
}