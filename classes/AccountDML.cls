/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik AtTask 1919914 
 *@date Original: 15 May 2014, Last Modified: 13 June 2014, 20 Feb 2017
 *@description This  is handler class for 'AccountMasterTriggerHandler' . 
 *@Revision:26 sep 2014|Archana Lohar 
 */
public  class AccountDML {
    
    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: kishoe AN - Cloud Sherpas/Mathworks, Faina Gorelik AtTask 1919914 
     *@Date Original: 15 May 2014
     *@Last Modified: 25 May 2014,20 Feb 2017
     *@Description: It will accept the list of accounts and sets the the latin value on the state latin fields
      for the address fields (state) with non-latin values
     *               
     */ 
        
     /*public void AddCPNChildCount(set <Id> Set_CPNID){ //fg
     Logger.push('AddCPNChildCount','AccountDML');
     List<Account> cpnaddaccountList=new List<Account>();// list of CPN to be updated with number of the children accounts
     List <Account> accnAddChild =[select id,Child_Accounts__c from Account where id in : Set_CPNID Limit 50000];
         for (Account accnt : accnAddChild){
               integer a = [select count() from Account where Corporate_Parent_Name__c in :Set_CPNID ];
               accnt.Child_Accounts__c = a;
               cpnaddaccountList.add(accnt);  
         }//end for
         try{
             if(cpnaddaccountList.size()>0){
                 update cpnaddaccountList;
             } 
         }
         catch(system.DmlException e){
               for (Integer i = 0;i < e.getNumDml();i++){
               Logger.debugException('Error in AddCPNChildCount' + e.getDmlMessage(i)+ 'for ID:' + e.getDmlId(i));
           }
         }

        
         Logger.pop(); 
    }// end 
    //fg end
    */
    public void replaceAccountAddress(list<Account> retAcctLst){
        Logger.push('replaceAccountAddress','AccountDML');
        
        //List to add the accounts to insert 
        List<Account> accountList=new List<Account>();
        
        //instantiating CS_LatinAddressUtilityHelper class
        LatinAddressUtilityHelper utilObj = new LatinAddressUtilityHelper();

        
        //map to get the country names
        Map<string,string>countryMap=utilObj.getCountryMap(Account.BillingCountryCode.getDescribe().getPickListValues());
        
        if(!retAcctLst.isEmpty() && retAcctLst != NULL){

            //For loop to traverse the accounts list which has latin state
            for(Account accObj: retAcctLst){
                
              
                /* Create the Address object, assign the values to address variables and 
                pass the object to utility class to get the replaced or converted values if necessary*/
                
                Address addrObj = new Address();
                addrObj.setName(accObj.Name != NULL ? accObj.Name : '');
                addrObj.setCountry(accObj.BillingCountrycode != NULL ? countryMap.get(accObj.BillingCountrycode) : '');
                addrObj.setStateCode(utilObj.getStateCode(accObj.BillingCountrycode, accObj.BillingStateCode ));
                addrObj.setState(accObj.BillingState != NULL ? accObj.BillingState : '');
                Logger.debug(' LocalState value:'+accObj.BillingState  + ' on Account Id:'+ accObj.Id );
                //calling utility class to get the latinAddress
                addrObj = utilObj.getLatinAddress(addrObj);

                //setting the replaced values back to Account latin state field               
                accObj.Account_State_Province_Latin__c = addrObj.getState();
               
                accountList.add(accObj);
                Logger.debug(' Latin state value:'+accObj.Account_State_Province_Latin__c + ' on Account Id:'+ accObj.Id );
               
              
            }//for


        }//if
        
        try
        {
            if(!accountList.isEmpty())
            {
                update accountList;
            }
            
        }
        catch (System.DmlException e) {            
           
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                //Logger.DebugException('Error in replaceAccountAddress:'+e.getMessage());
                Logger.debugException('Error in replaceAccountAddress:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }
       Logger.pop(); 
       
    }
        
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Andy Ognenoff - Cloud Sherpas/Mathworks
     *@Date Original: 22 Aug 2014 
     *@Last Modified: 22 Sep 2014
     *@Description: It will accept the list of accounts and Query for all Opportunities
                    associated to the Accounts that have changed territories AND 
                    that are currently owned by the generic system owner 
     */ 
      public void assignOpportunitiesByRole(list<Account> accList){
        
        //Fetch general setting instance
        General_Settings__c settings= General_Settings__c.getInstance();
        
        List<id> optyIdsList=new List<id>();
        
        //Get user to set default opportunity and task owner by custom setting
        //We will query by alias as the name field has issues with different locales
        List<User> usrObjByName=new List<User>();
        usrObjByName=[select id,name from User where alias =:settings.Default_Opportunity_Owner__c ];
        
        List<Opportunity> optyList=new List<Opportunity>();
        
        if(usrObjByName!=null && !usrObjByName.isEmpty()){
        
        //AO 22-Sep-2014: Added filter to only look at open opps
        optyList=[select id
                  FROM Opportunity WHERE IsClosed = false AND
                  accountid in:accList AND ownerid=:usrObjByName[0].id];
        }
        
        for(Opportunity opty:optyList){
            
            optyIdsList.add(opty.id);
        }
       
        
        OpportunityAssignmentManager.assignOpportunitiesByTerritoryTeamRoles(optyIdsList);
   
      }
        
}