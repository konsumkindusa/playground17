/**
 * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 * @date Original: 18 Aug 2015, Last Modified: 18 Aug 2015
 * @description Global utility class that contains different record builders for unit testing.
 */
public  class CTrainingCustomSettingBuilder {  

    /**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified by:Sagar Talele
    * @date Original: 17 Aug 2015, Last Modified:  17 Aug 2015
    * @description Helper method to re-create Email_Template_Selection_Settings__c.
    */
     public static void buildEmailTemplateSelectionSettings(){
         Email_Template_Selection_Settings__c emailTempObj = new Email_Template_Selection_Settings__c();
         emailTempObj.Name = 'TestEmailFunctionality';
         emailTempObj.Event_Name__c = 'TestEmailFunctionality';
         emailTempObj.Email_Template_Name__c = 'TestEmailFunctionality_Test';
         emailTempObj.FieldName__c = 'Test_Flags_1__c';
         insert emailTempObj;
     }
      /**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified by:Sagar Talele
    * @date Original: 17 Aug 2015, Last Modified:  17 Aug 2015
    * @description Helper method to re-create Email_Template_Selection_Settings__c.
    */
    public static void buildEmailAddressForSponsorOfficeSettings(){
        EmailAddressForSponsorOffice__c emailAddressObj = new EmailAddressForSponsorOffice__c();
        emailAddressObj.Email__c = 'support@mathworks.com';
        emailAddressObj.name = 'test';
        insert emailAddressObj;
    }
    
    
    /**
    * @author Original: Abhay Verma - Accenture/Mathworks, Last Modified by:
    * @date Original: 5 April 2016, Last Modified:  
    * @description Helper method to re-create Training_Agreement_Settings__c .
    */
    
    public void buildEnrollmentCodeConfiguration(){
        Training_Agreement_Settings__c enrolCodeConfig = new Training_Agreement_Settings__c();
        enrolCodeConfig.SetupOwnerId = UserInfo.getOrganizationId();
        enrolCodeConfig.Character_Set__c = '0;1;2;3;4;5;6;7;8;9;A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z';
        enrolCodeConfig.Code_Length__c = 12;
        enrolCodeConfig.Self_Enrollment_Authenticated_URL__c = 'https://traindev-mathworksservicerequest.cs15.force.com/enroll?code=';
        enrolCodeConfig.Self_Enrollment_Unauthenticated_URL__c = 'https://traindev-mathworksservicerequest.cs15.force.com/enroll?code=';       
        enrolCodeConfig.Account_Academy_Login_Url_to_MATLAB_Acad__c ='https://testAccountAcademy@loginUrltest.com';
        enrolCodeConfig.Send_Email__c = true;
        enrolCodeConfig.Mw_Local_Training_Url_to_Default_Traini__c = 'https://localTraining@urltest.com';
        enrolCodeConfig.VF_Email_Template_Name__c = 'Mathworks_Training_Enroll_Confirmation';
        enrolCodeConfig.Task_Owner__c = 'mwsadmin';
        enrolCodeConfig.Email_Template_Subject__c = 'MathWorks Online Training Enrollment Confirmation';
        enrolCodeConfig.OrgWideEmailAddress__c = 'abc@test.com';
        enrolCodeConfig.Training_Coordinator_Email_Template_Name__c = 'TAH_Training_Coordinator_Notification';
        enrolCodeConfig.TrainopsEmails__c = 'testTrainingOps@nmkTest.com';
        enrolCodeConfig.Training_Coordinator_Renewal_Temp_Name__c = 'TAH_TC_Renewal_Notification';
        enrolCodeConfig.FAQ_Page_Url__c = 'faqPageUrl@testLink.com';
        insert enrolCodeConfig;
    }
    /***************************************************************************************
     * @author Original: Sagar Talele Accenture/Mathworks, Last Modified by:
     * @date Original: 12 March 2016, Last Modified: 12 March 2016
     * @description : Helper method to re-create Training_Agreement_Settings__c.
     ****************************************************************************************/
    public void buildTrainingAgreementSettings(){
        Training_Agreement_Settings__c  trainigSettings = new Training_Agreement_Settings__c ();
        trainigSettings.Auto_Create_Class_Association__c = false;
        insert trainigSettings;
        
    } 
}