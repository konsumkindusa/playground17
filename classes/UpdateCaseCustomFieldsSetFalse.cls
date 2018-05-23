/*
 * @Author:  Donna Latte
 * Modification History:
 * Date:  4/11/2014 Created
 * @description:  Schedule once a day to force a Case Update on any Cases with Articles.
 *                Opposite condition fixed when a CaseArticle is removed, but the Case still indicates it has an Article.
 *                The CaseTriggerHandle update calls CaseDML CaseArticleCheck which is designed to update
 *                Custom Case Fields:  Known vs New, Has Linked Article, and Citation.
 * 
 */


global class UpdateCaseCustomFieldsSetFalse implements Database.Batchable<sObject>{

        global final String query;


 /*
	* @Author: Donna Latte
	* Modification History:
	* @date   4/11/2014 Created
	* @description: Batchable Class Constructor
*/


global UpdateCaseCustomFieldsSetFalse(){
    system.debug('@inUpdateCaseCustomFields');
    
    //Disable OnSupport trigger for Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        query = 'Select Id from Case where Has_Linked_Article__c = true and Id not in (Select CaseId from CaseArticle)';
        system.debug('@query ' + query);
}

    
    /*
	* @Author: Donna Latte
	* Modification History:
	* @date   4/11/2014 Created
	* @description: Collects the records or objects to be passed to the interface method execute
	* @param BC: BatchableContext object used to track the progress of the batch job
	*/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    
    /*
	* @Author: Donna Latte
	* Modification History:
	* @date   4/11/2014 Created
	* @description: method to do all required processing for each chunk of data
	* @param BC: BatchableContext object used to track the progress of the batch job
	* @param spamCase: returned list from the QueryLocator
	*/
    
    global void execute (Database.BatchableContext BC, List<Case> caseHasLinkedTrue){
        
        for (Case c : caseHasLinkedTrue) {
           c.Has_Linked_Article__c = false;
        }

        update caseHasLinkedTrue;
    }
        
    /*
	* @Author: Donna Latte
	* Modification History:
	* @date   3/28/2014 Created
	* @description: method called after the execution of the batch
	* @param BC: BatchableContext object used to track the progress of the batch job
	*/
    
    global void finish (Database.BatchableContext BC){
     /* Get the ID of the AsyncApexJob representing this batch job
   		 from Database.BatchableContext.
   		 Query the AsyncApexJob object to retrieve the current job's information.
     */
   		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
   		// Send an email to the Apex job's submitter notifying of job completion.
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   		String[] toAddresses = new String[] {a.CreatedBy.Email};
   		mail.setToAddresses(toAddresses);
   		mail.setSubject('Update False Custom Case Schedulable ' + a.Status);
   		mail.setPlainTextBody('The Custom Case Job set Has Linked to False ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     
    }
}