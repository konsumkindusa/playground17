/**
 *@author Original: Faina Gorelik 
 *@date Original:   7 July 2015
 *@description:  this is a controller class for running opportunity ReOrg process
 */

public with sharing class OpportunityMassReOrgController {

        public boolean isSuccess{get;set;}
        public String RunningUserId{get;set;}
        public DateTime LastRunTime{get;set;}
        public string LastJobId{get;set;}
        public string LastStatus{get;set;}
        public Boolean isDisabled{get;set;}
        Opportunity_Mass_Reorg__c  optset;
    
    // Start ReOrg process calling Batchable class
    public void ReOrgOpty(){    
    
        Logger.push('ReOrgOpty', 'OpportunityMassReOrgController');
      
        // Start the reorg job
            OpportunityAssignmentManagerBatchable ReOrgOpportunity = new OpportunityAssignmentManagerBatchable();
            ID LastJobId = Database.executeBatch(ReOrgOpportunity);
            isDisabled = true;
            
          // populate custom settings 
            optset = Opportunity_Mass_Reorg__c.GetOrgDefaults();
            optset.Last_Run_Time__C = System.Now();
            optset.Last_Running_User__c = UserInfo.getName() ;
            optset.Reorg_Job_Id__c = LastJobId;
            AsyncApexJob ReorgJob = [Select Id, Status from AsyncApexJob where id =:LastJobId];
            optset.Job_Status__c = ReorgJob.Status;
            try{
            upsert optset;
            }
            catch (Exception e)
            {
             Logger.debugException(e);
            }
            
            
            Logger.pop(); 
               
    }
    
    Public void UpdateCustomSetting(){
     Logger.push('UpdateCustomSetting', 'OpportunityMassReOrgController');
    // get last running job id from the custom setting
        isDisabled = false;
        optset = Opportunity_Mass_Reorg__c.GetOrgDefaults();
        LastJobId = optset.Reorg_Job_Id__c;
        System.Debug('faina Last Job id' + LastJobId);
     // get the status of the last running job, disable reorg opportunity button if job is not completed
      if (LastJobId !='' && LastJobId !=null){
      AsyncApexJob LastJob = [Select Status from AsyncApexJob where id =:LastJobId];
      optset.Job_Status__c = LastJob.Status;
      try{
      upsert optset;
      }
      catch (Exception e)
       {
         Logger.debugException(e);
       }
      if (LastJob.Status != 'Completed'){
          isDisabled = true;
      }
    
     
      }
    Logger.Pop();
    }


}