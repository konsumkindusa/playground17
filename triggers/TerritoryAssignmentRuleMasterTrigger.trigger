/**
 *author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *date Original: 2 Feb 2016, Last Modified: 
 *description This trigger is used to handle different trigger actions for Territory Assignment Rule
 */

trigger TerritoryAssignmentRuleMasterTrigger on Territory_Assignment_Rule__c (after insert) {

    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    //Create the instance for the Teritory Assignment Rule Handler Class.
    TerritoryAssignmentRuleTriggerHandler territoryAssignmentRuleHndlr = new TerritoryAssignmentRuleTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('TerritoryAssignmentRule') && !bypass.Triggers_Disabled__c){
    
        if(trigger.isafter){
            
            if(trigger.isInsert){
                territoryAssignmentRuleHndlr.onAfterInsert(trigger.new);
                System.debug('Inside the trigger');
            }
        }
    }    
}