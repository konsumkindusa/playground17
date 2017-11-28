/******************************************************************************
 * @author         Jaspreet Monga 
 * @date           8/4/2014 
 * @Last Modified by: Archana Lohar - Cloud Sherpas/Mathworks
 * @Last Modified: 3 Feb 2015
 * @description    will reassign the opportunity sales team members if owner of opportunity is changed.
 * Events : - before update
 *          - after update
 *          - before insert
 *          - after insert
 */


trigger OpportunityTrigger on Opportunity (before update, after update,before insert,after insert) {

    OpportunityTriggerHandler optyHandler=new OpportunityTriggerHandler();
    reassignOpporTeamMember instReassignOpporTeamMember= new reassignOpporTeamMember();

    if(trigger.isbefore)
    {
        //Added by-Archana Lohar-Mathworks/Cloudsherpas
        if(trigger.isInsert){
            optyHandler.onBeforeInsert(trigger.new);
        }

        if(trigger.isUpdate){
        instReassignOpporTeamMember.beforeUpdate(trigger.new,trigger.oldMap); 
        optyHandler.onBeforeUpdate(trigger.newmap,trigger.oldMap);
        }

    }   

    if(trigger.isAfter)
    {  
    	
    	//Added by-Archana Lohar-Mathworks/Cloudsherpas
    	if(trigger.isInsert){
          optyHandler.onAfterInsert(trigger.new);
        }
        
        if(trigger.isUpdate){
        instReassignOpporTeamMember.afterUpdate();   
        optyHandler.onAfterUpdate(trigger.newmap,trigger.oldMap);
        }
        
        
    }

}