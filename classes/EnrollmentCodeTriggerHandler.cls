/**
 * @author      Pranav Raulkar
 * @date        29/03/2016
 * @description   Trigger handler for EnrollmentCodeTrigger
 *           The trigger handler handles following events -
 *          1.  Before Insert
 * @revision    1.0 - Initial version
 */
public with sharing class EnrollmentCodeTriggerHandler {
  public void onBeforeInsert(List<Enrollment_Code__c> enrollmentCodeList) {
    if(Trigger.isExecuting) {
      if(enrollmentCodeList != null && enrollmentCodeList.size() > 0) {
        for(Enrollment_Code__c eCode : enrollmentCodeList) {
          eCode.Code__c = TrainingUtil.generateEnrollmentCode();
        }
      }
    }
  }
}