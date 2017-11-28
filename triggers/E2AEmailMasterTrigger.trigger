/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele
 *date Original: 12 Nov 2015, Last Modified:12 Nov 2015
 *description This trigger is used to handle different trigger actions for e2a Email 

 *Revision date: 12 Feb 2016 | Haigang.Wu@Mathworks.com 
 *Revision description: Add handeling for "before update" to solve the reparent issue. 
 */

trigger E2AEmailMasterTrigger on ortoo_e2a__EmailMessage__c (before update,after insert,after update,after delete,after undelete) {

    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //instantiating  the handler class E2AEmailTriggerHandler  which handles the trigger events for e2a email object.
    E2AEmailTriggerHandler e2aEmailHabndlerObj = new E2AEmailTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('e2a Email') && !bypass.Triggers_Disabled__c){
        
        if(trigger.isAfter){
            
            if(trigger.isInsert){
            
                e2aEmailHabndlerObj.onAfterInsert(Trigger.new);
            }
            if(trigger.isUpdate){
            
                e2aEmailHabndlerObj.onAfterUpdate(trigger.newmap, trigger.oldMap);
            }
            if(trigger.isDelete){
                e2aEmailHabndlerObj.onAfterDelete(trigger.oldMap);
            }
            if(trigger.isUnDelete){
                e2aEmailHabndlerObj.onAfterUnDelete(trigger.newmap);
            }
        } else {
            //if(trigger.isUpdate){
            //    e2aEmailHabndlerObj.onBeforeUpdate(trigger.oldMap, trigger.newmap);
            //}
        }
    }
}