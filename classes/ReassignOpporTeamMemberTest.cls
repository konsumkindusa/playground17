/**
* @author Original:Jaspreet Monga
* @date Original: 7/24/2014
* @description test class for testing all functionality on ReassignOpporTeamMember and OpportunityTrigger
*/ 
@isTest
private class ReassignOpporTeamMemberTest{
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
  static testMethod void testfetchOppteamdetails(){
      
      Organization orgObj=new Organization();

      /*** Create users *****/
      
      User objUser1 = TestDataBuilder.buildTestUser(1);
      insert objUser1; 
      
      User objUser2 = TestDataBuilder.buildTestUser(2);
      insert objUser2;
      
      User objUser3 = TestDataBuilder.buildTestUser(3);
      insert objUser3;    
      
      csb.buildBypassTriggerSettings();
      csb.buildGenSetting();
      /***** Create opportunities *****/
      Account acctL = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
      insert acctL;
      
      Opportunity objOpportunity = TestDataBuilder.buildTestOpportunity(1);
      objOpportunity.AccountId = acctL.Id;
      objOpportunity.OwnerId = objUser1.Id;
      insert objOpportunity;
      
      Opportunity objOpportunity2 = TestDataBuilder.buildTestOpportunity(1);
      objOpportunity2.AccountId = acctL.Id;
      objOpportunity.OwnerId = objUser2.Id;
      insert objOpportunity2;           
      
      
      /*** Create opportunity team memeber ****/
      
      OpportunityTeamMember newOpportunityTeamMember = new OpportunityTeamMember();
      newOpportunityTeamMember.UserId = objUser1.Id;
      newOpportunityTeamMember.OpportunityId = objOpportunity.Id;
      insert newOpportunityTeamMember;      
      
      OpportunityTeamMember newOpportunityTeamMember1 = new OpportunityTeamMember();
      newOpportunityTeamMember1.UserId = objUser2.Id;
      newOpportunityTeamMember1.OpportunityId = objOpportunity.Id;
      insert newOpportunityTeamMember1;
      
      OpportunityTeamMember newOpportunityTeamMember2 = new OpportunityTeamMember();
      newOpportunityTeamMember2.UserId = objUser1.Id;
      newOpportunityTeamMember2.OpportunityId = objOpportunity2.Id;
      insert newOpportunityTeamMember2;      
      
      OpportunityTeamMember newOpportunityTeamMember3 = new OpportunityTeamMember();
      newOpportunityTeamMember3.UserId = objUser3.Id;
      newOpportunityTeamMember3.OpportunityId = objOpportunity2.Id;
      insert newOpportunityTeamMember3;
      
      Organization myOrg = [Select Id, DefaultOpportunityAccess, DefaultCaseAccess from Organization];  
      
      orgObj=UtilityHelper.getOrganizationObject();
   
      if(orgObj.DefaultOpportunityAccess!='Edit'){
      
      OpportunityShare optyShareObj = new OpportunityShare();
      optyShareObj.OpportunityId=objOpportunity.id;
      optyShareObj.OpportunityAccessLevel='Edit';
      optyShareObj.userOrGroupid = objUser2.Id;
      insert optyShareObj;
      
           
      
      /*** Query opportunity shares to give edit access to team members who had edit access before reassignment of owner ***/
      
      List<OpportunityShare> listOpporShares = [select Id,UserOrGroupId,OpportunityId,OpportunityAccessLevel,RowCause from OpportunityShare where OpportunityId = :objOpportunity.Id and RowCause = 'Team'];
      listOpporShares[0].OpportunityAccessLevel ='Edit';
      update listOpporShares[0];
      }
      
      objOpportunity.OwnerId = objUser2.Id;
      update objOpportunity;
      
      List<OpportunityTeamMember> listOpporTeamAssert = [select Id from OpportunityTeamMember where OpportunityId = :objOpportunity.Id];
      
      system.assertequals(listOpporTeamAssert.size(),2);
      
      
  }
}