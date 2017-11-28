/**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
    * @Last Modified by : Archana Lohar - Cloud Sherpas/Mathworks,
    * @date Original: 26 July 2015, 
    * @LastModified Date : 26 July 2015
    * @description    Test Class to check the functionality of Class "UEH_MessageRoute" for routing to 
                      the appropriate module using to address(including dynamic module class instantiation)  
    
    */
    @isTest
    public with sharing class UEH_MessageRoutingUtilTest {
        
    //re-create custom setting test records when running the test class
    static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
        
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    
    /*
      @name         getModuleByToAddressTest 
      @date         26 July 2015
      @author       Archana
      @param        none.
      @return       Void. 
      @description  Test method  to check the functionality of method "getModuleByToAddress" for getting appropriate module
                    class name by Toaddress  
    .
     */
     
     public static testMethod void getModuleByToAddressTest(){ 
     
     //Inserting BlackList_Custom_Setting__c 
     custsettbuild.builtUEH_Recipient_Module_Handler();
     
     test.startTest();
     
     //Creating Test Data.
     String toAddressPresent = 'support@mathworks.com';
     System.assertEquals(UEH_MessageRoutingUtil.getModuleByToAddress(toAddressPresent), 'EmailHandler_Case');
     
     String toAddressNotPresent = 'archana@abc.com';
     System.assertEquals(UEH_MessageRoutingUtil.getModuleByToAddress(toAddressNotPresent), 'ModuleNotFound'); 
      
     test.stopTest();
     }   
         /*
      @name         getHandlerClassBykeyPrefixTest
      @date         27 July 2015
      @author       Sagar Talele
      @param        none.
      @return       Void. 
      @description  Test method  to check the functionality of method "getHandlerClassBykeyPrefix" for getting appropriate handler
                    class name by KeyPrefix.
    .
     */
     
     public static testMethod void getModuleByKeyPrefixTest(){ 
     
     //Inserting UEH_KeyPrefix_Module_Handler__c 
     custsettbuild.builtUEH_KeyPrefix_Module_Handler();
     
     test.startTest();
     
     //Creating Test Data.
     String toKeyPrefix = 'Z01';
     System.assertEquals(UEH_MessageRoutingUtil.getModuleByKeyPrefix(toKeyPrefix), 'CaseHandler');
     
     String tokeyPrefixfalseTest = 'Z02';
     System.assertEquals(UEH_MessageRoutingUtil.getModuleByKeyPrefix(tokeyPrefixfalseTest), 'ModuleNotFound'); 
      
     test.stopTest();
     }
        
      /*
      @name         routeMessageToModuleTest 
      @date         3 August 2015
      @author       Archana
      @param        none.
      @return       Void. 
      @description  Test method  to check that class has been instantiated dynamically.
     */
 
     public static testMethod void routeMessageToModuleTest(){ 
    
        test.startTest();
         
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
        
        //Positive Test
        UEH_MessageRoutingUtil.routeMessageToModule(emailObj,envelopeObj,'SampleEmailToSObjectModuleHandler');
        
        List<UEH_Inbound_Email_Log__c> logList = new List<UEH_Inbound_Email_Log__c>();
         
        logList = [select id,UEH_Status__c from UEH_Inbound_Email_Log__c];
        system.assert(logList[0].UEH_Status__c=='Accepted:Routed');
         
        //Negative Test
         try{
        
            UEH_MessageRoutingUtil.routeMessageToModule(emailObj,envelopeObj,'ClassNotExist');
         }
         catch(Exception ex){
             
            List<UEH_Inbound_Email_Log__c> logListNegativeTest = new List<UEH_Inbound_Email_Log__c>();
             
            logList = [select id,UEH_Status__c from UEH_Inbound_Email_Log__c];
            system.assert(logList[0].UEH_Status__c=='Accepted:Failed to Instantiate');
             
         }
         
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
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address: we recently received a request to change your outgoing Salesforce accounts email address for username kan@mathworks.com.uat.New email address: testsupp@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        
        UEH_MessageRoutingUtil.ForwardRequestToUserEmail(email, env); 
        
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
        email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address: we recently received a request to change your outgoing Salesforce accounts email address for username kan@mathworks.com.uat.New email address: testsupp@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'service@mathworks.com'};
        env.toAddress = 'emailhandler@7xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';

        UEH_MessageRoutingUtil.ForwardRequestToUserEmail(email, env);
        
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
        
        // setup the data for the email
        
        email.subject = 'Sandbox: You have requested to change your salesforce.com email address.';
        email.ccAddresses = ccAddresses;
        email.plainTextBody = 'we recently received a request to change your outgoing Salesforce accounts email address for username kan@mathworks.com.uat.New email address: testsupp@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        UEH_MessageRoutingUtil.ForwardRequestToUserEmail(email, env);
        
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
        //email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address:    TUser1@mathworks.com New email address: test@mathworks.com';
        email.htmlBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com Previous email address: we recently received a request to change your outgoing Salesforce accounts email address for username kan@mathworks.com.uat.New email address: testsupp@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'support@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        UEH_MessageRoutingUtil.ForwardRequestToUserEmail(email, env);
        
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
        //email.plainTextBody = 'This is a test email body '+ 'User name: TUser1@mathworks.com New email address: test@mathworks.com';
        email.htmlBody = 'we recently received a request to change your outgoing Salesforce accounts email address for username kan@mathworks.com.uat.New email address: testsupp@mathworks.com';
        email.fromAddress = senderEmail;
        env.fromAddress = senderEmail;
        email.toAddresses = new string[]{'supporte@mathworks.com'};
        env.toAddress = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';

        UEH_MessageRoutingUtil.ForwardRequestToUserEmail(email, env);
        
        List<Case> createdCases = [SELECT Status,Origin,Subject,Description,Area__c,Sub_Area__c FROM CASE];
        
        System.assertEquals(0, createdCases.size());
    }
 }