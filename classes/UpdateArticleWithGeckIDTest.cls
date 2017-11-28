/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 07 October 2013, Last Modified: 08 October 2013
* @description test class for UpdateArticleWithGeckID
*/ 
@isTest 
private class UpdateArticleWithGeckIDTest {

    static testMethod void testUpdateOnlineArticles() {
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        
        //create test Article 
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test article';
        faq.UrlName = 'test1-article';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        Test.startTest();
            //execute webservice method
           // UpdateArticleWithGeckId.findAndUpdateArticles(faqDr.ArticleNumber, '12345testGeck');
            UpdateArticleWithGeckId.findAndUpdateArticles(faqDr.ArticleNumber, '12345');
        Test.stopTest();
        
        //Retrieve updated test Online Article
        FAQ__kav upfaqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online' And Title = : faqDr.Title];
        
        //Verify that Geck Id has been updated on the article
        system.assertEquals(upfaqOn.GeckId__c,'12345');
        }
    }
    
    static testMethod void testUpdateOnlineArticlesWithDraft() {
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        //create test Article 
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test article';
        faq.UrlName = 'test2-article';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, true);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        Test.startTest();
            //execute webservice method
            UpdateArticleWithGeckId.findAndUpdateArticles(faqDr.ArticleNumber, '12345');
        Test.stopTest();
        
        //Retrieve updated test Online Article
        FAQ__kav upfaqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online' And Title = : faqDr.Title];
        
        //Verify that Geck Id has been updated on the article
        system.assertEquals(upfaqOn.GeckId__c,'12345');
        }
    }
    
    
    static testMethod void testUpdateArchiveArticles() {
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        
        //create test Article 
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test article';
        faq.UrlName = 'test3-article';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article 
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        //archive test Online article
        KbManagement.PublishingService.archiveOnlineArticle( (Id)faqDr.KnowledgeArticleId, null);
        
        Test.startTest();
            //execute webservice method
            UpdateArticleWithGeckId.findAndUpdateArticles(faqDr.ArticleNumber, '12345');
        Test.stopTest();
        
        //Retrieve updated test Online Article
        FAQ__kav upfaqAr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Archived' And Title = : faqDr.Title];
        
        //Verify that Geck Id has been updated on the article
        system.assertEquals(upfaqAr.GeckId__c,'12345');
        }
    }
    
    static testMethod void testUpdateArchiveArticleswithDraft() {
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        //create test Article 
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test article';
        faq.UrlName = 'test4-article';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article 
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //archive test Online article
        KbManagement.PublishingService.archiveOnlineArticle( (Id)faqDr.KnowledgeArticleId, null);
        
        //Retrieve test Archived Article
        FAQ__kav faqAr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Archived' And Title = : faqDr.Title];
        
       //Create a draft version of the archived article
        String archivedID = KbManagement.PublishingService.editArchivedArticle((ID)faqAr.KnowledgeArticleId);
        
        //Retrieve created Draft from Archived Article
        FAQ__kav faqDrArchived = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : archivedID ];
        
        Test.startTest();
            //execute webservice method
            UpdateArticleWithGeckId.findAndUpdateArticles(faqDrArchived.ArticleNumber, '12345');
        Test.stopTest();
        
        //Retrieve updated test Online Article
        FAQ__kav upfaqAr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Archived' And Title = : faqDr.Title];
        
        //Verify that Geck Id has been updated on the article
        system.assertEquals(upfaqAr.GeckId__c,'12345');
        }
    }
    
    static testMethod void testException() {
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        //create test Article 
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test article';
        faq.UrlName = 'test5-article';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        Test.startTest();
            //execute webservice method
            UpdateArticleWithGeckId.findAndUpdateArticles(faqDr.ArticleNumber, '111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111');
        Test.stopTest();
        }
    }
    
}