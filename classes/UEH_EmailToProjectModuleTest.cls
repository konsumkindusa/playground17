/**
	* @author Original:Haigang Wu - Mathworks, Last Modified:
	* @date Original: 20 July 2016, Last Modified:
    * @description :Test class for UEH_EmailToProjectModuleHandler
    */ 
    @istest
    public class UEH_EmailToProjectModuleTest {
        
        //re-create custom setting test records when running the test class
        static CustomSettingsBuilder csb = new CustomSettingsBuilder();
          
        //re-create custom setting test records when running the test class
        static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
       
        /*
          @name         processMessageTest
          @date         20.July.2016
          @author       Haigang Wu
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageValidIdTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            csb.buildGenSetting();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
             
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            MW_Project__c projectObj = new MW_Project__c();
            projectObj.Purpose__c = 'Territory Support';
            projectObj.Outcome__c = 'Deep Technical Engagement';
            projectObj.Expected_Date_Time__c = system.today() + 7;
            projectObj.Project_Status__c = 'Open';
            projectObj.Technical_Resource_Group__c = 'Technical Evangelist';
            projectObj.Office__c = 'Natick';
            projectObj.RecordTypeId = Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
            Insert projectObj;
             
            String recId = String.valueOf(projectObj.id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            
            List<MW_Project__c> proList = [Select Id, Thread_Id__c from MW_Project__c where Id = :projectObj.Id];
             
			//Fetching data from UEH General setting
			UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + proList[0].Thread_Id__c;
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
                             Project__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c
                             from ortoo_e2a__EmailMessage__c where Project__c=:projectObj.id];
             
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
          @date         20 July 2016
          @author       Haigang Wu
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageInValidIdTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            csb.buildGenSetting();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
             
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_Recipient_Module_Handler();
             
            //re-create ProjectRecipientToQueueMapping__c Custom Setting
            //custsettbuild.builtUEHProjectRecipientToQueueMapping();
        
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
             
            Messaging.InboundEmail inboundEmailMessage;
            Contact cnt;
            Group grpObj;
            User taskOwner;
             
            user testUser = TestDataBuilder.buildTestUser(100);
             
            system.runAs(testUser){
                  
                String refOrgId = userInfo.getOrganizationId();
                String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
                 
				//Fetching data from UEH General setting
				UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
                //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
                inboundEmailMessage = new Messaging.InboundEmail();
                inboundEmailMessage.FromAddress = 'ProjectTest@mathworks.com';
                inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ';
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
                envelopeObj.toAddress = 'proect@mathworks.com';
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
                cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
                cnt.email = 'personenvelopefromaddress@gmail.com';
                insert cnt;
                 
                //Create test Queue
                grpObj = new Group(Name='Japan Partner Agreements', type='Queue');
                insert grpObj;
                QueuesObject queueObj = new QueueSObject(QueueID = grpObj.id, SobjectType = 'MW_Project__c');
                insert queueObj;
                
                //Create Test User
                taskOwner = TestDataBuilder.buildTestUser(101);
                taskOwner.FirstName = 'Partner';
                taskOwner.LastName = 'Program';
                insert taskOwner;
                
                UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
                handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
                
            }
            test.stopTest(); 
             
            List<MW_Project__c> proList = new List<MW_Project__c>();
            
            proList = [select id,Project_Name__c,Application_of_Interest__c,
                                       Customer_Contact__c,Account__c,ownerid
                                       from MW_Project__c];
          
            System.assertEquals((proList[0].Application_of_Interest__c).trim(),(inboundEmailMessage.plainTextBody).trim());
            //System.assertEquals(proList[0].Project_Name__c,inboundEmailMessage.subject);
            System.assertEquals(proList[0].Customer_Contact__c,cnt.id);
             
                
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
           
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Incoming__c,
                             Project__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,ortoo_e2a__Contact_Id__c,
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Status__c,
                             ortoo_e2a__Has_Attachment__c
                             from ortoo_e2a__EmailMessage__c where Project__c=:proList[0].id];
             
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
            System.assertEquals(e2ALst[0].ortoo_e2a__Contact_Id__c ,cnt.id);
            System.assertEquals(e2ALst[0].ortoo_e2a__Has_Attachment__c ,true);
            
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
            
            for(Attachment atchObj : attchList){
                System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
             
            List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description
                                      From Task 
                                      Where WhatId =:proList[0].id];
           
            System.assertEquals(taskList[0].whatid,proList[0].id);
            //System.assertEquals(taskList[0].ownerid,taskOwner.id);
            System.assertEquals(taskList[0].Type,'Email');
            System.assertEquals(taskList[0].WhoId,proList[0].Customer_Contact__c);
            System.assertEquals((taskList[0].subject).trim(),('Email: '+inboundEmailMessage.Subject).trim());
            System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
            System.assertEquals((taskList[0].Description).trim(),(inboundEmailMessage.plainTextBody).trim());
            
         }
        
          /*
          @name         processMessageValidIdWithoutPlainTextBodyTest
          @date         13.August.2015
          @author       Archana Lohar
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageValidIdWithoutPlainTextBodyTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            csb.buildGenSetting();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
             
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
             
            
            MW_Project__c projectObj = new  MW_Project__c();
            projectObj.Purpose__c = 'Territory Support';
            projectObj.Outcome__c = 'Deep Technical Engagement';
            projectObj.Expected_Date_Time__c = system.today() + 7;
            projectObj.Project_Status__c = 'Open';
            projectObj.Technical_Resource_Group__c = 'Technical Evangelist';
            projectObj.Office__c = 'Natick';
            projectObj.RecordTypeId = Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
            Insert projectObj;
             
            String recId = String.valueOf(projectObj.id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            List<MW_Project__c> proList = [Select Id, Thread_Id__c from MW_Project__c where Id = :projectObj.Id];
             
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.htmlBody = '<html><title>'+proList[0].Thread_Id__c+'</title><body>Hi i am here.</body></html>';
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
                             Project__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c
                             from ortoo_e2a__EmailMessage__c where Project__c=:projectObj.id];
             
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
          @name         processMessageInValidIdWithoutPlainTextBodyTest
          @date         6.Oct.2015
          @author       Archana Lohar
          @param        none.
          @return       Void. 
          @description  Check the functionality processMessage method
        */
         public static testMethod void processMessageInValidIdWithoutPlainTextBodyTest(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            csb.buildGenSetting();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
             
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_Recipient_Module_Handler();
             
            //re-create ProjectRecipientToQueueMapping__c Custom Setting
            //custsettbuild.builtUEHProjectRecipientToQueueMapping();
        
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
             
            Messaging.InboundEmail inboundEmailMessage;
            Contact cnt;
            Group grpObj;
            User taskOwner;
             
            user testUser = TestDataBuilder.buildTestUser(100);
             
            system.runAs(testUser){
                  
                String refOrgId = userInfo.getOrganizationId();
                String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
                 
                //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
                inboundEmailMessage = new Messaging.InboundEmail();
                inboundEmailMessage.FromAddress = 'ProjectTest@mathworks.com';
                inboundEmailMessage.htmlBody = '<html><title></title><body>Hi i am here.</body></html>';
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
                envelopeObj.toAddress = 'proect@mathworks.com';
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
                cnt = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accNL.Id);
                cnt.email = 'personenvelopefromaddress@gmail.com';
                insert cnt;
                 
                //Create test Queue
                grpObj = new Group(Name='Japan Partner Agreements', type='Queue');
                insert grpObj;
                QueuesObject queueObj = new QueueSObject(QueueID = grpObj.id, SobjectType = 'MW_Project__c');
                insert queueObj;
                
                //Create Test User
                taskOwner = TestDataBuilder.buildTestUser(101);
                taskOwner.FirstName = 'Partner';
                taskOwner.LastName = 'Program';
                insert taskOwner;
                
                UEH_UniversalEmailHandler handlerClass = new UEH_UniversalEmailHandler();
                handlerClass.handleInboundEmail(inboundEmailMessage, envelopeObj);
                
            }
             
            test.stopTest(); 
            List<MW_Project__c> proList = new List<MW_Project__c>();
            
            proList = [select id,Project_Name__c,Application_of_Interest__c,
                                       Customer_Contact__c,Account__c,ownerid
                                       from MW_Project__c];
          
            //System.assertEquals((proList[0].Application_of_Interest__c).trim(),(inboundEmailMessage.plainTextBody).trim());
            //System.assertEquals(proList[0].Project_Name__c,inboundEmailMessage.subject);
            System.assertEquals(proList[0].Customer_Contact__c,cnt.id);
             
                
            List<ortoo_e2a__EmailMessage__c> e2ALst = new List<ortoo_e2a__EmailMessage__c>();
           
            e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Incoming__c,
                             Project__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,ortoo_e2a__Contact_Id__c,
                             ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                             ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Status__c,
                             ortoo_e2a__Has_Attachment__c
                             from ortoo_e2a__EmailMessage__c where Project__c=:proList[0].id];
             
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
            System.assertEquals(e2ALst[0].ortoo_e2a__Contact_Id__c ,cnt.id);
            System.assertEquals(e2ALst[0].ortoo_e2a__Has_Attachment__c ,true);
            
            List<Attachment> attchList = [SELECT Id, Name,BodyLength FROM Attachment WHERE Parent.Id =: e2ALst[0].Id];
            //Checking if the Attachment are inserted.
            System.assertEquals(attchList != null, True);
            
            for(Attachment atchObj : attchList){
                System.assertEquals(atchObj.BodyLength <= 5000000,True);
            }
             
            List<task> taskList = [Select WhatId,ownerid,Type,WhoId,subject,
                                      ActivityDate,Description
                                      From Task 
                                      Where WhatId =:proList[0].id];
           
            System.assertEquals(taskList[0].whatid,proList[0].id);
            //System.assertEquals(taskList[0].ownerid,taskOwner.id);
            System.assertEquals(taskList[0].Type,'Email');
            System.assertEquals(taskList[0].WhoId,proList[0].Customer_Contact__c);
            System.assertEquals((taskList[0].subject).trim(),('Email: '+inboundEmailMessage.Subject).trim());
            System.assertEquals(taskList[0].ActivityDate,(datetime.now()).date());
            
            
         }
         
         /*
         *@author Original:Haigang Wu - Mathworks, Last Modified:
         *@date Original: 20 july 2016, Last Modified: 
         *@description:Test to check if the contact on the e2a email is based on the email from address and not primary contact
         */
        public static testMethod void checkEmailContactTest(){
        
            test.startTest();
        
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
            csb.buildGenSetting();
        
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
        
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
        
            MW_Project__c projectObj = new MW_Project__c();
            projectObj.Purpose__c = 'Territory Support';
            projectObj.Outcome__c = 'Deep Technical Engagement';
            projectObj.Expected_Date_Time__c = system.today() + 7;
            projectObj.Project_Status__c = 'Open';
            projectObj.Technical_Resource_Group__c = 'Technical Evangelist';
            projectObj.Office__c = 'Natick';
            projectObj.RecordTypeId = Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
            Insert projectObj;
             
            String recId = String.valueOf(projectObj.id);
        
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
        
            List<MW_Project__c> proList = [Select Id, Thread_Id__c from MW_Project__c where Id = :projectObj.Id];
        
			//Fetching data from UEH General setting
			UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + proList[0].Thread_Id__c;
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
                     Project__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c,
                     ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                     ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c, ortoo_e2a__Contact_Id__c 
                     from ortoo_e2a__EmailMessage__c where Project__c=:projectObj.id];
        
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