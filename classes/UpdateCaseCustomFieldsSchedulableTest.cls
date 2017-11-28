@isTest
/*
 * @Author: Donna Latte
 * Modification History:
 * @date   3/28/2014 Created
*/

public class UpdateCaseCustomFieldsSchedulableTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    static testMethod void testUpdateCaseCustomFields(){
        system.debug('@InTest');
         //Disable OnSupport trigger for Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test Case records - staticresource is used for enabling modifying of LastModifiedDate field 
        list <Case> caselist = new list <Case>();
        caselist.add(TestDataBuilder.buildTestCase('Open'));
        caselist.add(TestDataBuilder.buildTestCase('Open'));
        insert caselist;
                
        UpdateCaseCustomFields updCase = new UpdateCaseCustomFields();
   
        Test.startTest();
        	//Run batchable class  
        	database.executebatch(updCase);
        Test.stopTest();
        
    }

    
    /** 
 		* @Author: Donna Latte
		* Modification History:
 		* @date   3/28/2014 Created
    * @description Test Method for testing running of Scheduled job for UpdateCaseCustomFields
    */ 
    public static testMethod void testScheduleOfUpdateCaseCustomFields() {
    	
		CronTrigger cronTrigger;
		String jobId;
        String scheduleExpression = '0 47 11 * * ?';
		//String scheduleExpression = '0 42 10 * * ?';
		
		// Schedule the test job
		Test.startTest();
			jobId = System.schedule('Test Update Cases', scheduleExpression, new UpdateCaseCustomFieldsSchedulable());
		Test.stopTest();
        

		
		// Get the CronTrigger info
		cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
		
		//Verify that the expressions are the same; Scheduled Job has been added on cronTrigger
		System.assertEquals(scheduleExpression, cronTrigger.CronExpression);
		
    }   
}