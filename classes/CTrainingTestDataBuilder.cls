/**
 * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 * @date Original: 19 May 2015, Last Modified: 19 May 2015
 * @description Global utility class that contains different record builders for unit testing.
 */
public with sharing class CTrainingTestDataBuilder {  
    
   /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 19 May 2015
     * @description Helper method to create a test Course record(can be called iteratively to create more than 1 Course.)
     * @param i An integer that will serve as index for iteration (bulk).
     */
      public static Course__c buildTestCourse(Integer i){
        Course__c courseObj =  new Course__c();
        courseObj.Name = 'testCourse'+i;
        courseObj.Status__c = 'Active';
        //Addition of new fields --Neha Mahajan
        courseObj.Pre_Requisite__c='test description';
        courseObj.Short_Description__c='test pre req'; 
        //courseObj.Course_ID__c = 'TEST';field not there for train env
        return courseObj;
       }
    /**
     * @author Original: Original: Krishna Bhaskarla, Mathworks , Last Modified :Sagar Talele ,Accenture
     * @date Original: Aug 19, 2015
     * @description Helper method to create a test training location record(can be called iteratively to create more than 1 location.)
     *              New Version - Sagar talele: Added the test values for Address_Line_1__c,City__c,Postal_Code__c,Country__c
     *                            as one validation rule which required above field value if Publish_To_Web__c  is true.
     * @param i An integer that will serve as index for iteration (bulk).
     */
    public static Training_Location__c buildTestTrainingLoc(Integer i){
        Training_Location__c trainLoc = new Training_Location__c();
        trainLoc.Name = 'testLoc'+i;
        trainLoc.Status__c = 'Active';
        trainLoc.Publish_To_Web__c = true;
        trainLoc.Address_Line_1__c = 'testAddressLine1';
        trainLoc.City__c = 'Boston';
        trainLoc.Postal_Code__c = '09212';
        trainLoc.Country__c = 'United States';
        return trainLoc;
        
    }
  
   /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 19 May 2015
     * @description Helper method to create a test class records(can be called iteratively to create more than 1 class.)
     * @param i An integer that will serve as index for iteration (bulk).
     */
       public static Class__c buildTestClass(Integer i,Id courseId,Id languageId){
           Class__c classObj = new Class__c();
           classObj.Course__c = courseId;
           classObj.Name = 'testClass'+i;
           classObj.Language__c = languageId;
           classObj.Max_Seats__c = 4;
           classObj.Status__c = 'Active';
           classObj.Class_Type__c = 'Public';
           return classObj;
       }
   /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 19 May 2015
     * @description Helper method to create a test Enrollment(can be called iteratively to create more than 1 Enrollment)
     * @param i An integer that will serve as index for iteration (bulk).
     */
      public static Enrollment__c buildTestEnrollment(Id contId,Id classId){
          Enrollment__c enrollmentObj = new Enrollment__c();
          enrollmentObj.Enrollee_Name__c = contId;
          enrollmentObj.Class__c = classId;
          return enrollmentObj;
      }
      
   /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 19 May 2015
     * @description Helper method to create a test language  record(can be called iteratively to create more than 1 language.)
     * @param i An integer that will serve as index for iteration (bulk).
     */
      public static Language__c buildTestLanguage(Integer i){
           Language__c lanObj = new Language__c();
           lanObj.Name = 'English' + i;
           lanObj.Language_Code__c = 'Eng';
           lanObj.SF_ISO_Code__c = 'en_US';
           return lanObj;
       }
   /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks ; last modified: Krishna B 
     * @date Original: 19 May 2015
     * @description Helper method to create a test Training Domain record(can be called iteratively to create more than 1 training Domain .)
     * @param i An integer that will serve as index for iteration (bulk).
     * Removind this code. Please refer story(1093975) for details
     */
      /*public static Training_Domain__c buildTestTrainingDomain(Integer i){
           Training_Domain__c trainDomObj = new Training_Domain__c();
           trainDomObj.Name= 'English' + i;
           trainDomObj.Status__c = 'Active';
           return trainDomObj;
       } */
       /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 19 May 2015
     * @description Helper method to create a test Training Domain record
     */
      public static Sponsor_Office__c buildTestSponsorOffice(Integer i,Id langId){
          Sponsor_Office__c spOfficeObj = new Sponsor_Office__c();
          spOfficeObj.Name = 'EN' + i;
          spOfficeObj.Class_Default_End_Time__c = '5:00 PM';
          spOfficeObj.Class_Default_Start_Time__c = '9:00 AM';
          spOfficeObj.Default_Class_Language__c = langId;
          spOfficeObj.Email__c = 'support@mathworks.com';
          return spOfficeObj;
      }
       /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 15 July 2015
     * @description Helper method to create a test Course Language record
     */
      public static Course_Language__c buildTestCourseLanguage(Id courseId,Id langId){
          Course_Language__c courseLangObj = new Course_Language__c();
          courseLangObj.Course__c = courseId;
          courseLangObj.Course_Language__c = langId;
          courseLangObj.Localized_Course_Name__c = 'Test Localized course name';
          courseLangObj.Course__c = courseId;
          return courseLangObj;
      }
      /**
     * @author Original: Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 29 July 2015
     * @description Helper method to create a test Enterprise Training Agreement record(can be called iteratively to create more than 1 training agreement .)
     * @param i An integer that will serve as index for iteration (bulk).
     */
      public static Enterprise_Training_Agreement__c   buildTestETAgreement(integer i){
          Enterprise_Training_Agreement__c ETAgreementObj = new Enterprise_Training_Agreement__c();
          ETAgreementObj.Name = 'Test' +i;
          ETAgreementObj.Term_Start_Date__c = System.Today().addDays(-1);
          ETAgreementObj.Term_End_Date__c = System.Today().addYears(1);
          return ETAgreementObj;
      }
      
      /**
     * @author Original: Original: Abhay Verma - Cloud Sherpas/Mathworks  
     * @date Original: 17 Aug 2015
     * @description Helper method to create a test Training Agreement Class Relationship record
     */
     
     public static Training_Agreement_Class_Relationship__c buildTestTAClassRelationship(Id classId,Id trainingAgreementId){
         Training_Agreement_Class_Relationship__c TAClassRelationshipObj = new Training_Agreement_Class_Relationship__c();
         TAClassRelationshipObj.class__c = classId;
         TAClassRelationshipObj.Enterprise_Training_Agreement__c = trainingAgreementId;
         return TAClassRelationshipObj;
     }
    /**
     * @author Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 17 aug 2015
     * @description Helper method to create a test Email Template
     */
     public static EmailTemplate buildTestEmailTemplate(){
         EmailTemplate validEmailTemplate = new EmailTemplate();
         validEmailTemplate.isActive = true;
         validEmailTemplate.Name = 'TestEmailFunctionality_Test_Pre_Enrollment_Eng_BNL';
         validEmailTemplate.DeveloperName = 'TestEmailFunctionality_Test_Instructor_Led_Eng_BNL';
         validEmailTemplate.TemplateType = 'text';
         validEmailTemplate.FolderId = UserInfo.getUserId();
         return validEmailTemplate;
     }
      /**
     * @author Original: Sagar Talele - Cloud Sherpas/Mathworks  
     * @date Original: 17 aug 2015
     * @description Helper method to create a test Email Template
     */
     public static OrgWideEmailAddress buildTestOrgWideEmailAddress(){
         OrgWideEmailAddress orgw=new OrgWideEmailAddress();
         orgw.Address ='abc@test.com';
         orgw.DisplayName ='test';
         orgw.IsAllowAllProfiles=true;
         return orgw;
     }
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
     * date Original: 5 April 2016, Last Modified: 5 April 2016
     * description : Helper method to create a test Enrollment Code record 
     ****************************************************************************************/                      
    public static Enrollment_Code__c buildTestEnrollmentCode(Id ETAid){
        Enrollment_Code__c enrollCodeObj = new Enrollment_Code__c();
        enrollCodeObj.Enterprise_Training_Agreement__c = ETAid;
        enrollCodeObj.Status__c = 'Active';                 
        return enrollCodeObj;
    }
    
     /**
    * @author Original: Neha Mahajan - Cloud Sherpas/Mathworks
    * @date Original: 06 April 2016
    * @description: Helper method to create Enrollment Code Configuration custom setting
    */
    public void buildEnrollmentCodeConfigurationCustomsetting(){
        Training_Agreement_Settings__c  eccset = new Training_Agreement_Settings__c();
        eccset.Character_Set__c='0;1;2;3;4;5;6;7;8;9;A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z';
        eccset.Code_Length__c=12;
        eccset.Self_Enrollment_Authenticated_URL__c='https://traindev-mathworksservicerequest.cs15.force.com/enroll?code=';
        eccset.Self_Enrollment_Unauthenticated_URL__c='https://traindev-mathworksservicerequest.cs15.force.com/enroll?code=';
        insert eccset;
    }
    
}