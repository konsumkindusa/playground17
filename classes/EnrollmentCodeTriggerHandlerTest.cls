/*
 * @author          Neha Mahajan
 * @date            05/04/2016
 * @description     Test Class for EnrollmentCodetriggerHandler
 */


@isTest
public class EnrollmentCodeTriggerHandlerTest {
    
    private static testMethod void testEnrollmentCode(){
        
        //re-create custom setting test records when running the test class
         CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
        //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         CTrainingTestDataBuilder testbuild =new CTrainingTestDataBuilder();
         testbuild.buildEnrollmentCodeConfigurationCustomsetting();
        Account AccObj=new Account();
        AccObj.Name='TestAccount';
        AccObj.Account_Status__c='Active';
        AccObj.Account_Sector__c='Commercial';
        insert AccObj;
            
        Contact ConObj=new Contact();
        ConObj.LastName='TestAccountL';
        ConObj.FirstName='TestAccountF';
        ConObj.AccountId=AccObj.id;
        insert ConObj; 
            
        Enterprise_Training_Agreement__c EAObj= new Enterprise_Training_Agreement__c();
        EAObj=CTrainingTestDataBuilder.buildTestETAgreement(1);
        //EAObj.RecordType.Name='Seat-Based';
        EAObj.Max_Seats__c=20;
        EAObj.CurrencyIsoCode='INR';
        EAObj.Account_Name__c=AccObj.Id;
        EAObj.Primary_Contact__c=ConObj.id;
        insert EAObj;
        
        Enrollment_Code__c ECodeObj= new Enrollment_Code__c();
        ECodeObj.Enterprise_Training_Agreement__c=EAObj.id;
        insert ECodeObj;
        
        Enrollment_Code__c EcodeObject=[select id,Code__c from Enrollment_Code__c where id=:ECodeObj.id];
        System.assert(EcodeObject.Code__c!=null);
        
        
    }
}