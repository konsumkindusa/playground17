/*
*@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade- Cloud Sherpas/Mathworks
*@date Original:  23 July 2014, Last Modified: 25 Nov 2014
*@description This  is Test class for 'OpportunityLineItemTriggerHandler' class . 
*/
@isTest
public with sharing class OpportunityLineItemTriggerHandlerTest {
   
   /*
     @name    testCreateLeadRelatedCont
     @date    23 July .2014
     @author  Divya Gawade
     @param   none.
     @return  Void.                              
    */

   static testMethod void testOppoProdWithTopicAssign(){
       
       //re-create custom setting test records when running the test class
       CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
           
       //Inserting Bypass trigger custom setting
       custsettbuild.buildBypassTriggerSettings();
       
       custsettbuild.buildGenSetting();
       
       List<Account> accLLst =new List<Account>();
        
       //prodList to add all product record.
       List<Product2> prodLst = new List<Product2>();
      
       //pricebookLst to add all standard pricebookentry record.
       List<PricebookEntry> pricebookEntryLst = new List<PricebookEntry>();
       
       //oppLst to add created opportunity.
       List<Opportunity> oppLst = new List<Opportunity>();
      
       //oppLineItemLst to add created opportunity product.
       List<OpportunityLineItem> oppLineItemLst = new List<OpportunityLineItem>();
       
       //oppLst to add created opportunity.
       List<Topic> topicLst = new List<Topic>();
       
       //oppLst to add created opportunity.
       List<TopicAssignment> topAssignLst = new List<TopicAssignment>();
       
       //create Account record from TestDataBuilder.
        
       for(Integer i=0;i<1;i++){
           Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
           accL.BillingCity ='Rio De Janeiro';
           accL.BillingCountry = 'Brazil';
           accL.BillingCountryCode ='BR';
           accL.BillingState ='Acre';
           accL.BillingStateCode = 'AC';
           accLLst.add(accL);         
       }
       
       insert accLLst;
       //create Product record from TestDataBuilder.
       
       for(Integer i=0;i<4;i++){
           Product2 prod = TestDataBuilder.buildTestProduct(i);
           prod.Topic__c ='abc'+i;
           prodLst.add(prod);         
       }
       insert prodLst;
       
       // Get standard price book ID.
       Id standardPB = System.Test.getStandardPricebookId();
        
       //create PricebookEntry record from TestDataBuilder.
    
       for(Integer i=0;i<4;i++){
           PricebookEntry pricebookEntry = TestDataBuilder.buildTestPricebookEntry(i);
           pricebookEntry.UnitPrice = 100;
           pricebookEntry.Pricebook2Id = standardPB;
           pricebookEntry.Product2Id=prodLst[i].Id;
           pricebookEntry.isActive = true;
           pricebookEntryLst.add(pricebookEntry);         
       }
       insert pricebookEntryLst;
       
        //create Opportunity record from TestDataBuilder.

       for(Integer i=0;i<4;i++){
           Opportunity oppo = TestDataBuilder.buildTestOpportunity(i);
           oppo.AccountId = accLLst[0].Id;
           oppo.Pricebook2Id = standardPB ;
           oppLst.add(oppo);         
       }
       insert oppLst;
       
       //create topic record from TestDataBuilder.
       
       for(Integer i=0;i<4;i++){
          Topic topic = TestDataBuilder.buildTestTopic(i);
          Topic.Name ='abc'+i;
          
          topicLst.add(topic);
       }
       insert topicLst;
       
       for(Integer i=0;i<2;i++)
       {
           TopicAssignment topassign = new TopicAssignment();
           topassign.topicId = topiclst[i].Id;
           topassign.EntityId = oppLst[i].Id;    
           topAssignLst.add(topassign);
       }
       
       insert topAssignLst;
       
       //create OpportunityLineItem record from TestDataBuilder.
        test.startTest();
       for(Integer i=0;i<4;i++){
           for(Integer j=0;j<4;j++){
           OpportunityLineItem oppLineItem = TestDataBuilder.buildTestOpportunityLineItem(i);
           oppLineItem.OpportunityId= oppLst[j].Id;
           oppLineItem.PricebookEntryId= pricebookEntryLst[i].id;
           oppLineItemLst.add(oppLineItem);    
           }     
       }
      
       
       //List<Topic> toList = [select id, name from topic];
       List<String> toNames = new List<String>();
       
       Set<ID> opptySet = new Set<Id>();
       for(Topic to: topicLst){
            toNames.add(to.name);
       }
       for(Opportunity op: oppLst){
            opptySet.add(op.Id);
       }
      
       
       insert oppLineItemLst;
       
       List<TopicAssignment> taList = [select TopicId,EntityId,Topic.Name from TopicAssignment where Topicid in (select id from topic where name in: toNames) and EntityId in :opptyset];
       System.assert(taList.size() > 0);
       for(TopicAssignment ta: taList){
              
              System.assert((ta.Topic.Name).contains('abc'));
       }
       test.stopTest();
       
 }
    /*
     @name    testCreateLeadRelatedCont
     @date    23 July .2014
     @author  Divya Gawade
     @param   none.
     @return  Void.                              
    */
    
    static testMethod void testOppoProdWithoutTopicAssign(){
       
      
       //re-create custom setting test records when running the test class
       CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
   
        
       //Inserting Bypass trigger custom setting
       custsettbuild.buildBypassTriggerSettings();
       
       custsettbuild.buildGenSetting();
        
       List<Account> accLLst =new List<Account>();
        
       //prodList to add all product record.
       List<Product2> prodLst = new List<Product2>();
      
       //pricebookLst to add all standard pricebookentry record.
       List<PricebookEntry> pricebookEntryLst = new List<PricebookEntry>();
       
       //oppLst to add created opportunity.
       List<Opportunity> oppLst = new List<Opportunity>();
      
       //oppLineItemLst to add created opportunity product.
       List<OpportunityLineItem> oppLineItemLst = new List<OpportunityLineItem>();
       
       //oppLst to add created opportunity.
       List<Topic> topicLst = new List<Topic>();
       
       //create Account record from TestDataBuilder.
        
       for(Integer i=0;i<1;i++){
           Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
           accL.BillingCity ='Rio De Janeiro';
           accL.BillingCountry = 'Brazil';
           accL.BillingCountryCode ='BR';
           accL.BillingState ='Acre';
           accL.BillingStateCode = 'AC';
           accLLst.add(accL);         
       }
       
       insert accLLst;
       //create Product record from TestDataBuilder.
       
       for(Integer i=0;i<2;i++){
           Product2 prod = TestDataBuilder.buildTestProduct(i);
           prod.Topic__c ='testtopic'+i;
           prodLst.add(prod);         
       }
       insert prodLst;
       
       // Get standard price book ID.
       Id standardPB = System.Test.getStandardPricebookId();
        
       //create PricebookEntry record from TestDataBuilder.
    
       for(Integer i=0;i<2;i++){
           PricebookEntry pricebookEntry = TestDataBuilder.buildTestPricebookEntry(i);
           pricebookEntry.UnitPrice = 100;
           pricebookEntry.Pricebook2Id = standardPB;
           pricebookEntry.Product2Id=prodLst[i].Id;
           pricebookEntry.isActive = true;
           pricebookEntryLst.add(pricebookEntry);         
       }
       insert pricebookEntryLst;
       
        //create Opportunity record from TestDataBuilder.

       for(Integer i=0;i<2;i++){
           Opportunity oppo = TestDataBuilder.buildTestOpportunity(i);
           oppo.AccountId = accLLst[0].Id;
           oppo.Pricebook2Id = standardPB ;
           oppLst.add(oppo);         
       }
       insert oppLst;
       
       //create topic record from TestDataBuilder.
       
       for(Integer i=0;i<2;i++){
          Topic topic = TestDataBuilder.buildTestTopic(i);
          Topic.Name ='topic'+i;
          topicLst.add(topic);
       }
       insert topicLst;
       
             
     //create OpportunityLineItem record from TestDataBuilder.

       for(Integer i=0;i<2;i++){
           OpportunityLineItem oppLineItem = TestDataBuilder.buildTestOpportunityLineItem(i);
           oppLineItem.OpportunityId= oppLst[i].Id;
           oppLineItem.PricebookEntryId= pricebookEntryLst[i].id;
           oppLineItemLst.add(oppLineItem);         
       }
       test.startTest();
       insert oppLineItemLst;
       
     
       test.stopTest();
       
         
       
      TopicAssignment tassign = [select TopicId,EntityId,Topic.Name from TopicAssignment where EntityId = : oppLst[0].id];
       System.debug('tassign' +tassign );
       
       System.assert(tassign.Topic.Name != 'testtopic' );
        
       
 }
 
}