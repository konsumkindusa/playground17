/**
 *author Original: Jaspreet Monga (Mathworks)
 *date Original: 10/1/2014
 *description trigger will be executed on following events:
 
       before insert
       after  insert
       before update
       after  update
       after  delete 
       after  undelete
   
 this trigger does following actions:
         1. Copies requester from parent project record and associate with current project team member (before insert)
         2. Makes list of resources on project team members related to a project and updates it on project (after)  
       
       
 */

trigger ProjectTeamMemberMasterTrigger on Project_Team_Member__c (before insert,after insert,before update,after update,after delete,after undelete) {

    ProjectTMTriggerHandler objprojectTMTriggerHandler = new ProjectTMTriggerHandler();
    
    if (Trigger.isbefore) {
    
        if (Trigger.isInsert){
            objprojectTMTriggerHandler.onBeforeInsert(trigger.new);
        }
    }
    
    if (Trigger.isAfter) {
       
        if (Trigger.isInsert){
           objprojectTMTriggerHandler.onAfterInsert(trigger.newMap);
        }
        
        if(Trigger.isUpdate) {
            objprojectTMTriggerHandler.onAfterUpdate(trigger.newMap);
        }
        
        if (Trigger.isDelete) {
            objprojectTMTriggerHandler.onAfterDelete(trigger.oldMap);
        } 
        
        if(Trigger.isUnDelete) {
            objprojectTMTriggerHandler.onAfterUnDelete(trigger.newMap);
        }
    
    }


}