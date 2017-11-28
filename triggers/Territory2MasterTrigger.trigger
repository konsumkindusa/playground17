/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
 *date Original: 22 October 2014, Last Modified: 12 August 2016
 *description This trigger is used to handle different trigger actions for Territory2 
 */
trigger Territory2MasterTrigger on Territory2 (before insert, before update,after insert,after update, after delete, before delete) { 

    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();

    //Intantiate the Territory2TriggerHandler class. Performs before or after insert trigger processes for each Territory2 record
    Territory2TriggerHandler terTrigHandler = new Territory2TriggerHandler();

    if (bypass.Trigger_Objects__c.contains('Territory2') && !bypass.Triggers_Disabled__c){

        if(trigger.isBefore){
            
            if(trigger.isInsert){

                terTrigHandler.onBeforeInsert(trigger.new); //SS 8/12/16 - Story:1617282

            }

            if(trigger.isUpdate){
	
				terTrigHandler.onBeforeUpdate(trigger.oldmap, trigger.newmap);//SS 8/12/16 - Story:1617282
            }

            if(trigger.isDelete){
                System.debug('In the delete variable' +trigger.old);
                terTrigHandler.onBeforeDelete(trigger.old);
            }
            
        }

        if(trigger.isAfter){

            if(trigger.isInsert)
            {   
                terTrigHandler.onAfterInsert(trigger.new);
            }

            if(trigger.isUpdate)
            { 
                terTrigHandler.OnAfterUpdate(trigger.oldmap, trigger.newmap);
            }
            
        }
    }
}