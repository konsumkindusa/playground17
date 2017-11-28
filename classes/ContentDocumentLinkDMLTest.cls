/**
* @author Original: Faina Gorelik - Mathworks
* @date Original: 29 September 2016 , Last Modified:
* @description test class for ContentDocumentLinkDML class 
*/ 

@isTest
public class ContentDocumentLinkDMLTest {
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    //  static testMethod void testupdateTaskHasAttachment(){
    static testMethod void testupdateTaskHasAttachment(){
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //Create new User
        User newUser = new User();
        newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
 		// Create New Email Task 
        Task newTask = new Task();
        newTask = TestDataBuilder.buildTestTask(newUser.Id, 'Completed', 'Email',  'Test Tas File');
        newTask.OwnerId = newUser.Id;
        newtask.Type = 'Email';
        
        test.startTest();   
        
        insert newTask;
        
        //Create new file
        ContentVersion  contver = new ContentVersion();
        contver.Title = 'File Upload Test';
        contver.PathOnClient ='/' + contver.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Test File Upload');
        contver.VersionData = bodyBlob;
        contver.Origin ='H';
        insert contver;
        
        // associate file to the task
        ContentDocumentLink contdoclink = new ContentDocumentLink();
        contdoclink.LinkedEntityId = newTask.id;
        contdoclink.ContentDocumentId =[select contentdocumentid from contentversion where id =: contver.id].contentdocumentid;
        contdoclink.ShareType ='V';
        insert contdoclink;
         // verify has attachment flag
        System.assertEquals(contdoclink.LinkedEntityId,newTask.Id);
        List<Task> taskList = [select Id, has_attachment__c from Task where Id = :newTask.Id];
        System.assertEquals(true, taskList[0].Has_Attachment__c);
        test.stopTest();

    }
}