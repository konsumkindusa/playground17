/**
* @author Original: Krishna Bhaskarla, Mathworks  
* @date Original: 08 October 2013, Last Modified: 09 October 2013
* @description test class for ArticlesWebservice
*/ 
@isTest
public with sharing class MW_ArticlesServiceTest {
    
    static testMethod void MW_ArticlesServiceTest(){
    
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
    
            //Master
            FAQ__kav faq = TestDataBuilder.buildTestFAQkav(11);
            insert faq;
            String url = 'http://testcase.mathworks.com/ext/answers';
            FAQ__kav faqObject = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE Id= : faq.id limit 1];
            system.debug('ArticleID:' +faqObject.KnowledgeArticleId);
            KbManagement.PublishingService.publishArticle(faqObject.KnowledgeArticleId, true);
            faqObject = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE Id= : faq.id limit 1];
            system.debug('Published ArticleID:' +faqObject.KnowledgeArticleId);
            //Translation
            String Id = KbManagement.PublishingService.submitForTranslation(faqObject.KnowledgeArticleId, 'ja', UserInfo.getuserId(), null);
            KbManagement.PublishingService.completeTranslation(Id);
            FAQ__kav TranObject = [Select Id, KnowledgeArticleId From FAQ__kav WHERE Id= : Id limit 1];  
            
            //Draft
            FAQ__kav faqDraft = TestDataBuilder.buildTestFAQkav(12);
            insert faqDraft;
            FAQ__kav draftObject = [Select Id, KnowledgeArticleId, Answers_URL__c From FAQ__kav WHERE Id= : faqDraft.id limit 1];
            KbManagement.PublishingService.publishArticle(draftObject.KnowledgeArticleId, true);
            String ArticleEdit = KbManagement.PublishingService.editOnlineArticle(draftObject.KnowledgeArticleId, true);
            FAQ__kav[] DrafeFAQ;
            DrafeFAQ = [Select Id, KnowledgeArticleId, Answers_URL__c From FAQ__kav WHERE Language='en_US' AND PublishStatus = 'Draft' and Id= : ArticleEdit limit 1];
            
            //Draft Translation
            FAQ__kav tran = TestDataBuilder.buildTestFAQkav(15);
            insert tran;
            FAQ__kav tranObj = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE Id= : tran.id limit 1];
            KbManagement.PublishingService.publishArticle(tranObj.KnowledgeArticleId, true);
            String tranId = KbManagement.PublishingService.submitForTranslation(tranObj.KnowledgeArticleId, 'ja', UserInfo.getuserId(), null);
            KbManagement.PublishingService.completeTranslation(tranId);
            FAQ__kav translation = [Select Id, KnowledgeArticleId From FAQ__kav WHERE Id= : tranId limit 1];
             
            Test.startTest();
                MW_ArticlesService.updateArticleURL(faqObject.KnowledgeArticleId,url,'en_US');
                MW_ArticlesService.updateArticleURL(TranObject.KnowledgeArticleId,'http://testKrishna','ja');
                MW_ArticlesService.updateArticleURL(DrafeFAQ[0].KnowledgeArticleId,url,'en_US');
                MW_ArticlesService.updateArticleURL(translation.KnowledgeArticleId,url,'ja');
                MW_ArticlesService.updateArticleURL(translation.KnowledgeArticleId,url,'kr');
                MW_ArticlesService.updateArticleURL('12345','http://testKrishna','ja');
            Test.stopTest();
            faqObject = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE KnowledgeArticleId = :faqObject.KnowledgeArticleId and publishstatus='online' and language='en_US'  limit 1];
            system.assertEquals(faqObject.Answers_URL__c, url);
                                   
        }
    }

}