/**
*author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
*date Original: 11 June 2013, Last Modified: 22 October 2013
*description This trigger is used to handle different trigger actions for EmailMessage 
*/
trigger EmailMessageMasterTrigger on EmailMessage (before insert, after insert, after update) {
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    //Intantiate the EmailMessageTriggerHandler class. Performs before or after insert trigger processes for each case record
    EmailMessageTriggerHandler emTrigHandler = New EmailMessageTriggerHandler();
    
    if (bypass.Trigger_Objects__c.contains('EmailMessage') && !bypass.Triggers_Disabled__c){
    	
	    if(trigger.isBefore)
	    {          
	        if(trigger.isInsert)
	        {
	            //performs the following EmailMessageDML class methods
	            emTrigHandler.OnBeforeInsert(trigger.new);
	        }
	        
	    }
	    
	    if(trigger.isAfter)
	    {          
	        if(trigger.isInsert)
	        {
	            //performs the following EmailMessageDML class methods
	            //CloseActivity - updates the status of a related open activity to 'Completed'
	            emTrigHandler.OnAfterInsert(trigger.new);
	        }
	        if(trigger.isUpdate)
	        {
	            //performs the following EmailMessageDML class methods
	            //CloseActivity - updates the status of a related open activity to 'Completed'
	            emTrigHandler.onAfterUpdate(trigger.new);
	        }
	        
	    }
	    
    }
        
}