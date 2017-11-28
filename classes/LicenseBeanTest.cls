/*
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, @Last Modified: Sagar Talele- Cloud Sherpas/Mathworks
 *@date Original: 03 November 2014, Last Modified:  03 November 2014
 *@description This  is Test class for 'LicenseBean' class . 
 */
@isTest
public class LicenseBeanTest{

    public static LicenseBean LicenseJsonObj;
    public static  List<LicenseBean.License> LicenseBeanLst;
    public static List<LicenseBean.LicensedProduct> LicenseProductLstRelatedToLiscence;
    public static integer totalNumber;
    public static testMethod void testgetParsedLicenseJson(){
    
        //setting value using getParsedLicenseJson() method
        String jsonToParse ='{"totalNumber":1,"licenses":[{"id":123456,"licenseAccountId":"1-I50X","overrideAccountId":"1-GG4TED","administratorId":"1-DOC","option":"Individual","use":"Commercial","term":"Perpetual","status":"Active","coreProductEndDate":"2015-01-01","prorateDate":"2015-01-01","maintenanceGroupId":12264,"licensedProducts":[{"productId":103,"productName":"MATLAB","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":259,"productName":"Simulink","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"},{"productId":260,"productName":"Simulink1","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-01-01"}]}]}';
        LicenseJsonObj = LicenseBean.getParsedLicenseJson(jsonToParse);
        LicenseBeanLst = LicenseJsonObj.licenses;
        totalNumber = LicenseJsonObj.totalNumber;
        LicenseProductLstRelatedToLiscence = LicenseBeanLst[0].licensedProducts;
        //getting value
        System.assertNotEquals(null, LicenseBeanLst);
        System.assertEquals(1, totalNumber);
        System.assertEquals('123456', LicenseBeanLst[0].id);
        System.assertEquals('1-I50X', LicenseBeanLst[0].licenseAccountId);
        System.assertEquals('1-GG4TED', LicenseBeanLst[0].overrideAccountId);
        System.assertEquals('1-DOC', LicenseBeanLst[0].administratorId);
        System.assertEquals('Individual', LicenseBeanLst[0].option);
        System.assertEquals('Commercial', LicenseBeanLst[0].use);
        System.assertEquals('Perpetual', LicenseBeanLst[0].term);
        System.assertEquals('Active', LicenseBeanLst[0].status);
        System.assertEquals('2015-01-01', LicenseBeanLst[0].coreProductEndDate);
        System.assertEquals('2015-01-01', LicenseBeanLst[0].prorateDate);
        System.assertEquals(12264, LicenseBeanLst[0].maintenanceGroupId);
        System.assertEquals(103, LicenseProductLstRelatedToLiscence[0].productId);
        System.assertEquals('MATLAB', LicenseProductLstRelatedToLiscence[0].productName);
        System.assertEquals(1, LicenseProductLstRelatedToLiscence[0].quantity);
        System.assertEquals('Unallocated', LicenseProductLstRelatedToLiscence[0].allocationStatus);
        System.assertEquals('2015-01-01', LicenseProductLstRelatedToLiscence[0].maintenanceEndDate);


    }
}