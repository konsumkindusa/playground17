/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified:
 *@date Original: 19 Feb 2016, Last Modified: 
 *@description This  is a Test class for 'TerritorySalesTeamMemberComponentCC' . 
 *@Revision:
 */
 
@isTest
public class TerritorySalesTeamMemberComponentTest{

    /*
      @name         getTerritoryTeamMembersTest
      @date         22.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  To test the functionality to get the territory team members. 
        */
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    @testSetup static void insertTestData() {
         
        //Inserting Bypass trigger custom setting
        csb.buildBypassTriggerSettings();
        
        //Creating Test user
        User usr = TestDataBuilder.buildTestUser(0);
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
    
    private static testMethod void getTerritoryTeamMembersTest(){
        
        User usr = TestDataBuilder.buildTestUser(111);
        insert usr;
        
        system.runAs(usr){
            //test start
            test.startTest();
            
            //List of user to store the test user data.
            List<User> userLst = new List<User>();
            
            //Create test data user. 
            for(Integer i=1;i<=50;i++){
                User testUser = TestDataBuilder.buildTestUser(i);
                userLst.add(testUser);
            }
            
            //Inserting the user list.
            insert userLst;
            
            Territory2 territory2Rec = [SELECT Id FROM Territory2 LIMIT 1];
            Territory_Shadow__c territoryShadowObj = [SELECT Id FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c=: territory2Rec.Id LIMIT 1];
            List<User> testTerritoryUserLst = [SELECT Id FROM User WHERE Id IN: userLst];
            System.assertEquals(testTerritoryUserLst.size(), 50, True);
            List<UserTerritory2Association> dummyUserTerritoryAssociationLst = new List<UserTerritory2Association>();
            //Create territory2Association Object record
            for(Integer i=0;i<=49;i++){
                
                UserTerritory2Association usrTerritoryAssociationObj = TestDataBuilder.buildTestUserterritory2Association(testTerritoryUserLst[i].Id, territory2Rec.Id);
                //Adding usrTerritoryAssociationRecord 
                dummyUserTerritoryAssociationLst.add(usrTerritoryAssociationObj);
            }
            
            //insert userTerritoryAssociationLst 
            insert dummyUserTerritoryAssociationLst;
            
            //Querying the usrTerritoryAssociationLst.
            List<UserTerritory2Association> usrTerritoryAssociationLst = [SELECT Id, User.Id FROM UserTerritory2Association WHERE ID IN: dummyUserTerritoryAssociationLst]; 
            
            //Asserting the usrTerritoryAssociationLst for 50 Records.
            System.assertEquals(usrTerritoryAssociationLst.size(), 50, True);
            
            //Create the instamce of TerritorySalesTeamMemberComponentCC Class. 
            TerritorySalesTeamMemberComponentCC controllerObj = new TerritorySalesTeamMemberComponentCC();
            
            controllerObj.territoryRecId = territory2Rec.Id;
            controllerObj.userTerritoryList = usrTerritoryAssociationLst;
            controllerObj.territoryShadowId = territoryShadowObj.Id;
            controllerObj.teamUserAssociationId = usrTerritoryAssociationLst[0].Id; 
            controllerObj.getTerritoryTeamMembers();
            controllerObj.edit();
            
             //Get the url when the Edit link is clicked.
            String nextPage= controllerObj.edit().getUrl();
            //Asserting if the User redirect to the expected territory rule criteria value page or not.
            System.assertEquals(nextPage,'/'+usrTerritoryAssociationLst[0].Id+'/e?isdtp=nv&retURL=%2Fapex%2FTerritorysummary%3Fid%3D'+territoryShadowObj.Id, True);
            System.assertEquals(controllerObj.getTerritoryTeamMembers().size(), usrTerritoryAssociationLst.size());
            test.stopTest();
        }
    }
    
    private static testMethod void noTerritoryTeamMembersTest(){
        
        User usr = TestDataBuilder.buildTestUser(111);
        insert usr;
        
        system.runAs(usr){
            //test start
            test.startTest();
            
            //List of user to store the test user data.
            List<User> userLst = new List<User>();
            
            //Create test data user. 
            for(Integer i=1;i<=50;i++){
                User testUser = TestDataBuilder.buildTestUser(i);
                userLst.add(testUser);
            }
            
            //Inserting the user list.
            insert userLst;
            
            Territory2 territory2Rec = [SELECT Id FROM Territory2 LIMIT 1];
            Territory_Shadow__c territoryShadowObj = [SELECT Id FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c=: territory2Rec.Id LIMIT 1];
            List<User> testTerritoryUserLst = [SELECT Id FROM User WHERE Id IN: userLst];
            System.assertEquals(testTerritoryUserLst.size(), 50, True);
            List<UserTerritory2Association> dummyUserTerritoryAssociationLst = new List<UserTerritory2Association>();
            
            //Create the instamce of TerritorySalesTeamMemberComponentCC Class. 
            TerritorySalesTeamMemberComponentCC controllerObj = new TerritorySalesTeamMemberComponentCC();
            
            controllerObj.territoryRecId = territory2Rec.Id;
            controllerObj.userTerritoryList = null;
            controllerObj.territoryShadowId = territoryShadowObj.Id;
            controllerObj.teamUserAssociationId = null;
            controllerObj.getTerritoryTeamMembers();
            controllerObj.edit();
            
             //Get the url when the Edit link is clicked.
            String nextPage= controllerObj.edit().getUrl();
            //Asserting if the User redirect to the expected territory rule criteria value page or not.
            System.assertEquals(controllerObj.getTerritoryTeamMembers(), null, True);
            test.stopTest();
        }
    }
    
}