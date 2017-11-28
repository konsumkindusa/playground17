/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 11 June 2013, Last Modified: 29 October 2013
* @description Class to handle delegated DML operations for EmailMessage object. 
* @FG 04/25/14 copied the original class from production 
* @FG 04/25/14 FG added logic to set flag on the Task Email Has Attachment G#1019527
*/
public class EmailMessageDML {
    
     /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 11 June 2013, Last Modified: 29 October 2013
    * @description method that updates the status of a related open activity to 'Completed' and get's the ThreadID of the Email
    * @param List_Emails collection of EmailMessage records
    **/
    public void CloseActivity(list <EmailMessage> List_Emails){
        
        //instantiate CustomSettingsBuilder class
        CustomSettingsBuilder csb = new CustomSettingsBuilder();
        Boolean EmailHasAttachment;//FG
        //Get Activity Ids
        map <Id,EmailMessage> ActEmailMap = new map <Id,EmailMessage>();
        
        //get Reference Organization ID
        String orgID = Userinfo.getOrganizationId();
        String reforgIDa = 'ref:_'+orgID.substring(0,5) + orgID.substring(11,15); //For 9 character ThreadID
        String reforgIDb = 'ref:_'+orgID.substring(0,5) + orgID.substring(10,15); //For 10 character ThreadID
        
        for (EmailMessage em : List_Emails){
        //FG get HasAttachment flag from the email record
            EmailHasAttachment = em.HasAttachment;
            //Collect all Case Ids if Emails are sent
            if (em.Status == '3'){
                ActEmailMap.put(em.ActivityId,em);
                //Get ThreadID and set it to Task
                if (em.TextBody.contains(reforgIDa+'._'+String.valueof(em.ParentId).substring(0, 5) + String.valueof(em.ParentId).substring(10,15)+':ref')){
                    String refID = reforgIDa+'._'+String.valueof(em.ParentId).substring(0, 5) + String.valueof(em.ParentId).substring(10,15)+':ref';
                    //Get Email Addresses (To, CC, BCC)
                    String emails = em.ToAddress;
                    if (em.CcAddress != null){
                      if (String.valueof(em.CcAddress).contains(';')){
                        emails += em.CcAddress;
                      }
                      else {
                        emails += ';' + em.CcAddress;
                      }
                    }
                    if (em.BccAddress != null){
                      if (String.valueof(em.BccAddress).contains(';')){
                        emails += em.BccAddress;
                      }
                      else {
                        emails += ';' + em.BccAddress;
                      }
                      
                    }
                }
                if (em.TextBody.contains(reforgIDb+'._'+String.valueof(em.ParentId).substring(0, 5) + String.valueof(em.ParentId).substring(10,15)+':ref')){
                    String refID = reforgIDb+'._'+String.valueof(em.ParentId).substring(0, 5) + String.valueof(em.ParentId).substring(10,15)+':ref';
                    //Get Email Addresses (To, CC, BCC)
                    String emails = em.ToAddress;
                    if (em.CcAddress != null){
                      if (String.valueof(em.CcAddress).contains(';')){
                        emails += em.CcAddress;
                      }
                      else {
                        emails += ';' + em.CcAddress;
                      }
                    }
                    if (em.BccAddress != null){
                      if (String.valueof(em.BccAddress).contains(';')){
                        emails += em.BccAddress;
                      }
                      else {
                        emails += ';' + em.BccAddress;
                      }
                      
                    }
                }
            }
        }
        
        //Retrieve Activities where Email Messsage was referenced to
        //FG commented the original select statement to add has attachment flag to the select query
       // list <Task> Actlist = [Select Id, Status, WhatId, OwnerId From Task Where Id in : ActEmailMap.keyset()];
        list <Task> Actlist = [Select Id, Status, WhatId, OwnerId, Has_Attachment__c From Task Where Id in : ActEmailMap.keyset()]; 
        //Collect all task activity to be updated
        list <Task> UpActlist = new list <Task>();
        if (Actlist.size() > 0){
            for (Task tsk : Actlist){
                //Close Activities 
                if (ActEmailMap.containskey(tsk.Id)){
                    tsk.Status = 'Completed';
                    tsk.Has_Attachment__c = EmailHasAttachment;//FG
                    UpActlist.add(tsk);
                    Logger.debug(tsk.Id);
                }
            }
        }
        
        //Update Activities 
        if (UpActlist.size() > 0){
            try{
                update UpActlist;
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Capture Dml exception here
                    Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
        }
        
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 7 July 2013
    * @description method sets email htmlbody.
    * @param emailList collection of EmailMessage records
    **/
    public void setEmailHtmlBody(list <EmailMessage> emailList){
        for (EmailMessage em : emailList){
            String plaintextbody = em.TextBody;
            em.HtmlBody = em.HtmlBody;
        }
    }
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 11 July 2013
    * @description sets the related Case subStatus to "Waiting for Internal".
    * @param emailList collection of EmailMessage records
    **/
    public void setParentCaseToWaitingForInternal(list <EmailMessage> newEmailList){
       set<id> parentIdsOfDraftMails = new set<id>();
        set<id> caseWaitingForInternals = new set<id>();
        set<id> emailMessageIdInDraft = new set<id>();
        map<id,id> emailMessageToCaseMap = new map<id,id>();
        map<id,String> emailMessageToProcessInstanceStatusMap = new map<id,String>();
        map<id,EmailMessage> emailMessageMap = new map<id,EmailMessage>();
        system.debug('@@newEmailList size:'+newEmailList.size());
        for (EmailMessage em : newEmailList){
            system.debug('@@Status:'+em.Status);
            if(em.Status =='5'){
                if(em.Subject.contains('-[For Approval]-')){
                    caseWaitingForInternals.add(em.parentId);
                }else{
                    parentIdsOfDraftMails.add(em.parentId);
                    emailMessageToCaseMap.put(em.id,em.parentId);
                    emailMessageMap.put(em.id,em);
                    emailMessageIdInDraft.add(em.id);
                }
            }
        }
        
        if(caseWaitingForInternals.size()>0){
            system.debug('@@updating cases for waiting for internal');
            List<Case> caseWaitingForInternalsList = [select id, SubStatus__c from Case WHERE id IN :caseWaitingForInternals];
            List<Case> casesForUpdate  = new List<Case>();
            for(Case c: caseWaitingForInternalsList){
                system.debug('@@c:'+c);
                c.SubStatus__c = 'Waiting for Internal';
                Logger.debug(c.Id);
                casesForUpdate.add(c);
            }
            system.debug('@@casesForUpdate: '+casesForUpdate);
            try{
                update casesForUpdate;
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Capture Dml exception here
                   Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
        }
        
        if(parentIdsOfDraftMails.size()>0){
            system.debug('@@entered second if statement');
            //get the status of approval related to emailMessages records
            List<ProcessInstance> processInstanceList = [SELECT Id,Status,TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN: emailMessageIdInDraft ORDER BY LastModifiedDate DESC];
            
            for(ProcessInstance pil:processInstanceList){
                if(emailMessageToProcessInstanceStatusMap.get(pil.TargetObjectId)==null){
                    emailMessageToProcessInstanceStatusMap.put(pil.TargetObjectId,pil.Status);
                    system.debug('@@Status:'+pil.status);
                }
            }
            
            //Map Case
            Map<id,Case> caseMap = new Map<id,Case> ([select id, SubStatus__c from Case WHERE id IN :parentIdsOfDraftMails]);
            
            List<Case> caseForUpdate = new List<Case>();
            for(id emmid: emailMessageIdInDraft){
                system.debug('@@current emmid:'+emmid);
                //get aproval status
                String approvalStatus = emailMessageToProcessInstanceStatusMap.get(emmid);
                system.debug('@@approval Status:'+approvalStatus);
                if(approvalStatus=='Rejected'){
                    Case updatedCase = new Case();
                    id caseId = emailMessageToCaseMap.get(emmid);
                    updatedCase = caseMap.get(caseId);
                    updatedCase.SubStatus__c = 'In Progress';
                    caseForUpdate.add(updatedCase);
                    Logger.debug(caseId);
                    system.debug('@@caseForUpdate:'+caseForUpdate);
                }
                if(approvalStatus=='Approved'){
                    Case updatedCase = new Case();
                    id caseId = emailMessageToCaseMap.get(emmid);
                    updatedCase = caseMap.get(caseId);
                    updatedCase.SubStatus__c = 'In Progress';
                    caseForUpdate.add(updatedCase);
                    Logger.debug(caseId);
                    system.debug('@@caseForUpdate:'+caseForUpdate);
                }
                
            }
            if(caseForUpdate.size()>0){
                try{
                    update caseForUpdate;
                }
                catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Capture Dml exception here
                    Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
            }
        
        }
        
    }
}