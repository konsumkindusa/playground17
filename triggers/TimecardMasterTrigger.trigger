/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar - Cloud Sherpas/Mathworks
 *date Original: 26 September 2014, Last Modified: 26 September 2014
 *description: This trigger is used to handle different trigger actions for Timecard  
 */
trigger TimecardMasterTrigger on Project_Time_Card__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	//Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
	
	//Intantiate the timecardTrigHandler class. Performs before trigger processes for each Timecard record
	TimecardTriggerHandler timecardTrigHandler = new TimecardTriggerHandler();{

		if(trigger.isBefore){

			if(trigger.isInsert){

			}

			if(trigger.isUpdate){

			}
			if(trigger.isDelete){
				
			timecardTrigHandler.onBeforeDelete(trigger.old);

			}

		}

		if(trigger.isAfter){	

			if(trigger.isInsert)
			{   
				
			}
			
			if(trigger.isUpdate)
			{ 
			
			}

		}
	}
}