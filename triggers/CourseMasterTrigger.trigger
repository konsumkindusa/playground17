/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   2 june 2015, Last Modified: 2 june 2015
 *@description:      This trigger is used to handle different trigger actions for Course
 */
trigger CourseMasterTrigger on Course__c (after insert) {

        //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
        Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
        
        //instantiating  the handler class CoursetriggerHandler which handles the trigger events for course object.
        CoursetriggerHandler ctHandler = new CoursetriggerHandler();
      
       if (bypass.Trigger_Objects__c.contains('Course') && !bypass.Triggers_Disabled__c){       
          if(trigger.isAfter){
    
                if(trigger.isInsert)
                {   
                   ctHandler.onAfterInsert(Trigger.new);
    
                }
          }
      }
}