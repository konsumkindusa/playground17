/*
 *@author Original:Archana Lohar - Cloud Sherpas/Mathworks, Last Modified:Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 26 June 2015, Last Modified: 6 August 2015
 *@description:This is a Central Universal class for handling email services 
 */
global class UEH_UniversalEmailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Logger.push('handleInboundEmail','UEH_UniversalEmailHandler ');
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        
        Boolean isValid = false;
        String threadId;
        String EmailChangeRequest = System.Label.EmailChangeRequest;
        
        try{
        
            //Check if Email Subject or Body contains Thread Id.
            if (UEH_MessageParsingUtils.containsThreadId(email.subject) || (email.PlainTextBody!= null && UEH_MessageParsingUtils.containsThreadId(email.PlainTextBody))
            || (email.htmlBody!= null && UEH_MessageParsingUtils.containsThreadId(email.htmlBody))) {
    
                threadId = UEH_MessageParsingUtils.getThreadID(email.subject);
                System.Debug('ThreadID::'+threadId);
                //Check if there is thread id in subject else get from body.
                if (threadId == 'ref::ref') {
                    
                    if(email.plainTextBody!= null){
                        threadId = UEH_MessageParsingUtils.getThreadID(email.PlainTextBody);
                        System.Debug('ThreadId PT::'+threadId);
                     }
                     else if(email.htmlBody!= null){
                         threadId = UEH_MessageParsingUtils.getThreadID(email.htmlBody);
                         System.Debug('ThreadId HT::'+threadId);
                     } 
                      
                }
                System.Debug('ThreadId Before is valid::'+threadId);
                if(threadId != 'ref::ref'){
                    //Check if Thread Id is Valid
                    isValid = UEH_MessageCheckingUtils.isValidThreadId(threadId);
                    System.Debug('Is valid ThreadId ::'+isValid);
                }
            }  
            
              
            //Check if Thread Id is valid
            if(isValid) {
    
                //Route message to appropriate module
                UEH_MessageRoutingUtil.routeMessageToModule(email, envelope, UEH_MessageRoutingUtil.getModuleByKeyPrefix(UEH_MessageParsingUtils.getKeyPrefixFromThreadId(threadId)));
    
            }
            else{
                
                 //Forward to User's email address
                if(email.Subject!= null && String.valueof(email.Subject).contains(EmailChangeRequest)){
                    UEH_MessageRoutingUtil.ForwardRequestToUserEmail(email, envelope);
                }
                else{
                    //Check if the sender of the email is in the org's whitelist
                    Boolean isInWhitelist = UEH_MessageCheckingUtils.isPresentInSenderWhiteList(email.FromAddress);
        
                    //If sender of the email is in the org's whitelist
                    if (isInWhitelist) {
                       
                        //Route message to appropriate module
                        UEH_MessageRoutingUtil.routeMessageToModule(email, envelope, UEH_MessageRoutingUtil.getModuleByToAddress(envelope.ToAddress));
        
                    } else { //If sender of the email is not in the org's whitelist
        
                        //Check if the sender of the email is in the org's sender blacklis
                        Boolean isInBlacklist = UEH_MessageCheckingUtils.isPresentInSenderBlackList(email.FromAddress);
        
                        //If the sender of the email is in the org's sender blacklist               
                        if (isInBlacklist) {
        
                            //Check if blacklist logging is enabled
                            if (uehGeneralSettings.Enable_Blacklist_Logging__c) {
        
                                //Sender is blacklisted, log the message as blocked and stop
                                UEH_MessageLoggingUtils.CreateInboundEmailLog(email, envelope, 'Blocked:Sender Blacklist', '');
        
                            }
                        } else if (UEH_MessageCheckingUtils.isInboundEmailSpam(email)) {
        
                            //Log the message as blocked and stop
                            UEH_MessageLoggingUtils.CreateInboundEmailLog(email, envelope, 'Blocked:potential spam', '');
        
                        } else {
        
                            //Route message to appropriate module
                            UEH_MessageRoutingUtil.routeMessageToModule(email, envelope, UEH_MessageRoutingUtil.getModuleByToAddress(envelope.ToAddress));
        
                        }       
                    }
                }
            }     
        }
        
        catch(exception ex){
        
          logger.debugException(ex);  
          Logger.pop();       
          system.debug(ex.getMessage()+'****ex*****'+ex.getStackTraceString());        
          //Log the message as Failed Email
          UEH_MessageLoggingUtils.CreateInboundEmailLog(email, envelope,'Failed Email',threadId+'' );

        }
        
        result.success = true;
        Logger.pop();
        return result;
        
    }

}