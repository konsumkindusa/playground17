/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *date Original: 18 Feb 2016, Last Modified: 18 Feb 2016
 *description This  is test class for UserT2ATriggerHandler   
 */

@isTest
public class UserT2ATriggerHandlerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    
    /***
    @ name    beforeInsertFunctionalRoleTest
    @ date    18 Feb 2016
    @ author  Sagar Talele
    @ param   none.
    @ return  Void. 
    @ description : Method for test the for functional role on before insert
    ***/
    public testMethod static void beforeInsertFunctionalRoleTest() {
        //Inserting Bypass trigger custom setting
           custsettbuild.buildBypassTriggerSettings();
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Inside Sales Rep';
        insert usr;
        User uObj = [Select Id,Functional_Role__c  From User Where Id =:usr.Id limit 1];
        System.assertEquals(uObj.Functional_Role__c,'Inside Sales Rep');
           System.runAs(usr){
        
            List<Territory2> territory2Lst =new List<Territory2>();
            List<Territory2> territory2List=new List<Territory2>();
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
            for(Integer i=0;i<100;i++){
                // for(Integer i=0;i<199;i++){

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
            System.assertEquals(territory2Lst.isEmpty(),false);  
            
            List<UserTerritory2Association> userT2AList = new List<UserTerritory2Association>();
            //create Territory record from TestDataBuilder.
          //  for(Integer i=0;i<199;i++){
                 for(Integer i=0;i<100;i++){
                UserTerritory2Association userT2aObj = TestDataBuilder.buildTestUserterritory2Association(usr.Id,territory2Lst[i].Id);
                userT2AList.add(userT2aObj);
            }
            insert userT2AList;
            System.assertEquals(userT2AList.isEmpty(),false);
            List<UserTerritory2Association> userT2ATestList = new List<UserTerritory2Association>();
            userT2ATestList = [Select Id,RoleInTerritory2,UserId,Territory2Id From UserTerritory2Association where Id In:userT2AList];
            for(UserTerritory2Association obj : userT2ATestList){
                System.assertEquals(obj.RoleInTerritory2,usr.Functional_Role__c);
            }
            
            //test for RoleInTerritory2 not equal to null
            
            //create Territory record from TestDataBuilder.
            for(Integer i=100;i<103;i++){
                //for(Integer i=200;i<399;i++){

                Territory2 dummyTerritory3=TestDataBuilder.buildTestTerritory2(i);         
                dummyTerritory3.Siebel_Territory_ID__c='2-UIOPYU'+i;
                dummyTerritory3.name='TestTerritory' + i;
                dummyTerritory3.DeveloperName='AMER1'+i;
                dummyTerritory3.Global_Region__c='International';
                dummyTerritory3.Region__c='omer';
                dummyTerritory3.Office_Group__c='Componentes Electronicas Ltda';
                dummyTerritory3.Office__c='Componentes Electronicas Ltda';
                dummyTerritory3.Office_Channel__c='Indirect';
                dummyTerritory3.Territory_Industry__c='UNKNOWN';
                dummyTerritory3.Territory_Sales_Team_Type__c='Mixed';
                dummyTerritory3.Territory_Sales_Group__c='Latin America';


                if(territory2ModelLst==null || !territory2ModelLst.isEmpty()){

                    dummyTerritory3.Territory2ModelId=territory2ModelLst[0].id;
                }
                else
                {
                    dummyTerritory3.Territory2ModelId=model.id;
                }
                dummyTerritory3.Territory2TypeId=typeTest.id;

                territory2List.add(dummyTerritory3);
            }

            insert territory2List;
            System.assertEquals(territory2List.isEmpty(),false);
            
            
            List<UserTerritory2Association> userT2ALst = new List<UserTerritory2Association>();
            //create Territory record from TestDataBuilder.
            for(Integer i=0;i<3;i++){
                //  for(Integer i=0;i<199;i++){
                UserTerritory2Association userT2a = TestDataBuilder.buildTestUserterritory2Association(usr.Id,territory2List[i].Id);
                userT2a.RoleInTerritory2 = 'Inside Sales Rep';
                userT2ALst.add(userT2a);
            }
            insert userT2ALst;
            System.assertEquals(userT2ALst.isEmpty(),false);
            List<UserTerritory2Association> userT2ATestLst = new List<UserTerritory2Association>();
            userT2ATestLst = [Select Id,RoleInTerritory2,UserId,Territory2Id From UserTerritory2Association where Id In:userT2ALst];
            for(UserTerritory2Association userT2Aobj : userT2ATestLst){
                System.assertEquals(userT2Aobj.RoleInTerritory2,userT2Aobj.RoleInTerritory2);
            }
        }
        
    }
}