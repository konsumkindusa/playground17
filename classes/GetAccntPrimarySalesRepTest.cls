/**
 *@author Original: Shweta Shanbhag - Mathworks
 *@date Original:9/6/2016
 *@description: Test class for getaccntprimarysalesrep class
 */


@isTest(seeAlldata=true)
public class GetAccntPrimarySalesRepTest {
          
private static testmethod void UpdategetFBsalesrepemail()
{
    CustomSettingsBuilder csb = new CustomSettingsBuilder();
    String SalesRepPrimary=System.Label.FunRole_SalesRepPrimary;
    String SalesManager=System.Label.FunRole_SalesManager;
     List<String> functionalRoleList=new  List<String>{SalesManager,SalesRepPrimary};
    List<User> userWithRoleLst=new List<User>();
    List<userterritory2Association> userAssoObjListToInsert=new List<userterritory2Association>();
    User usr = TestDataBuilder.buildTestUser(100); 
    insert usr;
    
     	csb.buildBypassTriggerSettings();
        csb.buildGenSetting();
        csb.buildTerritorySettings();
        General_Settings__c settings = General_Settings__c.getInstance(UserInfo.getOrganizationId());

     System.runAs(usr){ 
         
         List<Account> accLLst =new List<Account>();
         List<Account> accLLstUpdate =new List<Account>();
         List<Territory2> territory2Lst =new List<Territory2>();
         List<Territory2Model> territory2ModelLst =new List<Territory2Model>();
         List<Get_Feedback__c> GetFbLst = new List<Get_Feedback__c>();
         List<Id> GetFBIdList = new List<ID>();         
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

//*************************************Insert User (Territory team dummy user) Object*****************************************//

            //Insert User Record with functional roles
            for(Integer i=0;i<functionalRoleList.size();i++){
                User usrObj = TestDataBuilder.buildTestUser(i); 
                usrObj.Functional_Role__c=functionalRoleList[i];
                userWithRoleLst.add(usrObj);
            }
            insert userWithRoleLst;

  //*************************************Insert Userterritory2Association Object*****************************************//

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
            
         
      
       for(Integer i=0;i<10;i++){
                Account acc = acclLst[i];
                acc.Siebel_Territory_ID__c=territory2Lst[0].Siebel_Territory_ID__c;
                acc.Master_Territory_ID__c=territory2Lst[0].Master_Territory_ID__c;

                accLLstUpdate.add(acc);  

            }
          update accLLstUpdate; 
         
         
  //*************************************Insert Case Object*****************************************//       
         
          
              Case caserec = TestDataBuilder.buildTestCase('Open');
              caserec.AccountId = accLLst[0].id;
           	  caserec.OwnerId = usr.Id;
       		  insert caserec;
         
  //*************************************Insert GetFeedback Object*****************************************//   
  		 Id getFBServiceRecTypeId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        
          for(Integer i=0;i<10;i++){
              Get_Feedback__c getFBObj = TestDataBuilder.buildgetfeedback(i);
              getFBObj.RecordTypeId = getFBServiceRecTypeId;
              getFBObj.case__c = caserec.id;
              getFBObj.Service_Primary_Sales_Rep_email__c = '';
              getFBObj.Service_Case_Owner__c = usr.Id;
              GetFbLst.add(getFBObj);    
          }
         
         insert GetFbLst;
         
         for(Get_Feedback__c getFBObj2: GetFbLst )
         {
             GetFBIdList.add(getFBObj2.id);
         }
        
         test.StartTest();
         
         GetAccntPrimarySalesRep.getPrimarySalesRepEmail(GetFBIdList);
         
         Test.stopTest();
         
         List<Get_Feedback__c> GetFBUpdLst = [Select id, Service_Primary_Sales_Rep_email__c from  Get_Feedback__c where id in: GetFBIdList];
         for(Integer i=0;i<10;i++){
        
         System.assertNotEquals(GetFBUpdLst[i].Service_Primary_Sales_Rep_email__c, null);
         
         }
     }
    
}
    
}