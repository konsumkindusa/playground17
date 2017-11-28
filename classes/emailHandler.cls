/**
* @author Original: Brian Gebler - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 21 May 2013, Last Modified: 07 November 2013
* @Description: Handles all Inbound Emails Email To Case functionality  
*/
global class emailHandler implements Messaging.InboundEmailHandler {
    // Create an InboundEmailResult object for returning the result of the Apex Email Service
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String EmailChangeRequest = 'You have requested to change your salesforce.com email address.';
        
        system.debug('@@envelope toAddress:'+envelope.toAddress);
        system.debug('@@email toAddress:'+email.toAddresses);
        System.Debug('@@email PlainTextBody:'+email.PlainTextBody);
        System.Debug('@@email subject:'+email.Subject);
        //if (email.plainTextBody != null && email.Subject != null && envelope.toAddress != null){
        if (email.Subject != null && envelope.toAddress != null){
       
            //Perform Escalate To Dev on inbound emails
            if (email.plainTextBody != null && String.valueof(email.plainTextBody).contains('[DEVID') && !String.valueOf(email.Subject).contains(EmailChangeRequest)){
                EmailToCaseOverride.EscalateToDevInboundEmail(email, envelope);
            }
            //Forward to User's email address
            else if(String.valueof(email.Subject).contains(EmailChangeRequest)){
                EmailToCaseOverride.ForwardRequestToUserEmail(email, envelope);
            }
            //Email to Case override
            else{
                EmailToCaseOverride.ForwardEmail(email, envelope);
            }
            Email_To_Case_Override_Setting__c ecoset = Email_To_Case_Override_Setting__c.getInstance();
            //Allow capturing of Email Logs on valid emails
            try{
            if (ecoset.Allow_Email_Logs__c){
                Id validemailLogId = CreateEmailLog(email, envelope,true);
                system.debug('@@emailLogId:'+validemailLogId);
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
                        }
                    }
                }
                //Create Email Attachments if theres any
                if (emailBinaryDocs.size() > 0){
                    EmailToCaseOverride.CreateEmailBinaryAttachments(emailBinaryDocs, validemailLogId);
                }
                if (emailTextDocs.size() > 0){
                    EmailToCaseOverride.CreateEmailTextAttachments(emailTextDocs, validemailLogId);
                }
            }
            }catch(Exception ex){
                System.Debug('@@EmailHandler exception:'+ex.getMessage());
            }
        }
        //Log incoming Emails on Email Log custom object
        else{
            try{
            Id emailLogId = CreateEmailLog(email, envelope,false);
            system.debug('@@emailLogId:'+emailLogId);
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
                    }
                }
            }
            //Create Email Attachments if theres any
            if (emailBinaryDocs.size() > 0){
                EmailToCaseOverride.CreateEmailBinaryAttachments(emailBinaryDocs, emailLogId);
            }
            if (emailTextDocs.size() > 0){
                EmailToCaseOverride.CreateEmailTextAttachments(emailTextDocs, emailLogId);
            }
            
        }catch(Exception ex){
             System.Debug('@@EmailHandler exception:'+ex.getMessage());
        }
        }
        
        result.success = true;
        return result;
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 07 November 2013
    * @Description: helper method for capturing email details 
    * @param: email - contains email subject, body etc.
    * @param: envelope - contains Sender's email, Recipient's email, etc.
    * @param: createlog - allows creating of log, used also to check if email is valid or not
    */
    global static Id CreateEmailLog(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, Boolean createlog){
        //Populate Email Log details
        Email_Log__c elog = new Email_Log__c(
            Is_Valid__c = createlog,
            Email_From_Address__c = email.FromAddress,
            Envelope_To_Address__c = envelope.toAddress,
            Envelope_From_Address__c = envelope.FromAddress
        );
        //Get Subject
        if (email.Subject.length() > 255){ 
            elog.Email_Subject__c = email.Subject.substring(0,205);  
        }
        else { elog.Email_Subject__c = email.Subject; }
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Get PlainText Body
        if (email.PlainTextBody != null){
            if (email.PlainTextBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){ 
                string txtBody = email.PlainTextBody; 
                elog.Email_Text_Body__c = txtBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-1000); 
            }
            else { elog.Email_Text_Body__c = email.PlainTextBody; }
        }
        //Get HTML Body
        if (email.htmlBody != null){
            if (email.htmlBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                string htmlBody = email.htmlBody; 
                elog.Email_HTML_Body__c = htmlBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-1000); 
            }
            else { elog.Email_HTML_Body__c = email.htmlBody; }
        }
        //Get Email To Addresses
        if (email.ToAddresses != null){
            elog.Email_To_Addresses__c = '';
            for (String toemail : email.ToAddresses){
                elog.Email_To_Addresses__c+= toemail + '; ';    
            }
        }
        //Get CC Addresses
        if (email.CCAddresses != null){
            elog.Email_CC_Addresses__c = '';
            for (String ccemail : email.CCAddresses){
                elog.Email_CC_Addresses__c+= ccemail + '; ';
            }
        }
        //Create Email Log
        insert elog;
        return elog.id;
    }
}