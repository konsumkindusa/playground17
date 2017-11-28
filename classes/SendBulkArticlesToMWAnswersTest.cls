/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 08 October 2013, Last Modified: 09 October 2013
* @description test class for SendArticlesToMW, SendArticlesToMWSchedulable
*/ 
@isTest
private class SendBulkArticlesToMWAnswersTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
   
    static testMethod void testSendArticlestToMWOnline(){
        
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
          
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.language = 'ja';
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachment_4__Body__s = att1.Body;
        faq.Attachment_4__ContentType__s = 'text/plain';
        faq.Attachment_4__Name__s = att1.Name;
        faq.Attachment_5__Body__s = att1.Body;
        faq.Attachment_5__ContentType__s = 'text/plain';
        faq.Attachment_5__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        insert faq;
        
        //create test data categories
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
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            //publish test draft article
            update fa;
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false);   
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        
        
        List<String> articleIdList = new List<String>();
        articleIdList.add(faqOn.knowledgeArticleId);
        //execute main method for sending articles
        Test.startTest();
            SendBulkArticlesToMWAnswers.sendArticles(articleIdList);
        Test.stopTest();
        
           ArticleBulkData__c newArticleBulkData = new ArticleBulkData__c();
            
        }

          //Retrieve ArticleBulk data from the custom object
         // newArticleBulkData = [Select Article_Id__c From ArticleBulkData__c Where Article_Id__c = :FAQ__kav.Id];

          // system.assertEquals(newArticleBulkData.Id,FAQ__kav.Id );
        
       //assert eqauls should be equal to 1;
       //query the custom object with the knowledgeArticleId  
       
        //BulkArticle  = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];  
       
       
    }
  }