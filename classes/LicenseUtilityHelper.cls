/**
 *@author Original: Sagar Talele- Cloud Sherpas/Mathworks,
 *@Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original: 20 Feb 2015, Last Modified: 19 Feb 2015
 *@description This is Utility Class for License
 */
 
public with sharing class LicenseUtilityHelper{
 	
    public static Map<String,Account> OverrideAccountIdMap{get;set;}
    public static Map<String,Contact> LicenseAdministratorIdMap{get;set;} 
    public static Map<String,Account> LicenseAccountIdMap{get;set;} 
    /*
   *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks,
   *@Last Modified: Sagar  Talele - Cloud Sherpas/Mathworks,
   *@Date Original: 20 Feb 2015,
   *@Last Modified: 20 Feb 2015
   *@Description:It will create all maps for showing drilldowns on License page
   */
  public static void BuildDrilldownMaps(List<LicenseBean.License> licenseList){
      //Initialize List
      list<String> OverrideAccountIdLst=new  list<String>();
      list<String> LicenseAdministratorIdLst=new  list<String>();
      list<String> LicenseAccountIdLst=new  list<String>();
      if(!licenseList.isEmpty()){
                
                for(LicenseBean.License licenseobj :licenseList){

                    If(licenseobj.overrideAccountId!=null){ 
                            
                        OverrideAccountIdLst.add(licenseobj.overrideAccountId);
                        LicenseAdministratorIdLst.add(licenseobj.administratorId);
                        LicenseAccountIdLst.add(licenseobj.licenseAccountId);
                        
                            
                    }
                 }
          		    	OverrideAccountIdMap = new Map<String,Account>();
                        LicenseAdministratorIdMap = new Map<String,Contact>();
          	            LicenseAccountIdMap = new Map<String,Account>();
          
                    //Fill map to get account ids having Override Account Id as siebel account id  
                    For(Account accObj:[select id,Siebel_Account_Id__c,name,Account_Name_Latin__c from account where Siebel_Account_Id__c in:OverrideAccountIdLst]){

                        OverrideAccountIdMap.put(accObj.Siebel_Account_Id__c,accObj);
                    }

                    //Fill map to get account ids having Lisence Account Id as siebel account id  
                    For(Account accObj:[select id,Siebel_Account_Id__c,name,Account_Name_Latin__c from account where Siebel_Account_Id__c in:LicenseAccountIdLst])
                           LicenseAccountIdMap.put(accObj.Siebel_Account_Id__c,accObj);
                  
                     //Fill map to get Contact ids having Administrator Id as sibel contact id  
                    For(Contact conObj:[select id,lastname,Siebel_Contact_Id__c,name, First_Name_Latin__c, Last_Name_Latin__c  from Contact where Siebel_Contact_Id__c in:LicenseAdministratorIdLst])
                           LicenseAdministratorIdMap.put(conObj.Siebel_Contact_Id__c,conObj);
                    
                    //Fill map With OverrideAccountIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String overrideAccountIdKey: OverrideAccountIdLst){
                        if(!OverrideAccountIdMap.containskey(overrideAccountIdKey)){
                         OverrideAccountIdMap.put(overrideAccountIdKey,new Account(name='DummyAccount'));
                         
                         }
                    }
                    //Fill map With LicenseAccountIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String lisenceAccountIdKey: LicenseAccountIdLst){
                        if(!LicenseAccountIdMap.containskey(lisenceAccountIdKey)){
                         LicenseAccountIdMap.put(lisenceAccountIdKey,new Account(name='DummyAccount'));
                         }
                    }
                    
                    //Fill map With  LicenseAdministratorIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String administratorIdKey: LicenseAdministratorIdLst){
                        if(!LicenseAdministratorIdMap.containskey(administratorIdKey)){
                         LicenseAdministratorIdMap.put(administratorIdKey,new contact(lastName='DummyContact') );
                         }
                    }
  
      }
  }
  /*
   *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks,
   *@Last Modified: Sagar  Talele - Cloud Sherpas/Mathworks,
   *@Date Original: 20 Feb 2015,
   *@Last Modified: 20 Feb 2015
   *@Description:It will return OverrideAccountIdMap for Drilldown
   */
    public static Map<String,Account> getOverrideAccountIdMap(){
      return OverrideAccountIdMap;
    }
  /*
   *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks,
   *@Last Modified: Sagar  Talele - Cloud Sherpas/Mathworks,
   *@Date Original: 20 Feb 2015,
   *@Last Modified: 20 Feb 2015
   *@Description:It will return OverrideAccountIdMap for Drilldown
   */
     public static Map<String,Contact> getLicenseAdministratorIdMap(){
     return LicenseAdministratorIdMap;
    }
  /*
   *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks,
   *@Last Modified: Sagar  Talele - Cloud Sherpas/Mathworks,
   *@Date Original: 20 Feb 2015,
   *@Last Modified: 20 Feb 2015
   *@Description:It will return OverrideAccountIdMap for Drilldown
   */
     public static Map<String,Account> getLicenseAccountIdMap(){
         return LicenseAccountIdMap;
    }
  
}