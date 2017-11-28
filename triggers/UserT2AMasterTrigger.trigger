/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *date Original: 17 Feb 2016, Last Modified: 17 Feb 2016
 *description This trigger is used to handle different trigger actions for UserTerritory2Association  
 */
trigger UserT2AMasterTrigger on UserTerritory2Association  (before insert) { 

    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //Intantiate the UserT2ATriggerHandler class to Performs before insert trigger processes for each UserTerritory2Association record
    UserT2ATriggerHandler userT2AHandler = new UserT2ATriggerHandler();

    if (bypass.Trigger_Objects__c.contains('UserTerritory2Association') && !bypass.Triggers_Disabled__c){

        if(trigger.isBefore){

            if(trigger.isInsert){

               userT2AHandler.onBeforeInsert(trigger.new);

            }

        }
    }
}