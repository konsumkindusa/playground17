/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original: 7 July 2016, Last Modified: 7 July 2016
 *@description: This Class send the email to Training Coordinator with specific email Template
 */
global class EmailTotrainingCoordinator{
    public Enterprise_Training_Agreement__c etaObj{get;set;}
    public boolean isActivationEmail {get;set;}
    public boolean isRenewalEmail {get;set;}
    public EmailTotrainingCoordinator(ApexPages.StandardController controller){
        this.etaObj = (Enterprise_Training_Agreement__c)controller.getRecord();
    }
    public void SendActivationMail(){
        System.debug('**SendActivationMail**'+isActivationEmail );
        isActivationEmail = true;
        isRenewalEmail = false;
        sendEmailToCoordinator();
    }
    public void SendRenewalMail(){
        System.debug('**SendRenewalMail**'+isRenewalEmail );
        isRenewalEmail = true;
        isActivationEmail = false;
        sendEmailToCoordinator();
    }
    public  void sendEmailToCoordinator(){
        //get value from custom setting for Template Name
        Training_Agreement_Settings__c setting = Training_Agreement_Settings__c.getInstance();
        //instantiating Messaging.SingleEmailMesage List
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        //instantiating a list of Messaging.SendEmailResult
        List<Messaging.SendEmailResult> results ;
        Set<String> templateSet = new Set<String>();
        List<EmailTemplate> tempList = new List<EmailTemplate>();
        String activationTempName = setting.Training_Coordinator_Email_Template_Name__c;
        String renewalTempName = setting.Training_Coordinator_Renewal_Temp_Name__c;
        templateSet.add(activationTempName);
        templateSet.add(renewalTempName);
        Id templateId;
        Map<String,Id> templateNameToTempalteIdMap = new Map<String,Id>();
        //instantiating a list of org emails
        List<OrgWideEmailAddress> orgEmailList = new List<OrgWideEmailAddress>();
        
        tempList = [select id, name,developername from EmailTemplate where developername IN : templateSet];
        for(EmailTemplate temp: tempList){
            templateNameToTempalteIdMap.put(temp.developername,temp.id);
        }
        System.debug('**templateNameToTempalteIdMap**'+templateNameToTempalteIdMap);
        
        Enterprise_Training_Agreement__c enterprisetrainingobj = [Select Id,Primary_Contact__r.Email,Primary_Contact__c,
                                                        Account_Name__r.Salesforce_Territory_Id__c
                                                        From Enterprise_Training_Agreement__c
                                                            where Id =: etaObj.Id Limit 1];
        List<UserTerritory2Association> userT2AssociationList = [Select Id,RoleInTerritory2,Territory2Id,User.email
                                                                    From UserTerritory2Association 
                                                                        where RoleInTerritory2 = 'Sales Rep Primary' 
                                                                        and Territory2Id =: enterprisetrainingobj.Account_Name__r.Salesforce_Territory_Id__c];
        String [] ccAddresses = new String[]{};
        ccAddresses.add(setting.TrainopsEmails__c);
        system.debug('**ccAddresses1**'+ccAddresses);
        for(UserTerritory2Association uT2AObj : userT2AssociationList){
            if(uT2AObj.User.email != null){
                ccAddresses.add(uT2AObj.User.email);
            }
        }
        system.debug('**ccAddresses2**'+ccAddresses);
        
        //set setOrgWideEmailAddressId from eta sponsor office email
        //query for Org Email ids
        orgEmailList = [SELECT Id,Address,DisplayName  FROM OrgWideEmailAddress where Address =:setting.OrgWideEmailAddress__c];
        
        String[] toAddresses = new String[] {enterprisetrainingobj.Primary_Contact__r.Email};
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses );
        email.setTargetObjectId(enterprisetrainingobj.Primary_Contact__c);
        email.setTreatTargetObjectAsRecipient(true);
        email.setWhatId(enterprisetrainingobj.Id);
        if(!orgEmailList.isEmpty()){
            email.setOrgWideEmailAddressId(orgEmailList[0].Id);
        }
        if(isActivationEmail){
            templateId = templateNameToTempalteIdMap.get(activationTempName);
            email.setTemplateId(templateId);
        }
        System.debug('**Outside if**'+isRenewalEmail );
        if(isRenewalEmail ){
            System.debug('**Inside if**'+isRenewalEmail );
            templateId = templateNameToTempalteIdMap.get(renewalTempName);
            email.setTemplateId(templateId);
        }
        email.setSaveAsActivity(false);
        emailList.add(email);
        system.debug('**emailList**'+emailList);
        // send email to get result for enrollent request update
        try{
            System.debug('**emailList**'+emailList);
            //send all emails from the transaction
            results = Messaging.sendEmail(emailList,false);
        }catch(System.EmailException ex){
            System.debug('**THERE WAS AN ISSUE TO SEND MAIL TO THE DESTINATION :**'+ex.getMessage());
            Logger.debugException('THERE WAS AN ISSUE TO SEND MAIL TO THE DESTINATION : '+ex.getMessage());
        }
        if(results[0].isSuccess()){
            User u = [Select Id,Name,alias From User Where alias =: setting.Task_Owner__c];
        
            Messaging.SingleEmailMessage emailObj = Messaging.renderStoredEmailTemplate(templateId, enterprisetrainingobj.Primary_Contact__c,enterprisetrainingobj.Id);
            String emailHtmlBody = emailObj.getHtmlBody().stripHtmlTags();
            String emailSubject = emailObj.getSubject();
            Task tsk = new Task();
            tsk.Subject = emailSubject;
            tsk.Description = emailHtmlBody;
            tsk.Priority = 'Medium';
            tsk.whoid = enterprisetrainingobj.Primary_Contact__c;
            tsk.whatId = enterprisetrainingobj.Id;
            tsk.status = 'Completed';
            tsk.OwnerId = u.ID;
            try{
                Insert tsk;
            }catch(Exception ex){
                System.debug('THERE WAS AN ISSUE TO INSERT A TASK  :'+ex.getMessage());
                Logger.debugException('THERE WAS AN ISSUE TO INSERT A TASK  :'+ex.getMessage());
            }
        }
        
        
    }
}