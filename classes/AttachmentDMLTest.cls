/**
* @author Original: kishore AN - Cloud Sherpas/Mathworks
* @date Original: 20 March 2015 , Last Modified:
* @description test class for AttachmentDML class functionalities.
* @Revision :
*/ 
@isTest
public class AttachmentDMLTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
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
			List<Task> taskList = [select Id, has_attachment__c from Task where Id = :newTask.Id];
			System.assertEquals(true, taskList[0].has_attachment__c);       
        
        
        test.stopTest();
    }

}