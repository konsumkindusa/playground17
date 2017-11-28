/** 
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Haigang Wu - Mathworks
 *@date Original: 23 July 2014, Last Modified: 12 Aug 2016
 *@description This is  class for handling territory assignments
 *@Revision:Archana Lohar|19 December 2014|Modified code to avoid heap size exception.
 *@Revision:Haigang Wu | 12 Aug 2016 | Added support for Master_Territory_ID__c.
 */
public with sharing class TerritoryAssignmentManager {

    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Kishore - Cloud Sherpas/Mathworks 
     *@Date Original: 23 July 2014
     *@Last Modified: 20 Jan 2015 - Added immediate retry logic, moved common code to a method
     *@Description: It will accept the list of accounts and assign it to territory.
     */ 
	//Remove this method when retiring Siebel
    public static void assignAccountsToTerritory(List<Account> accList){ 

        Logger.push('assignAccountsToTerritory','TerritoryAssignmentManager');

        //List of Territory2 with Territory model state is active
        List<Territory2> territoryList=new List<Territory2>();

        //List of accounts to populate fields
        List<Account> accListToUpdate=new List<Account>();

        //List of ObjectTerritory2Association which has already a territory assigned to the account
        List<ObjectTerritory2Association> territory2AssoList=new List<ObjectTerritory2Association>(); 

        //List of ObjectTerritory2Association to Insert
        List<ObjectTerritory2Association> territory2AssoListToInsert=new List<ObjectTerritory2Association>();
        
        //map to hold the retry attempts so that it can be used at a later time 
        //to set the correct retry attempts in our retry logic
        Map<Id, Integer> accountRetryAttemptsMap = new Map<Id, Integer>();
        
        //set of unique Territory IDs from the Accounts passed in
        Set<String> siebelTerritoryIdSet=new Set<String>();

        //accList may have these fields already but requerying to make this method independent from its caller
        List<Account> accObjList=[select id,Siebel_Territory_ID__c,Salesforce_Territory_Id__c, Territory_Name__c,
                                   Global_Region__c, Region__c, Office_Group__c, Office__c, Office_Channel__c, 
                                   Territory_Industry__c, Territory_Sales_Group__c, Territory_Sales_Team_Type__c, 
                                   TA_Attempts__c,Is_Individual_Account__c,Account_Territory_Sector__c,
                                   Account_Territory_Type__c
                                   from Account where id in :accList];

        for(Account accObj: accObjList){

            if(accObj.Siebel_Territory_ID__c!=null && !accObj.Is_Individual_Account__c && accObj.Siebel_Territory_ID__c!=''){

                siebelTerritoryIdSet.add(accObj.Siebel_Territory_ID__c);

            }//if

        }//for

        //Map of Territory2 objects, indexed by Siebel_Territory_ID__c
        map<String,Territory2> siebelTerritoryIdToTerritory2 = new map<String,Territory2>();
        
        //Form a map of siebelTerritoryId to Territory2  
        for(Territory2 territoryObj:[select id
                                     ,Siebel_Territory_ID__c
                                     ,Master_Territory_ID__c
                                     ,Global_Region__c
                                     ,Region__c
                                     ,Office_Group__c
                                     ,Office__c
                                     ,Office_Channel__c
                                     ,Territory_Industry__c
                                     ,Territory_Sales_Group__c
                                     ,Territory_Sales_Team_Type__c
                                     ,Name 
                                     ,Territory_Sector__c
                                     ,Territory2Type.MasterLabel
                                     from territory2 where 
                                     Siebel_Territory_ID__c in:siebelTerritoryIdSet and Territory2Model.state='Active']){
                                         
                                         siebelTerritoryIdToTerritory2.put(territoryObj.Siebel_Territory_ID__c,territoryObj);
                                         
                                     }
        

        //Populate account fields using associated Territory2 object fields
        for(Account accToAssign:accObjList){

            //check if Siebel_Territory_ID__c is empty
            if(accToAssign.Siebel_Territory_ID__c!=null && !accToAssign.Is_Individual_Account__c){

                Territory2 territoryObj = new Territory2();

                if(siebelTerritoryIdToTerritory2.containsKey(accToAssign.Siebel_Territory_ID__c) && 
                        siebelTerritoryIdToTerritory2.get(accToAssign.Siebel_Territory_ID__c)!=null){

                    territoryObj=siebelTerritoryIdToTerritory2.get(accToAssign.Siebel_Territory_ID__c);

                    //Populate fields of Territory2 to Account
                    accToAssign.Salesforce_Territory_Id__c=territoryObj.id;
                    accToAssign.Territory_Name__c=territoryObj.name;
                    accToAssign.Global_Region__c=territoryObj.Global_Region__c;
                    accToAssign.Region__c=territoryObj.Region__c;
                    accToAssign.Office_Group__c=territoryObj.Office_Group__c;
                    accToAssign.Office__c=territoryObj.Office__c;
                    accToAssign.Office_Channel__c=territoryObj.Office_Channel__c;
                    accToAssign.Territory_Industry__c=territoryObj.Territory_Industry__c;
                    accToAssign.Territory_Sales_Group__c=territoryObj.Territory_Sales_Group__c;
                    accToAssign.Territory_Sales_Team_Type__c=territoryObj.Territory_Sales_Team_Type__c;
                    accToAssign.Account_Territory_Sector__c=territoryObj.Territory_Sector__c;
                    accToAssign.Account_Territory_Type__c= territoryObj.Territory2Type.MasterLabel;
                    accToAssign.Master_Territory_ID__c= territoryObj.Master_Territory_ID__c;
                    
                    if(accToAssign.TA_Attempts__c == null){
                        accToAssign.TA_Attempts__c = 0;        
                    }
                    accountRetryAttemptsMap.put(accToAssign.Id, accToAssign.TA_attempts__c.IntValue());
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts before reset:'+accToAssign.TA_attempts__c);
                    accToAssign.TA_Attempts__c = 0;
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts after reset:'+accToAssign.TA_attempts__c);

                    //Create record into ObjectTerritory2Association
                    ObjectTerritory2Association objAssoToInsert=new ObjectTerritory2Association();
                    objAssoToInsert.ObjectId=accToAssign.id;
                    objAssoToInsert.Territory2Id=territoryObj.id;
                    objAssoToInsert.AssociationCause='Territory2Manual';

                    territory2AssoListToInsert.add(objAssoToInsert);

                }//if
                else{ 

                    //If Salesforce Territory Id is not found in Territory2 then blank out account fields
                    clearTerritoryAttributesOnAccount(accToAssign);
                    if(accToAssign.TA_Attempts__c == null){
                        accToAssign.TA_Attempts__c = 0;        
                    }
                    accountRetryAttemptsMap.put(accToAssign.Id, accToAssign.TA_attempts__c.IntValue());
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts before reset:'+accToAssign.TA_attempts__c);
                    accToAssign.TA_Attempts__c = 0;
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts after reset:'+accToAssign.TA_attempts__c);

                    //Log error message
                    Logger.debug('Territory2 not found');

                }//else

            }

            else{

                //If siebel Territory Id is blank on account then blank out other  account fields
                clearTerritoryAttributesOnAccount(accToAssign);
                if(accToAssign.TA_Attempts__c == null){
                        accToAssign.TA_Attempts__c = 0;        
                }
                accountRetryAttemptsMap.put(accToAssign.Id, accToAssign.TA_attempts__c.IntValue());
                Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts before reset:'+accToAssign.TA_attempts__c);
                accToAssign.TA_Attempts__c = 0;
                Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts after reset:'+accToAssign.TA_attempts__c);

            }
            
            accListToUpdate.add(accToAssign);

        }//for

        //Query ObjectTerritory2Association if there is  already a territory assigned to the account
        territory2AssoList=[select id,ObjectId from ObjectTerritory2Association where isDeleted=false and ObjectId in:accObjList];

        Savepoint sp = Database.setSavepoint();

        try
        {
            Logger.Debug('Affected Accounts:'+accObjList);
            
            //perform the dml operataions
            executeDMLOperations(accListToUpdate,territory2AssoListToInsert,territory2AssoList);            
            

        }
        catch(Exception e){
        
            
            Database.rollback(sp);
            for (Integer i = 0; i < e.getNumDml(); i++) {
                    //capture Dml  Process exception 
                   Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
             }
            
            //immediately retry the territory Assignment
            // create a save point so that we can rollback in case of exception/error
            Savepoint sp2 = Database.setSavepoint();
            
            try{
                
                Logger.Debug('Affected Accounts retry:'+accObjList);
                
                //perform the dml operataions
              executeDMLOperations(accListToUpdate,territory2AssoListToInsert,territory2AssoList);

                
            }catch(Exception ex){
                //rollbakc all the changes 
                Database.rollback(sp2);
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                        //capture Dml  Process exception 
                       Logger.debugException(' DmlException in immediate retry:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                 }
                
                //even after the immediate retry, it still caused exception, delete the OTA records            
                if(!territory2AssoList.isEmpty() && territory2AssoList!= NULL)
                {                     
                    delete territory2AssoList;
    
                }
            
                //clear out the current territory attributes on the account(s)
                List<Account> accListToclear = new List<Account>();
                for(Account accToUpdate: accListToUpdate){
                    clearTerritoryAttributesOnAccount(accToUpdate);
                    //get the original attempts from the map
                    if(accountRetryAttemptsMap.containsKey(accToUpdate.Id)){
                        accToUpdate.TA_Attempts__c = accountRetryAttemptsMap.get(accToUpdate.Id);
                    }
                    //increment the retry attempt value by 1
                    Logger.Debug('Account Id:'+accToUpdate.Id+' retry attempts before increment:'+accToUpdate.TA_attempts__c);
                    accToUpdate.TA_Attempts__c += 1;
                    Logger.Debug('Account Id:'+accToUpdate.Id+' retry attempts after increment:'+accToUpdate.TA_attempts__c);
                    
                    accListToClear.add(accToUpdate);
                }
            
                //Update fields of Account record
                if(!accListToClear.isEmpty()){
                    update accListToClear;
                }
            }
            
             

        }//catch

        Logger.pop(); 

    }
    
    //HW, 1617306
    /** 
     *@Author Original: Haigang Wu - Mathworks 
     *@Last Modified: Haigang Wu - Mathworks  
     *@Date Original: 12 aug 2016
     *@Last Modified: 12 aug 2016
     *@Description: This is a clone of assignAccountsToTerritory that supports Master_Territory_ID__c.
     */ 

    public static void assignAccountsToTerritoryMaster (List<Account> accList){ 

        Logger.push('assignAccountsToTerritoryMaster','TerritoryAssignmentManager');

        //List of Territory2 with Territory model state is active
        List<Territory2> territoryList=new List<Territory2>();

        //List of accounts to populate fields
        List<Account> accListToUpdate=new List<Account>();

        //List of ObjectTerritory2Association which has already a territory assigned to the account
        List<ObjectTerritory2Association> territory2AssoList=new List<ObjectTerritory2Association>(); 

        //List of ObjectTerritory2Association to Insert
        List<ObjectTerritory2Association> territory2AssoListToInsert=new List<ObjectTerritory2Association>();
        
        //map to hold the retry attempts so that it can be used at a later time 
        //to set the correct retry attempts in our retry logic
        Map<Id, Integer> accountRetryAttemptsMap = new Map<Id, Integer>();
        
        //set of unique Territory IDs from the Accounts passed in
        Set<String> territoryIdSet=new Set<String>();

        //accList may have these fields already but requerying to make this method independent from its caller
        List<Account> accObjList=[select id,Master_Territory_ID__c,Salesforce_Territory_Id__c, Territory_Name__c,
                                   Global_Region__c, Region__c, Office_Group__c, Office__c, Office_Channel__c, 
                                   Territory_Industry__c, Territory_Sales_Group__c, Territory_Sales_Team_Type__c, 
                                   TA_Attempts__c,Is_Individual_Account__c,Account_Territory_Sector__c,
                                   Account_Territory_Type__c
                                   from Account where id in :accList];

        for(Account accObj: accObjList){

            if(accObj.Master_Territory_ID__c!=null && !accObj.Is_Individual_Account__c && accObj.Master_Territory_ID__c!=''){

                territoryIdSet.add(accObj.Master_Territory_ID__c);

            }//if

        }//for

        //Map of Territory2 objects, indexed by Master_Territory_ID__c
        map<String,Territory2> masterTerritoryIdToTerritory2 = new map<String,Territory2>();
        
        //Form a map of siebelTerritoryId to Territory2  
        for(Territory2 territoryObj:[select id
                                     ,Master_Territory_ID__c
                                     ,Siebel_Territory_ID__c
                                     ,Global_Region__c
                                     ,Region__c
                                     ,Office_Group__c
                                     ,Office__c
                                     ,Office_Channel__c
                                     ,Territory_Industry__c
                                     ,Territory_Sales_Group__c
                                     ,Territory_Sales_Team_Type__c
                                     ,Name 
                                     ,Territory_Sector__c
                                     ,Territory2Type.MasterLabel
                                     from territory2 where 
                                     Master_Territory_ID__c in:territoryIdSet and Territory2Model.state='Active']){
                                         
                                         masterTerritoryIdToTerritory2.put(territoryObj.Master_Territory_ID__c,territoryObj);
                                         
                                     }
        

        //Populate account fields using associated Territory2 object fields
        for(Account accToAssign:accObjList){

            //check if Master_Territory_ID__c is empty
            if(accToAssign.Master_Territory_ID__c!=null && !accToAssign.Is_Individual_Account__c){

                Territory2 territoryObj = new Territory2();

                if(masterTerritoryIdToTerritory2.containsKey(accToAssign.Master_Territory_ID__c) && 
                        masterTerritoryIdToTerritory2.get(accToAssign.Master_Territory_ID__c)!=null){

                    territoryObj=masterTerritoryIdToTerritory2.get(accToAssign.Master_Territory_ID__c);

                    //Populate fields of Territory2 to Account
                    accToAssign.Salesforce_Territory_Id__c=territoryObj.id;
                    accToAssign.Territory_Name__c=territoryObj.name;
                    accToAssign.Global_Region__c=territoryObj.Global_Region__c;
                    accToAssign.Region__c=territoryObj.Region__c;
                    accToAssign.Office_Group__c=territoryObj.Office_Group__c;
                    accToAssign.Office__c=territoryObj.Office__c;
                    accToAssign.Office_Channel__c=territoryObj.Office_Channel__c;
                    accToAssign.Territory_Industry__c=territoryObj.Territory_Industry__c;
                    accToAssign.Territory_Sales_Group__c=territoryObj.Territory_Sales_Group__c;
                    accToAssign.Territory_Sales_Team_Type__c=territoryObj.Territory_Sales_Team_Type__c;
                    accToAssign.Account_Territory_Sector__c=territoryObj.Territory_Sector__c;
                    accToAssign.Account_Territory_Type__c= territoryObj.Territory2Type.MasterLabel;
                    accToAssign.Siebel_Territory_ID__c= territoryObj.Siebel_Territory_ID__c;
                    
                    if(accToAssign.TA_Attempts__c == null){
                        accToAssign.TA_Attempts__c = 0;        
                    }
                    accountRetryAttemptsMap.put(accToAssign.Id, accToAssign.TA_attempts__c.IntValue());
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts before reset:'+accToAssign.TA_attempts__c);
                    accToAssign.TA_Attempts__c = 0;
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts after reset:'+accToAssign.TA_attempts__c);

                    //Create record into ObjectTerritory2Association
                    ObjectTerritory2Association objAssoToInsert=new ObjectTerritory2Association();
                    objAssoToInsert.ObjectId=accToAssign.id;
                    objAssoToInsert.Territory2Id=territoryObj.id;
                    objAssoToInsert.AssociationCause='Territory2Manual';

                    territory2AssoListToInsert.add(objAssoToInsert);

                }//if
                else{ 

                    //If Salesforce Territory Id is not found in Territory2 then blank out account fields
                    clearTerritoryAttributesOnAccountMaster(accToAssign);
                    if(accToAssign.TA_Attempts__c == null){
                        accToAssign.TA_Attempts__c = 0;        
                    }
                    accountRetryAttemptsMap.put(accToAssign.Id, accToAssign.TA_attempts__c.IntValue());
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts before reset:'+accToAssign.TA_attempts__c);
                    accToAssign.TA_Attempts__c = 0;
                    Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts after reset:'+accToAssign.TA_attempts__c);

                    //Log error message
                    Logger.debug('Territory2 not found');

                }//else

            }

            else{

                //If siebel Territory Id is blank on account then blank out other  account fields
                clearTerritoryAttributesOnAccountMaster(accToAssign);
                if(accToAssign.TA_Attempts__c == null){
                        accToAssign.TA_Attempts__c = 0;        
                }
                accountRetryAttemptsMap.put(accToAssign.Id, accToAssign.TA_attempts__c.IntValue());
                Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts before reset:'+accToAssign.TA_attempts__c);
                accToAssign.TA_Attempts__c = 0;
                Logger.Debug('Account Id:'+accToAssign.Id+' retry attempts after reset:'+accToAssign.TA_attempts__c);

            }
            
            accListToUpdate.add(accToAssign);

        }//for

        //Query ObjectTerritory2Association if there is  already a territory assigned to the account
        territory2AssoList=[select id,ObjectId from ObjectTerritory2Association where isDeleted=false and ObjectId in:accObjList];

        Savepoint sp = Database.setSavepoint();

        try
        {
            Logger.Debug('Affected Accounts:'+accObjList);
            
            //perform the dml operataions
            executeDMLOperations(accListToUpdate,territory2AssoListToInsert,territory2AssoList);            
            

        }
        catch(Exception e){
        
            
            Database.rollback(sp);
            for (Integer i = 0; i < e.getNumDml(); i++) {
                    //capture Dml  Process exception 
                   Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
             }
            
            //immediately retry the territory Assignment
            // create a save point so that we can rollback in case of exception/error
            Savepoint sp2 = Database.setSavepoint();
            
            try{
                
                Logger.Debug('Affected Accounts retry:'+accObjList);
                
                //perform the dml operataions
              executeDMLOperations(accListToUpdate,territory2AssoListToInsert,territory2AssoList);

                
            }catch(Exception ex){
                //rollbakc all the changes 
                Database.rollback(sp2);
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                        //capture Dml  Process exception 
                       Logger.debugException(' DmlException in immediate retry:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                 }
                
                //even after the immediate retry, it still caused exception, delete the OTA records            
                if(!territory2AssoList.isEmpty() && territory2AssoList!= NULL)
                {                     
                    delete territory2AssoList;
    
                }
            
                //clear out the current territory attributes on the account(s)
                List<Account> accListToclear = new List<Account>();
                for(Account accToUpdate: accListToUpdate){
                    clearTerritoryAttributesOnAccountMaster(accToUpdate);
                    //get the original attempts from the map
                    if(accountRetryAttemptsMap.containsKey(accToUpdate.Id)){
                        accToUpdate.TA_Attempts__c = accountRetryAttemptsMap.get(accToUpdate.Id);
                    }
                    //increment the retry attempt value by 1
                    Logger.Debug('Account Id:'+accToUpdate.Id+' retry attempts before increment:'+accToUpdate.TA_attempts__c);
                    accToUpdate.TA_Attempts__c += 1;
                    Logger.Debug('Account Id:'+accToUpdate.Id+' retry attempts after increment:'+accToUpdate.TA_attempts__c);
                    
                    accListToClear.add(accToUpdate);
                }
            
                //Update fields of Account record
                if(!accListToClear.isEmpty()){
                    update accListToClear;
                }
            }
            
             

        }//catch

        Logger.pop(); 

    }
    //1617306
    
	//Remove this method when retiring Siebel    
    //helper method to set territory 
    private static void clearTerritoryAttributesOnAccount(Account acc){
        acc.Salesforce_Territory_Id__c='';
        acc.Territory_Name__c='';
        acc.Global_Region__c='';
        acc.Region__c='';
        acc.Office_Group__c='';
        acc.Office__c='';
        acc.Office_Channel__c='';
        acc.Territory_Industry__c='';
        acc.Territory_Sales_Group__c='';
        acc.Territory_Sales_Team_Type__c='';
        acc.Master_Territory_ID__c=''; //HW, 1617306
        acc.Account_Territory_Sector__c=''; //HW, 1617306
        acc.Account_Territory_Type__c=''; //HW, 1617306
    }
    
    //HW, 1617306
    //helper method to set territory 
    private static void clearTerritoryAttributesOnAccountMaster(Account acc){
        acc.Salesforce_Territory_Id__c='';
        acc.Territory_Name__c='';
        acc.Global_Region__c='';
        acc.Region__c='';
        acc.Office_Group__c='';
        acc.Office__c='';
        acc.Office_Channel__c='';
        acc.Territory_Industry__c='';
        acc.Territory_Sales_Group__c='';
        acc.Territory_Sales_Team_Type__c='';
        acc.Siebel_Territory_ID__c=''; //Remove this line when retiring Siebel
        acc.Account_Territory_Sector__c=''; //HW, 1617306
        acc.Account_Territory_Type__c=''; //HW, 1617306
    }
    
    private static void executeDMLOperations(List<Account> accListToUpdate, List<ObjectTerritory2Association> insertOTA, List<ObjectTerritory2Association> deleteOTA){
        
                      
            //Delete already present record of ObjectTerritory2Association of same objectid
            if(!deleteOTA.isEmpty() && deleteOTA!= NULL)
            {
                Logger.Debug('Before deleting the record from OTA:'+deleteOTA);                
                delete deleteOTA;
                Logger.Debug('After deleting the record from OTA');

            }
            
            
            //Update fields of Account record
            if(!accListToUpdate.isEmpty())
            {
                Logger.Debug('Before updating accounts');
                Update accListToUpdate;
                Logger.Debug('After updating accounts');

            }

            //Insert record into ObjectTerritory2Association
            if(!insertOTA.isEmpty())
            {
                Logger.Debug('Before inserting the record to OTA');
                insert insertOTA;
                Logger.Debug('After inserting the record to OTA');

            }

    }
    
}