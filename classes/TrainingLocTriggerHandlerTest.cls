/**
 *@author Original: Krishna Bhaskarla,Mathworks
 *@date Original:    Aug 19, 2015
 *@description:     This is a test class for TrainingLocTriggerHandler 
 */
@isTest
public class TrainingLocTriggerHandlerTest {
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    private static testMethod void beforeUpdateTest(){
        //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
        // User usr = TestDataBuilder.buildTrainingAdminTestUser(1);
        Profile p = [select pf.id from profile pf WHERE pf.name= 'MW Training Admin' limit 1];
        User usr = new User();
        usr.emailencodingkey    = 'UTF-8';
        usr.languagelocalekey   = 'en_US';
        usr.localesidkey        = 'en_US';
        usr.timezonesidkey      = 'America/Los_Angeles'; 
        usr.ProfileId = p.Id;
        usr.alias           = 'TUser1';
        usr.email           = 'TUser1@mathworks.com';
        usr.lastname        = 'TUser1';
        usr.username        = 'TUser1@mathworks.com';
        usr.Area__c         = 'ES - Customer Support';
        usr.Portal_User_Status__c = 'Student';
        usr.Student__c = false;
        usr.Country_Code__c = 'ph';
        usr.Is_Test_User__c = true;
         insert usr;
         System.runAs(usr){
             List<Training_Location__c> trainLocList = new List<Training_Location__c>();
             Training_Location__c trainLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
             trainLocObj.Publish_To_Web__c = true;
             insert trainLocObj;
             Training_Location__c trainLocInt = [Select Id, Name From Training_Location__c where id =: trainLocObj.Id];
             System.assert(trainLocInt != null);
             //create Course__c record from CTrainingTestDataBuilder.
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
                      
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             // create class
             Class__c classObj =CTrainingTestDataBuilder.buildTestClass(1,courseObj.Id,langObj.Id);
             classObj.Training_Location__c = trainLocInt.Id;
             classObj.Publish_To_Web__c = true;
             classObj.Seat_Price__c = 10;
             insert classObj;
             trainLocList.add(trainLocInt);
             String errorMsg = system.label.Training_location_before_update;
             try{
                 Training_Location__c updateObj = trainLocList.get(0);
                 updateObj.Publish_To_Web__c = false;
                 Update updateObj;
             } catch(Exception e){
                 System.assert(e.getMessage().contains(errorMsg));
             }
            
         }
    }
    private static testMethod void beforeDeleteTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
         insert usr;
         System.runAs(usr){
             List<Training_Location__c> trainLocList = new List<Training_Location__c>();
             Training_Location__c trainLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
             insert trainLocObj;
             Training_Location__c trainLoc=[select Id,Name from Training_Location__c where Id =:trainLocObj.id];
             system.assert(trainLoc !=null);
             trainLocList.add(trainLoc);
             String errorMsg = system.label.Training_location_before_delete;
             try{
                 Delete trainLocList[0];
             } catch(Exception e){
                 System.assert(e.getMessage().contains(errorMsg));
             }
         }
    }

    private static testMethod void beforeUpdateTest2(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         
         Training_Validation_Rule__c rule = new Training_Validation_Rule__c();
         rule.prevent_unpublish_location__c = true;
         insert rule;

         List<Training_Location__c> trainLocList = new List<Training_Location__c>();
         Training_Location__c trainLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
         insert trainLocObj;

         Training_Location__c trainLoc=[select Id,Name from Training_Location__c where Id =:trainLocObj.id];
         system.assert(trainLoc !=null);
         trainLocList.add(trainLoc);
         String errorMsg = system.label.Training_location_before_delete;
         try{
            trainLocList[0].Publish_To_Web__c = false;
            update trainLocList[0];
         } catch(Exception e){
             System.assert(e.getMessage().contains(errorMsg));
         }
    }

    private static testMethod void beforeUpdateTest3() {
        //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();

         Training_Validation_Rule__c rule = new Training_Validation_Rule__c();
         rule.prevent_unpublish_location__c = true;
         insert rule;
         
         List<Training_Location__c> trainLocList = new List<Training_Location__c>();
         Training_Location__c trainLocObj1 = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
         Training_Location__c trainLocObj2 = CTrainingTestDataBuilder.buildTestTrainingLoc(2);

         trainLocObj1.Publish_To_Web__c = true;

         trainLocList.add(trainLocObj1);
         trainLocList.add(trainLocObj2);

         insert trainLocList;

         Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
         insert courseObj;
        
         Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
         insert langObj;

         Class__c classObj =CTrainingTestDataBuilder.buildTestClass(1, courseObj.Id, langObj.Id);
         classObj.Training_Location__c = trainLocList[0].Id;
         classObj.Publish_To_Web__c = true;
         classObj.Seat_Price__c = 10;
         insert classObj;

         try {
            trainLocList[0].Publish_To_Web__c = false;
            update trainLocList;
         } catch(DmlException dmlEx) {
            System.assert(true);
         }
    }
}