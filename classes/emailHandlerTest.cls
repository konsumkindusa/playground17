/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, LastUpdated By: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 29 May 2013 Last Modified: 1 October 2015
* @author Modified: Shweta Shanbhag
* @description Test Class for testing all functionality of EmailHandler
*/ 
@isTest
private class emailHandlerTest{
     //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 29 October 2013
    * @description: - Test method for incoming emails that does not have a mathworks office
                    - will not create a case
                    - From Address' Domain Country code is listed on Forwarding Rules
                    - will forward an email to the distributor and will notify the customer who sent the email
    */ 
// FG 11/20/13 - test incoming email with Null email body
    static testMethod void testIncomingEmailNullTextBodyFormat(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        System.debug('##Test Class start ');
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
        
        // call the email service class and test it with the data in the testMethod
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.debug('@@@## CaseID:' +c.id);
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            //System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'', c.Description);
           // System.assertEquals('Sender\'s email address: '+envelope.fromAddress, c.Description);
            System.assertEquals('ES - Technical Support', c.Area__c); //Case Area Country Code + type of support 
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;
            //System.debug('@@@## CaseDesc:' +c.Description);
            //System.debug('@@@## CaseID:' +caseId);
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



   
// FG 11/20/13 - test incoming email with empty plain text
    static testMethod void testIncomingEmailPlainTextBodyFormat(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        System.debug('##Test Class start ');
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
        email.plainTextBody = '';
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.debug('@@@## CaseID:' +c.id);
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'', c.Description);
            System.assertEquals('ES - Technical Support', c.Area__c); //Case Area Country Code + type of support 
            System.assertEquals('Test subArea', c.Sub_Area__c);
            caseId = c.id;
            //System.debug('@@@## CaseDesc:' +c.Description);
            //System.debug('@@@## CaseID:' +caseId);
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

// FG 11/20/13 - test incoming email with  html format
    static testMethod void testIncomingEmailHTMLBodyFormat(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
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
        email.htmlBody = '<!DOCTYPE html><html><body><h1>My First Heading</h1<p>My first paragraph.</p></body></html>';
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'\n\n<!DOCTYPE html><html><body><h1>My First Heading</h1<p>My first paragraph.</p></body></html>', c.Description);
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
    // End test incoming email HTML format
    
    static testMethod void testForwardEmailOnDistributor(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
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
        email.toAddresses = new string[]{'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com', 'cctest@email.com'};
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        //Verify that no case has been created
        //System.assertEquals(0, createdCases.size());
        //Verify that no EmailMessage record is created.
        List<EmailMessage> createdEmailMessage = [SELECT ParentId FROM EmailMessage];
        //System.assertEquals(0, createdEmailMessage.size());
        //Verify that no Task record has been created
        List<Task> createdTask = [SELECT WhatId FROM Task];
        //System.assertEquals(0, createdTask.size());
        
        //An email has been forwarded to Distributor's Email: test@test.ph
        //Customer's email has been notified that the email has been forwarded to the distributor
    }

    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails that has a mathworks office which will be sent to a support generic email
                    - From Address' Domain Country code is listed on Forwarding Rules
                    - will create a case with Area equal to Country Code + Technical Support
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseSupport(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
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
        System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);
        
        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails that has a mathworks office which will be sent to a service generic email
                    - From Address' Domain Country code is listed on Forwarding Rules
                    - will create a case with Area equal to Country Code + Customer Support
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseService(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
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
        System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);
        
        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }
    
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails that is sent to a non-generic email
                    - From Address' Domain Country code is listed on Forwarding Rules
                    - will create a case with Area equal to To Email's Area
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseDirect(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
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
        email.fromAddress = 'test@yahoo.co.ad';
        envelope.fromAddress = 'test@yahoo.co.ad';
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(1, createdCases.size());
        id caseId;
        for(Case c: createdCases){
            System.assertEquals('Open', c.Status);
            System.assertEquals('Email', c.Origin);
            System.assertEquals('Test email handler' , c.Subject);
            System.assertEquals('Sender\'s email address: '+envelope.fromAddress+'\n\nThis is a test email body', c.Description);
            System.assertEquals('AU - Customer Support', c.Area__c); //Direct email's Area
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
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails that has a mathworks office
                    - From Address' Domain Country code is not listed on Forwarding Rules
                    - will create a case with Area equal to Natick + type of support
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCreateCaseUnlisted(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
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
        System.assertEquals(2, createdEmailMessage.size()); //1 for actual email, 1 for a copy of auto response email
        System.assertEquals(caseId, createdEmailMessage[0].ParentId);
        
        //Check if a Task record is created.
        List<Task> createdTask = [SELECT WhatId FROM Task];
        System.assertEquals(2, createdTask.size()); //1 for the actual email, 1 for the auto response email
        System.assertEquals(caseId, createdTask[0].WhatId);
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails which have an existing Thread Id
                    - From Address' Domain Country code is listed on Forwarding Rules
                    - will update an identified case
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCustomerReply(){
        //create records on Custom Settings
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
        String senderEmail = 'test@yahoo.co.ad';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
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
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails which have an existing Thread Id
                    - From Address' Domain Country code is not listed on Forwarding Rules
                    - will update an identified case
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCustomerReplyUnlisted(){
        //create records on Custom Settings
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
        String senderEmail = 'test@yahoo.com';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create new Case with a valid contact and having 'Waiting for Customer' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = newContact.id;
        newCase.SubStatus__c = 'Waiting for Customer';
        insert newCase; 
        
        //Get the organization Id for reference.
        String orgID = Userinfo.getOrganizationId();
       //String refID =  '[ ref:_'+orgID.substring(0,5) + orgID.substring(11,15)+'._'+String.valueof(newCase.Id).substring(0, 5) + String.valueof(newCase.Id).substring(10,15)+':ref ]';
       //SS 10/01/15 Winter 16 issue - Commented line above and added 2 lines below to get the ref id from formula field
        list <Case> lstCase = [Select Email_Ref_Id__c from Case where id = : newCase.id];
        String refID =  '[ ' + lstCase[0].Email_Ref_Id__c + ' ]';
        
        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        // setup the data for the email
        email.subject = 'RE: test Subject ';
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
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
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 26 October 2013
    * @description: - Test method for incoming emails which have an existing Thread Id
                    - From Address' Domain Country code is not listed on Forwarding Rules
                    - will update an identified case
    */ 
    static testMethod void testForwardEmailWithMathworksOfficeCustomerReplyUnlistedCrit4(){
        //create records on Custom Settings
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
        String senderEmail = 'test@yahoo.com.au';
        Contact newContact = TestDataBuilder.buildTestContact(1, newUser.id, newAccount.id);
        newContact.email = senderEmail;
        insert newContact;
        
        //Create new Case with a valid contact and having 'Waiting for Customer' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = newContact.id;
        newCase.SubStatus__c = 'Waiting for Customer';
        insert newCase; 
        
        //Get the organization Id for reference.
        String orgID = Userinfo.getOrganizationId();
       //String refID =  '[ ref:_'+orgID.substring(0,5) + orgID.substring(11,15)+'._'+String.valueof(newCase.Id).substring(0, 5) + String.valueof(newCase.Id).substring(10,15)+':ref ]';
       //SS 10/01/15 Winter 16 issue- Commented line above and added 2 lines below to get the ref id from formula field
        list <Case> lstCase = [Select Email_Ref_Id__c from Case where id = : newCase.id];
        String refID = '[ ' + lstCase[0].Email_Ref_Id__c + ' ]';
        
        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> ccAddresses = new List<String>();
        ccAddresses.add('email1@email.com');
        ccAddresses.add('email2@email.com');
        
        // setup the data for the email
        email.subject = 'RE: test Subject ';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'Test email Body'+refID;
        email.fromAddress = senderemail;
        envelope.fromAddress = senderemail;
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
        emailHandler testInbound = new emailHandler();
        testInbound.handleInboundEmail(email, envelope);
        
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
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 29 October 2013
    * @description: - Test method for emails coming in where countrycode matching forwarding rules.
                    - No contact matches the email address of the sender. 
                    - Routing rule having a sub area. 
                    - Forwarding email has 'mathworks' domain.
                    - Sender's email matches a contact's email.
    */ 
    static testMethod void testEscalateToDevInboundEmail(){
        //create records on Custom Settings
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
        
        email.subject = 'No Sub Area';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body [DEVID';
        email.binaryAttachments = new list<Messaging.Inboundemail.Binaryattachment>();
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com','cctest@test.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        
        // call the email service class and test it with the data in the testMethod
        emailHandler  testInbound = new  emailHandler  ();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    }
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modifed: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 22 July 2013, Last Modified: 26 October 2013
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
        emailHandler  testInbound = new  emailHandler  ();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 31 October 2013
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
        emailHandler  testInbound = new  emailHandler();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    } 
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 22 July 2013, Last Modified; 26 October 2013
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
        
        // setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com New email address: test@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        
        // call the email service class and test it with the data in the testMethod
        emailHandler  testInbound = new  emailHandler  ();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    } 
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 23 July 2013, Last Modified; 26 October 2013
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
        emailHandler  testInbound = new  emailHandler  ();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    } 
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 23 July 2013, Last Modified: 26 October 2013
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
        emailHandler  testInbound = new  emailHandler  ();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    }
    
    
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 23 July 2013, Last Modified: 26 October 2013
    * @description: - Test method for emails coming in where countrycode matching forwarding rules.
                    - No contact matches the email address of the sender. 
                    - Routing rule having a sub area. 
                    - Forwarding email has 'mathworks' domain.
                    - Sender's email matches a contact's email.
    */ 
    static testMethod void testEscalateToDevWithReferenceID(){
        //create records on Custom Settings
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        csb.buildEmailToCaseOverrideSetting();
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
        
         //Create new Case with a valid contact and having 'Waiting for Customer' status.
        Case newCase = TestDataBuilder.buildTestCase('Open');
        newCase.ContactId = newContact.id;
        newCase.SubStatus__c = 'Waiting for Customer';
        insert newCase;
        
        //Get the organization Id for reference.
        String orgID = Userinfo.getOrganizationId();
       //String refID =  '[ ref:_'+orgID.substring(0,5) + orgID.substring(11,15)+'._'+String.valueof(newCase.Id).substring(0, 5) + String.valueof(newCase.Id).substring(10,15)+':ref ]';
       //SS 10/01/15 - Winter 16 issue - Commented line above and added 2 lines below to get the ref id from formula field
        list <Case> lstCase = [Select Email_Ref_Id__c from Case where id = : newCase.id];
        String refID = '[ ' +lstCase[0].Email_Ref_Id__c + ' ]';
        
        // Relate a new Task to a Case with Thread id containing a reference id
        Task newTask = new task();
        newTask.OwnerId = newUser.id;
        newTask.Status = 'Waiting on Customer';
        newTask.Type = 'Email';
        newTask.subject = 'Test Task Subject';
        newTask.WhatId = newCase.id;
        insert  newTask;
        
        Case insertedCase = [SELECT CaseNumber FROM Case WHERE id = :newCase.id ];
        
        // setup the data for the email
        email.subject = 'No Sub Area';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'This is a test email body [DEVID'+refID+' '+insertedCase.CaseNumber;
        email.binaryAttachments = new list<Messaging.Inboundemail.Binaryattachment>();
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'service@mathworks.com'};
        env.toAddress = 'emailhandler@7xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';

        
        // call the email service class and test it with the data in the testMethod
        emailHandler  testInbound = new  emailHandler  ();
        testInbound.handleInboundEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        List<EmailMessage> existingEmailMessage = [SELECT id FROM EmailMessage WHERE parentId =: newCase.id];
        System.assertEquals(1, createdCases.size());
        System.assertEquals(1, existingEmailMessage.size());
    }

   
}