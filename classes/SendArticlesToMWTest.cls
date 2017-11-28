/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks , modified by Faina Gorelik AtTask 1725966
* @date Original: 08 October 2013, Last Modified: 22 October 2013, 22 June 2017
* @description test class for SendArticlesToMW, SendArticlesToMWSchedulable
*/ 
@isTest
private class SendArticlesToMWTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
   
    static testMethod void testSendArticlestToMWNoUpdate(){
        
        
        User usr = TestDataBuilder.buildTestUser(1);
        //set the knowledge user permission to manage knowledge
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
        
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        System.runAs(usr){
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        insert faq;
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that no articles has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,0);
        system.assertEquals(saset.Last_Run_Status__c,'No articles to be sent.');
        }
        
    }
    
    static testMethod void testSendArticlestToMWException(){
        
        csb.buildIntegrationSetting();
        //Retrieve Integration setting
        Integration_Settings__c integrationSetting = [Select Id, Name, Username__c, Password__c, Clientname__c, Endpoint__c, Timeout__c From Integration_Settings__c Where Name = 'Send Articles to MW Answers' limit 1];
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        list <Attachment> attlist = new list <Attachment>();
        for (Integer i=0;i<5;i++){
            Attachment att = new Attachment();
            att.Name = 'inlineimage'+i+'.txt';
            att.Body = Blob.valueof('inlinetext');
            att.ParentId = integrationsetting.Id;
            attlist.add(att);
        }
        insert attlist;
        
        try {
            //create a test response for webservice callout
            SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
            Test.setMock(WebServiceMock.class,mock);
            
            //create a test response for webservice callout
            SendArticlesToMWImagesTestMock mockIMG = new SendArticlesToMWImagesTestMock();
            Test.setMock(WebServiceMock.class,mockIMG);
            
            Test.startTest();
                SendArticlesToMW.sendArticles(UserInfo.getSessionId());
            Test.stopTest();
        }
        catch (Exception e) {}
        //can't assert 
        
    } 
    
    static testMethod void testSendArticlestToMWOnlineRemoval(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
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
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
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
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, true);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            update fa;  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
        
    }
    
    
    static testMethod void testSendArticlestToMWOnlineRemovalAnswer(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
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
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, true);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, Article_to_be_sent__c, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            fa.Article_to_be_sent__c = 'false';
            update fa;  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
        
    }
    
    
    
    static testMethod void testSendArticlestToMWOnlineRemovalJP(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
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
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        faq.Language='ja';
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
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
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, true);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            update fa;  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
        
    }
    
    static testMethod void testSendArticlestToMWOnlineRemovalJPArticle(){
        
         User usr = TestDataBuilder.buildTestUser(1);
        //set the knowledge user permission to manage knowledge
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        System.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.Language='ja';
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
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
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, true);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, Article_to_be_sent__c, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            fa.Article_to_be_sent__c = 'false';
            update fa;  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
        
    }
    
    
    
    static testMethod void testSendArticlestToMWOnline(){
        User usr = TestDataBuilder.buildTestUser(1);
        //set the knowledge user permission to manage knowledge
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
         
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.Language='en_US';
        faq.IsVisibleinCSP = true; 
        faq.ValidationStatus = 'Externally Validated';       
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName, ISMAsterLanguage, ISVisibleInCSP From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  and Id = : faq.Id ];
         System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article master:'+faqDr.ISMAsterLanguage);
         System.Debug('@@faqDr article cp:'+faqDr.ISVisibleInCSP);
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            //publish test draft article
            update fa;
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false); 
            
            String Id = KbManagement.PublishingService.submitForTranslation((Id)fa.KnowledgeArticleId, 'ja', UserInfo.getuserId(), null);
            KbManagement.PublishingService.completeTranslation(Id);  
        }        
        
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,2);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
    }
    
    
    static testMethod void testSendArticlestToMWOnlineJP(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.Language='ja';
        faq.IsVisibleinCSP = true; 
        faq.ValidationStatus = 'Externally Validated';       
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName, ISMAsterLanguage, ISVisibleInCSP From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  and Id = : faq.Id ];
         System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article master:'+faqDr.ISMAsterLanguage);
         System.Debug('@@faqDr article cp:'+faqDr.ISVisibleInCSP);
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
            
            String Id = KbManagement.PublishingService.submitForTranslation((Id)fa.KnowledgeArticleId, 'en_US', UserInfo.getuserId(), null);
            KbManagement.PublishingService.completeTranslation(Id);    
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,2);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
    }
    
    static testMethod void testSendArticlestToMWOnlineKO(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.Language='ko';
        faq.IsVisibleinCSP = true; 
        faq.ValidationStatus = 'Externally Validated';       
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName, ISMAsterLanguage, ISVisibleInCSP From FAQ__kav Where Language = 'ko' AND publishstatus = 'Draft'  and Id = : faq.Id ];
         System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article master:'+faqDr.ISMAsterLanguage);
         System.Debug('@@faqDr article cp:'+faqDr.ISVisibleInCSP);
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ko' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ko' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            //publish test draft article
            update fa;
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false); 
            
            String Id = KbManagement.PublishingService.submitForTranslation((Id)fa.KnowledgeArticleId, 'en_US', UserInfo.getuserId(), null);
            KbManagement.PublishingService.completeTranslation(Id);    
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,2);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
    }
    static testMethod void testSendArticlestToMWOnlineRemovalKOArticle(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.Language='ko';
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
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
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ko' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ko' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, true);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, Article_to_be_sent__c, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ko' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            fa.Article_to_be_sent__c = 'false';
            update fa;  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
        
    }
    
    
    //Test method to test Online articles with validation status as 'Internally validated'
     static testMethod void testSendArticlestToMWOnlineInternallyValidated(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        string imgaddress = 'img/loading.gif';
        //HW 1943305
        /*
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        */
        faq.Language='en_US';
        faq.IsVisibleinCSP = false;
        faq.Answers_URL__c = 'test.com' ;
        faq.ValidationStatus = 'Internally Validated';       
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName, ISMAsterLanguage, ISVisibleInCSP From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  and Id = : faq.Id ];
         System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article master:'+faqDr.ISMAsterLanguage);
         System.Debug('@@faqDr article cp:'+faqDr.ISVisibleInCSP);
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
       /* FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            //publish test draft article
            update fa;
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false); 
            
            String Id = KbManagement.PublishingService.submitForTranslation((Id)fa.KnowledgeArticleId, 'ja', UserInfo.getuserId(), null);
            KbManagement.PublishingService.completeTranslation(Id);  
        } */        
        
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
    }
   
    
    
    static testMethod void testSendArticlestToMWOArchived(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="img/loading.gif" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
        faq.Internal_Notes__c = 'notes <img src="img/loading.gif" ></img>';
        faq.KCS_Comments__c = 'comments <img src="img/loading.gif" ></img>';
        faq.Question_RT__c = 'question <img src="img/loading.gif" ></img>';
        faq.Related_Articles__c = 'articles <img src="img/loading.gif" ></img>';
        string imgaddress = 'img/loading.gif';
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //archive test Online article
        KbManagement.PublishingService.archiveOnlineArticle( (Id)faqDr.KnowledgeArticleId, null);
        
        //retrieve online article
        FAQ__kav faqArc = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Archived'  AND Title = : faqDr.Title ];
        
        String Archivedid = KbManagement.PublishingService.editArchivedArticle((ID)faqArc.KnowledgeArticleId);
        
        //Retrieve and update created Draft article then republish rearchive the Article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : Archivedid ]){
            fa.Title = 'test article updated';
            update fa;
            //publish test draft article
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false);
            //archive test Online article
            KbManagement.PublishingService.archiveOnlineArticle( (Id)fa.KnowledgeArticleId, null);  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
    }
    
    
    static testMethod void testSendArticlestToMWOArchivedJP(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="img/loading.gif" ></img>';
        faq.Answers_URL__c = 'http://www.mathworks.com';
        faq.Internal_Notes__c = 'notes <img src="img/loading.gif" ></img>';
        faq.KCS_Comments__c = 'comments <img src="img/loading.gif" ></img>';
        faq.Question_RT__c = 'question <img src="img/loading.gif" ></img>';
        faq.Related_Articles__c = 'articles <img src="img/loading.gif" ></img>';
        string imgaddress = 'img/loading.gif';
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        faq.IsVisibleinCSP = true;
        faq.ValidationStatus = 'Externally Validated';
        faq.Language = 'ja';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //archive test Online article
        KbManagement.PublishingService.archiveOnlineArticle( (Id)faqDr.KnowledgeArticleId, null);
        
        //retrieve online article
        FAQ__kav faqArc = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Archived'  AND Title = : faqDr.Title ];
        
        String Archivedid = KbManagement.PublishingService.editArchivedArticle((ID)faqArc.KnowledgeArticleId);
        
        //Retrieve and update created Draft article then republish rearchive the Article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'ja' AND publishstatus = 'Draft'  AND Id = : Archivedid ]){
            fa.Title = 'test article updated';
            update fa;
            //publish test draft article
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false);
            //archive test Online article
            KbManagement.PublishingService.archiveOnlineArticle( (Id)fa.KnowledgeArticleId, null);  
        }
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that an article has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,1);
        system.assertEquals(saset.Last_Run_Status__c.substring(0,2),'OK');
        }
    }
    
    static testMethod void testSendArticlestToMWOnNextRun(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Articles
        list <FAQ__kav> faqlist = new list <FAQ__kav>();
        for (integer i=0; i<20; i++){ 
            FAQ__kav faq = TestDataBuilder.buildTestFAQkav(i);
            faq.Title = 'test article '+i;
            faq.UrlName = 'test-article-url'+i;
            faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        	faq.Answers_URL__c = 'http://www.mathworks.com';
            faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
            faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
            faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
            faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
            string imgaddress = 'img/loading.gif';
	        //HW 1943305
	        /*
	        faq.Attachment_2__Body__s = att1.Body;
	        faq.Attachment_2__ContentType__s = 'text/plain';
	        faq.Attachment_2__Name__s = att1.Name;
	        faq.Attachment_3__Body__s = att1.Body;
	        faq.Attachment_3__ContentType__s = 'text/plain';
	        faq.Attachment_3__Name__s = att1.Name;
	        faq.Attachments__Body__s = att1.Body;
	        faq.Attachments__Name__s = att1.Name;
	        faq.Attachments__ContentType__s = 'text/plain';
	        */
            faq.IsVisibleinCSP = true;
            faq.ValidationStatus = 'Externally Validated';
            faqlist.add(faq);
        }
        insert faqlist;
        
        set <string> faqtitleset = new set <string>();
        for (FAQ__kav faq : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id in : faqlist ]){
            //publish test draft article
            KbManagement.PublishingService.publishArticle( (Id)faq.KnowledgeArticleId, false);
            faqtitleset.add(faq.Title); 
        }
        
        set <string> faqDrIdSet = new set <string>();
        for (FAQ__kav faq : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title in : faqtitleset ]){
            String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faq.KnowledgeArticleId, true);
            faqDrIdSet.add(DraftId);
        }
        
        list <FAQ__kav> upfaqlist = new list <FAQ__kav>();
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id in : faqDRIDSet ]){
            fa.Title = 'test article updated';
            upfaqlist.add(fa);
        }
        update upfaqlist;
        
        //create a test response for webservice callout
        SendArticlesWSDLTestMock mock = new SendArticlesWSDLTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        
        Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
        //Verify that articles has been sent
        system.assertEquals(saset.Number_of_Articles_Sent__c,9); //max number of articles to be sent a single schedule run is 10 because of callout limitation 
        system.assertEquals(saset.Last_Run_Status__c.substringAfter('with '), '11 pending Article(s) on next run.');
        }
    } 

    static testMethod void testSendArticlesMWSchedulable() {
         User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
      System.runAs(usr){
        //create test Article 
        FAQ__kav faq = new FAQ__kav();
        //faq.Title = 'test article';
        faq.Title = 'test article' + DateTime.now().getTime();
       // faq.UrlName = 'test-article';
        faq.UrlName = 'test-article'+ DateTime.now().getTime();
        faq.IsVisibleInCSP = true;
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            //publish test draft article
            update fa;
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false);   
        }
        
        CronTrigger cronTrigger;
        string jobId;
        SendArticlesToMWSchedulable sams = new SendArticlesToMWSchedulable();
        String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = ss + ' ' + '15' + ' ' + '0' + ' * * ?';
        
        // Schedule the test job
        Test.startTest();
          jobId = System.schedule('Send Articles to MW Test', nextFireTime, sams);
        Test.stopTest();
        
        //Get CronJobDetail info
        CronJobDetail cronJob = [Select Id, Name From CronJobDetail Where Name = 'Send Articles to MW Test'];
        // Get the CronTrigger info
        cronTrigger = [SELECT Id, CronExpression, CronJobDetailId, TimesTriggered, NextFireTime FROM CronTrigger Where CronJobDetailId = : cronJob.Id];
        
        //Verify that Scheduled Job has been added on cronTrigger
        System.assertEquals(cronJob.Id, cronTrigger.CronJobDetailId);
    }
    }
    
     static testMethod void testSendArticlestToMWRichTextImages(){
        User usr = TestDataBuilder.buildTestUser(1);
         //set the knowledge user permission to manage knowledge
         usr.UserPermissionsKnowledgeUser = true;
         insert usr;
        //Re-create Send Articles custom setting
        csb.buildSendArticlesSettings();
        //Re-create Integration Settings
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         system.runAs(usr){
        //create test document to be used as attachment
        Document att1 = TestDataBuilder.buildTestDocument(1);
        insert att1;
        
        //create test Article 
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
        faq.Answer__c = 'answers <img src="test.jpg" ></img>';
        faq.Internal_Notes__c = 'notes <img src="https://'+URL.getSalesforceBaseUrl().getHost()+'/img/test.jpg" ></img>';
        faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
        faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
        faq.Related_Articles__c = 'articles <img src="test.jpg" ></img>';
        faq.Attachment_2__Body__s = att1.Body;
        faq.Attachment_2__ContentType__s = 'text/plain';
        faq.Attachment_2__Name__s = att1.Name;
        faq.Attachment_3__Body__s = att1.Body;
        faq.Attachment_3__ContentType__s = 'text/plain';
        faq.Attachment_3__Name__s = att1.Name;
        faq.Attachments__Body__s = att1.Body;
        faq.Attachments__Name__s = att1.Name;
        faq.Attachments__ContentType__s = 'text/plain';
        faq.Language='en_US';
        faq.IsVisibleInCSP = true;
        faq.ValidationStatus = 'Externally Validated';
        insert faq;
        
        //retrieve created test article to get KnowledgeArticleId
        FAQ__kav faqDr = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName,Language From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
        System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article language:'+faqDr.Language);
         
        //publish test draft article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.KnowledgeArticleId, false);
        
        //retrieve online article
        FAQ__kav faqOn = [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Online'  AND Title = : faqDr.Title ];
        System.Debug('@@faqDr article:'+faqDr.KNowledgeArticleId);
         System.Debug('@@faqDr article language:'+faqDr.Language);
        //make a draft version of the test online article
        String Draftid = KbManagement.PublishingService.editOnlineArticle ((ID)faqOn.KnowledgeArticleId, false);
        
        //Retrieve and update created Draft article
        for (FAQ__kav fa : [Select Id, ArticleNumber, GeckId__c, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : DraftId ]){
            fa.Title = 'test article updated';
            //publish test draft article
            update fa;
            KbManagement.PublishingService.publishArticle( (Id)fa.KnowledgeArticleId, false);   
        }
        
        //Test rich text images
        SendArticlesToMW saw = new SendArticlesToMW();
        saw.testTheImages();
        
        //create a test response for webservice callout
        SendArticlesToMWImagesTestMock mock = new SendArticlesToMWImagesTestMock();
        Test.setMock(WebServiceMock.class,mock);
        
        //execute main method for sending articles
        Test.startTest();
            SendArticlesToMW.sendArticles(UserInfo.getSessionId());
        Test.stopTest();
        }
        
    }
    
    
}