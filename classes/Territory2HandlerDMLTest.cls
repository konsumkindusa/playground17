/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:20 Nov 2015, Last Modified:
 *@description This is a test class for Territory2HandlerDMLTest.
 */

@isTest(seeAlldata=true)
public Class Territory2HandlerDMLTest{
 
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
        
     /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 20 Nov 2015 
     *@Last Modified: 
     *@Description: Test Method to check the functionality of InsertTerritoryShadowObjRec Method.
     */
     
    private static testMethod void InsertTerritoryShadowObjRecTest(){
            
       
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
 
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        // Inserting GeneralSetting record
        csb.buildGenSetting();
        //Inserting Territory_Settings__c record fg
        csb.buildTerritorySettings();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
     
        //intialize all variable
        Territory2Model model;
        //List of Terriotry2 Object to store the inserted record.
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();
        //Set of Territory2 Object Id.
        Set<Id> territorySet = new Set<Id>();
        //List of Territory2 object to store the dummy records. 
        List<Territory2> territoryLstNew =new List<Territory2>();
        //List to store the territory2Model.
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=199;i++){
                    
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
                dummyTerritory2.Is_Active__c =true;//fg
                dummyTerritory2.Master_Territory_ID__c = 'TM'+i;//fg
                dummyTerritory2.Unique_Master_Territory__c=dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c; //fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //Start Test
            Test.startTest(); 
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
            
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c,is_Active__c,Master_Territory_ID__c FROM Territory2 WHERE Id IN: territoryLstNew];//fg
            System.assertEquals(insertedTerritory2Lst.size(), 200, True);
            
            for(Territory2 territory2Obj : insertedTerritory2Lst){
                territorySet.add(territory2Obj.Id);
            }
            //Stop Test
            Test.StopTest(); 
           
            //Querying the Territory_Shadow__c Object List Associated to the the Territory2 Object.
            List<Territory_Shadow__c> TSLst = [SELECT Id,Office_Channel__c,Office__c,Description__c,Territory_Type__c,Territory_Sector__c,Territory_Sales_Team_Type__c,Office_Group__c,Territory_Industry__c,Global_Region__c,Name,Region__c,Territory_Sales_Group__c,Territory2_Developer_Name__c,Salesforce_Territory_ID__c,Master_Territory_ID__c,is_Active__c,Siebel_Territory_ID__c FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c IN: territorySet];//fg
            //Asserting the size of Territory Shadow List.
            System.assertEquals(TSLst.size(), 200, True);
            
            for(Integer i=0;i<=199;i++){
                if(TSLst[i].Salesforce_Territory_ID__c == insertedTerritory2Lst[i].Id){
                    //Asserting of the inserted Territory Shadow object fields as according to the associated Territory2 Object
                    System.assertEquals(TSLst[i].Salesforce_Territory_ID__c, insertedTerritory2Lst[i].Id);
                    System.assertEquals(TSLst[i].Master_Territory_ID__c, insertedTerritory2Lst[i].Master_Territory_ID__c); //fg
                    System.assertEquals(TSLst[i].Territory2_Developer_Name__c, insertedTerritory2Lst[i].DeveloperName);
                    System.assertEquals(TSLst[i].Name, insertedTerritory2Lst[i].Name);
                    System.assertEquals(TSLst[i].Global_Region__c, insertedTerritory2Lst[i].Global_Region__c);
                    System.assertEquals(TSLst[i].Office__c, insertedTerritory2Lst[i].Office__c);
                    System.assertEquals(TSLst[i].Office_Channel__c, insertedTerritory2Lst[i].Office_Channel__c);
                    System.assertEquals(TSLst[i].Office_Group__c, insertedTerritory2Lst[i].Office_Group__c);
                    System.assertEquals(TSLst[i].Region__c, insertedTerritory2Lst[i].Region__c);
                    System.assertEquals(TSLst[i].Territory_Industry__c, insertedTerritory2Lst[i].Territory_Industry__c);
                    System.assertEquals(TSLst[i].Territory_Sales_Group__c, insertedTerritory2Lst[i].Territory_Sales_Group__c);
                    System.assertEquals(TSLst[i].Territory_Sales_Team_Type__c, insertedTerritory2Lst[i].Territory_Sales_Team_Type__c);
                    System.assertEquals(TSLst[i].is_Active__c, insertedTerritory2Lst[i].is_Active__c);
                    System.assertEquals(TSLst[i].Siebel_Territory_ID__c,insertedTerritory2Lst[i].Siebel_Territory_ID__c);//fg
                }
            }   
        }//End of System.run(usr)
       
    }//End of Method.
    
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 20 Nov 2015 
     *@Last Modified: 
     *@Description: Test Method to check the functionality of InsertTerritoryShadowObjRec Method.
     */
     
    private static testMethod void updatetTerritoryShadowObjRecTest(){
            
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        
        
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildTerritorySettings();// fg
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        
        //intialize all variable
        Territory2Model model;
        //List of Terriotry2 Object to store the inserted record.
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();
        //Set of Territory2 Object Id.
        Set<Id> territorySet = new Set<Id>();
        //List of Territory2 object to store the dummy records. 
        List<Territory2> territoryLstNew =new List<Territory2>();
        //List to store the territory2Model.
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        //List to get the updated territory2 records
        List<Territory2> updateTerritory2Lst = new List<territory2>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=199;i++){
                    
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
                dummyTerritory2.description = 'Test Desc';
                dummyTerritory2.Territory_Sales_Group__c='Latin America';
                dummyTerritory2.Name='testTerritoryUpdated'+i;
                dummyTerritory2.is_Active__c = false;//fg
                dummyTerritory2.Master_Territory_ID__c ='TM-'+i;// fg
                dummyTerritory2.Unique_Master_Territory__c=dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
            
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c,is_Active__c,Master_Territory_ID__c FROM Territory2 WHERE Id IN: territoryLstNew];//fg
            System.assertEquals(insertedTerritory2Lst.size(), 200, True);
            
            //Integer to Update the territory Object.
            Integer updateCounter=0;
            for(Territory2 territory2Obj : insertedTerritory2Lst){
                updateCounter++;
                
                territory2Obj.description = 'Test update'+updateCounter;
                territorySet.add(territory2Obj.Id);
                updateTerritory2Lst.add(territory2Obj);
            }
            
            //Start Test
            Test.startTest(); 
            update updateTerritory2Lst;
            //Stop Test
            Test.StopTest(); 
           
            //Querying the Territory_Shadow__c Object List Associated to the the Territory2 Object.
            List<Territory_Shadow__c> TSLst = [SELECT Id,Siebel_Territory_ID__c,Office_Channel__c,Office__c,Description__c,Territory_Type__c,Territory_Sector__c,Territory_Sales_Team_Type__c,Office_Group__c,Territory_Industry__c,Global_Region__c,Name,Region__c,Territory_Sales_Group__c,Territory2_Developer_Name__c,Salesforce_Territory_ID__c,Master_Territory_ID__c,is_Active__c FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c IN: territorySet];//fg
            //Asserting the size of Territory Shadow List.
            System.assertEquals(TSLst.size(), 200, True);
            
            for(Integer i=0;i<=199;i++){
                if(TSLst[i].Salesforce_Territory_ID__c == insertedTerritory2Lst[i].Id){
                    //Asserting of the inserted Territory Shadow object fields as according to the associated Territory2 Object
                    System.assertEquals(TSLst[i].Description__c, updateTerritory2Lst[i].Description);
                }
            }   
        }//End of System.run(usr)
       
    }//End of Method.
    
    
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 20 Nov 2015 
     *@Last Modified: 
     *@Description: Test Method to check the functionality of updateTerritoryShadowObjRec Method.
     */
     
    private static testMethod void upsertTerritoryShadowObjRecTest(){
            
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        
        
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildTerritorySettings();// fg 
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        
        //intialize all variable
        Territory2Model model;
        //List to Store the Territory2 Object List.
        List<Territory2> territoryLstNew =new List<Territory2>();
        //List to store the territory2Model records.
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        //List of territory2 object.
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();
        //Set of territory2 Object Id.
        Set<Id> territory2IdSet = new Set<Id>(); 
        //List to store the update territory2 records.
        List<Territory2> updateTerritory2Lst = new List<Territory2>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=199;i++){
                    
                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                
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
                dummyTerritory2.Description = 'New Territory'+i;
                dummyTerritory2.is_Active__c = true;//fg
                dummyTerritory2.Master_Territory_ID__c ='TM-'+i;   //fg  
                dummyTerritory2.Unique_Master_Territory__c=dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c; //fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //inserting territory2 Object.
            insert territoryLstNew;
            
            //Qeuying the territory2 object. 
            insertedTerritory2Lst  = [SELECT Id,Name,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Siebel_Territory_ID__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c,is_Active__c,Master_Territory_ID__c FROM Territory2 WHERE Id IN: territoryLstNew];//fg
            //Asserting the territory2 Object record.
            System.assertEquals(insertedTerritory2Lst.size(), 200, True);
            
            //Querying the list of Territory_Shadow__c Object associted.
            List<Territory_Shadow__c> TSLst = [SELECT Id,Office_Channel__c,Office__c,Description__c,Territory_Type__c,Territory_Sector__c,Territory_Sales_Team_Type__c,Office_Group__c,Territory_Industry__c,Global_Region__c,Name,Region__c,Territory_Sales_Group__c,Territory2_Developer_Name__c,Salesforce_Territory_ID__c,Master_Territory_ID__c,is_Active__c,Siebel_Territory_ID__c FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c IN: territory2IdSet];//fg
            //Asserting the Territory_Shadow__c Object List.
            System.assertEquals(TSLst.size(), 0, True);
            
            //Test Start
            Test.startTest();
            //Integer to Update the territory Object.
            Integer updateCounter=0;
            for(Territory2 territory2Obj : insertedTerritory2Lst){
                updateCounter++;
                //Updating the Siebel_Territory_ID__c field on the Territory2 Object.
                territory2Obj.Siebel_Territory_ID__c = 'TT-123'+updateCounter;
                territory2Obj.Description = 'Test Desc' +updateCounter;
                territory2Obj.is_Active__c = false; //fg
                territory2Obj.Master_Territory_ID__c = 'TM-'+ updateCounter;//fg
                territory2Obj.Unique_Master_Territory__c=territory2Obj.Territory2ModelId+territory2Obj.Master_Territory_ID__c;//fg
                updateTerritory2Lst.add(territory2Obj);
                territory2IdSet.add(territory2Obj.Id);
                // shweta - add logic for Master Territory id when development completed
            }
            
             
            //Updating the Territory2 Object List.
            database.upsert(updateTerritory2Lst, false);
            //Test Stop
            Test.StopTest(); 
            
            //Querying the list of Territory_Shadow__c Object associted.
            List<Territory_Shadow__c> territoryShadowLst = [SELECT Id,Salesforce_Territory_ID__c,Office_Channel__c,Office__c,Description__c,Territory_Type__c,Territory_Sector__c,Territory_Sales_Team_Type__c,Office_Group__c,Territory_Industry__c,Global_Region__c,Name,Region__c,Territory_Sales_Group__c,Territory2_Developer_Name__c,Siebel_Territory_ID__c,Master_Territory_ID__c,is_Active__c FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c IN: territory2IdSet];//fg
            
            //Asserting the Territory_Shadow__c Object List.
            System.assertEquals(territoryShadowLst.size(), 200, True);
            
            for(Integer i=0;i<=199;i++){
                if(territoryShadowLst[i].Salesforce_Territory_ID__c == updateTerritory2Lst[i].Id){
                    //Asserting of the Territory Shadow object is updated as according to the associated Territory2 Object
                    System.assertEquals(territoryShadowLst[i].Description__c, updateTerritory2Lst[i].Description);
                    // System.assertEquals(territoryShadowLst[i].Master_Territory_ID__c, updateTerritory2Lst[i].Siebel_Territory_ID__c);//fg
                    System.assertEquals(territoryShadowLst[i].Master_Territory_ID__c, updateTerritory2Lst[i].Master_Territory_ID__c);//fg
                    System.assertEquals(territoryShadowLst[i].Siebel_Territory_ID__c, updateTerritory2Lst[i].Siebel_Territory_ID__c); //fg                
                    System.assertEquals(territoryShadowLst[i].is_Active__c, updateTerritory2Lst[i].is_Active__c);
                }
            }   
          }//End of System.run(usr)
    
    }//End of Method.  
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 20 Nov 2015 
     *@Last Modified: 
     *@Description: Test Method to check the functionality of deleteTerritoryShadowObjRec Method.
     */
     
    private static testMethod void deleteTerritoryShadowObjRecTest(){
            
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        
        
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        
        //intialize all variable
        Territory2Model model;
        //List of Terriotry2 Object to store the inserted record.
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();
        //Set of Territory2 Object Id.
        Set<Id> territorySet = new Set<Id>();
        //List of Territory2 object to store the dummy records. 
        List<Territory2> territoryLstNew =new List<Territory2>();
        //List to store the territory2Model.
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=199;i++){
                    
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
                dummyTerritory2.Master_Territory_ID__c = 'TM-'+i;
                dummyTerritory2.Unique_Master_Territory__c= dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
             
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
            
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c FROM Territory2 WHERE Id IN: territoryLstNew];
            System.assertEquals(insertedTerritory2Lst.size(), 200, True);
            
            //Filling the territorySet.
            for(Territory2 territory2Obj : insertedTerritory2Lst){
                territorySet.add(territory2Obj.Id);
            }
            
            
            //Start Test
            Test.startTest();
            Database.Delete(insertedTerritory2Lst, false); 
            //Stop Test
            Test.StopTest(); 
            
            //Querying the Territory_Shadow__c Object List Associated to the the Territory2 Object.
            List<Territory_Shadow__c> TSList = [SELECT Id,Office_Channel__c,Office__c,Description__c,Territory_Type__c,Territory_Sector__c,Territory_Sales_Team_Type__c,Office_Group__c,Territory_Industry__c,Global_Region__c,Name,Region__c,Territory_Sales_Group__c,Territory2_Developer_Name__c,Salesforce_Territory_ID__c,Master_Territory_ID__c,Siebel_Territory_ID__c FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c IN: territorySet];
            //Asserting the size of Territory Shadow List.
            System.assertEquals(TSList.size(), 0, True);
              
        }//End of System.run(usr)
       
    }//End of Method.
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 20 Nov 2015 
     *@Last Modified: 
     *@Description: Test Method to check the functionality of deleteTerritoryShadowObjRec Method.
     */
     
    private static testMethod void cannotDeletionTerritory2ObjWithAccountAssociatedTest(){
            
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        
        
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        
        //intialize all variable
        Territory2Model model;
        //List of Terriotry2 Object to store the inserted record.
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();
        //Set of Territory2 Object Id.
        Set<Id> territorySet = new Set<Id>();
        //List of Territory2 object to store the dummy records. 
        List<Territory2> territoryLstNew =new List<Territory2>();
        //List to store the territory2Model.
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=199;i++){
                    
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
                dummyTerritory2.Master_Territory_ID__c ='TM-'+i;
                   dummyTerritory2.Unique_Master_Territory__c= dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
            
            List<Territory2> territoryList = [SELECT Id FROM Territory2 WHERE ID IN:territoryLstNew];
            System.assertEquals(territoryList.size(),200,True);        
            
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c FROM Territory2 WHERE Id IN: territoryLstNew];
            System.assertEquals(insertedTerritory2Lst.size(), 200, True);
            
            for(Territory2 territory2Obj : insertedTerritory2Lst){
                territorySet.add(territory2Obj.Id);
            }
            
            //List of Account object records list.
            List<Account> accList = new List<Account>();
            Integer accCounter = 0;
            for(Territory2 territory2Obj : insertedTerritory2Lst){
                accCounter++;
                Account accObj = TestDataBuilder.buildTestAccount(accCounter, usr.Id);
                accObj.Siebel_Territory_ID__c = territory2Obj.Siebel_Territory_ID__c;
                accObj.Master_Territory_ID__c = territory2Obj.Master_Territory_ID__c;
                accList.add(accObj);
            }
            
            insert accList;
            
            List<Account> accLst = [SELECT Id FROM Account Where Id IN: accList];
            System.assertEquals(accLst.size(), 200, True);
            
            //Start Test
            Test.startTest();
            try{
                Database.Delete(insertedTerritory2Lst, false); 
            }
            catch(Exception ex){
                 
                System.assertEquals(ex.getMessage().contains(System.Label.Territory2DeleteErrorMessage), True);
            }
            //Stop Test
            Test.StopTest();
        }//End of System.run(usr)
    }//End of Method.
    
    
    
   private static testMethod void insertterritorymasteterritoryidpopulated()
   {
        /** 
     *@Author Original: Faina Gorelik - MathWorks
     *@Last Modified:  
     *@Date Original: 9/18/16
     *@Last Modified: 
     *@Description: Test Method to check generation and population of Master Territory Id on insert when master territory id is not null
     */
       //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        Territory_Settings__c terrset = Territory_Settings__c.getInstance(UserInfo.getOrganizationId());//fg
        boolean MasterFlag = terrset.Generate_Master_Territory_Flag__c;//fg

        //intialize all variable
        Territory2Model model; 
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();      
        List<Territory2> territoryLstNew =new List<Territory2>();
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=99;i++){
                    
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
                dummyterritory2.Master_Territory_ID__c = 'TM-New'+i;
               	dummyterritory2.Unique_Master_Territory__c='';//fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            Test.startTest(); 
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
            
            Test.stopTest(); 
            List<Territory2> territoryList = [SELECT Id FROM Territory2 WHERE ID IN:territoryLstNew];
            System.assertEquals(territoryList.size(),100,True);        
            
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,Unique_Master_Territory__c,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c FROM Territory2 WHERE Id IN: territoryLstNew];// fg added unique master territory to the query
            System.assertEquals(insertedTerritory2Lst.size(), 100, True);
            
            
             for(Integer i=0;i<=99;i++){      
               //  if (MasterFlag == true){
                     System.assert(insertedTerritory2Lst[i].Master_Territory_ID__c!=null); 
                     System.assert(insertedTerritory2Lst[i].Unique_Master_Territory__c!=null);//fg
             //    }
              //   else{
                    // System.assertEquals(insertedTerritory2Lst[i].Unique_Master_Territory__c, null);
                    // System.assertEquals(insertedTerritory2Lst[i].Master_Territory_ID__c, null);//(insertedTerritory2Lst[i].Master_Territory_ID__c='');  
                // }     
             }
            

        }//End of System.run(usr)
       
       //end new method
   }
    
     /** 
     *@Author Original: Shweta Shanbhag - MathWorks
     *@Last Modified:  Shweta Shanbhag
     *@Date Original: 8/16/16
     *@Last Modified: 
     *@Description: Test Method to check generation and population of Master Territory Id
     */
     
    private static testMethod void populatemasterterritoryidoninsert(){
            
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        Territory_Settings__c terrset = Territory_Settings__c.getInstance(UserInfo.getOrganizationId());//fg
        boolean MasterFlag = terrset.Generate_Master_Territory_Flag__c;//fg

        //intialize all variable
        Territory2Model model; 
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();      
        List<Territory2> territoryLstNew =new List<Territory2>();
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=99;i++){
                    
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
                dummyterritory2.Master_Territory_ID__c = '';
                dummyterritory2.Unique_Master_Territory__c='';//fg
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            Test.startTest(); 
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
            
            Test.stopTest(); 
            List<Territory2> territoryList = [SELECT Id FROM Territory2 WHERE ID IN:territoryLstNew];
            System.assertEquals(territoryList.size(),100,True);        
            
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,Unique_Master_Territory__c,DeveloperName,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c,Territory_Sales_Group__c FROM Territory2 WHERE Id IN: territoryLstNew];// fg added unique master territory to the query
            System.assertEquals(insertedTerritory2Lst.size(), 100, True);
            
            
             for(Integer i=0;i<=99;i++){      
                 if (MasterFlag == true){
                     System.assert(insertedTerritory2Lst[i].Master_Territory_ID__c!=null); 
                     System.assert(insertedTerritory2Lst[i].Unique_Master_Territory__c!=null);//fg
                 }
                 else{
                     System.assertEquals(insertedTerritory2Lst[i].Unique_Master_Territory__c, null);
                     System.assertEquals(insertedTerritory2Lst[i].Master_Territory_ID__c, null);
                 }     
             }
            

        }//End of System.run(usr)
    }//End of Method.
    
    /** 
     *@Author Original: Faina Gorelik - MathWorks
     *@Last Modified:  Faina Gorelik
     *@Date Original: 9/18/16
     *@Last Modified: 
     *@Description: Test Method to check  population of Unique Master Territory  when Master Territory id is not updated but unique master territory is updated
     */
    private static testMethod void populateuniquemasteronupdate(){ 
         //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        Territory_Settings__c terrset = Territory_Settings__c.getInstance(UserInfo.getOrganizationId());//fg
        boolean MasterFlag = terrset.Generate_Master_Territory_Flag__c;//fg
        
        //intialize all variable
        Territory2Model model; 
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();      
        List<Territory2> territoryLstNew =new List<Territory2>();
        List<Territory2> terrLstupdate =new List<Territory2>();
        List<Territory2> Updatedterrlst =new List<Territory2>();
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=1;i++){
                    
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
                dummyTerritory2.Master_Territory_ID__c = 'TM' + i;
                dummyTerritory2.Unique_Master_Territory__c= dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg
                
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
       
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c
                                      ,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c
                                      ,Territory_Sales_Group__c, Unique_Master_Territory__c, Include_In_Sales_Hierarchy__c FROM Territory2 WHERE Id IN: territoryLstNew]; //HW
            
          
                for (Integer i=0;i<=1;i++){
                    insertedTerritory2Lst[i].Unique_Master_Territory__c = 'TER-'+i;

            }
            Test.startTest(); 
            
            update insertedTerritory2Lst;
            
            Test.stopTest(); 
            
 			Updatedterrlst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c
                                      ,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c
                                      ,Territory_Sales_Group__c,Unique_Master_Territory__c,Territory2ModelId FROM Territory2 WHERE Id IN: insertedTerritory2Lst]; 
            
          
            for(Integer i=0;i<=1;i++){                
                    //System.assert(Updatedterrlst[i].Master_Territory_ID__c!=null);   
                	//System.assert(Updatedterrlst[i].Unique_Master_Territory__c!=null); 
                	System.assertEquals(Updatedterrlst[i].Unique_Master_Territory__c, Updatedterrlst[0].Territory2ModelId+Updatedterrlst[i].Master_Territory_ID__c); 
               
            }
           
        }//End of System.run(usr)  
    } // end of method
    /** 
     *@Author Original: Faina Gorelik - MathWorks
     *@Last Modified:  Faina Gorelik
     *@Date Original: 9/18/16
     *@Last Modified: 
     *@Description: Test Method to check generation and population of Master Territory Id when Master Territory id updated from not null to a different value
     */
    private static testMethod void populatemasterterridonupdatenotnull(){
         //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        Territory_Settings__c terrset = Territory_Settings__c.getInstance(UserInfo.getOrganizationId());//fg
        boolean MasterFlag = terrset.Generate_Master_Territory_Flag__c;//fg
        
        //intialize all variable
        Territory2Model model; 
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();      
        List<Territory2> territoryLstNew =new List<Territory2>();
        List<Territory2> terrLstupdate =new List<Territory2>();
        List<Territory2> Updatedterrlst =new List<Territory2>();
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=1;i++){
                    
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
                dummyTerritory2.Master_Territory_ID__c = 'TM' + i;
                dummyTerritory2.Unique_Master_Territory__c= dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg
                
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
       
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c
                                      ,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c
                                      ,Territory_Sales_Group__c, Unique_Master_Territory__c, Include_In_Sales_Hierarchy__c FROM Territory2 WHERE Id IN: territoryLstNew]; //HW
            
          
                for (Integer i=0;i<=1;i++){
                    insertedTerritory2Lst[i].Master_Territory_ID__c = 'TP-'+i;

            }
            Test.startTest(); 
            
            update insertedTerritory2Lst;
            
            Test.stopTest(); 
            
 			Updatedterrlst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c
                                      ,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c
                                      ,Territory_Sales_Group__c,Unique_Master_Territory__c,Territory2ModelId FROM Territory2 WHERE Id IN: insertedTerritory2Lst]; 
            
          
            for(Integer i=0;i<=1;i++){                
                    System.assert(Updatedterrlst[i].Master_Territory_ID__c!=null);   
                	System.assert(Updatedterrlst[i].Unique_Master_Territory__c!=null); 
                	System.assertEquals(Updatedterrlst[i].Unique_Master_Territory__c, Updatedterrlst[0].Territory2ModelId+Updatedterrlst[i].Master_Territory_ID__c); 
               
            }
           
        }//End of System.run(usr)
    }//end of method
    
     /** 
     *@Author Original: Shweta Shanbhag - MathWorks
     *@Last Modified:  Shweta Shanbhag
     *@Date Original: 8/16/16
     *@Last Modified: 
     *@Description: Test Method to check generation and population of Master Territory Id when Master Territory id updated from value to null
     */
     
    private static testMethod void populatemasterterritoryidonupdate(){
            
        //Create dummy User
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;

        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        
        //Fetch from General Setting
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        Territory_Settings__c terrset = Territory_Settings__c.getInstance(UserInfo.getOrganizationId());//fg
        boolean MasterFlag = terrset.Generate_Master_Territory_Flag__c;//fg
        
        //intialize all variable
        Territory2Model model; 
        List<Territory2> insertedTerritory2Lst = new List<Territory2>();      
        List<Territory2> territoryLstNew =new List<Territory2>();
        List<Territory2> terrLstupdate =new List<Territory2>();
        List<Territory2> Updatedterrlst =new List<Territory2>();
        List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
        
        System.runAs(usr){ 
            
            Territory2Type typeTest=[select id from Territory2Type limit 1];
    
            territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
            if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
            
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<=49;i++){
                    
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
                dummyTerritory2.Master_Territory_ID__c = 'TM' + i;
                dummyTerritory2.Unique_Master_Territory__c= dummyTerritory2.Territory2ModelId+dummyTerritory2.Master_Territory_ID__c;//fg
                
                
                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){
        
                    dummyTerritory2.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory2.Territory2ModelId=model.id;
                }
                dummyTerritory2.Territory2TypeId=typeTest.id;
        
                territoryLstNew.add(dummyTerritory2);
            }//End of For Loop
            
            //Inserting the Territory2 Object List.
            insert territoryLstNew;
       
            insertedTerritory2Lst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c
                                      ,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c
                                      ,Territory_Sales_Group__c, Unique_Master_Territory__c, Include_In_Sales_Hierarchy__c FROM Territory2 WHERE Id IN: territoryLstNew]; //HW
            
            
             for(territory2 terr2obj: insertedTerritory2Lst){                
                 terr2obj.Master_Territory_ID__c = null;   
                 terrLstupdate.add(terr2obj);
                }
            
            Test.startTest(); 
            
            update terrLstupdate;
            
            Test.stopTest(); 
            
 			Updatedterrlst  = [SELECT Id,Name,Siebel_Territory_ID__c,Master_Territory_ID__c,DeveloperName,Global_Region__c,Region__c
                                      ,Office_Group__c,Office__c,Office_Channel__c,Territory_Industry__c,Territory_Sales_Team_Type__c
                                      ,Territory_Sales_Group__c,Unique_Master_Territory__c FROM Territory2 WHERE Id IN: terrLstupdate]; 
            
           
           // for(Integer i=0;i<=49;i++){                
                   // System.assert(Updatedterrlst[i].Master_Territory_ID__c!=null);               
               // }
            for (Integer i=0;i<=49;i++){
                if (MasterFlag == true){
                    System.assert(Updatedterrlst[i].Master_Territory_ID__c!=null); 
                    System.assert(Updatedterrlst[i].Unique_Master_Territory__c!=null);//fg
                }
                else{
                    System.assertEquals(Updatedterrlst[i].Unique_Master_Territory__c, null);
                    System.assertEquals(Updatedterrlst[i].Master_Territory_ID__c, null);//(insertedTerritory2Lst[i].Master_Territory_ID__c='');  
                }     
            }
        }//End of System.run(usr)
    }//End of Method.
    
      /** 
     *@Author Original: Shweta Shanbhag - MathWorks
     *@Last Modified:  Shweta Shanbhag
     *@Date Original: 9/6/16
     *@Last Modified: 
     *@Description: Test Method to check if all primary sales rep attributes are returned 
     */
    private static testMethod void getprimarysalesreptest(){
        
        User usr = TestDataBuilder.buildTestUser(100); 
        insert usr;
        
        csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());
        String SalesRepPrimary=System.Label.FunRole_SalesRepPrimary;
        String SalesManager=System.Label.FunRole_SalesManager;
        List<String> functionalRoleList=new  List<String>{SalesManager,SalesRepPrimary};
        List<User> userWithRoleLst=new List<User>();
    	List<userterritory2Association> userAssoObjListToInsert=new List<userterritory2Association>();
        Map<id,UserTerritory2Association> TerritoryPrimarySalesRep = new  Map<id,UserTerritory2Association>();
        

         System.runAs(usr){ 
            
             
             List<Territory2> territory2Lst =new List<Territory2>();
             Set<ID> terr2Set = new Set<ID>();
             List<Territory2Model> territory2ModelLst =new List<Territory2Model>();       
             Territory2Model model;
             Territory2Type typeTest=[select id from Territory2Type limit 1];
          	 territory2ModelLst=[select id,state from Territory2Model where state='Active' limit 1];
    
             if(territory2ModelLst==null || territory2ModelLst.isEmpty()){
                model=TestDataBuilder.buildTestTerritory2Model(0);
                insert model;
            }
         
         for(Integer i=0;i<1;i++){
                Territory2 dummyTerritory2=TestDataBuilder.buildTestTerritory2(i);
                dummyTerritory2.Siebel_Territory_ID__c='1-UIOPYU'+i;
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
             
             for (territory2 terrobj: territory2Lst)
             {
                 terr2Set.add(terrobj.id);
             }
        
        
      //Insert User Record with functional roles
            for(Integer i=0;i<functionalRoleList.size();i++){
                User usrObj = TestDataBuilder.buildTestUser(i); 
                usrObj.Functional_Role__c=functionalRoleList[i];
                usrObj.FirstName= 'TUserFN' + i;
                usrObj.LastName = 'TUserLN' + i;
                userWithRoleLst.add(usrObj);
            }
            insert userWithRoleLst;    
        
            
             //Insert int UserTerritory2Association Object
             Integer count=2;
            //add users to territory2
            for(Integer i=0;i<1;i++){
      
                for(Integer j=0;j<count;j++){
                    userterritory2Association userAssObj=TestDataBuilder.buildTestUserterritory2Association(userWithRoleLst[j].id,territory2Lst[i].id);
                    userAssoObjListToInsert.add(userAssObj);
                }
                count--;
            }

            insert userAssoObjListToInsert;
            
      
 		test.StartTest();
		
             TerritoryPrimarySalesRep = Territory2HandlerDML.getprimarysalesrep(terr2Set);

		test.StopTest();     
             
           System.AssertEquals(TerritoryPrimarySalesRep.get(territory2Lst[0].id).User.Name, 'TUserFN1 TUserLN1' );
           System.AssertEquals(TerritoryPrimarySalesRep.get(territory2Lst[0].id).User.Email, 'tuser1@mathworks.com');
   
         }        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}//End of Class.