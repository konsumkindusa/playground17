/***************************************************************************************
 * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
 * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
 * description This batch claremaiss feth the dupilcate records and keeps one record and
 * delete the other duplicate records
 *
 ****************************************************************************************/
@isTest 
public class ObjectT2AssociationBatchClassTest {

    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele 
     * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
     * description This methods test for accounts that are associated with multiple territory records then it 
     * checks for account and get that territoryid and delete the other ObjectTerritory2Association records.
     ****************************************************************************************/
    static testMethod void deleteDuplicateAccountForObjectTerritory2Association() { 
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        LIST<AggregateResult> territoryToAccountList = new LIST<AggregateResult>();
        LIST<AggregateResult> territoryToAccountDeleteLst = new LIST<AggregateResult>();
        set<Id> accountIdSet = new set<Id>();
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        List<Account> accLLst =new List<Account>();
        List<Territory2> territoryLstNew =new List<Territory2>();
        List<Account> AcctList = new List<Account>();
         List<Account> accUpdatedList = new List<Account>();
         Territory2Model model;
           Database.QueryLocator QL;
        Database.BatchableContext BC;
        System.runAs(usr){ 
             
            //***********Insert Territory2*****************//
            Territory2Type typeTest=[select id,DeveloperName from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }


            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<200;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-latest'+i;
                dummyTerritory2.DeveloperName='dev11'+i;
                dummyTerritory2.Global_Region__c='International';
                dummyTerritory2.Region__c='omer';
                dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office_Channel__c='Indirect';
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                dummyTerritory2.Name='testTerritoryModified'+i;
                dummyTerritory2.caseAccessLevel='Edit';

                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){

                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;

                territoryLstNew.add(dummyTerritory2);
            }

            insert territoryLstNew;
            system.debug('***territoryLstNew**'+territoryLstNew);
            System.assertEquals(200,territoryLstNew.size());
            List<Territory2> tObjList = new List<Territory2>();
            tObjList = [Select Id From Territory2 where Id In:territoryLstNew];
            system.assertEquals(tObjList.size(),200);
            
            //***********Insert Account*****************//
            for(Integer i=0;i<200;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'testAcc' + i;
                accL.Siebel_Territory_ID__c= '1-latest'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                accLLst.add(accL);  

            }

            insert accLLst;
            System.assertEquals(200,accLLst.size());
           
            accUpdatedList = [Select Id,Siebel_Territory_ID__c  From Account where Id In:accLLst];
            
            List<ObjectTerritory2Association> objT2AList = new List<ObjectTerritory2Association> ();
               ObjectTerritory2Association objT2A = TestDataBuilder.buildObjectTerritory2Association(tObjList[0].Id,accUpdatedList[6].Id);
                objT2AList.add(objT2A); 
           
            insert objT2AList;
            //Account acc = [Select Id,Salesforce_Territory_Id__c  From Account where Id =:accLLst[0].Id];
            System.assertEquals(1,objT2AList.size());
        }
        Test.StartTest();
        territoryToAccountList = [Select count(Id),ObjectId From ObjectTerritory2Association  group by  objectId having count(Id) > 1 ];
        for(AggregateResult aggrObj : territoryToAccountList){
            accountIdSet.add((Id)aggrObj.get('ObjectId'));
        }
        System.assertEquals(1,territoryToAccountList.size());
        System.assertEquals(1,accountIdSet.size());
        List<ObjectTerritory2Association> t2List = new List<ObjectTerritory2Association>();
        t2List = [Select Id,Territory2Id,ObjectId From ObjectTerritory2Association where ObjectId IN:accountIdSet And Territory2Id != null];
        //System.assertEquals(1,t2List.size());
        System.assertEquals(true,t2List[0].Territory2Id!= null);
        
        ObjectTerritory2AssociationBatchClass batchObj = new ObjectTerritory2AssociationBatchClass();
        Database.executeBatch(batchObj);
        Test.StopTest();
         territoryToAccountDeleteLst = [Select count(Id),ObjectId From ObjectTerritory2Association  group by  objectId having count(Id) > 1 ];
         system.assertEquals(territoryToAccountDeleteLst.size(),0);
    }
}