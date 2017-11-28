public class ContactTriggerHandler {

    /**
     * @author Original: kishore AN - Cloud Shepras/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks, Faina Gorelik - MathWorks AtTask 860052
     * @date Original: , Last Modified: 03 April 2015, 17 April 2015
     * @description Method that handles before insert trigger event on the Contact object
     * @param List_Contacts A collection of Contacts to create new COntact
     */
    public void onBeforeInsert(List<Contact> List_Contacts){    
        Logger.push('onBeforeInsert','ContactTriggerHandler ');

        List<Contact> contactList = new List<Contact>();
        List<Account> acct_List = new List<Account>();
        Set<Id> accountSet = new Set<Id>();
        Set<Id> acctSet = new Set<Id>();
        
        //For loop travers the contacts 
        if(!List_Contacts.isEmpty())
        {
            for(Contact conobj:List_Contacts){
                //check to see if the contact is created in sfdc directly. contact will not have cds contact id yet.
                if(conobj.CDS_Contact_Id__c ==null && conobj.AccountId != null){
                    acctSet.add(conobj.AccountId );
                }
            }
            //get the account address fields associated with the contacts so that we can compare teh addresses
            if(!acctset.isEmpty()){ 
                acct_List = [SELECT Id,BillingCity,BillingState,BillingCountry,BillingStreet,Account_City_Latin__c,Account_Street_Latin__c,Account_State_Province_Latin__c
                                         FROM Account WHERE Id IN :acctSet limit 10000];
            }
            
            for(Contact contObj:List_Contacts){
                //check if the contact has CDS contact and compare the contact address with account address
                //if they are the same, set the account latin address on the contact
                if(contObj.CDS_Contact_Id__c ==null ){
                     for(Account acc : acct_List){ 
                         
                        if(acc.Id == contObj.AccountId){ System.Debug('In Contact Trigger checking before address fields check- Account Id:'+acc.Id); 
                             //if(contact is created as part of the lead conversion) then
                         // check for limited address fields on contact and account like city, state, country 
                         // else if address field like street, city, state, country   
                        
                         if(contObj.MailingCity !=null && acc.BillingCity !=null && acc.BillingStreet !=null &&  acc.BillingState !=null &&  acc.BillingCountry !=null){       
                                
                                System.Debug('before checking if the address matched');
                               
                                if( contObj.MailingCity == acc.BillingCity && (contObj.MailingStreet == acc.BillingStreet || (contObj.MailingStreet == '' || contObj.MailingStreet == null))){
                                    System.debug('Address on contact and account matched');
                                    //set the latin address only if they don't have a value
                                    if(contObj.Street_Latin__c == null || contObj.Street_Latin__c =='')
                                        contObj.Street_Latin__c=acc.Account_Street_Latin__c; 
                                if(contObj.City_Latin__c == null || contObj.City_Latin__c =='')  
                                        contObj.City_Latin__c=acc.Account_City_Latin__c;
                                if(contObj.State_Province_Latin__c == null || contObj.State_Province_Latin__c =='')
                                  contObj.State_Province_Latin__c = acc.Account_State_Province_Latin__c;
                             }
                            }                            
                        }                                     
                    } 
                }

                //set the Address Changed Date to now if any of the relevant address fields are provided (not null)
                if(contObj.MailingCountrycode != null || contObj.MailingStatecode != null || contObj.MailingCountry != null || contObj.County_Local__c != null || 
                    contObj.State_Province_Latin__c != null || contObj.City_Latin__c != null || contObj.Street_Latin__c != null){
                        contObj.Address_Changed_Date__c = DateTime.now(); 
                }
                
                //set the Account Changed Date to now since this is an insert
                contObj.Account_Changed_Date__c = DateTime.now();
                
                //get a set of all unique Accounts from the Contacts being inserted
                accountSet.add(contObj.AccountId);     
                
            }
             
            if(!accountSet.isEmpty()){
                
                //get a list of all contacts for all individual accounts in this transaction in order to prevent 
                //inserting an additional contact (Individual Accounts can only have 1 contact)
                List<Account> accountList = [SELECT Id,Is_Individual_Account__c,(SELECT Id FROM Contacts) 
                                             FROM Account 
                                             WHERE Id IN :accountSet AND Is_Individual_Account__c = true];
                                             
               for(Contact contObj:List_Contacts){
                
                    for(Account acc : accountList){
                        
                        if(acc.contacts.size()==1){
                            
                            if(acc.Id == contObj.AccountId){                                    
                                contObj.addError(system.label.Individual_Account_Error_Message);
                            }
                        }                        
                    }
                }
            }   
        }
        
        Logger.pop();
        
         
    }
     /**
     * @author Original: Krishna - Mathworks, Last Modified: Andy Ognenoff - Cloud Sherpas
     * @date Original: May 27 2014 , Last Modified: Oct 28 2014
     * @description Method that handles before update trigger event on the Contact object
     * @param oldmap contact records with old values
     * @param newmap contact records with new values
     */
    public void onBeforeUpdate(map<Id, Contact> oldmap, map<Id, Contact> newmap){
        Logger.push('onBeforeUpdate','ContactTriggerHandler ');
        /**
            Author added: Krishna 
            Date: May 27 2014
            Desc: Compare the previous values to the new values of all of the elements of the Contact  address (both local and Latin), 
            if any have changed, update the Address Changed Date/Time field with the current system date and time
        */
        List<Contact> contactList = new List<Contact>();
        Set<Id> accountSet = new Set<Id>();
        
        for(Id tempContact:oldmap.keySet()){
            if(newmap.get(tempContact).MailingCountrycode!=oldmap.get(tempContact).MailingCountrycode || 
                newmap.get(tempContact).MailingStatecode!=oldmap.get(tempContact).MailingStatecode ||
                newmap.get(tempContact).MailingCountry!=oldmap.get(tempContact).MailingCountry ||
                newmap.get(tempContact).MailingStreet!=oldmap.get(tempContact).MailingStreet ||
                newmap.get(tempContact).MailingCity!=oldmap.get(tempContact).MailingCity ||
                newmap.get(tempContact).MailingPostalCode!=oldmap.get(tempContact).MailingPostalCode ||
                newmap.get(tempContact).County_Local__c!=oldmap.get(tempContact).County_Local__c ||                  
                newmap.get(tempContact).State_Province_Latin__c!=oldmap.get(tempContact).State_Province_Latin__c || 
                newmap.get(tempContact).City_Latin__c!=oldmap.get(tempContact).City_Latin__c || 
                newmap.get(tempContact).Street_Latin__c!=oldmap.get(tempContact).Street_Latin__c ){
                
                    newmap.get(tempContact).Address_Changed_Date__c = DateTime.now();                
            }
            
            //set the Account Changed Date to now if the Account has changed
            if(newmap.get(tempContact).AccountId!=oldmap.get(tempContact).AccountId){
                newmap.get(tempContact).Account_Changed_Date__c = DateTime.now();
            }     
        }
        
        for(Contact cont : newmap.values()){
            if(newmap.get(cont.Id).AccountId != oldmap.get(cont.Id).AccountId){
                accountSet.add(cont.AccountId);
            }
        }
        
        if(!accountSet.isEmpty()){
            
            //get a list of all contacts for all individual accounts in this transaction in order to prevent 
            //updating a contact to an existing individual account (Individual Accounts can only have 1 contact)
            List<Account> accountList = [SELECT Id,Is_Individual_Account__c,(SELECT Id FROM Contacts) 
                                         FROM Account 
                                         WHERE Id IN :accountSet AND Is_Individual_Account__c = true];
                                         
            for(Contact contObj: newmap.values()){
                
                for(Account acc : accountList){
                    
                    if(acc.contacts.size() > 1){
                        
                        if(acc.Id == contObj.AccountId){                            
                            contObj.addError(system.label.Individual_Account_Error_Message);
                        }
                    }                    
                }                
            }
        }  
        
       Logger.pop();

    }

    /**
     * @author Original: 
     * @date Original: , Last Modified:17 April 2015
     * @description Method that handles after insert trigger event on the Contact object
     * @param List_Contacts A collection of Contacts to create new Contact
     */
    public void onAfterInsert(List<Contact> List_Contacts){  
        Logger.push('onAfterInsert','ContactTriggerHandler ');
               
        ContactDML cntDML = new ContactDML();         
        
        List<Contact> contbjList=[select MailingCountrycode ,MailingStatecode,MailingCountry,MailingState,MailingCity,MailingStreet,
                                  MailingPostalCode ,County_Local__c, State_Province_Latin__c,name,
                                  City_Latin__c,Street_Latin__c ,Accountid,
                                  FirstName,LastName
                                  from contact where id in :List_Contacts ]; 
        
        cntDML.createDummyAccount(contbjList); 
        cntDML.replaceContactAddress(contbjList); 
       // cntDML.createHVCPUser(List_Contacts); SS 1/25/15 - Commented as this is covered in Custom JIT
        
       
        
        Logger.pop();
    }

     /**
     * @author Original: 
     * @date Original: , Last Modified: 3/20/2014
     * @description Method that handles after update trigger event on the Contact object
     * @param oldmap contact records with old values
     * @param newmap contact records with new values
     * 
     */
    public void onAfterUpdate(map<Id, Contact> oldmap, map<Id, Contact> newmap){
        Logger.push('onAfterUpdate','ContactTriggerHandler ');
        
        Set<ID> setContactId = new set<ID>(); 

        /** 
           Added By : Jaspreet 
           Description: Following snippet it written to filter the records to be updated.
           Reason : This is done to reduce the future calls for method updateHVCPUser of class ContactDML
           Why Future Method: Standard fields of standard objects can not be updated sync after update of any object  
         */

        for(Id tempContact:oldmap.keySet()) 
        {
            if(newmap.containsKey(tempContact)) 
            {
                if(newmap.get(tempContact).Email != oldmap.get(tempContact).Email 
                        || newmap.get(tempContact).FirstName != oldmap.get(tempContact).FirstName 
                        || newmap.get(tempContact).LastName != oldmap.get(tempContact).LastName 
                        || newmap.get(tempContact).Country_Code__c != oldmap.get(tempContact).Country_Code__c
                        || newmap.get(tempContact).Siebel_Contact_Id__c != oldmap.get(tempContact).Siebel_Contact_Id__c
                        || newmap.get(tempContact).Student__c != oldmap.get(tempContact).Student__c
                        || newmap.get(tempContact).MathWorks_Account_ID__c != oldmap.get(tempContact).MathWorks_Account_ID__c)
                {
                    setContactId.add(newmap.get(tempContact).Id);
                }
            }
        }

        if(setContactId.size() > 0)
        {
            ContactDML.updateHVCPUser(setContactId);
        }  

        List<Contact> contList=new List<Contact>();

        for(Id tempAccount:oldmap.keySet()){
            if(newmap.get(tempAccount).MailingCountryCode != oldmap.get(tempAccount).MailingCountrycode
                    || newmap.get(tempAccount).MailingStateCode != oldmap.get(tempAccount).MailingStateCode 
                    || newmap.get(tempAccount).MailingStreet != oldmap.get(tempAccount).MailingStreet 
                    || newmap.get(tempAccount).MailingCity != oldmap.get(tempAccount).MailingCity
                    || newmap.get(tempAccount).MailingPostalCode != oldmap.get(tempAccount).MailingPostalCode
                    || newmap.get(tempAccount).County_Local__c != oldmap.get(tempAccount).County_Local__c){

                contList.add(newmap.get(tempAccount));
            }
 
        }

        //Calling method to replace the non latin strings if required and it will save it moving ahead



        List<Contact> contbjList=[select MailingCountrycode ,MailingStatecode,MailingCity,MailingStreet,
                                  MailingCountry,MailingState,name,
                                  MailingPostalCode ,County_Local__c,State_Province_Latin__c, 
                                  City_Latin__c,Street_Latin__c 
                                  from contact where id in :contList ];  

        ContactDML cntDML = new ContactDML();
        cntDML.replaceContactAddress(contbjList);
        
	    //Added by Haigang Wu Mar-28-2016 , in order to execute Story# 1418335
	    Set<ID> setContactLeadId = new set<ID>(); 
        for(Id tempAccount:oldmap.keySet()){
            if(newmap.get(tempAccount).AccountId != oldmap.get(tempAccount).AccountId){
                setContactLeadId.add(tempAccount);
            }
        }
	    
		if (setContactLeadId.size() > 0) {
	        List<Lead> leadList = [Select Id, Account__c, Contact__c from Lead 
	        	where Contact__c In : setContactLeadId 
	        	and RecordType.Name = 'Known Contact' 
	        	and status not in ('Closed - Converted', 'Closed - Unconverted') limit 10000];
	        
	        for(Lead objLead:leadList) {
		        objLead.Account__c = newmap.get(objLead.Contact__c).AccountId;
	        }
	        update leadList;
	    }
	    
        Logger.pop();
    }    
    
}