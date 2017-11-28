/**
 * @author          Pranav Raulkar
 * @date            29/03/2016
 * @description     Trigger for Enrollment_Code__c object
 *                  With bypass mechanism hooked in, the trigger handles following events -
 *                  1.  Before Insert
 * @revision        1.0 - Initial version
 */
trigger EnrollmentCodeTrigger on Enrollment_Code__c (before insert) {
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();

    if (bypass.Trigger_Objects__c.contains('EnrollmentCode') && !bypass.Triggers_Disabled__c){
        EnrollmentCodeTriggerHandler handler = new EnrollmentCodeTriggerHandler();
        handler.onBeforeInsert(Trigger.new);
    }
}