/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar - Cloud Sherpas/Mathworks
 *date Original: 26 September 2014, Last Modified: 26 September 2014
 *description: This  is handler class for 'TimecardMasterTrigger' . 
 */
public with sharing class TimecardTriggerHandler {
	/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar - Cloud Sherpas/Mathworks
 *date Original: 26 September 2014, Last Modified: 26 September 2014
 *description: check if project related to timecard is closed show error else delete Timecard 
 */
	public void onBeforeDelete(List<Project_Time_Card__c> List_projTimecard){
		
		Logger.push('onBeforeDelete','TimecardTriggerHandler ');
		//create a list that contains timecard id.
		List<Id> timecardId = new list<Id>();
		String deleteEroror = Label.TimecardDeleteErrorMessage;
		//fetch general setting instance
		Project_Validation_Rule_Settings__c settings  =Project_Validation_Rule_Settings__c.getInstance();
		
		// Iterate over the  List_projTimecard
		for(Project_Time_Card__c timecardObj :List_projTimecard){
          // checks if Project_Status__c=='closed' do not allow to delete the timecard and show error message. 
            if(timecardObj.Project_Status__c=='closed' &&  settings.Prevent_Deleting_Closed_Projects__c == true ){
            	//Show error message 
            	timecardObj.adderror(deleteEroror);
            }
           
        }
        
       Logger.pop(); 
	}
	
}