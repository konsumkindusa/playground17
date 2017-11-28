/*
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, @Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
 *@date Original:30 Oct 2014, Last Modified: 25 Nov 2014
 *@description This  is Test class for 'OpportunityNewTrialController' class . 
 */
 
@isTest
private class OpportunityNewTrialControllerTest{

    public static Account accObj {get; set;}
    public static Contact conObj {get; set;}
    public static TrialsIntegrationSetting__c settings ;
 


    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /*
    @ name    TestIfValidationPass
    @ date    30.Oct.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Void. 
    @ description :That will test if contact found associated with opportunity
     */
    static testMethod void TestIfValidationPass()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){

            Opportunity opty=insertOpportunityCompleteData();           

            //set current page 
            PageReference trialPage = Page.OpportunityNewTrial;
            Test.setCurrentPage(trialPage);

            //Putting id into URL
            trialPage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OpportunityNewTrialController controller = new OpportunityNewTrialController(sc);

            Test.startTest();

           // List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.Siebel_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];
            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];
            System.currentPagereference().getParameters().put('contactId',relatedContactsList[0].Contact.id);
            controller.selectContact();
            controller.selContactid=relatedContactsList[0].Contact.id; 
            
            //search contact 
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkTrialPage=controller.validateFields();
            

            //assert that the page reference is redirected to Contact Detail Page
            System.assertEquals(settings.AUIUrl__c+relatedContactsList[0].contact.CDS_Contact_Id__c+'&opptyId='+opty.Id, MathworkTrialPage.getUrl());
            //System.assertEquals(settings.AUIUrl__c+relatedContactsList[0].contact.Siebel_Contact_Id__c+'&opptyId='+opty.Id, MathworkTrialPage.getUrl());

            Test.stopTest();
        }
    }


    /*
    @ name    TestIfValidationFail
    @ date    30.Oct.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Void. 
    @ description :That will test if contact found associated with opportunity
     */
    static testMethod void TestIfValidationFail()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){

            Opportunity opty=insertOpportunityInCompleteData();

            //set current page 
            PageReference trialPage= Page.OpportunityNewTrial;
            Test.setCurrentPage(trialPage);

            //Putting id into URL
            trialPage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OpportunityNewTrialController controller = new OpportunityNewTrialController(sc);
            
            Test.startTest();

            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];
            // List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.Siebel_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];

            controller.selContactid=relatedContactsList[0].Contact.id; 

            //search opportunity
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkTrialPage=controller.validateFields();

            //assert that the page reference is redirected to Trial Page
            System.assertEquals(null, MathworkTrialPage);

            Test.stopTest();
        }
    }
    /*
    @ name    TestValidationWithOpportunityProduct
    @ date    30.Oct.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Void. 
    @ description :That will test if contact found associated with opportunity
     */
    static testMethod void TestValidationWithOpportunityProduct()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){

            Opportunity opty=insertOpportunityCompleteData();


            // Create a new product
            Product2 productObj = new Product2();
            productObj.Name='Additional Client Licenses';
            productObj.IsActive=true;
            productObj.ProductCode='AS';
            productObj.Trialable__c = true;    
            productObj.Product_Unique_Identifier__c='Unclassified_Consulting1';
            insert productObj ;


            /*//Create a custom pricebook
            Pricebook2 pb=[select id from Pricebook2 where IsStandard = true limit 1];
            pb.isActive=true;       
            update pb;*/

            // Create a pricebook entry for custom pricebook
            PricebookEntry pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id=Test.getStandardPricebookId();
            pbe.Product2Id=productObj.id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            insert pbe;

            OpportunityLineItem NewRec = new OpportunityLineItem();
            NewRec.UnitPrice=200;
            NewRec.Quantity=3;
            NewRec.OpportunityId=opty.Id;
            NewRec.PricebookEntryId=pbe.id;
            //NewRec.Product2id =product.id;
            insert NewRec;

            //set current page 
            PageReference trialPage= Page.OpportunityNewTrial;
            Test.setCurrentPage(trialPage);

            //Putting id into URL
            trialPage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OpportunityNewTrialController controller = new OpportunityNewTrialController(sc);
            
            Test.startTest();

            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];
		// List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.Siebel_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];
            controller.selContactid=relatedContactsList[0].Contact.id; 

            //search contact 
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkTrialPage=controller.validateFields();


            //assert that the page reference is redirected to Contact Detail Page
            System.assertEquals(settings.AUIUrl__c+relatedContactsList[0].contact.CDS_Contact_Id__c+'&opptyId='+opty.Id+'&products=AS', MathworkTrialPage.getUrl());
           //  System.assertEquals(settings.AUIUrl__c+relatedContactsList[0].contact.Siebel_Contact_Id__c+'&opptyId='+opty.Id+'&products=AS', MathworkTrialPage.getUrl());

             Test.stopTest();
        }
    }
    
    /*
    @ name    TestValidationWithMultipleOpportunityProduct
    @ date    16.July.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Void. 
    @ description :That will test if contact found associated with opportunity
     */
    static testMethod void TestValidationWithMultipleOpportunityProduct()  {

        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){

            Opportunity opty=insertOpportunityCompleteData();


            // Create a new product
            Product2 productObj = new Product2();
            productObj.Name='Additional Client Licenses';
            productObj.IsActive=true;
            productObj.ProductCode='AS';
            productObj.Trialable__c = true;
            productObj.Product_Unique_Identifier__c='Unclassified_Consulting1';
            insert productObj ;

            // Create a pricebook entry for custom pricebook
            PricebookEntry pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id=Test.getStandardPricebookId();
            pbe.Product2Id=productObj.id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            //pbe.UseStandardPrice =true;
            insert pbe;

            List<OpportunityLineItem> opptylineitems = new List<OpportunityLineItem>();
            for(Integer i=0;i<5;i++)
            {
                OpportunityLineItem NewRec = new OpportunityLineItem();
                NewRec.UnitPrice=200;
                NewRec.Quantity=3;
                NewRec.OpportunityId=opty.Id;
                NewRec.PricebookEntryId=pbe.id;
                //NewRec.Product2id =product.id;
                opptylineitems.add(newRec);
            }
            
            insert opptylineitems;
            
            //set current page 
            PageReference trialPage = Page.OpportunityNewTrial;
            Test.setCurrentPage(trialPage);

            //Putting id into URL
            trialPage.getParameters().put('id', opty.Id);

            ApexPages.StandardController sc = new ApexPages.StandardController(opty);
            OpportunityNewTrialController controller = new OpportunityNewTrialController(sc);
            
            Test.startTest();

            List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.CDS_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];
			// List<OpportunityContactRole> relatedContactsList = [SELECT Id,contact.name,contact.id,contact.Siebel_Contact_Id__c,isPrimary FROM OpportunityContactRole where  opportunity.id=:opty.id limit 1];

            controller.selContactid=relatedContactsList[0].Contact.id; 

            //search contact 
            controller.getContactsOfOpportunityRecord();
            PageReference MathworkTrialPage=controller.validateFields();


            //assert that the page reference is redirected to Contact Detail Page
            System.assertEquals(settings.AUIUrl__c+relatedContactsList[0].contact.CDS_Contact_Id__c+'&opptyId='+opty.Id+'&products=AS%2CAS%2CAS%2CAS%2CAS', MathworkTrialPage.getUrl());
             //System.assertEquals(settings.AUIUrl__c+relatedContactsList[0].contact.Siebel_Contact_Id__c+'&opptyId='+opty.Id+'&products=AS%2CAS%2CAS%2CAS%2CAS', MathworkTrialPage.getUrl());

             Test.stopTest();
        }
    }
    
    /*
    @ name    insertOpportunityCompleteData
    @ date    30.Oct.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Lead record. 
    @ description Method to Insert test lead data with account and contact lookup for LeadConversion.                              
     */

    private static Opportunity insertOpportunityCompleteData() {

        Integer index=0;

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //re-create trial Custom Setting
        csb.buildTrialsIntegrationSetting();
        
        //re-create trial Custom Setting
        csb.buildGenSetting();
        
        //Fetching date from General custom setting
         settings = TrialsIntegrationSetting__c.getInstance();   

        //create Account record from TestDataBuilder.
        accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
      //  accObj.Siebel_Account_Id__c='C12345';
      	accObj.CDS_Account_Id__c='C12345';


        insert accObj;

        //create Contact record from TestDataBuilder.
        conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Bombay';
        conObj.MailingCountry = 'India';
        conObj.MailingState ='Maharashtra';
        conObj.MailingCountryCode = 'IN';
        conObj.MailingStateCode ='MH';
        conObj.MailingPostalCode ='400011';
       
        conObj.MailingStreet = 'MG Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'john@gmail.com';
        conObj.CDS_Contact_Id__c='C3456';
        //conObj.Siebel_Contact_Id__c='C3456';
        conObj.First_Name_Latin__c='qwerty';
        conObj.Last_Name_Latin__c='qsdfg';

        insert conObj;

        //create Lead record from TestDataBuilder.

        Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
        opty.AccountId = accObj.Id;

        insert opty;

        OpportunityContactRole roles=new OpportunityContactRole();
        roles.OpportunityId = opty.id;
        roles.ContactId =conObj.id;
        roles.isPrimary=true;
        insert roles;

        return opty;


    } 

    /*
    @ name    insertOpportunityInCompleteData
    @ date    30.Oct.2014
    @ author  Divya Gawade
    @ param   none.
    @ return  Lead record. 
    @ description Method to Insert test lead data with account and contact lookup for LeadConversion.                              
     */

    private static Opportunity insertOpportunityInCompleteData() {

        Integer index=0;

        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //re-create trial Custom Setting
        csb.buildTrialsIntegrationSetting();
        
        //re-create trial Custom Setting
        csb.buildGenSetting();
                
        //Fetching date from General custom setting
         settings = TrialsIntegrationSetting__c.getInstance();   

        //create Account record from TestDataBuilder.
        accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.name = 'Test123';
        accObj.Account_Name_Latin__c = 'TestName';
        accObj.BillingCity = 'Test';
        accObj.Account_Street_Latin__c = 'TestStreet';
        accObj.Account_City_Latin__c='TestCity';
        //accObj.Is_Individual_Account__c=true;
        
        insert accObj;

        //create Contact record from TestDataBuilder.
        conObj = TestDataBuilder.buildTestContact(index,UserInfo.getUserId(),accObj.id);
        conObj.MailingCity = 'Bombay';
        conObj.MailingCountry = 'India';
        conObj.MailingState ='Maharashtra';
        conObj.MailingCountryCode = 'IN';
        conObj.MailingStateCode ='MH';
        conObj.MailingPostalCode ='400011';
      
        conObj.MailingStreet = 'MG Street';
        conObj.County_Local__c = 'abc'; 
        conObj.email = 'john@gmail.com';
        //conObj.Siebel_Contact_Id__c='C3456';
        conObj.FirstName='Test';
        conObj.LastName='Test';


        insert conObj;

        //create Lead record from TestDataBuilder.

        Opportunity opty = TestDataBuilder.buildTestOpportunity(index);
        opty.AccountId = accObj.Id;

        insert opty;

        OpportunityContactRole roles=new OpportunityContactRole();
        roles.OpportunityId = opty.id;
        roles.ContactId =conObj.id;
        roles.isPrimary=true;
        insert roles;

        return opty;


    } 
}