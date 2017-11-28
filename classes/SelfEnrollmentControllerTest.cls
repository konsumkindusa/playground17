/***************************************************************************************
 * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
 * date Original: 28 March 2016, Last Modified: 28 March 2016
 * description : This is a test class for EnrollmentTriggerHandler
 ****************************************************************************************/
@isTest
public class SelfEnrollmentControllerTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTcustsettbuild = new CTrainingCustomSettingBuilder();
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
     * date Original: 28 March 2016, Last Modified: 28 March 2016
     * description : This is a test Method for SelfEnrollmentController 
     ****************************************************************************************/
     private static testMethod void validateEnrollmentCodeTest(){
         
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        cTcustsettbuild.buildEnrollmentCodeConfiguration();
        Id etAgrrementRecTypeId = [Select ID, Name From RecordType Where sObjectType = 'Enterprise_Training_Agreement__c' AND RecordType.Name = 'Unlimited' limit 1].Id;
        //intialize class list to create multiple records for Enterprise Training Agreement.
        List<Enterprise_Training_Agreement__c> ETAgreementList = new List<Enterprise_Training_Agreement__c>();
        for(Integer i=0;i<3;i++){
            Enterprise_Training_Agreement__c ETAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(1);
            ETAgreementObj.RecordTypeId = etAgrrementRecTypeId ;
            ETAgreementObj.Self_Enrollment_Content__c = 'testRichText';
            ETAgreementList.add(ETAgreementObj);
        }
        insert ETAgreementList ;
        System.assertEquals(ETAgreementList.size(),3);
        Enterprise_Training_Agreement__c  etaObj = [Select Id,Is_Active__c,Account_Name__c From Enterprise_Training_Agreement__c  where Id =:ETAgreementList[0].Id ];
        system.assertEquals(etaObj.Is_Active__c ,true);
        //intialize class list to create multiple records for Enrollment_Code__c 
        List<Enrollment_Code__c> enrollCodeList = new List<Enrollment_Code__c>();
        for(Integer i=0;i<3;i++){
            Enrollment_Code__c enrollObj= CTrainingTestDataBuilder.buildTestEnrollmentCode(etaObj.Id);
            enrollCodeList.add(enrollObj);
        }
        insert enrollCodeList;
        Enrollment_Code__c enrollCode = [Select id,Code__c,Status__c, Enterprise_Training_Agreement__c, Enterprise_Training_Agreement__r.Is_Active__c From Enrollment_Code__c Where Id =:enrollCodeList[0].Id];
        system.assertEquals(enrollCode.Code__c != null,true);
        
        PageReference pageRef = Page.SelfEnrollment;
        Test.setCurrentPage(pageRef);
        SelfEnrollmentController SelfEnrollmentController = new SelfEnrollmentController();
        SelfEnrollmentController.enrollmentCode = enrollCode.Code__c;
        SelfEnrollmentController.navigateToAuthUrl();
        SelfEnrollmentController.checkEnrollmentCode();
        SelfEnrollmentController.navigateToAuthUrl();
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, enrollCode.Code__c);
        ApexPages.currentPage().getParameters().put('language', '');
        SelfEnrollmentController.validateEnrollmentCode(enrollCode);
        system.assertEquals(SelfEnrollmentController.isValidEnrollmentCode,true);
        //system.assertEquals(SelfEnrollmentController.isError,false);
        
     }
     /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
     * date Original: 28 March 2016, Last Modified: 28 March 2016
     * description : This is a test Method for SelfEnrollmentController 
     ****************************************************************************************/
     private static testMethod void validateEnrollmentCodeNegativeTest(){
        //Senario 2 where Code__c  is null and Enterprise_Training_Agreement__c   isActive is false
         //intialize class list to create multiple records for Enterprise Training Agreement.
         //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        cTcustsettbuild.buildEnrollmentCodeConfiguration();
        Id etAgrrementRecTypeId = [Select ID, Name From RecordType Where sObjectType = 'Enterprise_Training_Agreement__c' AND RecordType.Name = 'Unlimited' limit 1].Id;
        
        List<Enterprise_Training_Agreement__c> ETAgtList = new List<Enterprise_Training_Agreement__c>();
        for(Integer i=0;i<3;i++){
            Enterprise_Training_Agreement__c ETAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(1);
            ETAgreementObj.RecordTypeId = etAgrrementRecTypeId ;
            ETAgreementObj.Self_Enrollment_Content__c = null;
            ETAgreementObj.Term_Start_Date__c = System.Today().addDays(-2);
            ETAgreementObj.Term_End_Date__c = System.Today().addDays(-1);
            ETAgtList.add(ETAgreementObj);
        }
        insert ETAgtList ;
        System.assertEquals(ETAgtList.size(),3);
        Enterprise_Training_Agreement__c  etaObj1 = [Select Id,Is_Active__c,Account_Name__c From Enterprise_Training_Agreement__c  where Id =:ETAgtList[0].Id ];
        system.assertEquals(etaObj1.Is_Active__c ,false);
        //intialize class list to create multiple records for Enrollment_Code__c 
        List<Enrollment_Code__c> enrollCodeLst = new List<Enrollment_Code__c>();
        for(Integer i=0;i<3;i++){
            Enrollment_Code__c enrollObj= CTrainingTestDataBuilder.buildTestEnrollmentCode(etaObj1.Id);
            enrollCodeLst.add(enrollObj);
        }
        insert enrollCodeLst;
        Enrollment_Code__c enrollCodeObj = [Select id,Code__c From Enrollment_Code__c Where Id =:enrollCodeLst[0].Id];
        enrollCodeObj.Code__c =null;
        update enrollCodeObj;
        system.assertEquals(enrollCodeObj.Code__c == null,true);
        
        PageReference pageRef1 = Page.SelfEnrollment;
        Test.setCurrentPage(pageRef1);
        // Add parameters to page URL
       // ApexPages.currentPage().getParameters().put('code', '888888888888');
        ApexPages.currentPage().getParameters().put('code', '888888888888');
        ApexPages.currentPage().getParameters().put(TrainingUtil.ECODE_URL_PARAM_KEY, enrollCodeObj.Code__c);
        SelfEnrollmentController controller = new SelfEnrollmentController();
        controller.navigateToAuthUrl();
        system.assertEquals(controller.isValidEnrollmentCode,false);
    }
}