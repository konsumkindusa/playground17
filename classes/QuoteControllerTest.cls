@isTest
public class QuoteControllerTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /*
    @ name    oppIdrelatedquoteTest
    @ date    8.August.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Void. 
    @ description :Expected 
     */
    private static testMethod void oppIdrelatedquoteTest() {
         User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        csb.buildQuoteIntegrationSettings();
        csb.buildIntegrationSetting();
        //re-create address latin conversion Custom Setting
        csb.buildAddressLatinTranslation();
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
         //fetch general setting instance
        QuoteIntegrationSettings__c settings = QuoteIntegrationSettings__c.getInstance();
        System.runAs(usr){
            
        Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
                acc.Name = 'Smith';
                acc.BillingCity ='Boston';
                acc.BillingCountry = 'United States';
                acc.BillingCountryCode = 'US';
                acc.BillingPostalCode ='400011';
                acc.BillingStateCode ='AK';
                acc.BillingState ='Alaska';
                acc.BillingStreet = 'MG Street';
                acc.County__c = 'abc';
                acc.Siebel_Account_Id__c = '1-CS15';
                insert acc;
    
            
                Contact cont= TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),acc.id);
                cont.MailingCity = 'Bombay';
                cont.MailingCountry = 'India';
                cont.MailingCountryCode = 'IN';
                cont.MailingPostalCode ='400011';
                cont.MailingState ='Maharashtra';
                cont.MailingStateCode = 'MH';
                cont.MailingStreet = 'MG Street';
                cont.County_Local__c = 'abc';
                cont.email ='john@gmail.com';
                cont.Siebel_Contact_Id__c = '1-1JAHOZ';
                insert cont;         
         
           // Get standard price book ID.
           Id standardPB = System.Test.getStandardPricebookId();
           
            List<Opportunity > oppLst = new  List<Opportunity >();
           //create Opportunity record from TestDataBuilder.
            for(Integer i=0;i<2;i++){
               Opportunity oppo = TestDataBuilder.buildTestOpportunity(i);
               oppo.Pricebook2Id = standardPB ;
               oppo.AccountID = acc.ID;
               oppLst.add(oppo);         
           }
           insert oppLst;
           
           system.assertEquals(oppLst.size(),2);
           
            //set current page 
            PageReference oppoPage = Page.OpportunityViewQuote;
            Test.setCurrentPage(oppoPage);
      
            //Opportunity standardCtrlCon = new Opportunity();
            //QuoteController controller = new QuoteController(new ApexPages.StandardController(standardCtrlCon));
            
            Opportunity oppty = new Opportunity();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(oppLst[1]);
            QuoteController controller = new QuoteController(standardCtrlCon);
            controller.firstPageOfQuote();
            controller.previousOfQuote();
            controller.nextOfQuote();
            controller.LastPageOfQuote();
            controller.getprev();
            controller.getnxt();
            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimock1 = new MultiStaticResourceCalloutMock();
            settings = QuoteIntegrationSettings__c.getInstance();
            //Getting url from General setting
            String url = settings.GQOQuoteBaseURL__c ;
            multimock1.setStaticResource(
                    url+'?opportunityId='+ oppLst[1].Id , 'mockResponseTestOppo');
                    
            multimock1.setStatusCode(200);
            multimock1.setHeader('Content-Type', 'application/json');

            Test.startTest();
            //search quotes
            Test.setMock(HttpCalloutMock.class, multimock1);
            
            controller.getQuotesOfOpportunityRecord(); 
            Test.stopTest();
            
    }
  }
}