/*
 *    @description:    tests the TrialPeopleBean
 */ 
@isTest

public with sharing class TrialPeopleBeanTest {

	private static testMethod void testGetParsedPeopleJson(){
		
		//setting value using getParsedContactJson() method
		String jsonToParse='{"summaryCount":1,"people":{"entitlementPersonBean":[{"role":"LEU","webProfileId":"498836","webProfileUserId":null,"firstName":"Jodi","lastName":"Cade","latinFirstName":"","latinLastName":"","emailAddress":"jodi_cade@bose.com","accountName":"Bose Corp","latinAccountName":"","department":"SW Eng Systems","countryCode":"US","latinDepartment":"","roleId":"364","accessToActivationKeyOverride":"true","accessToDownloadOverride":"true","accessToLoginNamedUserOverride":"false","accessToMatlabOnTheWebOverride":"false","permissionList":["ActivationKeyAvailable","DownloadAvailable","Activatable"],"entitlementId":958588,"accessToOnDemandOverride":"false","createdDateTime":"2008-02-06 13:55:00"}]}}';

		Test.startTest();

		TrialPeopleBean peopleObj = TrialPeopleBean.parse(jsonToParse);
		
		System.assertEquals (1,peopleObj.summaryCount);
		System.assertEquals ('LEU',peopleObj.people.entitlementPersonBean[0].role);
		System.assertEquals ('498836',peopleObj.people.entitlementPersonBean[0].webProfileId);
	    System.assertEquals ('SW Eng Systems',peopleObj.people.entitlementPersonBean[0].department);
		System.assertEquals ('Jodi',peopleObj.people.entitlementPersonBean[0].firstName);
		System.assertEquals ('Cade',peopleObj.people.entitlementPersonBean[0].lastName);
		System.assertEquals ('',peopleObj.people.entitlementPersonBean[0].latinFirstName);
		System.assertEquals ('',peopleObj.people.entitlementPersonBean[0].latinLastName);
		
		System.assertEquals ('jodi_cade@bose.com',peopleObj.people.entitlementPersonBean[0].emailAddress);
		System.assertEquals ('Bose Corp',peopleObj.people.entitlementPersonBean[0].accountName);
		System.assertEquals ('',peopleObj.people.entitlementPersonBean[0].latinAccountName);
		System.assertEquals ('US',peopleObj.people.entitlementPersonBean[0].countryCode);
		System.assertEquals ('',peopleObj.people.entitlementPersonBean[0].latinDepartment);
		
		System.assertEquals ('364',peopleObj.people.entitlementPersonBean[0].roleId);
		
	
		System.assertEquals ('false',peopleObj.people.entitlementPersonBean[0].accessToOnDemandOverride);
		System.assertEquals ('false',peopleObj.people.entitlementPersonBean[0].accessToMatlabOnTheWebOverride);
		System.assertEquals ('false',peopleObj.people.entitlementPersonBean[0].accessToLoginNamedUserOverride);
		System.assertEquals ('true',peopleObj.people.entitlementPersonBean[0].accessToDownloadOverride);
		System.assertEquals ('958588',peopleObj.people.entitlementPersonBean[0].entitlementId);
		System.assert (peopleObj.people.entitlementPersonBean[0].permissionList!=NULL);
		
		System.assertEquals ('364',peopleObj.people.entitlementPersonBean[0].roleId);
		System.assert (peopleObj!=NULL);
		
		Test.stopTest();
	}
}