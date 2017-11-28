/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 05 June 2013, Last Modified: 22 October 2013
* @description test class CustomButtonFunctions functionalities.
*/ 
@isTest
private class CustomButtonFunctionsTest {
	
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
	* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
	* @date Original: 05 Jun 2013, Last Modified: 22 October 2013
	* @description test method for testing taking of ownership on Tasks
	* @author modified: Marc Ouimet; Date: 20 May 2014; added line 51 for test coverage of TakeOwnershipCase method for g1043744
	*/ 
    static testmethod void testTakeOwnership(){
    	
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //Create new User records.
        List<User> newUser = new List<User>();
        newUser.add(TestDataBuilder.buildTestUser(1));
        newUser.add(TestDataBuilder.buildTestUser(2));
        insert newUser;
        
        //Create new Case record.
        Case newCase = new Case();
        newCase = TestDataBuilder.buildTestCase('Open');
        newCase.IsEscalated = true;
        newCase.Escalation_to__c = 'Natick EDG';
        insert newCase;
        
        //Create a new Task with a valid case related to it. 
        Task newTask = TestDataBuilder.buildTestTask(newUser[0].Id, 'In Progress', 'Escalation',  'No Case Test');
        newTask.WhatId = newCase.Id; 
        newTask.Category__c = 'Escalation – Request to Dev';
        newTask.Escalate_To__c = 'Natick EDG';
        insert newTask;

        //Run test with User#2
        system.runAs(newUser[1]){
        	
	        test.startTest();
	        	//Simulate clicking of Take Ownership button on Task
	            CustomButtonFunctions.TakeOwnership(newTask.id,newUser[1].id);
            	CustomButtonFunctions.TakeOwnershipCase(newCase.id,newUser[1].id); //Modified by Marc Ouimet 20 May 2014 for g1043744
	        test.stoptest();
	        
	        //Retrieve updated Task
	        Task updatedTask = [Select Id, OwnerId From Task Where Id = : newTask.Id];
	        
	        //Retrieve updated Case
	        Case updatedCase = [Select Id, IsEscalated, Escalation_to__c From Case Where id = : newCase.Id];
	        
	        //Verify that task ownership was changed to User#2
	        system.assertEquals(updatedTask.OwnerId,newUser[1].Id);
	        //Verify that related Case's Escalation To value was changed to null because Case is escalated
	        system.assertEquals(updatedCase.Escalation_to__c,null);
        }
        
    }
}