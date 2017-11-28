/*
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, @Last Modified: kishore AN- Cloud Sherpas/Mathworks, Faina Gorelik
 *@date Original: 9 June 2014, Last Modified: 1st April 2015, 19th August 2015, 1st June 2017
 *@description This  is Test class for 'LeadConversionController' class .
 *@revision: Dennis Atwood (1770924) In the convertUnknownLeadWithOppAndActivity test Method, populate Lead.Competitor__c field
 			 and assert that created Task's Description field contains the text from Competitor__c
 *@revision: Updated the email addresses in the insert lead method
             Archana lohar|1st April 2015|Added account options selected value to respected scenario. Faina added Handraiser fields to the lead object
 */

@isTest(seeAlldata=true)//For DupeBlocker Package
public with sharing class LeadConversionControllerTest {
    public static String kwncont = 'Known Contact';
    public static String unkwncont ='Unknown Contact';
    public static Integer index=0;
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    /*
    @ name    convertLeadWithExsistingAccountByNameAndCountry  
    @ date    2.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion with opportunity With 
                  Exsisting Account By Name And Country.                           
     */ 
    //Positive Test
    static testMethod void convertLeadWithExsistingAccountByNameAndCountry() { 

        //Inserting lead
        Lead leadObjTest = insertLead();

        leadObjTest.RecordTypeId =UtilityHelper.getLeadRecordTypeId(unkwncont);

        leadObjTest.account__c=null;
        leadObjTest.contact__c=null;
        leadObjTest.company='Test12345';
        leadObjTest.Country='United States';
        leadObjTest.CountryCode = 'US';
        leadObjTest.StateCode = 'NY';
        leadObjTest.State = 'New York';
        leadObjTest.Email ='john123Test@xyz.coz';
        leadObjTest.firstName ='testFirstName';
        leadObjTest.Hand_Raiser_Type__c ='Contact Maintenance';
        leadObjTest.Hand_Raiser_Responses__c = 'Hand Raiser Response';


        //update lead with accoount and contact null
        update leadObjTest;

        //create Account record from TestDataBuilder.
        Account dummyaccObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        dummyaccObj.BillingCity ='Rio De Janeiro';
        dummyaccObj.BillingCountryCode = 'US';
        dummyaccObj.BillingCountry = 'United States';
        dummyaccObj.BillingStateCode = 'NY';
        dummyaccObj.BillingState = 'New York';
        dummyaccObj.name ='Test12345';


        insert dummyaccObj;


        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        //set doNotCreateOpty to true
        controller.doNotCreateOpty=true;

        //set selcontactid 
        System.currentPagereference().getParameters().put('accountId',dummyaccObj.id);
        controller.selAccountid=dummyaccObj.id;

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);

        //This is for creating opportunity opportunity
        controller.ownerId=usrObj.id;

        controller.getLeadRecordToConvert();
        
        //set selected Account option to reccAccs
        controller.selectedValue='reccAccs';


        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];

        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;

        //Check for correct account  associated
        system.assertEquals( convertRes.getAccountId(),dummyaccObj.id);

        test.stopTest();

    }

    /*
        @ name    convertLeadWithExistingContactByEmailURT  
        @ date    7.July.2014
        @ author  Archana Lohar
        @ param   none.
        @ return  Void. 
        @ description Method to Implement test for LeadConversion with opportunity.                           
     */
    //Positive Test
    static testMethod void convertLeadWithExsistingAccountByLocationAndName() { 

        //Inserting lead
        Lead leadObjTest = insertLead();

        leadObjTest.RecordTypeId =UtilityHelper.getLeadRecordTypeId(unkwncont);

        leadObjTest.account__c=null;
        leadObjTest.contact__c=null;
        leadObjTest.company='Test12345';
        leadObjTest.CountryCode = 'IN';
        leadObjTest.Country = 'India';
        leadObjTest.StateCode = 'MH';
        leadObjTest.State = 'Maharashtra';
        leadObjTest.City ='Rio De Janeiro';
        leadObjTest.Email ='john123Test@xyz.coz';
        leadObjTest.firstName ='testFirstName';
        leadObjTest.Sector__c = 'Commercial';
        leadObjTest.Hand_Raiser_Type__c ='Contact Maintenance';
        leadObjTest.Hand_Raiser_Responses__c ='Hand Raiser Response';// fg

        //update lead with accoount and contact null
        update leadObjTest;

        //create Account record from TestDataBuilder.
        Account dummyaccObj1 = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        dummyaccObj1.BillingCity ='Rio De Janeiro';
        dummyaccObj1.BillingCountryCode = 'IN';
        dummyaccObj1.BillingCountry = 'India';
        dummyaccObj1.BillingStateCode = 'MH';
        dummyaccObj1.BillingState = 'Maharashtra';
        dummyaccObj1.name ='Test12345';
        dummyaccObj1.Account_Sector__c ='Commercial';
        dummyaccObj1.Siebel_Account_Id__c = '40687';
        insert dummyaccObj1;


        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);


        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        //set doNotCreateOpty to true
        controller.doNotCreateOpty=true;

        controller.accountFound=false;

        controller.getLeadRecordToConvert();
        
        //Set selectedValue to 'exactAccount'
        controller.selectedValue='exactAccount';

        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];



        system.assert(controller.accountfound);
        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isConverted);
        Database.LeadConvertResult convertRes=controller.lcr;
        //Check for correct account and contact associated
        system.assertEquals(convertRes.getAccountId(),dummyaccObj1.Id);

        test.stopTest();

    }

   // fg start
   /*
        @ name    convertOptyLeadAddContactRole
        @ date    30.April.2015
        @ author  Faina Gorelik
        @ param   none.
        @ return  Void. 
        @ description Method to Implement test Converting unknown Lead with the existing opportunity where one existing contact already in Opportunity contact role                         
     */
        
static testMethod void convertOptyLeadAddContactRole() { 

        //Insert Account
        
         Account dummyaccObj1 = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        dummyaccObj1.BillingCity ='Natick';
        dummyaccObj1.BillingCountryCode = 'IN';
        dummyaccObj1.BillingCountry = 'India';
        dummyaccObj1.BillingStateCode = 'MH';
        dummyaccObj1.BillingState = 'Maharashtra';
        dummyaccObj1.name ='Television';
        dummyaccObj1.Account_Sector__c ='Commercial';
        dummyaccObj1.Siebel_Account_Id__c = '40681';
        insert dummyaccObj1;
        
        // Insert Contact
        
        Contact ContactObjTest = TestDataBuilder.buildTestContact(index+2,UserInfo.getUserId(),dummyaccObj1.id);
        ContactObjTest.AccountId = dummyaccObj1.id;    
        ContactObjTest.LastName ='Lead';
        ContactObjTest.FirstName = 'FirstName';
        ContactObjTest.MailingStreet = 'test street';
        ContactObjTest.MailingCity= 'test city';
        ContactObjTest.MailingCountryCode = 'US';
        ContactObjTest.MailingCountry = 'United States';
        ContactObjTest.MailingState='New York';
        ContactObjTest.MailingStateCode = 'NY';        
        ContactObjTest.MailingPostalCode = '00001';
        ContactObjTest.Email = 'faina@testbose.come';
        ContactObjTest.Country_Code__c = 'US';
        
        Insert ContactObjTest;

        
        //Insert Opportunity
        
        Opportunity OptyObjTest = TestDataBuilder.buildTestOpportunity(index);
        OptyObjTest.name = 'ExistingOpty';
        OptyObjTest.AccountId = dummyaccObj1.Id;
        insert OptyObjTest;

        // Insert Contact into Opportunity Contact Role
        OpportunityContactRole OptyContactRoleTest = TestDataBuilder.builOpportunityContactRole(ContactObjTest.id,OptyObjTest.id);
        //
        OptyContactRoleTest.contactid=ContactObjTest.id;
        OptyContactRoleTest.OpportunityId=OptyObjTest.id;
        OptyContactRoleTest.role='Other';
        Insert OptyContactRoleTest; 
        //
        //Insert second contact to for known lead
         // Insert Contact
        
        Contact ContactObjTest1 = TestDataBuilder.buildTestContact(index+3,UserInfo.getUserId(),dummyaccObj1.id);
        ContactObjTest1.AccountId = dummyaccObj1.id;    
        ContactObjTest1.LastName ='Lead';
        ContactObjTest1.FirstName = 'FirstName';
        ContactObjTest1.MailingStreet = 'test street';
        ContactObjTest1.MailingCity= 'test city';
        ContactObjTest1.MailingCountryCode = 'US';
        ContactObjTest1.MailingCountry = 'United States';
        ContactObjTest1.MailingState='New York';
        ContactObjTest1.MailingStateCode = 'NY';        
        ContactObjTest1.MailingPostalCode = '00001';
        ContactObjTest1.Email = 'faina888@testbose.come';
        ContactObjTest1.Country_Code__c = 'US';
        
        Insert ContactObjTest1;
        
        //Inserting lead
        Lead leadObjTest = TestDataBuilder.buildTestLead(index,kwncont);
        leadObjTest.Email ='faina88888@testbose.come';
        leadObjtest.firstName = 'abc';
        leadObjTest.Street='testStreet';
        leadObjTest.city='testCity';
        leadObjTest.Country='Afghanistan';
        leadObjTest.PostalCode='10011';
        leadObjTest.Account__c = dummyaccObj1.Id;
        leadObjTest.Contact__c = ContactObjTest1.id;
        leadObjTest.Hand_Raiser_Type__c ='Contact Maintenance';//fg
        leadObjTest.Existing_Opportunity__C = OptyObjTest.Id;
        insert leadObjTest;

        test.startTest();
          //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        controller.getLeadRecordToConvert();
        PageReference testPageRef = controller.convertLeadObj();


        Lead leadObjToTest = [select isConverted
                              from Lead 
                              where id =:leadObjTest.id];
        
            List<OpportunityContactRole> optyContactRole = [select id from OpportunityContactRole where OpportunityId = :OptyObjTest.Id ];
            System.assertEquals(2, optyContactRole.size());
           
     
        test.stopTest();



}

   
   //fg end 
    
    
    
         /*
        @ name    convertLeadWithExsistingOpport
        @ date    30.April.2015
        @ author  Faina Gorelik
        @ param   none.
        @ return  Void. 
        @ description Method to Implement test Converting lead with the existing opportunity and contact and add                           
     */
        
        static testMethod void convertLeadWithExsistingOpport() { 

        //Insert Account
        
         Account dummyaccObj1 = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        dummyaccObj1.BillingCity ='Babson';
        dummyaccObj1.BillingCountryCode = 'IN';
        dummyaccObj1.BillingCountry = 'India';
        dummyaccObj1.BillingStateCode = 'MH';
        dummyaccObj1.BillingState = 'Maharashtra';
        dummyaccObj1.name ='Faina12345';
        dummyaccObj1.Account_Sector__c ='Commercial';
        dummyaccObj1.Siebel_Account_Id__c = '406870';
        insert dummyaccObj1;
        
        // Insert Contact
        
        Contact ContactObjTest = TestDataBuilder.buildTestContact(index+2,UserInfo.getUserId(),dummyaccObj1.id);
        ContactObjTest.AccountId = dummyaccObj1.id;    
        ContactObjTest.LastName ='Lead';
        ContactObjTest.FirstName = 'FirstName';
        ContactObjTest.MailingStreet = 'test street';
        ContactObjTest.MailingCity= 'test city';
        ContactObjTest.MailingCountryCode = 'US';
        ContactObjTest.MailingCountry = 'United States';
        ContactObjTest.MailingState='New York';
        ContactObjTest.MailingStateCode = 'NY';        
        ContactObjTest.MailingPostalCode = '00001';
        ContactObjTest.Email = 'faina@testbose.come';
        ContactObjTest.Country_Code__c = 'US';
        
        Insert ContactObjTest;

        
        //Insert Opportunity
        
        Opportunity OptyObjTest = TestDataBuilder.buildTestOpportunity(index);
        OptyObjTest.name = 'ExistingOpty';
        OptyObjTest.AccountId = dummyaccObj1.Id;
        insert OptyObjTest;

        //Insert lead
        
        Lead leadObjTest = TestDataBuilder.buildTestLead(index,kwncont);
        leadObjTest.Email ='faina@testbose.come';
        leadObjtest.firstName = 'abc';
        leadObjTest.Street='testStreet';
        leadObjTest.city='testCity';
        leadObjTest.Country='Afghanistan';
        leadObjTest.PostalCode='10011';
        leadObjTest.Hand_Raiser_Responses__c = 'Hand Raiser Response';//fg
        leadObjTest.Account__c = dummyaccObj1.Id;
        leadObjTest.Contact__c = ContactObjTest.id;
        leadObjTest.Existing_Opportunity__C = OptyObjTest.Id;
            
        insert leadObjTest;

        test.startTest();
          //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        controller.getLeadRecordToConvert();
        PageReference testPageRef = controller.convertLeadObj();


        Lead leadObjToTest = [select isConverted
                              from Lead 
                              where id =:leadObjTest.id];
        
            List<OpportunityContactRole> optyContactRole = [select id,contactId from OpportunityContactRole where OpportunityId = :OptyObjTest.Id ];
            System.assertEquals(1, optyContactRole.size());
            System.assertEquals(ContactObjTest.id, optyContactRole[0].ContactId);
     
        test.stopTest();



}

  /*
        @ name    convertLeadWithExsistingOpport
        @ date    30.April.2015
        @ author  Faina Gorelik
        @ param   none.
        @ return  Void. 
        @ description Method to Implement test Converting known Lead with the existing opportunity where lead contact already in Opportunity contact role                         
     */
        
static testMethod void convertOptyLeadDoNotAddContactRole() { 

        //Insert Account
        
         Account dummyaccObj1 = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        dummyaccObj1.BillingCity ='San Juan';
        dummyaccObj1.BillingCountryCode = 'IN';
        dummyaccObj1.BillingCountry = 'India';
        dummyaccObj1.BillingStateCode = 'MH';
        dummyaccObj1.BillingState = 'Maharashtra';
        dummyaccObj1.name ='Sheraton';
        dummyaccObj1.Account_Sector__c ='Commercial';
        dummyaccObj1.Siebel_Account_Id__c = '406873';
        insert dummyaccObj1;
        
        // Insert Contact
        
        Contact ContactObjTest = TestDataBuilder.buildTestContact(index+2,UserInfo.getUserId(),dummyaccObj1.id);
        ContactObjTest.AccountId = dummyaccObj1.id;    
        ContactObjTest.LastName ='Lead';
        ContactObjTest.FirstName = 'FirstName';
        ContactObjTest.MailingStreet = 'test street';
        ContactObjTest.MailingCity= 'test city';
        ContactObjTest.MailingCountryCode = 'US';
        ContactObjTest.MailingCountry = 'United States';
        ContactObjTest.MailingState='New York';
        ContactObjTest.MailingStateCode = 'NY';        
        ContactObjTest.MailingPostalCode = '00001';
        ContactObjTest.Email = 'faina@testbose.come';
        ContactObjTest.Country_Code__c = 'US';
        
        Insert ContactObjTest;

        
        //Insert Opportunity
        
        Opportunity OptyObjTest = TestDataBuilder.buildTestOpportunity(index);
        OptyObjTest.name = 'ExistingOpty';
        OptyObjTest.AccountId = dummyaccObj1.Id;
        insert OptyObjTest;

        // Insert Contact into Opportunity Contact Role
        OpportunityContactRole OptyContactRoleTest = TestDataBuilder.builOpportunityContactRole(ContactObjTest.id,OptyObjTest.id);
        //
        OptyContactRoleTest.contactid=ContactObjTest.id;
        OptyContactRoleTest.OpportunityId=OptyObjTest.id;
        OptyContactRoleTest.role='Other';
        Insert OptyContactRoleTest; 
        //
        //Inserting lead
        
        Lead leadObjTest = TestDataBuilder.buildTestLead(index,kwncont);
        leadObjTest.Email ='faina@testbose.come';
        leadObjtest.firstName = 'abc';
        leadObjTest.Street='testStreet';
        leadObjTest.city='testCity';
        leadObjTest.Country='Afghanistan';
        leadObjTest.PostalCode='10011';
        leadObjTest.Account__c = dummyaccObj1.Id;
        leadObjTest.Contact__c = ContactObjTest.id;
        leadObjTest.Existing_Opportunity__C = OptyObjTest.Id;
            
        insert leadObjTest;

        test.startTest();
          //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        controller.getLeadRecordToConvert();
        PageReference testPageRef = controller.convertLeadObj();


        Lead leadObjToTest = [select isConverted
                              from Lead 
                              where id =:leadObjTest.id];
        
            List<OpportunityContactRole> optyContactRole = [select id,contactId from OpportunityContactRole where OpportunityId = :OptyObjTest.Id ];
            System.assertEquals(1, optyContactRole.size());
            System.assertEquals(ContactObjTest.id, optyContactRole[0].ContactId);
     
        test.stopTest();



}

// fg end
    /*
    @ name    convertLeadWithExistingContactByEmailURT  
    @ date    7.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion with opportunity.                           
     */
    //Positive Test
    static testMethod void convertLeadWithExistingContactByEmailURT() { 

        //Inserting lead
        Lead leadObjTest =insertLead();

        leadObjTest.RecordTypeId =UtilityHelper.getLeadRecordTypeId(unkwncont);
        leadObjtest.firstName = 'abc';
        leadObjTest.account__c=null;
        leadObjTest.contact__c=null;

        //update lead with accoount and contact null
        update leadObjTest;

        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        controller.doNotCreateOpty=true;

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);

        //This is for creating opportunity opportunity
        controller.ownerId=usrObj.id;

        controller.getLeadRecordToConvert();

        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];

        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;

        //Check for correct account and contact associated
        system.assertEquals(leadObjToTest.account__c, convertRes.getAccountId());
        system.assertEquals(leadObjToTest.contact__c, convertRes.getContactId());

        test.stopTest();

    }

    /*
    @ name    convertKnownLeadWithoutAccountAndContact  
    @ date    28.July.2014
    @ author  Andre Calimlim
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion with opportunity.                           
     */
    //Negative Test
    static testMethod void convertKnownLeadWithoutAccountAndContact() { 

        //Inserting lead
        Lead leadObjTest = TestDataBuilder.buildTestLead(index,kwncont);
        leadObjTest.Email ='john123Test@xyz'+index+'.coz';
        leadObjtest.firstName = 'abc';
        leadObjTest.Street='testStreet';
        leadObjTest.city='testCity';
        leadObjTest.Account__c = null;
        leadObjTest.Contact__c = null;
        insert leadObjTest;


        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        controller.doNotCreateOpty=true;

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);

        //This is for creating opportunity opportunity
        controller.ownerId=usrObj.id;

        controller.getLeadRecordToConvert();
        controller.leadObj.recordtypeId = UtilityHelper.getLeadRecordTypeId('Known Contact');
        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];
        system.debug('********leadObjToTest  is ' + leadObjToTest );
        //Check for converted Lead
        system.assertEquals(false, leadObjToTest.isconverted);


        test.stopTest();

    }
    /*
    @ name    convertLeadWithOpportunity
    @ date    11.June.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion with opportunity. 
    @Last Modified By : Abhay Verma
    @Last Modified Date : 16-March-2016
    @revision Call the getStatusOption() Method.                          
     */
    //Positive Test
    static testMethod void convertLeadWithOpportunity() { 



        //Inserting lead
        Lead leadObjTest =insertLead();

        test.startTest();


        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);


        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        controller.doNotCreateOpty=false;


        controller.getLeadRecordToConvert();
        controller.getStatusOptions();
        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted
                              from Lead 
                              where id =:leadObjTest.id];
        
        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;
        
        //Check for correct account and contact associated
        system.assertEquals(leadObjTest.account__c, convertRes.getAccountId());
        system.assertEquals(leadObjTest.contact__c, convertRes.getContactId());
        
        test.stopTest();

    }
    /*
    @ name    convertUnknownLeadWithOpportunity
    @ date    28.June.2014
    @ author  Andre Calimlim
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion with opportunity having unknown Lead recordType.                           
     */
    //Positive Test
    static testMethod void convertUnknownLeadWithOppAndActivity() { 

        //Inserting lead
        Lead leadObjTest = insertLead();

        leadObjTest.RecordTypeId =UtilityHelper.getLeadRecordTypeId(unkwncont);

        leadObjTest.account__c=null;
        leadObjTest.contact__c=null;
        leadObjTest.company='Test12345';
        leadObjTest.CountryCode = 'IN';
        leadObjTest.Country = 'India';
        leadObjTest.StateCode = 'MH';
        leadObjTest.State = 'Maharashtra';
        leadObjTest.City ='Rio De Janeiro';
        leadObjTest.Email ='john123Test@xyz.coz';
        leadObjTest.firstName ='testFirstName';
        leadObjTest.Sector__c = 'Commercial';
        
        //DMA 1770924  uknown lead w/0 Handraiser and with Comp
        //set Competitor__c to a valid picklist option
        List<Schema.PicklistEntry> compValues = New List<Schema.PicklistEntry>();
        compValues = Lead.Competitor__c.getDescribe().getPicklistValues();
        String competitorValue = compValues[0].getValue();
		leadObjTest.Competitor__c = competitorValue;
        //update lead with accoount and contact null
        update leadObjTest;

        //create Account record from TestDataBuilder.
        Account dummyaccObj1 = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        dummyaccObj1.BillingCity ='Rio De Janeiro';
        dummyaccObj1.BillingCountryCode = 'IN';
        dummyaccObj1.BillingCountry = 'India';
        dummyaccObj1.BillingStateCode = 'MH';
        dummyaccObj1.BillingState = 'Maharashtra';
        dummyaccObj1.name ='Test12345';
        dummyaccObj1.Account_Sector__c ='Commercial';
        dummyaccObj1.Siebel_Account_Id__c = '40687';
        insert dummyaccObj1;


        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        //set doNotCreateOpty to false
        controller.doNotCreateOpty=false;

        //This is to  create Activity
        controller.doNotCreateActivity=false;

        //set sendNotificationEmail to false
        controller.sendNotificationEmail=false;

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);

        //This is for creating opportunity opportunity
        controller.ownerId=usrObj.id;
        //ontroller.acc = new Account();


        controller.getLeadRecordToConvert();
        
        //Set selectedValue to 'exactAccount'
        controller.selectedValue='exactAccount';
        controller.selectedStatus = 'In Progress';

        
        controller.acc.ownerId = UserInfo.getUserId();// = new Account(ownerid = usrObj.id);
        //controller.selectAccount();
        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];

        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;

        //Check for Activity on opportunity
        List<Task> taskObjtoTest = [select Id,subject, whatId, Priority, Description From Task where whatId = :convertRes.getOpportunityId() ];
        System.assertEquals(taskObjtotest[0].subject, System.Label.Task_subject_on_lead_conversion);

        //Check for correct account  associated
        system.assertEquals(convertRes.getAccountId(),dummyaccObj1.id);
        
        //DMA 1770924
        //check that Competitor__c field value(s) made it to the created Task Description field
        String taskDescription = taskObjtotest[0].Description;
        system.assert(taskDescription.contains(competitorValue));

        test.stopTest();

    }

    /*
    @ name    convertLeadWithActivity
    @ date    23.June.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion with Activity creation                              
     */

    static testMethod void convertLeadWithActivity() {


        //Inserting lead
        Lead leadObjTest =insertLead();

        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        //This is to  create opportunity
        controller.doNotCreateOpty=false;

        //This is to  create Activity
        controller.doNotCreateActivity=false;


        //set sendNotificationEmail to true
        controller.sendNotificationEmail=true;


        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);
        usrObj.Firstname='SFDC';
        usrObj.LastName='TestAdmin';
        insert usrObj;

        //Creating Task while lead conversion
        Task taskObj = TestDataBuilder.buildTestTask(usrObj.id,'In Progress','TO DO', 'call');
        taskObj.Priority='ASAP';
        taskObj.WhoId=leadObjTest.Id;
        insert taskObj;

        //controller.taskId=taskObj;

        controller.getLeadRecordToConvert();

        PageReference testPageRef = controller.convertLeadObj();
        //Account testacct = [select Account_City_Latin__c from Account where Id = : leadObjTest.Account__c];
        //system.assertEquals('latin city', testacct.Account_City_Latin__c);
        //system.assertEquals(false, controller.doNotCreateOpty);
        //system.assertEquals('test error', controller.testError);
        Lead leadObjToTest = [select isConverted
                              from Lead 
                              where id =:leadObjTest.id];
        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;
        //Check for correct account and contact associated
        system.assertEquals(leadObjTest.account__c, convertRes.getAccountId());
        system.assertEquals(leadObjTest.contact__c, convertRes.getContactId());

        //Check for Activity on opportunity
        List<Task> taskObjtoTest = [select Id,subject, whatId, Priority From Task where whatId = :convertRes.getOpportunityId() ];
        //system.assertEquals('test error', controller.testError);
        //system.assertEquals(taskObjtoTest.size(), 1);
        //system.assertEquals(taskObj.size(), 2);

        Boolean taskFound = false;
        for(Task ta : taskObjtoTest){
            if(ta.Id == taskObj.id){
                taskFound = true;
            }
        }
        system.assert(taskFound);
        //system.assertEquals('ASAP', taskObjtoTest[0].Priority);

        test.stopTest();

    }



    /*
    @ name    convertLeadWithoutOpportunity
    @ date    11.June.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test for LeadConversion without creating opportunity.                              
     */

    static testMethod void convertLeadWithoutOpportunity() {



        //Inserting lead
        Lead leadObjTest =insertLead();

        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 
        //This is to not create opportunity
        controller.doNotCreateOpty=true;


        controller.getLeadRecordToConvert();
        PageReference testPageRef = controller.convertLeadObj();


        Lead leadObjToTest = [select isConverted
                              from Lead 
                              where id =:leadObjTest.id];
        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;
        //Check for correct account and contact associated
        system.assertEquals(leadObjTest.account__c, convertRes.getAccountId());
        system.assertEquals(leadObjTest.contact__c, convertRes.getContactId());

        test.stopTest();

    }





    /*
    @ name    insertLead
    @ date    11.June.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Lead record. 
    @ description Method to Insert test lead data with account and contact lookup for LeadConversion.                              
     */

    private static Lead insertLead() {

        //re-create general Custom Setting
        //csb.buildGenSetting();

        //re-create Bypass Trigger Custom Setting
        //csb.buildBypassTriggerSettings();

        //create Account record from TestDataBuilder.
        Account accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.BillingPostalCode = '1111';
        accObj.BillingStreet = 'aa street';
        //accObj.Account_City_Latin__c = 'test123';
        //accObj.Account_Street_Latin__c = 'testStreet';
        //accObj.Account_Name_Latin__c = 'testlatin';


        insert accObj;

        //create Contact record from TestDataBuilder.
        Contact conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Bombay';
        conObj.MailingCountry = 'India';
        conObj.MailingCountryCode='IN';
        conObj.MailingPostalCode ='400011';
        conObj.MailingState ='Maharashtra';
        conObj.MailingStateCode = 'MH';
        conObj.MailingStreet = 'MG Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'johnTest@zasdf.fes';

        insert conObj;

        //create Lead record from TestDataBuilder.

        Lead led = TestDataBuilder.buildTestLead(index,kwncont);
        led.Email ='johnTest@zasdf.fes';
        led.FirstName = 'abc';
        led.account__c=accObj.id;
        led.contact__c=conObj.id;
        led.Street='testStreet';
        led.city='testCity';

        insert led;

        return led;


    }
  
    /*
    @ name    insertLead
    @ date    4 Feb 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Lead record. 
    @ description Method to Insert test lead data with unknown recordType for setting the Primary_Contact__c as primary contact on Opportunity.

     */
    static testMethod void convertLeadwithOpportunityPrimaryContactUpdate(){
        //Inserting lead
        Lead leadObjTest = insertLead();

        leadObjTest.RecordTypeId =UtilityHelper.getLeadRecordTypeId(unkwncont);

        leadObjTest.account__c=null;
        leadObjTest.contact__c=null;
        leadObjTest.company='Test12345';
        leadObjTest.Country='United States';
        leadObjTest.CountryCode = 'US';
        leadObjTest.StateCode = 'NY';
        leadObjTest.State = 'New York';
        leadObjTest.Email ='john123Test@xyz.coz';
        leadObjTest.firstName ='testFirstName';


        //update lead with accoount and contact null
        update leadObjTest;

        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        //set doNotCreateOpty to false
        controller.doNotCreateOpty=false;
      

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);

        //This is for creating opportunity opportunity
        controller.ownerId=usrObj.id;

        controller.getLeadRecordToConvert();
        
        //set selectedvalue to 'newAccCon'
        controller.selectedvalue='newAccCon';

        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];

        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;

        Opportunity opptyOBj=[Select id,Primary_Contact__c  from opportunity where id =: convertRes.getOpportunityId()];
        Contact conOBj=[Select id from contact where id =: convertRes.getContactId()];
        system.assertEquals(opptyOBj.Primary_Contact__c,convertRes.getContactId()); 
        test.stopTest();

    }
    
    
    //DMA Added method to extend code coverage in these cases unknown with handraiser and comp :
	//		1. Account already associated with lead, Account has Territory_Name__c populated
	//		2. Lead has handraiser type and also Competitor populated
    //Positive Test
    static testMethod void convertLeadWithHandraiserWithAccount() { 
        
        String handRaiserType = 'Contact Maintenance';
        
        //create Account record from TestDataBuilder.
        //Account dummyaccObj1 = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        Account dummyaccObj1 = New Account();
        dummyaccObj1.ownerId = UserInfo.getUserId();
        dummyaccObj1.BillingStreet = '1234 Main St';
        dummyaccObj1.BillingCity ='Boston';
        dummyaccObj1.BillingCountryCode = 'US';
        dummyaccObj1.BillingCountry = 'United States';
        dummyaccObj1.BillingStateCode = 'MA';
        dummyaccObj1.BillingState = 'Massachusetts';
        dummyaccObj1.BillingPostalCode = '02215';
        dummyaccObj1.name ='MyAcc 123456';
        dummyaccObj1.Account_Sector__c ='Commercial';
        dummyaccObj1.Siebel_Account_Id__c = '40999';
        dummyaccObj1.Territory_Name__c = 'some text';
        insert dummyaccObj1;
        
        //Inserting lead
        Lead leadObjTest = insertLead();

        leadObjTest.RecordTypeId =UtilityHelper.getLeadRecordTypeId(unkwncont);

        leadObjTest.account__c=dummyaccObj1.Id;
        leadObjTest.contact__c=null;
        leadObjTest.company='Testing123456';
        leadObjTest.CountryCode = 'US';
        leadObjTest.Country = 'United States';
        leadObjTest.StateCode = 'MA';
        leadObjTest.State = 'Massachusetts';
        leadObjTest.City ='Boston';
        leadObjTest.Email ='testingdummyacct@xyz.coz';
        leadObjTest.firstName ='testingFirstN';
        leadObjTest.Sector__c = 'Commercial';
        leadObjTest.Hand_Raiser_Type__c = handRaiserType;
        
        //DMA 1770924
        //set Competitor__c to a valid picklist option
        List<Schema.PicklistEntry> compValues = New List<Schema.PicklistEntry>();
        compValues = Lead.Competitor__c.getDescribe().getPicklistValues();
        String competitorValue = compValues[0].getValue();
		leadObjTest.Competitor__c = competitorValue;
        //update lead with accoount and contact null
        update leadObjTest;

        test.startTest();

        //Creating testPage
        PageReference pageRef= new PageReference('/');
        Test.setCurrentPageReference(pageRef);

        //Putting id into URL
        pageRef.getParameters().put('id', leadObjTest.Id);

        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(leadObjTest); 
        LeadConversionController controller = new LeadConversionController(stdcontroller); 

        //following 2 lines added for coverage
        boolean selec = controller.selected;
        controller.selectAccount();
        
        //set doNotCreateOpty to false
        controller.doNotCreateOpty=false;

        //This is to  create Activity
        controller.doNotCreateActivity=false;

        //set sendNotificationEmail to false
        controller.sendNotificationEmail=false;

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(index);

        //This is for creating opportunity opportunity
        controller.ownerId=usrObj.id;
        //ontroller.acc = new Account();


        controller.getLeadRecordToConvert();
        
        //Set selectedValue to 'exactAccount'
        //controller.selectedValue='exactAccount';
        controller.selectedValue='exsAcc';
        controller.selectedStatus = 'In Progress';

        
        controller.acc.ownerId = UserInfo.getUserId();// = new Account(ownerid = usrObj.id);
        //controller.selectAccount();
        PageReference testPageRef = controller.convertLeadObj();

        Lead leadObjToTest = [select isConverted,account__c,contact__c
                              from Lead 
                              where id =:leadObjTest.id];

        //Check for converted Lead
        system.assertEquals(true, leadObjToTest.isconverted);

        Database.LeadConvertResult convertRes=controller.lcr;

        //Check for Activity on opportunity
        List<Task> taskObjtoTest = [select Id,subject, whatId, Priority, Description From Task where whatId = :convertRes.getOpportunityId() ];
        System.assertEquals(taskObjtotest[0].subject, System.Label.Task_subject_on_lead_conversion);

        //Check for correct account  associated
        system.assertEquals(convertRes.getAccountId(),dummyaccObj1.id);
        
        //DMA 1770924
        //check that Competitor__c field value(s) made it to the created Task Description field
        String taskDescription = taskObjtotest[0].Description;
        system.assert(taskDescription.contains(competitorValue));
        system.assert(taskDescription.contains(handRaiserType));

        test.stopTest();

    }

}