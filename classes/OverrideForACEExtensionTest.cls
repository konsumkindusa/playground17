/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 07 May 2013, Last Modified: 22 October 2013
* @description test class for testing functionalities of OverrideForACEExtension
*/ 
@isTest
private class OverrideForACEExtensionTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 07 May 2013, Last Modified: 22 October 2013
    * @description test method for testing opening of ACE Edit link on Account Edit
    */ 
    
    static testMethod void testOpenACEonAccountEdit() {
        
        //Set Org Defaults for General Setting custom setting
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Creat Test User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        //Create Test Account
        Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
        acc.Siebel_Account_Id__c = '1-XXYY';
        insert acc;
        
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        OverrideForACEExtension ofe = new OverrideForACEExtension(sc);
        
        Pagereference pref = Page.AccountEditOverride;
        
        test.startTest();
            //Set page to AccountEditOverride - simulates clicking of Edit button on Account record
            Test.setCurrentPage(pref);
            ofe.ACEonEdit();
        test.stopTest();
        
        //Verify ACE Edit link has been opened
        system.assertEquals(ofe.URLpath.contains('/ace/openAccount.do?objectId='), true);
        
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 07 May 2013, Last Modified: 22 October 2013
    * @description test method for testing opening of ACE Edit link on Contact Edit
    */ 
    
    static testMethod void testOpenACEonContactEdit() {
        
        //Set Org Defaults for General Setting custom setting
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Creat Test User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        //Create Test Account
        Account acc = TestDataBuilder.buildTestAccount(1, usr.Id);
        acc.Siebel_Account_Id__c = '1-XXYY';
        insert acc;
        
        //Create Test Contact
        Contact con = TestDataBuilder.buildTestContact(1, usr.Id, acc.Id);
        con.Siebel_Contact_Id__c = '1-YYXX';
        insert con;
        
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        OverrideForACEExtension ofe = new OverrideForACEExtension(sc);
        
        Pagereference pref = Page.AccountEditOverride;
        
        test.startTest();
            //Set page to AccountEditOverride - simulates clicking of Edit button on Contact record
            Test.setCurrentPage(pref);
            ofe.ACEonEdit();
        test.stopTest();
        
        //Verify ACE Edit link has been opened
        system.assertEquals(ofe.URLpath.contains('/ace/openContact.do?objectId='), true);
        
    }
    
        
    /**
    * @author Original: Robbie Dell Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 08 May 2013, Last Modified: 22 October 2013
    * @description test method for testing ACE tool pop up, upon click New Account button
    */ 
    static testMethod void testOpenACEonAccountNew(){
        //Set Org Defaults for General Setting custom setting
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create a Test User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        Account acct = new Account();
        
        ApexPages.StandardController sc = new ApexPages.standardController(acct);
        OverrideForACEExtension ofe = new OverrideForACEExtension(sc);
        
        test.startTest();
            ofe.ACEonNew();
        test.stoptest();
    }
    
    /**
    * @author Original: Robbie Dell Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 08 May 2013, Last Modified: 22 October 2013
    * @description test method for testing ACE tool pop up, upon click New Contact button
    */ 
    static testMethod void testOpenACEonContactNew(){
        //Set Org Defaults for General Setting custom setting
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create a Test User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        Contact cont = new Contact();
        
        ApexPages.StandardController sc = new ApexPages.standardController(cont);
        OverrideForACEExtension ofe = new OverrideForACEExtension(sc);
        
        test.startTest();
            ofe.ACEonNew();
        test.stoptest();
    }
}