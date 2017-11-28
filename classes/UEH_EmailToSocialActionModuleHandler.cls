/***************************************************************************************
 * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Haigang Wu
 * date Original: 11 March 2016, Last Modified: 29 Sep 2016
 * description This is a Social Action module handler class that extends the abstract class UEH_EmailToSObjectModule
 *@Revision:29 Sep 2016|Haigang Wu|Made changes related to 1693609
 ****************************************************************************************/
//HW 1693609
//public class UEH_EmailToSocialActionModuleHandler implements UEH_EmailToSObjectModule{
public class UEH_EmailToSocialActionModuleHandler extends UEH_EmailToSObjectModule implements Queueable, Database.AllowsCallouts {
    Social_Action__c socialActionObj;
    GlobalContactSearchController.SearchContactResponse conRes;
    public String defaultSubject = System.Label.Social_Action_subject;
    Boolean setNewMessageFlag;
    //DL 1562614 
    Boolean isSocialActionNew = false;
    Id ContactId;
    
    public UEH_EmailToSocialActionModuleHandler(){
        System.debug('**UEH_EmailToSocialActionModuleHandlerConstructor**');
        //Instantiate Social Action  record
        socialActionObj = new Social_Action__c();
         //Set setNewMessageFlag to true
        setNewMessageFlag = true;
    }
    /***************************************************************************************
    * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Haigang Wu 
    * date Original: 11 March 2016, Last Modified: 29 Sep 2016
    * description It will accept the email and envelop object from Universal Email Handler and will create 
    *               Social Action record.
    ****************************************************************************************/ 
    //HW 1693609
    //public void processMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
    public override void execute(QueueableContext qContext){
        Logger.push('execute','UEH_EmailToSocialActionModuleHandler');
        //Get UEH_SocialAction_RecipientToQueueMapping__c custom setting
         List<UEH_SocialAction_RecipientToQueueMapping__c> recipientQueueAssignmentLst = UEH_SocialAction_RecipientToQueueMapping__c.getAll().Values();

        Map<string,string> recipientToQueueMap = new Map<string,string>();

        List<Group > qList = new List<Group>();

        Boolean isValid = false;

        String threadId;
        String emailText = '';

        if(email.PlainTextBody!= null){
            emailText = email.PlainTextBody;
        }
        else if(email.htmlBody!= null){
            emailText = email.htmlBody;
        }

        //Check If Email Subject or body contains ThraedId
        If(UEH_MessageParsingUtils.containsThreadId(email.subject) || (email.PlainTextBody!= null && UEH_MessageParsingUtils.containsThreadId(email.PlainTextBody))
                || (email.htmlBody!= null && UEH_MessageParsingUtils.containsThreadId(email.htmlBody))){

            threadId = UEH_MessageParsingUtils.getThreadID(email.subject);    

            //Check if there is thread id in subject else get from body.
            if(threadId=='ref::ref'){
                if(email.plainTextBody!= null){
                    threadId = UEH_MessageParsingUtils.getThreadID(email.PlainTextBody);
                }
                else if(email.htmlBody!= null){
                    threadId = UEH_MessageParsingUtils.getThreadID(email.htmlBody);
                }    
            } 

            if(threadId != 'ref::ref'){
                //Check if Thread Id is Valid
                isValid = UEH_MessageCheckingUtils.isValidThreadId(threadId);
            }


        } 
        //Check if Thread Id is valid
        if(isValid){

            //If Thread id Valid then only create E2A object.
             saveMessage(email,envelope,UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId));

        }
        else{//If Thread id InValid then create Social Action Object as well as E2A object.

            //Check if the recipientQueueAssignmentLst is empty or null
            if(!recipientQueueAssignmentLst.isEmpty() && recipientQueueAssignmentLst != null){

                for(UEH_SocialAction_RecipientToQueueMapping__c assignRec : recipientQueueAssignmentLst){

                    if(assignRec.Queue_Name__c != '' && assignRec.Queue_Name__c != Null 
                            && assignRec.Recipient_Email_Address__c!= '' && assignRec.Recipient_Email_Address__c!= Null){

                        recipientToQueueMap.put(assignRec.Recipient_Email_Address__c,assignRec.Queue_Name__c); 

                    }
                } 
            }
            List<Contact> conlist = new List<Contact>();

            String EmailAddress = envelope.fromAddress;

            If(EmailAddress.length()>80){
                EmailAddress.SubString(0,80);
            }
            System.debug('**EmailAddress**'+EmailAddress);
            //Search Contact by GlobalContactSearchController in Salesforce as well as in CDS.
            conRes = GlobalContactSearchController.searchContactByEmail(EmailAddress);
            //Check if contact found by GlobalContactSearchController
            if(conRes.ErrorCode == 'SUCCESS' && conRes.ErrorReason == 'Ok'){
                //DL 1562614
                ContactId = conRes.ContactId; 
                //end DL

                //Query Contact if found
                conlist = [select id,AccountId from Contact where id=:conRes.ContactId];
                //check if contact list is empty
                if(!conlist.isEmpty()){
                    socialActionObj.Contact__c = conlist[0].id;
                    socialActionObj.Account__c = conlist[0].AccountId; 
                    
                }

            }


            //Create Social Action Record
            socialActionObj.Status__c ='New'; 
                

            //Set Email Body Subject
            if(email.subject.length() > 80)
            {
                socialActionObj.Event_Program_Name__c = email.subject.substring(0,80);
            }
            else{  
                socialActionObj.Event_Program_Name__c = email.subject;                      
            }

            if(email.subject == null || email.subject == ''){
                socialActionObj.Event_Program_Name__c = defaultSubject;    
            }

            //set Description
            //Fetching data from UEH General setting
            UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
            if(emailText.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                socialActionObj.Description__c = emailText.subString(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-5);
            }
            else{
                socialActionObj.Description__c = emailText;
            }

            //Check if envelope.ToAddress is in custom setting
            if(recipientToQueueMap.containsKey(envelope.ToAddress) && recipientToQueueMap.get(envelope.ToAddress)!=null){

                //query queue for assigning to Academic Support record
                qList =[select id from Group where Type = 'Queue' and  name=:recipientToQueueMap.get(envelope.ToAddress)];

                If(!qList.isEmpty()){

                    socialActionObj.ownerid = qList[0].id;

                }    
            }
            try{

                insert socialActionObj; 
                isSocialActionNew = true;   //DL: 1562614        
                System.debug('**&&socialActionObj' +socialActionObj);
            } 

            catch (System.DmlException ex) {
               // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(0)+ 'for ID:'+ex.getDmlId(0));
                Logger.pop(); 
                

            }

            //Set setNewMessageFlag to false if Email comes first time for Social Action Object
            setNewMessageFlag = false;

            //Create E2A Object On Social Action Object.
            saveMessage(email,envelope,socialActionObj.id); 
        }
        Logger.pop();
    }
    
   /***************************************************************************************
    * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
    * date Original: 11 March 2016, Last Modified: 11 March 2016
    * description: It will accept the email and envelop object from Universal Email Handler and will create 
    *               E2A record.
    ****************************************************************************************/ 
    public void saveMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope,Id socialActionId){

        Logger.push('saveMessage','UEH_EmailToSocialActionModuleHandler');

        List<Social_Action__c> socialActionList =  new List<Social_Action__c>();
        socialActionList = [Select id,Contact__c,ownerid,(Select id From e2a_Emails__r) From Social_Action__c where Id =:socialActionId];
        String OwnerObjectId = String.ValueOf(socialActionId);
        
        Id senderContactid = null;

        //Populate Email Log Details
        ortoo_e2a__EmailMessage__c e2aObj = new ortoo_e2a__EmailMessage__c(

                ortoo_e2a__From_Address__c = email.FromAddress,
                Social_Action__c = socialActionId,
                ortoo_e2a__Incoming__c = true,
                ortoo_e2a__Status__c = 'new',
                ortoo_e2a__Owner_Object__c = OwnerObjectId.subString(0,3)

                );

        String EmailAddress = envelope.fromAddress;

        if(EmailAddress.length()>80){
            EmailAddress.SubString(0,80);
        }

        //Get Subject
        if (email.Subject!=null){ 
            if(email.Subject.length()>80){
                e2aObj.Name = email.Subject.substring(0,80); //truncate subject to 80 chars - no need to keep thread id
            }
            else{
                e2aObj.Name = email.Subject; 
            }

            if(email.Subject.length()>255){
                e2aObj.ortoo_e2a__Subject__c = UEH_MessageParsingUtils.truncateSubject(email.Subject);  
            }
            else{
                e2aObj.ortoo_e2a__Subject__c = email.Subject; 
            }
        }


        //Check if there is already contact
        // DL: 1562614 
         if(ContactId==null && !isSocialActionNew)  {
            GlobalContactSearchController.SearchContactResponse conRes = GlobalContactSearchController.searchContactByEmail(EmailAddress);
            if(conRes.ErrorCode == 'SUCCESS' && conRes.ErrorReason == 'Ok'){
                e2aObj.ortoo_e2a__Contact_Id__c = conRes.ContactId;
                senderContactid = conRes.ContactId; 
                }
         } else{
            e2aObj.ortoo_e2a__Contact_Id__c = contactId;
            senderContactid = ContactId;
        }


        //Get PlainText Body
        if (email.PlainTextBody != null){
            if (email.PlainTextBody.length() > 32500){
                e2aObj.ortoo_e2a__Text_Body__c = UEH_MessageParsingUtils.truncateBody(email.PlainTextBody); 

            }
            else{
                e2aObj.ortoo_e2a__Text_Body__c = email.PlainTextBody; 
            }
        }

        //Get HTML Body
        if (email.htmlBody != null){
            if (email.htmlBody.length() > 32500){
                e2aObj.ortoo_e2a__Html_Body__c = UEH_MessageParsingUtils.truncateBody(email.htmlBody); 
            }
            else { 
                e2aObj.ortoo_e2a__Html_Body__c = email.htmlBody; 
            }
        }

        //Get Email To Addresses
        if (email.ToAddresses != null){
            e2aObj.ortoo_e2a__To_Address__c = '';
            for (String toemail : email.ToAddresses){
                e2aObj.ortoo_e2a__To_Address__c += toemail + '; ';    
            }
        }

        //Get CC Addresses
        if (email.CCAddresses != null){
            e2aObj.ortoo_e2a__Cc_Address__c = '';
            for (String ccemail : email.CCAddresses){
                e2aObj.ortoo_e2a__Cc_Address__c += ccemail + '; ';
            }
        }

        //Get From Name
        if(email.fromName != null){        
            e2aObj.ortoo_e2a__From_Name__c = email.fromName;
        }

        //Get Header
        //if(email.headers != null){
        //    e2aObj.ortoo_e2a__Headers__c = '';
        //    for(Messaging.InboundEmail.Header emailhead : email.headers){
        //        e2aObj.ortoo_e2a__Headers__c +='['+emailhead.name+' | '+emailhead.value+']'+'&'+'\n';
        //    }
        //} 
        //Get Header, truncate if too long for field length
        //2175617 DMA
        String eHead = '';
        Integer maxHeaderLength = SObjectType.ortoo_e2a__EmailMessage__c.Fields.ortoo_e2a__Headers__c.Length;
        if(email.headers != null){
            for(Messaging.InboundEmail.Header emailhead : email.headers){
                eHead +='['+emailhead.name+' | '+emailhead.value+']'+'&'+'\n';
                if(eHead.length()>maxHeaderLength) break;
            }
        } 
        e2aObj.ortoo_e2a__Headers__c = eHead.abbreviate(maxHeaderLength);

        //Get Message Id 
        if(email.messageId != null){
            e2aObj.ortoo_e2a__Message_Id__c = email.messageId;
        }

        if(email.textAttachments!=null || email.binaryAttachments!=null){
            e2aObj.ortoo_e2a__Has_Attachment__c = true;
        }

        //Create Email Log
        try{
            insert e2aObj;
        }
        catch(DMLException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                //Process exception here
                Logger.debugException('Error in Creating E2A Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                Logger.pop(); 
            }
        }

        //For Creating attachmnets on E2a Object
        if(email.textAttachments!=null || email.binaryAttachments!=null){
            UEH_MessageLoggingUtils.createAttachments(email,e2aObj.id,socialActionList[0].id,senderContactid,socialActionList[0].ownerid);
        }

         Id taskId = UEH_MessageLoggingUtils.createTask(email,socialActionList[0].id,senderContactid,socialActionList[0].ownerid);
        Logger.pop(); 
    }
}