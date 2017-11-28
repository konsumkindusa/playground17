/*
*@author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathwoks
*@date Original: 22 May 2013, Last Modified: 23 July 2013
*@description: Batch job for deleting Spam/Cancelled Case Records
*/ 
global class DeleteSpamCases implements Database.Batchable<sObject>{
	
    global final String query;

    /*
	* @author Original: Robbie Macatbag - Cloud Sherpas/Mathwors, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks 
	* @date   Original: 22 May 2013, Last Modified: 23 July 2013
	* @description: Batchable Class Constructor
	*/
    global DeleteSpamCases(){
    	
        DateTime  comparatorDateTime = Datetime.now().addDays(-10); //get current datetime and subtract 10 days 
        String dateTimeString = string.valueOfGmt(comparatorDateTime); //convert datetime to string
        List<String> dateStringList =  new List<string>();
        dateStringList = dateTimeString.split(' ',2); //split dateTimeString and put to dateStringList List.
        String comparatorDateTimeString = String.join(dateStringList,'T'); //join the List dateStringList by 'T' and put it to variable comparatorDateTimeString
        comparatorDateTimeString = comparatorDateTimeString +'Z'; //add 'Z' to String comparatorDateTimeString.

        query = 'Select Id from Case where status = \'Cancelled\' and LastModifiedDate <= '+comparatorDateTimeString ;
    }
    
    /*
	* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks 
	* @date   Original: 22 May 2013
	* @description: Collects the records or objects to be passed to the interface method execute
	* @param BC: BatchableContext object used to track the progress of the batch job
	*/
    global Database.QueryLocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }
    
    /*
	* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks 
	* @date   Original: 22 May 2013, Last Modified: 03 June 2013
	* @description: method to do all required processing for each chunk of data
	* @param BC: BatchableContext object used to track the progress of the batch job
	* @param spamCase: returned list from the QueryLocator
	*/
    global void execute (Database.BatchableContext BC, List<Case> spamCase){
       //Delete Case records 
       delete spamCase;
    }
    
    /*
	* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks 
	* @date   Original: 22 May 2013
	* @description: method called after the execution of the batch
	* @param BC: BatchableContext object used to track the progress of the batch job
	*/
    global void finish (Database.BatchableContext BC){
        
    }
}