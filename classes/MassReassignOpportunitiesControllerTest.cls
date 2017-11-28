/*
 *    @description: tests the MassReassignOpportunitiesController
 */ 
@isTest(seeAllData=true)/*for Territory2 object*/
public with sharing class MassReassignOpportunitiesControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    /*
    @ name    testReassign
    @ date    6.August.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :This method tests assigning opportunity to new user
     */ 
    public static testmethod void testReassignWithTask(){
        
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();

        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Sales Manager'; //SS 3/16/2016 Added to exclude the opp auto assignment process on creation
        insert usr;

        System.runAs(usr){   

            //Create Dummy Data
            createDummyDataWithTask(usr); 

            MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();

            Test.startTest();
            
            System.debug(usr.id+'inserted user id');
            System.debug(UserInfo.getUserId()+'UserInfo.getUserId()');
            
            //Enter Search Criteria
            controller.searchRecord.stageName = 'Discover';
            controller.searchRecord.name = 'testOpty';
            controller.helperRecord.ClosedDate_From__c=System.today();
            controller.helperRecord.ClosedDate_To__c=System.today()+2;
            controller.helperRecord.From__c=System.today();
            controller.helperRecord.To__c=System.today()+1;
            controller.searchRecord.Type = 'testType';
            controller.searchRecord.ownerId = usr.id;
            controller.searchRecordByAccountFields.name = 'TestAccount123';
            controller.searchRecordByAccountFields.Territory_name__c = 'testTerritoryUpdated';
            
            
            controller.refreshOptyListBySearch();

            System.assert(controller.optyList.size()>0);

            controller.optyList[0].selected = true;
            
            //Insert new User to assign
            User usrTest = TestDataBuilder.buildTestUser(2);
            insert usrTest;
            
            
            
            //Assign new user to Opportunity
            controller.helperRecord.Assign_to__c = usrTest.id;
            controller.Assign();
            
        
            //Check whether new user has been assigned to opporunity
            Opportunity optyToTest= [select id,ownerId
                                     from Opportunity 
                                     where ownerid=:usrTest.id limit 1];
            
            System.assert(optyToTest!=null);
            
            Task taskToTest= [select id,ownerId
                                     from Task 
                                     where ownerid=:usrTest.id limit 1];
                                     
            System.assert(taskToTest.ownerid!=UserInfo.getUserId());
            

            Test.stopTest();

        }


    }

    /*
    @ name    createDummyDataWithTask
    @ date    6.August.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :This method creates Dummy Contact and Dummy Account
     */ 
    private static void createDummyDataWithTask(User usr){

        //Create Dummy Data
        Integer index=0;



        //***********Insert Territory2*****************//
        Territory2Type typeTest=[select id from Territory2Type limit 1];

        Territory2Model territory2Model=[select id,state from Territory2Model where state='Active' limit 1];


        //create Territory record from TestDataBuilder
        Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(index);
        dummyTerritory2.Siebel_Territory_ID__c='1-New'+index;
        dummyTerritory2.Master_Territory_ID__c = 'TM-New' +index;
        dummyTerritory2.DeveloperName='dev1'+index;
        dummyTerritory2.Global_Region__c='International';
        dummyTerritory2.Region__c='omer';
        dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
        dummyTerritory2.Office__c='Componentes Electronicas Ltda';
        dummyTerritory2.Office_Channel__c='Indirect';
        dummyTerritory2.Territory_Industry__c='UNKNOWN';
        dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
        dummyTerritory2.Territory_Sales_Group__c='Latin America';
        dummyTerritory2.Name='testTerritoryUpdated';
        dummyTerritory2.CaseAccessLevel='Edit';


        dummyTerritory2.Territory2ModelId=territory2Model.id;

        dummyTerritory2.Territory2TypeId=typeTest.id;

        insert dummyTerritory2;


        Account accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.CDS_Account_Id__c='c12345';
        accObj.name='TestAccount123';
        accObj.siebel_territory_id__c='1-New'+index;
        accObj.Master_Territory_ID__c = 'TM-New' +index;


        insert accObj;

        Opportunity testOpty = new Opportunity();
        testOpty.StageName = 'Discover';
        testOpty.CloseDate = System.today()+1;
        testOpty.AccountId=accObj.Id;
        testOpty.Name='testOpty';
        testOpty.Type = 'testType';
        testOpty.ownerId = usr.id;
        insert testOpty;
       
        Task taskObj = TestDataBuilder.buildTestTask(UserInfo.getUserId(),'In Progress','TO DO', 'call');
            taskObj.Priority='ASAP';
            taskObj.whatid=testOpty.Id;
            insert taskObj;

    }
    
    /*
    @ name    testReassign
    @ date    6.August.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :This method tests assigning opportunity to new user
     */ 
    public static testmethod void testReassignWithActivity(){
        
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();

        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   

            Test.startTest();
            
            //Create Dummy Data
            createDummyDataWithActivity(usr); 

            MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();

           
            
            //Enter Search Criteria
            controller.searchRecord.stageName = 'Discover';
            controller.searchRecord.name = 'testOpty1';
            controller.helperRecord.ClosedDate_From__c=System.today();
            controller.helperRecord.ClosedDate_To__c=System.today()+2;
            controller.helperRecord.From__c=System.today();
            controller.helperRecord.To__c=System.today()+1;
            controller.searchRecord.Type = 'testType1';
            //controller.searchRecord.ownerId = usr.id;
            controller.searchRecordByAccountFields.name = 'TestAccount123';
            controller.searchRecordByAccountFields.territory_name__c= 'testTerritoryUpdated';
            
            
            controller.refreshOptyListBySearch();

            System.assert(controller.optyList.size()>0);

            controller.optyList[0].selected = true;
            
            //Insert new User to assign
            User usrTest = TestDataBuilder.buildTestUser(2);
            insert usrTest;
            
            
            
            //Assign new user to Opportunity
            controller.helperRecord.Assign_to__c = usrTest.id;
            controller.Assign();
            
        
            //Check whether new user has been assigned to opporunity
            Opportunity optyToTest= [select id,ownerId
                                     from Opportunity 
                                     where ownerid=:usrTest.id limit 1];
            
            System.assert(optyToTest!=null);
            
            List<Event> eventToTest= [select id,ownerId
                                     from Event 
                                     where ownerid=:usrTest.id limit 1];
                                     
          
            System.assert(eventToTest!=null);

            Test.stopTest();

        }


    }


/*
    @ name    createDummyDataWithActivity
    @ date    12.December.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :This method creates Dummy Contact and Dummy Account
     */ 
    private static void createDummyDataWithActivity(User usr){

        //Create Dummy Data
        Integer index=0;



        //***********Insert Territory2*****************//
        Territory2Type typeTest=[select id from Territory2Type limit 1];

        Territory2Model territory2Model=[select id,state from Territory2Model where state='Active' limit 1];


        //create Territory record from TestDataBuilder
        Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(index);
        dummyTerritory2.Siebel_Territory_ID__c='1-New'+index;
        dummyTerritory2.Master_Territory_ID__c = 'TM-New' +index;
        dummyTerritory2.DeveloperName='dev1'+index;
        dummyTerritory2.Global_Region__c='International';
        dummyTerritory2.Region__c='omer';
        dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
        dummyTerritory2.Office__c='Componentes Electronicas Ltda';
        dummyTerritory2.Office_Channel__c='Indirect';
        dummyTerritory2.Territory_Industry__c='UNKNOWN';
        dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
        dummyTerritory2.Territory_Sales_Group__c='Latin America';
        dummyTerritory2.Name='testTerritoryUpdated';
        dummyTerritory2.CaseAccessLevel='Edit';


        dummyTerritory2.Territory2ModelId=territory2Model.id;

        dummyTerritory2.Territory2TypeId=typeTest.id;

        insert dummyTerritory2;


        Account accObj = TestDataBuilder.buildTestAccount(index,UserInfo.getUserId());
        accObj.BillingCity ='Rio De Janeiro';
        accObj.BillingCountryCode = 'US';
        accObj.BillingCountry = 'United States';
        accObj.BillingStateCode = 'NY';
        accObj.BillingState = 'New York';
        accObj.CDS_Account_Id__c='c12345';
        accObj.name='TestAccount123111';
        accObj.siebel_territory_id__c='1-New'+index;
        accObj.Master_Territory_ID__c = 'TM-New' +index;


        insert accObj;
        
        List<Account> newAccount = new List<Account>([SELECT Id, Territory_Name__c FROM Account WHERE Id =: accObj.Id]);
        
        System.assertEquals('testTerritoryUpdated', newAccount[0].Territory_Name__c);
        
        Opportunity testOpty = new Opportunity();
        testOpty.StageName = 'Discover';
        testOpty.CloseDate = System.today()+1;
        testOpty.AccountId=accObj.Id;
        testOpty.Name='testOpty1';
        testOpty.Type = 'testType1';
        testOpty.ownerId = UserInfo.getUserId();
        insert testOpty;
       
        Event eventObj = TestDataBuilder.buildTestEvent(UserInfo.getUserId(),'call');
        eventObj.whatid=testOpty.Id;
        insert eventObj;
       
    }     


}