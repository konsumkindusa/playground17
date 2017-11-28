/*
 *@author Original:Archana Lohar - Cloud Sherpas/Mathworks, Last Modified:Haigang Wu
 *@date Original: 9 Sep 2015, Last Modified: 29 Sep 2016
 *@description:This is a Academic Support module handler class that extends the abstract class EmailToSObjectModule
 *@Revision:1 July 2016|Kishore AN|Made changes related to 1562614 Attask
 *@Revision:29 Sep 2016|Haigang Wu|Made changes related to 1693609
 */

//HW 1693609
//public class UEH_EmailToAcademicSupportModuleHandler implements UEH_EmailToSObjectModule{
public class UEH_EmailToAcademicSupportModuleHandler extends UEH_EmailToSObjectModule implements Queueable, Database.AllowsCallouts {

    Academic_Support_Project__c academicSupObj; 
    Boolean setNewMessageFlag;
    public String defaultSubject = System.Label.Academic_Support_Subject;
    GlobalContactSearchController.SearchContactResponse conRes;
    Boolean isAcademicSupNew = false;
    Id ContactId;
   
    public UEH_EmailToAcademicSupportModuleHandler(){

        //Instantiate Academic Support Project record
        academicSupObj = new Academic_Support_Project__c();

        //Set setNewMessageFlag to true
        setNewMessageFlag = true;

    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Haigang Wu 
     *@Date Original: 9 Sep 2015
     *@Last Modified: 29 Sep 2016
     *@Description: It will accept the email and envelop object from Universal Email Handler and will create 
                    Academic Support Project record.
     */ 
    //HW 1693609
    //public void processMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
    public override void execute(QueueableContext qContext){

        Logger.push('execute','UEH_EmailToAcademicSupportModuleHandler');
        System.debug('execute****execute ');
        //Get UEH_AcademicSup_RecipientToQueueMapping__c custom setting
        List<UEH_AcademicSup_RecipientToQueueMapping__c> recipientQueueAssignmentLst = UEH_AcademicSup_RecipientToQueueMapping__c.getAll().Values();

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
        else{//If Thread id InValid then create Book Project Object as well as E2A object.

            //Check if the recipientQueueAssignmentLst is empty or null
            if(!recipientQueueAssignmentLst.isEmpty() && recipientQueueAssignmentLst != null){

                for(UEH_AcademicSup_RecipientToQueueMapping__c assignRec : recipientQueueAssignmentLst){

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

            //Search Contact by GlobalContactSearchController in Salesforce as well as in CDS.
            conRes = GlobalContactSearchController.searchContactByEmail(EmailAddress);

            //Check if contact found by GlobalContactSearchController
            if(conRes.ErrorCode == 'SUCCESS' && conRes.ErrorReason == 'Ok'){

                //check if contact list is empty
                conlist = [select id,AccountId from Contact where id=:conRes.ContactId];
                ContactId = conRes.ContactId;

                //check if contact list is empty
                if(!conlist.isEmpty()){
                    academicSupObj.Primary_Contact__c = conlist[0].id;
                    academicSupObj.Account__c = conlist[0].AccountId; 

                }

            }


            //Create Book project Record
            academicSupObj.Status__c ='Not Started'; 


            //Set Email Body Subject
            if(email.subject.length() > 80)
            {
                academicSupObj.name = email.subject.substring(0,80);
            }
            else{  
                academicSupObj.name = email.subject;                      
            }

            if(email.subject == null || email.subject == ''){
                academicSupObj.name = defaultSubject;    
            }

            //set Description
            if(emailText.length() > 32000){
                academicSupObj.Description__c = emailText.subString(0,32000);
            }
            else{
                academicSupObj.Description__c = emailText;
            }

            //Check if envelope.ToAddress is in custom setting
            if(recipientToQueueMap.containsKey(envelope.ToAddress) && recipientToQueueMap.get(envelope.ToAddress)!=null){

                //query queue for assigning to Academic Support record
                qList =[select id from Group where Type = 'Queue' and  name=:recipientToQueueMap.get(envelope.ToAddress)];

                If(!qList.isEmpty()){

                    academicSupObj.ownerid = qList[0].id;

                }    
            }
            try{

                insert academicSupObj;
                isAcademicSupNew = true;
                System.debug('**&&academicSupObj' +academicSupObj);
            } 

            catch (System.DmlException e) {
                System.debug('**&&academicSupObjException' +academicSupObj);
                // Capture Dml exception here
                Logger.debugException('DmlException:'+e.getDmlMessage(0)+ 'for ID:'+e.getDmlId(0));
                Logger.pop(); 
                

            }

            //Set setNewMessageFlag to false if Email comes first time for creating Book
            //project object
            setNewMessageFlag = false;

            //Create E2A Object On Academic support project Object.
            saveMessage(email,envelope,academicSupObj.id); 
        }
        Logger.pop();
    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 9 Sep 2015
     *@Last Modified: 1 July 2016
     *@Description: It will accept the email and envelop object from Universal Email Handler and will create 
                    E2A record.
     */ 
    public void saveMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope,Id academicSupProjectId){

        Logger.push('saveMessage','UEH_EmailToAcademicSupportModuleHandler');

        List<Academic_Support_Project__c> academicSupProjList =  new List<Academic_Support_Project__c>();
        

        academicSupProjList = [select id,OwnerId,Primary_Contact__c,New_Email_Message__c,(SELECT id FROM  e2a_Emails__r)
                               from Academic_Support_Project__c where id =:academicSupProjectId];

        String EmailAddress = envelope.fromAddress;

        if(EmailAddress.length()>80){
            EmailAddress.SubString(0,80);
        }


        String OwnerObjectId = String.ValueOf(academicSupProjectId);
        Id senderContactid = null;

        //Populate Email Log Details
        ortoo_e2a__EmailMessage__c e2aObj = new ortoo_e2a__EmailMessage__c(

                ortoo_e2a__From_Address__c = email.FromAddress,
                Academic_Support_Project__c = academicSupProjectId,
                ortoo_e2a__Incoming__c = true,
                ortoo_e2a__Status__c = 'new',
                ortoo_e2a__Owner_Object__c = OwnerObjectId.subString(0,3)

                );

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
        if(ContactId==null && !isAcademicSupNew){  
            GlobalContactSearchController.SearchContactResponse conRes = GlobalContactSearchController.searchContactByEmail(EmailAddress);
            if(conRes.ErrorCode == 'SUCCESS' && conRes.ErrorReason == 'Ok'){

                e2aObj.ortoo_e2a__Contact_Id__c = conRes.ContactId;
                senderContactid = conRes.contactId; 

            }
        }else{
            e2aObj.ortoo_e2a__Contact_Id__c = contactId;
            senderContactid = contactId; 
        }

        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Get PlainText Body
        if (email.PlainTextBody != null){
            if (email.PlainTextBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
                e2aObj.ortoo_e2a__Text_Body__c = UEH_MessageParsingUtils.truncateBody(email.PlainTextBody); 

            }
            else{
                e2aObj.ortoo_e2a__Text_Body__c = email.PlainTextBody; 
            }
        }

        //Get HTML Body
        if (email.htmlBody != null){
            if (email.htmlBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
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
            UEH_MessageLoggingUtils.createAttachments(email,e2aObj.id,academicSupProjList[0].id,senderContactid,academicSupProjList[0].ownerid);
        }

        //Create task on Academic support object
        Id taskId = UEH_MessageLoggingUtils.createTask(email,academicSupProjList[0].id,senderContactid,academicSupProjList[0].ownerid);

        Logger.pop(); 
    }
}