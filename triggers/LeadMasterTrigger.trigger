/**
 *author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Kishore AN - Cloud Sherpas/Mathworks
 *date Original: 26 May 2014, Last Modified: 12 June 2014
 *description: This trigger is used to handle different trigger actions for Lead
 *revision: Commented out the call to trigger handler in after insert 
 */
 
trigger LeadMasterTrigger on Lead (before insert, before update,after insert,after update) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    //Intantiate the LeadTriggerHandler class. Performs before or before insert trigger processes for each Lead record
    LeadTriggerHandler ledTrigHandler = new LeadTriggerHandler();
        
        if(trigger.isBefore){

            if(trigger.isInsert){

                ledTrigHandler.onBeforeInsert(trigger.new);

            }

            if(trigger.isUpdate){
                ledTrigHandler.OnBeforeUpdate(trigger.oldmap, trigger.newmap);

            }

        }
        if(trigger.isAfter){
            
            if(trigger.isInsert ){
                
                
                ledTrigHandler.onAfterInsert(trigger.new);
                
            }            
            if(trigger.isUpdate){   
                         
                ledTrigHandler.OnAfterUpdate(trigger.oldmap, trigger.newmap);

            }
            
        }
        
        

}