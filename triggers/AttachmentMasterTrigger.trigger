/**
*author Original: Kishore AN - Cloud Sherpas/Mathworks
*date Original: 20 March 2015, Last Modified:
*description This trigger is used to handle different trigger actions for Attachment 
*revision:
*/

trigger AttachmentMasterTrigger on Attachment (After insert) {
    
    AttachmentTriggerHandler attachmentHandler = new AttachmentTriggerHandler();
    if(trigger.isAfter){
        if(trigger.isInsert){
            attachmentHandler.onAfterInsert(trigger.new,trigger.newMap);
        }
    }

}