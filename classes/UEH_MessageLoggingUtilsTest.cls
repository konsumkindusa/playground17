/**
    * @author Original:    Abhay Verma - Cloud Sherpas/Mathworks, 
    * @Last Modified by:   14 December 2015
    * @date Original:      16 July 2015, 
    * @LastModified Date : 
    * @description         Test Class to check the functionality of Class "UEH_MessageLoggingUtils".
                           Check if the Email Coming from Email Services is created as a record in 
                           UEH Inbound Email Log Object.
  */

@isTest
public class UEH_MessageLoggingUtilsTest{
    
   //re-create custom setting test records when running the test class
   static CustomSettingsBuilder csb = new CustomSettingsBuilder();
   static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
 
   /*
       *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
       *@Last Modified:   Abhay Verma - Cloud Sherpas/Mathworks 
       *@Date Original:   26 June 2015
       *@Last Modified:   26 June 2015
       *@param            none.
       *@return           void
       *@Description:     Create test data from Message Inbound Email and Messgae Inboud Envlope 
                          and check if it map email details in its required field and create Email 
                          log Object.
       */ 
       
       public static testMethod void CreateInBoundEmailLogTest(){
       //Getting the Reference Id.
       //UEH_MessageParsingUtils.refOrgId = UEH_MessageParsingUtils.getReferenceOrgID();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
        custsettbuild.builtUEHGeneralSetting();
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail lessCharEmailObj = new Messaging.InboundEmail();
        lessCharEmailObj.Subject = 'Email Logging Case ' + refId;
        lessCharEmailObj.FromAddress = 'personemailfromaddress@gmail.com';
        lessCharEmailObj.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        lessCharEmailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        lessCharEmailObj.ToAddresses = new String[] {'person@gmail.com'};
        lessCharEmailObj.CCAddresses = new String[] {'user@gmail.com'};
        lessCharEmailObj.fromName = 'User Name';
        lessCharEmailObj.htmlBodyIsTruncated = False;
        lessCharEmailObj.replyTo = 'personemailfromaddress@gmail.com';
        lessCharEmailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        lessCharEmailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        lessCharEmailObj.plainTextBodyIsTruncated = False;
        lessCharEmailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        
        //Creating Envelope data
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelopetoaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
        String Status = 'Accepted';    
        
        //Creating text Attachment Data
        Messaging.InboundEmail.TextAttachment attachTextFile = new Messaging.InboundEmail.TextAttachment();
        
        attachTextFile.body = 'my attachment text';
        attachTextFile.fileName = 'textfiletwo.txt';
        attachTextFile.mimeTypeSubType = 'texttwo/plain';
        lessCharEmailObj.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile };
          
        //Createing Binary Attachment Data.  
        Messaging.InboundEmail.BinaryAttachment attachBinaryFile = new Messaging.InboundEmail.BinaryAttachment();
          
        attachBinaryFile.body = blob.valueOf('my attachment text');
        attachBinaryFile.fileName = 'textfileone.txt';
        attachBinaryFile.mimeTypeSubType = 'text/plain';
        lessCharEmailObj.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile };
        
        // Creating Email for Excessing Char Limit Body and Subject        
        Messaging.InboundEmail excessCharEmailObj= new Messaging.InboundEmail();
        
        Integer i=0;
        String maxCharSubject;
        
        //Loop to insert 256 Char in Subject.
        for(i=0; i<=255;i++){
            maxCharSubject = maxCharSubject + i;
        }
       //Loop to insert Max_Email_Body_Length__c Char in Plain Text Body and HTML Body.
        String plaintextadd;
        for(i=0;i<=uehGeneralSettings.Max_Email_Body_Length__c/100;i++){
            plaintextadd = plaintextadd + '0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        }
        excessCharEmailObj.Subject = maxCharSubject + refId;
        excessCharEmailObj.FromAddress = 'excesscharpersonemailfromaddress@gmail.com';
        excessCharEmailObj.plainTextBody = 'Email Message Body' + plaintextadd + refId;
        excessCharEmailObj.htmlBody = '<!DOCTYPE html><html><title><h1><p>This s A test mail</p></h1></title><body> ' + plaintextadd + refId +'</body></html>';
        excessCharEmailObj.ToAddresses = new String[] {'personexcess@gmail.com'};
        excessCharEmailObj.CCAddresses = new String[] {'userexcess@gmail.com'};
        excessCharEmailObj.fromName = 'User Name Excess';
        excessCharEmailObj.htmlBodyIsTruncated = True;
        excessCharEmailObj.replyTo = 'excesscharpersonemailfromaddress@gmail.com';
        excessCharEmailObj.inReplyTo = 'excesscharpersonemailfromaddress@gmail.com';
        excessCharEmailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        excessCharEmailObj.plainTextBodyIsTruncated = True;
        excessCharEmailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelope1Obj = new Messaging.InboundEnvelope();
        envelope1Obj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelope1Obj.FromAddress = 'personenvelopefromaddress@gmail.com';
        
        //Creating text Attachment data.
        Messaging.InboundEmail.TextAttachment attachTextFile1 = new Messaging.InboundEmail.TextAttachment();
        
        attachTextFile1.body = 'my attachment text';
        attachTextFile1.fileName = 'textfiletwo.txt';
        attachTextFile1.mimeTypeSubType = 'texttwo/plain';
        excessCharEmailObj.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile1 };
        
        //Creating Binary Attachment Data.  
        Messaging.InboundEmail.BinaryAttachment attachBinaryFile1 = new Messaging.InboundEmail.BinaryAttachment();
        attachBinaryFile1.body = blob.valueOf('my attachment text');
        attachBinaryFile1.fileName = 'textfileone.txt';
        attachBinaryFile1.mimeTypeSubType = 'text/plain';
        excessCharEmailObj.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile1 };
        
        String Status1 = 'Accepted';    
        
        //run test
        Test.startTest();
           Id emailLogId = UEH_MessageLoggingUtils.CreateInBoundEmailLog(lessCharEmailObj, envelopeObj, Status,'');
           UEH_Inbound_Email_Log__c elog = [SELECT Id FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId];
           System.assertEquals(emailLogId, elog.Id);
           Id emailLogId1 = UEH_MessageLoggingUtils.CreateInBoundEmailLog(excessCharEmailObj, envelope1Obj, Status1,'');
           UEH_Inbound_Email_Log__c elog1 = [SELECT Id FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId1];
           System.assertEquals(emailLogId1, eLog1.Id);
        
        //Get all the Field for Quering all the Object Fields data.
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.UEH_Inbound_Email_Log__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
    
        String querystr = 'SELECT ';
        String querystr1 = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
           String labelName = s.getDescribe().getLabel(); 
           String fieldName = s.getDescribe().getName();
           
          
           querystr += fieldName + ',';
           querystr1 += fieldName + ',';
        }
        
        
        querystr = querystr.subString(0, querystr.length() - 1);
        querystr1 = querystr1.subString(0, querystr1.length() - 1);
        
        querystr += ' FROM UEH_Inbound_Email_Log__c WHERE ((UEH_Email_From_Address__c =\''+ lessCharEmailObj.FromAddress +'\') AND (UEH_Envelope_To_Address__c =\''+envelopeObj.toAddress +'\')) ';
        querystr1 += ' FROM UEH_Inbound_Email_Log__c WHERE ((UEH_Email_From_Address__c =\''+ excessCharEmailObj.FromAddress +'\') AND (UEH_Envelope_To_Address__c =\''+envelope1Obj.toAddress+'\'))';
        
        
        UEH_Inbound_Email_Log__c[] elogLst = Database.query(querystr);
        UEH_Inbound_Email_Log__c[] elogExcessCharLst = Database.query(querystr1);
      
                                       
        // Asserting for the Messaging.InboundEmail lessCharEmail Object.
        System.assertEquals(elogLst[0].UEH_Email_From_Address__c, lessCharEmailObj.FromAddress);
        System.assertEquals(elogLst[0].UEH_Email_To_Addresses__c, lessCharEmailObj.ToAddresses[0]+';');
        System.assertEquals(elogLst[0].UEH_Email_CC_Addresses__c, lessCharEmailObj.CCAddresses[0]+';');
        System.assertEquals(elogLst[0].UEH_Email_Text_Body__c, lessCharEmailObj.plainTextBody);
        System.assert((elogLst[0].UEH_Email_Text_Body__c).length()<uehGeneralSettings.Max_Email_Body_Length__c);
        System.assertEquals(elogLst[0].UEH_Email_Subject__c, lessCharEmailObj.Subject);
        System.assertEquals(elogLst[0].UEH_Email_HTML_Body__c, lessCharEmailObj.htmlBody);
        System.assertEquals(elogLst[0].UEH_Envelope_To_Address__c, envelopeObj.toAddress);
        System.assertEquals(elogLst[0].UEH_Envelope_From_Address__c, envelopeObj.FromAddress);
        System.assertEquals(elogLst[0].UEH_Status__c, Status);
        System.assertEquals(elogLst[0].UEH_Email_from_Name__c, lessCharEmailObj.fromName);
        System.assertEquals(elogLst[0].UEH_Email_from_Name__c, lessCharEmailObj.fromName);
        System.assertEquals(elogLst[0].UEH_Email_Html_Body_Is_Truncated__c, lessCharEmailObj.htmlBodyIsTruncated);
        System.assertEquals(elogLst[0].UEH_Email_Reply_To__c, lessCharEmailObj.replyTo);
        System.assertEquals(elogLst[0].UEH_Email_Plain_Text_Body_Is_Truncated__c, lessCharEmailObj.plainTextBodyIsTruncated);
        System.assertEquals(elogLst[0].UEH_Email_Message_Id__c, lessCharEmailObj.messageId);
        System.assert(elogLst[0].UEH_Email_References__c != null);    
        
        List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: elogLst[0].Id];
        //Checking if the Attachment are inserted.
        System.assertEquals(attchList != null, True);
        
        for(Attachment atchObj : attchList){
            System.assertEquals(atchObj.BodyLength <= 26214400,True);
        }
        
        // Asserting for the Messaging.InboundEmail excessCharEmail Object.
        System.assertEquals(elogExcessCharLst[0].UEH_Email_From_Address__c, excessCharEmailObj.FromAddress);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_To_Addresses__c, excessCharEmailObj.ToAddresses[0]+';');
        System.assertEquals(elogExcessCharLst[0].UEH_Email_CC_Addresses__c, excessCharEmailObj.CCAddresses[0]+';');
        System.assertEquals(elogExcessCharLst[0].UEH_Envelope_To_Address__c, envelope1Obj.toAddress);
        System.assertEquals(elogExcessCharLst[0].UEH_Envelope_From_Address__c, envelope1Obj.FromAddress);
        System.assertEquals(elogExcessCharLst[0].UEH_Status__c, Status1);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_from_Name__c, excessCharEmailObj.fromName);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_from_Name__c, excessCharEmailObj.fromName);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_Html_Body_Is_Truncated__c, True);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_Reply_To__c, excessCharEmailObj.replyTo);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_Plain_Text_Body_Is_Truncated__c, True);
        System.assertEquals(elogExcessCharLst[0].UEH_Email_Message_Id__c, excessCharEmailObj.messageId);
        System.assert(elogExcessCharLst[0].UEH_Email_References__c != null);
        System.assert(elogExcessCharLst[0].UEH_Email_Text_Body__c.length() < uehGeneralSettings.Max_Email_Body_Length__c);
        System.assert(elogExcessCharLst[0].UEH_Email_Subject__c.length() < 255);
        System.assert(elogExcessCharLst[0].UEH_Email_HTML_Body__c.length() < uehGeneralSettings.Max_Email_Body_Length__c);
        
        //Quering the Attachment to check for Assertion.
        List<Attachment> attchListExcessChar = [SELECT Id, BodyLength, Name FROM Attachment WHERE Parent.Id =: elogExcessCharLst[0].Id];
        
        //Checking if the Attachment are inserted.
        System.assertEquals(attchListExcessChar != null, True);
        //Asserting the Attachment has more then 5MB is data.
        for(Attachment atchObj : attchListExcessChar){
            System.assertEquals(atchObj.BodyLength <= 26214400,True);
        }
        
        Test.stopTest();
        
    }
       
      
     /*
      @name         getEmailMapFromLogLstTest
      @date         9.July.2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Test method to ckeck the UEH_InboundEmailLog Object Feilds Values is properly pass in to the Wrapper Class.
     */
    
    public static testMethod void getEmailMapFromLogLstTest(){
    
    List<UEH_Inbound_Email_Log__c> uehElogLst = new List<UEH_Inbound_Email_Log__c>();
    
    Integer i=0;
    
    for(i=0; i <= 199; i++){
        
        //Creating the UEH_InboundEmailLog Records.
        UEH_Inbound_Email_Log__c eLog = new UEH_Inbound_Email_Log__c();
        eLog.UEH_Email_CC_Addresses__c = 'username@gmail.com;username1' + i +'@gmail.com' ;
        eLog.UEH_Email_From_Address__c = 'person_email' +i+ 'fromaddress@gmail.com';
        eLog.UEH_Email_from_Name__c = 'User Name' +i;
        eLog.UEH_Email_Header__c = '[Return-Path | abhay.verma@cloudsherpas.com]&[Authentication-Results | mx3-chi3.mta.salesforce.com header.DKIM-Signature=@cloudsherpas.com; dkim=pass]';
        eLog.UEH_Email_HTML_Body__c = '<html><title>This s A test mail' +i+ '</title><body>Hi i am here.</body></html>';
        eLog.UEH_Email_Html_Body_Is_Truncated__c = False;
        eLog.UEH_Email_in_Reply_To__c = 'personemailfromaddress' +i+ '@gmail.com';
        eLog.UEH_Email_Message_Id__c = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVV' +i+ 'CoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        eLog.UEH_Email_Plain_Text_Body_Is_Truncated__c = False;
        eLog.UEH_Email_Reply_To__c = 'personemailfromaddress' +i+ '@gmail.com';
        eLog.UEH_Email_Subject__c = 'Email Logging Case' +i;
        eLog.UEH_Email_Text_Body__c = 'Email plain Text Body Test' +i;
        eLog.UEH_Email_To_Addresses__c = 'person' +i+ '@gmail.com;person2@gmail.com';
        eLog.UEH_Envelope_From_Address__c = 'personenvelopefromaddress' +i+'@gmail.com';
        eLog.UEH_Envelope_To_Address__c = 'personenvelope1toaddress' +i+ '@gmail.com';
        eLog.UEH_Status__c = 'Accepted';
        
        uehElogLst.add(eLog);
    }
    
    try{
        insert uehElogLst;
    }
   catch(DMLException ex){

            for (i = 0; i < ex.getNumDml(); i++) {
                //Process exception here
                Logger.debugException('Error in Creating Email Log Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
    }
    
    //List of Assigment related to the UEH Inbound Object.
    List<Attachment> attachLst = new List<Attachment>();
    //Map to create the List of Attachment having key as Id of UEH Inbound Email Log Object.
    Map<Id, List<Attachment>> attachElogMap = new Map<Id, List<Attachment>>();
    
    //Creating Attachment Data.
    for(UEH_Inbound_Email_Log__c eLogObj : uehElogLst){
        Attachment attachObj = new Attachment();  
        attachObj.ParentId = eLogObj.Id;  
        attachObj.Name = 'Test Attachment';  
        Blob attachBody = Blob.valueOf('Test Data');
        attachObj.Body = attachBody;  
        
        attachLst.add(attachObj);
    }
    insert attachLst;
    
    
    // Creating Set to pass the Set of Id as Argument in Method.
    List<Id> uehLstObj = new List<Id>();
    for(UEH_Inbound_Email_Log__c tempuehObj : uehElogLst){
        uehLstObj.add(tempuehObj.Id);
    }
    
    // Create the Set Id for the Method Paramenter.
    Set<Id> eLogSet = new Set<Id>();
    // List of the Wrapper Class to store the Wrapper Class Records.
    List<UEH_EmailEnvelopeWrapper> wrapperObjTestLst = new List<UEH_EmailEnvelopeWrapper>();
    // Map of Id and Wrapper class to get the Return.
    Map<Id, UEH_EmailEnvelopeWrapper> wrapperObjTestMap = new Map<Id, UEH_EmailEnvelopeWrapper>();
    //List of the UEH Inbound Email Log Object to save the Records from Query.
    List<UEH_Inbound_Email_Log__c> uehObjLst = new List<UEH_Inbound_Email_Log__c>();
    
    //Test Starts
    test.startTest();
    
    //Querying the insert Records.
    uehObjLst = [SELECT Id, UEH_Email_From_Address__c, UEH_Email_CC_Addresses__c, UEH_Email_from_Name__c, UEH_Email_HTML_Body__c,
                UEH_Email_in_Reply_To__c, UEH_Email_Message_Id__c, UEH_Email_Header__c, UEH_Email_References__c, UEH_Email_Reply_To__c, UEH_Email_Subject__c,
                UEH_Email_To_Addresses__c, UEH_Envelope_From_Address__c, UEH_Envelope_To_Address__c FROM UEH_Inbound_Email_Log__c 
                WHERE Id IN: uehlstObj];
    
    //Storing all the Attachment in a list.
    attachLst = [SELECT Id, Name, ParentId, Body FROM Attachment WHERE ParentId IN: uehObjLst];
    
    //Filling the Map of Attachment with its respective UEH Inbound Email Log Object Id.
    for(Attachment attachObj : attachLst){
        if(!attachElogMap.containsKey(attachObj.ParentId)){
        attachElogMap.put(attachObj.ParentId, new List<Attachment> {attachObj});
        } 
        else{
            attachELogMap.get(attachObj.parentId).add(attachObj);
        }
        
    }
    
    //Adding the UEH_Inbound_Email_Log__c id in the Set.
    for(UEH_Inbound_Email_Log__c eListLog : uehObjLst){
        eLogSet.add(eListLog.Id);
    }
    
      // Call the getEmailMapFromLogLst Method in UEH_EmailMessageUtils Class and Save it in the Map.
      wrapperObjTestMap = UEH_MessageLoggingUtils.getEmailMapFromLogLst(eLogSet);
     
      // Add the Record from Map into Wrapper Class List.
      for(Id elogLstObj : eLogSet){
          wrapperObjTestLst.add(wrapperObjTestMap.get(elogLstObj));
      }
    List<String> headerLst = new List<String>();
    // Asserting the UEH_Inbound_Email_Log__c test Records.
    for(i=0; i<=199; i++){
        System.assertEquals(wrapperObjTestLst[i].emailFromAddress, uehObjLst[i].UEH_Email_From_Address__c);
        System.assertEquals(wrapperObjTestLst[i].emailCCAddresses, uehObjLst[i].UEH_Email_CC_Addresses__c);
        System.assertEquals(wrapperObjTestLst[i].emailFromName, uehObjLst[i].UEH_Email_from_Name__c);
        System.assertEquals(wrapperObjTestLst[i].emailHtmlBody, uehObjLst[i].UEH_Email_HTML_Body__c);
        System.assertEquals(wrapperObjTestLst[i].emailHeaderList,uehObjLst[i].UEH_Email_Header__c.split('&'));
        System.assertEquals(wrapperObjTestLst[i].emailInReplyTo, uehObjLst[i].UEH_Email_in_Reply_To__c);
        System.assertEquals(wrapperObjTestLst[i].emailMessageId, uehObjLst[i].UEH_Email_Message_Id__c);
        System.assertEquals(wrapperObjTestLst[i].emailReferences, uehObjLst[i].UEH_Email_References__c);
        System.assertEquals(wrapperObjTestLst[i].emailReplyTo, uehObjLst[i].UEH_Email_Reply_To__c);
        System.assertEquals(wrapperObjTestLst[i].emailSubject, uehObjLst[i].UEH_Email_Subject__c);
        System.assertEquals(wrapperObjTestLst[i].emailToAddresses, uehObjLst[i].UEH_Email_To_Addresses__c);
        System.assertEquals(wrapperObjTestLst[i].envelopeFromAddress, uehObjLst[i].UEH_Envelope_From_Address__c);
        System.assertEquals(wrapperObjTestLst[i].envelopeToAddress, uehObjLst[i].UEH_Envelope_To_Address__c);
        System.assertEquals(wrapperObjTestLst[i].emailAttachment.size(), attachELogMap.get(uehObjLst[i].Id).size());
    }
    // Stop test.
    test.stopTest();
    
    
    }
    
    /*
       *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
       *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks 
       *@Date Original:   15 August 2015
       *@Last Modified:   15 August 2015
       *@param            none.
       *@return           void
       *@Description:     Create test data from Message Inbound Email and check if 
                          attachments has been created properly.
       */ 
       
       public static testMethod void CreateAttchmentsTest(){
        
       Test.startTest();  
           
       //re-create Bypass Trigger Custom Setting
       csb.buildBypassTriggerSettings();
           
       Partner_Agreement__c agreeObj = new  Partner_Agreement__c();
       Insert agreeObj;
       
       //Create Test Account
       Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
       accNL.Name = 'EmailTest' + 0;
       Insert accNL;
                 
       //Create test Contact
        Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
        cnt.email = 'personenvelopefromaddress@gmail.com';
        insert cnt;     
           
       //Getting the Reference Id.
       //UEH_MessageParsingUtils.refOrgId = UEH_MessageParsingUtils.getReferenceOrgID();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
        emailObj.Subject = 'Email Logging Case ' + refId;
        emailObj.FromAddress = 'personemailfromaddress@gmail.com';
        emailObj.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        emailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        emailObj.ToAddresses = new String[] {'person@gmail.com'};
        emailObj.CCAddresses = new String[] {'user@gmail.com'};
        emailObj.fromName = 'User Name';
        emailObj.htmlBodyIsTruncated = False;
        emailObj.replyTo = 'personemailfromaddress@gmail.com';
        emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        emailObj.plainTextBodyIsTruncated = False;
        emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        
        //Creating text Attachment Data
        Messaging.InboundEmail.TextAttachment attachTextFile = new Messaging.InboundEmail.TextAttachment();
        
        attachTextFile.body = 'my attachment text';
        attachTextFile.fileName = 'textfiletwo.txt';
        attachTextFile.mimeTypeSubType = 'texttwo/plain';
        emailObj.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile };
          
        //Createing Binary Attachment Data.  
        Messaging.InboundEmail.BinaryAttachment attachBinaryFile = new Messaging.InboundEmail.BinaryAttachment();
          
        attachBinaryFile.body = blob.valueOf('my attachment text');
        attachBinaryFile.fileName = 'textfileone.txt';
        attachBinaryFile.mimeTypeSubType = 'text/plain';
        emailObj.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile };
        
        UEH_MessageLoggingUtils.createAttachments(emailObj,agreeObj.Id,agreeObj.Id,cnt.id,agreeObj.ownerId);
            
        List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: agreeObj.Id];
        //Checking if the Attachment are inserted.
        System.assertEquals(attchList != null, True);
        
        for(Attachment atchObj : attchList){
            System.assertEquals(atchObj.BodyLength <= 26214400,True);
        }
       
        Test.stopTest();
    }      
    /*
       *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
       *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks 
       *@Date Original:   24 August 2015
       *@Last Modified:   24 August 2015
       *@param            none.
       *@return           void
       *@Description:     Create test data from Message Inbound Email and check if 
                          Task has been created properly.
       */ 
       
       public static testMethod void CreateTaskTest(){
        
       Test.startTest();  
           
       //re-create Bypass Trigger Custom Setting
       csb.buildBypassTriggerSettings();
         
       user testUser = TestDataBuilder.buildTestUser(100);
          
       system.runAs(testUser){
           
       //Create Test Account
       Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
       accNL.Name = 'EmailTest' + 0;
       Insert accNL;
             
       //Create test Contact
       Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
       cnt.email = 'personenvelopefromaddress@gmail.com';
       insert cnt;  
         
       Partner_Agreement__c agreeObj = new  Partner_Agreement__c();
       agreeObj.Primary_Contact__c = cnt.id;  
       agreeObj.OwnerId = testUser.id;
       Insert agreeObj;
           
       User partProgramUsr = TestDataBuilder.buildTestUser(200);
       partProgramUsr.firstName = 'Partner';
       partProgramUsr.lastName = 'Program';
       insert partProgramUsr;
           
       //Getting the Reference Id.
       //UEH_MessageParsingUtils.refOrgId = UEH_MessageParsingUtils.getReferenceOrgID();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
        emailObj.Subject = 'Email Logging Case ' + refId;
        emailObj.FromAddress = 'personemailfromaddress@gmail.com';
        emailObj.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        emailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        emailObj.ToAddresses = new String[] {'person@gmail.com'};
        emailObj.CCAddresses = new String[] {'user@gmail.com'};
        emailObj.fromName = 'User Name';
        emailObj.htmlBodyIsTruncated = False;
        emailObj.replyTo = 'personemailfromaddress@gmail.com';
        emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        emailObj.plainTextBodyIsTruncated = False;
        emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
                
        Id taskId = UEH_MessageLoggingUtils.createTask(emailObj,agreeObj.Id,agreeObj.Primary_Contact__c,agreeObj.ownerid);
         
        System.debug(partProgramUsr+'partProgramUsrpartProgramUsrpartProgramUsrpartProgramUsrpartProgramUsr');
         
        List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description
                                      From Task 
                                      Where WhatId =:agreeObj.id];
           
        System.assertEquals(taskList[0].whatid,agreeObj.id);
        //System.assertEquals(taskList[0].ownerid,partProgramUsr.id);
        System.assertEquals(taskList[0].Type,'Email');
        System.assertEquals(taskList[0].WhoId,agreeObj.Primary_Contact__c);
        System.assertEquals((taskList[0].subject).trim(),('Email: '+emailObj.Subject).trim());
        System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
        System.assertEquals(taskList[0].Description,emailObj.plainTextBody);
           
         
        }
          
       
        Test.stopTest();
    }
    
    
     /*
       *@Author Original:  Shweta Shanbhag - Mathworks 
       *@Last Modified:   Shweta Shanbhag - Mathworks 
       *@Date Original:   2 Feb 2016
       *@Last Modified:   2 Feb 2016
       *@param            none.
       *@return           void
       *@Description:     Create test data from Message Inbound Email that has only HTML mody and no plain text body and check if 
                          Task has been created properly and if the Case substatus has changed from Waiting from Customer to In Progress
       */ 
       
       public static testMethod void CreateTaskHTMLBodyWaitingCustTest(){
        
       Test.startTest();  
           
       //re-create Bypass Trigger Custom Setting
       csb.buildBypassTriggerSettings();
         
       user testUser = TestDataBuilder.buildTestUser(100);
          
       system.runAs(testUser){
           
       //Create Test Account
       Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
       accNL.Name = 'EmailTest' + 0;
       Insert accNL;
             
       //Create test Contact
       Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
       cnt.email = 'personenvelopefromaddress@gmail.com';
       insert cnt;  
           
       //Create new Case with a valid contact and having 'Waiting for Customer' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = cnt.id;
        newCase.OwnerId = testUser.id;
        newCase.SubStatus__c = 'Waiting for Customer';
        insert newCase; 
           
       User partProgramUsr = TestDataBuilder.buildTestUser(200);
       partProgramUsr.firstName = 'Partner';
       partProgramUsr.lastName = 'Program';
       insert partProgramUsr;
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
        emailObj.Subject = 'Email Logging Case ' + refId;
        emailObj.FromAddress = 'personemailfromaddress@gmail.com';
        emailObj.plainTextBody = null;
        emailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        emailObj.ToAddresses = new String[] {'person@gmail.com'};
        emailObj.CCAddresses = new String[] {'user@gmail.com'};
        emailObj.fromName = 'User Name';
        emailObj.htmlBodyIsTruncated = False;
        emailObj.replyTo = 'personemailfromaddress@gmail.com';
        emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        emailObj.plainTextBodyIsTruncated = False;
        emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
                
        Id taskId = UEH_MessageLoggingUtils.createTask(emailObj,newCase.Id,newCase.ContactId,newCase.ownerid);
         
       
         
        List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description,Status
                                      From Task 
                                      Where WhatId =:newCase.id];
           
        List<Case> createdCases = [SELECT Status,SubStatus__c,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
           
        System.assertEquals(taskList[0].whatid,newCase.id);
        System.assertEquals(taskList[0].Type,'Email');
        System.assertEquals(taskList[0].WhoId,newCase.ContactId);
        System.assertEquals((taskList[0].subject).trim(),('Email: '+emailObj.Subject).trim());
        System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
        System.assertEquals(taskList[0].Description,null);
        System.assertEquals(taskList[0].Status, 'In Progress');
        System.assertEquals(createdCases[0].SubStatus__c,'In Progress');           
        }
              
        Test.stopTest();
    }
    
    /*
       *@Author Original:  Shweta Shanbhag - Mathworks 
       *@Last Modified:   Shweta Shanbhag - Mathworks 
       *@Date Original:   2 Feb 2016
       *@Last Modified:   2 Feb 2016
       *@param            none.
       *@return           void
       *@Description:     Create test data from Message Inbound Email that has only HTML mody and no plain text body and check if 
                          Task has been created properly and the category and if the case substatus is updated.
       */ 
       
       public static testMethod void CreateTaskHTMLBodyDEVIDTest(){
        
       Test.startTest();  
           
       //re-create Bypass Trigger Custom Setting
       csb.buildBypassTriggerSettings();
         
       user testUser = TestDataBuilder.buildTestUser(100);
          
       system.runAs(testUser){
           
       //Create Test Account
       Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
       accNL.Name = 'EmailTest' + 0;
       Insert accNL;
             
       //Create test Contact
       Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
       cnt.email = 'personenvelopefromaddress@gmail.com';
       insert cnt;  
           
       //Create new Case with a valid contact and having 'Waiting for Internal' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = cnt.id;
        newCase.OwnerId = testUser.id;
        newCase.SubStatus__c = 'Waiting for Internal';
        insert newCase; 
         
        Case insertedCase = [SELECT CaseNumber FROM Case WHERE id = :newCase.id ];
           
       User partProgramUsr = TestDataBuilder.buildTestUser(200);
       partProgramUsr.firstName = 'Partner';
       partProgramUsr.lastName = 'Program';
       insert partProgramUsr;
           
       //Getting the Reference Id.
       //UEH_MessageParsingUtils.refOrgId = UEH_MessageParsingUtils.getReferenceOrgID();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
        emailObj.Subject = 'Email Logging Case ' + refId;
        emailObj.FromAddress = 'personemailfromaddress@gmail.com';
        emailObj.plainTextBody = null;
        emailObj.htmlBody = '<html><title>This s A test mail </title><body> [DEVID' + refId + ' ' + insertedCase.CaseNumber + ' email body</body></html>';
        emailObj.ToAddresses = new String[] {'person@gmail.com'};
        emailObj.CCAddresses = new String[] {'user@gmail.com'};
        emailObj.fromName = 'User Name';
        emailObj.htmlBodyIsTruncated = False;
        emailObj.replyTo = 'personemailfromaddress@gmail.com';
        emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        emailObj.plainTextBodyIsTruncated = False;
        emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
                
        Id taskId = UEH_MessageLoggingUtils.createTask(emailObj,newCase.Id,newCase.ContactId,newCase.ownerid);
         
       
         
        List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description,Status
                                      From Task 
                                      Where WhatId =:newCase.id];
           
        List<Case> createdCases = [SELECT Status,SubStatus__c,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
           
        System.assertEquals(taskList[0].whatid,newCase.id);
        System.assertEquals(taskList[0].Type,'Email');
        System.assertEquals(taskList[0].WhoId,newCase.ContactId);
        System.assertEquals((taskList[0].subject).trim(),('Email: '+emailObj.Subject).trim());
        System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
        System.assertEquals(taskList[0].Description,null);
        System.assertEquals(taskList[0].Status, 'In Progress');
        System.assertEquals(createdCases[0].SubStatus__c,'In Progress');
        }
          
       
        Test.stopTest();
    }
    
    public static testMethod void EmailwithManyToAddressesTest(){
       //Getting the Reference Id.
       //UEH_MessageParsingUtils.refOrgId = UEH_MessageParsingUtils.getReferenceOrgID();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
        List<String> toaddressesList = new List<String>{'person@gmail.com','person1@gmail.com','person2@gmail.com','person3@gmail.com','person4@gmail.com','person5@gmail.com','person6@gmail.com','person7@gmail.com','person8@gmail.com','person9@gmail.com','person10@gmail.com'};
        
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail lessCharEmailObj = new Messaging.InboundEmail();
        lessCharEmailObj.Subject = 'Email Logging Case ' + refId;
        lessCharEmailObj.FromAddress = 'personemailfromaddress@gmail.com';
        lessCharEmailObj.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        lessCharEmailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        lessCharEmailObj.ToAddresses = toaddressesList;
        lessCharEmailObj.CCAddresses = new String[] {'user@gmail.com'};
        lessCharEmailObj.fromName = 'User Name';
        lessCharEmailObj.htmlBodyIsTruncated = False;
        lessCharEmailObj.replyTo = 'personemailfromaddress@gmail.com';
        lessCharEmailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        lessCharEmailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        lessCharEmailObj.plainTextBodyIsTruncated = False;
        lessCharEmailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        
        //Creating Envelope data
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelopetoaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
        String Status = 'Accepted';    
        
        
        
        
        //run test
        Test.startTest();
           Id emailLogId = UEH_MessageLoggingUtils.CreateInBoundEmailLog(lessCharEmailObj, envelopeObj, Status,'');
           UEH_Inbound_Email_Log__c elogObj = [SELECT Id FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId];
           System.assertEquals(emailLogId, elogObj.Id);
           
        //Get all the Field for Quering all the Object Fields data.
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.UEH_Inbound_Email_Log__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
    
        String querystr = 'SELECT ';
        
        for(Schema.SObjectField s : fldObjMapValues)
        {
           String labelName = s.getDescribe().getLabel(); 
           String fieldName = s.getDescribe().getName();
           
          
           querystr += fieldName + ',';
           
        }
        
        
        querystr = querystr.subString(0, querystr.length() - 1);
        
        
        querystr += ' FROM UEH_Inbound_Email_Log__c WHERE ((UEH_Email_From_Address__c =\''+ lessCharEmailObj.FromAddress +'\') AND (UEH_Envelope_To_Address__c =\''+envelopeObj.toAddress +'\')) ';
                
        
        UEH_Inbound_Email_Log__c[] elogLst = Database.query(querystr);
        String toaddressesString='';
        for(String toaddr:toaddressesList){
            toaddressesString+=toaddr +'; ';
        }
        
        
        System.Debug('toaddresses::'+elogLst[0].UEH_Email_To_Addresses__c+'::');
      
                                       
        // Asserting for the Messaging.InboundEmail lessCharEmail Object.
        System.assertEquals(elogLst[0].UEH_Email_From_Address__c, lessCharEmailObj.FromAddress);
        System.assertEquals(elogLst[0].UEH_Email_To_Addresses__c, toaddressesString.trim());
        System.assertEquals(elogLst[0].UEH_Email_CC_Addresses__c, lessCharEmailObj.CCAddresses[0]+';');
        System.assertEquals(elogLst[0].UEH_Email_Text_Body__c, lessCharEmailObj.plainTextBody);
        System.assertEquals(elogLst[0].UEH_Email_Subject__c, lessCharEmailObj.Subject);
        System.assertEquals(elogLst[0].UEH_Email_HTML_Body__c, lessCharEmailObj.htmlBody);
        System.assertEquals(elogLst[0].UEH_Envelope_To_Address__c, envelopeObj.toAddress);
        System.assertEquals(elogLst[0].UEH_Envelope_From_Address__c, envelopeObj.FromAddress);
        System.assertEquals(elogLst[0].UEH_Status__c, Status);
        System.assertEquals(elogLst[0].UEH_Email_from_Name__c, lessCharEmailObj.fromName);
        System.assertEquals(elogLst[0].UEH_Email_from_Name__c, lessCharEmailObj.fromName);
        System.assertEquals(elogLst[0].UEH_Email_Html_Body_Is_Truncated__c, lessCharEmailObj.htmlBodyIsTruncated);
        System.assertEquals(elogLst[0].UEH_Email_Reply_To__c, lessCharEmailObj.replyTo);
        System.assertEquals(elogLst[0].UEH_Email_Plain_Text_Body_Is_Truncated__c, lessCharEmailObj.plainTextBodyIsTruncated);
        System.assertEquals(elogLst[0].UEH_Email_Message_Id__c, lessCharEmailObj.messageId);
        System.assert(elogLst[0].UEH_Email_References__c != null);    
        
        Test.stopTest();
        
    }  
    
    /*
       *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
       *@Last Modified:    
       *@Date Original:   21 March 2016
       *@Last Modified:   
       *@param            none.
       *@return           void
       *@Description:     This is a test method for test CreateTaskForLargeAttachment Method.
       */ 
    
    public static testMethod void CreateTaskForLargeAttachmentTest(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        user testUser = TestDataBuilder.buildTestUser(100);
          
        system.runAs(testUser){
            String emailAttachmentName = 'Test Attachment';
            //Create test account data
            Account accObj = TestDataBuilder.buildTestAccount(1, testUser.Id);
            insert accObj;
            
            Account createdAcc = [SELECT Id FROM Account WHERE Id =:accObj.Id];
            System.assertEquals(accObj.Id, createdAcc.id);
            
            //Create test Contact data
            Contact conObj = TestDataBuilder.buildTestContact(1, testUser.Id, accObj.Id);
            insert conObj;
            Contact createdCon = [SELECT Id FROM Contact WHERE Id =:conObj.Id];
            System.assertEquals(createdCon.Id, conObj.Id);
            
            //Create test Case data
            Case caseObj = TestDataBuilder.buildTestCase('Open');
            caseObj.ContactId = conObj.Id; 
            insert caseObj;
            
            //Start Test
            test.startTest();
            Id taskId = UEH_MessageLoggingUtils.CreateTaskForLargeAttachment(emailAttachmentName, caseObj.Id, conObj.Id, conObj.OwnerId);
            Task taskObj = [SELECT Id FROM Task WHERE Id =:taskId];
            System.assertEquals(taskObj.Id, taskId);
            //stoptest
            test.stopTest();
        }   
    }
    
    
    /*
       *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
       *@Last Modified:    
       *@Date Original:   21 March 2016
       *@Last Modified:   
       *@param            none.
       *@return           void
       *@Description:     This is a test method for test CreateEmailActivity Method.
       */ 
    
    public static testMethod void CreateEmailActivityTest(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        user testUser = TestDataBuilder.buildTestUser(100);
          
        system.runAs(testUser){
          
            String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
        emailObj.Subject = 'Email Logging Case ' + refId;
        emailObj.FromAddress = 'personemailfromaddress@gmail.com';
        emailObj.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        emailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        emailObj.ToAddresses = new String[] {'person@gmail.com'};
        emailObj.CCAddresses = new String[] {'user@gmail.com'};
        emailObj.fromName = 'User Name';
        emailObj.htmlBodyIsTruncated = False;
        emailObj.replyTo = 'personemailfromaddress@gmail.com';
        emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        emailObj.plainTextBodyIsTruncated = False;
        emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        
        //Creating Envelope data
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelopetoaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
        String Status = 'Accepted';    
        
        //Creating text Attachment Data
        Messaging.InboundEmail.TextAttachment attachTextFile = new Messaging.InboundEmail.TextAttachment();
        
        attachTextFile.body = 'my attachment text';
        attachTextFile.fileName = 'textfiletwo.txt';
        attachTextFile.mimeTypeSubType = 'texttwo/plain';
        emailObj.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile };
          
        //Createing Binary Attachment Data.  
        Messaging.InboundEmail.BinaryAttachment attachBinaryFile = new Messaging.InboundEmail.BinaryAttachment();
          
        attachBinaryFile.body = blob.valueOf('my attachment text');
        attachBinaryFile.fileName = 'textfileone.txt';
        attachBinaryFile.mimeTypeSubType = 'text/plain';
        emailObj.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile };
        
        //Create test Case data
        Case caseObj = TestDataBuilder.buildTestCase('Open');
        insert caseObj;
        Case createdCaseObj = [SELECT Id FROM Case WHERE Id =: caseObj.Id];
        System.assertEquals(createdCaseObj.Id, caseObj.Id);
        
        //Create Test task data
        Task taskObj = TestDataBuilder.buildTestTask(testUser.Id, 'Open', 'Email', 'Test Task Subject');
        insert taskObj;
        Task createdTask = [SELECT Id FROM Task WHERE Id =:taskObj.Id];
        System.assertEquals(createdTask.Id, taskObj.Id);
            
        //run test
        Test.startTest();
            Id emailActivityId = UEH_MessageLoggingUtils.CreateEmailActivity(emailObj, envelopeObj, createdCaseObj.Id, createdTask.id);
            EmailMessage emailmsgObj = [SELECT Id, ParentId from EmailMessage WHERE ParentId =: createdCaseObj.Id]; 
            System.assertEquals(emailmsgObj.Id,emailActivityId);
        Test.stopTest();
        }
    }
        
     /*
       *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
       *@Last Modified:    
       *@Date Original:   21 March 2016
       *@Last Modified:   
       *@param            none.
       *@return           void
       *@Description:     This is a test method for test CreateCaseTest Method.
       */ 
    
    public static testMethod void CreateCaseTest(){
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        user testUser = TestDataBuilder.buildTestUser(100);
          
        system.runAs(testUser){
          
            //Create test account data
            Account accObj = TestDataBuilder.buildTestAccount(1, testUser.Id);
            insert accObj;
            
            Account createdAcc = [SELECT Id FROM Account WHERE Id =:accObj.Id];
            System.assertEquals(accObj.Id, createdAcc.id);
            
            //Create test Contact data
            Contact conObj = TestDataBuilder.buildTestContact(1, testUser.Id, accObj.Id);
            insert conObj;
            Contact createdCon = [SELECT Id FROM Contact WHERE Id =:conObj.Id];
            System.assertEquals(createdCon.Id, conObj.Id);
            
            //Create test Case data
            Case dummycaseObj = TestDataBuilder.buildTestCase('Open');
            dummycaseObj.ContactId = conObj.Id; 
            insert dummycaseObj;  
            
            Case caseObj = [SELECT Id, SubStatus__c, RecordType.Name FROM Case WHERE Id =:dummycaseObj.Id];
            
            //Calling the Email_Routing_Rules__c custom setting.
            csb.buildTestRoutingRule();
            
            List<Email_Routing_Rules__c> emilRoutingRulesLst = [SELECT Id, Area_on_SR__c, Sub_Area_on_SR__c FROM Email_Routing_Rules__c];
                 
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
           
			//Fetching data from UEH General setting
			UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
            emailObj.Subject = 'Email Logging Case ' + refId;
            emailObj.FromAddress = 'personemailfromaddress@gmail.com';
            emailObj.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
            emailObj.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
            emailObj.ToAddresses = new String[] {'person@gmail.com'};
            emailObj.CCAddresses = new String[] {'user@gmail.com'};
            emailObj.fromName = 'User Name';
            emailObj.htmlBodyIsTruncated = False;
            emailObj.replyTo = 'personemailfromaddress@gmail.com';
            emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
            emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
            emailObj.plainTextBodyIsTruncated = False;
            emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
            
            
            //Creating Envelope data
            Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
            envelopeObj.toAddress = 'personenvelopetoaddress@gmail.com';
            envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
            String Status = 'Accepted';    
            
            //Creating text Attachment Data
            Messaging.InboundEmail.TextAttachment attachTextFile = new Messaging.InboundEmail.TextAttachment();
            
            attachTextFile.body = 'my attachment text';
            attachTextFile.fileName = 'textfiletwo.txt';
            attachTextFile.mimeTypeSubType = 'texttwo/plain';
            emailObj.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile };
              
            //Createing Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile = new Messaging.InboundEmail.BinaryAttachment();
              
            attachBinaryFile.body = blob.valueOf('my attachment text');
            attachBinaryFile.fileName = 'textfileone.txt';
            attachBinaryFile.mimeTypeSubType = 'text/plain';
            emailObj.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile };
                
            test.startTest();
            Id caseObjId = UEH_MessageLoggingUtils.CreateCase(emailObj, envelopeObj, emilRoutingRulesLst[0].Area_on_SR__c, emilRoutingRulesLst[0].Sub_Area_on_SR__c, caseObj.SubStatus__c, caseObj.RecordType.Name, createdCon.id);
            
            Case cseCreatedFromEmail = [SELECT Id FROM Case WHERE Id =:caseObjId];
            System.assertEquals(caseObjId, cseCreatedFromEmail.Id);
                
            test.stopTest();    
        }
    }
    
 	/*
 		*@Author Original:  Donna Latte - MathWorks
 		*@Last Modified:
 		*@Date Original:  	13 Jul 2016
 		*@param			  
 		*@return
 		*@Description:   	This is a test method to test updateInBoundEmailLog
 	*/
   public static testMethod void UpdateInboundEmailLogTest() {
   	 	String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
       
        custsettbuild.builtUEHGeneralSetting();
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
		
		//Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail emailObj = new Messaging.InboundEmail();
        emailObj.Subject = 'Test Email Case ' + refId;
        emailObj.FromAddress = 'personemailfromaddress@gmail.com';
        emailObj.plainTextBody = 'Email plain Text Body test for update log ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        emailObj.htmlBody = '<html><title>This is a test email</title><body>Hi i am ' + refId + ' here.</body></html>';
        emailObj.ToAddresses = new String[] {'person@gmail.com'};
        emailObj.CCAddresses = new String[] {'user@gmail.com'};
        emailObj.fromName = 'User Name';
        emailObj.htmlBodyIsTruncated = False;
        emailObj.replyTo = 'personemailfromaddress@gmail.com';
        emailObj.inReplyTo = 'personemailfromaddress@gmail.com';
        emailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        emailObj.plainTextBodyIsTruncated = False;
        emailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        
        //Creating Envelope data
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelopetoaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
        String Status = 'Accepted';
        
        //run test
        Test.startTest();
           Id emailLogId = UEH_MessageLoggingUtils.CreateInBoundEmailLog(emailObj, envelopeObj, Status,'');
           UEH_Inbound_Email_Log__c elog = [SELECT Id, UEH_Status__c FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId];
           System.assertEquals(emailLogId, elog.Id);
           System.assertEquals('Accepted',elog.UEH_Status__c);
           
           //Update Inbound Email Log
           String fieldToUpdate = 'Update';
           Id emailLogId1 = UEH_MessageLoggingUtils.UpdateInboundEmailLog(elog.Id,fieldToUpdate);
           UEH_Inbound_Email_Log__c elog1 = [SELECT UEH_Status__c FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId1];
           System.assertEquals(fieldToUpdate, elog1.UEH_Status__c);
           
    // Stop test.
    test.stopTest();
   }
    
}