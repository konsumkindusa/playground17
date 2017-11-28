/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 01 Aug 2013, Last Modified: 22 October 2013
* @description Test Class for testing functionality of CaseArticleInfoEmailTemplateController
*/ 
@isTest 
private class CaseArticleInfoEmailTemplateCtrlrTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    static testMethod void testCaseArticleInfoEmailTemplate() {
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        user testUser = TestDataBuilder.buildTestUser(100);
        testUser.UserPermissionsKnowledgeUser = true;
        
        system.runAs(testUser){
        
        //Create test Case
        Case cse = TestDataBuilder.buildTestCase('Open');
        insert cse;
        
        //Create test article
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        //add images to richtext field to create attachment
        faq.Answer__c = '<img src=\'http://test.com/image.jpg\'></img><img src=\'http://test.com/image3.jpg\'></img><img src=\'http://test.com/image2.jpg\'></img>';
        insert faq;
        
        //Retrieve created test article
        FAQ__kav faqDr = [Select Id, KnowledgeArticleId, Title, URLName From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft' limit 1];
        //update faq;
        
        //Test Publish article
        KbManagement.PublishingService.publishArticle( (Id)faqDr.get('KnowledgeArticleId'), false);
        
        //Create Case - Article junction record
        CaseArticle cseArc = new CaseArticle();
        cseArc.CaseId = cse.Id;
        cseArc.KnowledgeArticleId = faqDr.KnowledgeArticleId;
        insert cseArc;
        
        Test.startTest();
        
        	//Test Case Article with attachment
        	CaseArticleInfoEmailTemplateController caietc = new CaseArticleInfoEmailTemplateController();
        	caietc.cseId = cse.Id;
        	caietc.getcseId();
        	caietc.getcse();
        	caietc.getArticleWrList();
        	caietc.getSize();
        	
        	//Catch exception
        	CaseArticleInfoEmailTemplateController caietc2 = new CaseArticleInfoEmailTemplateController();
        	caietc2.getArticleWrList();
        	
        Test.stopTest();
        
        }    
        
        //No available data to assert 
        
    }
}