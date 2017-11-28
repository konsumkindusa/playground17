/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original: 3 July 2015, Last Modified:14 Oct 2015
 *@description :This is an utility class that contains utility methods for creating and retrieving email messages from a log. 
 */

public class UEH_MessageLoggingUtils{

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 3 July 2015
     *@Last Modified: 14 Oct 2015
     *@Description: helper method for capturing email details and create Email log Object.
     *@param: email - contains email subject, body etc.
     *@param: envelope - contains Sender's email, Recipient's email, etc.
     *@param: createlog - Used also to check whether email is Acceped or block     
     *@param: moduleName - module name to populate on email log object.  
     */ 
    public static Id CreateInBoundEmailLog(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope,String status,String moduleName){

        Logger.push('CreateInBoundEmailLog','UEH_MessageLoggingUtils');

        List<Attachment> attachObjList = new List<Attachment>();

        //Populate Email Log Details
        UEH_Inbound_Email_Log__c elog = new UEH_Inbound_Email_Log__c(
                UEH_Email_From_Address__c = email.FromAddress,
                UEH_Envelope_To_Address__c = envelope.toAddress,
                UEH_Envelope_From_Address__c = envelope.FromAddress,
                UEH_Status__c=status,
                Module_Name__c=moduleName

                );

        //Get Subject
        if (email.Subject!=null){ 
            if(email.Subject.length()>255){
                elog.UEH_Email_Subject__c = UEH_MessageParsingUtils.truncateSubject(email.Subject);  
            }
            else{
                elog.UEH_Email_Subject__c=email.Subject; 
            }
        }

        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Get PlainText Body
        if (email.PlainTextBody != null){
            if (email.PlainTextBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                elog.UEH_Email_Text_Body__c = UEH_MessageParsingUtils.truncateBody(email.PlainTextBody); 
                elog.UEH_Email_Plain_Text_Body_Is_Truncated__c = true;
            }
            else{
                elog.UEH_Email_Text_Body__c=email.PlainTextBody; 
            }
        }

        //Get HTML Body
        if (email.htmlBody != null){
            if (email.htmlBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                elog.UEH_Email_HTML_Body__c = UEH_MessageParsingUtils.truncateBody(email.htmlBody); 
                elog.UEH_Email_Html_Body_Is_Truncated__c = True;
            }
            else { 
                elog.UEH_Email_HTML_Body__c= email.htmlBody; 
            }
        }

        //Get Email To Addresses
        if (email.ToAddresses != null){
            elog.UEH_Email_To_Addresses__c = '';
            for (String toemail : email.ToAddresses){
                elog.UEH_Email_To_Addresses__c += toemail + '; ';    
            }
        }

        //Get CC Addresses
        if (email.CCAddresses != null){
            elog.UEH_Email_CC_Addresses__c = '';
            for (String ccemail : email.CCAddresses){
                elog.UEH_Email_CC_Addresses__c += ccemail + '; ';
            }
        }

        //Get From Name
        if(email.fromName != null){        
            elog.UEH_Email_from_Name__c = email.fromName;
        }

        //Get Header
        if(email.headers != null){
            elog.UEH_Email_Header__c = '';
            for(Messaging.InboundEmail.Header emailhead : email.headers){
                elog.UEH_Email_Header__c +='['+emailhead.name+' | '+emailhead.value+']'+'&'+'\n';
            }
        } 

        // Get In Reply 
        if(email.inReplyTo != null){
            elog.UEH_Email_Reply_To__c = email.inReplyTo;
        }

        //Get Message Id 
        if(email.messageId != null){
            elog.UEH_Email_Message_Id__c = email.messageId;
        }  

        // Get Reference
        if (email.references!=null){

            String referencesString = String.join(email.references, ',');

            if(referencesString.length()>255){
                elog.UEH_Email_References__c = UEH_MessageParsingUtils.truncateSubject(referencesString);  
            }
            else{
                elog.UEH_Email_References__c = referencesString;  
            }
        }

        // Get reply To
        if(email.replyTo != null){
            elog.UEH_Email_Reply_To__c = email.replyTo;
        }

        //Create Email Log
        try{
            insert elog;
        }
        catch(DMLException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                //Process exception here
                Logger.debugException('Error in Creating Email Log Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                Logger.pop();
            }
        }

        if(email.textAttachments!=null){
            // Save attachments, if any
            for (Messaging.Inboundemail.TextAttachment  tAttachment :email.textAttachments) { 
                //TODO: Needs check for file size
                if(tAttachment.Body.Length() <= 5000000){
                    Attachment attachment = new Attachment();
                    attachment.Name = tAttachment.fileName;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachment.ParentId = elog.Id;
                    attachObjList.add(attachment);  

                }
            }
        }

        if(email.binaryAttachments!=null){
            for (Messaging.Inboundemail.BinaryAttachment  bAttachment :email.binaryAttachments) {
                //TODO: Needs check for file size
                if(bAttachment.body.size() <= 5000000){
                    Attachment attachment = new Attachment(); 
                    attachment.Name = bAttachment.fileName;
                    attachment.Body = bAttachment.body;
                    attachment.ParentId = elog.Id;
                    attachObjList.add(attachment);
                }
            }
        }
        //Check the Attachments Size, if it is greater then 25MB.
        Integer attachSize = 0;
        for(Attachment attachObj : attachObjList){
            attachSize += attachObj.body.size(); 
        }

        if(attachSize <= 25000000){
            try{

                insert attachObjList;
            }
            catch(DMLException ex){

                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    //Process exception here
                    Logger.debugException('Error in Creating Attachment Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                    Logger.pop();
                }
            }
        }
        Logger.pop(); 
        return elog.id;        

    }//End of CreateInBoundEmailLog Method

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Date Original: 9 July 2015
     *@Last Modified: 14 Oct 2015
     *@Description: helper method for getting Map of Inbound Email Object and Envelope from set of email log ids
     */ 
    public static Map<Id,UEH_EmailEnvelopeWrapper> getEmailMapFromLogLst(set<Id> emailLogIdsSet){

        Logger.push('getEmailMapFromLogLst','UEH_MessageLoggingUtils');
        //List to save the UEH_Inbound_Email_Log__c record.
        List<UEH_Inbound_Email_Log__c> logList = new List<UEH_Inbound_Email_Log__c>();
        //Map to save the UEH_Inbound_Email_Log__c record Field to Wrapper Class Property. 
        Map<Id,UEH_EmailEnvelopeWrapper> emailWrapperMap = new Map<Id,UEH_EmailEnvelopeWrapper>();
        //List to save the attachment related to the Record.
        List<Attachment> attachmentsLst = new List<Attachment>();

        Map<Id, List<Attachment>> inboundObjMap = new Map<Id, List<Attachment>>();

        //Query to retrieve all the Fields in UEH Inbound Log Object.
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.UEH_Inbound_Email_Log__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String query = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String fieldName = s.getDescribe().getName();

            query += fieldName + ',';
        }

        query = query.subString(0, query.length() - 1);

        query += ' FROM UEH_Inbound_Email_Log__c WHERE id in : emailLogIdsSet';

        logList = Database.query(query);

        //Getting all the Attachment to the UEH Inbound Email Log.
        attachmentsLst = [SELECT Id, ParentId, Name, Body FROM Attachment Where ParentId IN: logList];

        //Filling the Map having Id of Object with List of Attachment.    
        for(Attachment attachmentObj : attachmentsLst){
            if(!inboundObjMap.containsKey(attachmentObj.ParentId)){
                inboundObjMap.put(attachmentObj.ParentId, new List<Attachment> {attachmentObj});
            }
            else{
                inboundObjMap.get(attachmentObj.ParentId).add(attachmentObj);
            }
        }

        for(UEH_Inbound_Email_Log__c emailLogObj : logList){

            UEH_EmailEnvelopeWrapper wrapperObj = new UEH_EmailEnvelopeWrapper();
            wrapperObj.emailFromAddress = emailLogObj.UEH_Email_From_Address__c;
            wrapperObj.emailToAddresses = emailLogObj.UEH_Email_To_Addresses__c;
            wrapperObj.envelopeToAddress = emailLogObj.UEH_Envelope_To_Address__c;
            wrapperObj.envelopeFromAddress = emailLogObj.UEH_Envelope_From_Address__c;
            wrapperObj.emailSubject = emailLogObj.UEH_Email_Subject__c;
            wrapperObj.emailPlainTextBody = emailLogObj.UEH_Email_Text_Body__c;
            wrapperObj.emailHtmlBody = emailLogObj.UEH_Email_HTML_Body__c;
            wrapperObj.emailCCAddresses = emailLogObj.UEH_Email_CC_Addresses__c;
            wrapperObj.emailFromName = emailLogObj.UEH_Email_from_Name__c;
            wrapperObj.emailHeaderList = emailLogObj.UEH_Email_Header__c.split('&');
            wrapperObj.emailMessageId = emailLogObj.UEH_Email_Message_Id__c;
            wrapperObj.emailInReplyTo = emailLogObj.UEH_Email_in_Reply_To__c;
            wrapperObj.emailReferences = emailLogObj.UEH_Email_References__c;
            wrapperObj.emailReplyTo = emailLogObj.UEH_Email_Reply_To__c;
            if(inboundObjMap.containsKey(emailLogObj.Id)){
                wrapperObj.emailAttachment = inboundObjMap.get(emailLogObj.Id);
            }


            emailWrapperMap.put(emailLogObj.id,wrapperObj);
        }

        Logger.pop();
        return emailWrapperMap;
    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 12 August 2015
     *@Last Modified: 14 Oct 2015
     *@Description: helper method for Creating Attachment 
     *@param: email - contains Attchment.
     *@param: objId - Id of object on which Attachmnets will be created.
     */ 
    public static void createAttachments(Messaging.InboundEmail email,Id objId,Id ParentId,id contactId,id OwnerId){

        Logger.push('createAttachments','UEH_MessageLoggingUtils');

        List<Attachment> attachObjList = new List<Attachment>();
        
        Integer maxSizeAttachment = 26214400;

        if(email.textAttachments!=null){
            // Save attachments, if any
            for (Messaging.Inboundemail.TextAttachment  tAttachment :email.textAttachments) { 
                //TODO: Needs check for file size
                if(tAttachment.Body.Length() <= maxSizeAttachment){

                    Attachment attachment = new Attachment();
                    attachment.Name = tAttachment.fileName;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachment.ParentId = objId;
                    String emailContentType = tAttachment.mimeTypeSubType +';charset=UTF-8';
                    attachment.ContentType = emailContentType;
                    attachObjList.add(attachment);  
                }
                else{
                    
                     id newTaskId = CreateTaskForLargeAttachment(tAttachment.filename,ParentId,contactId,OwnerId);
                }
            }
        }

        if(email.binaryAttachments!=null){
            for (Messaging.Inboundemail.BinaryAttachment  bAttachment :email.binaryAttachments) {
                //TODO: Needs check for file size
                if(bAttachment.body.size() <= maxSizeAttachment){
                    Attachment attachment = new Attachment(); 
                    attachment.Name = bAttachment.fileName;
                    attachment.Body = bAttachment.body;
                    attachment.ParentId = objId;
                    String emailContentType = bAttachment.mimeTypeSubType +';charset=UTF-8';
                    attachment.ContentType = emailContentType;
                    attachObjList.add(attachment);
                }
                else{
                    
                     id newTaskId = CreateTaskForLargeAttachment(bAttachment.filename,ParentId,contactId,OwnerId);
                }
            }
        }


        //Check the Attachments Size, if it is greater then 25MB.
        Integer attachSize = 0;
        for(Attachment attachObj : attachObjList){
            attachSize += attachObj.body.size(); 
        }

        if(attachSize <= maxSizeAttachment){         
            try{
                insert attachObjList;
            }
            catch(DMLException ex){

                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    //Process exception here
                    Logger.debugException('Error in Creating Attachment Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                    Logger.pop();
                }
            }     
        }
        else{
            id newTaskId = CreateTaskForLargeAttachment('Exceeded the max attachments size limit',ParentId,contactId,OwnerId);
            
        }
    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Shweta Shanbhag - Mathworks 
     *@Date Original: 20 August 2015
     *@Last Modified: 2 Feb 2016
     *@Description: helper method for Creating Task 
     *@param: email
     *@param: Task what id
     *@param: Task OwnerId
     *@param: Task who Id.
     */ 
    public static Id createTask(Messaging.InboundEmail email,Id whatId,Id whoid,id ownerId){

        Logger.push('createTask','UEH_MessageLoggingUtils');
       
        System.debug('UtilityHelper.ObjectTypeOf(whatId))');
        
        List<User> partProgramUserLst = new List<User>();

        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();

        If(String.valueOf(UtilityHelper.ObjectTypeOf(ownerId)) == 'Group'){
            partProgramUserLst = [select id,name from user where Alias=:uehGeneralSettings.Partner_Program_User__c];

        }
        //Intialize task object
        Task newTask = new Task();
        
        //set Parent Id
        newTask.WhatId = whatId;


        //set owner Id
        if(!partProgramUserLst.isEmpty() && String.valueOf(UtilityHelper.ObjectTypeOf(ownerId)) == 'Group'){
            newTask.OwnerId = partProgramUserLst[0].id;
        }
        else{
          newTask.OwnerId = ownerId;    
        }

        newTask.Type = 'Email';

        If(whoid!=null){
            //Set who id
            newTask.WhoId = whoid;
        }

        //Set Email Body Subject
        if(email.subject!=null){
            if(email.subject.length() > 255)
            {
                newTask.subject = email.subject.substring(0,205);
            }
            else{  
                newTask.subject = 'Email: '+email.subject;                      
            }
        }
        //Set ActivityDate
        datetime todaysDate = datetime.now();
        date dueDate = todaysDate.date();
        newTask.ActivityDate = dueDate;

        //set Description
        if(email.PlainTextBody!=null){
            if(email.PlainTextBody.length() > 32000){
                newTask.Description = email.PlainTextBody.subString(0,32000);
            }
            else{
                newTask.Description = email.PlainTextBody;
            }
        }

        //set task status to completed
        newTask.Status = 'Completed'; 
        
        String ctEmailBody;
       //SS 02/01/2016 - 1319805 Added logic to populate html body in the string if plaintextbody is empty so that the logic on Case is executed
        if(String.isNotEmpty(email.PlainTextBody))
            ctEmailBody = email.PlainTextBody;
        else if(String.isNotEmpty(email.HtmlBody))
            ctEmailBody = email.HtmlBody;
        
       // String ctEmailBody = email.PlainTextBody;
        
        if (String.valueOf(UtilityHelper.ObjectTypeOf(whatId)) == 'Case' && ctEmailBody!=null ){
        
            if(email.textAttachments!=null || email.binaryAttachments!=null){
                newTask.Has_Attachment__c = true;
            }
                
            
            newTask.Status = 'In Progress';
            
            //Get Case record
            List<Case> parentCaseList = [SELECT id, CaseNumber, SubStatus__c FROM Case WHERE id =:whatId];
                
            if (Whatid != null){
                if (ctEmailBody.contains(String.valueof(parentCaseList[0].CaseNumber)) && ctEmailBody.contains('DEVID')){
                    newTask.Category__c = 'Escalation – Request to Dev';
                }   
            }

            if ( (parentCaseList[0].SubStatus__c == 'Waiting For Internal'  && (ctEmailBody.contains(String.valueof(parentCaseList[0].CaseNumber)) && ctEmailBody.contains('DEVID') ) ) || 
                    (parentCaseList[0].SubStatus__c == 'Waiting For Customer'  && !ctEmailBody.contains('DEVID') ) )
            {
                parentCaseList[0].SubStatus__c ='In Progress';
                
                System.debug('parentCaseList[0].SubStatus__c' +parentCaseList[0].SubStatus__c);

                try{

                    update parentCaseList[0];     

                }catch (System.DmlException e) {

                    // Capture Dml exception here
                    Logger.debugException('DmlException:'+e.getDmlMessage(0)+ 'for ID:'+e.getDmlId(0)); 
                    System.debug(e.getDmlMessage(0)+'e.getDmlMessage(0)');
                    Logger.pop();

                }
            }
        }
        
        try{
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail  = true;
            database.insert(newTask, dmlo);
            //insert newTask;             
            
        }

        catch (System.DmlException e) {

            // Capture Dml exception here
            Logger.debugException('DmlException:'+e.getDmlMessage(0)+ 'for ID:'+e.getDmlId(0)); 
            System.debug(e.getDmlMessage(0)+'e.getDmlMessage(0)');          
            Logger.pop() ;     

        }

        Logger.pop();  
        return newTask.id;

    }
    
  /**
    * @author Original: Archana Lohar, Last Modified: Archana Lohar
    * @date Original: 2 Dec 2015, Last Modified: 14 December 2015
    * @Description: method for creating related Task Activities on Case when Attachment exceeds size limit of 25MB
    * @param ctEmailAttachmentName - Email Attachment Name
    * @param ctCaseId - Id of Case record related to Task
    */
    public static Id CreateTaskForLargeAttachment(String ctEmailAttachmentName,id caseId,id ContactId,id ownerid){

       Logger.push('CreateTaskForLargeAttachment','UEH_MessageLoggingUtils');
       Task newTask = new Task();
       try{
           
            newTask.WhatId = caseId;
            newTask.OwnerId = ownerid;
            newTask.WhoId = ContactId;
            newTask.Type = 'Email';
            
            //Set Email Body Subject
            newTask.subject = 'Email Attachment Missing: '+ ctEmailAttachmentName;
            
            datetime todaysDate = datetime.now();
            date dueDate = todaysDate.date();
            newTask.ActivityDate = dueDate;
            String tempDesc = 'Email Attachment is greater than 25MB limit.  Attachment Name: ' + ctEmailAttachmentName + ' did not get attached';
            
            // making sure the attachment name does not exceed length for Description
            if(ctEmailAttachmentName!='' && ctEmailAttachmentName.length() > 32000){
                tempDesc = ctEmailAttachmentName.subString(0,31500);
            }
            
            newTask.Description = tempDesc;
           
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail  = true;
            database.insert(newTask, dmlo);
           
         }catch (Exception ex){ 
            // Capture Dml exception here
            Logger.debugException('DmlException:'+ex.getDmlMessage(0)+ 'for ID:'+ex.getDmlId(0));        
            Logger.pop() ; 
         }
      
         Logger.pop(); 
         return newTask.id; //return the newly created Task Id.
     }
    

    /**
     * @author Original: Archana Lohar- Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 9 Nov 2015, Last Modified: 14 December 2015
     * @Description: helper method for creating related Email Messages to Case
     * @param email - Email Object
     * @param envelope - Envelope Object
     * @param caseId - case object id
     * @param taskId - Id of Task record related to Email Message
     */
    public static Id CreateEmailActivity(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope,Id caseId,Id taskId){

        Logger.push('CreateEmailActivity','UEH_MessageLoggingUtils');

        EmailMessage emailActivity = new EmailMessage();

        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Get HTML Body
        if (email.htmlBody != null){
            if (email.htmlBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                emailActivity.HtmlBody = UEH_MessageParsingUtils.truncateBody(email.htmlBody); 
            }
            else { 
                emailActivity.HtmlBody = email.htmlBody; 
            }
        }

        //Get PlainText Body
        if (email.PlainTextBody != null){
            if (email.PlainTextBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                emailActivity.TextBody = UEH_MessageParsingUtils.truncateBody(email.PlainTextBody); 
            }
            else{
                emailActivity.TextBody = email.PlainTextBody; 
            }
        }

        //Get Subject
        if (email.Subject!=null){ 
            if(email.Subject.length()>255){
                emailActivity.Subject = UEH_MessageParsingUtils.truncateSubject(email.Subject);  
            }
            else{
                emailActivity.Subject = email.Subject; 
            }
        }

        //Get Email To Addresses
        if (email.ToAddresses != null){
            emailActivity.ToAddress = '';
            for (String toemail : email.ToAddresses){
                emailActivity.ToAddress+= toemail + ',';    
            }
        }

        //Get CC Addresses
        if (email.CCAddresses != null){
            emailActivity.CcAddress = '';
            for (String ccemail : email.CCAddresses){
                emailActivity.CcAddress += ccemail + ',';
            }
        }

        //Create new EmailMessage
        emailActivity.ActivityId = taskId;
        emailActivity.ParentId = caseId;
        emailActivity.Status = '0';
        emailActivity.FromAddress = email.FromAddress;
        emailActivity.Incoming = true;
        emailActivity.MessageDate = datetime.now();

        //Adding check for insert emailActivity to avoid required field missing error when emailActivity.ParentId equal to null
        if(emailActivity.ParentId != null){
            try{
                insert emailActivity;
            }
            catch(System.DmlException e){
                Logger.debugException('Error in emailActivity insert:'+e.getMessage());
                Logger.pop();
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
     * @author Original: Archana lohar - Cloud Sherpas/Mathworks, Last Modified: Archana lohar - Cloud Sherpas/Mathworks
     * @date Original: 23 Nov 2015, Last Modified: 14 December 2015
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
    public static id CreateCase(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, String emailRoutingRuleA, String emailRoutingRuleSA,String caseSubStatus,String recordTypeName,Id ContactObjId){

        Logger.Push('CreateCase', 'UEH_MessageLoggingUtils');

        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true;

        //Creating new object of case
        Case newCase = new Case();

        //Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);
        
        newCase.contactId = ContactObjId;

        //Set Case description
        if (email.PlainTextBody != null){
            if (email.PlainTextBody.length() > 32000){
                newcase.Description = email.PlainTextBody.substring(0,32000); 
            }
            else{
                  if(ContactObjId==null && email.PlainTextBody.length() < 31500){
                     newcase.Description = 'Sender\'s email address: '+email.fromAddress+'\n\n'+email.PlainTextBody;
                  }
                  else{
                     newcase.Description = email.PlainTextBody; 
                  }
            }
        }

        newCase.Status='Open';
        newCase.SubStatus__c=caseSubStatus;
        newCase.Origin = 'Email';
        
        //Set Subject
        if (email.Subject!=null){ 
            if(email.Subject.length()>255){
                newCase.Subject = UEH_MessageParsingUtils.truncateSubject(email.Subject);  
            }
            else{
                newCase.Subject = email.Subject; 
            }
        }
        
        newCase.SuppliedEmail = email.fromaddress;
        
        //set Case area and sub-area
        if(emailRoutingRuleA != null && emailRoutingRuleA != ''){
            newCase.Area__c = emailRoutingRuleA;
            if(emailRoutingRuleSA != null && emailRoutingRuleSA != ''){
                newCase.Sub_Area__c= emailRoutingRuleSA;
            }
        }
        
        Id caseRecordTypeId = null;

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
            Logger.Pop();
        }
        Logger.Pop();
        return newCase.id;
    }
    
    /**
     * @author Original: Donna Latte
     * @date Original: 6 Jul 2016, Last Modified: 
     * @Description: helper method for updating Status on existing UEH_InboundMessageLog
     * @param Id - UEH_InboundMessageLog Id
     * @param Map<String,String> - Map of Field to Update and Field Value pair
	*/
public static Id UpdateInBoundEmailLog(Id elogId, String Status){

        Logger.push('updateInBoundEmailLog','UEH_MessageLoggingUtils');
        
        //List to save the UEH_Inbound_Email_Log__c record.
        List<UEH_Inbound_Email_Log__c> logList;
        List<UEH_Inbound_Email_Log__c> logListUpdate = new List<UEH_Inbound_Email_Log__c>();

		//Query to retrieve all the Fields in UEH Inbound Log Object.
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.UEH_Inbound_Email_Log__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String query = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String fieldName = s.getDescribe().getName();
            System.debug('fieldName: ' + fieldName);

            query += fieldName + ',';
        }

        query = query.subString(0, query.length() - 1);

        query += ' FROM UEH_Inbound_Email_Log__c WHERE id = : elogId limit 1';

        logList = Database.query(query);
        
        //Set the field to update
        If (logList != null && logList.size()>0 ){
        	logList[0].UEH_Status__c = Status;
        	logListUpdate.add(logList[0]);
        }
        
 
		//Update  field
 		try{
 			System.debug('In try block to call update');
 			update logListUpdate;

        }catch(Exception ex){

            System.Debug('Exception:'+ex.getMessage());
            Logger.debugException(ex);
            Logger.Pop();
        }
        Logger.Pop();
        return elogId;
    }
}