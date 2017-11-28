/**
 *author Original: Faina Gorelik - MathWorks
 *date Original: 28 September 2017, Last Modified: 
 *description This  is handler class for TrainingAgreementClassTriggerHandler, not validation for Assert since we are not getting back any response after the call
 */

@isTest
public class TrainingAgreementClassTriggerHandlerTest {
    
static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
// create new ETA
private static testMethod void updateTAgreementClassRelationshipTest(){// fg test Course Manager integration when the existing license has been udpated
        
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
            
          // build new course
            Course__c courseObjNew = CTrainingTestDataBuilder.buildTestCourse(1);
            insert courseObjnew;
            Course__c courseIntNew = [Select Id, Name From Course__c where id =: courseObjNew.Id];
            
            // add new class associated with the new course
             List<Class__c> classListNew = new List<Class__c>();
            for(Integer i=0;i<3;i++){
                Class__c classObjNew =CTrainingTestDataBuilder.buildTestClass(i,courseObjNew.Id,langObj.Id);
                classObjNew.recordTypeId = recTypeId ;
                classObjNew.Status__c = 'Active';
                classListNew.add(classObjNew);
            }
            insert classListNew;
           // add new class to the relationship table
           Training_Agreement_Class_Relationship__c TARelRecord = new Training_Agreement_Class_Relationship__c();
           List<Class__c> ETRelClass = new List<Class__c>();  
           ETRelClass = [select Id  From Class__C where Id =:classListNew[0].Id];
           TARelRecord.Class__c = ETRelClass[0].Id;
           TARelRecord.Enterprise_Training_Agreement__c = ETAgreementList[0].Id;
           StaticResourceCallOutMock multimockcallMAOTSNew = new StaticResourceCalloutMock();
           multimockcallMAOTSNew.setStaticResource('MockResponseCourseManager');     
           multimockcallMAOTSNew.setStatusCode(200);
           multimockcallMAOTSNew.setHeader('x-mw-authentication', 'LEARN-MATLAB');
           multimockcallMAOTSNew.setHeader('OrganizationID', UserInfo.getOrganizationId()); 
           string urlnew = 'https://sf-ext-msg-dev.mathworks.com/course-manager/service/v1/license-enrollments/099902';
           test.setMock(HttpCalloutMock.class, multimockcallMAOTSNew);
           insert TARelRecord;
            test.stopTest();
        }
    }
    
}