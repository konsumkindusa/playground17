/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 25 July 2013, Last Modified: 24 Aprilr 2015
* @description Class to handle delegated DML operations for FeedItem object.
*/
@isTest 
private class FeedItemDMLTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    static testMethod void testCreateArticleOnFeedbackPost() {
            
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
            
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            
            //Create Test Knowledge Article
            FAQ__kav faqArticle = new FAQ__kav();
            faqArticle.Title = 'testarticle';
            faqArticle.urlname='codecoveragetestarticle1';
            Database.SaveResult result = Database.Insert(faqArticle,true);
            String parentId = null;

            if(result != null && result.isSuccess()){
                parentId = result.getId();
            }
                
        list <FAQ__DataCategorySelection> faqdclist = new list <FAQ__DataCategorySelection>();
        FAQ__DataCategorySelection faqdcP = TestDataBuilder.buildTestFAQDataCategories(parentId, 'Product', 'All_Products');
        faqdclist.add(faqdcP);
        FAQ__DataCategorySelection faqdcTy = TestDataBuilder.buildTestFAQDataCategories(parentId, 'Type', 'Enhancement');
        faqdclist.add(faqdcTy);
        FAQ__DataCategorySelection faqdcT = TestDataBuilder.buildTestFAQDataCategories(parentId, 'Topic', 'All');
        faqdclist.add(faqdcT);
        FAQ__DataCategorySelection faqdcPS = TestDataBuilder.buildTestFAQDataCategories(parentId, 'Platform_OS', 'All');
        faqdclist.add(faqdcPS);
        FAQ__DataCategorySelection faqdcVR = TestDataBuilder.buildTestFAQDataCategories(parentId, 'Verified_in_Release', 'R2013a');
        faqdclist.add(faqdcVR);
        insert faqdclist;
    
            //Retrieve created test Knowledge Article
            faqArticle = [Select ID, urlname, knowledgeArticleId,PublishStatus from FAQ__kav where id = : parentId];
            
            //to publish an article
            if(faqArticle.PublishStatus =='draft'){
                KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
            }
            
            //Create Test FeedItem
            FeedItem fitem = TestDataBuilder.buildTestFeedItem(0, faqArticle.knowledgeArticleId, 'TextPost');
            fitem.Body = '#Feedback';
            
            Test.startTest();
                //Insert FeedItem on Knowledge Article
                insert fitem;
            Test.stopTest();
            
            //Retrieve created Article Feedback
            //SS 4/24/15 Added Feed_Id__c field in the query - story 840580
            list <Article_Feedback__c> artfbacks = [Select Id, Feed_Id__c, Comments__c From Article_Feedback__c where Article_Id__c = : faqArticle.KnowledgeArticleId];
            
            //Verify that Article Feedback record is created for inserted FeedItem
            system.assertEquals(artfbacks.size(),1);
            system.assertEquals(artfbacks[0].Feed_Id__c,fitem.Id); //SS 4/24/15 Added new assert - story 840580
        }
            
    }
    
    
    static testMethod void testdeleteFeeditem() {
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            
            //Create Test Knowledge Article
            FAQ__kav faqArticle = new FAQ__kav();
            faqArticle.Title = 'testarticle';
            faqArticle.urlname='codecoveragetestarticle1';
            Database.SaveResult result = Database.Insert(faqArticle,true);
            String parentId = null;

            if(result != null && result.isSuccess()){
                parentId = result.getId();
            }
                
            
            //Retrieve created test Knowledge Article
            faqArticle = [Select ID, urlname, knowledgeArticleId,PublishStatus from FAQ__kav where id = : parentId];
            
            //to publish an article
            if(faqArticle.PublishStatus =='draft'){
                KbManagement.PublishingService.publishArticle(faqArticle.KnowledgeArticleId, true);
            }
            
            //Create Test FeedItem
            FeedItem fitem = TestDataBuilder.buildTestFeedItem(0, faqArticle.knowledgeArticleId, 'TextPost');
            fitem.Body = 'Feedback';
            insert fitem;
            
            FeedComment fc = new FeedComment(
            feedItemId = fitem.Id,
            commentBody =  Label.DeleteFeedITem
            ); 
            
            test.startTest();
            insert fc;
            test.stopTest();
            
            list <Feeditem> listFeedtiem = [Select Id from Feeditem where Id = : fitem.Id];
            
            system.assertEquals(listFeedtiem.size(),0);
            
        }
    }
    
    
    
}