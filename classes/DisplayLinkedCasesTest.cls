/**
 * FG 04/25/14
 This class contains unit tests for validating the behavior of DisplayLinkedCasescontroller class
 
 */
@isTest
private class DisplayLinkedCasesTest {

    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    static testMethod void testCaseArticle() {
    
    user testUser = TestDataBuilder.buildTestUser(100);
    testUser.UserPermissionsKnowledgeUser = true;
        
    system.runAs(testUser){
    
        //Create test Case
       //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        Case cse = TestDataBuilder.buildTestCase('open');
        
        cse.Subject = 'create article from case';
        cse.description = 'creating article from case';
        cse.Area__c = 'Natick - Customer Support';
        cse.Topic__c = 'Activation.';
        cse.platform__c = 'Windows x32';
        cse.OS__c = 'Windows 8';
        
        insert cse;
        
          //Create test article
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        //add images to richtext field to create attachment
        faq.Answer__c = '<img src=\'http://test.com/image.jpg\'></img><img src=\'http://test.com/image3.jpg\'></img><img src=\'http://test.com/image2.jpg\'></img>';
        insert faq;
         //Test Publish article
       
       Case testcase = [select Id from Case where Id =:cse.Id ];
       FAQ__kav testart = [Select Id, ArticleNumber,KnowledgeArticleId From FAQ__kav Where Language = 'en_US' AND publishstatus = 'Draft'  AND Id = : faq.Id ];
       
       KbManagement.PublishingService.publishArticle( (Id)testart.get('KnowledgeArticleId'), false);
        //Create Case - Article junction record
        CaseArticle cseArc = new CaseArticle();
        cseArc.CaseId = cse.Id;
        cseArc.KnowledgeArticleId = testart.KnowledgeArticleId;
        insert cseArc;
        
        integer index = 0;
        integer blockSize = 10;
        
        Test.startTest();
        Pagereference pref = Page.DisplayLincedCases;
        pref.getParameters().put('ArticleNumber', testart.ArticleNumber);
        Test.setCurrentPage(pref);
        DisplayLinkedCasesContoller mycontr = new DisplayLinkedCasesContoller();
        mycontr.getReq();
        mycontr.beginning();
        mycontr.previous();
        mycontr.next();
        mycontr.getprev();
        mycontr.getnxt();
        mycontr.end();
        
       
        Test.stopTest();
        }
    }
}