/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks, Faina Gorelik MathWorks AtTask 2238455 add trigger on after update
 *@date Original:   29 July 2015, Last Modified: 29 July 2015, August 2017
 *@description:      This trigger is used to handle different trigger actions for Enterprise Training Agreement
 */
trigger EnterpriseTrainingAgreementMasterTrigger on Enterprise_Training_Agreement__c (before insert, before update,after insert,after update,after delete) {
        
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
            
    //instantiating  the handler class ETrainingAgreementTriggerHnadler  which handles the trigger events for Enterprise Training Agreement object.
    ETrainingAgreementTriggerHandler  eTAgreementHandler = new ETrainingAgreementTriggerHandler();
              
     if (bypass.Trigger_Objects__c.contains('EnterpriseTrainingAgreement') && !bypass.Triggers_Disabled__c){
        if(trigger.isAfter){
        
            if(trigger.isInsert)
            {   
               eTAgreementHandler.onAfterInsert(Trigger.new);
        
            }
            
            if (trigger.isUpdate){
                eTAgreementHandler.onAfterUpdate(trigger.oldmap, trigger.newmap);  
            }
        }
         
      
    }
}