/**
* @author Original: Neha Mahajan
* @date Original: 1 March 2016
* @description: This test class is to test the functionality of TerritoryRuleCriteriaValCompCC.
*/

@isTest
public class TerritoryRuleCriteriaValCompCCTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
    @testSetup static void insertTestData() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Territory Management custom Settings
        custsettbuild.buildTerritoryManagementSettings();
        
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
      @name         territoryRuleCriteriaValueComponentStateCodeTest
      @date         1.November.2017
      @author       Faina Gorelik
      @param        none.
      @return       List. 
      @description  Method to test the functionality of the territory Rule Criteria Value component for showing 
                    Country Code List 
        */ 
    
    public static testMethod void territoryRuleCriteriaValueComponentCountryCode(){
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        // Territory Management Custom Settings
        custsettbuild.buildTerritoryManagementSettings();
        
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
            
            //Querying the Territory Assignment Rule Created
            Territory_Assignment_Rule__c assignmentRuleRecord = [SELECT Id FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            //Asserting assignemnt rule is created or not
            System.assertNotEquals(assignmentRuleRecord.Id, null, True);
            
            //Creating theTerritory Rule Criteria Test data.
            Territory_Rule_Criteria__c testTerritoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Test Territory Criteria ', assignmentRuleRecord.Id);
            
            //Fetching the Account Name Record Type Id.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Country Code').getRecordTypeId();
            //Assigning the Account Name Record Type Id to the Territory Rule Criteria Test Record.
            testTerritoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
            
            //Inserting Test Territory Rule Criteria Record.
            insert testTerritoryCriteriaObj;
            
            //Querying the Territory Rule Criteria Record.
            Territory_Rule_Criteria__c territoryRuleCriteriaObj = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id =:testTerritoryCriteriaObj.Id];
            //Asserting if the test data is created or not.
            System.assertNotEquals(territoryRuleCriteriaObj.Id, null, True);
            
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //Creating the Territory Rule Criteria Value test record.
            for(Integer i=0;i<=9;i++){
                Territory_Rule_Criteria_Value__c TRCVObj = TestDataBuilder.buildTerritoryRuleCriteriaValue(testTerritoryCriteriaObj.Id);
                
                //Filling the different field as according to the different record type of Territory Rule Criteria.
                
               
                TRCVObj.Country_LongName__c= 'Azerbaijan';
                TRCVObj.Country_Code__c ='AZ';
                //Adding the Test records to the Territory Rule Criteria Value List
                TRCVList.add(TRCVObj);
            }
            //Inserting the Territory Rule Criteria value List.
            insert TRCVList;
            
            //Querying the Territory Rule Criteria value List
            //List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            System.assertEquals(insertedTRCVLst.size(),10, True);
            
            //start Test
            test.startTest();
                TerritoryRuleCriteriaValueComponentCC criteriaValueComponentObj = new TerritoryRuleCriteriaValueComponentCC();
                
                criteriaValueComponentObj.territoryRuleCriteriaValueLst = insertedTRCVLst;
                criteriaValueComponentObj.territoryRuleCriteriaId = territoryRuleCriteriaObj.Id;
                criteriaValueComponentObj.territoryRuleCriteriaValueId = insertedTRCVLst[0].Id;
                criteriaValueComponentObj.territoryShadowId = shadowObj.Id;
                criteriaValueComponentObj.getTerritoryRuleCriteriaValueList();
                criteriaValueComponentObj.newTerritoryCriteriaValue();
     
                //Asserting Territory Rule Criteria Value record. 
                System.assertEquals(criteriaValueComponentObj.getTerritoryRuleCriteriaValueList().size(), 10);
                
           
            //stop test
            test.stopTest();
            
        }//Run As User
    }
    
    /*
      @name         territoryRuleCriteriaValueComponentStateCodeTest
      @date         1.November.2017
      @author       Faina Gorelik
      @param        none.
      @return       List. 
      @description  Method to test the functionality of the territory Rule Criteria Value component for showing 
                    Account Postal Code List 
        */    
    
    public static testMethod void territoryRuleCriterValueComponentPostalCodeTest(){
         User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        // Territory Management Custom Settings
        custsettbuild.buildTerritoryManagementSettings();
        
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
            
            //Querying the Territory Assignment Rule Created
            Territory_Assignment_Rule__c assignmentRuleRecord = [SELECT Id FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            //Asserting assignemnt rule is created or not
            System.assertNotEquals(assignmentRuleRecord.Id, null, True);
            
            //Creating theTerritory Rule Criteria Test data.
            Territory_Rule_Criteria__c testTerritoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Test Territory Criteria ', assignmentRuleRecord.Id);
            
            //Fetching the Account Name Record Type Id.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account Postal Code').getRecordTypeId();
            //Assigning the Account Name Record Type Id to the Territory Rule Criteria Test Record.
            testTerritoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
            
            //Inserting Test Territory Rule Criteria Record.
            insert testTerritoryCriteriaObj;
            
            //Querying the Territory Rule Criteria Record.
            Territory_Rule_Criteria__c territoryRuleCriteriaObj = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id =:testTerritoryCriteriaObj.Id];
            //Asserting if the test data is created or not.
            System.assertNotEquals(territoryRuleCriteriaObj.Id, null, True);
            
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //Creating the Territory Rule Criteria Value test record.
            for(Integer i=0;i<=9;i++){
                Territory_Rule_Criteria_Value__c TRCVObj = TestDataBuilder.buildTerritoryRuleCriteriaValue(testTerritoryCriteriaObj.Id);
                
                //Filling the different field as according to the different record type of Territory Rule Criteria.
                
               
                TRCVObj.Postal_Code_Low__c = '10+i';

                //Adding the Test records to the Territory Rule Criteria Value List
                TRCVList.add(TRCVObj);
            }
            //Inserting the Territory Rule Criteria value List.
            insert TRCVList;
            
            //Querying the Territory Rule Criteria value List
            //List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            System.assertEquals(insertedTRCVLst.size(),10, True);
            
            //start Test
            test.startTest();
                TerritoryRuleCriteriaValueComponentCC criteriaValueComponentObj = new TerritoryRuleCriteriaValueComponentCC();
                
                criteriaValueComponentObj.territoryRuleCriteriaValueLst = insertedTRCVLst;
                criteriaValueComponentObj.territoryRuleCriteriaId = territoryRuleCriteriaObj.Id;
                criteriaValueComponentObj.territoryRuleCriteriaValueId = insertedTRCVLst[0].Id;
                criteriaValueComponentObj.territoryShadowId = shadowObj.Id;
                criteriaValueComponentObj.getTerritoryRuleCriteriaValueList();
                criteriaValueComponentObj.newTerritoryCriteriaValue();
     
                //Asserting Territory Rule Criteria Value record. 
                System.assertEquals(criteriaValueComponentObj.getTerritoryRuleCriteriaValueList().size(), 10);
                
           
            //stop test
            test.stopTest();
            
        }//Run As User
    }  
   /*
      @name         territoryRuleCriteriaValueComponentStateCodeTest
      @date         1.November.2017
      @author       Faina Gorelik
      @param        none.
      @return       List. 
      @description  Method to test the functionality of the territory Rule Criteria Value component for showing 
                    Account State Code List 
        */   
    public static testMethod void territoryRuleCriteriaValueComponentStateCodeTest(){
               //create test User
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        // Territory Management Custom Settings
        custsettbuild.buildTerritoryManagementSettings();
        
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
            
            //Querying the Territory Assignment Rule Created
            Territory_Assignment_Rule__c assignmentRuleRecord = [SELECT Id FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            //Asserting assignemnt rule is created or not
            System.assertNotEquals(assignmentRuleRecord.Id, null, True);
            
            //Creating theTerritory Rule Criteria Test data.
            Territory_Rule_Criteria__c testTerritoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Test Territory Criteria ', assignmentRuleRecord.Id);
            
            //Fetching the Account Name Record Type Id.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account State Code').getRecordTypeId();
            //Assigning the Account Name Record Type Id to the Territory Rule Criteria Test Record.
            testTerritoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
            
            //Inserting Test Territory Rule Criteria Record.
            insert testTerritoryCriteriaObj;
            
            //Querying the Territory Rule Criteria Record.
            Territory_Rule_Criteria__c territoryRuleCriteriaObj = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id =:testTerritoryCriteriaObj.Id];
            //Asserting if the test data is created or not.
            System.assertNotEquals(territoryRuleCriteriaObj.Id, null, True);
            
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //Creating the Territory Rule Criteria Value test record.
            for(Integer i=0;i<=9;i++){
                Territory_Rule_Criteria_Value__c TRCVObj = TestDataBuilder.buildTerritoryRuleCriteriaValue(testTerritoryCriteriaObj.Id);
                
                //Filling the different field as according to the different record type of Territory Rule Criteria.
                
               
                TRCVObj.Country_LongName__c = 'Australia';
                TRCVObj.State_LongName__c = 'New South Wales';
                TRCVObj.Score__c = i+1;
                //Adding the Test records to the Territory Rule Criteria Value List
                TRCVList.add(TRCVObj);
            }
            //Inserting the Territory Rule Criteria value List.
            insert TRCVList;
            
            //Querying the Territory Rule Criteria value List
            //List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            System.assertEquals(insertedTRCVLst.size(),10, True);
            
            //start Test
            test.startTest();
                TerritoryRuleCriteriaValueComponentCC criteriaValueComponentObj = new TerritoryRuleCriteriaValueComponentCC();
                
                criteriaValueComponentObj.territoryRuleCriteriaValueLst = insertedTRCVLst;
                criteriaValueComponentObj.territoryRuleCriteriaId = territoryRuleCriteriaObj.Id;
                criteriaValueComponentObj.territoryRuleCriteriaValueId = insertedTRCVLst[0].Id;
                criteriaValueComponentObj.territoryShadowId = shadowObj.Id;
                criteriaValueComponentObj.getTerritoryRuleCriteriaValueList();
                criteriaValueComponentObj.newTerritoryCriteriaValue();
     
                //Asserting Territory Rule Criteria Value record. 
                System.assertEquals(criteriaValueComponentObj.getTerritoryRuleCriteriaValueList().size(), 10);
                
           
            //stop test
            test.stopTest();
            
        }//Run As User
    }  
    
     /*
      @name         territoryRuleCriteriaValueComponentTest
      @date         1 Nov 2017
      @author       Faina Gorelik 
      @description  Method to test the functionality of the territory Rule Criteria Value component for showing 
                   city list of criteria value. 
        */  
    public static testMethod void territoryRuleCriteriaValueComponentCityTest(){
                       //create test User
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        // Territory Management Custom Settings
        custsettbuild.buildTerritoryManagementSettings();
        
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
            
            //Querying the Territory Assignment Rule Created
            Territory_Assignment_Rule__c assignmentRuleRecord = [SELECT Id FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            //Asserting assignemnt rule is created or not
            System.assertNotEquals(assignmentRuleRecord.Id, null, True);
            
            //Creating theTerritory Rule Criteria Test data.
            Territory_Rule_Criteria__c testTerritoryCriteriaObj = TestDataBuilder.buildTerritoryRuleCriteria('Test Territory Criteria ', assignmentRuleRecord.Id);
            
            //Fetching the Account Name Record Type Id.
            Id accountNameRecTypeId = Schema.SObjectType.Territory_Rule_Criteria__c.getRecordTypeInfosByName().get('Account City').getRecordTypeId();
            //Assigning the Account Name Record Type Id to the Territory Rule Criteria Test Record.
            testTerritoryCriteriaObj.RecordTypeId = accountNameRecTypeId;
            
            //Inserting Test Territory Rule Criteria Record.
            insert testTerritoryCriteriaObj;
            
            //Querying the Territory Rule Criteria Record.
            Territory_Rule_Criteria__c territoryRuleCriteriaObj = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id =:testTerritoryCriteriaObj.Id];
            //Asserting if the test data is created or not.
            System.assertNotEquals(territoryRuleCriteriaObj.Id, null, True);
            
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //Creating the Territory Rule Criteria Value test record.
            for(Integer i=0;i<=9;i++){
                Territory_Rule_Criteria_Value__c TRCVObj = TestDataBuilder.buildTerritoryRuleCriteriaValue(testTerritoryCriteriaObj.Id);
                
                //Filling the different field as according to the different record type of Territory Rule Criteria.
                
               
                TRCVObj.City__c = 'CityComponent'+ 1;
             
                //Adding the Test records to the Territory Rule Criteria Value List
                TRCVList.add(TRCVObj);
            }
            //Inserting the Territory Rule Criteria value List.
            insert TRCVList;
            
            //Querying the Territory Rule Criteria value List
            //List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            System.assertEquals(insertedTRCVLst.size(),10, True);
            
            //start Test
            test.startTest();
                TerritoryRuleCriteriaValueComponentCC criteriaValueComponentObj = new TerritoryRuleCriteriaValueComponentCC();
                
                criteriaValueComponentObj.territoryRuleCriteriaValueLst = insertedTRCVLst;
                criteriaValueComponentObj.territoryRuleCriteriaId = territoryRuleCriteriaObj.Id;
                criteriaValueComponentObj.territoryRuleCriteriaValueId = insertedTRCVLst[0].Id;
                criteriaValueComponentObj.territoryShadowId = shadowObj.Id;
                criteriaValueComponentObj.getTerritoryRuleCriteriaValueList();
                criteriaValueComponentObj.newTerritoryCriteriaValue();
     
                //Asserting Territory Rule Criteria Value record. 
                System.assertEquals(criteriaValueComponentObj.getTerritoryRuleCriteriaValueList().size(), 10);
                
           
            //stop test
            test.stopTest();
            
        }//Run As User
    }
    /*
      @name         territoryRuleCriteriaValueComponentTest
      @date         2.March.2016
      @author       Abhay Verma
      @param        none.
      @return       List. 
      @description  Method to test the functionality of the territory Rule Criteria Value component for showing 
                    delete and edit the list of criteria value. 
        */  
    public static testMethod void territoryRuleCriteriaValueComponentTest(){
        //create test User
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        // Territory Management Custom Settings
        custsettbuild.buildTerritoryManagementSettings();
        
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
            
            //Querying the Territory Rule Criteria Record.
            Territory_Rule_Criteria__c territoryRuleCriteriaObj = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id =:testTerritoryCriteriaObj.Id];
            //Asserting if the test data is created or not.
            System.assertNotEquals(territoryRuleCriteriaObj.Id, null, True);
            
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //Creating the Territory Rule Criteria Value test record.
            for(Integer i=0;i<=199;i++){
                Territory_Rule_Criteria_Value__c TRCVObj = TestDataBuilder.buildTerritoryRuleCriteriaValue(testTerritoryCriteriaObj.Id);
                
                //Filling the different field as according to the different record type of Territory Rule Criteria.
                TRCVObj.Account_Name__c = 'Test Account ' +i;
                TRCVObj.Location__c = 'Test Location' +i;
                TRCVObj.Country_LongName__c = 'India';
                TRCVObj.State_LongName__c = 'Maharashtra';
                //Adding the Test records to the Territory Rule Criteria Value List
                TRCVList.add(TRCVObj);
            }
            //Inserting the Territory Rule Criteria value List.
            insert TRCVList;
            
            //Querying the Territory Rule Criteria value List
            //List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            List<Territory_Rule_Criteria_Value__c> insertedTRCVLst = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN:TRCVList];
            System.assertEquals(insertedTRCVLst.size(),200, True);
            
            //start Test
            test.startTest();
                TerritoryRuleCriteriaValueComponentCC criteriaValueComponentObj = new TerritoryRuleCriteriaValueComponentCC();
                
                criteriaValueComponentObj.territoryRuleCriteriaValueLst = insertedTRCVLst;
                criteriaValueComponentObj.territoryRuleCriteriaId = territoryRuleCriteriaObj.Id;
                criteriaValueComponentObj.territoryRuleCriteriaValueId = insertedTRCVLst[0].Id;
                criteriaValueComponentObj.territoryShadowId = shadowObj.Id;
                criteriaValueComponentObj.getTerritoryRuleCriteriaValueList();
                criteriaValueComponentObj.newTerritoryCriteriaValue();
           		criteriaValueComponentObj.beginning();
            	criteriaValueComponentObj.next();
            	criteriaValueComponentObj.end();
            	criteriaValueComponentObj.previous();  
            	criteriaValueComponentObj.getprev();
            	criteriaValueComponentObj.getnxt();
            
                
                //Asserting Territory Rule Criteria Value record. 
                System.assertEquals(criteriaValueComponentObj.getTerritoryRuleCriteriaValueList().size(), 100);
                
                criteriaValueComponentObj.editCriteriaValueObj();
                //Get the url when the Edit link is clicked.
                String nextPage= criteriaValueComponentObj.editCriteriaValueObj().getUrl();
                //Asserting if the User redirect to the expected territory rule criteria value page or not.
                System.assertEquals(nextPage,'/'+insertedTRCVLst[0].Id+'/e?retURL=%2Fapex%2FTerritorysummary%3Fid%3D'+shadowObj.Id, True);
            
                criteriaValueComponentObj.deleteruleCriteriaValue();
                
                List<Territory_Rule_Criteria_Value__c> deletedRuleCriteriaValue = [SELECT Id,IsDeleted FROM Territory_Rule_Criteria_Value__c WHERE Id =:insertedTRCVLst[0].Id];
                //Asserting to check if the selected territory rule criteria value record is deleted or not.
                System.assertEquals(0, deletedRuleCriteriaValue.size());
                //Get the url when the Delete link is clicked.
                String deletePageUrl = criteriaValueComponentObj.deleteruleCriteriaValue().getUrl();
                //Asserting if the User redirect to the Territory Summary page or not.
                System.assertEquals(deletePageUrl,'/apex/Territorysummary?id='+shadowObj.Id+'&reload=true', True);
            //stop test
            test.stopTest();
            
        }//Run As User
    }//End of Method
    
    /*
      @name         noTerritoryRuleCriteriaFoundTest
      @date         2.March.2016
      @author       Abhay Verma
      @param        none.
      @return       List. 
      @description  Method to test the fucntionality of No Territory Rule Criteria Found in the component . 
        */  
    
    
    public static testMethod void noTerritoryRuleCriteriaFoundTest(){
        //create test User
        User usr = TestDataBuilder.buildTestUser(1);
        //insert test user.
        insert usr;
        
        System.runAs(usr){
            //Inserting Bypass trigger custom setting
            custsettbuild.buildBypassTriggerSettings();
            
            // insert Territory Management Custom Setting
            custsettbuild.buildTerritoryManagementSettings();
            
            //get Territory_Rule_Criteria__c record
            Territory_Shadow__c shadowObj = [select id from Territory_Shadow__c limit 1];
            
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
            
            //Querying the Territory Rule Criteria Record.
            Territory_Rule_Criteria__c territoryRuleCriteriaObj = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id =:testTerritoryCriteriaObj.Id];
            //Asserting if the test data is created or not.
            System.assertNotEquals(territoryRuleCriteriaObj.Id, null, True);
            
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //start test
            test.startTest();
                
                TerritoryRuleCriteriaValueComponentCC criteriaValueComponentObj = new TerritoryRuleCriteriaValueComponentCC();
                
                criteriaValueComponentObj.territoryRuleCriteriaValueLst = null;
                criteriaValueComponentObj.territoryRuleCriteriaId = territoryRuleCriteriaObj.Id;
                criteriaValueComponentObj.territoryRuleCriteriaValueId = null;
                criteriaValueComponentObj.territoryShadowId = shadowObj.Id;
                criteriaValueComponentObj.getTerritoryRuleCriteriaValueList();
                criteriaValueComponentObj.newTerritoryCriteriaValue();
                criteriaValueComponentObj.editCriteriaValueObj();
                criteriaValueComponentObj.deleteruleCriteriaValue();
                
                //Asserting Territory Criteria value List is Empty or not.
                System.assertEquals(criteriaValueComponentObj.getTerritoryRuleCriteriaValueList(), null);
           
            //stop test
            test.stopTest();
        }//Run As User
    }//End of Method
}//End of Class