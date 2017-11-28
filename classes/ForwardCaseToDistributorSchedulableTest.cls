/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *date Original: 15 May 2015, Last Modified:15 May 2015 
 *description : Test class for Batch class to  forward case to distributors */

@isTest
public with sharing class ForwardCaseToDistributorSchedulableTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    public static Account accObj {get; set;}
    public static Contact conObj {get; set;}  

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *date Original: 15 May 2015, Last Modified:15 May 2015 
     *description : Test setUp method to insert test cases */
    @testSetup static void setup() {

        //Create General Setting
         List<General_Settings__c> genSettings = new List<General_Settings__c>([SELECT Id FROM General_Settings__c WHERE SetupOwnerId =: UserInfo.getOrganizationId()]);
            General_Settings__c getSet = new General_Settings__c();
            if(genSettings != null && !genSettings.IsEmpty()){
                getSet.Id = genSettings[0].Id;
            }            
            getSet.ACE_Url__c = 'http://mathworks.com';
            getSet.Escalate_To_Dev_Email__c = 'devsupp@mathworks.com';
            getSet.SetupOwnerId = UserInfo.getOrganizationId();
            getSet.EmailRoutingRule_Current_ResponseTo__c = 'Response_to_PROD__c';
            getSet.Opportunity_Close_Date__c = Date.valueof('2099-01-01');
            getSet.CDSBaseUrl__c='https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v1/';
            getSet.RegEx_Latin__c='^[\u0000-\u04FF]+';
            User usrObj=TestDataBuilder.buildTestUser(0);
            getSet.Default_Opportunity_Owner__c=usrObj.alias;
            getSet.RTToIncludeAddingProjTeamMemberOnInsert__c='Marketing Request,Sales Request';
            getSet.Batch_Size_For_Territory2Trigger__c = '2000';
            getSet.Batch_Schedule_Time_Territory2Trigge__c = '15';
            getSet.Bypass_Assignment_Of_Account_To_Territor__c = false;
            getSet.CaseDeleteOverride_Excluded_Profile_1__c = 'MathWorks Data Management';
            getSet.CaseDeleteOverride_Excluded_Profile_2__c = 'System Administrator';
            getSet.CDS_IsChanged_Interval__c = 0.0003472220;
            getSet.Current_Domain__c = 'https://mathworks--salesdev.cs15.my.salesforce.com/';
            getSet.Emailaddress_Territory2Dml__c = ' sfdcsupport@mathworks.com';
            getSet.HideCheckBoxForDoNotCreateActivity__c = true;
            getSet.HideCheckBoxForSendEmailNotification__c = true;
            getSet.HideOpportunityOwnerSearchBox__c = true;
            getSet.Open_Preference_Center__c = 'https://go2.mathworks.com/mwint00qe000000431aheay';
            getSet.ORC_Url__c = 'http://inside-apps-dev3.mathworks.com/orclookups/contactDetails.do';
            getSet.RegEx_To_Check_ID__c ='[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ;
            getSet.Research_Team_Owner__c ='mwsadmin';
            getSet.ForwardCToDistributorSchedulableInterval__c = 0;
            getSet.BatchSizeForForwardingCasesToDistributor__c = 80;
            upsert getSet;
     
        
        //Create Forwarding Rule custom setting
        csb.buildTestForwardRule();
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        List<Account> testAccounts = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TAccount';
        acc.ownerId     = UserInfo.getUserId();
        acc.BillingStreet = 'test street';
        acc.BillingCity = 'test city';
        acc.BillingCountryCode = 'Ph';
        acc.BillingCountry = 'Philippines';
        acc.BillingPostalCode = '00000';
        testAccounts.add(acc);        

        insert testAccounts;
        
        List<Contact> testContacts = new List<Contact>();
            
        Contact con = new Contact();
        con.AccountId = testAccounts[0].id;
        con.OwnerId = UserInfo.getUserId();
        con.LastName = 'TLastName';
        con.FirstName = 'TFirstname';
        con.MailingStreet = 'test street';
        con.MailingCity = 'test city';
        con.MailingCountryCode = 'PH';
        con.MailingCountry = 'Philippines';
        con.MailingPostalCode = '00000';
        con.Email = 'mwtest@mwtest.com';
        con.MathWorks_Account_ID__c = '12334324';
        con.Siebel_Contact_Id__c = '123234245';
        con.Student__c = false;
        testContacts.add(con);
        insert testContacts;

        List<Case> testCases = new List<Case>();
        for(integer i=0;i<1;i++){

            Case cseObj=TestDataBuilder.buildTestCase('Open');
            cseObj.Origin='ML_Web';
            cseObj.ContactId = testContacts[0].id;
            testCases.add(cseObj);
        }  

        insert testCases;
        
        List<Attachment> testAttachment = new List<Attachment>();
        for(integer i=0;i<1;i++){
            
            Attachment attach=new Attachment();    
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=testCases[i].id;
            testAttachment.add(attach);    
        }
        insert testAttachment;
    }

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *date Original: 15 May 2015, Last Modified:15 May 2015 
     *description : Test method to check whether forwarded cases status has been changed to Cancelled */
    static testMethod void testForwardCaseToDistributor() {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){
        
           Test.startTest();
           
           ForwardCaseToDistributorSchedulable M = new ForwardCaseToDistributorSchedulable();
           Database.executeBatch(M); 
           
           Test.stopTest();
           
           List<Case> cseList=[select status,ForwardToDistributor__c  from Case];
          system.debug(cseList);
           for(Case cse:cseList){
            
            system.assert(cse.status=='Cancelled');
            
          }

        }   

    }

}