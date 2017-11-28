/**
  * @author Original: Sagar Talele - Accenture/Mathworks Last Modified: Sagar talele
  * @date Original: 20 May 2016, Last Modified: 20 May 2016
  * @description: This batch will send a mail to enrollee which includes all the details 
  *               of courses that enrollee enrolled.This batch will also update status of
  *               Enrollment request 
  **/
global class EmailToEnrolleesBatch implements Queueable {
    Set<Id> enrollReqIdSet = new Set<Id>();
    /**
      * @author Original: Sagar Talele - Accenture/Mathworks Last Modified: Sagar talele
      * @date Original: 20 May 2016, Last Modified: 20 May 2016
      * @description: This is execute method to build a logic for sending mails
      **/
    public EmailToEnrolleesBatch(Set<Id> enrollReqIds){
        Logger.push('EmailToEnrolleesBatch', 'EmailToEnrolleesBatch');
        enrollReqIdSet = enrollReqIds;
        Logger.pop();
    }
    /**
      * @author Original: Sagar Talele - Accenture/Mathworks Last Modified: Sagar talele
      * @date Original: 20 May 2016, Last Modified: 20 May 2016
      * @description: This is execute method to build a logic for sending mails
      **/
    global void execute(QueueableContext context) {
        Logger.push('EmailToEnrolleesBatch', 'execute');
        
        List<AggregateResult>enrollrequestAggrList = new List<AggregateResult>();
        Set<String> batchIdSet = new Set<String> ();
        Set<Id> contactIdSet = new Set<Id>();
        List<Enrollment_Request__c> enrollrequestList = new List<Enrollment_Request__c>();
        //instantiating a list of org emails
        List<OrgWideEmailAddress> orgEmailList = new List<OrgWideEmailAddress>();
        //get value from custom setting for Template Name
        Training_Agreement_Settings__c setting = Training_Agreement_Settings__c.getInstance();
        //instantiating Messaging.SingleEmailMesage List
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        //Map of Contact Id as a key and value as a list of Enrollment Request
        Map<Id,List<Enrollment_Request__c>> conIdToEnrollReqMap = new Map<Id,List<Enrollment_Request__c>>();
        //Map of Contact id as a key and value as a boolean which decide the mail is required to send or not.
        Map<Id,Boolean> conIdToIsSendMailMap = new Map<Id,Boolean>();
        //instantiating a list of Enrollment Request
        List<Enrollment_Request__c> enrollReqLst = new List<Enrollment_Request__c>();
        //Contact Id set
        Set<Id> conIdSet = new Set<Id>();
        //Map of Contact Id as key and Messaging.sendEmailResult as a value
        Map<Id,Messaging.SendEmailResult> contactIdToEmailResultMap = new Map<Id,Messaging.SendEmailResult>();
        //instantiating a list of Messaging.SendEmailResult
        List<Messaging.SendEmailResult> results ;
        String templateApiName;
        Id templateId;
        Integer i=0;
        Integer j=0;
        List<Task> taskList = new List<Task>();
        Map<Id,String> conIdToHtmlBodyMap = new Map<Id,String>();
        Set<Id> conIdForTaskSet = new Set<Id>();
        Map<Id,String> conIdToEmailSubjectMap = new Map<Id,String>();
        
        enrollrequestAggrList = [Select count(id) ,Contact__c,Batch_ID__c From Enrollment_Request__c Where Status__c != 'Completed' group by Contact__c,Batch_ID__c];
        System.debug('**enrollrequestAggrList**'+enrollrequestAggrList);
        
        for(AggregateResult agr: enrollrequestAggrList){
            batchIdSet.add(String.valueOf(agr.get('Batch_ID__c')));
            contactIdSet.add((Id)agr.get('Contact__c'));
            //batchIdSet.add('0ea0c549-c46d-2980-7878-8f532704575a');
            //contactIdSet.add('003e000000Xdee8');
        }
        
        enrollrequestList = [Select Id,
                                    Contact__r.Email,Batch_ID__c,
                                    Contact__c,Class__c,
                                    Enterprise_Training_Agreement__c,
                                    Enterprise_Training_Agreement__r.Sponsor_Office__r.Email__c,
                                    Status__c,
                                    Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c
                                        From Enrollment_Request__c
                                        Where Batch_ID__c IN : batchIdSet 
                                            And Contact__c IN : contactIdSet
                                                And Id IN :enrollReqIdSet ];
        System.debug('**enrollrequestList**'+enrollrequestList);
        
        if(setting.Send_Email__c){
            //Set TemplateId
            templateApiName = setting.VF_Email_Template_Name__c;//'Mathworks_Training_Enroll_Confirmation';
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
            System.debug('**templateId**'+templateId);
            //set setOrgWideEmailAddressId from eta sponsor office email
            //query for Org Email ids
            orgEmailList = [SELECT Id,Address,DisplayName  FROM OrgWideEmailAddress where Address =:setting.OrgWideEmailAddress__c];
            System.debug('**orgEmailList**'+orgEmailList);
           
            
            //sendEmail to for enrollment request
            for(Enrollment_Request__c enrollReq : enrollrequestList){
            
                if(!conIdToEnrollReqMap.containsKey(enrollReq.Contact__c)){
                    conIdToEnrollReqMap.put(enrollReq.Contact__c,new List<Enrollment_Request__c>{enrollReq});
                }else{
                    conIdToEnrollReqMap.get(enrollReq.Contact__c).add(enrollReq);
                }
                
                if(conIdToEnrollReqMap.ContainsKey(enrollReq.Contact__c) && enrollReq.Status__c == 'Pending Notification'){
                    if(!conIdToIsSendMailMap.containsKey(enrollReq.Contact__c)){
                        conIdToIsSendMailMap.put(enrollReq.Contact__c,true);
                    }
                }else{
                        conIdToIsSendMailMap.put(enrollReq.Contact__c,false);
                }
            }
            
            //sendEmail to for enrollment request
            for(Enrollment_Request__c enrollReq : enrollrequestList){
                if(conIdToIsSendMailMap.containsKey(enrollReq.Contact__c) && conIdToIsSendMailMap.get(enrollReq.Contact__c) && !conIdSet.contains(enrollReq.Contact__c)){
                        System.debug('**enrollReq**'+enrollReq);
                        String[] toAddresses = new String[] {enrollReq.Contact__r.email};
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(toAddresses);
                        email.setTargetObjectId(enrollReq.Contact__c);
                        email.setTreatTargetObjectAsRecipient(true);
                        email.setWhatId(enrollReq.Id);
                        email.setTemplateId(templateId);
                        email.setSaveAsActivity(false);
                        email.setReplyTo(setting.OrgWideEmailAddress__c);
                        if(!orgEmailList.isEmpty()){
                           email.setOrgWideEmailAddressId(orgEmailList[0].Id);
                        }
                        
                        emailList.add(email);
                        conIdSet.add(enrollReq.Contact__c);
                }  
            }
            
            // send email to get result for enrollent request update
            try{
                    System.debug('**emailList**'+emailList);
                    //send all emails from the transaction
                    results = Messaging.sendEmail(emailList,false);
            }catch(System.EmailException ex){
                    System.debug('**THERE WAS AN ISSUE TO SEND MAIL TO THE DESTINATION :**'+ex.getMessage());
                    Logger.debugException('THERE WAS AN ISSUE TO SEND MAIL TO THE DESTINATION : '+ex.getMessage());
            }
            
             
            for( Messaging.SendEmailResult emailResult: results){
                if(emailList.get(i).getTargetObjectId()!= null){
                    contactIdToEmailResultMap.put(emailList.get(i).getTargetObjectId(),emailResult);
                }
               i++;
            }
            System.debug('**contactIdToEmailResultMap**'+contactIdToEmailResultMap);
        }   
        
        //list to add Enrollment_Request__c success records
        List<Enrollment_Request__c> enrollReqUpdateList = new List<Enrollment_Request__c>();
        //For Task 
        List<Enrollment_Request__c> enrollReqTaskList = new List<Enrollment_Request__c>();
        for(Enrollment_Request__c enrollReq : enrollrequestList){
            if((contactIdToEmailResultMap.containsKey(enrollReq.Contact__c)
                && contactIdToEmailResultMap.get(enrollReq.Contact__c).isSuccess()) || !setting.Send_Email__c){
                enrollReq.Status__c = 'Completed';
                enrollReqUpdateList.add(enrollReq);
                enrollReqTaskList.add(enrollReq);
                if(!Test.isRunningTest()){
                    Messaging.SingleEmailMessage emailObj = Messaging.renderStoredEmailTemplate(templateId, enrollReq.Contact__c,enrollReq.Id);
                    if(!conIdToHtmlBodyMap.containsKey(enrollReq.Contact__c)){
                        conIdToHtmlBodyMap.put(enrollReq.Contact__c,emailObj.getHtmlBody().stripHtmlTags());
                        conIdToEmailSubjectMap.put(enrollReq.Contact__c,emailObj.getSubject());
                    }
                    system.debug('Talele Rocks : '+emailObj.getSubject());
                }
                
            }else{
                if(contactIdToEmailResultMap.containsKey(enrollReq.Contact__c)){
                enrollReq.Status__c = 'Exception';
                enrollReq.Exception_Reason__c = 'Email Notification Failure:'+contactIdToEmailResultMap.get(enrollReq.Contact__c).getErrors()[0].getMessage();
                enrollReqUpdateList.add(enrollReq);
                }
            }
            j++;
        }
        System.debug('**enrollReqUpdateList**'+enrollReqUpdateList);
        
        User u = [Select Id,Name,alias From User Where alias =: setting.Task_Owner__c];
        if(!enrollReqTaskList.isEmpty()){
            for(Enrollment_Request__c enrollReqObj : enrollReqTaskList){
                if(!conIdForTaskSet.contains(enrollReqObj.Contact__c)){
                    Task tsk = new Task();
                    tsk.Subject = conIdToEmailSubjectMap.get(enrollReqObj.Contact__c);//System.Label.Cp_EnrollTemplateSubject;
                    tsk.Description = conIdToHtmlBodyMap.get(enrollReqObj.Contact__c);
                    tsk.Priority = 'Medium';
                    tsk.whoid = enrollReqObj.Contact__c;
                    tsk.whatId = enrollReqObj.Enterprise_Training_Agreement__c;
                    tsk.status = 'Completed';
                    tsk.OwnerId = u.ID;
                    taskList.add(tsk);
                    conIdForTaskSet.add(enrollReqObj.Contact__c);
                }
            }
            Try{
                insert taskList;
            }catch(Exception ex){
                    Logger.debugException('THERE WAS AN ISSUE TO Creat the Task for Enrollment Request Record : '+ex.getMessage());
            }   
        }
                
        //udpate the Enrollment Request 
        Try{
            if(!enrollReqUpdateList.isEmpty()){
                Update enrollReqUpdateList;
            }
        }catch(Exception ex){
                    Logger.debugException('THERE WAS AN ISSUE TO Update the Enrollment Request Record : '+ex.getMessage());
        }
        
        Logger.pop();
                
    }
    /**
      * @author Original: Sagar Talele - Accenture/Mathworks Last Modified: Sagar talele
      * @date Original: 20 May 2016, Last Modified: 20 May 2016
      * @description: This is execute method Schedule the class
      **/
    global void execute(SchedulableContext ctx) {
    }
}