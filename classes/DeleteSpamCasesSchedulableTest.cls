@isTest
/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks   
* @date Original: 30 May 2013, Last Modified: 22 June 2013
* @description test class for testing functionality of DeleteSpamCase
*/ 
private class DeleteSpamCasesSchedulableTest{
	
     //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

	/**
	* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
	* @date Original: 30 May 2013, Last Modified: 22 October 2013
	* @description test method for testing taking of ownership on Tasks
	*/ 
    static testMethod void testDeletinOfCancelledCaseRecords(){
    	
        //Disable OnSupport trigger for Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        //create test Case records - staticresource is used for enabling modifying of LastModifiedDate field 
        list <Case> caselist = new list <Case>();
        caselist.add(TestDataBuilder.buildTestCase('Cancelled'));
        caselist.add(TestDataBuilder.buildTestCase('Cancelled'));
        insert caselist;
               
        DeleteSpamCases dsc = new DeleteSpamCases();
              
        Test.StartTest();
        	//Run batchable class  
        	database.executebatch(dsc);
        Test.StopTest();
        
    }
    
    /** 
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 06 June 2013, Last Modified: 22 October 2013
    * @description Test Method for testing running of Scheduled job for DeleteSpamCases
    */ 
    public static testMethod void testScheduleOfDeleteSpamCases() {
    	
		CronTrigger cronTrigger;
		String jobId;
		String scheduleExpression = '0 42 10 * * ?';
		
		// Schedule the test job
		Test.startTest();
			jobId = System.schedule('Test Delete Cancelled Cases', scheduleExpression, new DeleteSpamCasesSchedulable());
		Test.stopTest();
		
		// Get the CronTrigger info
		cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
		
		//Verify that the expressions are the same; Scheduled Job has been added on cronTrigger
		System.assertEquals(scheduleExpression, cronTrigger.CronExpression);
		
    }
}