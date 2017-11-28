/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Krishna Bhaskarla, Mathworks story Ref No: 1093975
 *@date Original:    3 June 2015, Last Modified:  23 Sep 2015
 *@description:     This is a test class for CoursetriggerHandler 
 */
@isTest
public  with sharing class CourseTriggerHandlerTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
     /*
    @ name    contactRelatedLicenseAndProductTest
    @ date     25 June 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion of course the course language records gets created  
                   and number of records depends on records in language object.
     */              
     private static testMethod void insertCourseLanguageTest(){
         
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
            List <Language__c> lanList = new List <Language__c> ();
         System.runAs(usr){
             
             for(Integer i=0;i<3;i++){
                 //create Language__c record from CTrainingTestDataBuilder.
                 Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                 lanList.add(langObj);
             }
             insert lanList;
             Language__c langInt = [Select Id,Name From Language__c where id =: lanList[0].Id];
             System.assert(langInt != null);
             
             //create Course__c record from CTrainingTestDataBuilder.
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             insert courseObj;
             Course__c courseInt = [Select Id, Name,Pre_Requisite__c,Short_Description__c,Prerequisite__c From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             //test  the businesss logic that 3 records created for course language after insert of course
             List<Course_Language__c> clangList = [Select Id,Course__c,Localized_Pre_Requisite__c,Localized_Short_Description__c From Course_Language__c where Course__c =: courseObj.Id];
             System.assertEquals(clangList.size (), 3);
             //assert to check for fields if they are same
             System.assertEquals(courseInt.Pre_Requisite__c!=null,true);
             System.assertEquals(clangList[0].Localized_Pre_Requisite__c!=null,true);
             System.assertEquals(courseInt.Pre_Requisite__c,clangList[0].Localized_Pre_Requisite__c);
             System.assertEquals(courseInt.Short_Description__c,clangList[0].Localized_Short_Description__c);
         }
     }
     /*
    @ name    contactRelatedLicenseAndProductTest
    @ date     3 June 2015
    @ author  Sagar Talele; last modified: Krishna B
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion of course the Training Domain Connection records gets created  
                   and number of records depends on records in Training Domain records which has status equal to active.
        Removing this code. Please ref story(1093975) for details 
     */   
    
   /*  private static testMethod void insertTrainingDomainConTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
           List <Training_Domain__c> trainDomList = new List <Training_Domain__c> (); 
         System.runAs(usr){
             for(Integer i=0;i<3;i++){
                 //create Language__c record from CTrainingTestDataBuilder.
                 Training_Domain__c trainDomObj = CTrainingTestDataBuilder.buildTestTrainingDomain(i);
                 trainDomList.add(trainDomObj);
             }
             insert trainDomList;
             Training_Domain__c trainDonInt = [Select Id,Status__c From Training_Domain__c where Id =: trainDomList[0].Id];
             System.assert(trainDonInt != null);
             //create Course__c record from CTrainingTestDataBuilder.
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             List<Training_Domain_Connections__c> trainDonConInt = [Select Id,Course__c,Training_Domain__c From Training_Domain_Connections__c where Course__c =: courseObj.Id];
             System.assertEquals(trainDonConInt.size (),trainDomList.size() );
         } 
     } */
}