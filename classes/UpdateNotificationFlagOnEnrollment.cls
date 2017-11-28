/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:   8 Sep 2015, Last Modified:26 Oct 2015
 *@description:     Batch Class to Update the Notification Flag (Send Awaiting Payment Notification, Send Registered - AP Notification and Send Registered Notification) on the Enrollment Object.
 */

global class UpdateNotificationFlagOnEnrollment implements Schedulable, Database.Batchable<sObject>{
    

    global final String enrollmentQuery;
    global  List<Enrollment__c> updateEnrolLst;
        
/*
  * @author Original: Abhay Verma - Cloud Sherpas/Mathworks 
  * @date   Original: 9 Sep 2015
  * @description: Global Constructor for UpdateNotificationFlagOnEnrollment Class.
  * @param BC: BatchableContext object used to track the progress of the batch job
  */
  
  global UpdateNotificationFlagOnEnrollment(){
      
        String clsRecTypeId;
        clsRecTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Self-Paced').getRecordTypeId();
        enrollmentQuery = 'SELECT Id,Send_Registered_Notification__c,Certification_Exam_Agreement__c, Name, class__r.Start_Date__c, class__r.RecordTypeId, Class_Status__c, Start_Date__c, Send_Email__c,Enrollment_Status__c, Send_Awaiting_Payment_Notification__c, Send_Registered_AP_Notification__c FROM Enrollment__c WHERE Class_Status__c = \'Active\' AND  class__r.RecordTypeId != '+'\'' +clsRecTypeId+ '\' AND Start_Date__c > TODAY AND Send_Email__c = True AND (Enrollment_Status__c = \'Registered - Awaiting Payment\' OR Enrollment_Status__c = \'Awaiting Payment\' OR (Enrollment_Status__c = \'Registered\' AND Certification_Exam_Agreement__c = \'Awaiting Response\'))'; 
 } 
        
/*
  * @author Original: Abhay Verma - Cloud Sherpas/Mathworks 
  * @date   Original: 8 Sep 2015
  * @description: Collects the records or objects to be passed to the interface method execute
  * @param BC: BatchableContext object used to track the progress of the batch job
  */
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(enrollmentQuery);
    }
    
     /*
  * @author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
  * @date   Original: 8 Sep 2015, Last Modified: 
  * @description: method to do update the record as according to the Status.
  * @param BC: BatchableContext object used to track the progress of the batch job
  * @param enrolLst: returned list from the QueryLocator
  */
    
    global void execute(Database.BatchableContext BC, List<Enrollment__c> enrolLst){
        //List to store the enrollment records which need to update.
        updateEnrolLst = new List<Enrollment__c>();
        
        //Check the Enrollment Status and raise the flag to True for the associated Status.
        //Check if the list is empty or not.
        if(!(enrolLst.isEmpty())){        
            for(Enrollment__c enrolObj : enrolLst){
            
                //check if the Start date of the class should be greater then 7 day from the date of sending the Alert.
                if(enrolObj.class__r.Start_Date__c >= Date.Today() + 7){                
                    if(enrolObj.Enrollment_Status__c == 'Registered - Awaiting Payment'){
                        enrolObj.Send_Registered_AP_Notification__c = True;
                    }
                    else if(enrolObj.Enrollment_Status__c == 'Awaiting Payment'){
                        enrolObj.Send_Awaiting_Payment_Notification__c = True;
                    }
                    else if(enrolObj.Enrollment_Status__c == 'Registered' && enrolObj.Certification_Exam_Agreement__c== 'Awaiting Response'){
                        enrolObj.Send_Registered_Notification__c= True;
                    }
                    
                    updateEnrolLst.add(enrolObj);
                }
            }
            
        }
      
        try{
            if(!updateEnrolLst.isempty()){
                //update the Enrollment records.
                update updateEnrolLst;
            }
        }
        catch(Exception ex){
             for (Integer i = 0; i < ex.getNumDml(); i++) {
                 //Process exception here
                Logger.debugException('Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
             }
        }
    }
    
    /*
  * @author Original: Abhay Verma - Cloud Sherpas/Mathworks 
  * @date   Original: 8 Sep 2015
  * @description: method called after the execution of the batch
  * @param BC: BatchableContext object used to track the progress of the batch job
  */
    
    global void finish(Database.BatchableContext BC) {
        
        AsyncApexJob apexJobObj = [select id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where id =: bc.getJobId()];
        
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
        mail.setToAddresses(new String[]{apexJobObj.CreatedBy.Email});
        mail.setSubject('Batch Class Result');
        mail.setHtmlBody('The batch Apex job processed ' + '<b>' + apexJobObj.TotalJobItems + '</b>' +' batches with '+ '<b>' + apexJobObj.NumberOfErrors + '</b>' + ' failures.');
        //sendEmail methods
        Messaging.sendEmail(new Messaging.singleEmailMessage[]{mail});
    }
    
    /*
  * @author Original: Abhay Verma - Cloud Sherpas/Mathworks 
  * @date   Original: 10 Sep 2015
  * @description: Schedulable method to execute Schedular.
  * @param SC: 
  */
    
    global void execute(SchedulableContext SC) {
         
        UpdateNotificationFlagOnEnrollment batchObj = new UpdateNotificationFlagOnEnrollment();
        Id batchId = Database.executeBatch(batchObj, 2000);
    }
}