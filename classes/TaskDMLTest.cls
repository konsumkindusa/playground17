/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks, Faina Gorelik
* @date Original: 05 June 2013, Last Modified: 22 October 2013
* @description test class for TaskDML class functionalities.
* @Revision :Archana Lohar|3 Dec 2014|Added new method TestUpdateLeadIdOnTask, Faina Gorelik 23 Nov 2015.
*/ 
@isTest
private class TaskDMLTest {
    
     //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 05 June 2013, Last Modified: 22 October 2013
    * @description test method for testing UpdateEscalatTo with Task that has no WhatID
    */ 
    static testMethod void testNewTaskWithoutWhatId(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        //Create new task without any case related to it.
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Escalation',  'No Case Test');
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        test.startTest();
            insert newTask;
        test.stopTest();
        
        List<Case> caseListAfterTaskCreation = new List<Case>();
        caseListAfterTaskCreation = [SELECT id,Escalation_to__c,IsEscalated FROM Case WHERE id = :newTask.WhatId];
        Case updatedCase = new Case();
        for(Case c: caseListAfterTaskCreation){
            updatedCase = c;
        }
        system.assertEquals(updatedCase.Escalation_to__c,null);
        system.assertEquals(updatedCase.IsEscalated,false);
        
        
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks  
    * @date Original: 05 June 2013, Last Modified: 22 October 2013
    * @description test method for testing UpdateEscalatTo with Task that has Contact WhatID
    */ 
    static testMethod void testNewTaskWithWhatIdOnContact(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
       
        
        //Cfreate a new Account.
        Account newAccount = new Account();
        newAccount = TestDataBuilder.buildTestAccount(1, newUser.Id);
        //added on newAccount to avoid error FIELD_INTEGRITY_EXCEPTION on Billing Address
            newAccount.Account_Sector__c = 'Commercial';
            newAccount.BillingCity ='Boston';
            newAccount.BillingCountry = 'United States';
            newAccount.BillingCountryCode = 'US';
            newAccount.BillingPostalCode ='400011';
            newAccount.BillingStateCode ='AK';
            newAccount.BillingState='Alaska';
            newAccount.BillingStreet = 'MG Street';
            newAccount.County__c = 'abc';
        insert newAccount;
        //Get Account Id.
        List<Account> accountList = [SELECT Id FROM Account LIMIT 1];
        id newAccountId;
        for(Account a: accountList ){
            newAccountId = a.id;
        }
        
        //Create a task which is related to an Account.
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Escalation',  'No Case Test');
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        test.startTest();
            insert newTask;
        test.stopTest();
         
        List<Case> caseListAfterTaskCreation = new List<Case>();
        caseListAfterTaskCreation = [SELECT id,Escalation_to__c,IsEscalated FROM Case WHERE id = :newTask.WhatId];
        Case updatedCase = new Case();
        for(Case c: caseListAfterTaskCreation){
            updatedCase = c;
        }
        system.assertEquals(updatedCase.Escalation_to__c,null);
        system.assertEquals(updatedCase.IsEscalated,false);
        
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 05 June 2013, Last Modified: 22 October 2013
    * @description test method for testing UpdateEscalatTo with Task that has Case WhatID
    */
    static testMethod void testNewTaskWithWhatIdOnCase(){
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
    
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
         
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Escalation',  'No Case Test');
        newTask.WhatId = newCase.Id; 
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        newtask.Type = 'Escalation';
        test.startTest();
            insert newTask;
        test.stopTest();
        
        List<Case> caseListAfterTaskCreation = new List<Case>();
        caseListAfterTaskCreation = [SELECT id,Escalation_to__c,IsEscalated FROM Case WHERE id = :newTask.WhatId];
        Case updatedCase = new Case();
        for(Case c: caseListAfterTaskCreation){
            updatedCase = c;
        }
        //verify Case's Escalate To is update with value of Task's Escalate To
        system.assertEquals(updatedCase.Escalation_to__c,'Natick EDG');
        system.assertEquals(updatedCase.IsEscalated,true);
    }
    /**
    * @author Original: Andre Calimlim 
    * @date : 10 June 2014
    * @description test method for testing updateAttemptToLeads with Task that has type Call - Outbound or Email that triggers after insert
    */
    static testMethod void testTaskAfterInsertAttemptToLeadUpdate(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        System.runas(newUser){
            //Create Lead 
            Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
            leadRec.Status = 'Open';
            insert leadRec;
            Test.startTest();
                //Create Task
                Task newTask = new Task();
                newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
                newTask.Status = 'Completed';
                newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
                newTask.WhoId = leadRec.Id; 
                //Test after insert           
                insert newTask;                
             Test.stopTest();
             System.assertEquals(1, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        }
    }
   /**
    * @author Original: Andre Calimlim 
    * @date : 10 June 2014
    * @description test method for testing updateAttemptToLeads with Task that has type Call - Outbound or Email that triggers after delete
    */
    static testMethod void testTaskAfterDeleteAttemptToLeadUpdate(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        //Create Lead 
        Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
        leadRec.Status = 'Open';
        insert leadRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'Completed';
        newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
        newTask.WhoId = leadRec.Id; 
        insert newTask;
        System.assertEquals(1, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        System.runas(newUser){            
            Test.startTest();                
                delete newTask;                                     
            Test.stopTest();
        System.assertEquals(0, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);              
        }
    }
    /**
    * @author Original: Andre Calimlim 
    * @date : 10 June 2014
    * @description test method for testing updateAttemptToLeads with Task that has type Call - Outbound or Email that triggers after update
    */
    static testMethod void testTaskAfterUpdateAttemptToLeadUpdate(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        //Create Lead 
        Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
        leadRec.Status = 'Open';
        insert leadRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'Completed';
        newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
        newTask.WhoId = leadRec.Id; 
        //Test after insert           
        insert newTask;
        System.assertEquals(1, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Email',  'Send Email Test');
        newTask.Status = 'Completed';
        newTask.WhoId = leadRec.Id;
        insert newTask;
        System.assertEquals(1, [SELECT Email_Attempts__c FROM Lead WHERE id =: leadRec.id].Email_Attempts__c);
        System.runas(newUser){            
            Test.startTest();                
                //Test after update
                newTask.Type = 'Call - Outbound';
                newTask.Subject = 'Call Contact Test 1';
                newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
                update newTask;                                
            Test.stopTest();
            System.assertEquals(2, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
            System.assertEquals(0, [SELECT Email_Attempts__c FROM Lead WHERE id =: leadRec.id].Email_Attempts__c);                        
        }
    }
    /**
    * @author Original: Andre Calimlim 
    * @date : 1 Aug 2014
    * @description test method for testing updateAttemptToOpp with Task that has type Call - Outbound or Email that triggers after update
    */
    static testMethod void testTaskAfterUpdateAttemptToOppUpdate(){
        csb.buildGenSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        Account acctL = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acctL;
        //Create opty 
        Opportunity oppRec = TestDataBuilder.buildTestOpportunity(1);
        opprec.AccountId = acctL.Id;
        insert oppRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'Completed';
        newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
        newTask.WhatId = oppRec.Id; 
        //Test after insert           
        insert newTask;
        System.assertEquals(1, [SELECT Call_Attempts__c FROM Opportunity WHERE id =: oppRec.id].Call_Attempts__c);
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Email',  'Send Email Test');
        newTask.Status = 'Completed';
        newTask.WhatId = oppRec.Id;
        insert newTask;
        System.assertEquals(1, [SELECT Email_Attempts__c FROM Opportunity WHERE id =: oppRec.id].Email_Attempts__c);
        System.runas(newUser){            
            Test.startTest();                
                //Test after update
                newTask.Status = 'Completed';
                newTask.Type = 'Call - Outbound';
                newTask.Subject = 'Call Contact Test 1';
                newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
                update newTask;                                
            Test.stopTest();
            System.assertEquals(2, [SELECT Call_Attempts__c FROM Opportunity WHERE id =: oppRec.id].Call_Attempts__c);
            System.assertEquals(0, [SELECT Email_Attempts__c FROM Opportunity WHERE id =: oppRec.id].Email_Attempts__c);                        
        }
    }
    /**
    * @author Original: Andre Calimlim 
    * @date : 10 June 2014
    * @description test method for testing updateAttemptToLeads with Task that has type other than Call - Outbound or Email expected that Attempt to lead doesn't increased or decreased
    */
    static testMethod void testTaskAfterInsertAttemptToLeadNotUpdated(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        System.runas(newUser){
            //Create Lead 
            Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
            leadRec.Status = 'Open';
            insert leadRec;
            Test.startTest();
                //Create Task
                Task newTask = new Task();
                newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call',  'Call Contact Test');
                newTask.Status = 'Completed';
                newTask.WhoId = leadRec.Id; 
                //Test after insert           
                insert newTask;                
             Test.stopTest();
             System.assertEquals(0, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        }
    }
    /**
    * @author Original: Andre Calimlim 
    * @date : 10 June 2014
    * @description test method for testing updateAttemptToLeads with Task that has type Call - Outbound or Email that triggers after delete expected that Attempt to lead doesn't increased or decreased
    */
    static testMethod void testTaskAfterDeleteAttemptToLeadNotUpdated(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        //Create Lead 
        Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
        leadRec.Status = 'Open';
        insert leadRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'Not Started';
        newTask.WhoId = leadRec.Id; 
        insert newTask;
        System.assertEquals(0, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        System.runas(newUser){            
            Test.startTest();                
                delete newTask;                                     
            Test.stopTest();
            System.assertEquals(0, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);              
        }
    }
    /**
    * @author Original: Andre Calimlim 
    * @date : 10 June 2014
    * @description test method for testing updateAttemptToLeads with Task that has type Call - Outbound or Email that triggers after update expected that Attempt to lead doesn't increased or decreased
    */
    static testMethod void testTaskAfterUpdateAttemptToLeadNotUpdated(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        //Create Lead 
        Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
        leadRec.Status = 'Open';
        insert leadRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'Completed';
        newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
        newTask.WhoId = leadRec.Id; 
        //Test after insert           
        insert newTask;
        System.assertEquals(1, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call',  'Call Contact Test');
        newTask.Status = 'Completed';
        newTask.WhoId = leadRec.Id;
        insert newTask;
        System.assertEquals(0, [SELECT Email_Attempts__c FROM Lead WHERE id =: leadRec.id].Email_Attempts__c);
        System.runas(newUser){            
            Test.startTest();                
                //Test after update
                newTask.Type = 'Call';
                newTask.Subject = 'Call Contact Test 1';
                newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
                update newTask;                                
            Test.stopTest();
            System.assertEquals(1, [SELECT Call_Attempts__c FROM Lead WHERE id =: leadRec.id].Call_Attempts__c);
        }
    }
    
     /**
    * @author Original: Sagar Talele
    * @date : 18 December 2014
    * @description test method for testing updateNextDueDate Before insert and before Update
    */
    static testMethod void testupdateNextDueDate()
    {
         csb.buildGenSetting();
         //re-create Bypass Trigger Custom Setting
         csb.buildBypassTriggerSettings();
         User newUser = new User();
         newUser = TestDataBuilder.buildTestUser(1);
         insert newUser;
         User newUser1 = new User();
         newUser1 = TestDataBuilder.buildTestUser(2);
         insert newUser1;
         
         Account acctL = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
         insert acctL;
         
         Opportunity testOpportunity = TestDataBuilder.buildTestOpportunity(1);
         testOpportunity.AccountId = acctL.Id;
         testOpportunity.OwnerId = newUser.Id;
         testOpportunity.Next_Activity_Due_Date__c =Date.today();
         Task testTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Email', 'Testing');
         testTask.ActivityDate = Date.today();
         Test.startTest(); 
         insert testOpportunity;
         
         testTask.whatId =testOpportunity.Id ;
         insert testTask;
         update testTask;
         Test.stopTest(); 
         System.assertEquals(testOpportunity.Next_Activity_Due_Date__c,testTask.ActivityDate);
         system.debug(testOpportunity.OwnerId +' ---Owner '+testTask.Owner);
        
    }
    
     /**
    * @author Original: Archana Lohar 
    * @date :3 Dec 2014
    * @description test method for testing updateLeadIdOnTask with Task 
    */
    static testMethod void testUpdateLeadIdOnTask(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        //Create Lead 
        Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
        leadRec.Status = 'Open';
        insert leadRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'Completed';
        newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
        newTask.WhoId = leadRec.Id; 
        //Test after insert           
        insert newTask;
        System.assertEquals(leadRec.id, [SELECT Salesforce_Lead_Id__c FROM task WHERE id =: newTask.id].Salesforce_Lead_Id__c);
    }
    
    /**
    * @author Original: Archana Lohar 
    * @date : 12 December 2014
    * @description test method for testing UpdateEscalateTo  after update
    */
    static testMethod void testUpdateEscalateToUpdate(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        //Create Lead 
        Lead leadRec = TestDataBuilder.buildTestLead(1, 'Unknown Contact');
        leadRec.Status = 'Open';
        insert leadRec;
       
        Task newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Email',  'Send Email Test');
        newTask.Status = 'In Progress';
        newTask.WhoId = leadRec.Id;
        insert newTask;
      
        System.runas(newUser){            
            Test.startTest();                
                //Test after update
                newTask.Type = 'call';
                update newTask; 
                
                Task updatedTask = [SELECT Id FROM Task WHERE Id =: newTask.Id];
                
                //Asserting if task is created or not.
                system.assertEquals(newTask.id, updatedTask.Id, True);
            Test.stopTest();                        
        }
    }
    /**
    * @author Original: Sagar Talele
    * @date : 18 December 2014
    * @description test method for testing SetActivityDates after insert
    */
     static testMethod void testSetActivityDates(){
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
    
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Completed', 'Call - Outbound',  'No Case Test');
        newTask.WhatId = newCase.Id; 
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        //newtask.Type = 'Escalation';
        test.startTest();
        insert newTask;
        test.stopTest();
        
        List<Case> caseListAfterTaskCreation = new List<Case>();
        caseListAfterTaskCreation = [SELECT id,First_Contact_Date__c,Last_Activity_Date__c FROM Case WHERE id = :newTask.WhatId];
        Case updatedCase = new Case();
        for(Case c: caseListAfterTaskCreation){
            updatedCase = c;
        }
        system.assertEquals(updatedCase.First_Contact_Date__c.date(),date.today());
        system.assertEquals(updatedCase.Last_Activity_Date__c.date(),date.today());
        
    }
    
   
    /**
    * @author Original: Faina Gorelik
    * @date : 01 April 2015
    * @description test method for testing SetActivityDate on case after update AtTask 840586 
    */
   
       static testMethod void testUpdateSetActivityDates(){
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
    
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Call - Outbound',  'No Case Test');
        newTask.WhatId = newCase.Id; 
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        
        
        insert newTask;
        
         //Create a new Task with a valid case related to it. 
        Task newTask1 = new Task();
        newTask1 = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Call - Outbound',  'No Case Test');
        newTask1.WhatId = newCase.Id; 
        newTask1.Category__c = 'Escalation – Request to Dev';
        newTask1.Escalate_To__c = 'Natick EDG';
        
        
        insert newTask1;
        
        test.startTest();
        newTask.Status = 'Completed';
        newTask1.Status ='Completed';
        update newTask; 
        update newTask1;  
        
        List<Case> caseListAfterTaskCreation = new List<Case>();
        caseListAfterTaskCreation = [SELECT id,First_Contact_Date__c,Last_Activity_Date__c FROM Case WHERE id = :newTask.WhatId];
        Case updatedCase = new Case();
        for(Case c: caseListAfterTaskCreation){
            updatedCase = c;
        }
        system.assertEquals(updatedCase.First_Contact_Date__c.date(),date.today());
        system.assertEquals(updatedCase.Last_Activity_Date__c.date(),date.today());
        test.stopTest();
        
        
       
    }
    
     /**
    * @author Original: Sagar Talele
    * @date : 18 December 2014
    * @description test method for testing UpdateFirstActivityCompletedDate after update
    */
    static testMethod void testUpdateFirstActivityCompletedDate(){
         csb.buildGenSetting();
         //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        Account acctL = TestDataBuilder.buildtestAccount(1, UserInfo.getuserId());
        insert acctL;
        
        //Create Opty
        Opportunity oppRec = TestDataBuilder.buildTestOpportunity(1);
        oppRec.AccountId = acctL.Id;
        oppRec.OwnerId = newUser.Id;
        insert oppRec;
        //Create Task
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Outbound',  'Call Contact Test');
        newTask.Status = 'In Progress';
        newTask.Call_Outbound_Outcomes__c = 'Contacted Customer';
        newTask.WhatId = oppRec.Id; 
        insert newTask;
        newTask.Status = 'Completed';
        Test.startTest();                
                update newTask;                                
        Test.stopTest();
        
    
    }
     /**
    * @author Original: Divya Gawade
    * @date : 20 Jan 2015
    * @description test method for testing cannot create an escalation task on closed case
    */
    static testMethod void testEscalationTaskOnClosedCase(){
      //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
    
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
       
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('closed');
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Call - Outbound',  'No Case Test');
        newTask.WhatId = newCase.Id; 
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        newtask.Type = 'Escalation';
        test.startTest();
        try{
            insert newTask;
        }
        catch(Exception ex){
           system.assertEquals( ex.getMessage().contains('You cannot create an escalation task on closed case'),True);
        }
        test.stopTest();
    }
    /**@author Original: Sagar Talele
     * @date Original: 16/3/2015
     * @description Test Method will test the Has Email Attachment field on task updated when task related to case has Attachment.
     **/
    static testMethod void testupdateTaskHasAttachment(){
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('closed');
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Completed', 'Email',  'Case Attachment Test');
        newTask.WhatId = newCase.Id; 
        newTask.OwnerId = newUser.Id;
        newtask.Type = 'Email';
        
        test.startTest();
        
          insert newTask;
            Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.ParentId=newTask.id;
            attach.OwnerId=newUser.Id;
            insert attach;  
            System.assertEquals(attach.parentId,newTask.id);
            List<Attachment> attachments=[select id, name,ParentId from Attachment where ParentId=:newTask.id];
            System.assertEquals(1, attachments.size());
        
        test.stopTest();
    }
    
    /* @author Original: Priyank Saxena
    * @date : 1 April 2015
    * @description test method for testing Escl to dev email when the Case substatus is set to "Waiting to Internal" 
    */
     static testMethod void testEscalatetoDevEmail(){
      //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
    
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Sent', 'Email',  'Email Outbound test');
        newTask.WhatId = newCase.Id; 
        test.startTest();
        insert newTask;
        List<Case> caseListAfterTaskCreation = [SELECT id,Substatus__c FROM Case WHERE id = :newTask.WhatId];
        system.assertequals(1,caseListAfterTaskCreation.size());
        system.assertequals('Waiting for Internal',caseListAfterTaskCreation[0].Substatus__c);
        test.stopTest();
        
     }
     //
     
    /**
    * @author Original: Faina Gorelik - MathWorks 
    * @date Original: 23 Nov 2015
    * @description test method for testing Set Task Status to Updated Status, set Updated Status custom field to null after task updated
    */ 
     static testMethod void testSetUpdatedStatus(){
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            
            //Create new User
            User newUser = new User();
            newUser = TestDataBuilder.buildTestUser(1);
            insert newUser;
            
            
            Task newTask = new Task();
            newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Not Started', 'Call - Inbound', 'Test Updated Status');
            test.startTest();
            insert newTask;
            
            Task UpdTask = new Task(); 
            
            newTask.Updated_Status__c = 'In Progress';
            update newTask;
            UpdTask = [Select Id, Status, Updated_Status__c from Task Where Id = : NewTask.Id];
            test.stopTest();
            system.assertEquals(UpdTask.Updated_Status__c,null);
            system.assertEquals(UpdTask.Status,'In Progress');         
            
        }
        
         /*
        * @author Original: Neha Mahajan
        * @date Original: 11 March 2016
        * @description test method for testing if the status and substatus fields on the case are updated based on task field value insertion
        */ 
        
        static testMethod void InsertTaskforEscalationStatusTest(){
    
        //re-create Bypass Trigger Custom Setting
         csb.buildBypassTriggerSettings();
         
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
       
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        newCase.SubStatus__c='In Progress';
       
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task  newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Escalation',  'No Case Test');
        newTask.WhatId = newCase.id; 
        newTask.Escalate_To__c = 'CN - Customer Support';
        
        insert newTask;
       
        List<Case> caseList = new List<Case>();
        caseList= [SELECT id,First_Contact_Date__c,Last_Activity_Date__c, Status, SubStatus__c FROM Case WHERE id = :newTask.id];
        for(Case CaseObj:caseList){
        system.assertEquals(CaseObj.Status,'Open'); 
        system.assertEquals(CaseObj.SubStatus__c,'Waiting for Internal');
        }
        
        Task taskObj= new Task();
        taskObj=[Select Id,Escalate_To__c from Task Where Id = : newtask.Id];
        system.assertEquals(taskObj.Escalate_To__c,'CN - Customer Support');
    }   


       /*
        * @author Original: Neha Mahajan
        * @date Original: 11 March 2016
        * @description test method for testing if the status and substatus fields on the case are updated based on task field value updation
        */ 
         
        static testMethod void updateTaskforEscalationStatusTest(){
        
        //re-create Bypass Trigger Custom Setting
         csb.buildBypassTriggerSettings();
         
        //Create new User record.
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
       
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        newCase.SubStatus__c='In Progress';
        insert newCase ;
        
        //create new task record
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'In Progress', 'Meeting',  'No Case Test');
        newTask.WhatId = newCase.Id; 
        newTask.Escalate_To__c = 'CN - Customer Support';
             
        insert newTask;
        
        newtask.Type = 'Escalation'; 
        update newTask;
        
        List<Case> caseList = new List<Case>();
        caseList= [SELECT id,First_Contact_Date__c,Last_Activity_Date__c, Status, SubStatus__c FROM Case WHERE id = :newTask.id];
        for(Case CaseObj:caseList){
        
        system.assertEquals(CaseObj.Status,'Open'); 
        system.assertEquals(CaseObj.SubStatus__c,'Waiting for Internal');
        
        }
        
        Task taskObj= new Task();
        taskObj=[Select Id,Escalate_To__c from Task Where Id = : newtask.Id];
        system.assertEquals(taskObj.Escalate_To__c,'CN - Customer Support');
       }
}