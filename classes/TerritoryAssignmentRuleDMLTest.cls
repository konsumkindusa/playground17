/**
    * @author Original: Abhay Verma - Cloud Sherpas/Mathworks, 
    * @Last Modified by:
    * @date Original: 17 Feb 2016 
    * @LastModified Date :
    * @description :Test class for TerritoryAssignmentRuleDML
    */
    
@isTest
public class TerritoryAssignmentRuleDMLTest{
        
        
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
          @name         territoryRuleCriteriaAndCriteriaValueObjectCloningTest
          @date         17 Feb 2016
          @author       Abhay Verma
          @param        none.
          @return       Void. 
          @description  Check the functionality territoryRuleCriteriaAndCriteriaValueObjectCloning method
        */
    
    public static testMethod void territoryRuleCriteriaAndCriteriaValueObjectCloningTest(){
        
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
            List<Territory_Rule_Criteria__c> insertedTerritoryCriteiaLst = [SELECT Id FROM Territory_Rule_Criteria__c WHERE Id IN: TRCList];
            
            //Asserting the Territory Rule Criteria List to get inserted or not.
            System.assertEquals(insertedTerritoryCriteiaLst.size(), 200, true);
            
            //List to store the Territory Rule Criteria Value test record.
            List<Territory_Rule_Criteria_Value__c> TRCVList = new List<Territory_Rule_Criteria_Value__c>();
            
            //Creating the Territory Rule Criteria Value test record.
            for(Integer i=0;i<=199;i++){
                Territory_Rule_Criteria_Value__c TRCVObj = new Territory_Rule_Criteria_Value__c();
                TRCVObj.Territory_Rule_Criteria__c = TRCList[i].Id;
                
                //Filling the different field as according to the different record type of Territory Rule Criteria.
                if(TRCList[i].RecordTypeId == accountNameRecTypeId){
                    TRCVObj.Account_Name__c = 'Test Account ' +i;
                    TRCVObj.Location__c = 'Test Location' +i;
                    TRCVObj.Country_LongName__c = 'India';
                    TRCVObj.State_LongName__c = 'Maharashtra';
                }
                else if(TRCList[i].RecordTypeId == accountPostalCodeRecTypeId){
                    TRCVObj.Postal_Code_Low__c = '123'+i;
                    TRCVObj.Postal_Code_High__c = '321'+i;
                }
                else if(TRCList[i].RecordTypeId == accountCityRecTypeId){
                    TRCVObj.City__c = 'Mumbai';
                }
                else if(TRCList[i].RecordTypeId == accountCountryCodeRecTypeId){
                    TRCVObj.Country_LongName__c = 'India';
                }
                else if(TRCList[i].RecordTypeId == accountSectorRecTypeId){
                    TRCVObj.Sector__c = 'Government';
                }
                else if(TRCList[i].RecordTypeId == accountStateCodeRecTypeId){
                    TRCVObj.Country_LongName__c = 'India';
                    TRCVObj.State_LongName__c = 'Maharashtra';
                }
                if(i==0){
                        TRCVObj.Score__c = 1;
                }
                else{
                    TRCVObj.Score__c = i;
                }
                TRCVList.add(TRCVObj);
            }
            
            //Inserting the Territory Rule Criteria Value.
            insert TRCVList;
            
            //Querying the Territory Rule Criteria Value.
            List<Territory_Rule_Criteria_Value__c> insertedTerritoryCriteriaValueList = [SELECT Id FROM Territory_Rule_Criteria_Value__c WHERE Id IN: TRCVList];
            
            //Asserting of the Territory Rule Criteria Value List is inserted or not.
            System.assertEquals(insertedTerritoryCriteriaValueList.size(), 200, True);
            
            //Start Test
            test.startTest();
            
            //Querying the test territory Assignment rule record.
            Territory_Assignment_Rule__c assignmentRule = [SELECT Id,Territory__c FROM Territory_Assignment_Rule__c WHERE Id =: assignmentRuleObj.Id];
            
            //Cloning the Territory Assignment Rule Record.
            Territory_Assignment_Rule__c territoryAssignmentRuleObj = assignmentRule.clone(false, True);
            System.assert(territoryAssignmentRuleObj.isClone());
            //Inserting the Territory Assignment Rule Record
            insert territoryAssignmentRuleObj;
            
            //Asserting if the cloned Territory Assignment Rule record is inserted or not.
            System.assert(territoryAssignmentRuleObj.Id != null, True);
            
            List<Territory_Rule_Criteria__c> territoryCriteriaList = [SELECT Id, SourceId__c, Territory_Assignment_Rule__c, (SELECT Id FROM Territory_Rule_Criteria_Values__r) FROM Territory_Rule_Criteria__c WHERE Id IN:  insertedTerritoryCriteiaLst];
            List<Territory_Rule_Criteria__c> clonedTerritoryCriteriaList = [SELECT Id, SourceId__c, Territory_Assignment_Rule__c, (SELECT Id FROM Territory_Rule_Criteria_Values__r) FROM Territory_Rule_Criteria__c WHERE Territory_Assignment_Rule__c =: territoryAssignmentRuleObj.Id];
            List<Territory_Rule_Criteria_Value__c> clonedTerritoryCriteriaValueList = [SELECT Id, Territory_Rule_Criteria__c FROM Territory_Rule_Criteria_Value__c WHERE Territory_Rule_Criteria__c IN: clonedTerritoryCriteriaList];
            
            for(Integer i=0; i<=199; i++){
                if(clonedTerritoryCriteriaList[i].SourceId__c == territoryCriteriaList[i].Id){
                    //Asserting the Cloned Territory Criteria Object record have same number of child as of Original Territory Criteria Object record.
                    System.assertEquals((clonedTerritoryCriteriaList[i].Territory_Rule_Criteria_Values__r).size(), (territoryCriteriaList[i].Territory_Rule_Criteria_Values__r).size());
                }
            }
            //Asserting the Cloned Territory Criteria Object Record is created.
            System.assertEquals(clonedTerritoryCriteriaList.size(), 200, True);
            //Asserting the Cloned Territory Criteria Value Object Record is created.
            System.assertEquals(clonedTerritoryCriteriaValueList.size(), 200, True);
            
            //Stop Test.
            test.stopTest();
        }//End of Run as User
    }//End of Method
}//End of Class