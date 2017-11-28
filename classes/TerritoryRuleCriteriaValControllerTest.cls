/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original:20 Jan 2016, Last Modified: 20 Jan 2016
 *@description:This is a Test class for TerritoryRuleCriteriaValuesController class.
 */
@isTest
public class TerritoryRuleCriteriaValControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
    /***
    @ name    insertTestData
    @ date    20.Jan.2016
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
    @ name    saveTerritoryRuleCriteriaValueTest
    @ date    20.Jan.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing saveTerritoryRuleCriteriaValueAccountNameTest save
    ***/
    private testMethod static void saveTerritoryRuleCriteriaValueAccountNameTest() {
        
        //get Territory_Rule_Criteria__c record
        Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
         
        Territory_Assignment_Rule__c ruleObj = TestDataBuilder.buildTerritoryAssignmentRule(shadowObj.id);
        insert ruleObj;
        
        Territory_Rule_Criteria__c criteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('testCriteria',ruleObj.id);
        insert criteriaObj;  
       
        //set current page 
        PageReference redirectPage= Page.TerritoryRuleCriteriaValuesRedirectPage;
        Test.setCurrentPage(redirectPage);
        
        System.currentPageReference().getParameters().put('retURL', '/'+criteriaObj.id);
        Territory_Rule_Criteria_value__c valueObj = new Territory_Rule_Criteria_value__c();
        valueObj.Territory_Rule_Criteria__c = criteriaObj.id;
        valueObj.Score__c=100;
       
        ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(valueObj);
        TerritoryRuleCriteriaValuesController controller = new TerritoryRuleCriteriaValuesController(standardCtrlCon);

        controller.sController = standardCtrlCon;
        controller.theData.countryCode = 'IN';
        controller.theData.stateCode = 'MH';
        controller.theData.stateName = 'Maharashtra';
        controller.theData.countryName = 'India';
        controller.saveCustom();
        
        List<Territory_Rule_Criteria_value__c>  valuelst = new List<Territory_Rule_Criteria_value__c>();
        valuelst = [select id,Score__c,Country_Code__c,state_code__c from Territory_Rule_Criteria_value__c where Territory_Rule_Criteria__c=:criteriaObj.id];
            
        system.assert(valuelst[0]!=null);
        system.assertEquals(valuelst[0].Score__c,100);          
       
    }   
    
        /***
    @ name    saveTerritoryRuleCriteriaValueForAccountCountryCodeTest
    @ date    8.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing TerritoryRuleCriteriaValue ForAccountCountryCode Record Type save
    ***/
    private testMethod static void saveTerritoryRuleCriteriaValueForAccountCountryCodeTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
             
            Territory_Assignment_Rule__c ruleObj = TestDataBuilder.buildTerritoryAssignmentRule(shadowObj.id);
            insert ruleObj;
            
            Territory_Rule_Criteria__c criteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('testCriteria',ruleObj.id);
            RecordType rt = [select id,Name from RecordType where SobjectType='Territory_Rule_Criteria__c' and DeveloperName='Account_Country_Code' Limit 1];
            criteriaObj.recordTypeid = rt.id;
            insert criteriaObj; 
            
            system.debug(criteriaObj);
            
            //set current page 
            PageReference redirectPage= Page.TerritoryRuleCriteriaValuesRedirectPage;
            Test.setCurrentPage(redirectPage);
            
            System.currentPageReference().getParameters().put('retURL', '/'+criteriaObj.id);
            Territory_Rule_Criteria_value__c valueObj = new Territory_Rule_Criteria_value__c();
            valueObj.Territory_Rule_Criteria__c = criteriaObj.id;
            valueObj.Score__c=100;
            insert valueObj;
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(valueObj);
            TerritoryRuleCriteriaValuesController controller = new TerritoryRuleCriteriaValuesController(standardCtrlCon);
    
            controller.sController = standardCtrlCon;
            
            controller.saveCustom();
            
            List<Territory_Rule_Criteria_value__c>  valuelst = new List<Territory_Rule_Criteria_value__c>();
            valuelst = [select id,Score__c,Country_Code__c,state_code__c from Territory_Rule_Criteria_value__c where Territory_Rule_Criteria__c=:criteriaObj.id];
                
            system.assert(valuelst[0]!=null);
            system.assertEquals(valuelst[0].Score__c,100);
            
        }
    }   
    
        /***
    @ name    saveTerritoryRuleCriteriaValueForAccountStateCodeTest
    @ date    8.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing TerritoryRuleCriteriaValue For AccountStateCode Record Type save
    ***/
    private testMethod static void saveTerritoryRuleCriteriaValueForAccountStateCodeTest() {
        
        User usr = TestDataBuilder.buildTestUser(100);
        insert usr;
        
        System.runAs(usr){
        
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
             
            Territory_Assignment_Rule__c ruleObj = TestDataBuilder.buildTerritoryAssignmentRule(shadowObj.id);
            insert ruleObj;
            
            Territory_Rule_Criteria__c criteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('testCriteria',ruleObj.id);
            RecordType rt = [select id,Name from RecordType where SobjectType='Territory_Rule_Criteria__c' and DeveloperName='Account_State_Code' Limit 1];
            criteriaObj.recordTypeid = rt.id;
            insert criteriaObj; 
            
            system.debug(criteriaObj);
            
            //set current page 
            PageReference redirectPage= Page.TerritoryRuleCriteriaValuesRedirectPage;
            Test.setCurrentPage(redirectPage);
            
            System.currentPageReference().getParameters().put('retURL', '/'+criteriaObj.id);
            Territory_Rule_Criteria_value__c valueObj = new Territory_Rule_Criteria_value__c();
            valueObj.Territory_Rule_Criteria__c = criteriaObj.id;
            valueObj.Score__c=100;
            valueObj.state_code__c='MH';
            valueObj.State_LongName__c='Maharashtra';
            valueObj.Country_Code__c='IN';
            valueObj.Country_LongName__c='India';
            insert valueObj;
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(valueObj);
            TerritoryRuleCriteriaValuesController controller = new TerritoryRuleCriteriaValuesController(standardCtrlCon);
    
            controller.sController = standardCtrlCon;
            controller.theData.countryCode = 'IN';
            controller.theData.stateCode = 'MH';
            controller.theData.stateName = 'Maharashtra';
            controller.theData.countryName = 'India';
            controller.saveCustom();
            
            List<Territory_Rule_Criteria_value__c>  valuelst = new List<Territory_Rule_Criteria_value__c>();
            valuelst = [select id,Score__c,Country_Code__c,state_code__c from Territory_Rule_Criteria_value__c where Territory_Rule_Criteria__c=:criteriaObj.id];
                
            system.assert(valuelst[0]!=null);
            system.assertEquals(valuelst[0].Score__c,100);
            
        }
    }   
    
    /***
    @ name    updateTerritoryRuleCriteriaValueTest
    @ date    8.Feb.2016
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description : Method for testing TerritoryRuleCriteriaValue Update
    ***/
    private testMethod static void updateTerritoryRuleCriteriaValueTest() {
        
        //get Territory_Rule_Criteria__c record
        Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
         
        Territory_Assignment_Rule__c ruleObj = TestDataBuilder.buildTerritoryAssignmentRule(shadowObj.id);
        insert ruleObj;
        
        Territory_Rule_Criteria__c criteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('testCriteria',ruleObj.id);
        insert criteriaObj;  
        
        //set current page 
        PageReference redirectPage= Page.TerritoryRuleCriteriaValuesRedirectPage;
        Test.setCurrentPage(redirectPage);
        System.currentPageReference().getParameters().put('retURL', '/'+criteriaObj.id);
       
        Territory_Rule_Criteria_value__c valueObj = new Territory_Rule_Criteria_value__c();
        valueObj.Territory_Rule_Criteria__c = criteriaObj.id;
        valueObj.Score__c=100;
        insert valueObj;
        
        System.currentPageReference().getParameters().put('ID',valueObj.id);
        
        ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(valueObj);
        TerritoryRuleCriteriaValuesController controller = new TerritoryRuleCriteriaValuesController(standardCtrlCon);

        controller.sController = standardCtrlCon;
        system.debug(controller.saveCustom().getUrl());
        system.assertEquals(controller.saveCustom().getUrl(),'/'+criteriaObj.id);      
        
    }   
}