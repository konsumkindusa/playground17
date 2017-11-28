/**
 * @author Original: Faina Gorelik - Mathworks 
 * @date Original: 25 July 2017, Last Modified: 
 * Last Modified:
 * @description:    tests class for BodiServiceUtilityClass
 */ 

@isTest
public class BodiServiceUtilityClassTest {
    private static testMethod void testGetValidParseBodiserviceJson(){
        string jsonData = '{"pid": -1,"cid": -1,"rid": -1,"repoName": "bodiAppTest","returnCode": null,"errorMessage": "User bodiwrapper does not have full access control on repository bodiAppTest. "}';
        // OnSupportUtilityClass.Rootboolean onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
        BodiServiceUtilityClass.Rootboolean bodiServiceResponse = BodiServiceUtilityClass.getParsedBodiServiceJson(jsonData);

        System.assertNotEquals(null, bodiServiceResponse);
        System.assertEquals(-1, bodiServiceResponse.pid);
        System.assertEquals(-1, bodiServiceResponse.cid);
        System.assertEquals(-1, bodiServiceResponse.rid);
        System.assertEquals('bodiAppTest', bodiServiceResponse.repoName);
        System.assertEquals('User bodiwrapper does not have full access control on repository bodiAppTest. ', bodiServiceResponse.errorMessage);

    }    
    
    
}