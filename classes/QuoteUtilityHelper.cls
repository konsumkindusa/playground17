/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 19 Feb 2015, Last Modified: 19 Feb 2015
 *@description This is Utility Class for Quotes
 */
public with sharing class QuoteUtilityHelper {

	public Static Map<String,Opportunity> mapOpportunity; 
	public Static Map<String,Contact> mapContact;
	public Static Map<String,Account> mapAccount;

	/*
	 *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Date Original: 19 Feb 2015,
	 *@Last Modified: 19 Feb 2015
	 *@Description:It will create all maps for showing drilldowns on Quotes page
	 */
	public static void BuildDrilldownMaps(List<QuoteBean> quotesList){

		//Initialize variables
		List<String> opportunityIds=new List<String>();
		List<String> contactSiebelIdLst=new List<String>();
		List<String> accounttSiebelIdLst=new List<String>();

		If(!quotesList.isEmpty()){  

			for(QuoteBean quoteObj:quotesList){

				//if((quoteObj.opportunityId).startsWithIgnoreCase('006')){
				opportunityIds.add(quoteObj.opportunityId);
				//}
				contactSiebelIdLst.add(quoteObj.contactId);
				accounttSiebelIdLst.add(quoteObj.accountId);

			}

			//Map for Opportunity Drilldown
			if(!opportunityIds.isEmpty()){

				mapOpportunity = new Map<String,Opportunity>();
				for(Opportunity oppObj : [SELECT id, Name
				                          FROM Opportunity 
				                          WHERE id in :opportunityIds]){

					mapOpportunity.put(oppObj.id,oppObj);
				}

				//To avoid map key not found exceotion in page
				for(String oppid: opportunityIds){

					if(!mapOpportunity.containskey(oppid)){
						mapOpportunity.put(oppid,new Opportunity(Name='DummyOpportunity'));

					}

				}

			}

			//Map for Contact Drilldown
			if(!contactSiebelIdLst.isEmpty()){

				mapContact = new Map<String,Contact>();
				for(Contact conObj : [SELECT id,lastName, Name, Siebel_Contact_Id__c,
				                      First_Name_Latin__c, Last_Name_Latin__c
				                      FROM Contact 
				                      WHERE Siebel_Contact_Id__c in : contactSiebelIdLst]){


					mapContact.put(conObj.Siebel_Contact_Id__c,conObj);
				}
				//To avoid map key not found exceotion in page
				for(String conId: contactSiebelIdLst){

					if(!mapContact.containskey(conId)){
						mapContact.put(conId,new Contact(lastname='DummyContact'));

					}

				}

			} 

			//Map for count Drilldown
			if(!accounttSiebelIdLst.isEmpty()) {

				mapAccount = new Map<String,Account>();

				for(Account acc : [SELECT id, Siebel_Account_Id__c, Name, Account_Name_Latin__c 
				                   FROM Account 
				                   WHERE Siebel_Account_Id__c in : accounttSiebelIdLst]) {
					mapAccount.put(acc.Siebel_Account_Id__c,acc);
				}

				//To avoid map key not found exceotion in page
				for(String quoteAccountIdKey: accounttSiebelIdLst){

					if(!mapAccount.containskey(quoteAccountIdKey)){
						mapAccount.put(quoteAccountIdKey,new Account(name='DummyAccount'));

					}

				}

			}

		}

	}
	
	/*
	 *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Date Original: 19 Feb 2015,
	 *@Last Modified: 19 Feb 2015
	 *@Description:It will return OpportunityMap for Drilldown
	 */
	public static Map<String,Opportunity> getOpportunityMap(){
		
		return mapOpportunity;
	}
	
	/*
	 *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Date Original: 19 Feb 2015,
	 *@Last Modified: 19 Feb 2015
	 *@Description:It will return ContactMap for Drilldown
	 */
	public static Map<String,Contact> getContactMap(){
		
		return mapContact;
	}
	
	/*
	 *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
	 *@Date Original: 19 Feb 2015,
	 *@Last Modified: 19 Feb 2015
	 *@Description:It will return AccountMap for Drilldown
	 */
	public static Map<String,Account> getAccountMap(){
		
		return mapAccount;
	}

}