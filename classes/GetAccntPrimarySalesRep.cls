/**
 *@author Original: Shweta Shanbhag - Mathworks
 *@date Original:9/6/2016
 *@description: Invocable class that will be called from process builder and populate the account primary sales rep's email address on the get feedback object
 */


public class GetAccntPrimarySalesRep{
 @InvocableMethod(label='Get Case Account Primary Sales rep search' description='Returns the email address of the primary rep of account on the case')
  public Static void getPrimarySalesRepEmail(List<ID> getFBLst) {
   
	Logger.push('getPrimarySalesRepEmail', 'GetAccntPrimarySalesRep');
      Map<Id, Id> CaseAccntTerritoryIdMap = new Map<Id, Id>();
      Set<Id> terr2IdSet = new Set<Id>();
      Map<Id, UserTerritory2Association> terrToprimarySalesRep = new Map <Id, UserTerritory2Association>();
      List<Get_Feedback__c> getFBUpdList = new List<Get_Feedback__c>();
    
    for ( Get_Feedback__c getFBObj: [SELECT Case__r.Id, Case__r.Account.Salesforce_Territory_Id__c   FROM Get_Feedback__c WHERE Id in :getFBLst])
      {
          CaseAccntTerritoryIdMap.put(getFBObj.Case__r.Account.Salesforce_Territory_Id__c, getFBObj.Case__r.Id);
          system.debug('***CaseAcctterrMap***'+CaseAccntTerritoryIdMap);
          terr2IdSet.add(getFBObj.Case__r.Account.Salesforce_Territory_Id__c);
          system.debug('***TerrIdSet***'+terr2IdSet);    
      }
      
      if(!terr2IdSet.isEmpty())
      { terrToprimarySalesRep = Territory2HandlerDML.getprimarysalesrep(terr2IdSet);
      
      for (Get_Feedback__c GetFBUpdObj: [SELECT Case__r.Id, Case__r.Account.Salesforce_Territory_Id__c FROM Get_Feedback__c WHERE Id in :getFBLst AND Case__r.Account.Salesforce_Territory_Id__c in:terrToprimarySalesRep.keyset() ] )
      {
         GetFBUpdObj.Service_Primary_Sales_Rep_email__c  = (terrToprimarySalesRep.get(GetFBUpdObj.Case__r.Account.Salesforce_Territory_Id__c)).User.email;
         getFBUpdList.add(GetFBUpdObj);
      }
      
      if(!getFBUpdList.IsEmpty())
      { update getFBUpdList;
      }
      }
    Logger.pop();
  }

}