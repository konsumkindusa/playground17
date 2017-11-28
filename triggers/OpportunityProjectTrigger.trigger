/**
*author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modifed by : Faina Gorelik
*date Original: 1 April 2015, Last Modified:5 January 2016
*description This trigger is used to handle different trigger actions for Opportunity Project 
*revision: Faina Gorelik AtTask 1135328 
*/
trigger OpportunityProjectTrigger on Opportunity_Projects__c (before insert, before update,after insert,after update,after delete) {
    OpportunityProjectTriggerHandler OppProjectHandler = new OpportunityProjectTriggerHandler();
       if(trigger.isBefore){
 
            if(trigger.isInsert){

                OppProjectHandler.onBeforeInsert(trigger.new);

            }

        }
        
       if (trigger.isAfter){
        
        
            if (trigger.isDelete){
             OppProjectHandler.onAfterDelete(trigger.old);
         
            }
        }
}