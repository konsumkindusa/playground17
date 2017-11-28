/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified:Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik - MW
 *date Original: 12 June 2015, Last Modified:12 June 2015 , 17 August 2015
 *description : Batch class for OpportunityAssignmentManager, changes by Faina - added paramter to the class Statuful to keep the list of all opty ids for the Owner role update batch job*/
global with sharing class OpportunityAssignmentManagerBatchable implements Schedulable, Database.Batchable<sObject>,Database.Stateful{
    
    //String will hold the query
    global String Query;
    global  List<id> optyIds;
    General_Settings__c settings ;
   
    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified:Andy Ognenoff - Cloud Sherpas/Mathworks
     *date Original: 12 June 2015, Last Modified:01 July 2015  
     *description : Constructor which initialises the Query*/   
    global OpportunityAssignmentManagerBatchable(){
    
        optyIds = new List<id>();
        Query = 'SELECT ID FROM Opportunity WHERE Batch_Evaluate__c =True and isClosed =False and Locked__c =False';    
    }//OpportunityAssignmentManagerSchedulable

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified:Archana Lohar - Cloud Sherpas/Mathworks
     *date Original: 12 June 2015, Last Modified:12 June 2015 
     *description : Start method
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }//start

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified:Archana Lohar - Cloud Sherpas/Mathworks
     *date Original: 12 June 2015, Last Modified:12 June 2015 
     *description : BatchableContext Execute method
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    
        //Collect current batch opportunity ids
        List<id> optyIdLst= new List<id>();

        for(sobject s : scope){
            Opportunity oppObj = (Opportunity)s;
            optyIds.add(oppObj.id);
            optyIdLst.add(oppObj.id);
        }//for


        OpportunityAssignmentManager.assignOpportunitiesByTerritoryTeamRoles(optyIdLst);
        

    }//execute

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *date Original: 19 Jan 2015, Last Modified:19 Jan 2015 
     *description : SchedulableContext Execute method with the batch size as defined in the Territory Settings custom settings
     */
    global void execute(SchedulableContext ctx){
        //get the batch size from the custom settings and use it to execute the job
        Integer batchSize = Integer.ValueOf(settings.BatchSizeForOpportunityAssignmentManager__c);       
        ID batchprocessid = Database.executeBatch(this,batchSize);
    }//execute   

    /**
     *author Original: Faina Gorelik, Last Modified: 
     *date Original: 05 July 2015, date modified : 06 August 2015
     *description : Finish method sends email with the job status to the current user, invoke second batch job to update Opportunity Functional role if opty owner role has been changed 
     the second job can be invoked only if the first job is successfull
     **/
    global void finish(Database.BatchableContext BC){
    
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('ReOrg Opportunity Job ' + a.Status);
       mail.setPlainTextBody('The ReOrg Job ID ' + a.Id + ' has been completed '+ a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
       
    // check if first job is success then kick of the second job
    if (a.Status == 'Completed' && optyIds.size() > 0) {
    // add check if opty is not null and opty size > 0) before call next line
        UpdateOpportunityFunctionalRoleBatchable batchJob = new UpdateOpportunityFunctionalRoleBatchable(optyIds);
        Database.executebatch(batchJob);
      }
    
    }//finish

}//OpportunityAssignmentManagerSchedulable class