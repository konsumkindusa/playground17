/**
* @author Original: kishore AN - Cloud Sherpas/Mathworks  
* @date Original:17 October 2013, Last Modified: 17 October 2013
* @description test class for CaseGeckCreationController
*/

@isTest(SeeAllData = true)
private class CaseGeckCreationControllerTest {

    static testMethod void populateArticlesTest(){
        
        User usr = TestDataBuilder.buildTestUser(1);
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
        
        System.runAs(usr){
        
            //create test account
            Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
            insert acc;
            
            //create test contact
            Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
            con.Email = 'test@test.com';
            insert con;
            
            //create test case 
            Case cse = TestDataBuilder.buildTestCase('Open');
            cse.AccountId = acc.Id;
            cse.ContactId = con.Id;
            insert cse;
            
            FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
            faq.Answer__c = 'answers <img src="test.jpg" ></img>';
            faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
            faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
            faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
            
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
            
            
            CaseArticle ca = new CaseArticle();
            ca.CaseId = cse.Id;
            ca.KnowledgeArticleId = faqDr.KnowledgeArticleId;
            ca.ArticleLanguage = 'en_US';
            
            insert ca;
            
            
            Test.startTest();
            
                Pagereference pref = Page.CaseGeckCreationPage;
                pref.getParameters().put('Id', cse.Id);
                Test.setCurrentPage(pref);
                Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
                CaseGeckCreationController cpcsex = new CaseGeckCreationController(stdctlr);
                cpcsex.caseCreateEscalationURL();
            Test.stopTest();
        }
    }
    
    static testMethod void populateArticlesNoCaseArticleTest(){
        
        User usr = TestDataBuilder.buildTestUser(1);
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
        
        System.runAs(usr){
        
            //create test account
            Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
            insert acc;
            
            //create test contact
            Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
            con.Email = 'test@test.com';
            insert con;
            
            //create test case 
            Case cse = TestDataBuilder.buildTestCase('Open');
            cse.AccountId = acc.Id;
            cse.ContactId = con.Id;
            insert cse;
            
            FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
            faq.Answer__c = 'answers <img src="test.jpg" ></img>';
            faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
            faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
            faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
            
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
            
            
            
            Test.startTest();
            
                Pagereference pref = Page.CaseGeckCreationPage;
                pref.getParameters().put('Id', cse.Id);
                Test.setCurrentPage(pref);
                Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
                CaseGeckCreationController cpcsex = new CaseGeckCreationController(stdctlr);
            Test.stopTest();
        }
    }
    
    
    static testMethod void generateGekoURLTest(){
        
        User usr = TestDataBuilder.buildTestUser(1);
        usr.UserPermissionsKnowledgeUser = true;
        insert usr;
        
        System.runAs(usr){
            //create test account
            Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
            insert acc;
            
            //create test contact
            Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
            con.Email = 'test@test.com';
            insert con;
            
            //create test case 
            Case cse = TestDataBuilder.buildTestCase('Open');
            cse.AccountId = acc.Id;
            cse.ContactId = con.Id;
            insert cse;
            
            FAQ__kav faq = TestDataBuilder.buildTestFAQkav(0);
            faq.Answer__c = 'answers <img src="test.jpg" ></img>';
            faq.Internal_Notes__c = 'notes <img src="test.jpg" ></img>';
            faq.KCS_Comments__c = 'comments <img src="test.jpg" ></img>';
            faq.Question_RT__c = 'question <img src="test.jpg" ></img>';
            faq.question__c = 'test question';
            insert faq;
            
            //create test data categories
            list <FAQ__DataCategorySelection> faqdclist = new list <FAQ__DataCategorySelection>();
            FAQ__DataCategorySelection faqdcP = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Product', 'MATLAB');
            faqdclist.add(faqdcP);
            FAQ__DataCategorySelection faqdcTy = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Type', 'Enhancement');
            faqdclist.add(faqdcTy);
            FAQ__DataCategorySelection faqdcT = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Topic', 'All');
            faqdclist.add(faqdcT);
            FAQ__DataCategorySelection faqdcPS = TestDataBuilder.buildTestFAQDataCategories(faq.Id, 'Platform_OS', 'All_OS');
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
            
            
            CaseArticle ca = new CaseArticle();
            ca.CaseId = cse.Id;
            ca.KnowledgeArticleId = faqDr.KnowledgeArticleId;
            ca.ArticleLanguage = 'en_US';
            
            insert ca;
            
            
            Test.startTest();
            
                Pagereference pref = Page.CaseGeckCreationPage;
                pref.getParameters().put('articleNumber', faqDr.ArticleNumber);
                //pref.getParameters().put('lang', 'en_US');
                Test.setCurrentPage(pref);
                Apexpages.Standardcontroller stdctlr = new Apexpages.Standardcontroller(cse);
                CaseGeckCreationController cpcsex = new CaseGeckCreationController(stdctlr);
            Test.stopTest();
        }
    }
}