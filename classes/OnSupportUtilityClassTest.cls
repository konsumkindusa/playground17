/**
 * @author Original: Faina Gorelik - Mathworks 
 * @date Original: 5 July 2016, Last Modified: 
 * Last Modified:
 * @description:    tests the OnSupportUtilityClass 
 */ 

@isTest
public class OnSupportUtilityClassTest {

    private static testMethod void testGetValidParsedOnSupportJson(){
        //build json response for valid license and product
        string jsonData = '{"licenseId": 10900,"licenseSupportEligible":true,"licenseeAccountId":"C0005","controllingProductDetail":{"geographicScope":"LOCAL","latestServiceEndDate":"2026-06-30","offeringGracePeriod": 0,"option":"TH","term":"ANNUAL","use":"ACADEM","lifecycleStage":"ACTIVE"},"productCode":"MB","productSupportEligible": true,"requestedProductDetail": {"geographicScope": "LOCAL", "latestServiceEndDate":"2026-06-30","offeringGracePeriod":0,"option": "TH", "term":"ANNUAL", "use":"ACADEM","lifecycleStage": "ACTIVE"}}'; 
        OnSupportUtilityClass.Rootboolean onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
        
        System.assertNotEquals(null, onSupportResponse);
        System.assertEquals('10900', onSupportResponse.licenseId);
        System.assertEquals(true, onSupportResponse.licenseSupportEligible);
        System.assertEquals('C0005',onSupportResponse.licenseeAccountId);
        System.assertEquals('MB', onSupportResponse.productCode);
        System.assertEquals(true, onSupportResponse.productSupportEligible);
        
        // get ControllingproductDetail fields
        System.assertEquals('LOCAL',onSupportResponse.controllingProductDetail.geographicScope);
        System.assertEquals('2026-06-30',onSupportResponse.controllingProductDetail.latestServiceEndDate);
        System.assertEquals(0,onSupportResponse.controllingProductDetail.offeringGracePeriod);
        System.assertEquals('TH',onSupportResponse.controllingProductDetail.option);
        System.assertEquals('ANNUAL',onSupportResponse.controllingProductDetail.term);
        System.assertEquals('ACADEM',onSupportResponse.controllingProductDetail.use);
        System.assertEquals('ACTIVE',onSupportResponse.controllingProductDetail.lifecycleStage);

        //get RequestProductDetail fields
        //RequestedProductDetail
        System.assertEquals('LOCAL',onSupportResponse.RequestedProductDetail.geographicScope);
        System.assertEquals('2026-06-30',onSupportResponse.RequestedProductDetail.latestServiceEndDate);
        System.assertEquals(0,onSupportResponse.RequestedProductDetail.offeringGracePeriod);
        System.assertEquals('TH',onSupportResponse.RequestedProductDetail.option);
        System.assertEquals('ANNUAL',onSupportResponse.RequestedProductDetail.term);
        System.assertEquals('ACADEM',onSupportResponse.RequestedProductDetail.use);
        System.assertEquals('ACTIVE',onSupportResponse.RequestedProductDetail.lifecycleStage);
             
        
    }
    
    private static testMethod void testGetProductReasonParsedOnSupportJson(){
	// build json string to get product reason code
      	string jsonData ='{"licenseId":10800,"licenseSupportEligible":true,"licenseeAccountId":"C0004","controllingProductDetail":{"geographicScope":"LOCAL","latestServiceEndDate":"2026-01-31","offeringGracePeriod":0,"option":"CN","term":"PERPETUAL","use":"ACADEM","lifecycleStage":"ACTIVE"},"productCode":"ML","productReason":"PRODUCT_NOT_FOUND_ON_LICENSE","productSupportEligible":false,"requestedProductDetail": {} }';                              
        OnSupportUtilityClass.Rootboolean onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
        
        System.assertNotEquals(null, onSupportResponse);
        System.assertEquals('10800', onSupportResponse.licenseId);
        System.assertEquals(true, onSupportResponse.licenseSupportEligible);
        System.assertEquals('C0004',onSupportResponse.licenseeAccountId);
        System.assertEquals('ML', onSupportResponse.productCode);
        System.assertEquals(false, onSupportResponse.productSupportEligible);
        System.assertEquals('PRODUCT_NOT_FOUND_ON_LICENSE', onSupportResponse.ProductReason);
        
        // get ControllingproductDetail fields
        System.assertEquals('LOCAL',onSupportResponse.controllingProductDetail.geographicScope);
        System.assertEquals('2026-01-31',onSupportResponse.controllingProductDetail.latestServiceEndDate);
        System.assertEquals(0,onSupportResponse.controllingProductDetail.offeringGracePeriod);
        System.assertEquals('CN',onSupportResponse.controllingProductDetail.option);
        System.assertEquals('PERPETUAL',onSupportResponse.controllingProductDetail.term);
        System.assertEquals('ACADEM',onSupportResponse.controllingProductDetail.use);
        System.assertEquals('ACTIVE',onSupportResponse.controllingProductDetail.lifecycleStage);

       
        
    }
    
    private static testMethod void testGetLicenseReasonParsedOnSupportJson(){
        //build json string to get license reason
        string jsonData ='{"licenseId":10700,"licenseReason": "OFF_MAINTENANCE","licenseSupportEligible":false,"licenseeAccountId":"C0003","controllingProductDetail":{"geographicScope":"LOCAL","latestServiceEndDate":"2026-01-31","offeringGracePeriod":0,"option":"CN","term":"PERPETUAL","use":"ACADEM","lifecycleStage":"ACTIVE"}}';                              
        OnSupportUtilityClass.Rootboolean onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
        
        System.assertNotEquals(null, onSupportResponse);
        System.assertEquals('10700', onSupportResponse.licenseId);
        System.assertEquals(false, onSupportResponse.licenseSupportEligible);
        System.assertEquals('C0003',onSupportResponse.licenseeAccountId);
        System.assertEquals('OFF_MAINTENANCE', onSupportResponse.licenseReason);
        
        // get ControllingproductDetail fields
        System.assertEquals('LOCAL',onSupportResponse.controllingProductDetail.geographicScope);
        System.assertEquals('2026-01-31',onSupportResponse.controllingProductDetail.latestServiceEndDate);
        System.assertEquals(0,onSupportResponse.controllingProductDetail.offeringGracePeriod);
        System.assertEquals('CN',onSupportResponse.controllingProductDetail.option);
        System.assertEquals('PERPETUAL',onSupportResponse.controllingProductDetail.term);
        System.assertEquals('ACADEM',onSupportResponse.controllingProductDetail.use);
        System.assertEquals('ACTIVE',onSupportResponse.controllingProductDetail.lifecycleStage);
        
    }
    
    private static testMethod void testGetDetalParsedOnSupportJson(){
        //build json string to get detail for the not found response
        string jsonData ='{"detail": "license 123 not found"}';
        OnSupportUtilityClass.Rootboolean onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
        System.assertEquals('license 123 not found', onSupportResponse.detail);
    }
}