/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 24 July 2013, Last MOdified: 22 October 2013
* @description test class to test the validation rule "License_Number_Non_Number"
*/ 
@isTest
private class LicenseNumberNonNumberValidationRuleTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 05 June 2013
    * @description test method to test blank liceses number
    */
    static testMethod void BlankLicenseTest() {
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        List<Case> InsCse = new List<Case>(); 
                
        Test.startTest();
            //create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Product_Base_Code__c = 'ML';
            cse.License__c = '';
            insert cse;
            
            //Retrieve inserted case 
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case];
        Test.stopTest();
        
        //Verify that a Case has been inserted
        system.assertEquals(InsCse.size(),1);
        //Assertions can not be made for verifying On Support fields because of asynchronous call (CheckOnSupport)
        
    }
    
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 05 June 2013, Last Modified: 22 October 2013
    * @description test method to test license numbers containing numbers.
    */
    static testMethod void AllNumberLicenseTest() {
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        List<Case> InsCse = new List<Case>(); 
        
        Test.startTest();
            //create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Product_Base_Code__c = 'ML';
            cse.License__c = '02134569876';
            insert cse;
            
            //Retrieve inserted case 
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case];
        Test.stopTest();
        
        //Verify that a Case has been inserted
        system.assertEquals(InsCse.size(),1);
        //Assertions can not be made for verifying On Support fields because of asynchronous call (CheckOnSupport)
        
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 05 June 2013, Last Modified: 22 October 2013
    * @description test method to test license numbers having the word DEMO or STUDENT only.
    */
    static testMethod void LicenseWithDemoOrStudentWordTest() {
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        
        List<Case> InsCse = new List<Case>(); 
        List<Case> InsCseDEMO = new List<Case>(); 
        List<Case> InsCseSTUDENT = new List<Case>(); 
        
        
        Test.startTest();
            //create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Product_Base_Code__c = 'ML';
            cse.License__c = 'DEMO';
            insert cse;
            
            Case cse2 = new Case();
            cse2.status = 'Open';
            cse2.Product_Base_Code__c = 'ML';
            cse2.License__c = 'STUDENT';
            insert cse2;
            
            //Retrieve inserted case 
            InsCse = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case];
            InsCseDEMO = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case WHERE License__c ='DEMO'];
            InsCseSTUDENT = [Select Id, Account.Name, Support_Status__c, Support_Reason__c, On_Support__c, License_Account__c From Case WHERE License__c = 'STUDENT'];
        Test.stopTest();
        
        //Verify that a Case has been inserted
        system.assertEquals(InsCse.size(),2);
         system.assertEquals(InsCseDEMO.size(),1);
          system.assertEquals(InsCseSTUDENT.size(),1);
        //Assertions can not be made for verifying On Support fields because of asynchronous call (CheckOnSupport)
        
    }
   
}