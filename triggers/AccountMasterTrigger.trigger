/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *date Original: 13 May 2014, Last Modified: 13 May 2014
 *description This trigger is used to handle different trigger actions for Account 
 */
trigger AccountMasterTrigger on Account (before insert, before update,after insert,after update) { 

    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //Intantiate the AccountTriggerHandler class. Performs before or after insert trigger processes for each Account record
    AccountTriggerHandler accTrigHandler = new AccountTriggerHandler();

    if (bypass.Trigger_Objects__c.contains('Account') && !bypass.Triggers_Disabled__c){

        if(trigger.isBefore){

            if(trigger.isInsert){

                accTrigHandler.onBeforeInsert(trigger.new);

            }

            if(trigger.isUpdate){


                accTrigHandler.OnBeforeUpdate(trigger.oldmap, trigger.newmap);

            }

        }

        if(trigger.isAfter){

            if(trigger.isInsert)
            {   
                if(CheckRecursive.runOnce()){
                accTrigHandler.onAfterInsert(trigger.new);
                }

            }

            if(trigger.isUpdate)
            { 
            
                accTrigHandler.OnAfterUpdate(trigger.oldmap, trigger.newmap);
            }
        }

    }


}