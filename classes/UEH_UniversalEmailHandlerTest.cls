/**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
    * @Last Modified by:
    * @date Original: 8.August.2015, 
    * @LastModified Date : 
    * @description :
    */
  @isTest  
  public class UEH_UniversalEmailHandlerTest {
      
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
      
    //re-create custom setting test records when running the test class
    static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
      
      /*
      @name         EmailMessageWithValidThreadIdTest
      @date         8.August.2015
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of UniversalEmailHandler - For Email Message with Valid Thread Id
    */
     public static testMethod void EmailMessageWithValidThreadIdTest(){ 
     
        test.startTest();
         
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler();
        
        Case cseObj = TestDataBuilder.buildTestCase('Open');
        Insert cseObj;
        
         Academic_Support_Project__c academicSupObj = new  Academic_Support_Project__c();
         Insert academicSupObj;
        
        String recId = String.valueOf(cseObj.id);
         
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
        List<Case> caseList = [Select id, email_Ref_Id__c from Case where Id=: cseObj.Id];
         List<Academic_Support_Project__c> academicSuppList = [select Id, Thread_Id__c from Academic_Support_Project__c where Id = :academicSupObj.Id];
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + academicSuppList[0].Thread_Id__c;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
         
        System.assertEquals(emailLogObjList[0].UEH_Status__c,'Accepted:Routed');
        System.assert(emailLogObjList[0].UEH_Status__c == 'Accepted:Routed');
        System.assert(emailLogObjList[0].Module_Name__c == 'UEH_EmailToAcademicSupportModuleHandler');
         
        test.stopTest();
         
     }
      
     /*
      @name         EmailMessageWithInValidThreadIdTest
      @date         8.August.2015
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of UniversalEmailHandler - For Email Message with InValid Thread Id
    */
     public static testMethod void EmailMessageWithInValidThreadIdTest(){ 
     
        test.startTest();
       
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler();
      
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + 'ref:_00De05VmMk._500e08PLSJ:ref';
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
         
        System.assert(emailLogObjList[0].UEH_Status__c == 'Accepted : moduleNotFound');
        
        test.stopTest(); 
     }
      
      /*
      @name         EmailMessageWithInValidThreadIdWithExceptionTest
      @date         14.Oct.2015
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of UniversalEmailHandler - For Email Message with InValid Thread Id
    */
     public static testMethod void EmailMessageWithInValidThreadIdWithExceptionTest(){ 
     
        test.startTest();
       
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();
      
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char';
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'fakeadress@mathwork.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
         
        System.assertEquals(emailLogObjList[0].UEH_Status__c,'Accepted:Failed to Instantiate');
        
        test.stopTest();  
     }
      
     
   /*
      @name         EmailmessageWithSenderInBlacklistTest
      @date         9.August.2015
      @author       Archana lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of blacklist checking of sender
     */
     public static testMethod void EmailmessageWithSenderInBlacklistTest(){ 
     
     test.startTest();
       
        
        //Inserting BlackList_Custom_Setting__c 
        custsettbuild.builtUEH_Sender_BlacklistForUniversalEmailHandler();
         
        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();
      
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'verma.abhay092@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' ;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
         
        System.assert(emailLogObjList[0].UEH_Status__c == 'Blocked:Sender Blacklist');
         
        test.stopTest();
        
     }
      
      
   /*
      @name         EmailmessageWithSenderInWhiteListModuleNotFoundTest
      @date         11.August.2015
      @author       Archana lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of whilelist checking of sender and when there is not module for further processing
     */
     public static testMethod void EmailmessageWithSenderInWhiteListModuleNotFoundTest(){ 
     
     test.startTest();
       
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler();
         
        //Inserting BlackList_Custom_Setting__c 
        custsettbuild.builtUEH_Sender_WhitelistForUniversalEmailHandler();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'whiteListuser@servicemail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' ;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
         
        System.assert(emailLogObjList[0].UEH_Status__c == 'Accepted : moduleNotFound');
        
        test.stopTest();
     }

     /*
      @name         EmailmessageWithSenderInWhiteListModuleFoundTest
      @date         11.August.2015
      @author       Archana lohar 
      @param        none.
      @return       Void. 
      @description  Check the functionality of whilelist checking of sender and when there is  module for further processing
     */
     public static testMethod void EmailmessageWithSenderInWhiteListModuleFoundTest(){ 
     
     test.startTest();
       
         
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();
         
        //Inserting BlackList_Custom_Setting__c 
        custsettbuild.builtUEH_Sender_WhitelistForUniversalEmailHandler();
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'supportTest@mathworks.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' ;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'supporttest@mathworks.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
         
        System.debug(emailLogObjList+'emailLogObjList');
       
        System.assert(emailLogObjList[0].UEH_Status__c == 'Accepted:Routed');
        System.assert(emailLogObjList[0].Module_Name__c == 'SampleEmailToSObjectModuleHandler');   
        
        test.stopTest();
     }
      
      /*
      @name         EmailmessageWithoutthreadIdTest
      @date         11.August.2015
      @author       Archana lohar 
      @param        none.
      @return       Void. 
      @description  Check the functionality when there is no thread id present in subject as well as body
     */
     public static testMethod void EmailmessageWithoutThreadIdTest(){ 
     
     test.startTest();
       
       
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'supportTest123@mathworks.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' ;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'supportTest123@mathworks.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
         
        List<UEH_Inbound_Email_Log__c> emailLogObjList = new List<UEH_Inbound_Email_Log__c>();
         
        emailLogObjList = [select id,UEH_Status__c,Module_Name__c from UEH_Inbound_Email_Log__c];
       
        System.assert(emailLogObjList[0].UEH_Status__c == 'Accepted : moduleNotFound');
        
        test.stopTest();        
     }
      
      /*
      @name         EmailmessageSpamTest
      @date         11.August.2015
      @author       Archana lohar 
      @param        none.
      @return       Void. ing
      @description  Check the functionality when the email message is spam.
     */
     public static testMethod void EmailmessageSpamTest(){ 
     
        test.startTest();
        //Inserting UEHMessageCheckingSettings__c 
        custsettbuild.builtUEHMessageCheckingSettings(); 
         
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' ;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.Subject = 'TestEmail';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
            
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
            
        Id emailLogId = UEH_MessageLoggingUtils.CreateInBoundEmailLog(inboundEmailMessage, envelopeObj, 'Accepted','');
        System.assert(emailLogId != null);
         
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);       
        
        test.stopTest();
        
     }
      
     /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 Dec 2015, Last Modified: 7 Dec 2015
    * @description: - Test Method to mock customer replying to User change email field autoresponse using plaintextbody field.
    */ 
    static testMethod void testUserChangeEmailWithPlainTextBody(){
        //Test 
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        
        //Create a new user
        User newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        //Create an Account associated with the user
        Account newAccount = TestDataBuilder.buildTestAccount(1, newUser.id);
        insert newAccount;
        
        //Create a contact related to Account.
        String senderEmail = 'newContactEmail@email.com';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        // setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address:    TUser1@mathworks.com New email address: test@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    }
    
   /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 Dec 2015, Last Modified: 7 Dec 2015
    * @description: - Test Method to mock customer replying to User change email field autoresponse with Previous Email Address
    */ 
    static testMethod void testUserChangeEmailWithPreviousEmailAddress(){
        //Test 
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        csb.buildEmailToCaseOverrideSetting();
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        
        //Create a new user
        User newUser = TestDataBuilder.buildTestUser(1);
        newUser.Email = 'service@mathworks.com';
        insert newUser;
        
        //Create an Account associated with the user
        Account newAccount = TestDataBuilder.buildTestAccount(1, newUser.id);
        insert newAccount;
        
        //Create a contact related to Account.
        String senderEmail = 'newContactEmail@email.com';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        // setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address:    service@mathworks.com New email address: test@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'service@mathworks.com'};
        env.toAddress = 'emailhandler@7xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    } 
    
   /** 
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 Dec 2015, Last Modified: 7 Dec 2015
    * @description: - Test Method to mock customer replying to User change email field autoresponse using plaintextbody field.
    */ 
    static testMethod void testUserChangeEmailWithPlainTextBodyWithoutPreviousEmail(){
        //Test 
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        
        //Create a new user
        User newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        //Create an Account associated with the user
        Account newAccount = TestDataBuilder.buildTestAccount(1, newUser.id);
        insert newAccount;
        
        //Create a contact related to Account.
        String senderEmail = 'newContactEmail@email.com';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        //setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com New email address: test@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    } 
    
    /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 Dec 2015, Last Modified: 7 Dec 2015
    * @description: - Test Method to mock customer replying to User change email field autoresponse using plaintextbody field.
    */ 
    static testMethod void testUserChangeEmailWithHtmlBody(){
        //Test 
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        
        //Create a new user
        User newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        //Create an Account associated with the user
        Account newAccount = TestDataBuilder.buildTestAccount(1, newUser.id);
        insert newAccount;
        
        //Create a contact related to Account.
        String senderEmail = 'newContactEmail@email.com';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        // setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address:    TUser1@mathworks.com New email address: test@mathworks.com';
        email.htmlBody = '<p>This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address:    TUser1@mathworks.com New email address: test@mathworks.com</p>';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
		
        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    } 
    
    /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
    * @date Original: 7 Dec 2015, Last Modified: 7 Dec 2015
    * @description: - Test Method to mock customer replying to User change email field autoresponse using plaintextbody field.
    */ 
    static testMethod void testUserChangeEmailWithHtmlBodyWithoutPreviousEmail(){
        //Test 
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        
        //Create a new user
        User newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;
        
        //Create an Account associated with the user
        Account newAccount = TestDataBuilder.buildTestAccount(1, newUser.id);
        insert newAccount;
        
        //Create a contact related to Account.
        String senderEmail = 'newContactEmail@email.com';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;      
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        // setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com New email address: test@mathworks.com';
        email.htmlBody = '<p>This is a test email body '+ 'User name: TUser1@mathworks.com  New email address: test@mathworks.com</p>';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'supporte@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
        handlerClass.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    }
}