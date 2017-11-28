/**
* @author Original:Jaspreet Monga
* @date Original: 7/24/2014
* @description test class for testing all functionality on viewterritoryteam
*/ 
@isTest
private class territoryteamTest{

  static testMethod void testfetchterritoryteamdetails(){
  
      integer i = 1;
      CustomSettingsBuilder csb = new CustomSettingsBuilder();
      
      Territory2Model objTerritory2Model = TestDataBuilder.buildTestTerritory2Model(i);
      Territory2 objTerritory2 = TestDataBuilder.buildTestTerritory2(i);
      User objUser = TestDataBuilder.buildTestUser(i);
      insert objUser;
      System.RunAs(objUser){
      csb.buildBypassTriggerSettings();
      }
      insert objTerritory2Model;
      objTerritory2.Territory2ModelId =objTerritory2Model.Id;
      Territory2Type objTerritory2Type =[select id from Territory2Type limit 1];
      objTerritory2.Territory2TypeId = objTerritory2Type.Id;
      insert objTerritory2;
    
      
      
      UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association();
      objUserTerritory2Association.Territory2Id = objTerritory2.id;
      objUserTerritory2Association.UserId = objUser.Id;
      
     
      insert objUserTerritory2Association;
      viewterritoryteam testviewterritoryteam2 = new viewterritoryteam();   
      PageReference pageRef2 = Page.viewterritoryteams;
      pageRef2.getParameters().put('territoryId',objTerritory2.Id);     
      Test.setCurrentPage(pageRef2); 
      System.assertEquals('/apex/viewterritoryteams?territoryId='+objTerritory2.Id,pageRef2.getUrl());
      viewterritoryteam testviewterritoryteam = new viewterritoryteam();
      
  }


}