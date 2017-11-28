/**
*author Original: Faina Gorelik 
*date Original: 13 September 2017
*description This trigger is used to handle different trigger actions for Training Agreement Object AtTask 2238455
*revision: Faina Gorelik AtTask 1135328 
*/


trigger TrainingAgreementClassMasterTrigger on Training_Agreement_Class_Relationship__c (before insert, before update,after insert,after update,after delete) {

      //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    TrainingAgreementClassTriggerHandler TraingAgreementClass = new TrainingAgreementClassTriggerHandler();
  if (bypass.Trigger_Objects__c.contains('ETAClass') && !bypass.Triggers_Disabled__c){
        
       if (trigger.isAfter){
        
        
            if(trigger.isInsert)
            {   
               TraingAgreementClass.onAfterInsert(Trigger.new);
        
            }

        }
  } 
}