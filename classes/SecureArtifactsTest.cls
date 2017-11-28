/**
* @author Original: Krishna Bhaskarla
* @date Original: 26 March 2014
* @description test class for SecureArtifacts Webservice
*/ 
@isTest
public with sharing class SecureArtifactsTest {
	static CustomSettingsBuilder csb = new CustomSettingsBuilder();
	
	private static void createTestData(){
		 //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings(); 		
		
		//Instantiate CaseTriggerHandler class
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        //Stops the trigger for functioning (needed on every Case update because of CheckOnSupport)
        cseTrigHandler.stopTrigger();
          
		//create test account
            Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
            //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
            acc.Siebel_Account_Id__c = '1-1G82J';
            insert acc;
        Account InsAcc = new Account();
        InsAcc = [Select Id From Account Where Id = : acc.Id];
        
        // create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@test.com';
        con.Country_Code__c = 'ph';
        insert con;
        Contact InsCon = new Contact();
        InsCon = [Select Id From Contact Where Id = : con.Id];
        
        // create test case 
        Case InsCse = new Case();  
        Case cse = new Case();
        cse.status = 'Open';
        cse.Area__c = 'Natick - Technical Support';
        cse.Sub_Area__c = 'MATLAB';
        cse.Product_Base_Code__c = 'ML';
        cse.License__c = '491381';
        cse.AccountId = InsAcc.Id;
        cse.ContactId=InsCon.Id;
        insert cse;
        
        InsCse = [Select Id From Case Where Id = : cse.Id];
            // Insert attachment
            Attachment att = new Attachment();
            att.Name = 'inlineimage.txt';
            att.Body = Blob.valueof('inlinetext');
            att.ParentId = InsCse.Id;
        
            insert att;
        
        
	}
	
	private static void createTestData1(){
		 //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings(); 		
		
		//Instantiate CaseTriggerHandler class
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        //Stops the trigger for functioning (needed on every Case update because of CheckOnSupport)
        cseTrigHandler.stopTrigger();
          
		//create test account
            Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
            //set a Siebel Account Id equal to the value on MW_OnSupportTestMock accountID value 
            acc.Siebel_Account_Id__c = '1-1G82J';
            insert acc;
        Account InsAcc = new Account();
        InsAcc = [Select Id From Account Where Id = : acc.Id];
        
        // create test contact
        Contact con = TestDataBuilder.buildTestContact(1, UserInfo.getUserId(), acc.Id);
        con.Email = 'test@test.com';
        con.Country_Code__c = 'ph';
        insert con;
        Contact InsCon = new Contact();
        InsCon = [Select Id From Contact Where Id = : con.Id];
        
        // create test case 
        Case InsCse = new Case();  
        Case cse = new Case();
        cse.Area__c = 'Natick - Technical Support';
        cse.Sub_Area__c = 'MATLAB';
        cse.Product_Base_Code__c = 'ML';
        cse.License__c = '491381';
        cse.AccountId = InsAcc.Id;
        cse.ContactId=InsCon.Id;
        cse.ClosedDate=Date.today().addDays(-100);
        cse.isSecured__c=true;
        insert cse;
        Test.setCreatedDate(cse.Id, DateTime.newInstance(2012,12,12));
        cse.status = 'Closed';
        update cse;

        InsCse = [Select Id,CreatedDate,ClosedDate From Case Where Id = : cse.Id];
            // Insert attachment
            Attachment att = new Attachment();
            att.Name = 'inlineimage.txt';
            att.Body = Blob.valueof('inlinetext');
            att.ParentId = InsCse.Id;
        
            insert att;
	}
	
	static testMethod void testSecureArtifactsByHours(){
		
       createTestData();
		       
        Test.startTest();	
		    //Call webservice
		 	List<SecureArtifactsWS.Artifacts> artList = SecureArtifactsWS.getSecureArtifacts(1,0);
		 Test.stopTest();	
		
	}
	static testMethod void testSecureArtifactsByDays(){
		
		createTestData();
		//Call webservice
		 Test.startTest();		
		 	List<SecureArtifactsWS.Artifacts> artList = SecureArtifactsWS.getSecureArtifacts(0,1);
		 Test.stopTest();	
	}
	static testMethod void testdeleteArtifacts1(){
		
		//Call webservice
		createTestData1();
		 Test.startTest();		
		 	List<SecureArtifactsWS.DeleteArtifactsResponse> artList = SecureArtifactsWS.deleteArtifacts(1);
		 Test.stopTest();	
	}
	static testMethod void testdeleteArtifacts2(){
		
		//Call webservice
		 Test.startTest();		
		 	List<SecureArtifactsWS.DeleteArtifactsResponse> artList = SecureArtifactsWS.deleteArtifacts(1);
		 Test.stopTest();	
	}
}