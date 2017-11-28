@isTest(seeAlldata=true) 
public class Territory2DmlMasterTest {

public static Integer index=0;
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    static testMethod void SyncTerritoryFieldsToAccTest() { 

        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildTerritorySettingsMaster();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        

            //intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Territory2> territoryLstNew =new List<Territory2>();
            List<Territory2> territoryLstToUpdate =new List<Territory2>();
            List<Territory2> territoryListToUpdate =new List<Territory2>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            List<Account> AcctList = new List<Account>();
            //Instantiate SiebelTerritoryIdToTerritory2
            Map<String,Territory2>TerritoryIdToTerritory2=new map<String,Territory2>();
        
            Territory2Model model;
             System.runAs(usr){ 
             
            //***********Insert Territory2*****************//
            Territory2Type typeTest=[select id,DeveloperName from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }


            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<2;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-New'+i;
                dummyTerritory2.DeveloperName='dev1'+i;
                dummyTerritory2.Global_Region__c='International';
                dummyTerritory2.Region__c='omer';
                dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office__c='Componentes Electronicas Ltda';
                dummyTerritory2.Office_Channel__c='Indirect';
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                dummyTerritory2.Name='testTerritoryUpdated'+i;
                dummyTerritory2.caseAccessLevel='Edit';
                dummyTerritory2.is_Active__c = true;//fg
                dummyTerritory2.Master_Territory_ID__c = 'TM-'+i; //fg
                dummyTerritory2.Unique_Master_Territory__c = dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg

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


            //***********Insert Account*****************//
            for(Integer i=0;i<2;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='1-New'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                accL.Master_Territory_Id__c ='TM-'+i;//fg
                
                accLLst.add(accL);  

            }

            insert accLLst;
                 System.debug('Faina test account master TerritoryId' + accLLst);

            //***********Update Territory2*****************//
             //Territory2Type territoryTypeObj = [select id,DeveloperName from Territory2Type where Id != typeTest.Id ];
              Territory2Type territoryTypeObj =[select id,DeveloperName from Territory2Type where Id !=: typeTest.Id limit 1];
            for(Integer i=0;i<2;i++){

                Territory2 dummyTerritory2=territoryLstNew[i];
                
                dummyTerritory2.DeveloperName='developer'+i;
                dummyTerritory2.Global_Region__c='International__updated';
                dummyTerritory2.Region__c='omer_updated';
                dummyTerritory2.Office_Group__c='Componentes Electronicas Ltda__updated';
                dummyTerritory2.Office__c='Componentes Electronicas Ltda__updated';
                dummyTerritory2.Office_Channel__c='Indirect__updated';
                dummyTerritory2.Territory_Industry__c='UNKNOWN__updated';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America__updated';
                dummyTerritory2.Name='testTerritory__updated'+i;
                dummyTerritory2.Territory_Sector__c = 'TestTerritorySector';
                dummyTerritory2.Territory2TypeId = territoryTypeObj.Id;
                dummyTerritory2.is_Active__c = false;//fg
                dummyTerritory2.Siebel_Territory_ID__c='1-New'+i;

                territoryLstToUpdate.add(dummyTerritory2);

            }
            //update Territory2
            update territoryLstToUpdate;
            territoryListToUpdate = [Select Id,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,
                                Territory_Industry__c,Territory_Sales_Group__c,Territory_Sales_Team_Type__c,
                                name,Territory_Sector__c,Territory2Type.MasterLabel,Siebel_Territory_ID__c,Territory2TypeId,Master_Territory_ID__c,Unique_Master_Territory__c,Include_In_Sales_Hierarchy__c//fg,hw
                                 From Territory2 where Id In: territoryLstToUpdate];
                 //fg
                 System.debug('Faina' +territoryListToUpdate);
                 //fg
            if(territoryListToUpdate!= NULL && !territoryListToUpdate.isEmpty()){

                //Form a map of siebelTerritoryId to Territory2  
                for(Territory2 territoryObj:territoryListToUpdate){

                    if(territoryObj.Master_Territory_ID__c!=null && territoryObj.Master_Territory_ID__c!=''){

                        TerritoryIdToTerritory2.put(territoryObj.Master_Territory_ID__c,territoryObj);

                    } 
                }
            }
            
            test.startTest();
            
          //  Territory2Dml objBatch = new Territory2Dml(TerritoryIdToTerritory2);
            Territory2DmlMaster objBatch = new Territory2DmlMaster(TerritoryIdToTerritory2);
            
            QL = objBatch.start(bc);
            
            Database.QueryLocatorIterator QIT =  QL.iterator();
            
              while (QIT.hasNext())
                {
                    Account Acc = (Account)QIT.next();           
                    System.debug(Acc);
                    AcctList.add(Acc);
                }        
             objBatch.execute(BC, AcctList);
             objBatch.finish(BC); 
            
            
            //Verify that values are reflected to account records
            List<Account> accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Siebel_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c,
                                        Account_Territory_Sector__c,Account_Territory_Type__c,Master_Territory_id__c //fg
                                      From Account where id=:accLLst];

            //Query Inserted Territory2 Objects
            map<id,territory2> terMap=new map<id,territory2>([select id,Siebel_Territory_ID__c,Global_Region__c,Region__c,
                                                              Office_Group__c,Office__c,Office_Channel__c,
                                                              Territory_Industry__c,Territory_Sales_Group__c,
                                                              Territory_Sales_Team_Type__c,Name ,Territory_Sector__c,Territory2Type.MasterLabel, Master_Territory_id__c //fg
                                                              from territory2 where Territory2Model.state='Active' and id in:territoryLstToUpdate]);

            for(Account acc:accTocheck){

                    if(terMap.get(acc.Salesforce_Territory_Id__c)!=null && terMap.get(acc.Salesforce_Territory_Id__c).Master_Territory_ID__c==acc.Master_Territory_ID__c){

                        territory2 ter=terMap.get(acc.Salesforce_Territory_Id__c);
                        
                        //Asserts to check that fields are properly populated
                        System.assertEquals(ter.Territory_Sales_Team_Type__c,acc.Territory_Sales_Team_Type__c);
                        System.assertEquals(ter.Territory_Sales_Group__c,acc.Territory_Sales_Group__c);
                        System.assertEquals(ter.name,acc.Territory_Name__c);
                        System.assertEquals(ter.Territory_Industry__c,acc.Territory_Industry__c);
                        System.assertEquals(ter.Siebel_Territory_ID__c,acc.Siebel_Territory_ID__c);
                        System.assertEquals(ter.id,acc.Salesforce_Territory_Id__c);
                        System.assertEquals(ter.Office__c,acc.Office__c);
                        System.assertEquals(ter.Office_Group__c,acc.Office_Group__c);
                        System.assertEquals(ter.Office_Channel__c,acc.Office_Channel__c);
                        System.assertEquals(ter.Global_Region__c,acc.Global_Region__c);
                        System.assertEquals(ter.Region__c,acc.Region__c);
                        System.assertEquals(ter.Territory_Sector__c,acc.Account_Territory_Sector__c);
                        System.assertEquals(ter.Territory2Type.MasterLabel,acc.Account_Territory_Type__c);
                        System.assertEquals(ter.Master_Territory_id__c,acc.Master_Territory_ID__c);//fg
                    
                }

            }
            
            test.stopTest();

        }
}
}