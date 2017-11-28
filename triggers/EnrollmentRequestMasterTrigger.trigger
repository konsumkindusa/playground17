/**
*author Original: Archana Suryawanshi - Cloud Sherpas/Mathworks
*date Original: 4 April 2016, Last Modified:4 April 2016
*description This trigger is used to handle different trigger actions for Enrollment Request Object 
*/
trigger EnrollmentRequestMasterTrigger on Enrollment_Request__c (before insert,before update, after insert, after update) {
    
    EnrollmentRequestTriggerHandler eReqhandler = new EnrollmentRequestTriggerHandler();
    
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();

    if (bypass.Trigger_Objects__c.contains('EnrollmentRequest') && !bypass.Triggers_Disabled__c){
    
        if(trigger.isBefore){
     
            if(trigger.isInsert){
                eReqhandler.onBeforeInsert(trigger.new);
            }
            if(trigger.isUpdate){
                eReqhandler.onBeforeUpdate(trigger.oldMap,trigger.newMap);
            }
        }
        
        if(trigger.isAfter){    
            if(trigger.isInsert){
                System.debug('in the trigg insert' +trigger.new);
                eReqhandler.onAfterInsert(trigger.new);
            }
            if(trigger.isUpdate){
            System.debug('in the trigg update' +trigger.newMap);
                eReqhandler.onAfterUpdate(trigger.oldMap,trigger.newMap);
            }
        }
    }
}