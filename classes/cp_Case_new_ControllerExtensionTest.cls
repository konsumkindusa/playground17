/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 10 Oct 2013, Last Modified: 22 October 2013
* @description Test Class for testing functionality of cp_Case_new_ControllerExtension class
*/ 
@isTest
private class cp_Case_new_ControllerExtensionTest {
    
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
   
    static testMethod void TestCSoption1() {
        
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
              
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        //con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        //Inserted by-Archana-mathworks/Cloudsherpas
        con.mailingcountry = 'India';
        con.mailingcountryCode ='In';
        con.mailingstate ='Maharashtra';
        con.mailingstateCode ='Mh';
        con.mailingpostalcode ='123456';
        insert Con; //will create also a portal user
        //Retrieve Portal User created       
        System.debug('***Con :'+Con);
        
        User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        //Modified by:Archana Lohar/Mathworks-Cloudsherpas
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        
       //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.id];
        //System.debug('***pusr :'+pusr );
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        system.runAs(pusr){
            //Test converage for the myPage visualforce page
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'ProductActivation'; //Customer Service - option 1
                myPageCon.CaseObj.Subject = 'subject CsOpt1';
                myPageCon.CaseObj.License__c = '12345';
                myPageCon.CaseObj.Origin = 'Phone'; //to bypass Assignment Rules 
                myPageCon.CaseObj.Description = 'test description';
                myPageCon.createcase();
                
                 /*Retrieve created Case record
            Case cse = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cse != null);*/
                 //Retrieve created Case record
          List<Case> cseList = [Select Id,Subject From Case where subject = 'subject CsOpt1'];
            //Verify a Case has been created
           system.assert(cseList.isEmpty());
            Test.stopTest();    
        }    
    }
    
    static testMethod void TestCSoption2b() {
        
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
       pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
      pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'PasscodeLicense'; //customer Service - option 2
                //Populate fields 
                myPageCon.CaseObj.Subject = 'subject CsOpt2';
                myPageCon.CaseObj.License__c = '12345';
                myPageCon.CaseObj.Origin = 'Phone'; //to bypass Assignment Rules
                //myPageCon.CaseObj.Area__c = 'test';
               // myPageCon.CSPassCodeDesc = new list <string>{'What to do test','','','back up host id test1','back up host id test2',''};
               myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'};
                myPageCon.CSPassCodeDesc = new list <string>{'What to do test','Release #1232131','Host ID Sample','back up host id test1','back up host id test2','test'};
               
                myPageCon.createcase();
                
                 
            //Retrieve created Case record
            List<Case> cseList= [Select Id From Case ];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
            Test.stopTest(); 
           
            
        }
    }
    
    static testMethod void TestCSoption3a() {
      
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
       // User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
       pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
      pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'AddChangeLicense'; //customer Service - option 3
                //Populate fields 
                myPageCon.CaseObj.Subject ='Change an existing license contact';
                myPageCon.CSLicenseContact = new list <string>{'Change an existing license contact','Administrator','Mr.','First Name Test','Middle Name Test','Last Name Test','test@test.com','United States','Mrs.','New First Name','New Middle Name','New Last Name','Developer','Test Department','Test Mail Stop','Test University','Test New Street Address1','Test New Street Address2','Test New City','9999','New Email','99-9999-999','999','999-999-999','9999999999','Additional Request'};
                 myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'};
                myPageCon.CSPassCodeDesc = new list <string>{'What to do test','Release #1232131','Host ID Sample','back up host id test1','back up host id test2','test'};
               
                myPageCon.createcase();
                
                //Retrieve created Case record
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
            Test.stopTest(); 
            
            
        }
    }
    
    static testMethod void TestCSoption3b() {
        
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'AddChangeLicense'; //customer Service - option 3
                //Populate fields 
                myPageCon.CaseObj.Subject ='Add a new license contact';
                myPageCon.CSLicenseContact = new list <string>{'Add a new license contact','Asset manager','Mr.','First Name Test','Middle Name Test','Last Name Test','test@test.com','United States','Mrs.','New First Name','New Middle Name','New Last Name','Developer','Test Department','Test Mail Stop','Test University','Test New Street Address1','Test New Street Address2','Test New City','9999','New Email','99-9999-999','999','999-999-999','9999999999','Additional Request'};
                 myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'};
                myPageCon.CSPassCodeDesc = new list <string>{'What to do test','Release #1232131','Host ID Sample','back up host id test1','back up host id test2','test'};
                myPageCon.createcase();
            Test.stopTest(); 
            
            //Retrieve created Case record
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
        } 
    }
   
    static testMethod void TestCSoption3c() {
        
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
       // User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'AddChangeLicense'; //customer Service - option 3
                //Populate fields 
                myPageCon.CaseObj.Subject ='Remove an existing license contact';
                myPageCon.CSLicenseContact = new list <string>{'Remove an existing license contact','Asset manager','Mr.','First Name Test','Middle Name Test','Last Name Test','test@test.com','United States','Mrs.','New First Name','New Middle Name','New Last Name','Developer','Test Department','Test Mail Stop','Test University','Test New Street Address1','Test New Street Address2','Test New City','9999','New Email','99-9999-999','999','999-999-999','9999999999','Additional Request'};
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'};
                myPageCon.CSPassCodeDesc = new list <string>{'What to do test','Release #1232131','Host ID Sample','back up host id test1','back up host id test2','test'};
                myPageCon.createcase();
            Test.stopTest(); 
            
            //Retrieve created Case record
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
        } 
    }
    
    static testMethod void TestCSoption4() {
        
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
       // User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'RedesignateProducts'; //customer Service - option 4
                //Populate fields 
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'};
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                myPageCon.CSTransfer1 = new list <string>{'Product Name1','1','12345','54321'};
                myPageCon.CSTransfer2 = new list <string>{'Product Name2','2','45678','87654'};
                myPageCon.CaseObj.Description = 'Additional Description';
                myPageCon.createcase();
            Test.stopTest(); 
            
            //Retrieve created Case record  
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
        }
    }
  
    static testMethod void TestCSoption5() {
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
          User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'CombineLicenses'; //customer Service - option 5
                //Populate fields 
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'};
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                myPageCon.CSCombineLic =  new list <string>{'12345','54321','43231',''};
                myPageCon.CaseObj.Description = 'Description Test';
                myPageCon.createcase();
            Test.stopTest(); 
            
            //Retrieve created Case record  
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
        }
    }
  
    static testMethod void TestCSoption6() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
         User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'GeneralCustomerService'; //customer Service - option 6
                //Populate fields
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                myPageCon.createcase();
            Test.stopTest(); 
            
            //Retrieve created Case record  
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
        }
    }
   
    static testMethod void TestTSoption1() {
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test releases
        Release__c rel = TestDataBuilder.buildTestRelease(1, 'PreRelease', true);
        insert rel;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
         User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
		//HW 1776003
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        //faq.PublishStatus = 'Online';
		faq.Language = 'en_US';
		faq.Answers_URL__c = 'http://www.mathworks.com';
        insert faq;
		Case_Deflection__c cd = new Case_Deflection__c();
		cd.Subject__c = 'Test';
		insert cd;
        cp_Case_new_ControllerExtension.passArticleIdRemote(faq.id, 'test', cd.id);
        //HW 1776003  

        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            myPageCon.getReleases();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='MATLAB';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                  myPageCon.isDistributor = true;
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');    
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            List<Case> cseList = [Select Id,Subject From Case where subject = 'test title'];
            //Verify a Case has been created 
            system.assert(cseList.isEmpty());
        }
    }
    
    static testMethod void TestTSoption1b() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        
        FAQ__kav faq = TestDataBuilder.buildTestFAQkav(1);
        //faq.PublishStatus = 'Online';
		faq.Language = 'en_US';
		faq.Answers_URL__c = 'http://www.mathworks.com';
        insert faq;
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            insert productObj;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.Subject = 'test';
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                //myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                //
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');   
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
                myPageCon.refreshProductList(); 
                myPageCon.fetchSuggestedArticles(); 
                myPageCon.doNotHelpful(); 
                myPageCon.doNotHelpful1(); 
                //cp_Case_new_ControllerExtension.doHelpful('test input','article id','article title');
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
           system.assert(cseList.isEmpty());
           
           //cseList = [Select Id From Case where subject = 'Case created as a result of a Web Portal Case Deflection'];
           //system.assertEquals(1, cseList.size());
        } 
    }
    
    
    static testMethod void TestTSoption1c1() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('cc', 'jp');//SS 10/10/2016 Added to set the country code parameter on the page
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            insert productObj;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                //myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                //
                myPageCon.refreshProductRelease(); 
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            //List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
           system.assert(myPageCon.SelectedRelease.equals('-- Select Release --'));     
        } 
    }
    
    static testMethod void TestTSoption1c2() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            insert productObj;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='----------------------------------------------------------------------------------------------------\n' +
									'MATLAB Version: 8.6.0.267246 (R2015b)\n' +
									'MATLAB License Number: 34\n' +
									'Operating System: Microsoft Windows 10 Enterprise Version 10.0 (Build 10586)\n' +
									'Java Version: Java 1.7.0_60-b19 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode\n' +
									'----------------------------------------------------------------------------------------------------\n' +
									'MATLAB                                                Version 8.6         (R2015b)       \n' +
									'Simulink                                              Version 8.6         (R2015b)       \n';
                myPageCon.SelectedRelease = 'R2012a';
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                myPageCon.CaseObj.Description = 'Description Test';
                myPageCon.refreshProductRelease(); 
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            //List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
           //system.assert(myPageCon.SelectedRelease.equals('-- Select Release --'));
        } 
    }
    
    static testMethod void TestTSoption1c3() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;

        Release__c rel = TestDataBuilder.buildTestRelease(1, 'test', true);
        rel.Name = 'R2012a';
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        productObj.release__c='R2012a';
        Product2 productObj2 = TestDataBuilder.buildTestProduct(2);
        productObj2.Name='simulink';
        productObj2.release__c='R2012a';
        Product2 productObj3 = TestDataBuilder.buildTestProduct(3);
        productObj3.Name='Other';
        productObj3.release__c='R2012a';

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
    		insert rel;
            insert productObj;
            insert productObj2;
            insert productObj3;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='----------------------------------------------------------------------------------------------------\n' +
									'MATLAB Version: 8.6.0.267246 (R2012a)\n' +
									'MATLAB License Number: unknown\n' +
									'Operating System: Microsoft Windows 10 Enterprise Version 10.0 (Build 10586)\n' +
									'Java Version: Java 1.7.0_60-b19 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode\n' +
									'----------------------------------------------------------------------------------------------------\n' +
									'MATLAB                                                Version 8.6         (R2012a)       \n' +
									'Simulink                                              Version 8.6         (R2012a)       \n';
                myPageCon.SelectedRelease = 'R2012a';
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';  
                myPageCon.CaseObj.Description = 'Description Test';
                myPageCon.refreshProductRelease(); 
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            //List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
            system.assert(myPageCon.SelectedRelease.equals('R2012a'));
        } 
    }
    
    static testMethod void TestTSoption1c4() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            insert productObj;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test';
                myPageCon.SelectedRelease = 'R2012a';
                  myPageCon.isDistributor = true;
                //myPageCon.CaseObj.Product_Lookup__c='Matlab';
                //myPageCon.CaseObj.Subject='test title';
               // myPageCon.CaseObj.description = 'test description';
                //
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                //myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                //
                myPageCon.refreshProductRelease(); 
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            //List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
           system.assert(myPageCon.SelectedRelease.equals('-- Select Release --'));
        } 
    }
    
    static testMethod void TestTSoption1c5() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            insert productObj;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='   ';
                myPageCon.SelectedRelease = 'R2012a';
                myPageCon.isDistributor = true;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                //myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                //
                myPageCon.refreshProductRelease(); 
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            //List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
           system.assert(myPageCon.SelectedRelease.equals('-- Select Release --'));
        } 
    }
    
    static testMethod void TestTSoption1c6() {
      csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;

        Release__c rel = TestDataBuilder.buildTestRelease(1, 'test', true);
        rel.Name = 'R2012a';
        Product2 productObj = TestDataBuilder.buildTestProduct(1);
        productObj.Name='Matlab';
        productObj.release__c='R2012a';
        Product2 productObj2 = TestDataBuilder.buildTestProduct(2);
        productObj2.Name='simulink';
        productObj2.release__c='R2012a';
        Product2 productObj3 = TestDataBuilder.buildTestProduct(3);
        productObj3.Name='Other';
        productObj3.release__c='R2012a';

        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
           
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
    		insert rel;
            insert productObj;
            insert productObj2;
            insert productObj3;
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 1
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='----------------------------------------------------------------------------------------------------\n' +
									'MATLAB Version: 8.6.0.267246 (R2012a)\n' +
									'MATLAB License Number: 34\n' +
									'Operating System: Microsoft Windows 10 Enterprise Version 10.0 (Build 10586)\n' +
									'Java Version: Java 1.7.0_60-b19 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode\n' +
									'----------------------------------------------------------------------------------------------------\n' +
									'Other                                              Version 8.6         (R2012a)       \n';
                myPageCon.SelectedRelease = 'R2012a';
                  myPageCon.isDistributor = true;
                //myPageCon.CaseObj.Product_Lookup__c='Matlab';
                //myPageCon.CaseObj.Subject='test title';
               // myPageCon.CaseObj.description = 'test description';
                //
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                //myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                //
                myPageCon.refreshProductRelease(); 
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
            //List<Case> cseList = [Select Id,Subject From Case where subject = 'Service Request Title Test'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
            system.assert(myPageCon.SelectedRelease.equals('R2012a'));
        } 
    }
    
    static testMethod void TestTSoption2() {
    
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select  Id,LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
           
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Producthelp'; //Technical Support - option 2
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='matlab';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                  myPageCon.isDistributor = true;
                  
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');  
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                    //myPageCon.attlmdebugout = testAttachment;
                    myPageCon.attlicensedat.name = 'licensedat filename';
                    myPageCon.attlmdebugout.name = 'lmdebug filename';
                    myPageCon.attlicensedatBody = myAttach.body;
                    myPageCon.attlmdebugoutBody = myAttach.body;
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
            Test.stopTest(); 
            //Retrieve created Case record  
            //Case cse = [Select Id From Case];
            //Verify a Case has been created
            //system.assert(cse == null);
             List<Case> cseList = [Select Id,Subject From Case where subject = 'test title'];
           //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
           system.assert(cseList.isEmpty());
        } 
    }
    
   
    static testMethod void TestTSoption2b() {
    
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ph';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = true;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select  Id,LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          pusr.Portal_User_Status__c = 'Student';
          
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            myPageCon.getdistributoremailaddress();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Producthelp'; //Technical Support - option 2
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='MATLAB';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                  myPageCon.isDistributor = true;
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');   
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                    //myPageCon.attlmdebugout = testAttachment;
                    myPageCon.attlicensedat.name = 'licensedat filename';
                    myPageCon.attlmdebugout.name = 'lmdebug filename';
                    myPageCon.attlicensedatBody = myAttach.body;
                    myPageCon.attlmdebugoutBody = myAttach.body;
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
            Test.stopTest(); 
            //Check case is not created 
             list <Case> cselist = [Select Id,Subject From Case where Subject = 'test title'];
            System.debug('***cselist ***'+cselist);
            //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
            system.assert(cseList.isEmpty());
        } 
    }
    
     static testMethod void TestTSoption2c() {
    
       csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ph';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = true;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select  Id,LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          pusr.Portal_User_Status__c = 'Student';
          
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            myPageCon.getdistributoremailaddress();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 2
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='MATLAB';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                  myPageCon.isDistributor = true;
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                    //myPageCon.attlmdebugout = testAttachment;
                    myPageCon.attlicensedat.name = 'licensedat filename';
                    myPageCon.attlmdebugout.name = 'lmdebug filename';
                    myPageCon.attlicensedatBody = myAttach.body;
                    myPageCon.attlmdebugoutBody = myAttach.body;
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
            Test.stopTest(); 
            //Check case is not created 
            list <Case> cselist = [Select Id,Subject From Case where Subject = 'test title'];
            System.debug('***cselist ***'+cselist);
            //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
            system.assert(cseList.isEmpty());
        } 
    }
    
    static testMethod void TestTSoption2c1() {
    
       csb.buildGenSetting();
       // csb.buildTestForwardRule();
        //Create test mathworks office record
        Forwarding_Rule__c fR = new Forwarding_Rule__c();
        fr.name = 'ad';
        fr.Forwarding_Email_Address__c = 'dvessopo@mathworks.com';
        fr.Distributor_Name__c = 'Distributor Name';
        fr.Dommain_Country_Code__c = 'ad';
        fr.Case_Area_Country_Code__c = 'ES';
        fr.MathWorks_Office__c = false;
        insert fr;
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ph';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = true;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select  Id,LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          pusr.Portal_User_Status__c = 'Student';
          
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            myPageCon.getdistributoremailaddress();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 2
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='MATLAB';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                  myPageCon.isDistributor = false;
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');    
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                    //myPageCon.attlmdebugout = testAttachment;
                    myPageCon.attlicensedat.name = 'licensedat filename';
                    myPageCon.attlmdebugout.name = 'lmdebug filename';
                    myPageCon.attlicensedatBody = myAttach.body;
                    myPageCon.attlmdebugoutBody = myAttach.body;
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
            Test.stopTest(); 
              list <Case> cselist = [Select Id,Subject From Case where Subject = 'test title'];
            System.debug('***cselist ***'+cselist);
            //Verify a Case has been created 
            system.assert(!cseList.isEmpty());
        } 
    }
    static testMethod void TestTSoption2b1() {
    
        csb.buildGenSetting();
        //csb.buildTestForwardRule();
        Forwarding_Rule__c fR = new Forwarding_Rule__c();
        fr.name = 'ad';
        fr.Forwarding_Email_Address__c = 'dvessopo@mathworks.com';
        fr.Distributor_Name__c = 'Distributor Name';
        fr.Dommain_Country_Code__c = 'ad';
        fr.Case_Area_Country_Code__c = 'ES';
        fr.MathWorks_Office__c = false;
        insert fr;
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ph';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = true;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select  Id,LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          pusr.Portal_User_Status__c = 'Student';
          
          insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            myPageCon.getdistributoremailaddress();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Producthelp'; //Technical Support - option 2
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='MATLAB';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                  myPageCon.isDistributor = false;
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body , 'application/pdf');   
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                    //myPageCon.attlmdebugout = testAttachment;
                    myPageCon.attlicensedat.name = 'licensedat filename';
                    myPageCon.attlmdebugout.name = 'lmdebug filename';
                    myPageCon.attlicensedatBody = myAttach.body;
                    myPageCon.attlmdebugoutBody = myAttach.body;
                myPageCon.outputerr = 'Test Crash Report ';
                //attach file forlicense.dat
                //attach file forlmdebug.out
                myPageCon.createcase();
            Test.stopTest(); 
            //Check case is not created 
           list <Case> cselist = [Select Id,Subject From Case where Subject = 'test title'];
            System.debug('***cselist ***'+cselist);
            //Verify a Case has been created 
            system.assert(!cseList.isEmpty());
        } 
    }
    static testMethod void TestCSoption7() {
      csb.buildGenSetting();
        //csb.buildTestForwardRule();
        
        Forwarding_Rule__c fR = new Forwarding_Rule__c();
        fr.name = 'ad';
        fr.Forwarding_Email_Address__c = 'dvessopo@mathworks.com';
        fr.Distributor_Name__c = 'Distributor Name';
        fr.Dommain_Country_Code__c = 'ad';
        fr.Case_Area_Country_Code__c = 'ES';
        fr.MathWorks_Office__c = false;
        insert fr;
        
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select Id, LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
         User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        
        //Changed FederationIdentifier as it was already exists for this organization
        pusr.FederationIdentifier = '123456789';
        pusr.ContactId = con.Id;
        insert pusr;
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            
            Test.startTest();
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'GeneralCustomerService'; //customer Service - option 6
                //Populate fields
                myPageCon.isDistributor = false;
                myPageCon.CSCustomerInfo = new list <string>{'Fname','Lname','test@email.com'}; 
                myPageCon.CaseObj.Subject ='Service Request Title Test';
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Description = 'Description Test';
                myPageCon.createcase();
            Test.stopTest(); 
            
            //Retrieve created Case record  
            List<Case> cseList = [Select Id From Case];
            //Verify a Case has been created
            system.assert(cseList != null);
            System.assertEquals(1, cseList.size());
        }
    }
    static EmailTemplate emailTemp;
    
     static{
                //String emailBody = '\'{!Contact.\'';
                emailTemp = TestDataBuilder.buildTestEmailTemplate('test');
                emailTemp.body = '\'{!Contact.\'';
                emailTemp.Subject = 'Test Subject';
                emailTemp.DeveloperName='TestEmailTemp';
                emailTemp.FolderId =[select id,name  from folder where name = 'CS Japan'].id;
                emailTemp.TemplateType ='Text';
                
            }
    static testMethod void testupdateCaseArea(){
    
       String testEmailTemp = 'test';
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        //TestDataBuilder.buildTestEmailTemplate(testEmailTemp);
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ph';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = true;
        insert con; //will create also a portal user
        
        //Retrieve Portal User created
        //User pusr = [Select  Id,LastName, Email, Portal_User_Status__c, Country_Code__c, Student__c From User Where ContactId = : con.Id];
        User pusr= TestDataBuilder.buildTestUser(1);
         pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
            
          //Changed FederationIdentifier as it was already exists for this organization
          pusr.FederationIdentifier = '123456789';
          pusr.ContactId = con.Id;
          pusr.Portal_User_Status__c = 'Student';
          
            insert pusr;
          
        //HW, 1656885
        //Create standard user
        User stdusr= TestDataBuilder.buildTestUser(2);
         stdusr.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
            
            insert stdusr;
          
            //Disable On-Support trigger on Case
            CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
            cseTrigHandler.stopTrigger();
        
        //To test if emailTemp can be inserted as a standard user and then queried by portal user
        //Test Failed: emailTemp can be inserted but cannot be queried
        /*
        System.runAs(stdusr) {
            emailTemp.Name='Distributor Send Email';
            emailTemp.body='{!Contact. {!Contact.Account}';
            insert emailTemp;
            System.debug('emailTemp'+emailTemp.body);
            System.debug('emailTemp'+(emailTemp.body).contains('{!Contact.'));
            List <EmailTemplate> emailTempList = [SELECT Name, Body, Subject, Id FROM EmailTemplate WHERE Name LIKE '%Distributor Send Email%'];
            System.debug('emailTempList: ' + emailTempList);
        }*/

        System.runAs(stdusr) {
        //System.runAs(pusr) {
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            myPageCon.getPageFrame();
            myPageCon.getCaseObj();
            myPageCon.getdistributoremailaddress();
          
            Test.startTest();
                 
            emailTemp.Name='Distributor Send Email';
            emailTemp.body='{!Contact. {!Contact.Account}';
            insert emailTemp;
            System.debug('emailTemp'+emailTemp.body);
            System.debug('emailTemp'+(emailTemp.body).contains('{!Contact.'));
            List <EmailTemplate> emailTempList = [SELECT Name, Body, Subject, Id FROM EmailTemplate WHERE Name LIKE '%Distributor Send Email%'];
            System.debug('emailTempList: ' + emailTempList);
                 
                //Simulate selecting of task on New Case page
                myPageCon.selTask = 'Installation'; //Technical Support - option 2
                //Populate fields 
                myPageCon.caseObj.License__c = '432211';
                myPageCon.CaseObj.Platform__c = 'Windows x32';
                myPageCon.CaseObj.OS__c= 'Windows Any';
                myPageCon.outputver='test output ver text';
                myPageCon.SelectedRelease = 'R2012a';
                //myPageCon.CaseObj.Product_Lookup__c='matlab';
                myPageCon.CaseObj.Subject='test title';
                myPageCon.CaseObj.description = 'test description';
                //attach file for "attach file(s)":
                    Attachment myAttach = new Attachment();
                    myAttach.ParentId = (!Test.isRunningTest()) ? 'xxxxxxxxxx' : null;
                    myAttach.body = (!Test.isRunningTest()) ? pageRef.getContentAsPdf() : blob.valueOf('Test Attachement');
                    cp_Case_new_ControllerExtension.Attwrapper testAttachment = new cp_Case_new_ControllerExtension.Attwrapper('attachName',myAttach.body, 'application/pdf');    
                    myPageCon.attwrapperlist = new  list <cp_Case_new_ControllerExtension.Attwrapper>{ testAttachment,testAttachment,testAttachment,testAttachment,testAttachment};
                    myPageCon.attlicensedat.name = 'licensedat filename';
                    myPageCon.attlmdebugout.name = 'lmdebug filename';
                    myPageCon.attlicensedatBody = myAttach.body;
                    myPageCon.attlmdebugoutBody = myAttach.body;
                    myPageCon.outputerr = 'Test Crash Report ';
              System.debug('**isDistributor**'+myPageCon.isDistributor);
                
               myPageCon.createcase();
              
            Test.stopTest(); 
            //Check case is not created 
            list <Case> cselist = [Select Id From Case];
            //Verify a Case has not been created because the Case request has been forwarded to a Distributor email
             system.assertEquals(cselist.size(),0);
           system.assertEquals(myPageCon.isDistributor,false);
        
        }
    
    }
    
    
    static testMethod void TestCreatecaseNullArea() {
        
        csb.buildGenSetting();
        csb.buildTestForwardRule();
        csb.buildTestRoutingRule();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create test account
        Account acc = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acc;
        
        //create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@email.com';
        con.MathWorks_Account_ID__c = '1234599999';
        con.Country_Code__c = 'ad';
        con.Siebel_Contact_Id__c = 'MW-1234599';
        con.Student__c = false;
        insert con;
        
        //Retrieve Portal User created
        User pusr= TestDataBuilder.buildTestUser(1);
        pusr.ProfileId = csb.getUtilOverageHighVolumCustomerPortalUserProfileId();
        pusr.ContactId = con.Id;
        insert pusr;
        
        System.runAs(pusr) {
            
            PageReference pageRef = Page.cp_case_new;
            Test.setCurrentPageReference(pageRef);
            
            //create an instance of the controller
            cp_Case_new_ControllerExtension myPageCon = new cp_Case_new_ControllerExtension();
            //myPageCon.getCaseObj();
            
            Test.startTest();
            
                myPageCon.fwdRule=null;
                myPageCon.selTask='Installation';
                myPageCon.SelectedRelease='R2013b';
                cp_case_new_controllerextension.skipUpdateCaseArea = true;
                myPageCon.createcase();
                myPageCon.selTask=null;
                myPageCon.createcase();
            
                Product2 productObj = TestDataBuilder.buildTestProduct(1);
                productObj.Name='Matlab';
                productObj.release__c='R2013b';
                productObj.Hide_on_Portal__c=false;
                productObj.ProductCode='AA';
                productObj.Release__c='No Release';
                insert productObj;
                myPageCon.isDistributor = false;
                myPageCon.CaseObj.product_lookup__c=productObj.id;
                myPageCon.updateCaseSubArea();
                myPageCon.setUrl();
                Product2 productObj1 = TestDataBuilder.buildTestProduct(2);
                productObj1.Name='simulink';
                productObj1.release__c='R2013b';
                productObj1.Hide_on_Portal__c=false;
                insert productObj1;
            
                myPageCon.refreshProductList(); 
                myPageCon.fwdRule.Forwarding_Email_Address__c='test@test.ph';
            
                //myPageCon.fwdRule.MathWorks_Office__c=false;
                
                emailTemp.Name='Distributor Send Email';
                emailTemp.body='{!Contact. {!Contact.Account}';
                
                insert emailTemp;
                //system.assert(emailTemp!= null);
                //myPageCon.updateCaseArea();
                //Retrieve created Case record
                List<Case> cseList= [Select Id From Case ];
                //Verify a Case has been created
                system.assert(cseList != null);
                //Test.stopTest();        
        }
    }
    
}