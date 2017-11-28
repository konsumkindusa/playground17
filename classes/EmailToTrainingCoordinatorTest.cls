/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *date Original: 8 July 2016, Last Modified: 8 July 2016
 *description This  is test class for UserT2ATriggerHandler   
 */

@isTest
public class EmailToTrainingCoordinatorTest {
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    static CTrainingCustomSettingBuilder cTrainSettingBuilder = new CTrainingCustomSettingBuilder();
    private static final Integer LANG_COUNT = 2;
    private static final Integer ETAREEMENT_COUNT = 200;
    private static final Integer CONTACT_COUNT = 200;
    /***
    @ name    sendEmailToCoordinatorTest
    @ date    18 Feb 2016
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description : Method for test the for send Mail functionality for Training Coordinator.
    ***/
    public testMethod static void sendEmailToCoordinatorTest() {
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Inside Sales Rep';
        insert usr;
        User uObj = [Select Id,Functional_Role__c  From User Where Id =:usr.Id limit 1];
        
        System.assertEquals(uObj.Functional_Role__c,'Inside Sales Rep');
            System.runAs(usr){
                cTrainSettingBuilder.buildEnrollmentCodeConfiguration();
                List<Territory2> territory2Lst =new List<Territory2>();
                List<Territory2> territory2List=new List<Territory2>();
                List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
                List<Territory2> territory2LstTest =new List<Territory2>();
                Territory2Model model;

                Territory2Type typeTest=[select id from Territory2Type limit 1];

                territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

                if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                    model=TestDataBuilder.buildTestTerritory2Model(0);
                    insert model;

                }

                //create Territory record from TestDataBuilder.
                for(Integer i=0;i<199;i++){

                    Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);         
                    dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                    dummyTerritory2.name='TestTerritory';
                    dummyTerritory2.DeveloperName='AMER'+i;
                    dummyTerritory2.Global_Region__c='International';
                    dummyTerritory2.Region__c='omer';
                    dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
                    dummyTerritory2.Office__c='Componentes Electronicas Ltda';
                    dummyTerritory2.Office_Channel__c='Indirect';
                    dummyTerritory2.Territory_Industry__c='UNKNOWN';
                    dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                    dummyTerritory2.Territory_Sales_Group__c='Latin America';


                    if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){

                        dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                    }
                    else
                    {
                        dummyTerritory2.Territory2ModelId=model.id;
                    }
                    dummyTerritory2.Territory2TypeId=typeTest.id;

                    territory2Lst.add(dummyTerritory2);
                }

                insert territory2Lst;
                System.assertEquals(territory2Lst.isEmpty(),false);  
                
                List<UserTerritory2Association> userT2AList = new List<UserTerritory2Association>();
                //create Territory record from TestDataBuilder.
                for(Integer i=0;i<199;i++){
                    UserTerritory2Association userT2aObj = TestDataBuilder.buildTestUserterritory2Association(usr.Id,territory2Lst[i].Id);
                    userT2aObj.RoleInTerritory2 = 'Sales Rep Primary';
                    userT2AList.add(userT2aObj);
                }
                insert userT2AList;
                System.assertEquals(userT2AList.isEmpty(),false);
                List<UserTerritory2Association> userT2ATestList = new List<UserTerritory2Association>();
                userT2ATestList = [Select Id,RoleInTerritory2,UserId,Territory2Id From UserTerritory2Association where Id In:userT2AList];
                System.assertEquals(userT2ATestList.isEmpty(),false);
                //Inserting Bypass trigger custom setting
             List<Language__c> langLst = new List<Language__c>();
            
            //create Language__c record from CTrainingTestDataBuilder.
            for(Integer i=0; i<LANG_COUNT; i++){
                Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                langObj.SF_ISO_Code__c = (i==0 ? 'en_US' : 'ko');
                langObj.Language_Code__c='ENU';
                langLst.add(langObj);
            }
            insert langLst;
            
            List<Account> accountList = new List<Account>();
            for(Integer i=0; i<199; i++){ 
                Account acc = TestDataBuilder.buildTestAccount(i, usr.Id);
                acc.Salesforce_Territory_Id__c = territory2Lst[i].Id;
                accountList.add(acc);
            }
            insert accountList ;
                    
            List<Contact> conList = new List<Contact>();
            for(Integer i=0; i<199; i++){  
                Contact con = TestDataBuilder.buildTestContact(i, usr.Id, accountList[i].Id); 
                con.email = 'test'+i+'@test.com';
                conList.add(con);
            }
            insert conList;
           
            //Creating the Enterprise_Training_Agreement__c test data.
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<199;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c eTAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                ETAgreementObj.Max_Seats__c = 1;
                ETAgreementObj.Primary_Contact__c = conList[i].Id;
                ETAgreementObj.Account_Name__c = accountList[i].id;
                ETagreeemntLst.add(ETAgreementObj);
            }
            insert ETagreeemntLst;
            system.assertEquals(ETagreeemntLst.isEmpty(),false);
            //EmailTotrainingCoordinator cls = new EmailTotrainingCoordinator();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(ETagreeemntLst[0]);
            EmailToTrainingCoordinator controller = new EmailToTrainingCoordinator(standardCtrlCon);
            controller.SendActivationMail();
            controller.isRenewalEmail = false;
            list<Task> tskList = [Select id From Task where status ='Completed'];
            System.assertEquals(tskList.isEmpty(),false);
            System.assertEquals(tskList.size(),1);
            //controller.SendRenewalMail();
            }
    }
    /***
    @ name    sendEmailToCoordinatorTest
    @ date    18 Feb 2016
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description : Method for test the for send Mail functionality for Training Coordinator.
    ***/
    public testMethod static void sendEmailToCoordinatorForRenewalTest() {
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Inside Sales Rep';
        insert usr;
        User uObj = [Select Id,Functional_Role__c  From User Where Id =:usr.Id limit 1];
        
        System.assertEquals(uObj.Functional_Role__c,'Inside Sales Rep');
            System.runAs(usr){
                cTrainSettingBuilder.buildEnrollmentCodeConfiguration();
                List<Territory2> territory2Lst =new List<Territory2>();
                List<Territory2> territory2List=new List<Territory2>();
                List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
                List<Territory2> territory2LstTest =new List<Territory2>();
                Territory2Model model;

                Territory2Type typeTest=[select id from Territory2Type limit 1];

                territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

                if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                    model=TestDataBuilder.buildTestTerritory2Model(0);
                    insert model;

                }

                //create Territory record from TestDataBuilder.
                for(Integer i=0;i<199;i++){

                    Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);         
                    dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                    dummyTerritory2.name='TestTerritory';
                    dummyTerritory2.DeveloperName='AMER'+i;
                    dummyTerritory2.Global_Region__c='International';
                    dummyTerritory2.Region__c='omer';
                    dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
                    dummyTerritory2.Office__c='Componentes Electronicas Ltda';
                    dummyTerritory2.Office_Channel__c='Indirect';
                    dummyTerritory2.Territory_Industry__c='UNKNOWN';
                    dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                    dummyTerritory2.Territory_Sales_Group__c='Latin America';


                    if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){

                        dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                    }
                    else
                    {
                        dummyTerritory2.Territory2ModelId=model.id;
                    }
                    dummyTerritory2.Territory2TypeId=typeTest.id;

                    territory2Lst.add(dummyTerritory2);
                }

                insert territory2Lst;
                System.assertEquals(territory2Lst.isEmpty(),false);  
                
                List<UserTerritory2Association> userT2AList = new List<UserTerritory2Association>();
                //create Territory record from TestDataBuilder.
                for(Integer i=0;i<199;i++){
                    UserTerritory2Association userT2aObj = TestDataBuilder.buildTestUserterritory2Association(usr.Id,territory2Lst[i].Id);
                    userT2aObj.RoleInTerritory2 = 'Sales Rep Primary';
                    userT2AList.add(userT2aObj);
                }
                insert userT2AList;
                System.assertEquals(userT2AList.isEmpty(),false);
                List<UserTerritory2Association> userT2ATestList = new List<UserTerritory2Association>();
                userT2ATestList = [Select Id,RoleInTerritory2,UserId,Territory2Id From UserTerritory2Association where Id In:userT2AList];
                System.assertEquals(userT2ATestList.isEmpty(),false);
                //Inserting Bypass trigger custom setting
             List<Language__c> langLst = new List<Language__c>();
            
            //create Language__c record from CTrainingTestDataBuilder.
            for(Integer i=0; i<LANG_COUNT; i++){
                Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(i);
                langObj.SF_ISO_Code__c = (i==0 ? 'en_US' : 'ko');
                langObj.Language_Code__c='ENU';
                langLst.add(langObj);
            }
            insert langLst;
            
            List<Account> accountList = new List<Account>();
            for(Integer i=0; i<199; i++){ 
                Account acc = TestDataBuilder.buildTestAccount(i, usr.Id);
                acc.Salesforce_Territory_Id__c = territory2Lst[i].Id;
                accountList.add(acc);
            }
            insert accountList ;
                    
            List<Contact> conList = new List<Contact>();
            for(Integer i=0; i<199; i++){  
                Contact con = TestDataBuilder.buildTestContact(i, usr.Id, accountList[i].Id); 
                con.email = 'test'+i+'@test.com';
                conList.add(con);
            }
            insert conList;
           
            //Creating the Enterprise_Training_Agreement__c test data.
            List<Enterprise_Training_Agreement__c> ETagreeemntLst = new List<Enterprise_Training_Agreement__c>();
            for(Integer i=0;i<199;i++){
                //Create Test Data for Enterprise Training Agreement
                Enterprise_Training_Agreement__c eTAgreementObj = CTrainingTestDataBuilder.buildTestETAgreement(i);
                Id etraAgrerecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
                ETAgreementObj.recordTypeId = etraAgrerecTypeId;
                ETAgreementObj.Max_Seats__c = 1;
                ETAgreementObj.Primary_Contact__c = conList[i].Id;
                ETAgreementObj.Account_Name__c = accountList[i].id;
                ETagreeemntLst.add(ETAgreementObj);
            }
            insert ETagreeemntLst;
            system.assertEquals(ETagreeemntLst.isEmpty(),false);
            //EmailTotrainingCoordinator cls = new EmailTotrainingCoordinator();
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(ETagreeemntLst[0]);
            EmailToTrainingCoordinator controller = new EmailToTrainingCoordinator(standardCtrlCon);
            controller.isRenewalEmail = true;
            controller.SendRenewalMail();
            list<Task> tskList = [Select id From Task where status ='Completed'];
            System.assertEquals(tskList.isEmpty(),false);
            System.assertEquals(tskList.size(),1);
            }
    }
}