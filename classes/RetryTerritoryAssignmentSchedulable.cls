/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks, Faina Gorelik
 *date Original: 19 Jan 2015, Last Modified:19 Jan 2015, 20 November 2015 AtTask 1772050 , 12 January 2016 AtTask 1877463 
 *description : Batch class for Retry Territory Assignment*/
global class RetryTerritoryAssignmentSchedulable implements Schedulable, Database.Batchable<sObject>{

    //String will hold the query
    global final String Query;
    global static Territory_Settings__c territorySettings = Territory_Settings__c.getInstance();

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *date Original: 19 Jan 2015, Last Modified:19 Jan 2015 
     *description : Constructor which initialises the Query*/   
    global RetryTerritoryAssignmentSchedulable(){
        Query = 'SELECT ID FROM ACCOUNT'+
        ' WHERE Territory__c = \''+ territorySettings.Assignment_Status__c + '\' AND'+
        ' TA_Attempts__c >= 1 AND TA_Attempts__c <='+territorySettings.Max_TA_Attempts__c +
        '  ORDER BY siebel_territory_Id__c';    
    }//RetryTerritoryAssignmentSchedulable

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *date Original: 19 Jan 2015, Last Modified:19 Jan 2015 
     *description : Start method
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }//start

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *date Original: 19 Jan 2015, Last Modified:19 Jan 2015 
     *description : BatchableContext Execute method
     */
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        List<Account> acctIds = new List<Account>();

        for(sobject s : scope){
            Account acct = (Account)s;
            acctIds.add(acct);
        }//for

        if (territorySettings.Territory_Assignment_Lookup_Field__c =='Master'){
            TerritoryAssignmentManager.assignAccountsToTerritoryMaster(acctIds); //fg AtTask 1877463 
        }
        else // will be removed after TM golive
        {
            TerritoryAssignmentManager.assignAccountsToTerritory(acctIds);
        }
     //  TerritoryAssignmentManager.assignAccountsToTerritory(acctIds); //fg AtTask 1772050 
       // TerritoryAssignmentManager.assignAccountsToTerritoryMaster(acctIds);// fg 1859101 
       
        
        AccountDML accDml=new AccountDML();
        accDml.assignOpportunitiesByRole(acctIds);

    }//execute

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *date Original: 19 Jan 2015, Last Modified:19 Jan 2015 
     *description : SchedulableContext Execute method with the batch size as defined in the Territory Settings custom settings
     */
    global void execute(SchedulableContext ctx){
        //get the batch size from the custom settings and use it to execute the job
        Integer batchSize = territorySettings.TA_Retry_Batch_Size__c.intValue();       
        ID batchprocessid = Database.executeBatch(this,batchSize);
    }//execute   

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *date Original: 19 Jan 2015, Last Modified:19 Jan 2015 
     *description : Finish method*/
    global void finish(Database.BatchableContext BC){
    }//finish

}//RetryTerritoryAssignmentSchedulable class