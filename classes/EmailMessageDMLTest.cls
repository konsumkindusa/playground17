/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 11 June 2013, Last Modified: 22 October 2013
* @description test class for testing all functionality on EmailMessageDML class
*/ 
@isTest
private class EmailMessageDMLTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 11 June 2013, Last Modified: 22 October 2013
    * @description test method for testing closing of open activity related to email and case 
    */
    static testMethod void testCloseActivity() {
        
        CaseTriggerHandler cseTriggHandler = new CaseTriggerHandler();
        cseTriggHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create Test user
        User usr = TestDataBuilder.buildTestUser(0);
        usr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert usr;
        
        //Create Test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create Test Task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test inbound');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //Create Test Emails
        list <EmailMessage> emlist = new list <EmailMessage>();
        for (Integer i=0; i<20; i++){
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(i, tsk.Id, cse.Id, '0');
            emlist.add(em);
        }
        insert emlist;
        
        Task Uptsk = new Task(); 
        
        Test.startTest();
        
            //Create Test Emails
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(0, tsk.Id, cse.Id, '3');
            insert em;
            
            //Retrieve updated Task
            Uptsk = [Select Id, Status From Task Where id = : tsk.Id];
            
        Test.stopTest();
        
        //Verify that Activity is closed
        system.assertEquals(Uptsk.Status, 'Completed');
    }
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 16 July 2013, Last Modified: 22 October 2013
    * @description test method to test the Approcval Process on "Draft" emails.
    */
    static testMethod void TestApprovalProccesDraftMail() {
        
        CaseTriggerHandler cseTriggHandler = new CaseTriggerHandler();
        cseTriggHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create Test user
        User usr = TestDataBuilder.buildTestUser(0);
        usr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert usr;
        
        //Create Test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create Test Task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test inbound');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //Create Test Emails
        list <EmailMessage> emlist = new list <EmailMessage>();
        //for (Integer i=0; i<20; i++){
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
            em.Status = '5';
            em.Subject = 'email subject for email no.'+1;
            emlist.add(em);
        //}
        insert emlist;
        
        list <EmailMessage> emInsertedList = new list <EmailMessage>();
        emInsertedList = [SELECT id FROM EmailMessage];
        Test.startTest();
            integer i = 0;
            for(emailMessage emn: emInsertedList){
                i++;
                emn.Subject = 'updated email subject for email no.'+i;
            }
            update emlist;
        Test.stopTest();

    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 16 July 2013, Last Modified: 22 October 2013
    * @description test method to test the emails that were sent for approval.
    */
    static testMethod void TestApprovalProccesSentForApproval() {
        
        CaseTriggerHandler cseTriggHandler = new CaseTriggerHandler();
        cseTriggHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create Test user
        User usr = TestDataBuilder.buildTestUser(0);
        usr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert usr;
        
        //Create Test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create Test Task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test inbound');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //Create Test Emails
        list <EmailMessage> emlist = new list <EmailMessage>();
        //for (Integer i=0; i<20; i++){
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
            em.Status = '5';
            em.Subject = 'email subject for email no.'+1;
            emlist.add(em);
        //}
        insert emlist;
        
        
        Test.startTest();
            list <EmailMessage> emInsertedList = new list <EmailMessage>();
            emInsertedList = [SELECT id FROM EmailMessage];
            
            List<Approval.ProcessSubmitRequest> approvalReqList=new List<Approval.ProcessSubmitRequest>();

            //Mock sent for approval process
            for(emailMessage emn: emInsertedList){
                // create the new approval request to submit    
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();   
                req.setComments('Submitted for approval. Please approve.');
                req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                req.setObjectId(emn.Id);
                approvalReqList.add(req);
            }
            
            List<Approval.ProcessResult> resultList = Approval.process(approvalReqList);  
            
            
            
        Test.stopTest();

    }
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 16 July 2013, Last Modified: 22 October 2013
    * @description test method to test the emails that were sent for approval and have been approved.
    */
    static testMethod void TestApprovalProccesEmailApproved() {
        
        CaseTriggerHandler cseTriggHandler = new CaseTriggerHandler();
        cseTriggHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create Test user
        User usr = TestDataBuilder.buildTestUser(0);
        usr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert usr;
        
        //Create Test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create Test Task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test inbound');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //Create Test Emails
        list <EmailMessage> emlist = new list <EmailMessage>();
        //for (Integer i=0; i<20; i++){
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
            em.Status = '5';
            em.Subject = 'email subject for email no.'+1;
            emlist.add(em);
        //}
        insert emlist;
        
        
        Test.startTest();
            list <EmailMessage> emInsertedList = new list <EmailMessage>();
            emInsertedList = [SELECT id FROM EmailMessage];
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req1.setObjectId(emInsertedList[0].id);

            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);

            // Verify the result
            System.assert(result.isSuccess());

            System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());

            // Approve the submitted request
            // First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkitemIds();

            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));

            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            
        Test.stopTest();

    }
    
    
     /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 16 July 2013, Last Modified: 22 October 2013
    * @description test method to test the emails that were sent for approval and have been rejected.
    */
    static testMethod void TestApprovalProccesEmailRejected() {
        
        CaseTriggerHandler cseTriggHandler = new CaseTriggerHandler();
        cseTriggHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create Test user
        User usr = TestDataBuilder.buildTestUser(0);
        usr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert usr;
        
        //Create Test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create Test Task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test inbound');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //Create Test Emails
        list <EmailMessage> emlist = new list <EmailMessage>();
        //for (Integer i=0; i<20; i++){
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(1, tsk.Id, cse.Id, '0');
            em.Status = '5';
            em.Subject = 'email subject for email no.'+1;
            emlist.add(em);
        //}
        insert emlist;
        
        
        Test.startTest();
            list <EmailMessage> emInsertedList = new list <EmailMessage>();
            emInsertedList = [SELECT id FROM EmailMessage];
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req1.setObjectId(emInsertedList[0].id);

            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);

            // Verify the result
            System.assert(result.isSuccess());

            System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());

            // Approve the submitted request
            // First, get the ID of the newly created item
            List<Id> newWorkItemIds = result.getNewWorkitemIds();

            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Reject');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));

            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            
        Test.stopTest();

    }
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 16 July 2013, Last Modified: 22 October 2013
    * @description test method for testing closing of open activity related to email and case 
    */
    static testMethod void testCloseActivity2() {
        
        CaseTriggerHandler cseTriggHandler = new CaseTriggerHandler();
        cseTriggHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create Test user
        User usr = TestDataBuilder.buildTestUser(0);
        usr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert usr;
        
        //Create Test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create Test Task
        Task tsk = TestDataBuilder.buildTestTask(UserInfo.getUserId(), 'Not Started', 'Email', 'test inbound');
        tsk.WhatId = cse.Id;
        insert tsk;
        
        //get Reference Organization ID
        String orgID = Userinfo.getOrganizationId();
        String reforgID = 'ref:_'+orgID.substring(0,5) + orgID.substring(11,15);
        
        
        
        
        //Create Test Emails
        list <EmailMessage> emlist = new list <EmailMessage>();
        for (Integer i=0; i<20; i++){
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(i, tsk.Id, cse.Id, '0');
            em.TextBody = 'test body  '+ reforgID+'._'+String.valueof(em.ParentId).substring(0, 5) + String.valueof(em.ParentId).substring(10,15)+':ref';
            emlist.add(em);
        }
        insert emlist;
        
        Task Uptsk = new Task(); 
        
        Test.startTest();
        
            //Create Test Emails
            EmailMessage em = TestDataBuilder.buildTestEmailMessage(0, tsk.Id, cse.Id, '3');
            insert em;
            
            //Retrieve updated Task
            Uptsk = [Select Id, Status From Task Where id = : tsk.Id];
            
        Test.stopTest();
        
        //Verify that Activity is closed
        system.assertEquals(Uptsk.Status, 'Completed');
    }
}