/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 09 October 2013, Last Modified: 22 October 2013
* @description test class for EmailMessageController
*/ 
@isTest
private class cp_EmailMessageControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    static testMethod void testEmailMessage() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
		//create test case 
    	Case cse = TestDataBuilder.buildTestCase('Open');
    	cse.SubStatus__c = 'Waiting for Customer';
    	insert cse;
    	
    	//create test task
    	Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test email task');
    	tsk.WhatId = cse.Id;
    	insert tsk;
    	
		//create test emailmessage
		EmailMessage emsg = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
		insert emsg;
		
		//create attachments
		Attachment att = new Attachment();
		att.Body = Blob.valueof('test');
		att.Name = 'test.txt';
		att.ContentType = 'text/plain';
		att.ParentId = emsg.Id;
		insert att;
    	
    	Test.startTest();
	    	//set current page and controller
	    	Pagereference pref = Page.cp_case_email;
	    	pref.getParameters().put('Id', emsg.Id);
	    	Test.setCurrentPage(pref);
	    	Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(emsg);
	    	cp_EmailMessageController cpemsg = new cp_EmailMessageController(stdctlr);
	    	cpemsg.getAttachments();
    	Test.stopTest();
    	
    	//nothing to assert
    	
    }
    
    static testMethod void testEmailMessageMisc() {
        
		//re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
		
		//create test case 
    	Case cse = TestDataBuilder.buildTestCase('Open');
    	cse.SubStatus__c = 'Waiting for Customer';
    	insert cse;
    	
    	//create test task
    	Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test email task');
    	tsk.WhatId = cse.Id;
    	insert tsk;
    	
		//create test emailmessage
		EmailMessage emsg = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
		insert emsg;
		
    	Test.startTest();
	    	//set current page and controller
	    	Pagereference pref = Page.cp_case_email;
	    	pref.getParameters().put('Id', emsg.Id);
	    	Test.setCurrentPage(pref);
	    	cp_EmailMessageController cpemsg = new cp_EmailMessageController();
    	Test.stopTest();
    	
    	//nothing to assert
    	
    }
}