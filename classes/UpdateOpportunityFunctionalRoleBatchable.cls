/**
 *author Original: Faina Gorelik, Last Modified
 *date Original: 06 August 2015, Last Modified 
 *description : Batch class for Updating Opportunity Territory Role Name during opportunity ReOrg process*/

global with sharing class UpdateOpportunityFunctionalRoleBatchable implements Database.Batchable<sobject>
{

  global String Query;  
  List<Id> optyIdList = new List<Id>();
  
 
  
  global UpdateOpportunityFunctionalRoleBatchable(List<Id> optyIds){
      System.Debug ('faina' + optyIds);
      optyIdList = optyIds;
      Query = 'SELECT ID, Territory_Team_Role__c, Owner_Current_Role__c FROM Opportunity WHERE ID in :optyIdList';
 
  
  }
  
   global Database.QueryLocator start(Database.BatchableContext BC)
   {      
      return Database.getQueryLocator(query);
   }
   global void execute(Database.BatchableContext BC,List<Opportunity> scope)
   {
     Logger.push('execute',' UpdateOpportunityFunctionalRoleBatchable');
     List <Opportunity> opty = new List<Opportunity>();
    try
    {
          for(Opportunity o: scope)
             {
                 o.Territory_Team_Role__c = o.Owner_Current_Role__c;     
                 opty.add(o);      
             }
                   
                     update opty;
        
    }
    catch (Exception e)
    {
         Logger.debugException(e);
    }
        
        Logger.pop();
   }

   global void finish(Database.BatchableContext BC)
   {
      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('The Update Opportunity Territory Team Role Job ID ' + a.Status);
       mail.setPlainTextBody('The Update Opportunity Territory Team Role Job ID ' + a.Id + ' has been completed '+ a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
   }
}