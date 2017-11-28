/**
 *author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *date Original: 2 Feb 2016, Last Modified: 
 *description This is the handler class for TerritoryAssignmentRule Object.
 */


public class TerritoryAssignmentRuleTriggerHandler{
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified: 
     *@Date Original: 12 Feb 2016
     *@Last Modified: 
     *@Description: Method to handle the after insert event on Territory_Assignment_Rule__c Object.
     */ 
     
    //Create the instance for the TerritoryAssignmentRuleDML Class. 
    TerritoryAssignmentRuleDML territoryAssignmentRuleDmlObj = new TerritoryAssignmentRuleDML();
    
    public void onAfterInsert(List<Territory_Assignment_Rule__c> TARList){
        
        Logger.push('onAfterInsert', 'TerritoryAssignmentRuleTriggerHandler');
        
        //List to store the cloned records.
        List<Territory_Assignment_Rule__c> clonedTARList = new List<Territory_Assignment_Rule__c>();  
        //Check if the list is empty or not.
        if(!(TARList.isEmpty()) && TARList != null){        
            //Iterating over the Territory Assignment Rule List.
            for(Territory_Assignment_Rule__c territoryAssignmentRuleObj : TARList){
                //Check if the record is cloned or not.
                if(territoryAssignmentRuleObj.isClone()){
                    //add the cloned reocrd to the list
                    clonedTARList.add(territoryAssignmentRuleObj);
                }                
            }
            
            if(clonedTarList.size()> 0){
                territoryAssignmentRuleDmlObj.territoryRuleCriteriaAndCriteriaValueObjectCloning(clonedTARList);
            }
        }
    Logger.pop();
    }
}