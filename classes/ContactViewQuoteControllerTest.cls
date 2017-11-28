@isTest
public class ContactViewQuoteControllerTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild= new CustomSettingsBuilder();
    
    /*
    @name    contIdrelatedquoteTest
    @date    9.September.2014
    @author  Divya Gawade
    @param   none.
    @return  Void. 
    @description :Expected 
     */
    private static testMethod void contIdrelatedquoteTest() {
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        //re-create Quote Integration Custom Setting
        custsettbuild.buildQuoteIntegrationSettings();
        //re-create Integration Custom Setting
        custsettbuild.buildIntegrationSetting();
        custsettbuild.buildGenSetting();
         //fetch quote Integration setting instance
        QuoteIntegrationSettings__c settings = QuoteIntegrationSettings__c.getInstance();
         //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
       
        
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
           
           //fg insert contact into opportunity contact role table
           Opportunity optToInsert = oppLst[0];
           //Insert contact into first opportunity contact role
           OpportunityContactRole OptyContactRoleTest = TestDataBuilder.builOpportunityContactRole(cont.id,optToInsert.id);
            OptyContactRoleTest.contactid=cont.id;
            OptyContactRoleTest.OpportunityId = optToInsert.id;
            OptyContactRoleTest.role ='Other';
            Insert OptyContactRoleTest;
           // fg
           
           system.assertEquals(oppLst.size(),2);
           
            //set current page 
            PageReference contPage= Page.ContactViewQuote;
            Test.setCurrentPage(contPage);
      
            
            Contact con = new Contact();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(cont);
            ContactViewQuoteController controller = new ContactViewQuoteController(standardCtrlCon);
            
            // Use MultiStaticResourceCalloutMock to
            // specify fake response for a certain endpoint and 
            // include response body in a static resource.    
            MultiStaticResourceCalloutMock multimockgetQuotes = new MultiStaticResourceCalloutMock();
           
            multimockgetQuotes.setStaticResource(settings.GQOQuoteBaseURL__c + +'?contactId='+
             + cont.Siebel_Contact_Id__c, 'mockResponseTestOppo');
            multimockgetQuotes.setStatusCode(200);
            multimockgetQuotes.setHeader('Content-Type', 'application/json');
            
            
            Test.startTest();
            //search quotes
            Test.setMock(HttpCalloutMock.class, multimockgetQuotes);
            controller.getQuotesOfContactRecord(); 
            controller.firstPageOfQuote();
                controller.previousOfQuote();
                controller.nextOfQuote();
                controller.LastPageOfQuote();
                controller.getprev();
                controller.getnxt();
                
                  
            
           if(controller.GQOQuotLst.size() > 0)
            {
                controller.selectedquoteId = string.valueOf(controller.GQOQuotLst[0].ID);
                controller.getOppty();
                controller.selectedoppoId = controller.opptyList[0].Id;
                
                MultiStaticResourceCalloutMock multimocklinkQuote = new MultiStaticResourceCalloutMock();
                system.debug('**************** linkquote URL is ' + settings.GQOQuoteBaseURL__c + '/'  +
                 controller.selectedquoteId);
                multimocklinkQuote.setStaticResource(settings.GQOQuoteBaseURL__c + '/'  +
                controller.selectedquoteId,'mockResponseTestOppo');
                multimocklinkQuote .setStatusCode(200);
                multimocklinkQuote.setHeader('Content-Type', 'application/json');
                Test.setMock(HttpCalloutMock.class, multimocklinkQuote );
                //search quotes
                controller.setJsonStringForOpp();
            }                    
            Test.stopTest();
    }
  }
  

  
}