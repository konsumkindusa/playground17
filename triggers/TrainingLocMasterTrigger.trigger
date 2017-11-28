/**
 *@author Original: Krishna Bhaskarla - Mathworks
 *@date Original:   Aug 19, 2015
 *@description:     This trigger handles the actions on a training location object
 */
trigger TrainingLocMasterTrigger on Training_Location__c (before delete, before update) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    TrainingLocTriggerHandler trainLocHandler = new TrainingLocTriggerHandler();
    
     if (bypass.Trigger_Objects__c.contains('TrainingLocation') && !bypass.Triggers_Disabled__c){    
        if(trigger.isBefore){
             if(trigger.isDelete){   
                  trainLocHandler.onBeforeDelete(Trigger.old); 
             }
            if(trigger.isUpdate){
               /* Profile p = [SELECT Id FROM Profile WHERE Name='MW Training Admin'];
                if(p.Id != UserInfo.getProfileId()){
                    return;
                }*/
                trainLocHandler.onBeforeUpdate(trigger.oldmap, trigger.newmap);
            }
        }
    }

}