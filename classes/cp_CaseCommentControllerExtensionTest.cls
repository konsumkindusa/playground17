/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 09 October 0213, Last Modified: 22 October 2013
* @description test class for CaseCommentControllerExtension
*/ 
@isTest
private class cp_CaseCommentControllerExtensionTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    static testMethod void testCaseCommentOpenCase() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test case 
        Case cse = TestDataBuilder.buildTestCase('Open');
        cse.SubStatus__c = 'Waiting for Customer';
        insert cse;
        
        //set current page and controller
        Pagereference pref = Page.cp_create_casecomment;
        pref.getParameters().put('ParentId', cse.Id);
        pref.getParameters().put('cc', 'jp');//HW
        Test.setCurrentPage(pref);
        Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
        cp_CaseCommentControllerExtension cpccex = new cp_CaseCommentControllerExtension(stdctlr);
        
        cpccex.getCaseObj();
        cpccex.cancel();
        cpccex.getCCObj();
        
        Test.startTest();
            //populate Case Comment
            cpccex.ccObj.CommentBody = 'test comment';
            //save Case Comment
            cpccex.save();
        Test.stopTest();
        
        //Retrieve updated Case
        Case upCse = [Select Id, SubStatus__c,OwnerId, Owner.Type From Case Where Id = : cse.Id];
        System.Debug('Owner Id::'+upCse.OwnerId);
        System.Debug('Owner type::'+upCse.Owner.Type);
        //Retrieve created Case Comment
        CaseComment csecomment = [Select Id, CommentBody, IsPublished From CaseComment Where ParentId = : cse.Id];
        
        //Retrieve created Task
        list <Task> tsk = [Select Id, WhatId From Task Where WhatId = : cse.Id];
        
        //Verify that a comment has been added to the Case
        system.assertEquals(csecomment.CommentBody, 'test comment');
        system.assertEquals(csecomment.IsPublished, true);
        //Verify that SubStatus is changed to In Progress
        system.assertEquals(upCse.SubStatus__c,'In Progress');
        //Verify that a task has been created for the Case
        system.assertEquals(tsk.size(),1);
        
    }
    
    static testMethod void testCaseCommentClosedCase() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Closed');
        insert cse;
        
        //set current page and controller
        Pagereference pref = Page.cp_create_casecomment;
        pref.getParameters().put('ParentId', cse.Id);
        Test.setCurrentPage(pref);
        Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
        cp_CaseCommentControllerExtension cpccex = new cp_CaseCommentControllerExtension(stdctlr);
        cpccex.parentId = cse.Id;
        
        cpccex.getCaseObj();
        cpccex.cancel();
        cpccex.getCCObj();
        Test.startTest();
            //populate Case Comment
            cpccex.ccObj.CommentBody = 'test comment';
            //save Case Comment
            cpccex.save();
        Test.stopTest();
        
        //Retrieve created Case Comment
        CaseComment csecomment = [Select Id, CommentBody, IsPublished From CaseComment Where ParentId = : cse.Id];
        
        //Retrieve created Task
        list <Task> tsk = [Select Id, WhatId From Task Where WhatId = : cse.Id];
        
        //Verify that a comment has been added to the Case
        system.assertEquals(csecomment.CommentBody, 'test comment');
        system.assertEquals(csecomment.IsPublished, true);
        //Verify that a task has been created for the Case
        system.assertEquals(tsk.size(),1);
        
    }
    
    static testMethod void testCaseCommentMisc() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test case
        Case cse = TestDataBuilder.buildTestCase('Closed');
        insert cse;
        
        //set current page and controller
        Pagereference pref = Page.cp_create_casecomment;
        Test.setCurrentPage(pref);
        Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
        cp_CaseCommentControllerExtension cpccex = new cp_CaseCommentControllerExtension();
        cpccex.parentId = cse.Id;
        cpccex.caseObj = null;
        cpccex.getCaseObj();
        
    }
}