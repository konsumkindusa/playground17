/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik - AtTask
 *@date Original:24 Feb 2016, Last Modified: 24 Feb 2016
 *@description:This is a Test class for TerritorySummaryController class.
 */
@isTest
public class TerritorySummaryControllerTest {
    
     //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

     /***
    @ name    insertTestData
    @ date    24.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for inserting test data 
    ***/
    @testSetup static void insertTestData() {
        
           //Inserting Bypass trigger custom setting
           custsettbuild.buildBypassTriggerSettings();
        
           User usr = TestDataBuilder.buildTestUser(1);
           insert usr;
        
           System.runAs(usr){
        
            List<Territory2> territory2Lst =new List<Territory2>();
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
            for(Integer i=0;i<1;i++){

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
                dummyTerritory2.is_Active__c = true;// fg


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
          
        }
    }
    
     /***
    @ name    getTerritory2IdTest
    @ date    24.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  getTerritory2Id method
    ***/
    private testMethod static void getTerritory2IdTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
          
        
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);            
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
          
            controller.getTerritory2Id();
            
            system.assert(controller.territory2Id==shadowObj.Salesforce_Territory_ID__c);
            
        }
    }   
    
     /***
    @ name    redirectToTerritory2EditTest
    @ date    24.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  redirectToTerritory2Edit method
    ***/
    private testMethod static void redirectToTerritory2EditTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
          
        
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);            
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
          
            system.assert(controller.redirectToTerritory2Edit()!=null);
            
        }
    }   
    
    /***
    @ name    redirectToManageTerritoryUsersEditTest
    @ date    24.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  redirectToManageTerritoryUsersEdit method
    ***/
    private testMethod static void redirectToManageTerritoryUsersEditTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
          
        
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);            
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
            
            
            system.assert(controller.redirectToManageTerritoryUsersEdit()!=null);
          
        }
    }
    
    /***
    @ name    editAssignmentRuletest
    @ date    09.Mar.2016
    @ author  Neha Mahajan
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  editAssignmentRule method
    ***/
    private testMethod static void editAssignmentRuletest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
            
        
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);            
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
             controller.needreloadAgain=false;
             controller.isOnlyOneRule=false;
             controller.showCriteriaValue=true;
            system.debug(controller.editAssignmentRule());
            
        }
    }   

        
    
    /***
    @ name    deleteAssignmentRuletest
    @ date    09.Mar.2016
    @ author  Neha Mahajan
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  deleteAssignmentRule method
    ***/
    private testMethod static void deleteAssignmentRuletest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
             
            //Creating the Territory Assignment Rule test data.
            Territory_Assignment_Rule__c assignmentRuleObj = new  Territory_Assignment_Rule__c();
            assignmentRuleObj.Territory__c = shadowObj.Id;
            
            //Inserting the assignment rule.
            insert assignmentRuleObj;
        
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);           
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
            controller.assignmentRuleIdToEdit=assignmentRuleObj.id; 
            controller.deleteAssignmentRule();
            list<Territory_Assignment_Rule__c> assignObjLst=[select id from Territory_Assignment_Rule__c where id=:assignmentRuleObj.id limit 1];
            System.assertEquals(assignObjLst.size(),0);
        }
    }   
    
    

    /***
    @ name    newAssignmentRuleTest
    @ date    09.Mar.2016
    @ author  Neha Mahajan
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  newAssignmentRule method
    ***/
         private testMethod static void newAssignmentRuleTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
            
        
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);            
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
            
            controller.newAssignmentRule();
                        
        }
    }   
    
     /***
    @ name    getCriteriaObjsTest
    @ date    09.Mar.2016
    @ author  Neha Mahajan
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  getCriteriaObjs method
    ***/
         private testMethod static void getCriteriaObjsTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
            
            
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
           
            System.currentPageReference().getParameters().put('ID',shadowObj.id);       
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
            
            //Creating the Territory Assignment Rule test data.
            Territory_Assignment_Rule__c assignmentRuleObj = new  Territory_Assignment_Rule__c();
            assignmentRuleObj.Territory__c = shadowObj.Id;
            
            //Inserting the assignment rule.
            insert assignmentRuleObj;
            
            //Querying the Territory Assignment Rule Created
            Territory_Assignment_Rule__c assignmentRuleRecord = [SELECT Id FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            //Asserting assignemnt rule is created or not
            System.assertNotEquals(assignmentRuleRecord.Id, null, True);
            
            //Creating theTerritory Rule Criteria Test data.
            Territory_Rule_Criteria__c testTerritoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Test Territory Criteria ', assignmentRuleRecord.Id);
            
            //Fetching the Account Name Record Type Id.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Name').getRecordTypeId();
            //Assigning the Account Name Record Type Id to the Territory Rule Criteria Test Record.
            testTerritoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
            
            //Inserting Test Territory Rule Criteria Record.
            insert testTerritoryCriteriaObj;
            
            
            controller.getCriteriaObjs();
                        
        }
    }   

    
    /***
    @ name    getCriteriaValueObjsTest
    @ date    09.Mar.2016
    @ author  Neha Mahajan
    @ param   none.
    @ return  Void. 
    @ description : Method for testing  getCriteriaValueObjs method
    ***/
        private testMethod static void getCriteriaValueObjsTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory__c record
            Territory_Shadow__c shadowObj = [select id,Salesforce_Territory_ID__c from Territory_Shadow__c limit 1];
            
            //Creating the Territory Assignment Rule test data.
            Territory_Assignment_Rule__c assignmentRuleObj = new  Territory_Assignment_Rule__c();
            assignmentRuleObj.Territory__c = shadowObj.Id;
            
            //Inserting the assignment rule.
            insert assignmentRuleObj;
            
            //Querying the Territory Assignment Rule Created
            Territory_Assignment_Rule__c assignmentRuleRecord = [SELECT Id FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            //Asserting assignemnt rule is created or not
            System.assertNotEquals(assignmentRuleRecord.Id, null, True);
            
            //Creating theTerritory Rule Criteria Test data.
            Territory_Rule_Criteria__c testTerritoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Test Territory Criteria ', assignmentRuleRecord.Id);
            
            //Fetching the Account Name Record Type Id.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Name').getRecordTypeId();
            //Assigning the Account Name Record Type Id to the Territory Rule Criteria Test Record.
            testTerritoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
            
            //Inserting Test Territory Rule Criteria Record.
            insert testTerritoryCriteriaObj;
            
            //set current page 
            PageReference redirectPage= Page.Territorysummary;
            Test.setCurrentPage(redirectPage);           
            
            System.currentPageReference().getParameters().put('ID',shadowObj.id);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(shadowObj);
            TerritorySummaryController controller = new TerritorySummaryController(standardCtrlCon);
           
            controller.criteriaObjId=System.currentPageReference().getParameters().put('CriteriaId',testTerritoryCriteriaObj.id);  
           
            controller.getCriteriaValueObjs();
             System.assert(controller.ruleObjIdMatched==testTerritoryCriteriaObj.Territory_Assignment_Rule__c);
        
    }   

    }
}