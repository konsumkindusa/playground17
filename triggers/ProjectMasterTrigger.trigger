/**
 *author Original: Andre Calimlim
 *date Original: 4 Aug 2014
 *description This trigger is used to handle different trigger actions for MW_Project__c 
 */

trigger ProjectMasterTrigger on MW_Project__c (before insert, before update,after insert,after update) {
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    ProjectTriggerHandler trigHandler = new ProjectTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('Project') && !bypass.Triggers_Disabled__c){

        if(trigger.isBefore){

            if(trigger.isInsert){
                
                trigHandler.onBeforeInsert(trigger.new);
                
            }
            
            if(trigger.IsUpdate){
                
                trigHandler.onBeforeUpdate(trigger.new);
                
            }
        }

        if(trigger.isAfter){

            if(trigger.isInsert)
            {   
                
                trigHandler.onAfterInsert(trigger.new);

            }
            
            if(trigger.isUpdate)
            {   
                
                trigHandler.onAfterUpdate(trigger.oldmap, trigger.newmap);

            }
            
            
        }

    }

}