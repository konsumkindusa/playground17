/*
 *    @description:Class to test the TerritoryAssignmentManager
 */ 
@isTest(seeAlldata=true) //see all data is needed because Territory Models are not creatable in tests yet (Dec 2014)
private class TerritoryAssignmentManagerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    

    /*
      @ name    testIfSalesforceTerritoryIdFoundInsert 
      @ date    23.July.2014
      @ author  Archana Lohar
      @ param   none.
      @ return  Void. 
      @ description Method to Implement test for assigning account to Territory 
                    if salesforce territory id found(Insert)                            
     */

    static testMethod void testIfSalesforceTerritoryIdFoundInsert() {
        
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
         //Inserting Bypass trigger custom setting
        csb.buildGenSetting();
        csb.buildTerritorySettings();
        csb.buildBypassTriggerSettings();
        System.runAs(usr){   

            //intialize all variable
            List<Account> accLLst =new List<Account>();
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
            for(Integer i=0;i<4;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);         
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.Master_Territory_ID__c='M-UIOPYU'+i;
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

            for(Integer i=0;i<4;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c=territory2Lst[i].Siebel_Territory_ID__c;
                accL.Master_Territory_ID__c=territory2Lst[i].Master_Territory_ID__c;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                
                accLLst.add(accL);  

            }

            test.startTest();
            

            insert accLLst;

            test.stopTest();

            //Query Updated Account object
            List<Account> accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Siebel_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c,
                                      Account_Territory_Sector__c,Account_Territory_Type__c
                                      From Account where id=:accLLst];



            //Query Inserted Territory2 Objects
            map<id,territory2> terMap=new map<id,territory2>([select id,Siebel_Territory_ID__c,Global_Region__c,Region__c,
                                                              Office_Group__c,Office__c,Office_Channel__c,
                                                              Territory_Industry__c,Territory_Sales_Group__c,
                                                              Territory_Sales_Team_Type__c,Name,
                                                              Territory_Sector__c,Territory2Type.MasterLabel
                                                              from territory2 where Territory2Model.state='Active' and id in:territory2Lst]);

            for(Account acc:accTocheck){

                Territory2 ter=terMap.get(acc.Salesforce_Territory_Id__c);

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


            }

            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoList=[select id,ObjectId from ObjectTerritory2Association 
                                                                  where ObjectId in:accLLst];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(territory2AssoList.size(),accLLst.size());

        }
    }

    /*
    @ name    testIfSalesforceTerritoryIdFoundUpdate 
    @ date    23.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description @ description Method to Implement test for assigning account to Territory 
                  if salesforce territory id found(Update)                 
     */

    static testMethod void testIfSalesforceTerritoryIdFoundUpdate() {

        csb.buildGenSetting();
        csb.buildTerritorySettings();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        System.runAs(usr){   

            //intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Account> accLLstUpdate =new List<Account>();
            List<Territory2> territory2Lst =new List<Territory2>();
            List<Territory2> territoryLstNew =new List<Territory2>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            List<Territory2> territory2LstTest =new List<Territory2>();
            Territory2Model model;



            for(Integer i=0;i<100;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                
                accLLst.add(accL);  

            }

            test.startTest();

            insert accLLst;

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }


            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<100;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                
                dummyTerritory2.Siebel_Territory_ID__c='1-Updated'+i;  
                dummyTerritory2.Master_Territory_ID__c='M-Updated'+i;  
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


            for(Integer i=0;i<100;i++){

                Account acc = accLLst[i];
               
                acc.Siebel_Territory_ID__c=territoryLstNew[i].Siebel_Territory_ID__c;
                acc.Master_Territory_ID__c=territoryLstNew[i].Master_Territory_ID__c;

                accLLstUpdate.add(acc);  

            }
            update accLLstUpdate;


            List<Account> accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Siebel_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c,
                                      Account_Territory_Sector__c,Account_Territory_Type__c
                                      From Account where id=:accLLstUpdate];
            
            //Query Inserted Territory2 Objects
            map<id,territory2> terMap=new map<id,territory2>([select id,Siebel_Territory_ID__c,Global_Region__c,Region__c,
                                                              Office_Group__c,Office__c,Office_Channel__c,
                                                              Territory_Industry__c,Territory_Sales_Group__c,
                                                              Territory_Sales_Team_Type__c,Name,
                                                              Territory_Sector__c,Territory2Type.MasterLabel
                                                              from territory2 where Territory2Model.state='Active' and id in:territoryLstNew]);

            for(Account acc:accTocheck){

                if(terMap.get(acc.Salesforce_Territory_Id__c)!=null){

                    if(terMap.get(acc.Salesforce_Territory_Id__c).Siebel_Territory_ID__c==acc.Siebel_Territory_ID__c){

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
                    }
                }

            }


            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoListV1=[select id,ObjectId from ObjectTerritory2Association 
                                                                    where ObjectId in:accLLst];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(territory2AssoListV1.size(),accLLst.size());

        }
    } 

    /*
    @ name    testIfSiebelTerritoryIdNotFoundInsert
    @ date    23.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test if siebel territory id not found on territory2 records                          
     */

    static testMethod void testIfSiebelTerritoryIdNotFoundInsert() {

        csb.buildGenSetting();
        csb.buildTerritorySettings();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   
            //intialize all variable
            List<Account> accLLstToInsert =new List<Account>();

            for(Integer i=0;i<3;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='1-OHJUY'+i;
                accL.Master_Territory_ID__c='M-OHJUY'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                
                accL.Global_Region__c='International';
                accL.Region__c='omer';
                accL.Office_Group__c='Componentes Electronicas Ltda';
                accL.Office__c='Componentes Electronicas Ltda';
                accL.Office_Channel__c='Indirect';
                accL.Territory_Industry__c='UNKNOWN';
                accL.Territory_Sales_Team_Type__c='Mixed';
                accL.Territory_Sales_Group__c='Latin America';
                accLLstToInsert.add(accL);


            }

            test.startTest();

            insert accLLstToInsert ;

            //Query Updated Account object
            List<Account> accTocheck=new  List<Account>();

            accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Siebel_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c
                                      From Account where id=:accLLstToInsert ];

            for(Account acc:accTocheck){

                //Asserts to check that fields are properly populated
                System.assertEquals(null,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(null,acc.Territory_Sales_Group__c);
                System.assertEquals(null,acc.Territory_Name__c);
                System.assertEquals(null,acc.Territory_Industry__c);
                System.assertEquals(acc.Siebel_Territory_ID__c,acc.Siebel_Territory_ID__c);
                System.assertEquals(null,acc.Office__c);
                System.assertEquals(null,acc.Office_Group__c);
                System.assertEquals(null,acc.Office_Channel__c);
                System.assertEquals(null,acc.Global_Region__c);
                System.assertEquals(null,acc.Region__c);

            }

            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoListTest=[select id,ObjectId from ObjectTerritory2Association 
                                                                      where ObjectId in:accTocheck];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(0,territory2AssoListTest.size());


            test.stopTest();
        }

    }

    /*
    @ name    testIfSiebelTerritoryIdNotFoundUpdate
    @ date    12.December.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test if siebel territory id not found on territory2 records                          
     */

    static testMethod void testIfSiebelTerritoryIdISNullUpdate() {

        csb.buildGenSetting();
        csb.buildTerritorySettings();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   
            //intialize all variable
            List<Account> accLLst =new List<Account>();

            for(Integer i=0;i<3;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='1-OHJUY'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                

                accLLst.add(accL);  

            }

            test.startTest();

            insert accLLst;

            //Query Updated Account object
            List<Account> accTocheck=new  List<Account>();

            accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Siebel_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c
                                      From Account where id=:accLLst];

            //Query Updated Account object
            List<Account> UpdateAccList=new  List<Account>();

            //Update Account records
            for(Account acc:accTocheck){

                acc.Siebel_Territory_ID__c=null;
                UpdateAccList.add(acc);
            }
            update UpdateAccList;

            test.stopTest();


            for(Account acc:accTocheck){

                //Asserts to check that fields are properly populated
                System.assertEquals(null,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(null,acc.Territory_Sales_Group__c);
                System.assertEquals(null,acc.Territory_Name__c);
                System.assertEquals(null,acc.Territory_Industry__c);
                System.assertEquals(null,acc.Office__c);
                System.assertEquals(null,acc.Office_Group__c);
                System.assertEquals(null,acc.Office_Channel__c);
                System.assertEquals(null,acc.Global_Region__c);
                System.assertEquals(null,acc.Region__c);

            }

            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoListTest=[select id,ObjectId from ObjectTerritory2Association 
                                                                      where ObjectId in:accLLst];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(0,territory2AssoListTest.size());


        }

    }
    
    /*
    @ name    testIfSiebelTerritoryIdNotFoundUpdate
    @ date    23.July.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test if siebel territory id not found on territory2 records                          
     */

    static testMethod void testIfSiebelTerritoryIdNotFoundUpdate() {

        csb.buildGenSetting();
        csb.buildTerritorySettings();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   
            //intialize all variable
            List<Account> accLLst =new List<Account>();

            for(Integer i=0;i<3;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='1-OHJUY'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';                

                accLLst.add(accL);  

            }

            test.startTest();

            insert accLLst;

            //Query Updated Account object
            List<Account> accTocheck=new  List<Account>();

            accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Siebel_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c
                                      From Account where id=:accLLst];

            //Query Updated Account object
            List<Account> UpdateAccList=new  List<Account>();

            //Update Account records
            for(Account acc:accTocheck){

                acc.Siebel_Territory_ID__c='TestTerritory';
                UpdateAccList.add(acc);
            }
            update UpdateAccList;

            test.stopTest();


            for(Account acc:accTocheck){

                //Asserts to check that fields are properly populated
                System.assertEquals(null,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(null,acc.Territory_Sales_Group__c);
                System.assertEquals(null,acc.Territory_Name__c);
                System.assertEquals(null,acc.Territory_Industry__c);
                System.assertEquals(acc.Siebel_Territory_ID__c,'TestTerritory');
                System.assertEquals(null,acc.Office__c);
                System.assertEquals(null,acc.Office_Group__c);
                System.assertEquals(null,acc.Office_Channel__c);
                System.assertEquals(null,acc.Global_Region__c);
                System.assertEquals(null,acc.Region__c);

            }


        }

    }

    /*
      @ name    testIfSalesforceTerritoryIdFoundInsertMaster 
	  @ date    15.Aug.2016
	  @ author  Haigang Wu
      @ param   none.
      @ return  Void. 
      @ description Method to Implement test for assigning account to Territory 
                    if salesforce territory id found(Insert)                            
     */

    static testMethod void testIfSalesforceTerritoryIdFoundInsertMaster() {
        
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
         //Inserting Bypass trigger custom setting
        csb.buildGenSetting();
        csb.buildTerritorySettingsMaster();
        csb.buildBypassTriggerSettings();
        System.runAs(usr){   

            //intialize all variable
            List<Account> accLLst =new List<Account>();
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
            for(Integer i=0;i<4;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);         
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.Master_Territory_ID__c='M-UIOPYU'+i;
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

            for(Integer i=0;i<4;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Master_Territory_ID__c=territory2Lst[i].Master_Territory_ID__c;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                
                accLLst.add(accL);  

            }

            test.startTest();
            

            insert accLLst;

            test.stopTest();

            //Query Updated Account object
            List<Account> accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Master_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c,
                                      Account_Territory_Sector__c,Account_Territory_Type__c
                                      From Account where id=:accLLst];



            //Query Inserted Territory2 Objects
            map<id,territory2> terMap=new map<id,territory2>([select id,Master_Territory_ID__c,Global_Region__c,Region__c,
                                                              Office_Group__c,Office__c,Office_Channel__c,
                                                              Territory_Industry__c,Territory_Sales_Group__c,
                                                              Territory_Sales_Team_Type__c,Name,
                                                              Territory_Sector__c,Territory2Type.MasterLabel
                                                              from territory2 where Territory2Model.state='Active' and id in:territory2Lst]);

            for(Account acc:accTocheck){

                Territory2 ter=terMap.get(acc.Salesforce_Territory_Id__c);

                //Asserts to check that fields are properly populated
                System.assertEquals(ter.Territory_Sales_Team_Type__c,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(ter.Territory_Sales_Group__c,acc.Territory_Sales_Group__c);
                System.assertEquals(ter.name,acc.Territory_Name__c);
                System.assertEquals(ter.Territory_Industry__c,acc.Territory_Industry__c);
                System.assertEquals(ter.Master_Territory_ID__c,acc.Master_Territory_ID__c);
                System.assertEquals(ter.id,acc.Salesforce_Territory_Id__c);
                System.assertEquals(ter.Office__c,acc.Office__c);
                System.assertEquals(ter.Office_Group__c,acc.Office_Group__c);
                System.assertEquals(ter.Office_Channel__c,acc.Office_Channel__c);
                System.assertEquals(ter.Global_Region__c,acc.Global_Region__c);
                System.assertEquals(ter.Region__c,acc.Region__c);
                System.assertEquals(ter.Territory_Sector__c,acc.Account_Territory_Sector__c);
                System.assertEquals(ter.Territory2Type.MasterLabel,acc.Account_Territory_Type__c);


            }

            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoList=[select id,ObjectId from ObjectTerritory2Association 
                                                                  where ObjectId in:accLLst];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(territory2AssoList.size(),accLLst.size());

        }
    }

    /*
    @ name    testIfSalesforceTerritoryIdFoundUpdateMaster 
    @ date    15.Aug.2016
    @ author  Haigang Wu
    @ param   none.
    @ return  Void. 
    @ description @ description Method to Implement test for assigning account to Territory 
                  if salesforce territory id found(Update)                 
     */

    static testMethod void testIfSalesforceTerritoryIdFoundUpdateMaster() {

        csb.buildGenSetting();
        csb.buildTerritorySettingsMaster();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        System.runAs(usr){   

            //intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Account> accLLstUpdate =new List<Account>();
            List<Territory2> territory2Lst =new List<Territory2>();
            List<Territory2> territoryLstNew =new List<Territory2>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            List<Territory2> territory2LstTest =new List<Territory2>();
            Territory2Model model;



            for(Integer i=0;i<100;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                
                accLLst.add(accL);  

            }

            test.startTest();

            insert accLLst;

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }


            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<100;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                
                dummyTerritory2.Siebel_Territory_ID__c='1-Updated'+i;  
                dummyTerritory2.Master_Territory_ID__c='M-Updated'+i;  
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


            for(Integer i=0;i<100;i++){

                Account acc = accLLst[i];
               
                acc.Master_Territory_ID__c=territoryLstNew[i].Master_Territory_ID__c;

                accLLstUpdate.add(acc);  

            }
            update accLLstUpdate;


            List<Account> accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Master_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c,
                                      Account_Territory_Sector__c,Account_Territory_Type__c
                                      From Account where id=:accLLstUpdate];
            
            //Query Inserted Territory2 Objects
            map<id,territory2> terMap=new map<id,territory2>([select id,Master_Territory_ID__c,Global_Region__c,Region__c,
                                                              Office_Group__c,Office__c,Office_Channel__c,
                                                              Territory_Industry__c,Territory_Sales_Group__c,
                                                              Territory_Sales_Team_Type__c,Name,
                                                              Territory_Sector__c,Territory2Type.MasterLabel
                                                              from territory2 where Territory2Model.state='Active' and id in:territoryLstNew]);

            for(Account acc:accTocheck){

                if(terMap.get(acc.Salesforce_Territory_Id__c)!=null){

                    if(terMap.get(acc.Salesforce_Territory_Id__c).Master_Territory_ID__c==acc.Master_Territory_ID__c){

                        territory2 ter=terMap.get(acc.Salesforce_Territory_Id__c);
                        //Asserts to check that fields are properly populated
                        System.assertEquals(ter.Territory_Sales_Team_Type__c,acc.Territory_Sales_Team_Type__c);
                        System.assertEquals(ter.Territory_Sales_Group__c,acc.Territory_Sales_Group__c);
                        System.assertEquals(ter.name,acc.Territory_Name__c);
                        System.assertEquals(ter.Territory_Industry__c,acc.Territory_Industry__c);
                        System.assertEquals(ter.Master_Territory_ID__c,acc.Master_Territory_ID__c);
                        System.assertEquals(ter.id,acc.Salesforce_Territory_Id__c);
                        System.assertEquals(ter.Office__c,acc.Office__c);
                        System.assertEquals(ter.Office_Group__c,acc.Office_Group__c);
                        System.assertEquals(ter.Office_Channel__c,acc.Office_Channel__c);
                        System.assertEquals(ter.Global_Region__c,acc.Global_Region__c);
                        System.assertEquals(ter.Region__c,acc.Region__c);
                        System.assertEquals(ter.Territory_Sector__c,acc.Account_Territory_Sector__c);
                        System.assertEquals(ter.Territory2Type.MasterLabel,acc.Account_Territory_Type__c);
                    }
                }

            }


            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoListV1=[select id,ObjectId from ObjectTerritory2Association 
                                                                    where ObjectId in:accLLst];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(territory2AssoListV1.size(),accLLst.size());

        }
    } 

    /*
    @ name    testIfMasterTerritoryIdNotFoundInsert
    @ date    15.Aug.2016
    @ author  Haigang Wu
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test if Master territory id not found on territory2 records                          
     */

    static testMethod void testIfMasterTerritoryIdNotFoundInsert() {

        csb.buildGenSetting();
        csb.buildTerritorySettingsMaster();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   
            //intialize all variable
            List<Account> accLLstToInsert =new List<Account>();

            for(Integer i=0;i<3;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Master_Territory_ID__c='1-OHJUY'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                
                accL.Global_Region__c='International';
                accL.Region__c='omer';
                accL.Office_Group__c='Componentes Electronicas Ltda';
                accL.Office__c='Componentes Electronicas Ltda';
                accL.Office_Channel__c='Indirect';
                accL.Territory_Industry__c='UNKNOWN';
                accL.Territory_Sales_Team_Type__c='Mixed';
                accL.Territory_Sales_Group__c='Latin America';
                accLLstToInsert.add(accL);


            }

            test.startTest();

            insert accLLstToInsert ;

            //Query Updated Account object
            List<Account> accTocheck=new  List<Account>();

            accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Master_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c
                                      From Account where id=:accLLstToInsert ];

            for(Account acc:accTocheck){

                //Asserts to check that fields are properly populated
                System.assertEquals(null,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(null,acc.Territory_Sales_Group__c);
                System.assertEquals(null,acc.Territory_Name__c);
                System.assertEquals(null,acc.Territory_Industry__c);
                System.assertEquals(acc.Master_Territory_ID__c,acc.Master_Territory_ID__c);
                System.assertEquals(null,acc.Office__c);
                System.assertEquals(null,acc.Office_Group__c);
                System.assertEquals(null,acc.Office_Channel__c);
                System.assertEquals(null,acc.Global_Region__c);
                System.assertEquals(null,acc.Region__c);

            }

            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoListTest=[select id,ObjectId from ObjectTerritory2Association 
                                                                      where ObjectId in:accTocheck];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(0,territory2AssoListTest.size());


            test.stopTest();
        }

    }

    /*
    @ name    testIfMasterTerritoryIdNotFoundUpdate
    @ date    15.Aug.2016
    @ author  Haigang Wu
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test if Master territory id not found on territory2 records                          
     */

    static testMethod void testIfMasterTerritoryIdISNullUpdate() {

        csb.buildGenSetting();
        csb.buildTerritorySettingsMaster();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   
            //intialize all variable
            List<Account> accLLst =new List<Account>();

            for(Integer i=0;i<3;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Master_Territory_ID__c='1-OHJUY'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';
                

                accLLst.add(accL);  

            }

            test.startTest();

            insert accLLst;

            //Query Updated Account object
            List<Account> accTocheck=new  List<Account>();

            accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Master_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c
                                      From Account where id=:accLLst];

            //Query Updated Account object
            List<Account> UpdateAccList=new  List<Account>();

            //Update Account records
            for(Account acc:accTocheck){

                acc.Master_Territory_ID__c=null;
                UpdateAccList.add(acc);
            }
            update UpdateAccList;

            test.stopTest();


            for(Account acc:accTocheck){

                //Asserts to check that fields are properly populated
                System.assertEquals(null,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(null,acc.Territory_Sales_Group__c);
                System.assertEquals(null,acc.Territory_Name__c);
                System.assertEquals(null,acc.Territory_Industry__c);
                System.assertEquals(null,acc.Office__c);
                System.assertEquals(null,acc.Office_Group__c);
                System.assertEquals(null,acc.Office_Channel__c);
                System.assertEquals(null,acc.Global_Region__c);
                System.assertEquals(null,acc.Region__c);

            }

            //Query ObjectTerritory2Association to check record are inserted for account
            List<ObjectTerritory2Association> territory2AssoListTest=[select id,ObjectId from ObjectTerritory2Association 
                                                                      where ObjectId in:accLLst];
            //Check that account can be associated to only one Territory at a time
            System.assertEquals(0,territory2AssoListTest.size());


        }

    }
    
    /*
    @ name    testIfMasterTerritoryIdNotFoundUpdate
    @ date    15.Aug.2016
    @ author  Haigang Wu
    @ param   none.
    @ return  Void. 
    @ description Method to Implement test if Master territory id not found on territory2 records                          
     */

    static testMethod void testIfMasterTerritoryIdNotFoundUpdate() {

        csb.buildGenSetting();
        csb.buildTerritorySettingsMaster();
        csb.buildBypassTriggerSettings();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;

        System.runAs(usr){   
            //intialize all variable
            List<Account> accLLst =new List<Account>();

            for(Integer i=0;i<3;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Master_Territory_ID__c='1-OHJUY'+i;
                accL.BillingCity ='Rio De Janeiro';
                accL.BillingCountryCode = 'US';
                accL.BillingCountry = 'United States';
                accL.BillingStateCode = 'NY';
                accL.BillingState = 'New York';                

                accLLst.add(accL);  

            }

            test.startTest();

            insert accLLst;

            //Query Updated Account object
            List<Account> accTocheck=new  List<Account>();

            accTocheck=[Select Territory__c, Territory_Sales_Team_Type__c, Territory_Sales_Group__c,
                                      Territory_Name__c, Territory_Industry__c, Master_Territory_ID__c, Salesforce_Territory_Id__c,
                                      Office__c, Office_Group__c, Office_Channel__c,Global_Region__c,Region__c
                                      From Account where id=:accLLst];

            //Query Updated Account object
            List<Account> UpdateAccList=new  List<Account>();

            //Update Account records
            for(Account acc:accTocheck){

                acc.Master_Territory_ID__c='TestTerritory';
                UpdateAccList.add(acc);
            }
            update UpdateAccList;

            test.stopTest();


            for(Account acc:accTocheck){

                //Asserts to check that fields are properly populated
                System.assertEquals(null,acc.Territory_Sales_Team_Type__c);
                System.assertEquals(null,acc.Territory_Sales_Group__c);
                System.assertEquals(null,acc.Territory_Name__c);
                System.assertEquals(null,acc.Territory_Industry__c);
                System.assertEquals(acc.Master_Territory_ID__c,'TestTerritory');
                System.assertEquals(null,acc.Office__c);
                System.assertEquals(null,acc.Office_Group__c);
                System.assertEquals(null,acc.Office_Channel__c);
                System.assertEquals(null,acc.Global_Region__c);
                System.assertEquals(null,acc.Region__c);

            }


        }

    }

}