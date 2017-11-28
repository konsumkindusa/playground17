/**
*author Original: Sagar Talele - Cloud Sherpas/Mathworks, Modified by : Faina Gorelik
*date Original: 1 April 2015, Last Modified:25 January 2016, 03 March 2017
*description : This  is test class for 'OpportunityProjectTrigger'  , AtTask 1950895   - fix value on created opportunities due to the validation rules
*revision:
*/
@isTest
public class OpportunityProjectDmlTest {
 /**
    *author Original: Sagar Talele - Cloud Sherpas/Mathworks
    *date Original: 1 April 2015, Last Modified:
    *description : This  is test Method  to ensure the first opportunity is assigned to Project
    *revision:
    */
     //Create new instance of CustomSettingsBuilder
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    public static Account accObj;
    public static Contact conObj;
    
    static testMethod void testupdateOpportunityOnProject(){
         custsettbuild.buildBypassTriggerSettings();
         custsettbuild.buildGenSetting();
         custsettbuild.buildAddressLatinTranslation();
         List<Account> accNLLst =new List<Account>();
         List<Contact> contNLLst =new List<Contact>();
         List<Opportunity> oppLst=new List<Opportunity>();
         List<Opportunity_Projects__c> oppProjectLst=new List<Opportunity_Projects__c>();
        for(Integer i=0;i<=50;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;
        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<=50;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
            
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;
        List<MW_Project__c> recList = new List<MW_Project__c>();

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;

        for(Integer i = 0; i <=50; i++){

            //MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);//AtTask 1950895
            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), contNLLst[i].Id);
           // rec.account__C = accNLLst[i].id; fg
            rec.Purpose__c='Opportunity Support';//Territory Support'; fg
            rec.outcome__c = 'Workshop';//Internal';fg
            rec.requester__C=usrObj.id;
            recList.add(rec);

        }
         //create Opportunity record from TestDataBuilder.
         for(integer i=0;i<50;i++){
             Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i);
             oppObj.amount=20;
             oppObj.AccountId = accNLLst[i].id;
             oppObj.CurrencyIsoCode='INR';
             oppLst.add(oppObj);
         }
       
         Test.startTest();

        insert recList;
       
        insert oppLst;
        system.assert(recList.size()!=0);
        // create Opportunity Project record
         for(integer i=0;i<50;i++){
             Opportunity_Projects__c  oppProjectObj=TestDataBuilder.buildOpportunityProject(recList[i].Id,oppLst[i].id);
             oppProjectLst.add(oppProjectObj);
         }
        insert oppProjectLst;
        
        MW_Project__c projectObj = [Select Id,Opportunity__c From MW_Project__c where id =: recList[0].Id];
        System.assertEquals(projectObj.Opportunity__c,oppLst[0].Id);
        Test.stopTest();
       
    }
    // fg
     static testMethod void testdeleteOpportunityOnProject(){
         
          custsettbuild.buildBypassTriggerSettings();
         custsettbuild.buildGenSetting();
         custsettbuild.buildAddressLatinTranslation();
         List<Account> accNLLst =new List<Account>();
         List<Contact> contNLLst =new List<Contact>();
         List<Opportunity> oppLst=new List<Opportunity>();
         List<Opportunity_Projects__c> oppProjectLst=new List<Opportunity_Projects__c>();
        for(Integer i=0;i<=50;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;
        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<=50;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
            
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;
        List<MW_Project__c> recList = new List<MW_Project__c>();

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;

        for(Integer i = 0; i <=50; i++){

           // MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);//AtTask 1950895
           MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), contNLLst[i].Id);
         //   rec.account__C = accNLLst[i].id; //
            //rec.Purpose__c='Territory Support';
            rec.Purpose__c ='Opportunity Support';
           // rec.outcome__c = 'Internal';
           	rec.Outcome__c = 'Workshop';
            rec.requester__C=usrObj.id;
            recList.add(rec);

        }
         //create Opportunity record from TestDataBuilder.
         for(integer i=0;i<50;i++){
             Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i);
             oppObj.AccountId = accNLLst[i].id;
             oppObj.amount=20;
             oppObj.CurrencyIsoCode='INR';
             oppObj.Primary_Contact__c = contNLLst[i].Id;
             oppLst.add(oppObj);
         }
        insert recList;//Project List
        insert oppLst;// Opportunity List
         
       // create junction record to test the scenario where project associated with one opportunity or multiple opportunities

      List<Opportunity_Projects__c> OptyProj = new List<Opportunity_Projects__c>();
        Opportunity_Projects__c OptProj1 = new Opportunity_Projects__c(
        Project__c = recList[0].Id,
        Opportunity__c = oppLst[0].Id);
        OptyProj.add(OptProj1);
         
        Opportunity_Projects__c OptProj2 = new Opportunity_Projects__c(
        Project__c = recList[1].Id,
        Opportunity__c = oppLst[1].Id);
        OptyProj.add(OptProj2);
         
        Opportunity_Projects__c OptProj3 = new Opportunity_Projects__c(
        Project__c = recList[1].Id,
        Opportunity__c = oppLst[2].Id);
        OptyProj.add(OptProj3);
         
        Opportunity_Projects__c OptProj4 = new Opportunity_Projects__c(
        Project__c = recList[1].Id,
        Opportunity__c = oppLst[3].Id);
        OptyProj.add(OptProj4);
         
        insert OptyProj;
       
         
        Test.startTest();
        List<Opportunity_Projects__c> oppProjList = new List<Opportunity_Projects__c>();
        List<Opportunity_Projects__c> oppProjLst = new List<Opportunity_Projects__c>();
        oppProjList = [select id from Opportunity_Projects__c where Project__c = : recList[0].Id and Opportunity__c =: oppLst[0].Id];
        delete oppProjList;
        MW_Project__c mwProj = [select Opportunity__c from MW_Project__c where id = :recList[0].Id];
        //System.assertEquals(null, [select Opportunity__c from MW_Project__c where id = :recList[0].Id].Opportunity__c);
        System.assertEquals(null,mwProj.Opportunity__c);
        oppProjLst = [select id from Opportunity_Projects__c where Project__c = : recList[1].Id and Opportunity__c =: oppLst[1].Id];
        delete oppProjLst;
        MW_Project__c proj = [select Opportunity__c from MW_Project__c where id = :recList[1].Id];
        //System.assertEquals(oppLst[2].Id, [select Opportunity__c from MW_Project__c where id = :recList[1].Id].Opportunity__c);
        System.assertEquals(oppLst[2].Id,proj.Opportunity__c);
        Test.stopTest();
         
     }
   // fg end 
}