/**
*author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Eric Schoenfeld - Cloud Sherpas/Mathworks
*date Original: 03 June 2013, Last Modified: 10/14/2014
*description This trigger is used to handle different trigger actions for Case 
*/
trigger CaseMasterTrigger on Case (before insert, before update, after insert, after update) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //Intantiate the CaseTriggerHandler class. Performs before or after insert trigger processes for each case record
    CaseTriggerHandler cseTrigHandler= New CaseTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('Case') && !bypass.Triggers_Disabled__c){
    
        if(trigger.isBefore){
            
            if(trigger.isInsert){
                //performs the following CaseDML class methods
                //#EmailToCaseLoopKiller
                //#UpdateCaseProductFields
                //#updateCaseEmailTemplateInfo
                //#updateCaseArea
                //#updateCaseAccount
              cseTrigHandler.OnBeforeInsert(trigger.new);
            }
            
            if(trigger.isUpdate){
                //performs the following CaseDML class methods
                //#UpdateCaseProductFields
                //#updateCaseEmailTemplateInfo
                //#CaseArticleCheck
                //#updateSubStatusOnChangeOwnership
                cseTrigHandler.OnBeforeUpdate(trigger.oldmap, trigger.newmap);
            }
            
        }
        
        if(trigger.isAfter)
        {          
            if(trigger.isInsert)
            {
                //performs the following CaseDML class methods
                //#checkOnSupport
                cseTrigHandler.OnAfterInsert(trigger.new);
                    
            }
            
            if(trigger.isUpdate)
            {
                //performs the following CaseDML class methods
                //#checkOnSupport
                cseTrigHandler.OnAfterUpdate(trigger.oldmap, trigger.newmap);
            }
        }
    
    }
}