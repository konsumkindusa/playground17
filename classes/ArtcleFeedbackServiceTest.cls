/**
* @author Original: Krishna Bhaskarla
* @date Original: 26 July 2014
* @description test class for ArticleFeedback Webservice
*/ 
@isTest
public with sharing class ArtcleFeedbackServiceTest {
 static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    static testMethod void testArticleFeedback(){   
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();       
        
        User testUser = TestDataBuilder.buildTestUser(1);
        testUser.UserPermissionsKnowledgeUser = true;
        insert testUser;
            
        system.runAs(testUser){
        //create test Article 
        
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        faq.Language='en_US';
        faq.IsVisibleinCSP = true; 
        faq.ValidationStatus = 'Externally Validated';
        faq.Answers_URL__c = 'http://test.com';
        insert faq;
        list <FAQ__DataCategorySelection> faqdclist = new list <FAQ__DataCategorySelection>();
        FAQ__DataCategorySelection faqdcP = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Product', 'All_Products');
        faqdclist.add(faqdcP);
        FAQ__DataCategorySelection faqdcTy = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Type', 'Enhancement');
        faqdclist.add(faqdcTy);
        FAQ__DataCategorySelection faqdcT = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Topic', 'All');
        faqdclist.add(faqdcT);
        FAQ__DataCategorySelection faqdcPS = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Platform_OS', 'All');
        faqdclist.add(faqdcPS);
        FAQ__DataCategorySelection faqdcVR = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Verified_in_Release', 'R2013a');
        faqdclist.add(faqdcVR);
        insert faqdclist;
        
        //retrieve created test data categories on test article
        list <FAQ__DataCategorySelection> faqDC = [Select Id, ParentId, DataCategoryGroupName, DataCategoryName  From FAQ__DataCategorySelection Where parentId = : faq.Id ];
        
        
        
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName, ISMAsterLanguage, ISVisibleInCSP From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  and Id = : faq.Id ];
         System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article master:'+faqDr.ISMAsterLanguage);
         System.Debug('@@faqDr article cp:'+faqDr.ISVisibleInCSP);
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, KnowledgeArticleId, language, answers_url__c, Title From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        ArticleFeedbackService.CommentsInfo comments = new ArticleFeedbackService.CommentsInfo();
        comments.comment = 'Apex Test Class Comment';
        comments.commentType = 'Question Feedback';
        comments.ownerEmail = 'apexTestClass@test.com';
        Test.startTest();
            ArticleFeedbackService.setArticleFeedback(faqon.KnowledgeArticleId, faqon.ArticleNumber, comments, faqon.language);
        Test.stopTest();
        
        Article_Feedback__c aFeed = [Select Id, Article_Number__c From Article_Feedback__c where Article_Number__c =: faqOn.ArticleNumber];
        system.assertEquals(aFeed.Article_Number__c, faqOn.ArticleNumber);
        }
    }
        
}