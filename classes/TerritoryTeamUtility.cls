/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
 *@date Original:20 August 2014, Last Modified: 23 May 2015
 *@description This is Utility class for 'Opportunity Assignment Manager' to get the territory team .
 *@revision: 518008 - updated the getTerritoryTeamMembers method
 *           Archana Suryawanshi :Attask:1211182 and 1362981 - Changed Opportunity assignment based on user territory association role in territory (and not on the User Default Functional Role).
 
 */
public  class TerritoryTeamUtility {

    private TerritoryTeamUtility(){

    }

    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified:  Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 20 August 2014 
     *@Last Modified: 14 July 2015
     *@Description: It will get Territory Team members  of territory2 object of Account
     */
    public static Map<id,Map<string,List<id>>> getTerritoryTeamMembers (list<Account> accObjList){ 

        Logger.push('TerritoryTeamUtility','getTerritoryTeamMembers');

        //Map of accountid and salesforce territory id
        Map<Id, Id> AccountIdTerritoryIdMap = new Map<Id, Id>();
        
        //Map with territory id as key and a map of functional roles and lis of user ids as values
        Map<Id, Map<string,List<id>>> Territory2UserIdsMap = new Map<Id, Map<string,List<id>>>();
        //Map with Account id as key and map of functional role and list of user ids as value
        Map<id,Map<string,List<id>>> AccountTerritoryTeamMap =new Map<id,Map<string,List<id>>>();
        List<userterritory2Association> userAssoObjList=new List<userterritory2Association>();
            
        for(Account accObj:accObjList){
            //account has salesforce territory Id
            if(accObj.Salesforce_Territory_Id__c!=null){
                AccountIdTerritoryIdMap.put(accObj.Id, accObj.Salesforce_Territory_Id__c);
            }
        }
        
        //Query userAssoObjList to get associated users of Territory2
        userAssoObjList=[select id,userid,territory2id,user.Functional_Role__c,RoleInTerritory2 from userterritory2Association where territory2id in:AccountIdTerritoryIdMap.values()];
        
        
        //Fill Map of Territory Team members with functional roles, keyed by the territory id
        for(userterritory2Association usrObj:userAssoObjList){
            if(Territory2UserIdsMap.containsKey(usrObj.territory2id)){  
                if(Territory2UserIdsMap.get(usrObj.territory2id).containsKey(usrObj.RoleInTerritory2)){
                    Territory2UserIdsMap.get(usrObj.territory2id).get(usrObj.RoleInTerritory2).add(usrObj.userId);   
                }   
                else{
                    Territory2UserIdsMap.get(usrObj.territory2id).put(usrObj.RoleInTerritory2,new List<Id> { usrObj.userId});    
                }
        
            }
            else{
                Territory2UserIdsMap.put(usrObj.territory2id,new Map<String,List<id>>{usrObj.RoleInTerritory2  => new List<Id> { usrObj.userId}});    
            }
        
        }
        
        //Map with Account id as key and map of functional role and list of user ids as value
        for(Id accountId : AccountIdTerritoryIdMap.keySet()){
        
            if(Territory2UserIdsMap.ContainsKey(AccountIdTerritoryIdMap.get(accountId))){
                AccountTerritoryTeamMap.put(accountId, Territory2UserIdsMap.get(AccountIdTerritoryIdMap.get(accountId)));
            }
        }

        Logger.pop();

        //return map
        return AccountTerritoryTeamMap;
    }
}