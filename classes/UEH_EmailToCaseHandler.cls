/*
 *@author Original:Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Haigang Wu
 *@date Original: 24 Sep 2015, Last Modified:29 Sep 2016
 *@description:This is a Paterns Agreements  module handler class that extends the abstract class EmailToSObjectModule
 *@Revision:1 July 2016|Kishore AN|Made changes related to 1562614 Attask
 *@Revision:29 Sep 2016|Haigang Wu|Made changes related to 1693609
 */
//HW 1693609
//public Class UEH_EmailToCaseHandler  implements UEH_EmailToSObjectModule{
public Class UEH_EmailToCaseHandler extends UEH_EmailToSObjectModule implements Queueable, Database.AllowsCallouts {

    Id ContactId;
    GlobalContactSearchController.SearchContactResponse conRes;
    String EmailAddress;
    Boolean isCaseNew = false;

    /*
     *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks 
     *@Last Modified: Haigang Wu 
     *@Date Original: 24 Sep 2015
     *@Last Modified: 29 Sep 2016
     *@Description: It will accept the email and envelop object from Universal Email Handler 
     */ 
    //HW 1693609
    //public void processMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
    public override void execute(QueueableContext qContext){

        Logger.push('execute','UEH_EmailToCaseHandler');    

        Boolean isValid = false;
        String threadId;
        list<Email_Routing_Rules__c> emailRoutingRule;
        list <Forwarding_Rule__c> frRecords = new list <Forwarding_Rule__c>();
        String areaOnSR;
        String subAreaOnSR;

        //Check If Email Subject or body contains ThraedId
        If(UEH_MessageParsingUtils.containsThreadId(email.subject) || (email.PlainTextBody!= null && String.valueof(email.plainTextBody).contains('[DEVID')) || (email.PlainTextBody!= null && UEH_MessageParsingUtils.containsThreadId(email.PlainTextBody))
                || (email.htmlBody!= null && UEH_MessageParsingUtils.containsThreadId(email.htmlBody))){

            threadId = UEH_MessageParsingUtils.getThreadID(email.subject);    

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
        

        if(isValid ){

        
            //If Thread id Valid then only create task, emailmessage and  attachments object.
            saveMessage(email,envelope,UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId));

        }
        else{

            GlobalContactSearchController.SearchContactResponse conRes = GlobalContactSearchController.searchContactByEmail(envelope.fromAddress);

            if(conRes.ErrorCode == 'SUCCESS' && conRes.ErrorReason == 'Ok'){

                ContactId = conRes.contactId;
            }

            //Query Email Routing Rules by to Envelope address
            emailRoutingRule =  [SELECT Name, Area_on_SR__c, Response_to_DEV_email__c, Response_to_PROD__c, Response_to_TEST_email__c, Sub_Area_on_SR__c, Generic_Email__c,Case_Record_Type__c FROM Email_Routing_Rules__c WHERE Email_Service_Address__c = : envelope.toAddress AND Email_Service_Address__c <> null limit 1];

            Boolean containDevId=false;
            if(email.plainTextBody!=null){
                containDevId = String.valueof(email.plainTextBody).contains('[DEVID');       
            }

            //Check if emailRoutingRule is not null
            if(!emailRoutingRule.isEmpty()){        

                if(!containDevId){

                    //Forwarding Rules and Email Routing Rules are applied on generic Emails
                    if (emailRoutingRule[0].Generic_Email__c){

                        //Get Sender Address
                        String senderAddress = email.fromAddress;
                        //String domainExtension = 'in';
                        String domainExtension = senderAddress.substringAfterLast('.').toLowerCase();

                        //Checks if country domain is supported by Mathworks
                        frRecords = [SELECT Forwarding_Email_Address__c, Distributor_Name__c, Dommain_Country_Code__c, Case_Area_Country_Code__c, Email_Template_Name__c,MathWorks_Office__c FROM Forwarding_Rule__c WHERE Dommain_Country_Code__c = :domainExtension limit 1];

                        if (frRecords.size() > 0){

                            if(frRecords[0].MathWorks_Office__c == false){

                                //Set CC Address of the Email to be forwarded
                                String[] forwardCcAddresses = new String[]{};
                                if(email.ccAddresses!=null){
                                    for(String e: email.ccAddresses){
                                        forwardCcAddresses.add(e);
                                    }
                                }

                                //Forward the email to the distributor and send a notification mail to sender if email is not a Distributor 
                                UEH_MessageRoutingUtil.forwardEmailToDistributor(email,envelope,new String[]{frRecords [0].Forwarding_Email_Address__c});

                                //send confirmation Email
                                UEH_MessageRoutingUtil.SendConfirmationMail(new String[]{email.fromAddress},frRecords [0].Forwarding_Email_Address__c,forwardCcAddresses,frRecords [0].Distributor_Name__c,email.subject,'Forwarding Rules Auto Reply Email'); 
                            }
                            else{

                                //Checks if email is sent to Service or Support Mathworks address
                                if (emailRoutingRule[0].Name == Label.Service_Mathwork_Adress){
                                    AreaOnSR = frRecords[0].Case_Area_Country_Code__c + ' - Customer Support';
                                }
                                else if (emailRoutingRule[0].Name == Label.Support_Mathwork_Adress){
                                    AreaOnSR = frRecords[0].Case_Area_Country_Code__c + ' - Technical Support';
                                }

                                //Create Case Object
                                ID newCaseId =UEH_MessageLoggingUtils.CreateCase(email,envelope,areaOnSR,emailRoutingRule[0].Sub_Area_on_SR__c,'Unassigned',emailRoutingRule[0].Case_Record_Type__c,ContactId);
                                isCaseNew = true;

                                //Create task, emailmessage, attachments
                                saveMessage(email,envelope,newCaseId); 

                            }
                        }
                        else{

                            areaOnSR= EmailRoutingRule[0].Area_on_SR__c;

                            //Create Case Object
                            ID newCaseId =UEH_MessageLoggingUtils.CreateCase(email,envelope,areaOnSR,emailRoutingRule[0].Sub_Area_on_SR__c,'Unassigned',emailRoutingRule[0].Case_Record_Type__c,ContactId);
                            isCaseNew = true;
                            //Create task, emailmessage, attachments
                            saveMessage(email,envelope,newCaseId); 
                        }
                    }
                    else{

                        areaOnSR= EmailRoutingRule[0].Area_on_SR__c;

                        //Create Case Object
                        ID newCaseId =UEH_MessageLoggingUtils.CreateCase(email,envelope,areaOnSR,emailRoutingRule[0].Sub_Area_on_SR__c,'Unassigned',emailRoutingRule[0].Case_Record_Type__c,ContactId);
                        isCaseNew = true;
                        
                        //HW 1812324
                        if(newCaseId == null)
                        	Logger.debug('newCaseId is null. Email detail: ' + email + '. Envelope detail: '+ envelope);
                        //HW 1812324
                        
                        //Create task, emailmessage, attachments
                        saveMessage(email,envelope,newCaseId);  
                    }
                }
                else{

                    areaOnSR= EmailRoutingRule[0].Area_on_SR__c;

                    //Create Case Object
                    ID newCaseId =UEH_MessageLoggingUtils.CreateCase(email,envelope,areaOnSR,emailRoutingRule[0].Sub_Area_on_SR__c,'Unassigned',emailRoutingRule[0].Case_Record_Type__c,ContactId);
                    isCaseNew = true;
                    //Create task, emailmessage, attachments
                    saveMessage(email,envelope,newCaseId); 
                }
            }else{

                //Create Case Object
                ID newCaseId =UEH_MessageLoggingUtils.CreateCase(email,envelope,'Natick - Customer Support','','Unassigned',null,ContactId);
                isCaseNew = true;
                //Create task, emailmessage, attachments
                saveMessage(email,envelope,newCaseId); 
            }

            Logger.pop();
        }
    }

    /*
     *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 24 Sep 2015
     *@Last Modified: 1 July 2016
     *@Description: It will accept the email and envelop object from Universal Email Handler and will create 
                    E2A record.
     */ 
    public void saveMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope,Id caseId){

        Logger.push('saveMessage','UEH_EmailToCaseHandler');

        Id taskId;
        Integer maxSizeAttachment = 26214400;
        Id senderContactid;

        //Create Case List
        List<Case> caseList =  new List<Case>();
        
        //Query Case Object
        caseList = [select id,OwnerId from Case where id =:caseId];
        
        //Check if there is already contact 
        if(ContactId==null && !isCaseNew){  
            GlobalContactSearchController.SearchContactResponse conRes = GlobalContactSearchController.searchContactByEmail(envelope.fromAddress);
            if(conRes.ErrorCode == 'SUCCESS' && conRes.ErrorReason == 'Ok'){
                senderContactid = conRes.Contactid;
            }
        }else{
            senderContactid = ContactId;
        }
        
        //HW 1812324
        if(caseList == null)
        	Logger.debug('caseList is null. Email detail: ' + email + '. Envelope detail: '+ envelope + '. caseId: '+ caseId);
        //HW 1812324
        
        //Create task on Case object
        taskId = UEH_MessageLoggingUtils.createTask(email,caseList[0].id,senderContactid,caseList[0].ownerid);
        
        //Create related Email Message on Case
        id emailMsgId = UEH_MessageLoggingUtils.CreateEmailActivity(email,envelope,caseId,taskId);
        
        //For Creating attachmnets on Email Message Object
        if(email.textAttachments!=null || email.binaryAttachments!=null){
            UEH_MessageLoggingUtils.createAttachments(email,emailMsgId,CaseList[0].id,senderContactid,caseList[0].ownerid);
        }

        Logger.pop();
    }
}