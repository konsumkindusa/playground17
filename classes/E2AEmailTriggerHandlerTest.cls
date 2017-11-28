/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Haigang Wu
 *@date Original: 12 Nov 2015, Last Modified:30 Sep 2016
 *@description:   This is a test class for E2AEmailTriggerHandler  
 */
@isTest 
public class E2AEmailTriggerHandlerTest{
        //re-create custom setting test records when running the test class
        static CustomSettingsBuilder csb = new CustomSettingsBuilder();
          
        //re-create custom setting test records when running the test class
        static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
       
         /*
          @name         e2AEmailCountOnASPTest
          @date         17 Nov 2015
          @author       Sagar Talele
          @param        none.
          @return       Void. 
          @description  Check the functionality UpdateCountOfE2AEmailOnASP method
        */
         public static testMethod void e2AEmailCountOnASPTest1(){ 
         
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            Academic_Support_Project__c academicSupObj = new  Academic_Support_Project__c();
            Insert academicSupObj;
            Academic_Support_Project__c academicSupObj1 = new  Academic_Support_Project__c();
            Insert academicSupObj1;
             
            String recId = String.valueOf(academicSupObj.id);
            List<Academic_Support_Project__c> academicSuppList = [select Id, Thread_Id__c from Academic_Support_Project__c where Id = :academicSupObj.Id];
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);

            //Fetching data from UEH General setting
            UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
             
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + academicSuppList[0].Thread_Id__c;
            //inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ';
            inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
            inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
            inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
            inboundEmailMessage.fromName = 'User Name';
            inboundEmailMessage.subject = 'TestEmail'+ academicSuppList[0].Thread_Id__c;
            inboundEmailMessage.htmlBodyIsTruncated = False;
            inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
            inboundEmailMessage.plainTextBodyIsTruncated = False;
            inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
            // Creating Envelope Data    
            Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
            envelopeObj.toAddress = 'AcademicSupport@mathworks.com';
           //envelopeObj.toAddress ='academicsupport@n-jjgednvv0fg7dtpnxb9zhlcghd8ymgewx0ekk5ocuj8o58u99.e-5vmmkeak.cs15.apex.sandbox.salesforce.com';
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

            List<ortoo_e2a__EmailMessage__c> e2aList = new List<ortoo_e2a__EmailMessage__c>();
            List<ortoo_e2a__EmailMessage__c> updateE2aList = new List<ortoo_e2a__EmailMessage__c>();
            e2aList = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c From ortoo_e2a__EmailMessage__c where Academic_Support_Project__c=:academicSupObj.id ];
            System.assertEquals(e2aList.isEmpty(),false);
            System.Debug('email Status:'+e2aList[0].ortoo_e2a__Status__c);
            System.assertEquals(e2aList[0].ortoo_e2a__Status__c,'New');
            
            Academic_Support_Project__c aspObj = [Select Id,E2AEmailCount__c From Academic_Support_Project__c where Id =: academicSupObj.Id];
            System.assertEquals(aspObj.E2AEmailCount__c ,1);
            
            for(ortoo_e2a__EmailMessage__c Obj : e2aList ){
                Obj.ortoo_e2a__Status__c = 'Read';
                Obj.ortoo_e2a__Incoming__c = true;
                Obj.Academic_Support_Project__c = academicSupObj1.id;
                updateE2aList.add(Obj);
            }
            update updateE2aList;
            List<ortoo_e2a__EmailMessage__c> updatedE2aList = new List<ortoo_e2a__EmailMessage__c>();
            
            updatedE2aList = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c,Academic_Support_Project__c From ortoo_e2a__EmailMessage__c where Id IN :updateE2aList ];
            System.assertEquals(updatedE2aList[0].ortoo_e2a__Status__c,'Read');
            
            Academic_Support_Project__c accObj = [Select Id,E2AEmailCount__c From Academic_Support_Project__c where Id =: academicSupObj1.Id];
            System.assertEquals(accObj.E2AEmailCount__c ,0);
         }            


         public static testMethod void e2AEmailCountOnASPTest2(){ 
         
            test.startTest();
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            Academic_Support_Project__c academicSupObj = new  Academic_Support_Project__c();
            Insert academicSupObj;
            Academic_Support_Project__c academicSupObj1 = new  Academic_Support_Project__c();
            Insert academicSupObj1;
             
            String recId = String.valueOf(academicSupObj.id);
            List<Academic_Support_Project__c> academicSuppList = [select Id, Thread_Id__c from Academic_Support_Project__c where Id = :academicSupObj.Id];
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);

            //Fetching data from UEH General setting
            UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
             
            // check the delete functionality
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.inboundEmailMessage
            Messaging.InboundEmail inboundEmailMsg = new Messaging.InboundEmail();
            inboundEmailMsg.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMsg.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + academicSuppList[0].Thread_Id__c;
            //inboundEmailMsg.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ';
            inboundEmailMsg.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
            inboundEmailMsg.ToAddresses = new String[] {'person@gmail.com'};
            inboundEmailMsg.CCAddresses = new String[] {'user@gmail.com'};
            inboundEmailMsg.fromName = 'User Name';
            inboundEmailMsg.subject = 'EmailTestFoeDelete';
            inboundEmailMsg.htmlBodyIsTruncated = False;
            inboundEmailMsg.replyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMsg.inReplyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMsg.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
            inboundEmailMsg.plainTextBodyIsTruncated = False;
            inboundEmailMsg.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
            // Creating Envelope Data    
            Messaging.InboundEnvelope envelopeObj1 = new Messaging.InboundEnvelope();
            envelopeObj1.toAddress = 'AcademicSupport@mathworks.com';
           //envelopeObj1.toAddress ='academicsupport@n-jjgednvv0fg7dtpnxb9zhlcghd8ymgewx0ekk5ocuj8o58u99.e-5vmmkeak.cs15.apex.sandbox.salesforce.com';
            envelopeObj1.FromAddress = 'personenvelopefromaddress@gmail.com';
             
            //Creating text Attachment data.
            Messaging.InboundEmail.TextAttachment attachTextFile2 = new Messaging.InboundEmail.TextAttachment();
            
            attachTextFile2.body = 'my attachment text';
            attachTextFile2.fileName = 'textfiletwo.txt';
            attachTextFile2.mimeTypeSubType = 'texttwo/plain';
            inboundEmailMsg.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile2 };
            
            //Creating Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile2 = new Messaging.InboundEmail.BinaryAttachment();
            attachBinaryFile2.body = blob.valueOf('my attachment text');
            attachBinaryFile2.fileName = 'textfileone.txt';
            attachBinaryFile2.mimeTypeSubType = 'text/plain';
            inboundEmailMsg.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile2 };
        
             
            UEH_UniversalEmailHandler handlerCls = new UEH_UniversalEmailHandler();
            handlerCls.handleInboundEmail(inboundEmailMsg, envelopeObj1);
            test.stopTest();
            List<ortoo_e2a__EmailMessage__c> e2aLst = new List<ortoo_e2a__EmailMessage__c>();
            List<ortoo_e2a__EmailMessage__c> deleteE2aList = new List<ortoo_e2a__EmailMessage__c>();
            e2aLst = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c From ortoo_e2a__EmailMessage__c where Academic_Support_Project__c=:academicSupObj.id ];
            System.assertEquals(e2aLst.isEmpty(),false);
            
            Academic_Support_Project__c asp = [Select Id,E2AEmailCount__c From Academic_Support_Project__c where Id =: academicSupObj.Id];
            System.assertEquals(asp.E2AEmailCount__c ,1);
            
            delete e2aLst;
            Academic_Support_Project__c aspDelete = [Select Id,E2AEmailCount__c From Academic_Support_Project__c where Id =: academicSupObj.Id];
            System.assertEquals(aspDelete.E2AEmailCount__c ,0);
            undelete e2aLst;
         }
    /*
          @name         e2AEmailCountOnASPTest
          @date         17 Nov 2015
          @author       Sagar Talele
          @param        none.
          @return       Void. 
          @description  Check the functionality UpdateCountOfE2AEmailOnBP method
        */
         public static testMethod void e2AEmailCountOnBPTest1(){ 
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            
            Book_Project__c bookProjObj = new Book_Project__c();
            insert bookProjObj;
            Book_Project__c bookProjObj1 = new Book_Project__c();
            insert bookProjObj1;
             
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
             
            List<ortoo_e2a__EmailMessage__c> e2aList = new List<ortoo_e2a__EmailMessage__c>();
            
            List<ortoo_e2a__EmailMessage__c> updateE2aList = new List<ortoo_e2a__EmailMessage__c>();
            e2aList = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c From ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProjObj.id ];
            System.assertEquals(e2aList.isEmpty(),false);
            System.assertEquals(e2aList[0].ortoo_e2a__Status__c,'New');
            
            Book_Project__c bpObj = [Select Id,E2AEmailCount__c From Book_Project__c where Id =: bookProjObj.Id];
            System.assertEquals(bpObj.E2AEmailCount__c ,1);
            
            for(ortoo_e2a__EmailMessage__c Obj : e2aList ){
                Obj.ortoo_e2a__Status__c = 'Read';
                updateE2aList.add(Obj);
                Obj.ortoo_e2a__Incoming__c = true;
                Obj.Book_Project__c = bookProjObj1.id;
            }
            update updateE2aList;
            List<ortoo_e2a__EmailMessage__c> updatedE2aList = new List<ortoo_e2a__EmailMessage__c>();
            
            updatedE2aList = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c,Academic_Support_Project__c From ortoo_e2a__EmailMessage__c where Id IN :updateE2aList ];
            System.assertEquals(updatedE2aList[0].ortoo_e2a__Status__c,'Read');
            
            Book_Project__c  bookprjObj = [Select Id,E2AEmailCount__c From Book_Project__c  where Id =: bookProjObj1.Id];
            System.assertEquals(bookprjObj.E2AEmailCount__c ,0);
         }            

         public static testMethod void e2AEmailCountOnBPTest2(){ 
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
            
            
            Book_Project__c bookProjObj = new Book_Project__c();
            insert bookProjObj;
            Book_Project__c bookProjObj1 = new Book_Project__c();
            insert bookProjObj1;
             
            //String recId = String.valueOf(academicSupObj.id);
            String recId = String.valueOf(bookProjObj.Id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            
            List<Book_Project__c> bookProjList = [Select Id, Thread_Id__c from Book_Project__c where Id=:bookProjObj.Id];
             
            //Fetching data from UEH General setting
            UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
             
            //test delete functinality bookProjObj
            
            Book_Project__c bookProObj = new Book_Project__c();
            insert bookProObj;
             
            //String recId = String.valueOf(academicSupObj.id);
           // String recId = String.valueOf(bookProObj.Id);
          
            //String refOrgId1 = userInfo.getOrganizationId();
            //String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId1);
            
            List<Book_Project__c> bookProjLst = [Select Id, Thread_Id__c from Book_Project__c where Id=:bookProObj.Id];
            
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMssg = new Messaging.InboundEmail();
            inboundEmailMssg.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMssg.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + bookProjLst [0].Thread_Id__c;
            inboundEmailMssg.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
            inboundEmailMssg.ToAddresses = new String[] {'person@gmail.com'};
            inboundEmailMssg.CCAddresses = new String[] {'user@gmail.com'};
            inboundEmailMssg.fromName = 'User Name';
            inboundEmailMssg.subject = 'TestEmail';
            inboundEmailMssg.htmlBodyIsTruncated = False;
            inboundEmailMssg.replyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMssg.inReplyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMssg.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
            inboundEmailMssg.plainTextBodyIsTruncated = False;
            inboundEmailMssg.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
            // Creating Envelope Data    
            Messaging.InboundEnvelope envelopeObj1 = new Messaging.InboundEnvelope();
            envelopeObj1.toAddress = 'personenvelope1toaddress@gmail.com';
            envelopeObj1.FromAddress = 'personenvelopefromaddress@gmail.com';
             
            //Creating Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile3 = new Messaging.InboundEmail.BinaryAttachment();
            attachBinaryFile3.body = blob.valueOf('my attachment text');
            attachBinaryFile3.fileName = 'textfileone.txt';
            attachBinaryFile3.mimeTypeSubType = 'text/plain';
            inboundEmailMssg.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile3 };
        
             
            UEH_UniversalEmailHandler handlerClss = new UEH_UniversalEmailHandler();
            handlerClss.handleInboundEmail(inboundEmailMssg, envelopeObj1);
             
            test.stopTest();
            List<ortoo_e2a__EmailMessage__c> e2aDeleteLst = new List<ortoo_e2a__EmailMessage__c>();
            
            e2aDeleteLst = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c From ortoo_e2a__EmailMessage__c where Book_Project__c=:bookProObj.id ];
            System.assertEquals(e2aDeleteLst.isEmpty(),false);
            delete e2aDeleteLst;
            
            Book_Project__c Obj = [Select Id,E2AEmailCount__c From Book_Project__c where Id =: bookProObj.Id];
            System.assertEquals(Obj .E2AEmailCount__c ,0);
            
            undelete e2aDeleteLst;
        }
        /*
          @name         e2AEmailCountOnASPTest
          @date         17 Nov 2015
          @author       Sagar Talele
          @param        none.
          @return       Void. 
          @description  Check the functionality UpdateCountOfE2AEmailOnPA method
        */
         public static testMethod void e2AEmailCountOnPATest1(){ 
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
             
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
             
            
            Partner_Agreement__c agreeObj = new  Partner_Agreement__c();
            Insert agreeObj;
            Partner_Agreement__c agreeObj1 = new  Partner_Agreement__c();
            Insert agreeObj1;
             
            String recId = String.valueOf(agreeObj.id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            
            List<Partner_Agreement__c> partnerAgreeList = [Select Id, Thread_Id__c from Partner_Agreement__c where Id = :agreeObj.Id];
             
            //Fetching data from UEH General setting
            UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
             
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
            inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + partnerAgreeList[0].Thread_Id__c;
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
             
           
            List<ortoo_e2a__EmailMessage__c> updateE2aList = new List<ortoo_e2a__EmailMessage__c>();
            e2ALst = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c From ortoo_e2a__EmailMessage__c where Partner_Agreement__c=:agreeObj.id ];
            System.assertEquals(e2ALst .isEmpty(),false);
            System.assertEquals(e2ALst [0].ortoo_e2a__Status__c,'New');
            
            Partner_Agreement__c bpObj = [Select Id,E2AEmailCount__c From Partner_Agreement__c where Id =: agreeObj.Id];
            System.assertEquals(bpObj.E2AEmailCount__c ,1);
            
            for(ortoo_e2a__EmailMessage__c Obj : e2ALst ){
                Obj.ortoo_e2a__Status__c = 'Read';
                updateE2aList.add(Obj);
                Obj.ortoo_e2a__Incoming__c = true;
                Obj.Partner_Agreement__c = agreeObj1.id;
            }
            update updateE2aList;
            List<ortoo_e2a__EmailMessage__c> updatedE2aList = new List<ortoo_e2a__EmailMessage__c>();
            
            updatedE2aList = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c,Partner_Agreement__c From ortoo_e2a__EmailMessage__c where Id IN :updateE2aList ];
            System.assertEquals(updatedE2aList[0].ortoo_e2a__Status__c,'Read');
            
            Partner_Agreement__c  paObj = [Select Id,E2AEmailCount__c From Partner_Agreement__c where Id =: agreeObj1.Id];
            System.assertEquals(paObj.E2AEmailCount__c ,0);
         }            


         public static testMethod void e2AEmailCountOnPATest2(){ 
            test.startTest();
             
            //re-create Bypass Trigger Custom Setting
            csb.buildBypassTriggerSettings();
         
            //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
            custsettbuild.builtUEH_KeyPrefix_Module_Handler();
             
            //Inserting UEH GeneralSetting 
            custsettbuild.builtUEHGeneralSetting();
             
            
            Partner_Agreement__c agreeObj = new  Partner_Agreement__c();
            Insert agreeObj;
            Partner_Agreement__c agreeObj1 = new  Partner_Agreement__c();
            Insert agreeObj1;
             
            String recId = String.valueOf(agreeObj.id);
          
            String refOrgId = userInfo.getOrganizationId();
            String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
            
            List<Partner_Agreement__c> partnerAgreeList = [Select Id, Thread_Id__c from Partner_Agreement__c where Id = :agreeObj.Id];
             
            //Fetching data from UEH General setting
            UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
             
            //test delete functionality
            
            Partner_Agreement__c partAgrObj = new  Partner_Agreement__c();
            Insert partAgrObj;
            
            
            List<Partner_Agreement__c> paList = [Select Id, Thread_Id__c from Partner_Agreement__c where Id =:partAgrObj.Id];
            System.assertEquals(paList.IsEmpty(),false);
            //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
            Messaging.InboundEmail inboundEmailMessage1 = new Messaging.InboundEmail();
            inboundEmailMessage1.FromAddress = 'personemailfromaddress@gmail.com';
            inboundEmailMessage1.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + paList[0].Thread_Id__c;
            inboundEmailMessage1.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
            inboundEmailMessage1.ToAddresses = new String[] {'person@gmail.com'};
            inboundEmailMessage1.CCAddresses = new String[] {'user@gmail.com'};
            inboundEmailMessage1.fromName = 'User Name';
            inboundEmailMessage1.subject = 'TestEmailForDelete';
            inboundEmailMessage1.htmlBodyIsTruncated = False;
            inboundEmailMessage1.replyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMessage1.inReplyTo = 'personemailfromaddress@gmail.com';
            inboundEmailMessage1.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
            inboundEmailMessage1.plainTextBodyIsTruncated = False;
            inboundEmailMessage1.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
            // Creating Envelope Data    
            Messaging.InboundEnvelope envelopeObj1 = new Messaging.InboundEnvelope();
            envelopeObj1.toAddress = 'personenvelope1toaddress@gmail.com';
            envelopeObj1.FromAddress = 'personenvelopefromaddress@gmail.com';
             
            //Creating text Attachment data.
            Messaging.InboundEmail.TextAttachment attachTextFile2= new Messaging.InboundEmail.TextAttachment();
            
            attachTextFile2.body = 'my attachment text';
            attachTextFile2.fileName = 'textfiletwo.txt';
            attachTextFile2.mimeTypeSubType = 'texttwo/plain';
            inboundEmailMessage1.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile2 };
            
            //Creating Binary Attachment Data.  
            Messaging.InboundEmail.BinaryAttachment attachBinaryFile2 = new Messaging.InboundEmail.BinaryAttachment();
            attachBinaryFile2.body = blob.valueOf('my attachment text');
            attachBinaryFile2.fileName = 'textfileone.txt';
            attachBinaryFile2.mimeTypeSubType = 'text/plain';
            inboundEmailMessage1.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile2 };
        
             
            UEH_UniversalEmailHandler handlerCls = new UEH_UniversalEmailHandler();
            handlerCls.handleInboundEmail(inboundEmailMessage1, envelopeObj1);
             
            test.stopTest();
            List<ortoo_e2a__EmailMessage__c> e2AdeleteLst = new List<ortoo_e2a__EmailMessage__c>();
            e2AdeleteLst = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c From ortoo_e2a__EmailMessage__c where Partner_Agreement__c =:partAgrObj.id ];
            System.assertEquals(e2AdeleteLst.isEmpty(),false);
            
            
            Partner_Agreement__c Obj = [Select Id,E2AEmailCount__c From Partner_Agreement__c where Id =: partAgrObj.Id];
            System.assertEquals(Obj.E2AEmailCount__c ,1);
            
            delete e2AdeleteLst;
            Partner_Agreement__c partnerAgrObj = [Select Id,E2AEmailCount__c From Partner_Agreement__c where Id =: partAgrObj.Id];
            System.assertEquals(partnerAgrObj.E2AEmailCount__c ,0);
            undelete e2AdeleteLst;
        }
   /***************************************************************************************
    * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
    * date Original: 28 March 2016, Last Modified: 28 March 2016
    * description : Check the functionality UpdateCountOfE2AEmailOnSA method
    ****************************************************************************************/
  
    public static testMethod void UpdateCountOfE2AEmailOnSATest1(){
        test.startTest();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();
        
        Social_Action__c socialActionObj = new Social_Action__c();
        insert socialActionObj;
        Social_Action__c socialActionObj1 = new Social_Action__c();
        insert socialActionObj1;
        
        String recId = String.valueOf(socialActionObj.id);
        List<Social_Action__c> socailActionList = [select Id, Thread_Id__c from Social_Action__c where Id = :socialActionObj.Id];
        
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
        
        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + socailActionList[0].Thread_Id__c;
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
        List<ortoo_e2a__EmailMessage__c> updateE2aList = new List<ortoo_e2a__EmailMessage__c>();
        e2ALst = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Status__c,
                         Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c, 
                         ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                         ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c,Social_Action__c
                         from ortoo_e2a__EmailMessage__c where Social_Action__c=:socialActionObj.id];
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
        
        Social_Action__c saObj = [Select Id,E2AEmailCount__c From Social_Action__c where Id =: socialActionObj.Id];
        System.assertEquals(saObj.E2AEmailCount__c ,1);
        
        for(ortoo_e2a__EmailMessage__c Obj : e2ALst ){
                Obj.ortoo_e2a__Status__c = 'Read';
                Obj.ortoo_e2a__Incoming__c = true;
                Obj.Social_Action__c = socialActionObj1.id;
                updateE2aList.add(Obj);
            }
        update updateE2aList;
        List<ortoo_e2a__EmailMessage__c> updatedE2aList = new List<ortoo_e2a__EmailMessage__c>();
        
        updatedE2aList = [Select Id,Name,ortoo_e2a__Status__c,ortoo_e2a__Subject__c,Social_Action__c From ortoo_e2a__EmailMessage__c where Id IN :updateE2aList ];
        System.assertEquals(updatedE2aList[0].ortoo_e2a__Status__c,'Read');
        
        Social_Action__c socialObj = [Select Id,E2AEmailCount__c From Social_Action__c where Id =: socialActionObj1.Id];
        System.assertEquals(socialObj.E2AEmailCount__c ,0);
    }

    public static testMethod void UpdateCountOfE2AEmailOnSATest2(){
        test.startTest();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
         
        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler();
            
        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();
        
        Social_Action__c socialActionObj = new Social_Action__c();
        insert socialActionObj;
        Social_Action__c socialActionObj1 = new Social_Action__c();
        insert socialActionObj1;
        
        String recId = String.valueOf(socialActionObj.id);
        List<Social_Action__c> socailActionList = [select Id, Thread_Id__c from Social_Action__c where Id = :socialActionObj.Id];
        
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
        
        //check the delete functionality
        //Fetching data from UEH General setting
        UEHGeneralSetting__c uehGeneralSettings1 = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.inboundEmailMessage
        Messaging.InboundEmail inboundEmailMessage1 = new Messaging.InboundEmail();
        inboundEmailMessage1.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage1.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings1.Max_Email_Body_Length__c + ' Char ' + socailActionList[0].Thread_Id__c;
        inboundEmailMessage1.htmlBody = '<html><title>This s A test mail</title><body>Hi i am here.</body></html>';
        inboundEmailMessage1.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage1.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage1.fromName = 'User Name';
        inboundEmailMessage1.subject = 'TestEmail';
        inboundEmailMessage1.htmlBodyIsTruncated = False;
        inboundEmailMessage1.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage1.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage1.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage1.plainTextBodyIsTruncated = False;
        inboundEmailMessage1.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
    
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj1 = new Messaging.InboundEnvelope();
        envelopeObj1.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj1.FromAddress = 'personenvelopefromaddress@gmail.com';
         
        //Creating text Attachment data.
        Messaging.InboundEmail.TextAttachment attachTextFile2 = new Messaging.InboundEmail.TextAttachment();
        
        attachTextFile2.body = 'my attachment text';
        attachTextFile2.fileName = 'textfiletwo.txt';
        attachTextFile2.mimeTypeSubType = 'texttwo/plain';
        inboundEmailMessage1.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachTextFile2 };
        
        //Creating Binary Attachment Data.  
        Messaging.InboundEmail.BinaryAttachment attachBinaryFile3 = new Messaging.InboundEmail.BinaryAttachment();
        attachBinaryFile3.body = blob.valueOf('my attachment text');
        attachBinaryFile3.fileName = 'textfileone.txt';
        attachBinaryFile3.mimeTypeSubType = 'text/plain';
        inboundEmailMessage1.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachBinaryFile3 };
     
        UEH_UniversalEmailHandler handlerCls = new UEH_UniversalEmailHandler();
        handlerCls.handleInboundEmail(inboundEmailMessage1, envelopeObj1);
         
        test.stopTest();
        List<ortoo_e2a__EmailMessage__c> e2AList = new List<ortoo_e2a__EmailMessage__c>();
        e2AList = [select id,ortoo_e2a__From_Address__c,ortoo_e2a__Html_Body__c,ortoo_e2a__Status__c,
                         Partner_Agreement__c,ortoo_e2a__Subject__c,ortoo_e2a__Text_Body__c, 
                         ortoo_e2a__To_Address__c,ortoo_e2a__Cc_Address__c,ortoo_e2a__From_Name__c,
                         ortoo_e2a__Headers__c,ortoo_e2a__Message_Id__c,ortoo_e2a__Incoming__c,Social_Action__c
                         from ortoo_e2a__EmailMessage__c where Social_Action__c=:socialActionObj.id];
        // Asserting for the Messaging.InboundEmail lessCharEmail Object.
        System.assertEquals(e2AList[0].ortoo_e2a__From_Address__c, inboundEmailMessage1.FromAddress);
        System.assertEquals(e2AList[0].ortoo_e2a__To_Address__c, inboundEmailMessage1.ToAddresses[0]+';');
        System.assertEquals(e2AList[0].ortoo_e2a__Cc_Address__c, inboundEmailMessage1.CCAddresses[0]+';');
        System.assertEquals(e2AList[0].ortoo_e2a__Text_Body__c, inboundEmailMessage1.plainTextBody);
        System.assertEquals(e2AList[0].ortoo_e2a__Subject__c, inboundEmailMessage1.Subject);
        System.assertEquals(e2AList[0].ortoo_e2a__Html_Body__c, inboundEmailMessage1.htmlBody);
        System.assertEquals(e2AList[0].ortoo_e2a__From_Name__c, inboundEmailMessage1.fromName);
        System.assertEquals(e2AList[0].ortoo_e2a__Message_Id__c, inboundEmailMessage1.messageId);
        System.assertEquals(e2AList[0].ortoo_e2a__Incoming__c,true);
        System.assertEquals(e2AList[0].ortoo_e2a__Status__c,'New');
        
        Social_Action__c sObj = [Select Id,E2AEmailCount__c From Social_Action__c where Id =: socialActionObj.Id];
        System.assertEquals(sObj.E2AEmailCount__c ,1);
        
        delete e2AList;
        
        Social_Action__c saObjDelete = [Select Id,E2AEmailCount__c From Social_Action__c where Id =: socialActionObj.Id];
        System.assertEquals(saObjDelete.E2AEmailCount__c ,0);
        
        undelete e2AList;
            
    }
    
}