/**
 *@author Original: Andre Calimlim
 *@date Original: 6 Aug 2014
 *@description This is Test class for AUIConnectController
 *             
 */
@isTest
private class AUIConnectControllerTest {
	//Create new instance of CustomSettingsBuilder
	static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
	//Mock user for the tests
	static User usr;
	
	/**
	 * author Original: Andre Calimlim
	 * date Original: 5 Aug 2014
	 * @param: conSiebelId | the Contact Siebel Id for the Contact
	 * @param: accSiebelId | the Account Siebel Id for the Account
	 * @param: isIndiv | this will flag if Account is Individual
	 * @return: returns the contact record that will be calling the AUIConnect page
	 * description: This method will be used by testMethods to create Test Data
	 */
	static Contact createTestData(String accSiebelId, String conSiebelId, Boolean isIndiv){
		//Add TestData
		usr = TestDataBuilder.buildTestUser(1);
		insert usr;
		
		custsettbuild.buildBypassTriggerSettings();
		custsettbuild.buildGenSetting();
        custsettbuild.buildTrialsIntegrationSetting();
		
		Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
		//acc.Siebel_Account_Id__c = accSiebelId;
		acc.CDS_Account_Id__c = accSiebelId;
		acc.Is_Individual_Account__c = isIndiv;
        insert acc;
        
        Contact contL = TestDataBuilder.buildTestContact(1,UserInfo.getUserId(),acc.Id);
         //contL.Siebel_Contact_Id__c = conSiebelId;
        contL.CDS_Contact_Id__c = conSiebelId;
		insert contL;
		
		return contL;
	}
	
	//Positive Test to verify that it will redirect to AUI Url with the Siebel Contact id
    static testMethod void testAUIUrlReached() {
    	Contact con = createTestData('1111', '22222', false);
        System.runAs(usr){
        	
        	
        	PageReference AUIConn = Page.AUIConnect;
        	Test.setCurrentPage(AUIConn);
        	
        	AUIConn.getParameters().put('id', con.Id);
        	
        	AUIConnectController ctrl = new AUIConnectController(new ApexPages.StandardController(con));
        	PageReference redirectPage;
        	
        	Test.startTest();
        		redirectPage = ctrl.redirectToAUI();
        	Test.stopTest();
        	
            TrialsIntegrationSetting__c settings = TrialsIntegrationSetting__c.getInstance();
        	System.assertEquals(0, ApexPages.getMessages().size());
        	System.assertEquals(settings.AUIUrl__c + '22222', redirectPage.getUrl());
        }
    }
    //Negative Test to verify that ApexPage will have an error for Individual Account
    static testMethod void testIsIndividualAccount() {
        Contact con = createTestData('1111', '22222', true);
        System.runAs(usr){
        	
        	
        	PageReference AUIConn = Page.AUIConnect;
        	Test.setCurrentPage(AUIConn);
        	
        	AUIConn.getParameters().put('id', con.Id);
        	
        	AUIConnectController ctrl = new AUIConnectController(new ApexPages.StandardController(con));
        	
        	Test.startTest();
        		ctrl.redirectToAUI();
        	Test.stopTest();
        	
        	if(ApexPages.getMessages().size() > 0){ 
        		List<ApexPages.Message> allMessages = ApexPages.getMessages();
        		String msg;
        		for(ApexPages.Message am : allMessages){
        			msg = am.getSummary();
        		}
				
				System.assertEquals(true, msg.contains('individual account'));

				
        	}
        }
    }
    
    //Negative Test to verify that ApexPage will have 3 error occurrences
    static testMethod void testMultipleRequiredFieldMissing() {
        Contact con = createTestData('', '', true);
        System.runAs(usr){
        	
        	
        	PageReference AUIConn = Page.AUIConnect;
        	Test.setCurrentPage(AUIConn);
        	
        	AUIConn.getParameters().put('id', con.Id);
        	
        	AUIConnectController ctrl = new AUIConnectController(new ApexPages.StandardController(con));
        	
        	Test.startTest();
        		ctrl.redirectToAUI();
        	Test.stopTest();
        	if(ApexPages.getMessages().size() > 0){ 
        		List<ApexPages.Message> allMessages = ApexPages.getMessages();
        		String msg;
        		for(ApexPages.Message am : allMessages){
        			msg = am.getSummary();
        		}
        		
				String searchStr = '<br/>';
				Integer counter = 0;
				Integer index = msg.indexOf(searchStr);
				while (index >= 0) {
				    counter++;
				    msg = msg.substring(index+searchStr.length());
				    index = msg.indexOf(searchStr);
				}
				
				System.assertEquals(3, counter);
        	}
        	
        }
    }
    /*End of Test class*/
}