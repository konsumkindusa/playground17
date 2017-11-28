/**
 * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified by:Archana Lohar - Cloud Sherpas/Mathworks
 * @date Original: 16 July 2015, 
 * @LastModified Date : 16 July 2015,
 * @description : This is an utility Apex class that contains methods for routing to 
                  the appropriate module using toAddress(including dynamic module class instantiation)  

 */
public class UEH_MessageRoutingUtil{
    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 16 July 2015
     *@Last Modified: 16 July 2015
     *@Description: It will accept toAddress and will route to the appropriate 
     *              module based on the To Address of the message so it can be 
     *              processed more specifically by that module..     
     */ 
     public static string getModuleByToAddress(String toAddress){

        Logger.push('getModuleByToAddress','UEH_MessageRoutingUtil');

        String moduleNotFound = 'ModuleNotFound';

        Map<String,String> toAddressToModuleClassNameMap = new Map<String,String>();

        //Get routing table from custom setting
        list<UEH_Recipient_Module_Handler__c> moduleHandlerLst = UEH_Recipient_Module_Handler__c.getAll().Values();
        System.debug('moduleHandlerLst **** ' +moduleHandlerLst);
        //list<UEH_Recipient_Module_Handler__c> moduleHandlerLst = [select id,name,Module_Handler_Class__c,Recipient_Email_Address__c from UEH_Recipient_Module_Handler__c];
        system.debug(moduleHandlerLst+'moduleHandlerLstmoduleHandlerLst');
         
         
        //Check if there are any routing entries
        if(!moduleHandlerLst.isEmpty() && moduleHandlerLst != NULL){

            for(UEH_Recipient_Module_Handler__c modulehandlerRec: moduleHandlerLst){

                if(modulehandlerRec.Recipient_Email_Address__c != '' && modulehandlerRec.Recipient_Email_Address__c != NULL  
                        && modulehandlerRec.Module_Handler_Class__c!='' &&  modulehandlerRec.Module_Handler_Class__c!= NULL){

                    toAddressToModuleClassNameMap.put((modulehandlerRec.Recipient_Email_Address__c).tolowercase(),modulehandlerRec.Module_Handler_Class__c);

                }//if
            }//for

            
            if(toAddressToModuleClassNameMap.containsKey(toAddress.tolowercase())){
                
                Logger.pop();
                
                system.debug(toAddressToModuleClassNameMap.get(toAddress.tolowercase()));
                //if there is a routing entry for the Recipient, return the name of the Apex class that handles messages for that address
                return toAddressToModuleClassNameMap.get(toAddress.tolowercase());

            }
            else{

                Logger.pop();
                return moduleNotFound;
            }
        }
        else{

            Logger.pop();
            return moduleNotFound;

        } 

    }
     /*
     *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks 
     *@Last Modified: Andy Ognenoff - Cloud Sherpas/Mathworks 
     *@Date Original: 24 July 2015
     *@Last Modified: 28 July 2015
     *@Description: It will accept KeyPrefix and will route to the appropriate 
     *              module/handler class  based on theThread Id  of the message so it can be 
     *              processed more specifically by that module/handler class..     
     */
    public static string getModuleByKeyPrefix(String keyPrefix){
        
        Logger.push('getModuleByKeyPrefix','UEH_MessageRoutingUtil');
        //instantiating a map of string as akey
        Map<String,String> keyPrefixToHandlerClassNameMap = new Map<String,String>();
        
        //Get routing handler class table from custom setting
        list<UEH_KeyPrefix_Module_Handler__c> moduleHandlerLst = UEH_KeyPrefix_Module_Handler__c.getAll().Values();
     
        String moduleNotFound = System.Label.UEHRoutingModuleNotFound;
        //Check if there are any routing entries
        if(!moduleHandlerLst.isEmpty() && moduleHandlerLst != NULL){
            
            //iterate over UEH_KeyPrefix_Module_Handler__c custom setting to fill map 
            for(UEH_KeyPrefix_Module_Handler__c modulehandlerRec: moduleHandlerLst){
                
                //check map key and values not null 
                if(modulehandlerRec.Module_Handler_Class__c!= '' && modulehandlerRec.Module_Handler_Class__c!= NULL  
                        && modulehandlerRec.Key_Prefix__c!='' &&  modulehandlerRec.Key_Prefix__c!= NULL){
                        
                            //check the key is available in map  for avoiding  duplicate key in map
                    if(!keyPrefixToHandlerClassNameMap.containsKey(modulehandlerRec.Key_Prefix__c)){
                    keyPrefixToHandlerClassNameMap.put(modulehandlerRec.Key_Prefix__c,modulehandlerRec.Module_Handler_Class__c);
                    }
                }//if
            }//for
            if(keyPrefixToHandlerClassNameMap.containsKey(keyPrefix)){
                    Logger.pop();
                    //if there is a routing handler entry for the keyPrefix, return the name of the Apex Moduler /handler class that handles messages for that thread Id
                    return keyPrefixToHandlerClassNameMap.get(keyPrefix);
            }
            else{
                Logger.pop();
                system.debug(moduleNotFound+'moduleNotFoundmoduleNotFound');
                return  moduleNotFound ;
            }
           
        }
        else{
            Logger.pop();
            return  moduleNotFound ;
        }    
   }
    
   
    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 31 July 2015
     *@Last Modified: 12 August 2015
     *@Description: It will accept email,envelope and module name and It will dynamically instantiate the module class
                    It will call process method of it and will create email log object.
     */ 
    public static void routeMessageToModule(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope,string apexClass){

        Logger.push('routeMessageToModule','UEH_MessageRoutingUtil');
        Id emailLogId;
        
        if(apexClass != 'moduleNotFound'){
        
            try{
                
                //Dynamic Instantiation of ApexClass
                Type typeObj = Type.forName(apexClass);
                UEH_EmailToSObjectModule emailToSobjectModule = (UEH_EmailToSObjectModule)typeObj.newInstance();
                emailToSobjectModule.email = email; //HW 1693609
                emailToSobjectModule.envelope = envelope; //HW 1693609
                
                system.debug(apexClass+'in method');
                
                 //Log Email log object with module name populated 
                emailLogId = UEH_MessageLoggingUtils.CreateInboundEmailLog(email,envelope,'Accepted',apexClass);
                
                //Call processMessage method 
                //emailToSobjectModule.processMessage(email,envelope); //HW 1693609
				System.enqueueJob(emailToSobjectModule); //HW 1693609 
				                
				//Log Email log object with module name populated 
                UEH_MessageLoggingUtils.UpdateInboundEmailLog(emailLogId,'Accepted:Routed');
                
            }
            Catch(Exception ex){
            
               If (emailLogId != null) {  
            	   //Log Email log object with module name populated 
                	UEH_MessageLoggingUtils.UpdateInboundEmailLog(emailLogId,'Accepted:Failed to Instantiate');
            	} 
            	else {       
                //Log Email log object with module name populated 
	                UEH_MessageLoggingUtils.CreateInboundEmailLog(email,envelope,'Accepted:Failed to Instantiate',apexClass);
                }
                Logger.debugException(ex.getMessage());
                Logger.Pop();
               
            }
        
        }
        else{
            
           //Log Email log object when module not found in custom setting
           UEH_MessageLoggingUtils.CreateInboundEmailLog(email,envelope,'Accepted : moduleNotFound',''); 
            
        }
        Logger.pop();
    }
    
     
    

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 24 Nov 2015
     *@Last Modified: 24 Nov 2015
     *@Description: It will accept the email , envelop and Forwarding_Rule__c object and It will forward Email. 
     */ 
    public static void forwardEmailToDistributor(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, String[] forwardToaddress){

        Logger.push('forwardEmail','UEH_MessageLoggingUtils');    


        Messaging.Singleemailmessage mailToForward = new Messaging.Singleemailmessage();

        //Set ToAddress of the Email to be forwarded
        mailToForward.setToAddresses(forwardToaddress);

        //Set CC Address of the Email to be forwarded
        String[] forwardCcAddresses = new String[]{};
        if(email.ccAddresses!=null){
            for(String e: email.ccAddresses){
                forwardCcAddresses.add(e);
            }
        }

        mailToForward.setCcAddresses(forwardCcAddresses);

        //set ReplyTo Address of the Email to be forwarded
        mailToForward.setReplyTo(email.fromAddress);

        //set Subject of the Email to be forwarded
        mailToForward.setSubject(email.Subject);

        //set HtmlBody of the Email to be forwarded
        if (email.HtmlBody !=null){
            mailToForward.setHtmlBody(email.HtmlBody );
        }
        else if (email.PlainTextBody !=null){
            mailToForward.setPlainTextBody(email.PlainTextBody);
        }
        else {
            mailToForward.setPlainTextBody('');
        }

        mailToForward.setSenderDisplayName(email.fromAddress);

        //Email Binary Attachments (PDF, excel, images, etc)
        list <Messaging.Inboundemail.Binaryattachment> emailBinaryDocs = new list <Messaging.Inboundemail.Binaryattachment>();
        list <Messaging.EmailFileAttachment> emailattachments = new list <Messaging.EmailFileAttachment>();
        if (email.binaryAttachments != null){ 
            emailBinaryDocs = email.binaryAttachments;
            for (Messaging.InboundEmail.BinaryAttachment binatt : emailBinaryDocs){
                Messaging.EmailFileAttachment efatt = new Messaging.EmailFileAttachment();
                if(binatt.Body.size() <= 5000000){
                    efatt.setBody(binatt.Body);
                    efatt.setFileName(binatt.filename);
                    efatt.setContentType(binatt.mimeTypeSubType+';charset=UTF-8');
                    emailattachments.add(efatt);
                }
            }
        }
        
        if(email.textAttachments!=null){
            // Save attachments, if any
            for (Messaging.Inboundemail.TextAttachment  tAttachment :email.textAttachments) { 
                
                Messaging.EmailFileAttachment efatt = new Messaging.EmailFileAttachment();
                //TODO: Needs check for file size
                if(tAttachment.Body.Length() <= 5000000){
                    
                    efatt.setBody(Blob.valueOf(tAttachment.Body));
                    efatt.setFileName(tAttachment.filename);
                    efatt.setContentType(tAttachment.mimeTypeSubType+';charset=UTF-8');
                    emailattachments.add(efatt);
                      
                }
            }
        }

        if (emailattachments.size() > 0){
            mailToForward.setFileAttachments(emailattachments);
        }

        try{
            //Forward the email 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailToForward });

        }catch(Exception Ex) {

            Logger.debug('There is an exception while sending an email'+Ex.getMessage());
            Logger.pop();
        }

        Logger.pop();

    }


    /**
     * @author Original: Archana Lohar  - Cloud Sherpas/Mathworks, Last Modified:  Archana Lohar  - Cloud Sherpas/Mathworks
     * @date Original: 24 Nov 2015, Last Modified: 24 Nov 2015
     * @Description: helper method for sending confirmation email to the sender
     * @param: scmSenderAddress - contains email From Address
     * @param: scmForwardingEmailAddress - contains Forwarding Email To Address
     * @param: ccForwardCcAddresses - contains Forwarding CC Addresses
     * @param: scmForwardingDistributor - contains name of Distributor
     * @param: scmEmailSubj - contains Email's Subject
     * @param: emailTemplateName - contains Email template name that will be used
     */
    public static void SendConfirmationMail(List<String> scmSenderAddress, String scmForwardingEmailAddress, List<String> ccForwardCcAddresses, String scmForwardingDistributor, String scmEmailSubj, String emailTemplateName){

        Logger.push('SendConfirmationMail','UEH_MessageLoggingUtils');    

        //Send confirmation mail to sender.
        String emailTemplate = emailTemplateName;
        if(emailTemplate!=null){
            emailTemplate = '%'+emailTemplateName+'%';
        }

        List <EmailTemplate> emailTempList = [SELECT Name, Body, Subject, Id FROM EmailTemplate WHERE Name LIKE :emailTemplate];

        String emailSubject = 'RE: ' + scmEmailSubj;
        String tempConfirmationBody;
        
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

        confirmationMail.setToAddresses(scmSenderAddress); 
        confirmationMail.setSubject(emailSubject);
        confirmationMail.setPlainTextBody(tempConfirmationBody);

        try{
            //Forward the email 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { confirmationMail });

        }catch(Exception Ex) {

            Logger.debug('There is an exception while sending an email'+Ex.getMessage());
            Logger.pop();
        }

        Logger.pop();
    } 
    
    /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 Dec 2015, Last Modified: 7 Dec 2015
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
                forwardEmailRequestPrevious(username, email.fromAddress, emailSubj, emailTxtBody, '');
            }
            if (emailTxtBody.contains('New email address')){ 
                username = emailTxtBody.substringBetween('username','New email address:');
                username = username.trim();
                username = username.substringBeforeLast('.');
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
                username = stripHTMLBody.substringBetween('username','New email address:');
                username = username.trim();
                username = username.substringBeforeLast('.');
            }
        }
        
        String emailFrom = email.fromAddress;
        String emailTo = envelope.toAddress;
        String[] forwardToAddresses = new String[]{};
        String senderAddress = emailFrom;
        
        System.Debug('User name::'+username);
        //Retrieve user record matching the Username found on the email's body
        list <User> requesteduser = [Select Id, Name, UserName, Email From User Where UserName = : username limit 1];
        System.Debug('requested User::'+requesteduser);
        if (requesteduser.size() > 0){
            
            Messaging.Singleemailmessage mailToForward = new Messaging.Singleemailmessage();
            
            //Set To Address with requesteduser's Email
            forwardToAddresses.add(requesteduser[0].Email);
            
            //Set Reply To,Subject, Body of the Email to be forwarded
            mailToForward.setTargetObjectId(requesteduser[0].Id);
            mailToForward.setSaveAsActivity(false); 
            mailToForward.setReplyTo(senderAddress);
            mailToForward.setSubject(emailSubj);
            
            if (emailTxtBody != ''){
                mailToForward.setPlainTextBody(emailTxtBody);
            }
            if (emailHTMLBody != ''){
                mailToForward.setHTMLBody(emailHTMLBody);
            }
            
            //Forward Email to requested user's  Email (new Email Address)
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailToForward });
        }       
    }
    
        /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 December 2015
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
                }              
            }
        }
    } 
}