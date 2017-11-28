/**
 *author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified:
 *date Original: 06 Aug 2015, Last Modified:Sagar Talele
 *description This trigger is used to handle different trigger actions for Enrollment
 */

trigger EnrollmentMasterTrigger on Enrollment__c (before Insert,before Update,after insert,after update) {

     //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
     Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
     //instantiating  the handler class EnrollmentTriggerHandler which handles the trigger events for Enrollment object.
     EnrollmentTriggerHandler enrollHandlerObj = new EnrollmentTriggerHandler();
         
      if (bypass.Trigger_Objects__c.contains('Enrollment') && !bypass.Triggers_Disabled__c){
         if(trigger.isBefore){
             if(trigger.isInsert){
                 enrollHandlerObj.onBeforeInsert(Trigger.new);
             }
             else if(trigger.isUpdate){
                 enrollHandlerObj.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
             }
         }
          if(trigger.isAfter){
          
             if(trigger.isUpdate){
                 enrollHandlerObj.onAfterUpdate(trigger.oldmap, trigger.newmap);
             }
         }
     }
}