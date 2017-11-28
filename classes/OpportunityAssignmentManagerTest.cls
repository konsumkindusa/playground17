/*
 *    @description:Class to test the TerritoryAssignmentManager
 */ 
@isTest(seeAlldata=true)
public with sharing class OpportunityAssignmentManagerTest {

    //Re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

    static String SalesMaintenanceRep=System.Label.FunRole_SalesMaintenanceRep;
    static String InsideSalesRep=System.Label.FunRol_InsideSalesRep;
    static String NationalAccountSalesSpecialist=System.Label.FunRole_NationalAccountSalesSpecialist;
    static String SalesRepPrimary=System.Label.FunRole_SalesRepPrimary;
    static String SalesSpecialist=System.Label.FunRole_SalesSpecialist;
    static String Renewal=System.Label.FunRole_Renewal;
    static String Distributor=System.Label.FunRole_Distributort;
    static String SalesManager=System.Label.FunRole_SalesManager;


    static  List<String> functionalRoleList=new  List<String>{SalesSpecialist,SalesManager,Distributor,SalesRepPrimary,NationalAccountSalesSpecialist,InsideSalesRep,SalesMaintenanceRep};


    static map<String,ID> roleUserMap = new map<string,id>();
    
     /*
      @ name    assignOpportunitiesByTerritoryTeamRolesSMSTest 
      @ date    25.July.2014
      @ author  Archana Lohar
      @ param   none.
      @ return  Void. 
      @ description Method to Implement test for assigning Opportunities by TerritoryTeamRole                         
     */

    static testMethod void assignOpportunitiesByTerritoryTeamRolesSMSTest() {

        List<User> userWithRoleLst=new List<User>();
        Set<ID> userSet=new Set<ID>();
        List<userterritory2Association> userAssoObjListToInsert=new List<userterritory2Association>();
        List<Opportunity> optyLst =new List<Opportunity>();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(100); 
        PricebookEntry objPriceBookEntry;
        usr.Functional_Role__c = 'Sales Manager'; //SS 3/17/2016 Added to exclude the opp auto assignment process on creation
        insert usr;
        
        //Set ExecuteDML to false
        OpportunityAssignmentManager.setExecuteDML(true);
        OpportunityAssignmentManager.setMassReorg(true);

        //Fetching date from General custom setting
        csb.buildGenSetting();
        csb.buildBypassTriggerSettings();
        General_Settings__c settings = General_Settings__c.getInstance();
        
        System.runAs(usr){   

            //Intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Account> accLLstToUpdate =new List<Account>();
            List<Territory2> territory2Lst =new List<Territory2>();
            List<OpportunityLineItem> lineItemLst =new List<OpportunityLineItem>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            Territory2Model model;

            //*************************************Insert Account objects *****************************************//

            for(Integer i=0;i<10;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='TestSTI'+i;
                accLLst.add(accL);  

            }


            insert accLLst;


            //*************************************Insert Territory2 Object*****************************************//

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }

            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<10;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                //dummyTerritory2.caseAccessLevel='Edit';


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

            //*************************************Insert User (Territory team dummy user) Object*****************************************//

            //Insert User Record with functional roles
            for(Integer i=0;i<functionalRoleList.size();i++){

                //User With Sales Maintenance Rep functional role
                User usrObj = TestDataBuilder.buildTestUser(i); 
                usrObj.Functional_Role__c=functionalRoleList[i];
                userWithRoleLst.add(usrObj);

            }
            //Insert users
            insert userWithRoleLst;
            
            

            //Insert  Record in roleUserMap with functional roles
            for(Integer i=0;i<userWithRoleLst.size();i++){

                roleUserMap.put(userWithRoleLst[i].Functional_Role__c,userWithRoleLst[i].id);
                userSet.add(userWithRoleLst[i].id);

            }


            //*************************************Insert Userterritory2Association Object*****************************************//

            Integer count=7;
            //add users to territory2
            for(Integer i=0;i<7;i++){


                //Add all users to territory2
                for(Integer j=0;j<count;j++){

                    userterritory2Association userAssObj=TestDataBuilder.buildTestUserterritory2Association(userWithRoleLst[j].id,territory2Lst[i].id);
                    userAssoObjListToInsert.add(userAssObj);

                }

                count--;

            }

            insert userAssoObjListToInsert;


            //Get user to set default opportunity custom setting
            //We will query using alias as name had issues with different locales
            List<User> usrObjByName=new List<User>();
            usrObjByName=[select id,name,functional_role__C from User where alias=:settings.Default_Opportunity_Owner__c ];
            
            //User usrObj=TestDataBuilder.buildTestUser(100);
            //insert usrObj;
            
            
            system.debug(usrObjByName+'usrObjByName');

            for(Integer i=0;i<10;i++){

                Opportunity opty = TestDataBuilder.buildTestOpportunity(i);
               
                opty.accountid=accLLst[i].id;
                opty.ownerid=usrObjByName[0].id;
                opty.amount=1000;
                opty.batch_evaluate__c=true;
                optyLst.add(opty);

            }


            insert optyLst;
            
             // Create a new product
            Product2 productObj = new Product2();
            productObj.Name='Additional Client Licenses';
            productObj.IsActive=true;
            productObj.ProductCode='AS';
            productObj.Quotable__c=true;
            productObj.Product_Unique_Identifier__c='Unclassified_Consulting1';
            insert productObj ;


            // Create a pricebook entry for custom pricebook
            PricebookEntry pbe = new PricebookEntry();
            pbe.UseStandardPrice = false;
            pbe.Pricebook2Id=Test.getStandardPricebookId();
            pbe.Product2Id=productObj.id;
            pbe.IsActive=true;
            pbe.UnitPrice=100.0;
            //pbe.UseStandardPrice =true;
            insert pbe;

          for(Integer i=0;i<10;i++){
              
            OpportunityLineItem NewRec = new OpportunityLineItem();
            NewRec.UnitPrice=200;
            NewRec.Quantity=3;
            NewRec.OpportunityId=optyLst[i].Id;
            NewRec.PricebookEntryId=pbe.id;
            NewRec.Revenue_Class__c='SMS';
            //NewRec.Product2id =product.id;
            lineItemLst.add(NewRec);
              
            }
            
            insert lineItemLst;
           
            //************************************* Uptdate Account objects *****************************************//

            for(Integer i=0;i<7;i++){

                Account accL =accLLst[i];
                accL.Siebel_Territory_ID__c=territory2Lst[i].Siebel_Territory_ID__c;
                accLLstToUpdate.add(accL);  

            }

            test.startTest();

            Update accLLstToUpdate;      

            //Check to see if correct territory2 team member is assigned
            List<Opportunity> optyObjLst=[select id,owner.Functional_Role__c from Opportunity 
                                          where id in :optyLst];

            for(Integer i=0;i<optyObjLst.size();i++){

                system.assert(userSet.contains(optyObjLst[i].ownerid)); 

            }


            test.stopTest();

        }
    }

   /*
      @ name    assignOpportunitiesByTerritoryTeamRolesNoNSMSTest 
      @ date    25.July.2014
      @ author  Archana Lohar
      @ param   none.
      @ return  Void. 
      */

    static testMethod void assignOpportunitiesByTerritoryTeamRolesNoNSMSTest() {

        List<User> userWithRoleLst=new List<User>();
        Set<ID> userSet=new Set<ID>();
        List<userterritory2Association> userAssoObjListToInsert=new List<userterritory2Association>();
        List<Opportunity> optyLst =new List<Opportunity>();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(100); 
        PricebookEntry objPriceBookEntry;
        usr.Functional_Role__c = 'Sales Manager'; //SS 3/17/2016 Added to exclude the opp auto assignment process on creation
        insert usr;
        
        //Set ExecuteDML to false
        OpportunityAssignmentManager.setExecuteDML(true);
        OpportunityAssignmentManager.setMassReorg(true);

        //Fetching date from General custom setting
        csb.buildGenSetting();
        csb.buildBypassTriggerSettings();
        General_Settings__c settings = General_Settings__c.getInstance();
        
        System.runAs(usr){   

            //Intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Account> accLLstToUpdate =new List<Account>();
            List<Territory2> territory2Lst =new List<Territory2>();
            List<OpportunityLineItem> lineItemLst =new List<OpportunityLineItem>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            Territory2Model model;

            //*************************************Insert Account objects *****************************************//

            for(Integer i=0;i<10;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='TestSTI'+i;
                accLLst.add(accL);  

            }


            insert accLLst;


            //*************************************Insert Territory2 Object*****************************************//

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }

            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<10;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                //dummyTerritory2.caseAccessLevel='Edit';


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

            //*************************************Insert User (Territory team dummy user) Object*****************************************//

            //Insert User Record with functional roles
            for(Integer i=0;i<functionalRoleList.size();i++){

                //User With Sales Maintenance Rep functional role
                User usrObj = TestDataBuilder.buildTestUser(i); 
                usrObj.Functional_Role__c=functionalRoleList[i];
                userWithRoleLst.add(usrObj);

            }
            //Insert users
            insert userWithRoleLst;
            
            

            //Insert  Record in roleUserMap with functional roles
            for(Integer i=0;i<userWithRoleLst.size();i++){

                roleUserMap.put(userWithRoleLst[i].Functional_Role__c,userWithRoleLst[i].id);
                userSet.add(userWithRoleLst[i].id);

            }


            //*************************************Insert Userterritory2Association Object*****************************************//

            Integer count=7;
            //add users to territory2
            for(Integer i=0;i<7;i++){


                //Add all users to territory2
                for(Integer j=0;j<count;j++){

                    userterritory2Association userAssObj=TestDataBuilder.buildTestUserterritory2Association(userWithRoleLst[j].id,territory2Lst[i].id);
                    userAssoObjListToInsert.add(userAssObj);

                }

                count--;

            }

            insert userAssoObjListToInsert;


            //Get user to set default opportunity custom setting
            //We will query using alias as name had issues with different locales
            List<User> usrObjByName=new List<User>();
            usrObjByName=[select id,name,functional_role__C from User where alias=:settings.Default_Opportunity_Owner__c ];
           // usrObjByName[0].functional_role__C='';
            //update usrObjByName;
            
            
            //User usrObj=TestDataBuilder.buildTestUser(100);
            //insert usrObj;
            
            
            system.debug(usrObjByName+'usrObjByName');

            for(Integer i=0;i<10;i++){

                Opportunity opty = TestDataBuilder.buildTestOpportunity(i);
               
                opty.accountid=accLLst[i].id;
                opty.ownerid=usrObjByName[0].id;
                opty.amount=1000;
                opty.batch_evaluate__c=true;
                optyLst.add(opty);

            }


            insert optyLst;
            
            
            //************************************* Uptdate Account objects *****************************************//

            for(Integer i=0;i<7;i++){

                Account accL =accLLst[i];
                accL.Siebel_Territory_ID__c=territory2Lst[i].Siebel_Territory_ID__c;
                accLLstToUpdate.add(accL);  

            }

            test.startTest();

            Update accLLstToUpdate;      

            //Check to see if correct territory2 team member is assigned
            List<Opportunity> optyObjLst=[select id,owner.Functional_Role__c from Opportunity 
                                          where id in :optyLst];

            for(Integer i=0;i<optyObjLst.size();i++){

                system.assert(userSet.contains(optyObjLst[i].ownerid)); 

            }


            test.stopTest();

        }
    }
    
    /*
      @ name    assignOpportunitiesByTerritoryTeamRolesNoNSMSBatchEvaluateTrueTest 
      @ date    25.July.2014
      @ author  Archana Lohar
      @ param   none.
      @ return  Void. 
                      
     */

    static testMethod void assignOpportunitiesByTerritoryTeamRolesNoNSMSBatchEvaluateTrueTest() {

        List<User> userWithRoleLst=new List<User>();
        Set<ID> userSet=new Set<ID>();
        List<userterritory2Association> userAssoObjListToInsert=new List<userterritory2Association>();
        List<Opportunity> optyLst =new List<Opportunity>();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(100); 
        PricebookEntry objPriceBookEntry;
        usr.Functional_Role__c = 'Sales Manager'; //SS 3/17/2016 Added to exclude the opp auto assignment process on creation
        insert usr;
        
        //Set ExecuteDML to false
        OpportunityAssignmentManager.setExecuteDML(true);
       // OpportunityAssignmentManager.setMassReorg(true);

        //Fetching date from General custom setting
        csb.buildGenSetting();
        csb.buildBypassTriggerSettings();
        General_Settings__c settings = General_Settings__c.getInstance();
        
        System.runAs(usr){   

            //Intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Account> accLLstToUpdate =new List<Account>();
            List<Territory2> territory2Lst =new List<Territory2>();
            List<OpportunityLineItem> lineItemLst =new List<OpportunityLineItem>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            Territory2Model model;

            //*************************************Insert Account objects *****************************************//

            for(Integer i=0;i<10;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='TestSTI'+i;
                accLLst.add(accL);  

            }


            insert accLLst;


            //*************************************Insert Territory2 Object*****************************************//

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }

            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<10;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                //dummyTerritory2.caseAccessLevel='Edit';


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

            //*************************************Insert User (Territory team dummy user) Object*****************************************//

            //Insert User Record with functional roles
            for(Integer i=0;i<functionalRoleList.size();i++){

                //User With Sales Maintenance Rep functional role
                User usrObj = TestDataBuilder.buildTestUser(i); 
                usrObj.Functional_Role__c=functionalRoleList[i];
                userWithRoleLst.add(usrObj);

            }
            //Insert users
            insert userWithRoleLst;
            
            

            //Insert  Record in roleUserMap with functional roles
            for(Integer i=0;i<userWithRoleLst.size();i++){

                roleUserMap.put(userWithRoleLst[i].Functional_Role__c,userWithRoleLst[i].id);
                userSet.add(userWithRoleLst[i].id);

            }


            //*************************************Insert Userterritory2Association Object*****************************************//

            Integer count=7;
            //add users to territory2
            for(Integer i=0;i<7;i++){


                //Add all users to territory2
                for(Integer j=0;j<count;j++){

                    userterritory2Association userAssObj=TestDataBuilder.buildTestUserterritory2Association(userWithRoleLst[j].id,territory2Lst[i].id);
                    userAssoObjListToInsert.add(userAssObj);

                }

                count--;

            }

            insert userAssoObjListToInsert;


            //Get user to set default opportunity custom setting
            //We will query using alias as name had issues with different locales
            List<User> usrObjByName=new List<User>();
            usrObjByName=[select id,name,functional_role__C from User where alias=:settings.Default_Opportunity_Owner__c ];
           // usrObjByName[0].functional_role__C='';
            //update usrObjByName;
            
            
            //User usrObj=TestDataBuilder.buildTestUser(100);
            //insert usrObj;
            
            
            system.debug(usrObjByName+'usrObjByName');

            for(Integer i=0;i<10;i++){

                Opportunity opty = TestDataBuilder.buildTestOpportunity(i);
               
                opty.accountid=accLLst[i].id;
                opty.ownerid=usrObjByName[0].id;
                opty.amount=1000;
                //opty.batch_evaluate__c=true;
                optyLst.add(opty);

            }


            insert optyLst;
            
            
            //************************************* Uptdate Account objects *****************************************//

            for(Integer i=0;i<7;i++){

                Account accL =accLLst[i];
                accL.Siebel_Territory_ID__c=territory2Lst[i].Siebel_Territory_ID__c;
                accLLstToUpdate.add(accL);  

            }

            test.startTest();

            Update accLLstToUpdate;      

            //Check to see if correct territory2 team member is assigned
            List<Opportunity> optyObjLst=[select id,owner.Functional_Role__c from Opportunity 
                                          where id in :optyLst];

            for(Integer i=0;i<optyObjLst.size();i++){

                system.assert(userSet.contains(optyObjLst[i].ownerid)); 

            }


            test.stopTest();

        }
    }
    
     /*
      @ name    assignOpportunitiesByTerritoryTeamRolesNoNSMSTestBatchEvalueteTrue 
      @ date    25.July.2014
      @ author  Archana Lohar
      @ param   none.
      @ return  Void. 
       */

    static testMethod void assignOpportunitiesByTerritoryTeamRolesNoNSMSTestBatchEvalueteTrue() {

        List<User> userWithRoleLst=new List<User>();
        Set<ID> userSet=new Set<ID>();
        List<userterritory2Association> userAssoObjListToInsert=new List<userterritory2Association>();
        List<Opportunity> optyLst =new List<Opportunity>();
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(100); 
        PricebookEntry objPriceBookEntry;
        usr.Functional_Role__c = 'Sales Manager'; //SS 3/17/2016 Added to exclude the opp auto assignment process on creation
        insert usr;
        
        //Set ExecuteDML to false
        OpportunityAssignmentManager.setExecuteDML(true);
        OpportunityAssignmentManager.setMassReorg(true);

        //Fetching date from General custom setting
        csb.buildGenSetting();
        csb.buildBypassTriggerSettings();
        General_Settings__c settings = General_Settings__c.getInstance();
        
        System.runAs(usr){   

            //Intialize all variable
            List<Account> accLLst =new List<Account>();
            List<Account> accLLstToUpdate =new List<Account>();
            List<Territory2> territory2Lst =new List<Territory2>();
            List<OpportunityLineItem> lineItemLst =new List<OpportunityLineItem>();
            List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
            Territory2Model model;

            //*************************************Insert Account objects *****************************************//

            for(Integer i=0;i<10;i++){

                Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accL.Name = 'Smith' + i;
                accL.Siebel_Territory_ID__c='TestSTI'+i;
                accLLst.add(accL);  

            }


            insert accLLst;


            //*************************************Insert Territory2 Object*****************************************//

            Territory2Type typeTest=[select id from Territory2Type limit 1];

            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];

            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){

                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;

            }

            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<10;i++){

                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
                dummyTerritory2.Territory_Industry__c='UNKNOWN';
                dummyTerritory2.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                //dummyTerritory2.caseAccessLevel='Edit';


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

            //*************************************Insert User (Territory team dummy user) Object*****************************************//

            //Insert User Record with functional roles
            for(Integer i=0;i<functionalRoleList.size();i++){

                //User With Sales Maintenance Rep functional role
                User usrObj = TestDataBuilder.buildTestUser(i); 
                usrObj.Functional_Role__c=functionalRoleList[i];
                userWithRoleLst.add(usrObj);

            }
            //Insert users
            insert userWithRoleLst;
            
            

            //Insert  Record in roleUserMap with functional roles
            for(Integer i=0;i<userWithRoleLst.size();i++){

                roleUserMap.put(userWithRoleLst[i].Functional_Role__c,userWithRoleLst[i].id);
                userSet.add(userWithRoleLst[i].id);

            }


            //*************************************Insert Userterritory2Association Object*****************************************//

            Integer count=7;
            //add users to territory2
            for(Integer i=0;i<7;i++){


                //Add all users to territory2
                for(Integer j=0;j<count;j++){

                    userterritory2Association userAssObj=TestDataBuilder.buildTestUserterritory2Association(userWithRoleLst[j].id,territory2Lst[i].id);
                    userAssoObjListToInsert.add(userAssObj);

                }

                count--;

            }

            insert userAssoObjListToInsert;


            //Get user to set default opportunity custom setting
            //We will query using alias as name had issues with different locales
            List<User> usrObjByName=new List<User>();
            usrObjByName=[select id,name,functional_role__C from User where alias=:settings.Default_Opportunity_Owner__c ];
            //usrObjByName[0].functional_role__C='';
            //update usrObjByName;
            
            
            //User usrObj=TestDataBuilder.buildTestUser(100);
            //insert usrObj;
            
            
            system.debug(usrObjByName+'usrObjByName');

            for(Integer i=0;i<10;i++){

                Opportunity opty = TestDataBuilder.buildTestOpportunity(i);
               
                opty.accountid=accLLst[i].id;
                opty.ownerid=usrObjByName[0].id;
                opty.amount=1000;
                opty.batch_evaluate__c=true;
                optyLst.add(opty);

            }


            insert optyLst;
            
            
            //************************************* Uptdate Account objects *****************************************//

            for(Integer i=0;i<7;i++){

                Account accL =accLLst[i];
                accL.Siebel_Territory_ID__c=territory2Lst[i].Siebel_Territory_ID__c;
                accLLstToUpdate.add(accL);  

            }

            test.startTest();

            Update accLLstToUpdate;      

            //Check to see if correct territory2 team member is assigned
            List<Opportunity> optyObjLst=[select id,owner.Functional_Role__c from Opportunity 
                                          where id in :optyLst];

            for(Integer i=0;i<optyObjLst.size();i++){

                system.assert(userSet.contains(optyObjLst[i].ownerid)); 

            }


            test.stopTest();

        }
    }
}