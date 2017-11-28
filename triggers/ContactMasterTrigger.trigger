/**
*author Original: Kishore An - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
*date Original: 26 September 2013, Last Modified: 22 October 2013
*description This trigger is used to handle different trigger actions for Contact 
*/
trigger ContactMasterTrigger on Contact (before insert, before update, after insert, after update) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //Intantiate the ContactTriggerHandler class. Performs before or after insert trigger processes for each contact record
    ContactTriggerHandler contTrigHandler = New ContactTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('Contact') && !bypass.Triggers_Disabled__c){
        
        if(trigger.isBefore){
            
            if(trigger.isInsert){
                
                contTrigHandler.OnBeforeInsert(trigger.new);
            }
            
            if(trigger.isUpdate){
                
                contTrigHandler.OnBeforeUpdate(trigger.oldmap, trigger.newmap);
            }
            
        }
        
        if(trigger.isAfter){
                      
            if(trigger.isInsert)
            {  
                if(CheckRecursive.runOnce()){          
                contTrigHandler.OnAfterInsert(trigger.new);
                }
                    
            }
            
            if(trigger.isUpdate)
            {     
               // if(CheckRecursive.runOnce()){       
                contTrigHandler.OnAfterUpdate(trigger.oldmap, trigger.newmap);
              //  }
            }
            
        }
        
    }

}