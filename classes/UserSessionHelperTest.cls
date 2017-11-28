@isTest
private class UserSessionHelperTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

static testMethod void requestAccessTokenTest(){
string jobId;
    
     User usr = TestDataBuilder.buildTestUser(1);
     //set the knowledge user permission to manage knowledge
     usr.UserPermissionsKnowledgeUser = true;
     insert usr;
    
     custsettbuild.buildRemoteAppSettings();
     custsettbuild.buildSendArticlesSession();
     //custsettbuild.buildSendArticlesSettings();
     RemoteAppSettings__c remoteSetting = RemoteAppSettings__c.getInstance();
     Integration_Settings__c integrationSetting = TestDataBuilder.builIntegrationSettings();
     
     System.runAs(usr){
        
    
    //create test article
    FAQ__kav testFaq = new FAQ__kav();
    testFaq.Title = 'Test FAQ';
    testFaq.Summary = 'KB Summary';
    testFaq.URLName = 'testKBFAQArticleSummaryUnitTest';
    insert testFaq;
    
    System.debug('**testFaq**'+testFaq);
    // Get the KnowledgeArticleId
    FAQ__kav insertedTestFaq = [Select KnowledgeArticleId, publishstatus from FAQ__kav where ID = :testFaq.Id];
    System.debug('**insertedTestFaq**'+insertedTestFaq );
    // Publish
    KbManagement.PublishingService.publishArticle(insertedTestFaq.KnowledgeArticleId, true);
    
    // Use StaticResourceCalloutMock to
    // specify fake response for a certain endpoint and 
    // include response body in a static resource.
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockResponseAccessTokenArticle');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
   
    //re-create custom setting test records when running the test class
    CustomSettingsBuilder csb = new CustomSettingsBuilder();
    csb.buildSendArticlesSettings();
    SendArticlesToMWSchedulable sams = new SendArticlesToMWSchedulable();
    
        //csb.buildSendArticlesSettings();
   
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + '15' + ' ' + '0' + ' * * ?';
        
        // Schedule the test job
        Test.startTest();
        insert integrationSetting;
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        jobId = System.schedule('Send Articles to MW Test', nextFireTime, sams);
        Test.stopTest();
         
     }
  }
  

}