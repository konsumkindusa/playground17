@isTest
private class ContactDMLTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    static testMethod void testStudentCustomerUpdateHVCPUser(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
        User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error
        
        User PortalUsr = new User();
        Contact cnt = new Contact();
        
        Test.startTest();
         
         system.runAs(usrOwner){
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
                  
         cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '00012345';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         cnt.email = 'testmail@test.com';
         cnt.student__c = true;
         cnt.Siebel_Contact_id__c = '34567';
         insert cnt;
    
         User hvcpStudent = TestDataBuilder.buildPortalTestUser(0);
         hvcpStudent.ContactId = cnt.Id;
         hvcpStudent.FederationIdentifier =  cnt.MathWorks_Account_ID__c ;  
         hvcpStudent.country_code__c = cnt.country_code__c;    
         hvcpStudent.UserRoleId = null;
         hvcpStudent.CommunityNickName = cnt.FirstName.left(1) + cnt.LastName + cnt.MathWorks_Account_ID__c;
         hvcpStudent.IsActive = true;  
         insert hvcpStudent;
             
         cnt.student__c = true;
         cnt.FirstName = 'testname';
         cnt.MathWorks_Account_ID__c = '00012345';     
         
         Update cnt;
         
         cnt.student__C = false;
         cnt.FirstName= 'testname';  
         cnt.MathWorks_Account_ID__c = '00012345';     
         
         Update cnt;
         
         cnt.student__c = true;
         cnt.FirstName = 'testname';
         cnt.MathWorks_Account_ID__c = '';     
         
         Update cnt;
         
         
         }
        Test.stopTest();
        
        PortalUsr = [Select Id, Name, student__c, firstName, LastName,FederationIdentifier,Portal_User_Status__c from User where ContactId = :cnt.Id];
        System.AssertEquals(PortalUsr.firstName, 'testname' );
        System.assertEquals(PortalUsr.FederationIdentifier, null);
        System.assertEquals(PortalUsr.Portal_User_Status__c, 'Student');
        
        
    }
    
    
    static testMethod void testStudentUpdateInActivateHVCPUser(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
        User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error

        User PortalUsr = new User();
        Contact cnt = new Contact();
       
        Test.startTest();
        system.runAs(usrOwner){
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
                  
         cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '0012876';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         cnt.email = 'testmail@test.com';
         cnt.student__c = true;
         cnt.Siebel_Contact_id__c = '34567';
         cnt.MathWorks_Account_ID__c = '222345';
         insert cnt;
                           
         User hvcpStudent = TestDataBuilder.buildPortalTestUser(0);
         hvcpStudent.ContactId = cnt.Id;
         hvcpStudent.FederationIdentifier =  cnt.MathWorks_Account_ID__c ;  
         hvcpStudent.country_code__c = cnt.country_code__c;    
         hvcpStudent.UserRoleId = null;
         hvcpStudent.CommunityNickName = cnt.FirstName.left(1) + cnt.LastName + cnt.MathWorks_Account_ID__c;
         hvcpStudent.IsActive = true;  
         insert hvcpStudent;
            
         cnt.LastName= 'portaltestname';  
         cnt.student__C = false; 
         Update cnt;        
         }
         Test.stopTest();
         PortalUsr = [Select Id, Name, student__c, LastName, country_code__c from User where ContactId = :cnt.Id]; 
  
         System.AssertEquals(PortalUsr.LastName ,'portaltestname' ); 
         System.assertEquals(PortalUsr.student__c, false);
    }
    
    
    static testMethod void testStudentCreateHVCPUser(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
        User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error
        
        List<User> hvcpStudent;
        
        Test.startTest();
         
         system.runAs(usrOwner){
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
                  
         Contact cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '123456';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         cnt.email = 'testmail@test.com';
         cnt.student__c = true;
         cnt.Siebel_Contact_id__c = '34567';
         insert cnt;         
         
         hvcpStudent = [Select Id, Name, firstName, LastName from User where ContactId = :cnt.Id];
         }
        Test.stopTest();
        System.Assert(hvcpStudent.size() == 0);
     
    }
    
    
    static testMethod void testStudentCreateHVCPUserException(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
        User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error
        
        List<User> hvcpStudent;
        
        Test.startTest();
         
         system.runAs(usrOwner){
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
                  
         Contact cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '123456';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         
         cnt.student__c = true;
         cnt.Siebel_Contact_id__c = '34567';
         insert cnt;         
         
         hvcpStudent = [Select Id, Name, firstName, LastName from User where ContactId = :cnt.Id];
         }
        Test.stopTest();
        System.Assert(hvcpStudent.size() == 0);
        
    }
    
    
    static testMethod void testCustomerCreateHVCPUser(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
        User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error
        
        List<User> hvcpStudent;
        
        Test.startTest();
         
         system.runAs(usrOwner){
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
                  
         Contact cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '123456';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         cnt.email = 'testmail@test.com';
         cnt.student__c = false;
         cnt.Siebel_Contact_id__c = '34567';
         insert cnt;         
         
         hvcpStudent = [Select Id, Name, firstName, LastName from User where ContactId = :cnt.Id];
         }
        Test.stopTest();
        System.Assert(hvcpStudent.size() == 0);
        
    }
    
    
    static testMethod void testStudentUpdateHVCPUser(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
         User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error

         User PortalUsr = new User();

         Contact cnt = new Contact();
        
         Test.startTest();
         
         system.runAs(usrOwner){
         CheckRecursive.run = true;
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
         CheckRecursive.run = true;
         cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '0012876';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         cnt.email = 'testmail@test.com';
         cnt.student__c = true;
         cnt.Siebel_Contact_id__c = '34567';
         insert cnt;
     
         User hvcpStudent = TestDataBuilder.buildPortalTestUser(0);
         hvcpStudent.ContactId = cnt.Id;
         hvcpStudent.FederationIdentifier =  cnt.MathWorks_Account_ID__c ;  
         hvcpStudent.country_code__c = cnt.country_code__c;    
         hvcpStudent.UserRoleId = null;
         hvcpStudent.CommunityNickName = cnt.FirstName.left(1) + cnt.LastName + cnt.MathWorks_Account_ID__c;
         hvcpStudent.IsActive = true;  
         insert hvcpStudent;

         CheckRecursive.run = true;    
         cnt.student__C = false;
         cnt.FirstName= 'portaltestname';  
         cnt.MathWorks_Account_ID__c = '0012877';   

         Update cnt;
         
         }
        Test.stopTest();
        
        PortalUsr = [Select Id, Name, student__c, firstName, LastName,FederationIdentifier from User where ContactId = :cnt.Id];
        System.AssertEquals(PortalUsr.FirstName ,'portaltestname' );
        System.AssertEquals(PortalUsr.FederationIdentifier ,'0012877' );  
    }
    
    static testMethod void testCustomerUpdateHVCPUser(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        /*UserRole usrRole = [Select Id,name from UserRole where name like '%MathWorks Customer Services%']; 
        User usrOwner = TestDataBuilder.buildTestUser(0);
        usrOwner.UserRoleId = usrRole.Id;
        insert usrOwner; */
        
        User usrOwner = [Select Id From User Where Id = : UserInfo.getUserId()]; //current user was used to avoid mixed dml error

        User PortalUsr = new User();

        Contact cnt = new Contact();
        
        Test.startTest();
         
         system.runAs(usrOwner){
         Account acc = TestDataBuilder.buildTestAccount(0,usrOwner.Id);
         insert acc;
         CheckRecursive.run = true;         
         cnt = TestDataBuilder.buildTestContact(0,usrOwner.Id, acc.Id);
         cnt.MathWorks_Account_ID__c = '0012876';
         cnt.MailingCountryCode = 'US';
         cnt.country_code__c = 'US';
         cnt.email = 'testmail@test.com';
         cnt.student__c = false;
         cnt.Siebel_Contact_id__c = '34567';
         insert cnt;
             
         User hvcpStudent = TestDataBuilder.buildPortalTestUser(0);
         hvcpStudent.ContactId = cnt.Id;
         hvcpStudent.FederationIdentifier =  cnt.MathWorks_Account_ID__c ;  
         hvcpStudent.country_code__c = cnt.country_code__c;    
         hvcpStudent.UserRoleId = null;
         hvcpStudent.CommunityNickName = cnt.FirstName.left(1) + cnt.LastName + cnt.MathWorks_Account_ID__c;
         hvcpStudent.IsActive = true;  
         insert hvcpStudent;
         
         CheckRecursive.run = true;
         cnt.student__C = true;
         cnt.FirstName= 'portaltestname';  
         cnt.MathWorks_Account_ID__c = '0';     
         
         Update cnt;
         
         }
        Test.stopTest();
        
        PortalUsr = [Select Id, Name, student__c, firstName, LastName,FederationIdentifier from User where ContactId = :cnt.Id];
        System.AssertEquals(PortalUsr.FirstName ,'portaltestname' );
        System.AssertEquals(PortalUsr.student__C ,true );
        System.AssertEquals(PortalUsr.FederationIdentifier , null);
        
    }
 
}