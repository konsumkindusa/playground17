/**
 *author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Andre Calimlim - Cloud Sherpas/Mathworks
 *date Original: 23 July 2014, Last Modified: 23 July 2014
 *description This trigger is used to handle different trigger actions for Opportunity Line Item 
 */
trigger OpportunityLineItemMasterTrigger on OpportunityLineItem (after insert) {
    
    
    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    //Intantiate the LeadTriggerHandler class. Performs before or before insert trigger processes for each Lead record
    OpportunityLineItemTriggerHandler opportunityLineItemTriggerHandler = new OpportunityLineItemTriggerHandler();
        
       
		if(trigger.isAfter){

            if(trigger.isInsert){

                opportunityLineItemTriggerHandler.onAfterInsert(trigger.new);

            }

          
        }
   

}