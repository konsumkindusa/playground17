/**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
    * @Last Modified by:kishore AN - Cloud Sherpas/Mathworks,
    * @date Original: 26.August.2015, 
    * @LastModified Date :25 September 2015,
    * @description :Test class for UEH_EmailToBookProjectModuleHandler
    */ 
    @istest
    public class UEH_EmailToBookProjectModuleHandlerTest {
        
        //re-create custom setting test records when running the test class
        static CustomSettingsBuilder csb = new CustomSettingsBuilder();
          
        //re-create custom setting test records when running the test class
        static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
       
         /*
          @name         processMessageValidIdTest
          @date         13.August.2015
          @author       Archana Lohar
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageValidIdTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            //Academic_Support_Project__c academicSupObj = new  Academic_Support_Project__c();
            //Insert academicSupObj;
            
            Book_Project__c bookProjObj = new Book_Project__c();
            insert bookProjObj;
             
            //String recId = String.valueOf(academicSupObj.id);
            String recId = String.valueOf(bookProjObj.Id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            
            List<Book_Project__c> bookProjList = [Select Id, Thread_Id__c from Book_Project__c where Id=:bookProjObj.Id];
             
			//Fetching data from UEH General setting
			UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + bookProjList[0].Thread_Id__c;
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
             
            //Creating text Attachment data.
            Messaging.InboundEmail.TextAttachment attachTextFile1 = new Messaging.InboundEmail.TextAttachment();
            
            attachTextFile1.body = 'my attachment text';
            attachTextFile1.fileName = 'textfiletwo.txt';
            attachTextFile1.mimeTypeSubType = 'texttwo/plain';
            inboundEmailMessage.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile1 };
            
            //Creating Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile1 = new Messaging.InboundEmail.BinaryAttachment();
            attachBinaryFile1.body = blob.valueOf('my attachment text');
            attachBinaryFile1.fileName = 'textfileone.txt';
            attachBinaryFile1.mimeTypeSubType = 'text/plain';
            inboundEmailMessage.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile1 };
        
             
            UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
            handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
             
            test.stopTest(); 
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
             
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Status__c,
                             Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c, 
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c
                             from ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProjObj.id];
             
            // Asserting for the Messaging.InboundEmail lessCharEmail Object.
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Address__c, inboundEmailMessage.FromAddress);
            System.assertEquals(e2ALst[0].ortoo_e2a__To_Address__c, inboundEmailMessage.ToAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Cc_Address__c, inboundEmailMessage.CCAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Text_Body__c, inboundEmailMessage.plainTextBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__Subject__c, inboundEmailMessage.Subject);
            System.assertEquals(e2ALst[0].ortoo_e2a__Html_Body__c, inboundEmailMessage.htmlBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Name__c, inboundEmailMessage.fromName);
            System.assertEquals(e2ALst[0].ortoo_e2a__Message_Id__c, inboundEmailMessage.messageId);
            System.assertEquals(e2ALst[0].ortoo_e2a__Incoming__c,true);
            System.assertEquals(e2ALst[0].ortoo_e2a__Status__c,'New');
           
            
          
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
            
            for(Attachment atchObj : attchList){
                System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
            
            
         }
      
        
         /*
          @name         processMessageInValidIdTest
          @date         13.August.2015
          @author       Archana Lohar
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageInValidIdForNatikTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_Recipient_Module_Handler Custom Setting
            custsettbuild.builtUEH_Recipient_Module_Handler();
            
            //re-create  UEH_BookProject_RecipientToQueueMapping__c Custom Setting
            custsettbuild.builtUEHBookProjectRecipientToQueueMapping();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            Messaging.InboundEmail inboundEmailMessage;
            user bookProgramUsr;
             
            user testUser = TestDataBuilder.buildTestUser(100);
             
            system.runAs(testUser){
    
                String refOrgId = userInfo.getOrganizationId();
                String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
                 
				//Fetching data from UEH General setting
				UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
                //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
                inboundEmailMessage = new Messaging.InboundEmail();
                inboundEmailMessage.FromAddress = 'PartnerAgreementTest@mathworks.com';
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
                envelopeObj.toAddress = 'bookprogram@mathworks.com';
                envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
                 
                //Creating text Attachment data.
                Messaging.InboundEmail.TextAttachment attachTextFile1 = new Messaging.InboundEmail.TextAttachment();
                
                attachTextFile1.body = 'my attachment text';
                attachTextFile1.fileName = 'textfiletwo.txt';
                attachTextFile1.mimeTypeSubType = 'texttwo/plain';
                inboundEmailMessage.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile1 };
                
                //Creating Binary Attachment Data.  
                Messaging.InboundEmail.BinaryAttachment attachBinaryFile1 = new Messaging.InboundEmail.BinaryAttachment();
                attachBinaryFile1.body = blob.valueOf('my attachment text');
                attachBinaryFile1.fileName = 'textfileone.txt';
                attachBinaryFile1.mimeTypeSubType = 'text/plain';
                inboundEmailMessage.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile1 };
            
                //Create test Queue
                Group grpObj = new Group(Name='Book Project- Natick', type='Queue');
                insert grpObj;
                QueuesObject queueObj = new QueueSObject(QueueID = grpObj.id, SobjectType = 'Book_Project__c');
                insert queueObj;
                    
                //Create Test Account
                Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
                accNL.Name = 'EmailTest' + 0;
                Insert accNL;
                 
                //Create test Contact
                Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
                cnt.email = 'personenvelopefromaddress@gmail.com';
                //insert cnt;
                
                //Create Test User
                bookProgramUsr = TestDataBuilder.buildTestUser(101);
                bookProgramUsr.FirstName = 'book';
                bookProgramUsr.LastName = 'program';
                insert bookProgramUsr;
                
                system.debug(bookProgramUsr.Alias+'bookProgramUsr');
               
                UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
                handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
              
            }
               
            test.stopTest(); 
            List<Book_Project__c> bookProjLst = new List<Book_Project__c>();
            
            bookProjLst = [select id,OwnerId,owner.type,Status__c,Book_Title__c,Description__c                                      
                                     from Book_Project__c ];
             
            System.assertEquals((bookProjLst[0].Description__c).trim(),(inboundEmailMessage.plainTextBody).trim());
            System.assertEquals(bookProjLst[0].Book_Title__c,inboundEmailMessage.subject);
            System.assertEquals(bookProjLst[0].Status__c,'New');
            System.assertEquals(bookProjLst[0].owner.type,'Queue');
            
            
                
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
           
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Incoming__c,
                             Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,ortoo_e2a__Contact_Id__c,
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Status__c,
                             ortoo_e2a__Has_Attachment__c
                             from ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProjLst[0].id];
             
            // Asserting for the Messaging.InboundEmail lessCharEmail Object.
            System.assertEquals((e2ALst[0].ortoo_e2a__From_Address__c).toLowerCase(), inboundEmailMessage.FromAddress.toLowerCase());
            System.assertEquals(e2ALst[0].ortoo_e2a__To_Address__c, inboundEmailMessage.ToAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Cc_Address__c, inboundEmailMessage.CCAddresses[0]+';');
            System.assertEquals((e2ALst[0].ortoo_e2a__Text_Body__c).trim(),(inboundEmailMessage.plainTextBody).trim());
            System.assertEquals(e2ALst[0].ortoo_e2a__Subject__c, inboundEmailMessage.Subject);
            System.assertEquals(e2ALst[0].ortoo_e2a__Html_Body__c, inboundEmailMessage.htmlBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Name__c, inboundEmailMessage.fromName);
            System.assertEquals(e2ALst[0].ortoo_e2a__Message_Id__c, inboundEmailMessage.messageId);
            System.assertEquals(e2ALst[0].ortoo_e2a__Incoming__c,true);
            System.assertEquals(e2ALst[0].ortoo_e2a__Status__c,'New');
            System.assertEquals(e2ALst[0].ortoo_e2a__Has_Attachment__c,true);
             
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
            
            for(Attachment atchObj : attchList){
                System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
             
            List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description
                                      From Task 
                                      Where WhatId =:bookProjLst[0].id];
           
            System.assertEquals(taskList[0].whatid,bookProjLst[0].id);
            System.assertEquals(taskList[0].ownerid,bookProgramUsr.id);
            System.assertEquals(taskList[0].Type,'Email');
            System.assertEquals((taskList[0].subject).trim(),('Email: '+inboundEmailMessage.Subject).trim());
            System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
            System.assertEquals((taskList[0].Description).trim(),(inboundEmailMessage.plainTextBody).trim());

            
         }
        
         /*
          @name         processMessageValidIdWithoutPlaintextBodyTest
          @date         6.Oct.2015
          @author       Archana Lohar
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageValidIdWithoutPlaintextBodyTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            Book_Project__c bookProjObj = new Book_Project__c();
            insert bookProjObj;
             
            //String recId = String.valueOf(academicSupObj.id);
            String recId = String.valueOf(bookProjObj.Id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            
            List<Book_Project__c> bookProjList = [Select Id, Thread_Id__c from Book_Project__c where Id=:bookProjObj.Id];
             
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.htmlBody = '<html><title>'+bookProjList[0].Thread_Id__c+'</title><body>Hi i am here.</body></html>';
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
             
            //Creating text Attachment data.
            Messaging.InboundEmail.TextAttachment attachTextFile1 = new Messaging.InboundEmail.TextAttachment();
            
            attachTextFile1.body = 'my attachment text';
            attachTextFile1.fileName = 'textfiletwo.txt';
            attachTextFile1.mimeTypeSubType = 'texttwo/plain';
            inboundEmailMessage.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile1 };
            
            //Creating Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile1 = new Messaging.InboundEmail.BinaryAttachment();
            attachBinaryFile1.body = blob.valueOf('my attachment text');
            attachBinaryFile1.fileName = 'textfileone.txt';
            attachBinaryFile1.mimeTypeSubType = 'text/plain';
            inboundEmailMessage.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile1 };
        
             
            UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
            handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
             
            test.stopTest(); 
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
             
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Status__c,
                             Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c, 
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c
                             from ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProjObj.id];
             
            // Asserting for the Messaging.InboundEmail lessCharEmail Object.
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Address__c, inboundEmailMessage.FromAddress);
            System.assertEquals(e2ALst[0].ortoo_e2a__To_Address__c, inboundEmailMessage.ToAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Cc_Address__c, inboundEmailMessage.CCAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Text_Body__c, inboundEmailMessage.plainTextBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__Subject__c, inboundEmailMessage.Subject);
            System.assertEquals(e2ALst[0].ortoo_e2a__Html_Body__c, inboundEmailMessage.htmlBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Name__c, inboundEmailMessage.fromName);
            System.assertEquals(e2ALst[0].ortoo_e2a__Message_Id__c, inboundEmailMessage.messageId);
            System.assertEquals(e2ALst[0].ortoo_e2a__Incoming__c,true);
            System.assertEquals(e2ALst[0].ortoo_e2a__Status__c,'New');
           
            
          
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
            
            for(Attachment atchObj : attchList){
                System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
            
            
         }
      
        /*
          @name         processMessageInValidIdForNatikWithoutPlainTextBodyTest
          @date         6.Oct.2015
          @author       Archana Lohar
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageInValidIdForNatikWithoutPlainTextBodyTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_Recipient_Module_Handler Custom Setting
            custsettbuild.builtUEH_Recipient_Module_Handler();
            
            //re-create  UEH_BookProject_RecipientToQueueMapping__c Custom Setting
            custsettbuild.builtUEHBookProjectRecipientToQueueMapping();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            Messaging.InboundEmail inboundEmailMessage;
            user bookProgramUsr;
             
            user testUser = TestDataBuilder.buildTestUser(100);
             
            system.runAs(testUser){
    
                String refOrgId = userInfo.getOrganizationId();
                String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
                 
                //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
                inboundEmailMessage = new Messaging.InboundEmail();
                inboundEmailMessage.FromAddress = 'PartnerAgreementTest@mathworks.com';
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
                envelopeObj.toAddress = 'bookprogram@mathworks.com';
                envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
                 
                //Creating text Attachment data.
                Messaging.InboundEmail.TextAttachment attachTextFile1 = new Messaging.InboundEmail.TextAttachment();
                
                attachTextFile1.body = 'my attachment text';
                attachTextFile1.fileName = 'textfiletwo.txt';
                attachTextFile1.mimeTypeSubType = 'texttwo/plain';
                inboundEmailMessage.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile1 };
                
                //Creating Binary Attachment Data.  
                Messaging.InboundEmail.BinaryAttachment attachBinaryFile1 = new Messaging.InboundEmail.BinaryAttachment();
                attachBinaryFile1.body = blob.valueOf('my attachment text');
                attachBinaryFile1.fileName = 'textfileone.txt';
                attachBinaryFile1.mimeTypeSubType = 'text/plain';
                inboundEmailMessage.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile1 };
            
                //Create test Queue
                Group grpObj = new Group(Name='Book Project- Natick', type='Queue');
                insert grpObj;
                QueuesObject queueObj = new QueueSObject(QueueID = grpObj.id, SobjectType = 'Book_Project__c');
                insert queueObj;
                    
                //Create Test Account
                Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
                accNL.Name = 'EmailTest' + 0;
                Insert accNL;
                 
                //Create test Contact
                Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
                cnt.email = 'personenvelopefromaddress@gmail.com';
                insert cnt;
                
                //Create Test User
                bookProgramUsr = TestDataBuilder.buildTestUser(101);
                bookProgramUsr.FirstName = 'book';
                bookProgramUsr.LastName = 'program';
                insert bookProgramUsr;
                
                system.debug(bookProgramUsr.Alias+'bookProgramUsr');
               
                UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
                handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
              
            }
               
            test.stopTest(); 
            List<Book_Project__c> bookProjLst = new List<Book_Project__c>(); 
            
            bookProjLst = [select id,OwnerId,owner.type,Status__c,Book_Title__c,Description__c                                      
                                     from Book_Project__c ];
             
            
            System.assertEquals(bookProjLst[0].Book_Title__c,inboundEmailMessage.subject);
            System.assertEquals(bookProjLst[0].Status__c,'New');
            System.assertEquals(bookProjLst[0].owner.type,'Queue');
            
                
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
           
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Incoming__c,
                             Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,ortoo_e2a__Contact_Id__c,
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Status__c,
                             ortoo_e2a__Has_Attachment__c
                             from ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProjLst[0].id];
             
            // Asserting for the Messaging.InboundEmail lessCharEmail Object.
            System.assertEquals((e2ALst[0].ortoo_e2a__From_Address__c).toLowerCase(), inboundEmailMessage.FromAddress.toLowerCase());
            System.assertEquals(e2ALst[0].ortoo_e2a__To_Address__c, inboundEmailMessage.ToAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Cc_Address__c, inboundEmailMessage.CCAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Subject__c, inboundEmailMessage.Subject);
            System.assertEquals(e2ALst[0].ortoo_e2a__Html_Body__c, inboundEmailMessage.htmlBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Name__c, inboundEmailMessage.fromName);
            System.assertEquals(e2ALst[0].ortoo_e2a__Message_Id__c, inboundEmailMessage.messageId);
            System.assertEquals(e2ALst[0].ortoo_e2a__Incoming__c,true);
            System.assertEquals(e2ALst[0].ortoo_e2a__Status__c,'New');
            System.assertEquals(e2ALst[0].ortoo_e2a__Has_Attachment__c,true);
             
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
            
            for(Attachment atchObj : attchList){
                System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
             
            List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description
                                      From Task 
                                      Where WhatId =:bookProjLst[0].id]; 
           
            System.assertEquals(taskList[0].whatid,bookProjLst[0].id);
            System.assertEquals(taskList[0].ownerid,bookProgramUsr.id);
            System.assertEquals(taskList[0].Type,'Email');
            System.assertEquals((taskList[0].subject).trim(),('Email: '+inboundEmailMessage.Subject).trim());
            System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
            
         }
         
        /*
         *@author Original:kishore AN - Cloud Sherpas/Mathworks, Last Modified:
         *@date Original: 23 October 2015, Last Modified: 
         *@description:Test to check if the contact on the e2a email is based on the email from address and not primary contact
         */
        public static testMethod void checkEmailContactTest(){
        
            test.startTest();
        
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
        
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
        
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
        
            //Academic_Support_Project__c academicSupObj = new  Academic_Support_Project__c();
            //Insert academicSupObj;
        
            Book_Project__c bookProjObj = new Book_Project__c();
            insert bookProjObj;
        
            //String recId = String.valueOf(academicSupObj.id);
            String recId = String.valueOf(bookProjObj.Id);
        
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
        
            List<Book_Project__c> bookProjList = [Select Id, Thread_Id__c from Book_Project__c where Id=:bookProjObj.Id];
        
			//Fetching data from UEH General setting
			UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + bookProjList[0].Thread_Id__c;
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
        
            //Creating text Attachment data.
            Messaging.InboundEmail.TextAttachment attachTextFile1 = new Messaging.InboundEmail.TextAttachment();
        
            attachTextFile1.body = 'my attachment text';
            attachTextFile1.fileName = 'textfiletwo.txt';
            attachTextFile1.mimeTypeSubType = 'texttwo/plain';
            inboundEmailMessage.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile1 };
        
            //Creating Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile1 = new Messaging.InboundEmail.BinaryAttachment();
            attachBinaryFile1.body = blob.valueOf('my attachment text');
            attachBinaryFile1.fileName = 'textfileone.txt';
            attachBinaryFile1.mimeTypeSubType = 'text/plain';
            inboundEmailMessage.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile1 };
            
            //Create Test Account
            Account accNL = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
            accNL.Name = 'EmailTest' + 0;
            Insert accNL;
        
            //Create test Contact
            Contact cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
            cnt.email = 'personenvelopefromaddress@gmail.com';
            insert cnt;
        
        
            UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
            handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
        
            test.stopTest(); 
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
        
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Status__c,
                     Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c, 
                     ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                     ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c,ortoo_e2a__Contact_Id__c 
                     from ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProjObj.id];
        
            // Asserting for the Messaging.InboundEmail lessCharEmail Object.
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Address__c, inboundEmailMessage.FromAddress);
            System.assertEquals(e2ALst[0].ortoo_e2a__To_Address__c, inboundEmailMessage.ToAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Cc_Address__c, inboundEmailMessage.CCAddresses[0]+';');
            System.assertEquals(e2ALst[0].ortoo_e2a__Text_Body__c, inboundEmailMessage.plainTextBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__Subject__c, inboundEmailMessage.Subject);
            System.assertEquals(e2ALst[0].ortoo_e2a__Html_Body__c, inboundEmailMessage.htmlBody);
            System.assertEquals(e2ALst[0].ortoo_e2a__From_Name__c, inboundEmailMessage.fromName);
            System.assertEquals(e2ALst[0].ortoo_e2a__Message_Id__c, inboundEmailMessage.messageId);
            System.assertEquals(e2ALst[0].ortoo_e2a__Incoming__c,true);
            System.assertEquals(e2ALst[0].ortoo_e2a__Status__c,'New');
            System.assertEquals(e2ALst[0].ortoo_e2a__Contact_Id__c, cnt.Id);
        
        
        
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
        
            for(Attachment atchObj : attchList){
            System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
        
        
        }
    
    }