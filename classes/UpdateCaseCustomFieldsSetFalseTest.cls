@isTest
/*
 * @Author: Donna Latte
 * Modification History: Abhay Verma
 * Modification Date - 3 March 2016
 * @date   4/15/2014 Created
 * revision  : Update the testUpdateCaseCustomFieldsSetFalse Method.
*/

public class UpdateCaseCustomFieldsSetFalseTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    static testMethod void testUpdateCaseCustomFieldsSetFalse(){
         //Disable OnSupport trigger for Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test Case records - staticresource is used for enabling modifying of LastModifiedDate field 
        list <Case> caselist = new list <Case>();
        for(Integer i=0;i<=199;i++){        
            Case caseObj = TestDataBuilder.buildTestCase('Open');
            caseObj.Has_Linked_Article__c = True;
            caselist.add(caseObj);
        }
        insert caselist;
                
        UpdateCaseCustomFieldsSetFalse updCase = new UpdateCaseCustomFieldsSetFalse();
              
        Test.startTest();
            //Run batchable class  
            database.executebatch(updCase);
        Test.stopTest();
       
       List<Case> caseLst = [SELECT Id, Has_Linked_Article__c FROM Case  WHERE Id IN: caselist];
       
       for(Case caseObj : caseLst){
           System.assertEquals(False, caseObj.Has_Linked_Article__c); 
       }
    }

    
    /** 
        * @Author: Donna Latte
        * Modification History:
        * @date   4/15/2014 Created
    * @description Test Method for testing running of Scheduled job for UpdateCaseCustomFields
    */ 
    public static testMethod void testScheduleOfUpdateCaseCustomFieldsSetFalse() {
        
        CronTrigger cronTrigger;
        String jobId;
        String scheduleExpression = '0 47 11 * * ?';
        //String scheduleExpression = '0 42 10 * * ?';
        
        // Schedule the test job
        Test.startTest();
            jobId = System.schedule('Test Update Cases False', scheduleExpression, new UpdateCaseCustomFalseSchedulable());
        Test.stopTest();
        
        // Get the CronTrigger info
        cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        //Verify that the expressions are the same; Scheduled Job has been added on cronTrigger
        System.assertEquals(scheduleExpression, cronTrigger.CronExpression);
        
    }
}