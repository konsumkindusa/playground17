/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks,Faina Gorelik MathWorks AtTask 2238455, Faina Gorelik - Mathworks
 *@date Original:    3 June 2015, Last Modified:  3 June 2015, August 2017
 *@description:     This is a test class for CoursetriggerHandler 
 */
@isTest
public  with sharing class ETrainingAgreementTriggerHandlerTest{
    
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
     private static testMethod void insertTAgreementClassRelationshipTest(){
         
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
       System.runAs(usr){
              test.startTest();
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
             
             Id recTypeId = [Select Id From RecordType  Where (SobjectType = 'Class__c') AND (RecordType.Name ='Self-Paced') LIMIT 1].Id;
             //intialize class list to create multiple records for class.
             List<Class__c> classList = new List<Class__c>();
             for(Integer i=0;i<3;i++){
                 Class__c classObj =CTrainingTestDataBuilder.buildTestClass(i,courseObj.Id,langObj.Id);
                 classObj.recordTypeId = recTypeId ;
                 classObj.Status__c = 'Active';
                 classList.add(classObj);
             }
             insert classList;
             System.assertEquals(classList.size(),3);
             List<RecordType> recTypeList = new List<RecordType>();
             Id etAgrrementRecTypeId = [Select ID, Name From RecordType Where sObjectType = 'Enterprise_Training_Agreement__c' AND RecordType.Name ='Unlimited' limit 1].Id;
             //intialize class list to create multiple records for Enterprise Training Agreement.
             List<Enterprise_Training_Agreement__c> ETAgreementList = new List<Enterprise_Training_Agreement__c>();
             for(Integer i=0;i<3;i++){
                 Enterprise_Training_Agreement__c ETAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(1);
                 ETAgreementObj.RecordTypeId = etAgrrementRecTypeId ; 
                 if (i==2){// to cover http call on insert
                     ETAgreementObj.License_ID__c ='099902';
                 }
                 ETAgreementList.add(ETAgreementObj);
                 
             }    
        //   
           StaticResourceCallOutMock multimockcallMAOTS = new StaticResourceCalloutMock();
           multimockcallMAOTS.setStaticResource('MockResponseCourseManager');     
           multimockcallMAOTS.setStatusCode(200);
           multimockcallMAOTS.setHeader('x-mw-authentication', 'LEARN-MATLAB');
           multimockcallMAOTS.setHeader('OrganizationID', UserInfo.getOrganizationId()); 
           string url = 'https://sf-ext-msg-dev.mathworks.com/course-manager/service/v1/license-enrollments/099902';
           test.setMock(HttpCalloutMock.class, multimockcallMAOTS);
           //
             insert ETAgreementList ;
             System.assertEquals(ETAgreementList.size(),3);
             
             List<Training_Agreement_Class_Relationship__c> TAgreementClassRelList = new List<Training_Agreement_Class_Relationship__c>();
             TAgreementClassRelList = [Select Id,Class__c,Enterprise_Training_Agreement__c   From Training_Agreement_Class_Relationship__c where Enterprise_Training_Agreement__c =:ETAgreementList[0].Id];
             System.assertEquals(TAgreementClassRelList.size(),classList.size());
             System.assert(TAgreementClassRelList !=null);
              test.stopTest();
         }
     }
    
    private static testMethod void updateTAgreementClassRelationshipTest(){// fg test Course Manager integration when the existing license has been udpated
        
        // test the scenario when when submit batch check box is true
        //  //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        //Create test user
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        System.runAs(usr){
            //   test.startTest();
            //create Course__c record from CTrainingTestDataBuilder.
            Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
            insert courseObj;
            Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
            
            
            //create Language__c record from CTrainingTestDataBuilder.
            Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
            insert langObj;
            Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
            
            Id recTypeId = [Select Id From RecordType  Where (SobjectType = 'Class__c') AND (RecordType.Name ='Self-Paced') LIMIT 1].Id;
            //intialize class list to create multiple records for class.
            List<Class__c> classList = new List<Class__c>();
            for(Integer i=0;i<3;i++){
                Class__c classObj =CTrainingTestDataBuilder.buildTestClass(i,courseObj.Id,langObj.Id);
                classObj.recordTypeId = recTypeId ;
                classObj.Status__c = 'Active';
                classList.add(classObj);
            }
            insert classList;
            Id etAgrrementRecTypeId = [Select ID, Name From RecordType Where sObjectType = 'Enterprise_Training_Agreement__c' AND RecordType.Name ='Unlimited' limit 1].Id;
            
            // create new ETA record then update start date to push it to Course Manager system
            //intialize class list to create multiple records for Enterprise Training Agreement.
            List<Enterprise_Training_Agreement__c> ETAgreementList = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<3;i++){
                Enterprise_Training_Agreement__c ETAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(1);
                ETAgreementObj.RecordTypeId = etAgrrementRecTypeId ;
                ETAgreementList.add(ETAgreementObj);
            }
            insert ETAgreementList ;
            
            List<Enterprise_Training_Agreement__c> ETAUpdate = new List<Enterprise_Training_Agreement__c>();   
            ETAUpdate = [select id,License_ID__c,Term_Start_Date__c,Term_End_Date__c,Classes__c,Grace_Period_End_Date__c   From Enterprise_Training_Agreement__c where Id =:ETAgreementList[0].Id];
       //     test.startTest(); // start test to validate update record process
            ETAUpdate[0].Term_Start_Date__c = System.Today().addDays(-5);
            ETAUpdate[0].License_ID__c = '000900';
         	StaticResourceCallOutMock multimockcallMAOTS = new StaticResourceCalloutMock();
            multimockcallMAOTS.setStaticResource('MockResponseCourseManager');     
            multimockcallMAOTS.setStatusCode(200);
            multimockcallMAOTS.setHeader('x-mw-authentication', 'LEARN-MATLAB');
            multimockcallMAOTS.setHeader('OrganizationID', UserInfo.getOrganizationId()); 
            string url = 'https://sf-ext-msg-dev.mathworks.com/course-manager/service/v1/license-enrollments/000900';
 
            test.startTest(); // start test to validate update record process
            test.setMock(HttpCalloutMock.class, multimockcallMAOTS);
            update ETAUpdate[0]; 
            
            test.stopTest();
        }
    }
}