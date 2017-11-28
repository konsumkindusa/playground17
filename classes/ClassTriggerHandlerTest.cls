/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Andy Ognenoff - Cloud Sherpas/Mathworks
 *@date Original:    30 June 2015, Last Modified:  24 Aug 2015
 *@description:     This is a test class for ClassTriggerHandler 
 */
@isTest
public  with sharing class ClassTriggerHandlerTest{
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
    static CTrainingCustomSettingBuilder custsettingsbuild = new CTrainingCustomSettingBuilder();
     /*
    @ name    Class Deletion validation
    @ date     30 June 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Class cannot be deleted if there are any enrollments
     */              
     private static testMethod void beforeDeleteClassTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
         System.runAs(usr){
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             //create Course__c record from CTrainingTestDataBuilder.
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
          
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             //intialize class list to create multiple records for class.
             List<Class__c> classList = new List<Class__c>();
             for(Integer i=0;i<3;i++){
                 Class__c classObj =CTrainingTestDataBuilder.buildTestClass(i,courseObj.Id,langObj.Id);
                 classObj.RecordTypeId = ClassRecordtypeId;
                 classList.add(classObj);
             }
             insert classList;
             Class__c classInt = [Select Id,Name From Class__c Where Id =: classList[0].Id];
             System.assert(classInt != null);
                          
             //create Account record from TestDataBuilder.
             Account accObj = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
             insert accObj;
             Account accountInt = [select Id,Name from Account where Id =: accObj.Id];
             system.assert(accountInt != null);   
             
             //create Contact record from TestDataBuilder.
             Contact contL = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),accObj.id);
             insert contL;
             Contact conInt = [Select Id,Name From Contact Where Id =: contL.Id];
             system.assert(conInt != null); 
             
             //create Training_Entitlement__c record from CTrainingTestDataBuilder.
             Enrollment__c enrollmentObj =  CTrainingTestDataBuilder.buildTestEnrollment(contL.Id,classList[0].Id);
             insert enrollmentObj;
             Enrollment__c enrollInt = [select Id, Name From Enrollment__c  Where Id =: enrollmentObj.Id];
             system.assert(enrollInt != null); 
             String errorMsg = system.label.Class_Before_Delete;
             try{
                 Delete classList[0];
             }
             catch(Exception e){
             System.assert(e.getMessage().contains(errorMsg ));
             }
         }
     }
      /*
    @ name    Class Insertion defaulting fields from sponsor office
    @ date     30 June 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Check for Class fields defaulted from sponsor office
     */              
     private static testMethod void beforeInsertClassTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
         System.runAs(usr){
             //create Course__c record from CTrainingTestDataBuilder.
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             Sponsor_Office__c spOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(1,langObj.Id);
             spOfficeObj.Class_Default_Time_Zone__c = 'US Eastern';
             insert spOfficeObj;
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             
             //intialize class list to create multiple records for class.
             List<Class__c> classList = new List<Class__c>();
             for(Integer i=0;i<3;i++){
                 Class__c classObj =CTrainingTestDataBuilder.buildTestClass(i,courseObj.Id,langObj.Id);
                 		  classObj.RecordTypeId = ClassRecordtypeId;
                          classObj.Sponsor_Office__c = spOfficeObj.Id;
                 classList.add(classObj);
             }
             insert classList;
             Class__c clsInt = [Select Id,Language__c,Start_Time__c,End_Time__c, Time_Zone__c From Class__c Where Id =:classList[0].Id];
             System.assertEquals(clsInt.Language__c,spOfficeObj.Default_Class_Language__c);
             System.assertEquals(clsInt.Start_Time__c,spOfficeObj.Class_Default_Start_Time__c);
             System.assertEquals(clsInt.End_Time__c,spOfficeObj.Class_Default_End_Time__c);
             System.assertEquals(clsInt.Time_Zone__c, spOfficeObj.Class_Default_Time_Zone__c);
         }
      }
       /*
    @ name    class name default
    @ date     30 June 2015
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion of class the class name automatically set based on course language.
     */              
     private static testMethod void beforeInsertClassNameTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
         System.runAs(usr){
             //create Course__c record from CTrainingTestDataBuilder.
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             Course_Language__c courselanObj = CTrainingTestDataBuilder.buildTestCourseLanguage(courseObj.Id,langObj.Id);
             insert courselanObj;
             Course_Language__c courseLangInt = [Select Id,Localized_Course_Name__c From Course_Language__c Where id =:courselanObj.Id];
             System.assert(courseLangInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
             //intialize class list to create multiple records for class.
             List<Class__c> classList = new List<Class__c>();
             for(Integer i=0;i<3;i++){
                 Class__c classObj =CTrainingTestDataBuilder.buildTestClass(i,courseObj.Id,langObj.Id);
                 classObj.RecordTypeId = ClassRecordtypeId;
                 classList.add(classObj);
             }
             insert classList;
             Class__c clsInt = [Select Id,Name From Class__c Where Id =:classList[0].Id];
             System.assertEquals(clsInt.Name,courseLangInt.Localized_Course_Name__c);
         }
     }
     
       /*
    @ name    afterInsertClassTest
    @ date     30 June 2015
    @ author  Abhay Verma
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion and updatation of class the class automatically create Training Agreement Class Relationship Object Record .
     */              
     
    private static testMethod void afterInsertClassTest(){
             //Inserting Bypass trigger custom setting
             custsettbuild.buildBypassTriggerSettings();
             //Inserting Training Agreement Settings
             custsettingsbuild.buildTrainingAgreementSettings(); 
             //Create test user
             User usr = TestDataBuilder.buildTestUser(1);
             
             insert usr;
             
             System.runas(usr){
             
             Integer i;
             List<Enterprise_Training_Agreement__c> eTrainAgmntLst = new List<Enterprise_Training_Agreement__c>();
             //Quering the Unlimited Recordtype Id 
             Id etraAgrerecTypeId = [Select Id From RecordType Where (SobjectType = 'Enterprise_Training_Agreement__c') AND (RecordType.Name ='Unlimited') LIMIT 1].Id;
             //Creating Bulk Data for Enterprise Training Agreement Object. 
             for(i=0; i<=10; i++){
                Enterprise_Training_Agreement__c etaObj = CTrainingTestDataBuilder.buildTestETAgreement(i); 
                etaObj.recordTypeId = etraAgrerecTypeId;
                etaObj.Term_Start_Date__c = date.Today() - 5;
                etaObj.Term_End_Date__c = date.Today() + 10;
                eTrainAgmntLst.add(etaObj); 
             }
             insert eTrainAgmntLst;
             
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
            
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt!= null);
             
             //Quering the Self-Paced Recordtype Id
             Id recTypeId = [Select Id From RecordType  Where (SobjectType = 'Class__c') AND (RecordType.Name ='Self-Paced') LIMIT 1].Id;
             
             List<Class__c> clssLst = new List<Class__c>();
            //Creating the test data for Class Object. 
            for(i=0; i<=10; i++){
                Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseObj.Id, langObj.Id);
                clssObj.RecordTypeId= recTypeId;
                clssLst.add(clssObj);
            }
            
            //Counting the Size of Class and Training Agreement Class Relationship Object List.
            Integer clssLstSize = clssLst.size();
            Integer etAggremntLstSize = eTrainAgmntLst.size();
            
            //start Test.
            test.startTest();
            
            //Insert Class List.
            insert clssLst;
            Training_Agreement_Settings__c  trainingAgreementObj = [Select Id,Auto_Create_Class_Association__c  From Training_Agreement_Settings__c  where Auto_Create_Class_Association__c = false ];
            if(trainingAgreementObj.Auto_Create_Class_Association__c){
                //Quering the Training Agreement Class Relationship. 
                List<Training_Agreement_Class_Relationship__c> taClsRelLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c WHERE class__c IN: clssLst AND Enterprise_Training_Agreement__c IN: eTrainAgmntLst];
                //Asserting Training Agreement Class Realation Object Record must be equal to product of Class and Enterprise Training Agreement Object Record. 
                System.assertEquals(clssLstSize*etAggremntLstSize, taClsRelLst.size()); 
            }
            else{
                //Quering the Training Agreement Class Relationship. 
                List<Training_Agreement_Class_Relationship__c> taClsRelLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c WHERE class__c IN: clssLst AND Enterprise_Training_Agreement__c IN: eTrainAgmntLst];
                //Asserting Training Agreement Class Realation Object Record must be equal to product of Class and Enterprise Training Agreement Object Record. 
                System.assertEquals(0, taClsRelLst.size()); 
            }
            //Stop test.
            test.stopTest();
      }
    } 
    
          /*
    @ name    Class update - setting time zone from location
    @ date     February 3 2017
    @ author  Shweta Shanbhag
    @ description :Check for Class fields defaulted from sponsor office
     */              
     private static testMethod void beforeUpdateClassTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
         System.runAs(usr){
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             insert courseObj;
             
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;          
             
             Training_Location__c trnlocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
             trnlocObj.Time_Zone__c = 'US Central';
             insert trnlocObj;             
             
             Training_Location__c trnlocObj2 = CTrainingTestDataBuilder.buildTestTrainingLoc(2);
             trnlocObj2.Time_Zone__c = 'US Pacific';
             insert trnlocObj2;
                         
             Sponsor_Office__c spOfficeObj = CTrainingTestDataBuilder.buildTestSponsorOffice(1,langObj.Id);
             insert spOfficeObj;
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Instructor Led') LIMIT 1].Id;          
             
             Class__c classObj =CTrainingTestDataBuilder.buildTestClass(1,courseObj.Id,langObj.Id);
             classObj.RecordTypeId = ClassRecordtypeId;
             classObj.Sponsor_Office__c = spOfficeObj.Id;
             classObj.Training_Location__c = trnlocObj.Id;
              
             
             insert classObj;
              
             Class__c clsInt = [Select Id, Time_Zone__c, Training_Location__c From Class__c Where Id =:classObj.Id];            
             System.assertEquals(clsInt.Time_Zone__c, trnlocObj.Time_Zone__c);
             
             test.startTest();
             
             clsInt.Training_Location__c = trnlocObj2.Id;
             update clsInt;
             
			test.stopTest();             
             
             Class__c clsUpd = [Select Id, Time_Zone__c, Training_Location__c From Class__c Where Id =:clsInt.Id];
             System.assertEquals(clsUpd.Time_Zone__c, trnlocObj2.Time_Zone__c);
             
             
         }
      }
    
           /*
    @ name    beforeInsertClassCloneTest
    @ date    8 March 2017
    @ author  Shweta Shanbhag
    @ description :Expected that read only fields Course Code and Class Format get populated when cloning a class
     */              
       private static testMethod void beforeInsertClassCloneTest(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
         System.runAs(usr){
             //create Course__c record from CTrainingTestDataBuilder.
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             CourseObj.Course_Code__c = 'TEST';
             CourseObj.Status__c = 'Active';
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
                         
             Class__c classObj =CTrainingTestDataBuilder.buildTestClass(0,courseObj.Id,langObj.Id);
             classObj.RecordTypeId = ClassRecordtypeId; 
             classObj.Course_Code__c = 'TEST';
             classObj.Class_Format__c = 'Instructor Led Online';
             insert classObj;
             
             test.startTest();
             
             Class__c clsInt = [Select Id,Course__c, Language__c,Course_Code__c, Name, Class_Format__c From Class__c Where Id =:classObj.Id];
             Class__c classcloneObj = clsInt.clone(false, true); 
             System.assert(classcloneObj.isClone());
             insert classcloneObj;

			test.stopTest();
             
             Class__c clsCloneRec = [Select Id,Course__c, Language__c, Course_Code__c, Class_Format__c From Class__c Where Id =:classcloneobj.Id];
             System.assertEquals(clsCloneRec.Course_Code__c,'TEST');
             System.assertEquals(clsCloneRec.Class_Format__c, 'Instructor Led Online');
         }
     }
    
    
             /*
    @ name    beforeInsertSetClassInstructorUser
    @ date    27 March 2017
    @ author  Shweta Shanbhag
    @ description :Expected primary instructor user id is populated based the primary instructor's email
     */              
       private static testMethod void beforeInsertSetClassInstructorUser(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
           
           
         System.runAs(usr){
             
             Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
             insert accObj;

             Contact conObj2 = TestDataBuilder.buildTestContact(1, usr.Id, accObj.id);
             conObj2.Email = 'TUser2@mathworks.com';
           	 insert conObj2;
            
             User usr2 = TestDataBuilder.buildTestUser(2); //This user record will have email: 'TUser2@mathworks.com'
             insert usr2;
                                   
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             CourseObj.Course_Code__c = 'TEST';
             CourseObj.Status__c = 'Active';
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
                         
             Class__c classObj =CTrainingTestDataBuilder.buildTestClass(0,courseObj.Id,langObj.Id);
             classObj.RecordTypeId = ClassRecordtypeId; 
             classObj.Course_Code__c = 'TEST';
             classObj.Class_Format__c = 'Instructor Led Online';
             classObj.Primary_Instructor__c = conObj2.id; 
          
             test.startTest();
             
             insert classObj;

			test.stopTest();
             
             Class__c classUpd = [Select Id, Primary_Instructor__c, Instructor_User__c,primary_instructor_email__c From Class__c Where Id =:classObj.Id];
			 System.assertEquals(classUpd.Instructor_User__c,usr2.Id ); 
         }
     }
    
             /*
    @ name    beforeUpdateSetClassInstructorUser
    @ date    27 March 2017
    @ author  Shweta Shanbhag
    @ description :Expected primary instructor user id is populated based the primary instructor's email
     */              
       private static testMethod void beforeUpdateSetClassInstructorUser(){
         //Inserting Bypass trigger custom setting
         custsettbuild.buildBypassTriggerSettings();
         //Create test user
         User usr = TestDataBuilder.buildTestUser(1);
            insert usr;
           
           
         System.runAs(usr){
             
             Account accObj = TestDataBuilder.buildTestAccount(1, usr.Id);
             insert accObj;

             Contact conObj2 = TestDataBuilder.buildTestContact(1, usr.Id, accObj.id);
             conObj2.Email = 'TUser2@mathworks.com';
           	 insert conObj2;
            
             User usr2 = TestDataBuilder.buildTestUser(2); //This user record will have email: 'TUser2@mathworks.com'
             insert usr2;
             
             Contact conObj3 = TestDataBuilder.buildTestContact(2, usr.Id, accObj.id);
             conObj3.Email = 'TUser3@mathworks.com';
           	 insert conObj3;
             
             User usr3 = TestDataBuilder.buildTestUser(3); //This user record will have email: 'TUser3@mathworks.com'
             insert usr3;
             
             
             Id CourseRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Course__c') AND (RecordType.Name ='Training') LIMIT 1].Id;
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             courseObj.RecordTypeId = CourseRecordtypeId;
             CourseObj.Course_Code__c = 'TEST';
             CourseObj.Status__c = 'Active';
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
             
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt != null);
             
             Id ClassRecordtypeId = [Select Id From RecordType Where (SobjectType = 'Class__c') AND (RecordType.Name ='Distance Learning') LIMIT 1].Id;
                         
             Class__c classObj =CTrainingTestDataBuilder.buildTestClass(0,courseObj.Id,langObj.Id);
             classObj.RecordTypeId = ClassRecordtypeId; 
             classObj.Course_Code__c = 'TEST';
             classObj.Class_Format__c = 'Instructor Led Online';
             classObj.Primary_Instructor__c = conObj2.id; 
             insert classObj;
             
             Class__c classupd = [Select Id, Primary_Instructor__c, Instructor_User__c,primary_instructor_email__c From Class__c Where Id =:classObj.Id];
             classupd.Primary_Instructor__c = conObj3.id; 
             
             test.startTest();
             
             update classupd;

			test.stopTest();
             
             Class__c classinstupd = [Select Id, Primary_Instructor__c, Instructor_User__c,primary_instructor_email__c From Class__c Where Id =:classObj.Id];
			 System.assertEquals(classinstupd.Instructor_User__c,usr3.Id ); 
             
             classinstupd.Primary_Instructor__c = null;
             update classinstupd;
             
             Class__c classinstnull = [Select Id, Primary_Instructor__c, Instructor_User__c,primary_instructor_email__c From Class__c Where Id =:classinstupd.Id];
			 System.assertEquals(classinstnull.Instructor_User__c,null ); 
             
             
         }
     }
    
       /*
    @ name    afterUpdateClassTest
    @ date     30 June 2015
    @ author  Abhay Verma
    @ param   none.
    @ return  Void. 
    @ description :Expected that on insertion and updatation of class the class automatically create Training Agreement Class Relationship Object Record .
     */              
     
    private static testMethod void afterUpdateClassTest(){
             //Inserting Bypass trigger custom setting
             custsettbuild.buildBypassTriggerSettings();
             //Inserting Training Agreement Settings
             custsettingsbuild.buildTrainingAgreementSettings(); 
             List<Training_Agreement_Class_Relationship__c> taClsRelLst = new  List<Training_Agreement_Class_Relationship__c>();
             List<Training_Agreement_Class_Relationship__c> taClsRelUpdatedLst = new  List<Training_Agreement_Class_Relationship__c>();
             //Create test user
             User usr = TestDataBuilder.buildTestUser(1);
             insert usr;
             System.runas(usr){
             
             Integer i;
             
             List<Enterprise_Training_Agreement__c> eTrainAgmntLst = new List<Enterprise_Training_Agreement__c>();
             //Quering the Record Id for the Unlimited record Type.
             Id etraAgrerecTypeId = [Select Id From RecordType Where (SobjectType = 'Enterprise_Training_Agreement__c') AND (RecordType.Name ='Unlimited') LIMIT 1].Id;
             
             //creating the Test data using Test data Builder.
             for(i=0; i<=10; i++){
                Enterprise_Training_Agreement__c etaObj = CTrainingTestDataBuilder.buildTestETAgreement(i);   
                etaObj.recordTypeId = etraAgrerecTypeId;
                etaObj.Term_Start_Date__c = date.Today() - 5;
                etaObj.Term_End_Date__c = date.Today() + 10;
                eTrainAgmntLst.add(etaObj); 
             }
             insert eTrainAgmntLst;
             
             Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
             insert courseObj;
             Course__c courseInt = [Select Id, Name From Course__c where id =: courseObj.Id];
             System.assert(courseInt != null);
                         
             //create Language__c record from CTrainingTestDataBuilder.
             Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(1);
             insert langObj;
             Language__c langInt = [Select Id from Language__c where id =:langObj.Id];
             System.assert(langInt  != null);
             
             //Quering the Record Id for Seld-paced RecordType.
             Id recTypeId = [Select Id From RecordType  Where (SobjectType = 'Class__c') AND (RecordType.Name ='Self-Paced') LIMIT 1].Id;
             List<Class__c> clssLst = new List<Class__c>();
             
             //creating the Test data using Test data Builder.
             for(i=0; i<=10; i++){
                 Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(i, courseObj.Id, langObj.Id);
                 //Putting the Record Id.
                 clssObj.RecordTypeId= recTypeId;
                 clssLst.add(clssObj);
             }
           
            //Counting the Size of Class and Training Agreement Class Relationship Object List.
            Integer clssLstSize = clssLst.size();
            Integer etAggremntLstSize = eTrainAgmntLst.size();
            
            //Test Start
            test.startTest();
            insert clssLst;
            Training_Agreement_Settings__c  trainingAgreementObj = [Select Id,Auto_Create_Class_Association__c  From Training_Agreement_Settings__c  where Auto_Create_Class_Association__c = false ];
            if(trainingAgreementObj.Auto_Create_Class_Association__c){
                //Quering the Training Agreement Class Relationship. 
                taClsRelLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c WHERE class__c IN: clssLst AND Enterprise_Training_Agreement__c IN: eTrainAgmntLst];
                //Asserting Training Agreement Class Realation Object Record must be equal to product of Class and Enterprise Training Agreement Object Record.
                System.assertEquals(clssLstSize*etAggremntLstSize, taClsRelLst.size()); 
            }
            else{
                //Quering the Training Agreement Class Relationship. 
                 taClsRelLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c WHERE class__c IN: clssLst AND Enterprise_Training_Agreement__c IN: eTrainAgmntLst];
                //Asserting Training Agreement Class Realation Object Record must be equal to product of Class and Enterprise Training Agreement Object Record.
                System.assertEquals(0, taClsRelLst.size());
            }
            //Stop Test.
            test.stopTest();
             
            //Change the Status of the Class to Inavtive. 
            for(Class__c clsObj : clssLst){
                clsObj.Status__c = 'Inactive';
            }
            //Update the Class List. 
            update clssLst;
            
            //Asserting if the Status of the Class Object is Inactive. 
            for(Class__c clsObj : clssLst){
                System.assertEquals(clsObj.Status__c, 'Inactive');
            }
            
            //Change and Update of Class Object to Active.  
            for(Class__c clsObj : clssLst){
                clsObj.Status__c = 'Active';
            }
            //update Class Object List. 
            update clssLst;
            
            Training_Agreement_Settings__c  trainingAgreementUpdateObj = [Select Id,Auto_Create_Class_Association__c  From Training_Agreement_Settings__c  where Auto_Create_Class_Association__c = false ];
            if(trainingAgreementUpdateObj.Auto_Create_Class_Association__c){
                //Quering the Training Agreement Class Relationship. 
                taClsRelUpdatedLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c WHERE class__c IN: clssLst AND Enterprise_Training_Agreement__c IN: eTrainAgmntLst];
                //Asserting Training Agreement Class Realation Object Record must be equal to product of Class and Enterprise Training Agreement Object Record.
                System.assertEquals(clssLstSize*etAggremntLstSize, taClsRelUpdatedLst.size()); 
            }
            else{
                //Quering the Training Agreement Class Relationship. 
                taClsRelUpdatedLst = [SELECT Id, class__c, Enterprise_Training_Agreement__c FROM Training_Agreement_Class_Relationship__c WHERE class__c IN: clssLst AND Enterprise_Training_Agreement__c IN: eTrainAgmntLst];
                //Asserting Training Agreement Class Realation Object Record must be equal to product of Class and Enterprise Training Agreement Object Record.
                System.assertEquals(0, taClsRelUpdatedLst.size()); 
            }
            
    }//End of System.runas()
     
   }//End of Method.
     
}