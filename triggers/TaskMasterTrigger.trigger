/**
*author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
*date Original: 04 June 2013, Last Modified: 20 May 2015
*description This trigger is used to handle different trigger actions for Task 
*revision: Jaspreet | Refactor- TaskDML
*/
trigger TaskMasterTrigger on Task (before insert, before update, after update, after insert, after delete ) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //Intantiate the TaskTriggerHandler class
    TaskTriggerHandler tskTrigHandler = New TaskTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('Task') && !bypass.Triggers_Disabled__c){
        
        if(trigger.isBefore)
        {          
            //Perform after insert trigger event
            if(trigger.isInsert)
            {
                //performs the following CaseDML class methods
                //* EscalateToDevOutboundEmail - updates Task's Category to 'Escalate Request to Dev' and Case's SubStatus to 'Waiting for Internal'
                tskTrigHandler.OnBeforeInsert(trigger.new);
               
            }
            //Shweta - 10/01/2013
            /*if (trigger.isUpdate) AC - 8.12.2014: Comment out empty if conditions
            {
            //    tskTrigHandler.setSiebelContactId(trigger.new);
            }*/
            
            if(trigger.IsUpdate)
            {
              tskTrigHandler.onBeforeUpdate(trigger.newMap,trigger.oldMap);
            }
            
            
        }
        
        if(trigger.isAfter)
        {          
            //Perform after insert trigger event
            if(trigger.isInsert)
            {
                //performs the following CaseDML class methods
                //* UpdateEscalateTo - updates Case's Escalate To field equal to Tasks' Escalate To field value
                tskTrigHandler.OnAfterInsert(trigger.newMap,trigger.newMap);
            }
            
            if (trigger.isUpdate)
            {
               tskTrigHandler.OnAfterUpdate(trigger.newMap, trigger.oldMap);
            }
            //Perform after delete trigger event
            if(trigger.isDelete)
            {
                tskTrigHandler.OnAfterDelete(trigger.newMap,trigger.oldmap);
                
            }
        }
    
    }

}