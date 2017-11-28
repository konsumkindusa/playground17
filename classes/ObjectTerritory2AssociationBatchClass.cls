/***************************************************************************************
 * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
 * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
 * description This batch class fetch the dupilcate records and keeps one record and
 * delete the other duplicate records
 *
 ****************************************************************************************/
global class ObjectTerritory2AssociationBatchClass implements Database.Batchable<sObject> {
    
     //List to add aggregate Results
     global LIST<AggregateResult> territoryToAccountList = new LIST<AggregateResult>();
     global set<Id> accountIdSet = new set<Id>();
     
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele 
     * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
     * description This 
     ****************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC) {
                   
        territoryToAccountList = [Select count(Id),ObjectId From ObjectTerritory2Association  group by  objectId having count(Id) > 1 ];
        for(AggregateResult aggrObj : territoryToAccountList){
            accountIdSet.add((Id)aggrObj.get('ObjectId'));
        }
        String query = 'Select ObjectId, Territory2Id From ObjectTerritory2Association'+' where ObjectId In :accountIdSet';
        return Database.getQueryLocator(query);
    }
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele 
     * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
     * description This execute method the business logic
     ****************************************************************************************/
    global void execute(Database.BatchableContext BC,List<ObjectTerritory2Association> objT2AssociationList) {
    
        Logger.Push('execute','ObjectTerritory2AssociationBatchClass');
        //set of accountId's
        Set<Id> acctIdSet = new Set<Id>();
        //list to store accounts
        List<Account> accountList = new List<Account>();
        //map of territory2Id as a key and value as accountid
        Map<Id,Id> t2IdToAccIdRealMap = new Map<Id,Id>();
        //list to store ObjectTerritory2Association records
        List<ObjectTerritory2Association> objT2ADeleteList = new List<ObjectTerritory2Association>();
        //map of accountId as a key and values as a integer for avoiding duplicate territory and accountid 
        Map<Id,Integer> acctIdToCount = new Map<Id,Integer>();
        //map of account as key and territory Id as a value
        Map<Id,Id> acctIdToterritory2IdMap = new Map<Id,Id>();
        //iterate over the objT2AssociationList 
        for(ObjectTerritory2Association objT2A : objT2AssociationList){
            acctIdSet.add(objT2A.ObjectId);
        }
       //check set is not empty
        if(!acctIdSet.ISEmpty()){
            //query accounts which involves to multipe territories
            accountList = [Select id,Salesforce_Territory_Id__c From Account where Id In :acctIdSet];
            //iterate over the accountList to build t2IdToAccIdRealMap
            for(Account accObj : accountList){
                if(!acctIdToterritory2IdMap.containsKey(accObj.Id)){
                    acctIdToterritory2IdMap.put(accObj.Id,accObj.Salesforce_Territory_Id__c);
                }
            }
            
        }
        system.debug('**acctIdToterritory2IdMap**'+acctIdToterritory2IdMap);
        //iterate over the list of ObjectTerritory2Association records for delete operation
        for(ObjectTerritory2Association objT2A: objT2AssociationList){
            
            integer count = 0;
            //build the map of accountid and there count to avoid the duplicate records which has same territoryId and
            //account id
            //on ObjectTerritory2Association
            if(acctIdToCount.containsKey(objT2A.ObjectId)){
                count = count + 1;
                acctIdToCount.put(objT2A.ObjectId,count);
            }
            else{
                system.debug('**acctIdToterritory2IdMapgetobjT2A.ObjectId**'+acctIdToterritory2IdMap.get(objT2A.ObjectId));
                if(objT2A.Territory2Id == acctIdToterritory2IdMap.get(objT2A.ObjectId)){
                    acctIdToCount.put(objT2A.ObjectId,count);
                }
                
            }
           
           if( acctIdToterritory2IdMap.containsKey(objT2A.ObjectId) && acctIdToCount.containsKey(objT2A.ObjectId) && acctIdToCount.get(objT2A.ObjectId) == 0 )
            {
                if(!(objT2A.Territory2Id == acctIdToterritory2IdMap.get(objT2A.ObjectId))){
                    objT2ADeleteList.add(objT2A);
                }
                
            }
            else{
                objT2ADeleteList.add(objT2A);
            }
        }
        //check objT2ADeleteList is not empty
        if(!objT2ADeleteList.IsEmpty()){
            try{
               delete objT2ADeleteList;
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                  //capture Dml  Process exception 
                  Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
                Logger.Pop();
          }
        }
        Logger.pop();
        
    }
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele 
     * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
     * description This is finish method executes 
     ****************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        
    }
}