/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 09 October 2013, Last Modified: 22 October 2013
* @description test class for cp_Case_ControllerExtension
* @lastModifiedBy:Archana - Cloud Sherpas/Mathworks  
*/ 
@isTest
private class cp_CaseControllerExtensionTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    static testMethod void testCaseDetail() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@test.com';
        insert con;
        
        //create test contact2
        Contact con2 = TestDataBuilder.buildTestContact(2, UserInfo.getUserId(), acc.Id);
        con.Email = 'test2@test.com';
        insert con2;
        
        //create test user
        User usr = TestDataBuilder.buildTestUser(1);
        usr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        //Modified by:Archana Lohar/Mathworks-Cloudsherpas
        //Changed FederationIdentifier as it was already exists for this organization
        usr.FederationIdentifier = '123456789';
        usr.ContactId = con.Id;
        insert usr;
        
        //create test case 
        Case cse = TestDataBuilder.buildTestCase('Open');
        cse.AccountId = acc.Id;
        cse.ContactId = con.Id;
        insert cse;
        
        //create test task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test email task');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //create test emailmessage
        EmailMessage emsg = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
        emsg.ToAddress = 'test@test.com';
        emsg.FromAddress = 'test@test.com';
        insert emsg;
        
        //create attachment
        Attachment att = new Attachment();
        att.Body = Blob.valueof('test');
        att.Name = 'test.txt';
        att.ContentType = 'text/plain';
        att.ParentId = cse.Id;
        insert att;
        
        //create case comment
        CaseComment csecom = new CaseComment();
        csecom.CommentBody = 'test comment';
        csecom.ParentId = cse.Id;
        csecom.IsPublished = true;
        insert csecom;
        
        Test.startTest();
        //run as test user
        system.runAs(usr){
        
            //set current page and controller
            Pagereference pref = Page.cp_case_detail;
            pref.getParameters().put('Id', cse.Id);
            Test.setCurrentPage(pref);
			pref.getParameters().put('cc', 'jp');//HW
            Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
            cp_CaseControllerExtension cpcsex = new cp_CaseControllerExtension(stdctlr);
            
            cpcsex.createComment();
            cpcsex.cancel();
            cpcsex.attachfile();
            cpcsex.edit();
            cpcsex.save();
            cpcsex.getAllCaseActivity();
            cpcsex.getAllCaseActivities();
            cpcsex.getCaseOpenActivities();
            cpcsex.getCaseActivityHistory();
            cpcsex.getCase();
            cpcsex.getCaseAttachments();
            cpcsex.getCaseComments();
            cpcsex.getCaseEmails();
            cpcsex.getCaseObj();
            
            cpcsex.setUrl();
            cpcsex.newcase();
            
            cpcsex.closecasePage();
        }
        Test.stopTest();
        
    }
    
    static testmethod void testCaseClose(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@test.com';
        insert con;
        
        //create test case 
        Case cse = TestDataBuilder.buildTestCase('Open');
        cse.AccountId = acc.Id;
        cse.ContactId = con.Id;
        insert cse;
        
        Test.startTest();
            //set current page and controller
            Pagereference pref = Page.cp_case_close;
            pref.getParameters().put('Id', cse.Id);
            Test.setCurrentPage(pref);
            Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
            cp_CaseControllerExtension cpcsex = new cp_CaseControllerExtension(stdctlr);
            cpcsex.caseclosecomment = 'Test Close Comment';
            cpcsex.closecasecancel();
            cpcsex.closeCase();
            
            Case caseClose = [SELECT Id, Status FROM Case WHERE Id =:cse.Id];
            
            //Check if the case status is changed to close or not.
            System.assertEquals(caseClose.Status, 'Closed', True);
            
        Test.stopTest();
        
    }
    
    static testMethod void testCaseDetailMiscExceptions() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        Test.startTest();
            cp_CaseControllerExtension cpcsex = new cp_CaseControllerExtension();
            cpcsex.getCaseEmails();
            cpcsex.getCaseComments();
        Test.stopTest();
        
    }
    
    /*
    Test method for CaseActivityInfo 
    */ 

    static testMethod void testCaseActivityInfo() {
    
    //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test user
        User usr = TestDataBuilder.buildTestUser(1);
        
        //create test case 
        Case cse = TestDataBuilder.buildTestCase('Open');
        
        //create test task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test email task');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        CaseActivityInfo infoObj= new CaseActivityInfo(tsk.id,tsk.subject,tsk.type,tsk.createddate);
         }
        
}