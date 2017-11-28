/*
 *@author Original:Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Archana Lohar
 *@date Original: 25 Sep 2015, Last Modified: 25 Sep 2015
 *@description:This is test class for UEH_CaseEmailHandler
 */
@istest 

public class UEH_EmailToCaseHandlerTest{
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    //re-create custom setting test records when running the test class
    static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 23 July 2013, Last Modified: 26 October 2013
     * @description:    - Test method for emails having plainTextBody empty.
                        
     */ 
    static testMethod void testIncomingEmailNullTextBodyFormat(){

        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

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
        String senderEmail = 'test@yahoo.co.ad';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'Test email handler';
        email.ccAddresses = ccAddresses;
        email.htmlBody = null;
        email.plainTextBody = null;
        email.fromAddress = 'test@yahoo.co.ad';
        envelope.fromAddress = 'test@yahoo.co.ad';
        email.toAddresses = new string[]{'support@mathworks.com'};
        envelope.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};

        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        //call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];

        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){

            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('ES - Technical Support', c.Area__c); //Case Area Country Code + type of support 
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;      
        }


        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);

        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }
    // End test inbound email with empty plain text


    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 23 July 2013, Last Modified: 26 October 2013
     * @description: - Test method for emails coming in where countrycode matching forwarding rules.
                    - No contact matches the email address of the sender. 
                    - Routing rule having a sub area. 
                    - Forwarding email has 'mathworks' domain.
                    - Sender's email matches a contact's email.
     */ 
    static testMethod void escalateToDevWithReferenceIDTest(){

        test.startTest();
        
        csb.buildTestRoutingRule();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Disables running of checkOnSupport method on Case trigger
        //CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        //cseTrigHandler.stopTrigger();

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

        //Create new Case with a valid contact and having 'Waiting for Customer' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = newContact.id;
        newCase.SubStatus__c = 'Waiting For Internal';
        insert newCase;
        
        system.debug(newCase.id+'newCase');

        //Get the organization Id for reference.
        String orgID = Userinfo.getOrganizationId();
        list <Case> lstCase = [Select Email_Ref_Id__c from Case where id = : newCase.id];
        String refID = '[ ' +lstCase[0].Email_Ref_Id__c + ' ]';

        Case insertedCase = [SELECT CaseNumber FROM Case WHERE id = :newCase.id ];

        // setup the data for the email
        email.subject = 'No Sub Area';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body [DEVID'+refID+' '+insertedCase.CaseNumber;
        email.binaryAttachments = new list<Messaging.Inboundemail.Binaryattachment>();
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'service@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, env);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,SubStatus__c,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        List<EmailMessage> existingEmailMessage = [SELECT id FROM EmailMessage WHERE parentId =: newCase.id];
        List<Task> taskList = [SELECT id,Category__c from task where whatid =: newCase.id];

        System.assertEquals(1, createdCases.size());
        System.assertEquals(1, existingEmailMessage.size());
        System.assertEquals(1, taskList.size());
        System.assert(taskList[0].Category__c=='Escalation – Request to Dev');
        System.assertEquals(createdCases[0].SubStatus__c,'In Progress');


    }   
    
     /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 23 July 2013, Last Modified: 26 October 2013
     * @description:- Email text body with DEVID but without Threadid
     */ 
    static testMethod void escalateToDevWithoutReferenceIDTest(){

        test.startTest();
        
        csb.buildTestRoutingRule();

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Disables running of checkOnSupport method on Case trigger
        //CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        //cseTrigHandler.stopTrigger();

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
        email.subject = 'No Sub Area';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body [DEVID';
        email.binaryAttachments = new list<Messaging.Inboundemail.Binaryattachment>();
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'service@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, env);

        test.stopTest();
        List<case> cselst = [select id,Area__c from Case];
        List<Case> createdCases = [SELECT Status,SubStatus__c,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        List<EmailMessage> existingEmailMessage = [SELECT id FROM EmailMessage where parentid =: cselst[0].id];
        List<Task> taskList = [SELECT id,Category__c from task where whatid =: cselst[0].id];

        System.assertEquals(1, createdCases.size());
        System.assertEquals(2, existingEmailMessage.size());
        System.assertEquals(1, taskList.size());
        
        
        list<Email_Routing_Rules__c> emailRoutingRule = new list<Email_Routing_Rules__c>();
        emailRoutingRule =  [SELECT  Area_on_SR__c  FROM Email_Routing_Rules__c WHERE Email_Service_Address__c = : env.toAddress AND Email_Service_Address__c <> null limit 1];
        
        System.assertEquals(cselst[0].Area__c,emailRoutingRule[0].Area_on_SR__c);
      

    }   

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 23 July 2013, Last Modified: 26 October 2013
     * @description: - Test method for forwarding email to distributor
     */ 
    static testMethod void testForwardEmailOnDistributor(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'Test email handler';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body';
        email.fromAddress = 'test@yahoo.com.ph';
        email.toAddresses = new string[]{'emailToCase@test.com', 'cctest@email.com'};
        envelope.fromAddress = 'test@yahoo.com.ph';
        envelope.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        //Verify that no case has been created
        System.assertEquals(0, createdCases.size());

        //Verify that no EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        System.assertEquals(0, createdEmailMessage.size());

        //Verify that no Task record has been created
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(0, createdTask.size());

        //An email has been forwarded to Distributor's Email: test@test.ph
        //Customer's email has been notified that the email has been forwarded to the distributor
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails that has a mathworks office which will be sent to a support generic email
                     - From Address' Domain Country code is listed on Forwarding Rules
                     - will create a case with Area equal to Country Code + Technical Support
     */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseSupport(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'Test email handler';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body';
        email.fromAddress = 'test@yahoo.co.ad';
        envelope.fromAddress = 'test@yahoo.co.ad';
        email.toAddresses = new string[]{'support@mathworks.com'};
        envelope.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];

        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'\n\nThis is a test email body', c.Description);
            System.assertEquals('ES - Technical Support', c.Area__c); //Case Area Country Code + type of support 
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;
        }


        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        //System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);

        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        //System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails that has a mathworks office which will be sent to a service generic email
                     - From Address' Domain Country code is listed on Forwarding Rules
                     - will create a case with Area equal to Country Code + Customer Support
     */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseService(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'Test email handler';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body';
        email.fromAddress = 'test@yahoo.co.ad';
        envelope.fromAddress = 'test@yahoo.co.ad';
        email.toAddresses = new string[]{'service@mathworks.com'};
        envelope.toAddress = 'emailhandler@7xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];

        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'\n\nThis is a test email body', c.Description);
            System.assertEquals('ES - Customer Support', c.Area__c); //Case Area Country Code + type of support 
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;
        }


        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        //System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);

        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        //System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails that is sent to a non-generic email
                     - From Address' Domain Country code is listed on Forwarding Rules
                     - will create a case with Area equal to To Email's Area
     */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseDirect(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Create a new user
        User newUser = TestDataBuilder.buildTestUser(1);
        insert newUser;

        //Create an Account associated with the user
        Account newAccount = TestDataBuilder.buildTestAccount(1, newUser.id);
        insert newAccount;

        //Create a contact related to Account.
        String senderEmail = 'test@yahoo.co.ad1';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'Test email handler';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body';
        email.fromAddress = 'test@yahoo.co.ad1';
        envelope.fromAddress = 'test@yahoo.co.ad1';
        email.toAddresses = new string[]{'info@mathworks.com.au'};
        envelope.toAddress = 'emailhandler@0xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];

        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('AU - Customer Support', c.Area__c); //Direct email's Area
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;
        }


        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        //System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);

        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        //System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails that has a mathworks office
                     - From Address' Domain Country code is not listed on Forwarding Rules
                     - will create a case with Area equal to Natick + type of support
     */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseUnlisted(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

        //Disables running of checkOnSupport method on Case trigger
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'Test email handler';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body';
        email.fromAddress = 'test@yahoo.com';
        envelope.fromAddress = 'test@yahoo.com';
        email.toAddresses = new string[]{'support@mathworks.com'};
        envelope.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];

        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'\n\nThis is a test email body', c.Description);
            System.assertEquals('Natick - Technical Support', c.Area__c); //FromEmail's Area
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;
        }


        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        //System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);

        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        //System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails which have an existing Thread Id
                     - From Address' Domain Country code is listed on Forwarding Rules
                     - will update an identified case
     */ 
    static testMethod void testForwardEmailWithMathworksOfficeCustomerReply(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //re-create builtUEH_KeyPrefix_Module_Handler Custom Setting
        custsettbuild.builtUEH_KeyPrefix_Module_Handler(); 

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

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
        String senderEmail = 'test@yahoo.co.ad';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //Create new Case with a valid contact and having 'Waiting for Customer' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = newContact.id;
        newCase.SubStatus__c = 'Waiting for Customer';
        insert newCase; 

        //Get the organization Id for reference.
        String orgID = Userinfo.getOrganizationId();
        //String refID =  '[ ref:_'+orgID.substring(0,5) + orgID.substring(10,15)+'._'+String.valueof(newCase.Id).substring(0, 5) + String.valueof(newCase.Id).substring(10,15)+':ref ]';
        //SS 10/01/15 Winter 16 issue -Commented line above and added 2 lines below to get the ref id from formula field
        list <Case> lstCase = [Select Id, Email_Ref_Id__c from Case where id = : newCase.id];
        String refID = '[ ' + lstCase[0].Email_Ref_Id__c + ' ]';

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'RE: test Subject string too long string too long string too long string too long string too long string too long string too long string too long string too long string too long string too long string too long string too long string too long'+refID;
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'Test email Body'+refID;
        email.fromAddress = senderemail;
        envelope.fromAddress = senderemail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        envelope.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);

        test.stopTest();
        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        System.assertEquals(1, createdEmailMessage.size()); //1 for actual email
        System.assertEquals(newCase.Id, createdEmailMessage[0].ParentId);

        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(1, createdTask.size()); //1 for the actual email
        System.assertEquals(newCase.Id, createdTask[0].WhatId);
    }
    
     /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails which have an existing Thread Id and which is not generic.                 
     */ 
    static testMethod void testForwardEmailWithNotGenericEmail(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

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
        String senderEmail = 'NotGeneric@mathworks.com.ok';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'RE: test Subject string';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'Test email Body';
        email.fromAddress = senderemail;
        envelope.fromAddress = senderemail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        envelope.toAddress = 'EmailToCase@NotGeneric.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        test.stopTest();
        list<Email_Routing_Rules__c> emailRoutingRule = new list<Email_Routing_Rules__c>();
        emailRoutingRule =  [SELECT  Area_on_SR__c FROM Email_Routing_Rules__c WHERE Email_Service_Address__c = : envelope.toAddress AND Email_Service_Address__c <> null limit 1];
        
        List<case> cselst = [select id,Area__c from Case];
        System.assertEquals(cselst[0].Area__c,emailRoutingRule[0].Area_on_SR__c);
        
        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT id FROM EmailMessage];
        System.assertEquals(1, createdEmailMessage.size()); //1 for actual email
      
        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(1, createdTask.size()); //1 for the actual email
        
    }
    
     /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 29 May 2013, Last Modified: 26 October 2013
     * @description: - Test method for incoming emails without email routing rule.                 
     */ 
    static testMethod void testForwardEmailWithoutEmailRoutingRule(){
        test.startTest();
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        //re-create builtUEH_Recipient_Module_Handler Custom Setting
        custsettbuild.builtUEH_Recipient_Module_Handler();

        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();

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
        String senderEmail = 'NotInRoutingRule@mathworks.com.ok';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create Test User
        User TestUsr = TestDataBuilder.buildTestUser(101);
        TestUsr.FirstName = 'Partner';
        TestUsr.LastName = 'Program';
        insert TestUsr;

        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');

        // setup the data for the email
        email.subject = 'RE: test Subject string';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'Test email Body';
        email.fromAddress = senderemail;
        envelope.fromAddress = senderemail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        envelope.toAddress = 'NotInRoutingRule@NotGeneric.com';
        //Add binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.Inboundemail.Binaryattachment[]{attachment};
        //Add text attachment
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = String.valueOf('my attachment text');
        attachmenttext.fileName = 'textfiletwo.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        UEH_UniversalEmailHandler testInbound = new  UEH_UniversalEmailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        test.stopTest();
        list<Email_Routing_Rules__c> emailRoutingRule = new list<Email_Routing_Rules__c>();
        emailRoutingRule =  [SELECT  Area_on_SR__c FROM Email_Routing_Rules__c WHERE Email_Service_Address__c = : envelope.toAddress AND Email_Service_Address__c <> null limit 1];
        
        List<case> cselst = [select id,Area__c from Case];
        System.assertEquals(cselst[0].Area__c,'Natick - Customer Support');
        
        //Check if an EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT id FROM EmailMessage];
        System.assertEquals(2, createdEmailMessage.size()); //1 for actual email
      
        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(2, createdTask.size()); //1 for the actual email
        
    }

}