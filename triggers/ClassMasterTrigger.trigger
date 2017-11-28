/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   26 june 2015, Last Modified: 26 june 2015
 *@description:      This trigger is used to handle different trigger actions for Class
 */
trigger ClassMasterTrigger on Class__c (before delete,before Insert, before update, after Insert, after Update) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    //instantiating  the handler class CoursetriggerHandler which handles the trigger events for course object.
    ClassTriggerHandler clsHandler = new ClassTriggerHandler();
          
       if (bypass.Trigger_Objects__c.contains('Class') && !bypass.Triggers_Disabled__c){
          if(trigger.isBefore){
                  
                if(trigger.isInsert)
                {   
                  clsHandler.onBeforInsert(Trigger.new);
    
                }
              
                if(trigger.IsUpdate){
                  clsHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
              }
              
                if(trigger.isDelete)
                {   
                   clsHandler.onBeforeDelete(Trigger.old);
    
                }
          }
          
          if(trigger.isAfter){
              
              if(trigger.IsInsert){
                  clsHandler.onAfterInsert(trigger.new);
              }
          
              if(trigger.IsUpdate){
                  clsHandler.onAfterUpdate(trigger.new, trigger.oldMap);
              }
          }
      }
}