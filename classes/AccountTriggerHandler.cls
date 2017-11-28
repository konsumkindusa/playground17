/** 
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik AtTask 1919914 
 *@date Original: 13 May 2014, Last Modified: 12 Aug 2016, 20 Feb 2017
 *@description This  is handler class for 'AccountMasterTrigger' . 
 *@Revision 28 July 2014 | Archana Lohar | Added code to call assignAccountsToTerritory of TerritoryAssignmentManager for assigning account to Territory
 *@Revision 12 Aug 2016 | Haigang Wu | Added support for Master_Territory_ID__c. 20 Feb 2017| Faina Gorelik| Count Number of Child accounts associated with CPN
 */ 
public with sharing class AccountTriggerHandler {

    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description Method that handles before insert trigger event on the Account object
     * @param Account A collection of Account to create new Account
     */
    public void onBeforeInsert(List<Account> List_Account){        
        Logger.push('onBeforeInsert','AccountTriggerHandler ');
        /** 
           Added by : Krishna - Mathworks, Last Modified - Faina Gorelik //fg AtTask 1919914
           Desc: If there is a value in any of the elements of the Account Address (both local and Latin), update the Address Changed 
           Date/Time field with the current system date and time 
         */
      //For loop travers the accounts
        if(!List_Account.isEmpty()){
            for(Account accObj: List_Account){
                if(accObj.BillingCountry != null || accObj.BillingState != null || accObj.BillingCountryCode != null ||
                        accObj.BillingStateCode != null || accObj.BillingCity != null || accObj.BillingStreet != null ||
                        accObj.BillingPostalCode != null || accObj.County__c != null ||
                        accObj.Account_State_Province_Latin__c != null || 
                        accObj.Account_City_Latin__c != null || accObj.Account_Street_Latin__c != null || 
                        accObj.Account_County_Latin__c != null){

                    accObj.Address_Changed_Date__c = DateTime.now();                    
                }
              
                System.Debug('Account name in acct trigger:'+accObj.Name);
            }            
        } 
        Logger.pop();
    }
    /**
     * @author Original: Krishna - Mathworks, Last Modified: Andy Ognenoff - Cloud Sherpas
     * @date Original: May 27 2014, Last Modified: Oct 24 2014
     * @description Method that handles before update trigger event on the Account object
     * @param oldmap Account records with old values
     * @param newmap Account records with new values
     */
    public void onBeforeUpdate(map<Id, Account> oldmap, map<Id, Account> newmap){

        Logger.push('onBeforeUpdate','AccountTriggerHandler ');
        /**
            Author added: Krishna 
            Date: May 27 2014
            Desc: Compare the previous values to the new values of all of the elements of the Account address (both local and Latin), if any have changed, 
                  update the Address Changed Date/Time field with the current system date and time 

         */
        for(Id tempAccount:oldmap.keySet()){
            if(     newmap.get(tempAccount).BillingStreet != oldmap.get(tempAccount).BillingStreet || 
                    newmap.get(tempAccount).BillingCountry != oldmap.get(tempAccount).BillingCountry || 
                    newmap.get(tempAccount).BillingState != oldmap.get(tempAccount).BillingState ||
                    newmap.get(tempAccount).BillingCountryCode != oldmap.get(tempAccount).BillingCountryCode ||
                    newmap.get(tempAccount).BillingStateCode != oldmap.get(tempAccount).BillingStateCode ||
                    newmap.get(tempAccount).BillingCity != oldmap.get(tempAccount).BillingCity ||
                    newmap.get(tempAccount).BillingPostalCode != oldmap.get(tempAccount).BillingPostalCode ||
                    newmap.get(tempAccount).County__c != oldmap.get(tempAccount).County__c ||                    
                    newmap.get(tempAccount).Account_State_Province_Latin__c != oldmap.get(tempAccount).Account_State_Province_Latin__c ||
                    newmap.get(tempAccount).Account_City_Latin__c != oldmap.get(tempAccount).Account_City_Latin__c ||
                    newmap.get(tempAccount).Account_Street_Latin__c != oldmap.get(tempAccount).Account_Street_Latin__c ||                    
                    newmap.get(tempAccount).Account_County_Latin__c != oldmap.get(tempAccount).Account_County_Latin__c 
                    ){
                newmap.get(tempAccount).Address_Changed_Date__c = DateTime.now();                
            }
        }// end for
        Logger.pop();
    }
    /**
     * @author Original: 
     * @date Original: , Last Modified: 12 Aug 2016, 20 Feb 2017
     * @description Method that handles after insert trigger event on the Contact object
     * @param List_Contacts A collection of Contacts to create new Contact
     *@Revision 28 July 2014 | Archana Lohar | Added code to call assignAccountsToTerritory of TerritoryAssignmentManager for assigning account to Territory
     *@Revision 12 Aug 2016 | Haigang Wu | Added support for Master_Territory_ID__c
	 *@Revision 20 Feb 2017|Faina Gorelik| AtTask 1919914 | Added CPN Account Logic
     */
    public void onAfterInsert(List<Account> List_Account){ 
        Logger.push('onAfterInsert', 'AccountTriggerHandler');
        
        AccountDML accDml=new AccountDML();
        List<Account> accObjListToPass=new List<Account>();
        //Fetching date from General custom setting
        General_Settings__c settings = General_Settings__c.getInstance();
        Territory_Settings__c tmSettings = Territory_Settings__c.getInstance(); //HW, 1617306

		//HW, 1617306, add query for Master_Territory_ID__c, remove Siebel_Territory_ID__c when retiring Siebel
        List<Account> accList=[select BillingCountry,BillingState,BillingCountryCode,BillingStateCode,name,
                               Account_State_Province_Latin__c,Siebel_Territory_ID__c,Master_Territory_ID__c 
                               from Account where id in :List_Account];
         accDml.replaceAccountAddress(accList);
        //fg 1919914 
		Set<Id> CPNId = new Set<Id>();
      //  for (Account acctCPN : [select Corporate_Parent_Name__c from Account where Id in : List_Account ]){
         //   if (string.isNotBlank(acctCPN.Corporate_Parent_Name__c) ){
           //     CPNId.add(acctCPN.Corporate_Parent_Name__c);
           // }
       // }   
         
        //check if Bypass_Assignment_Of_Account_To_Territor__c of general setting is false
        if(settings.Bypass_Assignment_Of_Account_To_Territor__c==false){

            //For loop to traverse the accounts 
            for(Account accObj: accList){

				//HW, 1617306, remove the else branch when retiring Siebel
				if (tmSettings.Territory_Assignment_Lookup_Field__c == 'Master') {
	                if(accObj.Master_Territory_ID__c!=null && !accObj.Is_Individual_Account__c && accObj.Master_Territory_ID__c!=''){
	                    accObjListToPass.add(accObj);
	                }
	                
				} else { //Siebel branch
	                if(accObj.Siebel_Territory_ID__c!=null && !accObj.Is_Individual_Account__c && accObj.Siebel_Territory_ID__c!=''){
	                    accObjListToPass.add(accObj);
                      
	                }
				}
            }// end for

            if(accObjListToPass!=null && !accObjListToPass.isEmpty()){
				if (tmSettings.Territory_Assignment_Lookup_Field__c == 'Master') {
	                TerritoryAssignmentManager.assignAccountsToTerritoryMaster(accObjListToPass);
				} else { //Siebel branch
	                TerritoryAssignmentManager.assignAccountsToTerritory(accObjListToPass);
				}
            }
			//1617306
			
			//fg 
          // if (CPNId.size()>0){
               // accDml.AddCPNChildCount(CPNId);
          //  }
			//fg end
        }
        
        Logger.pop();
    }//onAfterInsert

    /**
     * @author Original: 
     * @date Original: , Last Modified: 12 Aug 2016, , Faina Gorelik AtTask 1919914 
     * @description Method that handles after update trigger event on the Contact object
     * @param oldmap contact records with old values
     * @param newmap contact records with new values
     * @Revision 28 July 2014 | Archana Lohar | Added code to call assignAccountsToTerritory of TerritoryAssignmentManager for assigning account to Territory. 
     * @Revision 12 Aug 2016 | Haigang Wu | Added support for Master_Territory_ID__c
     * @Revision 20 Feb 2017|Faina Gorelik| Added logic to recalculate number of the children associated with CPN
     */
    public void onAfterUpdate(map<Id, Account> oldmap, map<Id, Account> newmap){
        Logger.push('onAfterUpdate', 'AccountTriggerHandler');
        List<Account> accList=new List<Account>();

        List<Account> accListChangedSTI=new List<Account>();
        Set <Id> Set_AddCPN_id = new Set <Id>();//fg AtTask 1919914
        //Fetching date from General custom setting
        General_Settings__c settings = General_Settings__c.getInstance();
        Territory_Settings__c tmSettings = Territory_Settings__c.getInstance(); //HW, 1617306

        for(Id tempAccount:oldmap.keySet()){
            if(newmap.get(tempAccount).BillingCountry != oldmap.get(tempAccount).BillingCountry
                    || newmap.get(tempAccount).BillingState != oldmap.get(tempAccount).BillingState){
                accList.add(newmap.get(tempAccount));
            }
            
			//HW, 1617306, remove the else branch when retiring Siebel
			if (tmSettings.Territory_Assignment_Lookup_Field__c == 'Master') {
	            if((newmap.get(tempAccount).Master_Territory_ID__c != oldmap.get(tempAccount).Master_Territory_ID__c )){
	                    accListChangedSTI.add(newmap.get(tempAccount));
	            }
                
			} else { //Siebel branch
	            if((newmap.get(tempAccount).Siebel_Territory_ID__c != oldmap.get(tempAccount).Siebel_Territory_ID__c )){
	                    accListChangedSTI.add(newmap.get(tempAccount));
	            }
			}
			//1617306
					
            //fg  AtTask 1919914 
    
        //   for (Account acct : newmap.values()){
             //   if ((oldmap.get(acct.id).Corporate_Parent_Name__c != acct.Corporate_Parent_Name__c) && string.isNotBlank(oldmap.get(acct.id).Corporate_Parent_Name__c)){   
                  	//Set_AddCPN_id.add(oldmap.get(acct.id).Corporate_Parent_Name__c);// update count children account on deleted CPN
               // }
               // if (string.isNotBlank(acct.Corporate_Parent_Name__c) ){
                 //  Set_AddCPN_id.add(acct.Corporate_Parent_Name__c); // update count children account on added CPN
              //  }
          //  }// end for
		
        }
        List<Account> accObjList=[select BillingCountry,BillingState,BillingCountryCode,BillingStateCode,name,
                                  Account_State_Province_Latin__c
                                  from Account where id in :accList limit 10000];


        //Calling method to replace the non latin strings if required and it will save it moving ahead
        AccountDML accDml=new AccountDML();
        accDml.replaceAccountAddress(accObjList);
        
      //fg AtTask 1919914 list of the CPN accounts to be updated with the number of children accounts
   
       // if (Set_AddCPN_id.size()>0){
          //  accDml.AddCPNChildCount(Set_AddCPN_id);
      //  }

        if(accListChangedSTI!=null && !accListChangedSTI.isEmpty()){

            //check if Bypass_Assignment_Of_Account_To_Territor__c of general setting is false
            if(settings.Bypass_Assignment_Of_Account_To_Territor__c==false){

				//HW, 1617306, remove the else branch when retiring Siebel
				if (tmSettings.Territory_Assignment_Lookup_Field__c == 'Master') {
	                TerritoryAssignmentManager.assignAccountsToTerritoryMaster(accListChangedSTI);
				} else { //Siebel branch
	                TerritoryAssignmentManager.assignAccountsToTerritory(accListChangedSTI);
				}
				//1617306

            }
            //Opportunity assignment by account 
            accDml.assignOpportunitiesByRole(accListChangedSTI);

        }   
        Logger.pop();

    } 

}