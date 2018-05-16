/*
 *    @description:    tests the TrialProductBean
 */ 
@isTest

public with sharing class TrialProductBeanTest {

    /*
      *    @description:	tests all the properties of TrialProductBean are working
      */ 
	private static testMethod void testGetParsedPeopleJson(){
		
		//setting value using getParsedContactJson() method
		String jsonToParse='{"entitlementReleaseBean":[{"passcodeVersionNumber":19,"shippedDate":"2008-02-29","name":"R2008a","products":{"entitlementProductBean":[{"productId":103,"productName":"MATLAB","productBaseCode":"ML","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"1","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":259,"productName":"Simulink","productBaseCode":"SL","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"2","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":2863,"productName":"Communications Blockset","productBaseCode":"CB","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"59","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":13,"productName":"Communications Toolbox","productBaseCode":"CM","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"36","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":17,"productName":"Control System Toolbox","productBaseCode":"CT","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"3","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":2044,"productName":"Data Acquisition Toolbox","productBaseCode":"DA","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"47","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":55,"productName":"Extended Symbolic Math Toolbox","productBaseCode":"EM","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"16","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":2489,"productName":"Filter Design Toolbox","productBaseCode":"QZ","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"55","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":5996,"productName":"Fixed-Point Toolbox","productBaseCode":"PO","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"91","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":5104,"productName":"Image Acquisition Toolbox","productBaseCode":"IA","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"78","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":86,"productName":"Image Processing Toolbox","productBaseCode":"IP","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"17","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":2877,"productName":"Instrument Control Toolbox","productBaseCode":"IC","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"62","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":126,"productName":"MATLAB Compiler","productBaseCode":"CO","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"28","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":162,"productName":"Neural Network Toolbox","productBaseCode":"NN","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"12","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":182,"productName":"Optimization Toolbox","productBaseCode":"OP","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"6","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":3051,"productName":"Real-Time Workshop Embedded Coder","productBaseCode":"EC","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"65","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":208,"productName":"Real-Time Workshop","productBaseCode":"RT","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"14","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":218,"productName":"Robust Control Toolbox","productBaseCode":"RC","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"5","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":45,"productName":"Signal Processing Blockset","productBaseCode":"DS","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"24","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":237,"productName":"Signal Processing Toolbox","productBaseCode":"SG","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"8","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":3996,"productName":"SimMechanics","productBaseCode":"MS","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"64","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":8359,"productName":"Simscape","productBaseCode":"SS","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"104","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":5241,"productName":"Simulink Control Design","productBaseCode":"SD","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"85","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":65,"productName":"Simulink Fixed Point","productBaseCode":"FP","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"25","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":174,"productName":"Simulink Response Optimization","productBaseCode":"NC","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"18","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":315,"productName":"Statistics Toolbox","productBaseCode":"ST","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"19","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":332,"productName":"Symbolic Math Toolbox","productBaseCode":"SM","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"15","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":341,"productName":"System Identification Toolbox","productBaseCode":"ID","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"4","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""},{"productId":2679,"productName":"xPC Target","productBaseCode":"XP","licenseOption":null,"licenseTerm":null,"licenseUse":null,"productOfferingLicenseTermId":null,"bitNumber":"56","seatQty":"1","defaultLicenseFileExpirationDate":"2008-03-15","productSmsEndDate":""}]},"fik":"39231-34402-60541-12109-21242-30703-02592-54736-15449-63234"}]}';
		
		Test.startTest();

		TrialProductBean productObj = TrialProductBean.parse(jsonToParse);
		
	
		System.assertEquals ('39231-34402-60541-12109-21242-30703-02592-54736-15449-63234',productObj.entitlementReleaseBean[0].fik);
		System.assertEquals ('19',productObj.entitlementReleaseBean[0].passcodeVersionNumber);
		System.assertEquals ('2008-02-29',productObj.entitlementReleaseBean[0].shippedDate);
	    System.assertEquals ('R2008a',productObj.entitlementReleaseBean[0].name);
		System.assertEquals ('MATLAB',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].productName);
		System.assertEquals ('103',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].productId);
        System.assertEquals ('ML',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].productBaseCode);
        System.assertEquals ('1',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].bitNumber);
        System.assertEquals ('1',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].seatQty);
        System.assertEquals ('2008-03-15',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].defaultLicenseFileExpirationDate);
        System.assertEquals ('',productObj.entitlementReleaseBean[0].Products.entitlementProductBean[0].productSmsEndDate);
		
		Test.stopTest();
	}
}