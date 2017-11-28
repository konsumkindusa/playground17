/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified:
 *@date Original: 29 Feb 2016, Last Modified: 
 *@description This  is a Test class for 'TerritoryRuleCriteriaComponentController' . 
 *@Revision:
 */

@isTest
public class TerritoryRuleCriteriaComponentCtrlTest{

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
    @testSetup static void insertTestData() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        //Creating Test user
        User usr = TestDataBuilder.buildTestUser(100);
        //inserting user.
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
            
        }//End of RunAs(Usr)
    }//End of @testSetup


    /*
      @name         territoryRuleCriteriaComponentTest
      @date         29.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       pageReference. 
      @description  Method to test the functionality of edit method in 'TerritoryRuleCriteriaComponentController'. 
        */  

    private static testMethod void territoryRuleCriteriaComponentTest(){
        
        
        //create test User
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        
        System.runAs(usr){
            //Inserting Bypass trigger custom setting
            custsettbuild.buildBypassTriggerSettings();
            
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
            
            //Creating the Territory Assignment Rule test data.
            Territory_Assignment_Rule__c assignmentRuleObj = new  Territory_Assignment_Rule__c();
            assignmentRuleObj.Territory__c = shadowObj.Id;
            
            //Inserting the assignment rule.
            insert assignmentRuleObj;
            
            //Fetching all the record type Id of Territory Rule Criteria Object.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Name').getRecordTypeId();
            Id accountPostalCodeRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Postal Code').getRecordTypeId();
            Id accountCityRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account City').getRecordTypeId();
            Id accountCountryCodeRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Country Code').getRecordTypeId();
            Id accountSectorRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Sector').getRecordTypeId();
            Id accountStateCodeRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account State Code').getRecordTypeId();
            
            //List to store the Territory Rule Criteria Object test Record
            List<Territory_Rule_Criteria__c> TRCList = new List<Territory_Rule_Criteria__c>();
            
            //Creating theTerritory Rule Criteria Test data.
            for(Integer i=0;i<=199;i++){
                Territory_Rule_Criteria__c territoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Territory Criteria ' +i, assignmentRuleObj.Id);
            
                //Assigning the different record type to different test data records.
                if(i<=34){
                    territoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
                }
                else if(34<i && i<=69){
                    territoryCriteriaObj.RecordTypeId = accountPostalCodeRecTypeId;
                }
                else if(70<i && i<=104){
                    territoryCriteriaObj.RecordTypeId = accountCityRecTypeId;
                }
                if(104<i && i<=139){
                    territoryCriteriaObj.RecordTypeId = accountCountryCodeRecTypeId;
                }
                else if(139<i && i<=174){
                    territoryCriteriaObj.RecordTypeId = accountSectorRecTypeId;
                }
                else{
                    territoryCriteriaObj.RecordTypeId = accountStateCodeRecTypeId;
                }
                TRCList.add(territoryCriteriaObj);
            }
            
            //Inserting the Territory Rule Criteria List.
            insert TRCList;  
            
            //Querying the Territory Rule Criteria List.
            List<Territory_Rule_Criteria__c> insertedTerritoryCriteriaLst = [SELECT Id, Required__c, Score__c, Territory_Assignment_Rule__c FROM Territory_Rule_Criteria__c WHERE Id IN: TRCList];
            
            //Asserting the Territory Rule Criteria List to get inserted or not.
            System.assertEquals(insertedTerritoryCriteriaLst.size(), 200, true);
            
            //Start test
            test.startTest(); 
            
            TerritoryRuleCriteriaComponentController criteriaControllerObj = new TerritoryRuleCriteriaComponentController();
            
            criteriaControllerObj.territoryRuleCriteriaObj = insertedTerritoryCriteriaLst[0];
            criteriaControllerObj.territoryShadowId = shadowObj.Id;
            criteriaControllerObj.territoryRuleCriteriaLst = insertedTerritoryCriteriaLst;
            criteriaControllerObj.territoryRuleCriteriaId = insertedTerritoryCriteriaLst[0].Id;
            criteriaControllerObj.ruleObjId = assignmentRuleObj.Id;
            criteriaControllerObj.criteriaObjId = insertedTerritoryCriteriaLst[0].Id; 
            criteriaControllerObj.show = True;
            
            criteriaControllerObj.getTerritoryRuleCriteriaList();
            //Asserting the territory rule criteria list is populating on the territory summary page.
            System.AssertEquals(criteriaControllerObj.getTerritoryRuleCriteriaList().size(), 200, True);
            
            criteriaControllerObj.getCriteriaValueObjs();
            
            criteriaControllerObj.newTerritoryCriteria();
            criteriaControllerObj.editCriteriaObj();
            
            //Get the url when the Edit link is clicked.
            String nextPage= criteriaControllerObj.editCriteriaObj().getUrl();
            //Asserting if the User redirect to the expected territory rule criteria value page or not.
            System.assertEquals(nextPage,'/'+insertedTerritoryCriteriaLst[0].Id+'/e?isdtp=vw&retURL=%2Fapex%2FTerritorysummary%3Fid%3D'+shadowObj.Id, True);
            
            criteriaControllerObj.deleteCriteriaRule();
            //Querying the Territory Rule Criteria Object to get the Deleted Rule Criteria Record.
            List<Territory_Rule_Criteria__c> deletedTerritoryRuleCriterialst = [SELECT Id FROM Territory_Rule_Criteria__c WHERE ID =:insertedTerritoryCriteriaLst[0].Id];
            //Asserting if the record is deleted or not.
            System.assertEquals(deletedTerritoryRuleCriterialst.size(), 0, True);
            
            
            //Stop Test         
            test.stopTest();
        }//End of Run as User  
    }//End of Method
    
    
    private static testMethod void NoterritoryRuleCriteriaFoundTest(){
        
        
        //create test User
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        
        System.runAs(usr){
            //Inserting Bypass trigger custom setting
            custsettbuild.buildBypassTriggerSettings();
            
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
            
            //Creating the Territory Assignment Rule test data.
            Territory_Assignment_Rule__c assignmentRuleObj = new  Territory_Assignment_Rule__c();
            assignmentRuleObj.Territory__c = shadowObj.Id;
            
            //Inserting the assignment rule.
            insert assignmentRuleObj;
            
            //Start test
            test.startTest(); 
            
            TerritoryRuleCriteriaComponentController criteriaControllerObj = new TerritoryRuleCriteriaComponentController();
            
            criteriaControllerObj.territoryRuleCriteriaObj = null;
            criteriaControllerObj.territoryShadowId = shadowObj.Id;
            criteriaControllerObj.territoryRuleCriteriaLst = null;
            criteriaControllerObj.territoryRuleCriteriaId = null;
            criteriaControllerObj.ruleObjId = assignmentRuleObj.Id;
            criteriaControllerObj.criteriaObjId = null; 
            criteriaControllerObj.show = True;
            criteriaControllerObj.getTerritoryRuleCriteriaList();
            criteriaControllerObj.getCriteriaValueObjs();
            criteriaControllerObj.editCriteriaObj();
            criteriaControllerObj.newTerritoryCriteria();
            criteriaControllerObj.deleteCriteriaRule();
            
            //Asserting the territory rule criteria list is not presented on the territory summary page.
            System.AssertEquals(criteriaControllerObj.getTerritoryRuleCriteriaList(), null, True);
            //Stop Test         
            test.stopTest();
        }//End of Run as User  
    }//End of Method
    
     
}//End of Class