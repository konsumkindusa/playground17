/**
 *@author Original: krishna Bhaskarla, Mathworks
 *@date Original:   Aug 19, 2015
 *@description:     This is a Handler class for TrainingLocation Object.
 */
public class TrainingLocTriggerHandler {
    TrainingLocDml locDml = new TrainingLocDml();
    /**
     *@author Original: Krishna Bhaskarla, Mathworks
     *@date Original: Aug 19,2015
     *@description: Method that handles Before Delete trigger event on the Training_Location__c object.
     */
     public void onBeforeDelete(List<Training_Location__c>locList){
        Logger.push('onBeforeDelete','TrainingLocTriggerHandler');
        List<Training_Location__c> trainLocList = new List<Training_Location__c>();
        Set<Id> trainLocId = (new Map<Id,Training_Location__c>(locList)).keySet();
               
        //query the training location records
        trainLocList = [Select Id,Name, Publish_To_Web__c From Training_Location__c Where Id IN :trainLocId];
        //check list is not empty
        if(!trainLocList.isEmpty()){
            //send class list and enrollment list      
            locDml.preventDelTrainingLoc(trainLocList);
        }
        Logger.pop();
     }
    /**
     *@author Original: Krishna Bhaskarla, Mathworks
     *@date Original: Aug 19,2015
     *@description: Method that handles Before Update trigger event on the Training_Location__c object.
     */
    public void onBeforeUpdate(map<Id, Training_Location__c> oldmap, map<Id, Training_Location__c> newmap){
        Logger.push('onBeforeUpdate','TrainingLocTriggerHandler');
        Training_Validation_Rule__c vRules = Training_Validation_Rule__c.getInstance(UserInfo.getProfileId());
        List<Training_Location__c> trainLocList = new List<Training_Location__c>();
        Map<id, Training_Location__c> pubToWebtrainLocMap = new Map<Id,Training_Location__c>();
       	//If the user is sysadmin - allow the user to unpublish the location.
        if(!vRules.prevent_unpublish_location__c){
          	 return;
        }
        
        /* Profile p = [SELECT Id FROM Profile WHERE Name='MW Training Admin'];
        if(p.Id != UserInfo.getProfileId()){
           return;
        } */
        
        for (Training_Location__c tLoc : newmap.values()){
            //Filter publish to web records that are updated 
            if (oldmap.get(tLoc.Id).publish_to_web__c!= tLoc.publish_to_web__c){
                pubToWebtrainLocMap.put(tLoc.Id,tLoc);
            }
        }
        
        Set<Id> trainLocIdSet = pubToWebtrainLocMap.keySet();
               
        //query the check if associated classes are published to web
        trainLocList = [select Name, Id from training_location__c where publish_to_web__c= true and ID IN (select Training_Location__c from class__c where publish_to_web__c = true AND Training_Location__c IN :trainLocIdSet)];
        if(!trainLocList.isEmpty()){
            locDml.restrictLocUnpublish(trainLocList);
        }
        Logger.pop();
    }
    
    
}