/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: kishore AN
* @date Original: 28 May 2013, Last Modified: 30 June 2015 By Jaspreet Monga
* @Description: Handles all Inbound Emails Email To Case functionality  
*/
public class EmailToCaseOverride {
    
   /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
    * @date Original: 28 May 2013, Last Modified: 31 October 2014, 
    * @Description: main method for forwarding messages to forwarding email addresses 
    * @param: email - contains email subject, body etc.
    * @param: envelope - contains Sender's email, Recipient's email, etc.
    * @ FG 11/22/13 - added logic to accetp html format 
    * @ FG 03/30/2014 G1019527 add EmailAttachment flag to task
    * @ KAN Updated the email routing rules to include case record type field and updated the createcase method call
    * @ KAN updated the code to generate a new 8 digit refID and use it in the check for refID
    */
    public static void ForwardEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        
        String emailSubj = email.Subject;
        
        //FG 11/18/13 save html body as plain text, commented orig line;
        String plainTextEmailBody = null;
        String HtmlEmailBody = null;
               if (email.htmlBody != null){
                   HtmlEmailBody = email.htmlBody;}
               if(email.plainTextBody != null){
                    plainTextEmailBody = email.plainTextBody;
                }
                else{ 
                    plainTextEmailBody = email.htmlBody;
                }
              
        system.debug('@@envelope To Address:'+envelope.ToAddress);
        list<string> emailCC = email.ccAddresses;
        String emailFrom = email.fromAddress;
        //String emailTo = envelope.toAddress;+
        
        
        String erulequery = 'SELECT Email_Service_Address__c, Response_to_DEV_email__c, Response_to_PROD__c, Response_to_TEST_email__c,Case_Record_Type__c FROM Email_Routing_Rules__c';
        //get general setting custom setting org defaults
        General_Settings__c genset = General_Settings__c.getInstance();
        list <Sobject> emailRules = database.query(erulequery);
        map <string,string> responseEmailMap = new map<string,string>();
        for (Sobject sobj: emailRules){
            if (envelope.toAddress == (String)sobj.get('Email_Service_Address__c') ){
                responseEmailMap.put((String)sobj.get(genset.EmailRoutingRule_Current_ResponseTo__c),(String)sobj.get('Email_Service_Address__c'));               
            }
        }
        system.debug('@@Response Email:'+responseEmailMap);
        
        list <String> emailsTo = email.toAddresses;
        String emailTo = '';
        if(emailsTo != null && emailsTo.size()>0){  
            for (String ToEmail : emailsTo){
                System.Debug('@@@ToEmail:'+ToEmail);
                if (responseEmailMap.containskey(ToEmail)){
                    //Service Email Address
                    emailTo = responseEmailMap.get(ToEmail);
                    system.debug('@@To Address:'+emailTo);
                }
                //Directly used a service email address
                else if (ToEmail.contains('salesforce.com')){
                    emailTo = ToEmail;
                }
                else {
                    if (emailCC == null){
                        emailCC = new list<string>();
                    }
                    //make additional To Addresses as CC Addresses
                    emailCC.add(ToEmail);
                    system.debug('@@CC Addresses:'+emailCC);
                }
            }
        }
        //if the email to is empty, check if the response email map has some values and use the envolope email toaddress
        if(emailTo=='' || emailTo == null){
            if(responseEmailMap.size() > 0){
                emailTo = envelope.toAddress;
            }
        }
        
        String debugcheck = ''; String AreaOnSR = ''; Boolean EmailHasAttachment = false; //fg
        //Holds the case id if a case already exists 
        Id currentCaseId = null;
        //Email Binary Attachments (PDF, excel, images, etc)
        list <Messaging.Inboundemail.Binaryattachment> emailBinaryDocs = new list <Messaging.Inboundemail.Binaryattachment>();
        list <Messaging.EmailFileAttachment> emailattachments = new list <Messaging.EmailFileAttachment>();
        if (email.binaryAttachments != null){ 
            emailBinaryDocs = email.binaryAttachments;
            for (Messaging.InboundEmail.BinaryAttachment binatt : emailBinaryDocs){
                Messaging.EmailFileAttachment efatt = new Messaging.EmailFileAttachment();
                if(binatt.Body.size() > 0){
                    efatt.setBody(binatt.Body);
                    efatt.setFileName(binatt.filename);
                    efatt.setContentType(binatt.mimeTypeSubType);
                    emailattachments.add(efatt);
                    if (EmailHasAttachment == false)//fg
                    {
                      Integer attsize = binatt.Body.size();
                      if(attsize < 5242880)
                      {
                        EmailHasAttachment = true;
                      }
                    }
                }
            }
        }
        //Email Text Attachments (txt)
        list <Messaging.Inboundemail.Textattachment> emailTextDocs = new list <Messaging.Inboundemail.Textattachment>(); 
        if (email.textAttachments != null){
            emailTextDocs = email.textAttachments;
            for (Messaging.InboundEmail.Textattachment binatt : emailTextDocs){
                Messaging.EmailFileAttachment efatt = new Messaging.EmailFileAttachment();
                
                if(binatt.body.length() > 0){
                    efatt.setBody(Blob.valueof(binatt.Body));
                    efatt.setFileName(binatt.filename);
                    efatt.setContentType(binatt.mimeTypeSubType);
                    emailattachments.add(efatt);
                    Integer textsize = binatt.body.length();
                    if (EmailHasAttachment == false)//fg
                    {
                      if(textsize < 5242880)
                      {
                        EmailHasAttachment = true;
                      }
                    }
                }
            }
        }
        
        String senderAddress = emailFrom; 
        system.debug('sender Address:'+senderAddress);
        //get email User Name
        String emailUserName = (senderAddress.split('@',2))[0];
        system.debug('Email UserName:'+emailUserName);
        //get domain country code
        String domainExtension = senderAddress.substringAfterLast('.').toLowerCase();
        system.debug('Domain Extension:'+domainExtension);
        
        debugcheck += '\nemailUserName0: ' + emailUserName;
        debugcheck += '\nEmail To: ' + emailTo;
        debugcheck += '\nEmail CC: ' + emailCC;
        String serviceEmailAddress = emailTo;
        System.Debug('@@@serviceEmailAddress :'+serviceEmailAddress);
        //get Reference Organization ID
        String orgID = Userinfo.getOrganizationId();
        String reforgIDa = 'ref:_'+orgID.substring(0,5) + orgID.substring(11,15); //For 9 character ThreadID
        String reforgIDb = 'ref:_'+orgID.substring(0,5) + orgID.substring(10,15); //For 10 character ThreadID
        String reforgIDc = 'ref:_'+orgID.substring(0,5) + orgID.substring(12,15); //For 8 character ThreadID
        //get user email domains being ignored on Forwarding Rules 
        list<Ignored_usernames__c> ignoredUserNames = [SELECT id FROM Ignored_usernames__c WHERE Name = :emailUserName];
        
        //Truncate Email Subject if characters exceeds Subject length
        String truncatedSubj;
        system.debug(emailSubj.length() + ' --emailSubj.length()');
        if (emailSubj.length() > 255){
            String tempsubj = emailSubj.substring(0,205); //Get first 205 characters on email Subject
            //Subjects with Thread ID
            if (emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc)  ){
                string truncatedthreadID = emailSubj.substringAfterLast('[ ref:_');
                system.debug('@@truncatedThreadID: [ ref:_'+truncatedthreadID);
                tempsubj+= '... [ ref:_'+truncatedthreadID;
                truncatedSubj = tempsubj;
            }
            //Subjects without Thread ID
            else{
                truncatedSubj = tempsubj;
            }
        }
        else{
            truncatedSubj = emailSubj;
        }
        system.debug('@@truncated Subject:'+truncatedSubj.length()+truncatedSubj);
        //Truncate Email Body if characters exceeds Body length
        String truncatedBody;
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        if ( plainTextEmailBody !=null && plainTextEmailBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
            String tempBody = plainTextEmailBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-1000); //Get first 31000 characters on email Body and it will remove the last threadid from email body
            //Creates body with last Thread ID 
            if (plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc)   ){
                string truncatedthreadID = plainTextEmailBody.substringAfterLast('ref:_');
                truncatedthreadID = truncatedthreadID.substringBefore(':ref'); // will remove text after last thread id (change is for Geck 1056463)
                tempBody+= '... ref:_'+truncatedthreadID+ ':ref '; // Again appends thread id to body
                truncatedBody = tempBody;
            }
            //Body without Thread ID
            else{
                truncatedBody = tempBody;
            }
        }
        else{
                truncatedBody = plainTextEmailBody ;
        }
        boolean isContainsReforgIDaOrIDb = false;
            if(plainTextEmailBody != null){
                 isContainsReforgIDaOrIDb = ( plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb)|| plainTextEmailBody.contains(reforgIDc));
            }
        system.debug('@@refOrgIDa:'+refOrgIDa);
        system.debug('@@refOrgIDb:'+refOrgIDb);
        system.Debug('@@reforgIDc:'+reforgIDc);
        //Extract the thread Id from the email body or on email subject and get the case Id
        if( isContainsReforgIDaOrIDb || emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc)){
            String caseThreadId = '';
            if (isContainsReforgIDaOrIDb){ 
                caseThreadId = plainTextEmailBody.SubstringBetween('ref:',':ref');
            }
            system.debug('@@caseThreadID1:'+caseThreadID);
            if (caseThreadId == null || caseThreadID == ''){
                if ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc ) ) {
                    caseThreadId = emailSubj.SubstringBetween('ref:',':ref');
                }
            }
            system.debug('@@caseThreadID2:'+caseThreadID);
            try{
                currentCaseId = Cases.getCaseIdFromEmailThreadId(caseThreadId);
            }catch(Exception ex){                
                currentCaseId = null;
            }
            system.debug('@@currentCaseID:'+currentCaseId);
        }
        if(ignoredUserNames.size()==0 ){
            
            String[] forwardToAddresses = new String[]{};
            String[] forwardCcAddresses = new String[]{};
            String ccAddressesString='';
            id newCaseId;
            
            debugcheck += '\n@EmailTBody:'+ email.plainTextBody;
            //debugcheck += '\n@Attachment:'+emailDoc;
            
            if(emailCc!=null){
                for(String e: emailCc){
                    forwardCcAddresses.add(e);
                    if(ccAddressesString!=null && ccAddressesString!=''){
                        ccAddressesString +=', ';
                    }
                    ccAddressesString += String.valueOf(e);
                }
            }
            
            System.Debug('@@@serviceEmailAddress :'+serviceEmailAddress);
            //Gets the current Email Routing Address
            list<Email_Routing_Rules__c> emailRoutingRule =  [SELECT Name, Area_on_SR__c, Response_to_DEV_email__c, Response_to_PROD__c, Response_to_TEST_email__c, Sub_Area_on_SR__c, Generic_Email__c,Case_Record_Type__c FROM Email_Routing_Rules__c WHERE Email_Service_Address__c = : serviceEmailAddress AND Email_Service_Address__c <> null limit 1];
            sobject emailRoutingRuleSobj = new Email_Routing_Rules__c();
            list <Forwarding_Rule__c> frRecord = new list <Forwarding_Rule__c>();
            if (emailRoutingRule.size() > 0){
                emailRoutingRuleSobj = (sobject)emailRoutingRule[0];
                //Forwarding Rules and Email Routing Rules are applied on generic Emails
                if (emailRoutingRule[0].Generic_Email__c){
                    //Checks if country domain is supported by Mathworks
                    frRecord = [SELECT Forwarding_Email_Address__c, Distributor_Name__c, Dommain_Country_Code__c, Case_Area_Country_Code__c, Email_Template_Name__c,MathWorks_Office__c FROM Forwarding_Rule__c WHERE Dommain_Country_Code__c = :domainExtension limit 1];
                    if (frRecord.size() > 0){
                        //Checks if email is sent to Service or Support Mathworks address
                        if (emailRoutingRule[0].Name == 'service@mathworks.com'){
                            AreaOnSR = frRecord[0].Case_Area_Country_Code__c + ' - Customer Support';
                        }
                        else if (emailRoutingRule[0].Name == 'support@mathworks.com'){
                            AreaOnSR = frRecord[0].Case_Area_Country_Code__c + ' - Technical Support';
                        }
                        
                        //Forward the email.
                        String forwardingEmailAdd;
                        String forwardingDistributor; 
                        String forwardingEmailAddTest;
                        String fowardingEmailTemplate;
                        for (Forwarding_Rule__c s: frRecord){
                            forwardingEmailAdd = s.Forwarding_Email_Address__c; //Forwarding Email Address is the Current Response To of the org
                            forwardingDistributor = s.Distributor_Name__c;
                            forwardToAddresses.add(forwardingEmailAdd); 
                            fowardingEmailTemplate = s.Email_Template_Name__c;
                        }
                        Messaging.Singleemailmessage mailToForward = new Messaging.Singleemailmessage();
                        //Set To, Reply To,Subject, Body of the Email to be forwarded
                        mailToForward.setToAddresses(forwardToAddresses);
                        if(emailCc!=null){
                            mailToForward.setCcAddresses(forwardCcAddresses);
                        }
                        mailToForward.setReplyTo(senderAddress);
                        mailToForward.setSubject(emailSubj);
                        //FG 11/19/13 - added logic to pass html body or plain text
                       // mailToForward.setPlainTextBody(HtmlEmailBody);
                        if (email.HtmlBody !=null){
                            mailToForward.setHtmlBody(HtmlEmailBody);}
                        else if (email.PlainTextBody !=null){
                            mailToForward.setPlainTextBody(plainTextEmailBody);}
                        else {mailToForward.setPlainTextBody('');}
                        mailToForward.setSenderDisplayName(senderAddress);
                        if (emailattachments.size() > 0){
                            mailToForward.setFileAttachments(emailattachments);
                        }
                        
                        //Create case or Activity if reference exist.
                        String ResponseToEmail = forwardingEmailAdd;
                        
                        debugcheck += '\n@ResponseToEmail:'+ResponseToEmail;
                        
                        if( currentCaseId != null && ( ( plainTextEmailBody != null &&( plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc) )) || ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb)|| emailSubj.contains(reforgIDc)) ) ){
                            debugcheck += '\ncrit=0';
                            //id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId); fg
                            id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId, EmailHasAttachment);
                            //Create related Email Message on Case
                            id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,null,plainTextEmailBody);
                            //Create Email Attachments if theres any
                             //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                            if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                                CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                            }
                            //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                            if (emailTextDocs.size() > 0 && emailMsgId != null){
                                CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                            }
                        }
                        else {
                            //Creates case if email is not a Distributor 
                            if(frRecord[0].MathWorks_Office__c == true){
                                debugcheck += '\n@EmailRoutingRule:'+emailRoutingRule;                                                  
                                //Create Case and assign default values for Area and Sub-Area
                                //SendConfirmationMail(senderAddress, forwardingEmailAdd, forwardCcAddresses, forwardingDistributor, emailSubj,'MathWorksEmail');
                                debugcheck +=  '\ncrit=1';
                                //Create Case
                                newCaseId = CreateCase(senderAddress, truncatedSubj, truncatedBody, AreaOnSR, emailRoutingRule[0].Sub_Area_on_SR__c, 'Unassigned', debugcheck, emailRoutingRule[0].Case_Record_Type__c);
                                //Create related Activity
                                //id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId);//fg
                                id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId, EmailHasAttachment);
                                //Create related Email Message on Case
                                id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                                //Create Email Attachments if theres any
                                //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                                if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                                    CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                                }
                                //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                                if (emailTextDocs.size() > 0 && emailMsgId != null){
                                    CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                                }
                            }
                            else{
                                //Forward the email to the distributor and send a notification mail to sender
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailToForward });
                                SendConfirmationMail(senderAddress, forwardingEmailAdd, forwardCcAddresses, forwardingDistributor, emailSubj,'Forwarding Rules Auto Reply Email'); 
                            }
                        }
                    }
                    else{
                        //Email is sent directly to specific email service address
                        AreaONSR = EmailRoutingRule[0].Area_on_SR__c;
                        if(  currentCaseId != null && ( ( plainTextEmailBody != null &&( plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc) )) || ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc)) )  ){
                            debugcheck += '\ncrit=2';
                            //Create related Activity
                          // id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId);//fg
                           id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId, EmailHasAttachment);
                            //Create related Email Message on Case
                            id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                            //Create Email Attachments if theres any
                            //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                             if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                                CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                            }
                            //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                            if (emailTextDocs.size() > 0 && emailMsgId != null){
                                CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                            }
                        }
                        else{
                            debugcheck += '\ncrit=3';
                            //Create Case
                            newCaseId = CreateCase(senderAddress, truncatedSubj, truncatedBody,AreaONSR,emailRoutingRule[0].Sub_Area_on_SR__c,'Unassigned',debugcheck,emailRoutingRule[0].Case_Record_Type__c);
                            //Sends Confirmation email
                            //SendConfirmationMail(senderAddress, null, forwardCcAddresses, null, emailSubj,'Math Works Notification Mail');
                            //Create related Activity
                            //id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId);// fg
                            id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId, EmailHasAttachment);
                            //Create related Email Message on Case
                            id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                            //Create Email Attachments if theres any
                            //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                            if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                                CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                            }
                            //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                            if (emailTextDocs.size() > 0){
                                CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                            }
                        }
                    }
                    
                }
                //Only Email Routing Rules are applied on non-generic Emails
                else{
                    //Email is sent directly to specific email service address
                    AreaONSR = EmailRoutingRule[0].Area_on_SR__c;
                    if( currentCaseId != null && ( ( plainTextEmailBody != null &&( plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc) ) )|| ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc)) )  ){
                        debugcheck += '\ncrit=4';
                        //Create related Activity
                      //  id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId);
                      id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId, EmailHasAttachment);//fg
                      
                        //Create related Email Message on Case
                        id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                        //Create Email Attachments if theres any
                        //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                        if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                            CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                        }
                        //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                        if (emailTextDocs.size() > 0 && emailMsgId != null){
                            CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                        }
                    }
                    else{
                        debugcheck += '\ncrit=5';
                        //Create Case
                        newCaseId = CreateCase(senderAddress, truncatedSubj, truncatedBody,AreaONSR,emailRoutingRule[0].Sub_Area_on_SR__c,'Unassigned',debugcheck,emailRoutingRule[0].Case_Record_Type__c);
                        //Sends Confirmation email
                        //SendConfirmationMail(senderAddress, null, forwardCcAddresses, null, emailSubj,'Math Works Notification Mail');
                        //Create related Activity
                        //id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId);// fg
                        id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId, EmailHasAttachment);
                        //Create related Email Message on Case
                        id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                        //Create Email Attachments if theres any
                        //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                        if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                            CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                        }
                       //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                        if (emailTextDocs.size() > 0 && emailMsgId != null){
                            CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                        }
                    }
                }
            }
            else{
                string responseAddress = '';
                for (string response :responseEmailMap.keySet()){
                    system.debug('@@responseEmailMap:'+responseEmailMap);
                    responseAddress = response;
                }
                //create default case
                newCaseId = CreateCase(senderAddress, truncatedSubj, truncatedBody,'Natick - Customer Support','','Unassigned',debugcheck, null);
                //Create related Activity
                //id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId);//fg
                id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId, EmailHasAttachment);
                //Create related Email Message on Case
                id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                //Create Email Attachments if theres any
                //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                    CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                }
                //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                if (emailTextDocs.size() > 0 && emailMsgId != null){
                    CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                }
            }
            
        }
    }
    
    
  
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
    * @date Original: 13 June 2013, Last Modified: 21 October 2015
    * @Description: main method that updates Case SubStatus to 'In Progress' and Activity Category to 'Escalation - Request to Dev' on an Inbound Email
    * @param: email - contains email subject, body etc.
    * @param: envelope - contains Sender's email, Recipient's email, etc.
    * @ FG 11/18/13 -  save email body html or plain text
    * @KAN - Updated the email routing rules query and the createcase method call
    * @ KAN updated the code to generate a new 8 digit refID and use it in the check for refID
    */
    public static void EscalateToDevInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        
        String emailSubj = email.Subject;
        Boolean EmailHasAttachment = false;//fg
       
        String plainTextEmailBody = null;
        String HtmlEmailBody = null;
        
        if (email.htmlBody != null){
            HtmlEmailBody = email.htmlBody;
        }
        if(email.plainTextBody != null){
            plainTextEmailBody = email.plainTextBody;
        }
        else{
            plainTextEmailBody = email.htmlBody;
        }
        List<string> emailCC = email.ccAddresses;
        String emailFrom = email.fromAddress;
        //String emailTo = envelope.toAddress;
        
        String erulequery = 'SELECT Email_Service_Address__c, Response_to_DEV_email__c, Response_to_PROD__c, Response_to_TEST_email__c,Case_Record_Type__c FROM Email_Routing_Rules__c';
        //get general setting custom setting org defaults
        General_Settings__c genset = General_Settings__c.getInstance();
        list <Sobject> emailRules = database.query(erulequery);
        map <string,string> responseEmailMap = new map<string,string>();
        for (Sobject sobj: emailRules){
            if (envelope.toAddress == (String)sobj.get('Email_Service_Address__c') ){
                responseEmailMap.put((String)sobj.get(genset.EmailRoutingRule_Current_ResponseTo__c),(String)sobj.get('Email_Service_Address__c'));
                
            }
        }
        system.debug('@@Response Email:'+responseEmailMap);
        
        list <String> emailsTo = email.toAddresses;
        String emailTo = '';
        if(emailsTo !=null && emailsTo.size() > 0){
            for (String ToEmail : emailsTo){
            System.Debug('@@ToEmail:'+ToEmail);
                if (responseEmailMap.containskey(ToEmail)){
                    //Service Email Address
                    emailTo = responseEmailMap.get(ToEmail);
                    system.debug('@@To Address:'+emailTo);
                }
                //Directly used a service email address
                else if (ToEmail.contains('salesforce.com')){
                    emailTo = ToEmail;
                }
                else {
                    if (emailCC == null){
                        emailCC = new list<string>();
                    }
                    //make additional To Addresses as CC Addresses
                    emailCC.add(ToEmail);
                    system.debug('@@CC Addresses:'+emailCC);
                }
            }
        }
        
        //if the email to is empty, check if the response email map has some values and use the envolope email toaddress
        if(emailTo=='' || emailTo == null){
            if(responseEmailMap.size() > 0){
                emailTo = envelope.toAddress;
            }
        }
        
        //Holds the case id if a case already exists 
        Id currentCaseId = null;
        //Email Binary Attachments (PDF, excel, images, etc)
        List <Messaging.Inboundemail.Binaryattachment> emailBinaryDocs = new list <Messaging.Inboundemail.Binaryattachment>();
        if (email.binaryAttachments != null){ 
            emailBinaryDocs = email.binaryAttachments;
            if (EmailHasAttachment == false)//fg
                    {
                      
                      EmailHasAttachment = true;
                      
                      
                      
                    }
        }
        //Email Text Attachments (txt)
        List <Messaging.Inboundemail.Textattachment> emailTextDocs = new list <Messaging.Inboundemail.Textattachment>(); 
        if (email.textAttachments != null){
          
            emailTextDocs = email.textAttachments;
            if (EmailHasAttachment == false)//fg
                    {
                      EmailHasAttachment = true;
                      
                    }
        }
        
        String senderAddress = emailFrom; //@@Test@@ after testing replace the email with emailFrom.
        String serviceEmailAddress = emailTo;
        System.Debug('@@@serviceEmailAddress:'+ serviceEmailAddress);
        //get Reference Organization ID
        String orgID = Userinfo.getOrganizationId();
        String reforgIDa = 'ref:_'+orgID.substring(0,5) + orgID.substring(11,15); //For 9 character ThreadID
        String reforgIDb = 'ref:_'+orgID.substring(0,5) + orgID.substring(10,15); //For 10 character ThreadID
        String reforgIDc = 'ref:_'+orgID.substring(0,5) + orgID.substring(12,15); //For 8 character ThreadID
        
        //Truncate Email Subject if characters exceeds Subject length
        String truncatedSubj;
        if (emailSubj.length() > 255){
            String tempsubj = emailSubj.substring(0,205); //Get first 205 characters on email Subject
            //Subjects with Thread ID
            if (emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc) ){
                string truncatedthreadID = emailSubj.substringAfterLast('[ ref:_');
                system.debug('@@truncatedThreadID: [ ref:_'+truncatedthreadID);
                tempsubj+= '... [ ref:_'+truncatedthreadID;
                truncatedSubj = tempsubj;
            }
            //Subjects without Thread ID
            else{
                truncatedSubj = tempsubj;
            }
        }
        else{
            truncatedSubj = emailSubj;
        }
        system.debug('@@truncated Subject:'+truncatedSubj.length()+truncatedSubj);
        //Truncate Email Body if characters exceeds Body length
        String truncatedBody;
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        if (plainTextEmailBody != null && plainTextEmailBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
            String tempBody = plainTextEmailBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-1000); //Get first 31000 characters on email Body
            //Body with Thread ID
            if (plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc)  ){
                string truncatedthreadID = plainTextEmailBody.substringAfterLast('ref:_');
                truncatedthreadID = truncatedthreadID.substringBefore(':ref');
                system.debug('@@truncatedThreadID: ref:_'+truncatedthreadID + ':ref ');
                tempBody+= '... ref:_'+truncatedthreadID+ ':ref';
                truncatedBody = tempBody;
            }
            //Body without Thread ID
            else{
                truncatedBody = tempBody;
            }
        }
        else{
                truncatedBody = plainTextEmailBody ;
            }
        system.debug('@@truncated Body:'+truncatedBody.length()+truncatedBody);
        
        //Extract the thread Id from the email body or on email subject and get the case Id
        if(( plainTextEmailBody != null &&( plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc) )) || ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb)|| emailSubj.contains(reforgIDc)) ){
            String caseThreadId = '';
            if ( (plainTextEmailBody != null)&& ( plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb)|| plainTextEmailBody.contains(reforgIDc) )){ 
                caseThreadId = plainTextEmailBody.SubstringBetween('ref:',':ref');
            }
            system.debug('@@caseThreadID1:'+caseThreadID);
            if (caseThreadId == null || caseThreadID == ''){
                if ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc)  ) {
                    caseThreadId = emailSubj.SubstringBetween('ref:',':ref');
                }
            }
            system.debug('@@caseThreadID2:'+caseThreadID);
            try{
                currentCaseId = Cases.getCaseIdFromEmailThreadId(caseThreadId);
            }catch(Exception ex){                
                currentCaseId = null;
            }
            system.debug('@@currentCaseID:'+currentCaseId);
        }
        String ccAddressesString='';
        id newCaseId;
            
        String debugcheck = '';
        //debugcheck += '@Attachment:'+emailDoc;
            
        if(emailCc!=null){
            for(String e: emailCc){
                if(ccAddressesString!=null && ccAddressesString!=''){
                    ccAddressesString +=', ';
                }
                ccAddressesString += String.valueOf(e);
            }
        }
        
        //Get Routing Email Address
        List<Email_Routing_Rules__c> emailRoutingRule =  [SELECT Name, Area_on_SR__c, Response_to_DEV_email__c, Response_to_PROD__c, Response_to_TEST_email__c, Sub_Area_on_SR__c, Generic_Email__c,Case_Record_Type__c FROM Email_Routing_Rules__c WHERE Email_Service_Address__c = : serviceEmailAddress limit 1];
        sobject emailRoutingRuleSobj = new Email_Routing_Rules__c();
        if (emailRoutingRule.size() > 0){
            emailRoutingRuleSobj = (sobject)emailRoutingRule[0];
        }
                
        if(emailRoutingRule.size()>0){
            if(( plainTextEmailBody != null && (plainTextEmailBody.contains(reforgIDa) || plainTextEmailBody.contains(reforgIDb) || plainTextEmailBody.contains(reforgIDc) ) )|| ( emailSubj.contains(reforgIDa) || emailSubj.contains(reforgIDb) || emailSubj.contains(reforgIDc)) ){
            
                if(currentCaseId == null){
                    currentCaseId =  CreateCase(senderAddress, truncatedSubj, truncatedBody, emailRoutingRule[0].Area_on_SR__c, emailRoutingRule[0].Sub_Area_on_SR__c, 'Unassigned', debugcheck,emailRoutingRule[0].Case_Record_Type__c);
                }
                
                //Create related Activity
               // id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId);//fg
               id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId, EmailHasAttachment);
                //Create related Email Message on Case
                id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
                //Create Email Attachments if theres any
                //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
                if (emailBinaryDocs.size() > 0 && emailMsgId != null ){
                    CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
                }
                //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
                if (emailTextDocs.size() > 0 && emailMsgId != null){
                    CreateEmailTextAttachments(emailTextDocs, emailMsgID);
                }
            }
        }
        else{
            string responseAddress = '';
            for (string response :responseEmailMap.keySet()){
                responseAddress = response;
            }
            //create default case
            newCaseId = CreateCase(senderAddress, truncatedSubj, truncatedBody,'Natick - Customer Support','','Unassigned',debugcheck, null);
            //Create related Activity
           // id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, newCaseId);//fg
           id newTaskId = CreateTask(truncatedSubj, truncatedBody, senderAddress, currentCaseId, EmailHasAttachment);
            //Create related Email Message on Case
            id emailMsgId = CreateEmailActivity((String)emailRoutingRuleSobj.get(genset.EmailRoutingRule_Current_ResponseTo__c), ccAddressesString, senderAddress, truncatedSubj, HtmlEmailBody,newTaskId,plainTextEmailBody);
            //Create Email Attachments if theres any
            //Adding check for calling CreateEmailBinaryAttachments to avoid required field missing error when emailMsgId equal to null
            if (emailBinaryDocs.size() > 0 && emailMsgId != null){
                CreateEmailBinaryAttachments(emailBinaryDocs, emailMsgID);
            }
            //Adding check for calling CreateEmailTextAttachments to avoid required field missing error when emailMsgId equal to null
            if (emailTextDocs.size() > 0 && emailMsgId != null){
                CreateEmailTextAttachments(emailTextDocs, emailMsgID);
            }
        }
        
    }
    
    /** HELPER METHODS **/
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 28 May 2013, Last Modified: 26 September 2013
    * @Description: helper method for sending confirmation email to the sender
    * @param: scmSenderAddress - contains email From Address
    * @param: scmForwardingEmailAddress - contains Forwarding Email To Address
    * @param: ccForwardCcAddresses - contains Forwarding CC Addresses
    * @param: scmForwardingDistributor - contains name of Distributor
    * @param: scmEmailSubj - contains Email's Subject
    * @param: emailTemplateName - contains Email template name that will be used
    */
    public static void SendConfirmationMail(String scmSenderAddress, String scmForwardingEmailAddress, List<String> ccForwardCcAddresses, String scmForwardingDistributor, String scmEmailSubj, String emailTemplateName){
        //Send confirmation mail to sender.
        String emailTemplate = emailTemplateName;
        if(emailTemplate!=null){
            emailTemplate = '%'+emailTemplateName+'%';
        }else{
            //emailTemplate = '%Forwarding Rules Auto Reply Email%';//default template incase emailTemplateName is null
        }
        List <EmailTemplate> emailTempList = [SELECT Name, Body, Subject, Id FROM EmailTemplate WHERE Name LIKE :emailTemplate];
        String[] senderadd = new String[]{};
        String emailSubject = 'RE: ' + scmEmailSubj;
        String tempConfirmationBody;
        
        senderadd.add(scmSenderAddress);//@@Test@@ after testing replace the email with scmSenderAddress
        Messaging.Singleemailmessage confirmationMail = new Messaging.Singleemailmessage();
        tempConfirmationBody = emailTempList[0].Body;
        //tempConfirmationBody = tempConfirmationBody.replace('[!Forwarding_Email_Address]', scmForwardingEmailAddress).replace('[!Distributor_Name]', scmForwardingDistributor).replace('[!Email_Subject]', scmEmailSubj);
        if(tempConfirmationBody.contains('[!Forwarding_Email_Address]')){
            tempConfirmationBody = tempConfirmationBody.replace('[!Forwarding_Email_Address]', scmForwardingEmailAddress);
        }
        if(tempConfirmationBody.contains('[!Distributor_Name]')){
            tempConfirmationBody = tempConfirmationBody.replace('[!Distributor_Name]', scmForwardingDistributor);
        }
        if(tempConfirmationBody.contains('[!Email_Subject]')){
            tempConfirmationBody = tempConfirmationBody.replace('[!Email_Subject]', scmEmailSubj);
        }
        
        confirmationMail.setToAddresses(senderadd); 
        confirmationMail.setSubject(emailSubject);
        confirmationMail.setPlainTextBody(tempConfirmationBody);
        //Send Confirmation Email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { confirmationMail });
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
    * @date Original: 28 May 2013, Last Modified: 31 October 2014
    * @Description: helper method for creating Case from Inbound Email
    * @param ccSenderAddress - Email From Address
    * @param caseSubject - Case Subject
    * @param caseDescription - Case Description
    * @param emailRoutingRuleA - Email Routing Rule record's Area
    * @param emailRoutingRuleSA - Email Routing Rule record's Sub Area
    * @param caseSubStatus - Case Sub Status
    * @param debugcheck - returns all debugs on created case
    * @param recordTypeName - Email Routing Rule record's Case Record Type Name
    */
    public static id CreateCase(String ccSenderAddress,String caseSubject,String caseDescription, String emailRoutingRuleA, String emailRoutingRuleSA,String caseSubStatus, String debugcheck,String recordTypeName){
        //Search for matching email in contact object.
        //@@TEST@@ START for testing case can be associated to any contact as long as it has the email.
        Logger.Push('CreateCase', 'EmailToCaseOverride');
        List<Contact> newContactList = new List<Contact>();
        String newCaseDescription;
        newContactList = [SELECT id,Contact_Status__c FROM Contact WHERE Email = :ccSenderAddress ORDER BY CreatedDate DESC LIMIT 1];
        
        id contactId;
        for(Contact cl: newContactList){
            contactId = cl.id;
        }
        
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        //Trigger Auto Response Email
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
        Case newCase = new Case();
        //Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);
        
        if(newContactList.size()==0){
            newCaseDescription = 'Sender\'s email address: '+ccSenderAddress+'\n\n'+caseDescription;
        }else{
            newCaseDescription = caseDescription;
        }
        String areaOnSR = emailRoutingRuleA;
        String subAreaOnSR = emailRoutingRuleSA;

        newCase.Status='Open';
        newCase.SubStatus__c=caseSubStatus;
        newCase.Origin = 'Email';
        newCase.Subject = caseSubject;
        newCase.Description = newCaseDescription;
        newCase.SuppliedEmail = ccSenderAddress;
        newCase.Area__c ='';
        newCase.Sub_Area__c= '';
        newCase.ContactId = contactId;
        if(debugCheck.length() > 32768){
            debugCheck = debugCheck.SubString(0,32700);
        }
        newCase.Test_Email_Debug__c = debugcheck;  
        if(areaOnSR != null && areaOnSR != ''){
            newCase.Area__c = areaOnSR;
            if(subAreaOnSR != null && subAreaOnSR != ''){
                newCase.Sub_Area__c= subAreaOnSR;
            }
        }
        Id caseRecordTypeId = null;
        //check if the record type name is null or empty and retrieve the case record type id
        System.Debug('CreateCase RecordTypeName:'+recordTypeName);
        Logger.Push('CreateCase RecordTypeName:', recordTypeName);
        if(recordTypeName!=null && recordTypeName!=''){
            RecordTypeInfo recordInfo = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName);
            If(recordInfo != null)
            caseRecordTypeId = recordInfo.getRecordTypeId();
        }
        //check if  case recordtypeid is null and set the record type id
        if(caseRecordTypeId!=null)
            newCase.RecordTypeId = caseRecordTypeId;
        
       try{
        insert(newCase);
        }catch(Exception ex){
            System.Debug('Exception:'+ex.getMessage());
            Logger.debugException(ex);
        }
        Logger.Pop();
        return newCase.id;
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 28 May 2013, Last Modified: 21 October 2015
    * @Description: helper method for creating related Task Activities on Case
    * @param ctEmailSubject - Email Subject
    * @param ctEmailBody - Email Body
    * @param ctEmailFrom - Email From Address
    * @param ctCaseId - Id of Case record related to Task
    * @param ctAttachment - email hasattachment flag copied to Task //fg
    * @ KAN updated the code to generate a new 8 digit refID and use it in the check for refID
    */
    public static Id CreateTask(String ctEmailSubject, String ctEmailBody, String ctEmailFrom, id ctCaseId, Boolean ctAttachment){
    
        //Create Activity 
        Case parentCase = new Case();
        //String outboundEmailSubject;
        id relatedCase;
        
        
        //get Reference Organization ID
        String orgID = Userinfo.getOrganizationId();
        String reforgIDa = 'ref:_'+orgID.substring(0,5) + orgID.substring(11,15); //For 9 character ThreadID
        String reforgIDb = 'ref:_'+orgID.substring(0,5) + orgID.substring(10,15); //For 10 character ThreadID
        String reforgIDc = 'ref:_'+orgID.substring(0,5) + orgID.substring(12,15); //For 8 character ThreadID
        
        Id currentCaseId = null;
        boolean isCtEmailBodyContainsReforgIDaOrIDb = false;
        if(ctEmailBody != null){
             isCtEmailBodyContainsReforgIDaOrIDb = ( ctEmailBody.contains(reforgIDa) || ctEmailBody.contains(reforgIDb) || ctEmailBody.contains(reforgIDc) );
        }
        if(isCtEmailBodyContainsReforgIDaOrIDb  ||  ctEmailSubject.contains(reforgIDa) || ctEmailSubject.contains(reforgIDb) || ctEmailSubject.contains(reforgIDc) ){
            String caseThreadId = '';
            if ( ctEmailBody.contains(reforgIDa) || ctEmailBody.contains(reforgIDb) || ctEmailBody.contains(reforgIDc) ){ 
                caseThreadId = ctEmailBody.SubstringBetween('ref:',':ref');
            }
            system.debug('@@caseThreadID1:'+caseThreadID);
            if (caseThreadId == null || caseThreadID == ''){
                if ( ctEmailSubject.contains(reforgIDa) || ctEmailSubject.contains(reforgIDb) || ctEmailSubject.contains(reforgIDc)  ) {
                    caseThreadId = ctEmailSubject.SubstringBetween('ref:',':ref');
                }
            }
            system.debug('@@caseThreadID2:'+caseThreadID);
            try{
                currentCaseId = Cases.getCaseIdFromEmailThreadId(caseThreadId);
            }catch(Exception ex){                
                currentCaseId = null;
            }
            system.debug('@@currentCaseID:'+currentCaseId);
        }
        
        if(ctCaseId==null){
            relatedCase = currentCaseId;    
        }else{
            relatedCase = ctCaseId;
        }
        
        //Get Case record
        List<Case> parentCaseList = [SELECT id, OwnerId, CaseNumber, SubStatus__c,ContactId FROM Case WHERE id =:relatedCase];
        for(Case c: parentCaseList){
            parentCase = c;
        }
        
        //Populate task fields and create new task activity
        Task newTask = new Task();
        newTask.WhatId = relatedCase;
        List<User> userIds = [SELECT id FROM User WHERE id=:parentCase.OwnerId];
        if(userIds.size()>0){
            newTask.OwnerId = parentCase.OwnerId;
        }
        newTask.WhoId = parentCase.ContactId;
        newTask.Type = 'Email';
        
        boolean isEmailbodyContainsDEVID = false;
        boolean isEmailbodyContainsParentCaseNumber = false;
        if(ctEmailBody != null){
             isEmailbodyContainsDEVID = ctEmailBody.contains('DEVID');
             isEmailbodyContainsParentCaseNumber = ctEmailBody.contains(String.valueof(parentcase.CaseNumber));
        }
        
        if (isEmailbodyContainsDEVID ){
            if (parentCase != null){
                if (isEmailbodyContainsParentCaseNumber ){
                    newTask.Category__c = 'Escalation – Request to Dev';
                }   
            }
        }
        //if ( ctEmailBody.contains(String.valueof(parentcase.CaseNumber)) && ctEmailBody.contains('DEVID') ){}
        
        //Set Email Body Subject
        newTask.subject = 'Email: '+ctEmailSubject;
        
        if(newTask.subject.length() > 255)
        {
         newTask.subject = newTask.subject.substring(0,205);
        }
        
        datetime todaysDate = datetime.now();
        date dueDate = todaysDate.date();
        newTask.ActivityDate = dueDate;
        String tempDesc = ctEmailBody;
        boolean isEmailLength =  false;
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        if(ctEmailBody != null){
            isEmailLength = ctemailBody.length() > uehGeneralSettings.Max_Email_Body_Length__c;
        }
        if(ctEmailBody!='' && isEmailLength ){
            tempDesc = ctEmailBody.subString(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-5);
        }
        newTask.Description = tempDesc;
        //ctAttachment = EmailHasAttachment;
        newTask.Has_Attachment__c = ctAttachment;
        
        system.debug('newTask -- '+newTask + ' -- newTask');
        
        // Added By Jaspreet    
       Database.DMLOptions dmlo = new Database.DMLOptions();
       dmlo.EmailHeader.triggerUserEmail  = true;
       database.insert(newTask, dmlo);
        
      //insert newTask;
        
        //if substatus = 'waiting for customer' and an inbound email comes in to associate with the case that doesn't have a DEVid on it and is from the customer associated with the case, then flip the status, if not, leave it as is.
        //If substatus = 'waiting for internal' and an inbound email comes in to associate with the case that HAS a DEVid on it then flip the sub status to in progress
        if ( (parentCase.SubStatus__c == 'Waiting For Internal'  && (ctEmailBody.contains(String.valueof(parentcase.CaseNumber)) && ctEmailBody.contains('DEVID') ) ) || 
             (parentCase.SubStatus__c == 'Waiting For Customer'  && !ctEmailBody.contains('DEVID') ) )
        {
            parentCase.SubStatus__c ='In Progress';
            update parentCase;  
        }
        
        return newTask.id; //return the newly created Task Id.
    }
    
    /**
    * @author Original: Donna Latte, Last Modified: Marc Ouimet
    * @date Original: 19 Nov2013, Last Modified: 2014-08-07
    * @Description: method for creating related Task Activities on Case when Attachment exceeds size limit of 25MB
    * @param ctEmailAttachmentName - Email Attachment Name
    * @param ctCaseId - Id of Case record related to Task
    * @2014-08-06 Marc Ouimet
    *             AtTask 496513 - changed tempDesc string to indicate that incoming attachment is greater than 25MB
    */
    public static Id CreateTaskLargeAttachment(String ctEmailAttachmentName, id ctCaseId){

        //Create Activity 
        id relatedCase = ctCaseId;
        Case parentCase = new Case();
        
        system.debug('@@relatedCase: ' + relatedCase);
      try {
        //Get Case record
        List<Case> parentCaseList = [SELECT id, OwnerId, CaseNumber, SubStatus__c, ContactId FROM Case WHERE id =:relatedCase];
        for(Case c: parentCaseList){
            parentCase = c;
        }
        system.debug('@@ParentCaseID: ' + parentCase.Id);
      }catch (Exception ex){system.debug(ex.getMessage());}
        
        //Populate task fields and create new task activity

       Task newTask = new Task();
       try {
        newTask.WhatId = parentCase.Id;
        List<User> userIds = [SELECT id FROM User WHERE id=:parentCase.OwnerId];
        if(userIds.size()>0){
            newTask.OwnerId = parentCase.OwnerId;
        }
        newTask.WhoId = parentCase.ContactId;
        newTask.Type = 'Email';
        
        //Set Email Body Subject
        newTask.subject = 'Email Attachment Missing: '+ ctEmailAttachmentName;
        
        datetime todaysDate = datetime.now();
        date dueDate = todaysDate.date();
        newTask.ActivityDate = dueDate;
        String tempDesc = 'Email Attachment is greater than 25MB limit.  Attachment Name: ' + ctEmailAttachmentName + ' did not get attached';
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        // making sure the attachment name does not exceed length for Description
        if(ctEmailAttachmentName!='' && ctEmailAttachmentName.length() > uehGeneralSettings.Max_Email_Body_Length__c){
            tempDesc = ctEmailAttachmentName.subString(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-5);
        }
        newTask.Description = tempDesc;
       
        //Added By Jaspreet    
        Database.DMLOptions dmlo = new Database.DMLOptions();
        dmlo.EmailHeader.triggerUserEmail  = true;
        database.insert(newTask, dmlo);
       
       //insert newTask;
        
      }catch (Exception ex){system.debug(ex.getMessage());}
      
       return newTask.id; //return the newly created Task Id.
     }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 28 May 2013, Last Modified: 21 October 2015
    * @Description: helper method for creating related Email Messages to Case
    * @param caToAddress - Email To Address
    * @param caCCAddress - Email CC Address
    * @param caEmailSubject - Email Subject
    * @param caEmailBody - Email Body
    * @param cataskId - Id of Task record related to Email Message
    * @ KAN updated the code to generate a new 8 digit refID and use it in the check for refID
    */
      public static Id CreateEmailActivity(String caToAddress, String caCcAddress, String caFromAddress, String caEmailSubject, String caEmailHtmlBody,id caTaskId,String caEmailTextBody){
        Logger.push('CreateEmailActivity','EmailToCaseOverride');
        Task relatedTask = new Task();
        id relatedCaseId;
        id contactId;
        String orgID = Userinfo.getOrganizationId();
        String reforgIDa = 'ref:_'+orgID.substring(0,5) + orgID.substring(11,15); //For 9 character ThreadID
        String reforgIDb = 'ref:_'+orgID.substring(0,5) + orgID.substring(10,15); //For 10 character ThreadID
        String reforgIDc = 'ref:_'+orgID.substring(0,5) + orgID.substring(12,15); //For 8 character ThreadID
        EmailMessage emailActivity = new EmailMessage();
        //caEmailHtmlBody = '<p>This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address:    TUser1@mathworks.com New email address: test@mathworks.com</p>';
         //Truncate Email HtmlBody if characters exceeds Body length
        String truncatedHtmlBody;
        boolean isEmailBodyLengthGrater =  false;
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        if(caEmailHtmlBody != null){
            isEmailBodyLengthGrater = caEmailHtmlBody.length() > uehGeneralSettings.Max_Email_Body_Length__c;
        }
        if (isEmailBodyLengthGrater){
            String tempBody = caEmailHtmlBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-1000); //Get first 31000 characters on email Body and it will remove the last threadid from email body
            //Creates body with last Thread ID 
            if (caEmailHtmlBody.contains(reforgIDa) || caEmailHtmlBody.contains(reforgIDb) || caEmailHtmlBody.contains(reforgIDc) ){
                string truncatedthreadID = caEmailHtmlBody.substringAfterLast('ref:_');
                truncatedthreadID = truncatedthreadID.substringBefore(':ref'); // will remove text after last thread id (change is for Geck 1056463)
                tempBody+= '... ref:_'+truncatedthreadID+ ':ref '; // Again appends thread id to body
                truncatedHtmlBody = tempBody;
            }
            //Body without Thread ID
            else{
                truncatedHtmlBody = tempBody;
            }
        }
        else{
                truncatedHtmlBody = caEmailHtmlBody ;
        }
        
        Id currentCaseId = null;
        boolean istreunbodyContainsIDaIDb = false;
        if(truncatedHtmlBody != null){
            istreunbodyContainsIDaIDb = truncatedHtmlBody.contains(reforgIDa) || truncatedHtmlBody.contains(reforgIDb)|| truncatedHtmlBody.contains(reforgIDc);
        }
        if( istreunbodyContainsIDaIDb || ( caEmailSubject.contains(reforgIDa) || caEmailSubject.contains(reforgIDb) || caEmailSubject.contains(reforgIDc)) ){
            String caseThreadId = '';
            system.debug('@@EmailBody:'+truncatedHtmlBody);
            system.debug('@@EmailSubject:'+caEmailSubject);
            try{
                if ( istreunbodyContainsIDaIDb ){ 
                    caseThreadId = truncatedHtmlBody.SubstringBetween('ref:',':ref');
                }
                system.debug('@@caseThreadID1:'+caseThreadID);
                if (caseThreadId == null || caseThreadID == ''){
                    if ( caEmailSubject.contains(reforgIDa) || caEmailSubject.contains(reforgIDb) || caEmailSubject.contains(reforgIDc) ) {
                        caseThreadId = caEmailSubject.SubstringBetween('ref:',':ref');
                    }
                }
                system.debug('@@caseThreadID2:'+caseThreadID);
                currentCaseId = Cases.getCaseIdFromEmailThreadId(caseThreadId);
            }catch(Exception ex){                
                currentCaseId = null;
            }
            system.debug('@@currentCaseID:'+currentCaseId);
        }
        
        if(caTaskId==null){
            relatedCaseId = currentCaseId;    
        }else{
            List<Task> newTask = [SELECT WhatId,WhoId FROM Task WHERE id =:caTaskId];
            if(newTask.size()>0){
                for(Task t: newTask){
                    relatedTask = t;
                }
                relatedCaseId = relatedTask.WhatId;
            }
            //emailActivity.RecurrenceActivityId = caTaskId;
            contactId = relatedTask.WhoId;
        }
        
        //Create new EmailMessage
        emailActivity.ActivityId = caTaskId;
        emailActivity.ParentId = relatedCaseId;
        emailActivity.Status = '0';
        emailActivity.FromAddress = caFromAddress;
        emailActivity.ToAddress = caToAddress;
        emailActivity.CcAddress = caCcAddress;
        emailActivity.TextBody = caEmailTextBody;
        emailActivity.HtmlBody = truncatedHtmlBody;
        emailActivity.Subject = caEmailSubject;
        emailActivity.Incoming = true;
        emailActivity.MessageDate = datetime.now();
         //Adding check for insert emailActivity to avoid required field missing error when emailActivity.ParentId equal to null
       if(emailActivity.ParentId != null){
           try{
               insert emailActivity;
           }
           catch(System.DmlException e){
                Logger.debugException('Error in emailActivity insert:'+e);
           }
        }
        else{
             Logger.pop();
            //if emailActivity not inserted then method should return null
            return null;
        }
        Logger.pop();
        return emailActivity.Id;
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 13 June 2013, Last Modified: 07 August 2014
    * @Description: helper method for creating Binary attachments on Email
    * @param emailAttachments list of Attachments to be created on Email Message
    * @param emailMsgId ID of Case related to the attachments
    * Change Log:
    * 2013-Dec-05 Donna Latte
    *             Get EmailMsg Parent Case Id from given EmailMsgId.
    *             Create Task if Email Msg Attachment > 5 MB.
    * 2014-Aug-07 Marc Ouimet
    *             AtTask 496513 - Updated threshold for attachment size to 25 MB; changed maxSize to 26214400 from 5242880.
    */
    public static void CreateEmailBinaryAttachments(list <Messaging.Inboundemail.Binaryattachment> emailAttachments, id emailMsgID){
        Integer maxSize = 26214400;
                
        system.debug([Select ParentID from EmailMessage where id = :emailMsgId limit 1][0].ParentID);
        id emailMsgParentCaseId = [SELECT ParentID FROM EmailMessage WHERE id = :emailMsgID limit 1][0].ParentID;

        if (emailMsgParentCaseId != null){
                system.debug('@@emailMsgParentCaseId: ' + emailMsgParentCaseId);
        }    
        if (emailAttachments != null){
            list <Attachment> AttList = new list <Attachment>();
            for (integer i = 0 ; i < emailAttachments.size() ; i++) {
                Attachment att = new Attachment();
                att.ParentId = emailMsgID;
                att.Name = emailAttachments[i].filename;
                if(emailAttachments[i].body.size() > 0 && emailAttachments[i].body.size() < maxSize ){
                    att.Body = emailAttachments[i].body;
                    AttList.add(att);
                }
                
                if (emailAttachments[i].body.size() > 0 && emailAttachments[i].body.size() >= maxSize) {
                    if (emailMsgParentCaseId != null) {
                        id newTaskId = CreateTaskLargeAttachment(emailAttachments[i].filename, emailMsgParentCaseId);
                        system.debug('@@newTaskId :' + newTaskId);
                    }
                }
            }
          //Create and add attachments to Email Message
          if (AttList.size() > 0){
            insert AttList;
          }
        }
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 24 July 2013, Last Modified: 07 August 2014
    * @Description: helper method for creating Text attachments on Email
    * @param emailAttachments list of Attachments to be created on Email Message
    * @param emailMsgId ID of Case related to the attachments
    * 2013-Dec-05 Donna Latte
    *             Get EmailMsg Parent Case Id from given EmailMsgId.
    *             Create Task if Email Msg Attachment > 5 MB.
    * 2014-Aug-07 Marc Ouimet
    *             Updated threshold for attachment size to 25 MB - changed maxSize to 26214400 from 5242880.
    */
    public static void CreateEmailTextAttachments(list <Messaging.Inboundemail.Textattachment> emailAttachments, id emailMsgID){
        Integer maxSize = 26214400;
        system.debug([Select ParentID from EmailMessage where id = :emailMsgId limit 1][0].ParentID);
        id emailMsgParentCaseId = [SELECT ParentID FROM EmailMessage WHERE id = :emailMsgID limit 1][0].ParentID;
        
        if (emailMsgParentCaseId != null){
                system.debug('@@emailMsgParentCaseId: ' + emailMsgParentCaseId);
        }
        
        if (emailAttachments != null){
            list <Attachment> AttList = new list <Attachment>();
            for (integer i = 0 ; i < emailAttachments.size() ; i++) {
                Attachment att = new Attachment();
                att.ParentId = emailMsgID;
                att.Name = emailAttachments[i].filename;
                if(emailAttachments[i].body.length() > 0 && emailAttachments[i].body.length() < maxSize){
                    att.Body = Blob.valueof(emailAttachments[i].body);
                    AttList.add(att);
                }
                if (emailAttachments[i].body.length() > 0 && emailAttachments[i].body.length() >= maxSize) {
                    if (emailMsgParentCaseId != null) {
                        id newTaskId = CreateTaskLargeAttachment(emailAttachments[i].filename, emailMsgParentCaseId);
                        system.debug('@@newTaskId :' + newTaskId);
                    }
                }
            }
          //Create and add attachments to Email Message
          if (AttList.size() > 0){
            insert AttList;
          }
        }
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 15 July 2013, Last Modified: 31 October 2013
    * @Description: main method for forwarding emails to user's email when change of email has been requested 
    * @param: email - contains email subject, body etc.
    * @param: envelope - contains Sender's email, Recipient's email, etc.
    */
    public static void ForwardRequestToUserEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        
        String emailSubj = 'You have requested to change your salesforce.com email address.';
        String emailTxtBody;
        String emailHTMLBody;
        String username = '';
        if (email.plainTextBody != null){
            emailTxtBody = email.plainTextBody;
            if (emailTxtBody.contains('Previous email address')){
                username = emailTxtBody.substringBetween('User name:','Previous email address');
                username = username.trim();
                system.debug('@@username:'+username);
                system.debug('@@fromaddress:'+email.fromAddress);
                system.debug('@@emailSubj:'+emailSubj);
                system.debug('@@emailTxtBody:'+emailTxtBody);
                forwardEmailRequestPrevious(username, email.fromAddress, emailSubj, emailTxtBody, '');
            }
            if (emailTxtBody.contains('New email address')){ 
                username = emailTxtBody.substringBetween('User name:','New email address:');
                username = username.trim();
            }
        }
        if (email.htmlBody != null){
            emailHTMLBody = email.htmlbody;
            String stripHTMLBody = emailHTMLBody.stripHtmlTags();
            if (stripHTMLBody.contains('Previous email address')){
                username = stripHTMLBody.substringBetween('User name:','Previous email address');
                username = username.trim();
                forwardEmailRequestPrevious(username, email.fromAddress, emailSubj, '', emailHTMLBody);
            }
            if (stripHTMLBody.contains('New email address')){ 
                username = stripHTMLBody.substringBetween('User name:','New email address:');
                username = username.trim();
            }
        }
        
        String emailFrom = email.fromAddress;
        String emailTo = envelope.toAddress;
        String[] forwardToAddresses = new String[]{};
        String senderAddress = emailFrom;
        
        //Retrieve user record matching the Username found on the email's body
        list <User> requesteduser = [Select Id, Name, UserName, Email From User Where UserName = : username limit 1];
        
        if (requesteduser.size() > 0){
            Messaging.Singleemailmessage mailToForward = new Messaging.Singleemailmessage();
            
            //Set To Address with requesteduser's Email
            forwardToAddresses.add(requesteduser[0].Email);
            
            //Set Reply To,Subject, Body of the Email to be forwarded
            //mailToForward.setToAddresses(forwardToAddresses);
            mailToForward.setTargetObjectId(requesteduser[0].Id);
            mailToForward.setSaveAsActivity(false); 
            mailToForward.setReplyTo(senderAddress);
            mailToForward.setSubject(emailSubj);
            if (emailTxtBody != ''){
                //emailTxtBody += '@@RequestedUser:'+requestedUser.size()+'UserName:'+username;
                mailToForward.setPlainTextBody(emailTxtBody);
            }
            if (emailHTMLBody != ''){
                //emailHTMLBody += '@@RequestedUser:'+requestedUser.size()+'UserName:'+username;
                mailToForward.setHTMLBody(emailHTMLBody);
            }
            
            //Forward Email to requested user's  Email (new Email Address)
            system.debug('@@Email has been forwarded to new email address');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailToForward });
        }
        
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 31 October 2013
    * @Description: helper method for forwarding emails to specific email address from Email To case Override Custom setting when To Email is included on the Email Routing Rule custom setting 
    * @param: username - username of the user requesting for email change
    * @param: senderAddress - the To Address
    * @param: emailSubj - Email Subject
    * @param: emailTxtBody -Email body on plain text format
    * @param: emailHTMLBody - Email body on HTML format
    */
    public static void forwardEmailRequestPrevious(String username, String senderAddress, String emailSubj, String emailTxtBody, String emailHTMLBody){
        String[] forwardToAddresses = new String[]{};
        //Retrieve user record matching the Username found on the email's body
        list <User> requestinguser = [Select Id, Name, UserName, Email From User Where UserName = : username limit 1];
        
        if (requestinguser.size() > 0){
            //get general setting custom setting org defaults
            General_Settings__c genset = General_Settings__c.getInstance();
            String erulequery = 'SELECT Email_Service_Address__c, Response_to_DEV_email__c, Response_to_PROD__c, Response_to_TEST_email__c,Case_Record_Type__c FROM Email_Routing_Rules__c';
            list <Sobject> emailRules = database.query(erulequery);
            map <boolean,string> emailforwardmap = new map <boolean,string>();
            string ResponseToAddress; 
            for (Sobject sobj: emailRules){
                //Checks if User's email is included on the Email Routing Rule
                if (requestinguser[0].Email == (String)sobj.get(genset.EmailRoutingRule_Current_ResponseTo__c) ){
                    ResponseToAddress = (String)sobj.get(genset.EmailRoutingRule_Current_ResponseTo__c);
                    system.debug('@@ResponseToAddress:'+ResponseToAddress);
                    Email_To_Case_Override_Setting__c ecoset = Email_To_Case_Override_Setting__c.getInstance();
                    if (ecoset.Forward_Change_Email_Request_Email__c){
                        emailforwardmap.put(true,ecoset.Forwarding_Email_Address__c);
                        //set forward To Address from the Forwarding Email Address of Email To Case Override custom setting
                        forwardToAddresses.add(emailforwardmap.get(true));
                        break;
                    }
                }
            }
            
            //Forwarding Email Address is included on the Email Routing Rule custom setting
            //will either not forward the email to that email or will forward to a specified email based from the Email To Case Override custom setting
            if (ResponseToAddress != null){
                Messaging.Singleemailmessage mailToForward = new Messaging.Singleemailmessage();
                //Set Reply To,Subject, Body of the Email to be forwarded
                if (emailforwardmap.containskey(true)){
                    //Forwards email to specified email address on the custom setting
                    mailToForward.setToAddresses(forwardToAddresses);
                    mailToForward.setSaveAsActivity(false); 
                    mailToForward.setReplyTo(senderAddress);
                    mailToForward.setSubject(emailSubj);
                    if (emailTxtBody != ''){
                        mailToForward.setPlainTextBody(emailTxtBody);
                    }
                    if (emailHTMLBody != ''){
                        mailToForward.setHTMLBody(emailHTMLBody);
                    }
                    //Forward Email to requested user's  Email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailToForward });
                    system.debug('@@Email has been forwarded to specific email address from custom setting: '+forwardToAddresses);  
                }
                
            }
        }
    } 

}