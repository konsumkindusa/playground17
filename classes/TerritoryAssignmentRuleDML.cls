/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original: 12 Feb 2016, Last Modified: 
 *@description This is the DML class for TerritoryAssignmentRuleMasterTrigger. 
 *@Revision: 
 */
 
public class TerritoryAssignmentRuleDML{
    
     /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original:   12 Feb 2016
     *@Last Modified: 
     *@Description:     This method is use to clone the Territory Assignment rule and its associated Territory
     *                  Rule Criteria and Territory Rule Criteria Value.
     *               
     */ 
     
    public void territoryRuleCriteriaAndCriteriaValueObjectCloning(List<Territory_Assignment_Rule__c> TARList){
    
        Logger.push('territoryRuleCriteriaAndCriteriaValueObjectCloning', 'TerritoryAssignmentRuleDML');
        
        //Store the territoryAssinmentRule Record Id
        Set<Id> TARRecIdSet = new Set<Id>();
        //List to store the TerritoryRuleCriteria associated to the Territory Assignment Rule.
        List<Territory_Rule_Criteria__c> territoryRuleCriteriaList = new List<Territory_Rule_Criteria__c>();
        //List to insert the TerritoryRuleCriteria associated to the Territory Rule Criteria.
        List<Territory_Rule_Criteria__c> clonedterritoryRuleCriteriaLst = new List<Territory_Rule_Criteria__c>();
        //Map of source and destination object field API Name.
        Map<String, String> srcDesObjFieldAPIMap = new map<String, String>();
        //Map of Old Territory Criteria Record with the new Territory Rule Criteria Record.
        Map<Id, Id> OldAndNewRecordCriteriaIdMap = new Map<Id, Id>();
        //List to store the Territory_Rule_Criteria_Value__c.
        List<Territory_Rule_Criteria_Value__c> TRCVLst = new List<Territory_Rule_Criteria_Value__c>();
        //List of Cloned Territory Rule Criteria Value.
        List<Territory_Rule_Criteria_Value__c> clonedTRCVLst = new List<Territory_Rule_Criteria_Value__c>();
        
        if(!(TARList.isEmpty()) && TARList != null){        
            for(Territory_Assignment_Rule__c territoryAssignRuleObj : TARList){
                //Create the set of the Original Territory Assignment Rule Id.
                TARRecIdSet.add(territoryAssignRuleObj.getCloneSourceId());
            }
        }
        //Dynamically building the SOQL and Querying the Territory Rule criteria object record and its Child associated to the Territory Assignment Rule.
        List<String> criteriaFields = new List<String>(Territory_Rule_Criteria__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> criteriaValueFields = new List<String>(Territory_Rule_Criteria_Value__c.SObjectType.getDescribe().fields.getMap().keySet());
        String Soql = ''
            + ' select ' + String.join(criteriaFields, ',')
            + ' , ( select ' + String.join(criteriaValueFields, ',')
            + ' from Territory_Rule_Criteria_Values__r ) '
            + '  from Territory_Rule_Criteria__c ' + ' WHERE Territory_Assignment_Rule__c IN: TARRecIdSet ';
        System.Debug('SOQL:::'+Soql);
        territoryRuleCriteriaList = Database.query(Soql);
        
        //territoryRuleCriteriaList = [SELECT Id, Name, SourceId__c, Required__c, Score__c, Territory_Assignment_Rule__c, RecordTypeId, (SELECT Id, Account_Name__c, City__c, Location__c, Country_Code__c, Country_LongName__c, Postal_Code_High__c, Postal_Code_Low__c, Score__c, Sector__c, State_Code__c, State_LongName__c, Territory_Rule_Criteria__c, Case_Sensitive__c FROM Territory_Rule_Criteria_Values__r) FROM Territory_Rule_Criteria__c WHERE Territory_Assignment_Rule__c IN: TARRecIdSet];
        
        //Filling the Territory Rule Criteria Value List.
        for(Territory_Rule_Criteria__c TRCObj : territoryRuleCriteriaList){
            TRCVLst.addAll(TRCObj.Territory_Rule_Criteria_Values__r);
        }
        
        List<Object_Clone_Mapping__mdt> objClnMappingLst = [SELECT Destination_Obj_API_Name__c, Destination_Obj_Field_API_Name__c, Src_Obj_API_Name__c, Src_Obj_Field_API_Name__c FROM Object_Clone_Mapping__mdt WHERE Destination_Obj_API_Name__c = 'Territory_Rule_Criteria__c' AND Src_Obj_API_Name__c = 'Territory_Rule_Criteria__c'];
        
        //Check if the Metadata is Empty or Not.
        if(!(objClnMappingLst.isEmpty())){
            //Filling the srcDesObjFieldAPIMap Map.
            for(Object_Clone_Mapping__mdt clnMapMdtObj : objClnMappingLst){
                srcDesObjFieldAPIMap.put(clnMapMdtObj.Src_Obj_Field_API_Name__c, clnMapMdtObj.Destination_Obj_Field_API_Name__c);
            }    
        }
        //Calling the cloneSobject Method.
        clonedterritoryRuleCriteriaLst = SobjectCloningUtility.cloneSobject(srcDesObjFieldAPIMap, territoryRuleCriteriaList, 'Territory_Rule_Criteria__c', 'Territory_Rule_Criteria__c');
        
        //Referring the Territory Assugnment Rule Obect Record Id to its associated Territory Rule Criteria Values Object Record.
        if(!clonedterritoryRuleCriteriaLst.isEmpty() && clonedterritoryRuleCriteriaLst != null){
            for(Territory_Rule_Criteria__c trcObj : clonedterritoryRuleCriteriaLst){
                trcObj.Territory_Assignment_Rule__c = TARList[0].Id;
            }
        }
        
        try{
            //Inserting the territory rule criteria list.
            insert clonedterritoryRuleCriteriaLst;
        }
        catch(Exception ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                Logger.Pop();
            }
        }//End of Catch
        
        //Check if the Cloned territory rule criteria List is empty or not.
        if(!(clonedterritoryRuleCriteriaLst.isEmpty()) && clonedterritoryRuleCriteriaLst != null){        
            //Filling the OldAndNewRecordCriteriaIdMap
            for(Territory_Rule_Criteria__c TRCObj : clonedterritoryRuleCriteriaLst){
                OldAndNewRecordCriteriaIdMap.put(TRCObj.SourceId__c, TRCObj.Id);
            }
        }
        
        //Clearing the List of Clone mapping.
        objClnMappingLst.clear();
        
        //Querying the custom metadata to get field mapping. 
        objClnMappingLst = [SELECT Destination_Obj_API_Name__c, Destination_Obj_Field_API_Name__c, Src_Obj_API_Name__c, Src_Obj_Field_API_Name__c FROM Object_Clone_Mapping__mdt WHERE Destination_Obj_API_Name__c = 'Territory_Rule_Criteria_Value__c' AND Src_Obj_API_Name__c = 'Territory_Rule_Criteria_Value__c'];
        
        //Clear the Source Destination Object Mapping Map.
        srcDesObjFieldAPIMap.clear();
        
        //Check if the Metadata is Empty or Not.
        if(!(objClnMappingLst.isEmpty())){
            //Filling the srcDesObjFieldAPIMap Map.
            for(Object_Clone_Mapping__mdt clnMapMdtObj : objClnMappingLst){
                srcDesObjFieldAPIMap.put(clnMapMdtObj.Src_Obj_Field_API_Name__c, clnMapMdtObj.Destination_Obj_Field_API_Name__c);
            }    
        }
        
        //Calling the cloneSobject Method.
        clonedTRCVLst = SobjectCloningUtility.cloneSobject(srcDesObjFieldAPIMap, TRCVLst, 'Territory_Rule_Criteria_Value__c', 'Territory_Rule_Criteria_Value__c');
        
        //Check if the cloned Territory Rule criteria Value List is empty or not.
        if(!clonedTRCVLst.isEmpty() && clonedTRCVLst != null){
            //Iterating over the Territory Rule Criteria Value List.
            for(Territory_Rule_Criteria_Value__c trcvObj : clonedTRCVLst){
                //Assigning the new Territory Rule Criteria record Id To the cloned Territory Rule Criteria Value record.
                if(OldAndNewRecordCriteriaIdMap.containsKey(trcvObj.Territory_Rule_Criteria__c)){
                    trcvObj.Territory_Rule_Criteria__c = OldAndNewRecordCriteriaIdMap.get(trcvObj.Territory_Rule_Criteria__c);
                }
            }//End of For loop
        }//End of If
        
        try{
            //Insert List of territory criteria value.
            insert clonedTRCVLst;
        }
        catch(Exception ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                Logger.Pop();
            }
        }
    Logger.pop();
    }//End of Method
}//End of Class