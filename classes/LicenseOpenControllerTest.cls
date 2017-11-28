/**
*@author Original: Faina Gorelik - Mathworks, Last Modified: 
*@date Original:   28 September 2016, Last Modified: 
*@description:     This is a test class for LicenseOpenController class
*/
@isTest
public class LicenseOpenControllerTest {
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
* test open license url for contact without mw account id
*/
    private static testMethod void OpenLicenseURLContactWithoutMWAccountId(){
        csb.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        System.runAs(usr){
            
            Account acc = TestDataBuilder.buildTestAccount(1,UserInfo.getUserId());
            insert acc;
            
            Contact cont= TestDataBuilder.buildTestContact(1,UserInfo.getUserId(),acc.id);
            cont.MathWorks_Account_ID__c = '';
            insert cont;
            
            //set current page 
            PageReference licenseopen = Page.LicenseOpenContact;
            licenseopen.getParameters().put('id',cont.id);
            Test.setCurrentPage(licenseopen);
            ApexPages.StandardController openlicensecontr = new ApexPages.StandardController(cont);
            LicenseOpenController  controller =  new LicenseOpenController(openlicensecontr);
            
            test.startTest();  
            PageReference OpenLicenseLink = controller.redirectToLicenseApp();
            System.assertEquals(null, OpenLicenseLink);
            test.stopTest();
        }
        
    }
    /* *
*test open url from account without cds account id
*/
    private static testMethod void OpenLicenseUrlNoCDSAccountId(){
        csb.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr; 
        System.runAs(usr){
            Account acc = TestDataBuilder.buildTestAccount(1,UserInfo.getUserId());
            insert acc;  
            PageReference licenseopen = Page.LicenseOpenAccount;
            licenseopen.getParameters().put('id',acc.id);
            Test.setCurrentPage(licenseopen);
            ApexPages.StandardController openlicensecontr = new ApexPages.StandardController(acc);
            LicenseOpenController  controller =  new LicenseOpenController(openlicensecontr);
            
            test.startTest();
            PageReference OpenLicenseLink = controller.redirectAccountToLicenseApp();
            System.assertEquals(null, OpenLicenseLink);
            test.stopTest();
        }   
    }     
    /* *
*test open url from account with cds account id
*/  
    private static testMethod void OpenLicenseUrlAccount(){
        csb.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr; 
        System.runAs(usr){
            Account acc = TestDataBuilder.buildTestAccount(1,UserInfo.getUserId());
            acc.CDS_Account_Id__c = 'c999999';
            insert acc;  
            PageReference licenseopen = Page.LicenseOpenAccount;
            licenseopen.getParameters().put('id',acc.id);
            Test.setCurrentPage(licenseopen);
            ApexPages.StandardController openlicensecontr = new ApexPages.StandardController(acc);
            LicenseOpenController  controller =  new LicenseOpenController(openlicensecontr);
            test.startTest();
            PageReference OpenLicenseLink = controller.redirectAccountToLicenseApp();
            System.assertNotEquals(null, OpenLicenseLink);
            test.stopTest();
        }   
    }
    
    /**
test open license url from  contact with mw account id  
*/
    private static testMethod void OpenLicenseUrl(){
        csb.buildLicensesIntegrationSetting();
        LicenseIntegrationSetting__c getSetLicense = LicenseIntegrationSetting__c.getInstance();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        System.runAs(usr){
            
            Account acc = TestDataBuilder.buildTestAccount(1,UserInfo.getUserId());
            insert acc;
            Contact cont= TestDataBuilder.buildTestContact(1,UserInfo.getUserId(),acc.id);
            insert cont;
            
            //set current page 
            PageReference licenseopen = Page.LicenseOpenContact;
            licenseopen.getParameters().put('id',cont.id);
            Test.setCurrentPage(licenseopen);
            ApexPages.StandardController openlicensecontr = new ApexPages.StandardController(cont);
            LicenseOpenController  controller =  new LicenseOpenController(openlicensecontr);
            test.startTest();
            PageReference OpenLicenseLink = controller.redirectToLicenseApp();
            System.assertNotEquals(null, OpenLicenseLink);
            test.stopTest();
        }
        
    }  
    
    
}