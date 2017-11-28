/*
 *    @description: tests the ContactViewTrialController
 */
@isTest(seeAllData=false)
public with sharing class ContactViewTrialControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /*
    @ name    TestShowTrialsRelatedToContact
    @ date    10.Oct.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :Expected that it  will show all the trials related to the contact record. 
     */
     @isTest static  void TestShowTrialsRelatedToContact(){

        List<Contact> conLst =new List<Contact>();
        List<Account> accLst =new List<Account>();

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        
        //re-create general Custom Setting
        csb.buildTrialsIntegrationSetting();
        
        //re-create address latin conversion Custom Setting
        csb.buildAddressLatinTranslation();
        
        csb.buildLicensesIntegrationSetting();
      
        csb.buildIntegrationSetting();
        System.runAs(usr){
            
         for(Integer i=0;i<3;i++){
             
            Account accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCity ='Rio De Janeiro';
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';
            accObj.BillingPostalCode = '1111';
            accObj.BillingStreet = 'aa street';
            accLst.add(accObj);
          }
            
          insert accLst;
          
         //create Contact record from TestDataBuilder.
          for(Integer i=0;i<3;i++){
              
            Contact contL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLst[i].id);
            contL.MailingCity = 'Bombay';
            contL.MailingCountry = 'India';
            contL.MailingCountryCode = 'IN';
            contL.MailingPostalCode ='400011';
            contL.MailingState ='Maharashtra';
            contL.MailingStateCode = 'MH';
            contL.MailingStreet = 'MG Street';
            contL.County_Local__c = 'abc';
            contL.email = 'john@gmail.com';
            contL.MathWorks_Account_ID__c='498836';

            conLst .add(contL);

            }
            insert conLst;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

            //set current page 
            PageReference trialsPage = Page.ContactViewTrials;
            Test.setCurrentPage(trialsPage);
           
            Test.startTest();

            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(conLst[1]);
            ContactViewTrialController controller = new ContactViewTrialController(standardCtrlCon);
            
            controller.getshowTrialsRelatedToOpportunityTest(); 
            
            controller.FirstPage();
            controller.previous();
            controller.next();
            controller.LastPage();
            controller.getprev();
            controller.getnxt();
            system.assertEquals(controller.trialList.size(),3);
            
            controller.selTrialid='1930281';
            controller.selectTrial();
           
            system.assert(controller.relatedProductList.size()!=null);
            system.assert(controller.relatedPeopleList.size()!=null);
            system.assertEquals(controller.selectedTrialList.size(),1);
            
            
            controller.FirstConPage();
            controller.previousCon();
            controller.nextCon();
            controller.LastConPage();
            controller.getConprev();
            controller.getConnxt();
            Test.stopTest();
            system.assert(controller.trialList.size()!=null);
            
        }

    }
}