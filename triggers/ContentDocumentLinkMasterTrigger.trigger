/**
*author Original: Faina Gorelik - Mathworks
*date Original: 26 September 2016, Last Modified:
*description This trigger is used to handle different trigger actions for Files
*/

trigger ContentDocumentLinkMasterTrigger on ContentDocumentLink (After insert) {
ContentDocumentLinkTriggerHandler contentdoclinkHandler = new ContentDocumentLinkTriggerHandler();
    if(trigger.isAfter){
        if(trigger.isInsert){
            contentdoclinkHandler.onAfterInsert(trigger.new,trigger.newMap);
        }
    }
}