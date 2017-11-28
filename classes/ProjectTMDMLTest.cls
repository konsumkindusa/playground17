/**
 * Modified : Faina Gorelik
 * Date modified: 29 Nov 2016 AtTask #1777908 
 * description: This class contains unit tests for validating the behavior of ProjectDML, ProjectTriggerHandler classes
 * and ProjectMasterTrigger trigger.
 */
@isTest
private class ProjectTMDMLTest {
  
 
 
 static testMethod void testCreateProjectTM()
 {
 
    User usrObj=TestDataBuilder.buildTestUser(2);
    insert usrObj;
    string TeamMemberUser1 = string.valueof(usrObj.Id).substring(0,15).substring(10,15);
    User usrObjRef=TestDataBuilder.buildTestUser(3);
    insert usrObjRef;
    string TeamMemberUser2 = string.valueof(usrObjRef.Id).substring(0,15).substring(10,15);
    List<MW_Project__c> testList = TestDataBuilder.buildTestMWProject(2, 'Sales - Qualifications');
    for(MW_Project__c objMWProj : testList)
    {
        objMWProj.Requester__c = usrObj.Id;
        objMWProj.Purpose__c='Opportunity Support';
        objMWProj.outcome__c = 'WebEx';  
        objMWProj.Selling_Priorities__c ='None';
       
    }
    insert testList;
  
   
    Project_Team_Member__c objProjecTM = new Project_Team_Member__c();
    objProjecTM.Resource__c = usrObj.ID;
    objProjecTM.Project__c = testList[0].ID;
    if(testList[0].First_Assigned_Date__c == null){
    //MW_Project__c proj = new MW_Project__c();
    //proj.id=testList[0].ID;
    testList[0].First_Assigned_Date__c = DateTime.now();
    //testList.add(proj);
    }
    
    
    Project_Team_Member__c projecTM = new Project_Team_Member__c();
    projecTM.Resource__c = usrObjRef.ID;
    projecTM.Project__c = testList[0].ID;
    if(testList[0].First_Assigned_Date__c == null){
    testList[0].First_Assigned_Date__c = DateTime.now().addHours(3) ;
     }
    
   
    List<MW_Project__c> updatedProj0 = [Select Id, project_team_members__c from mw_project__c where id=:testList[0].Id];
    insert objProjecTM;
    
    List<MW_Project__c> updatedProj1 = [Select Id, project_team_members__c from mw_project__c where id=:testList[0].Id];
    System.assertEquals(TeamMemberUser1+',' + updatedProj0[0].project_team_members__c , updatedProj1[0].project_team_members__c);
    
    update objProjecTM;
    
    Update testList;
     
    insert projecTM;
   
    Update testList;
    
    List<MW_Project__c> updatedProj2 = [Select Id, project_team_members__c from mw_project__c where id=:testList[0].Id];
    System.assertEquals(TeamMemberUser2+',' + updatedProj1[0].project_team_members__c , updatedProj2[0].project_team_members__c);
    
    System.assertNotEquals(testList[0].First_Assigned_Date__c,DateTime.now().addHours(3));
    
    delete objProjecTM;
    List<MW_Project__c> updatedProj3 = [Select Id, project_team_members__c from mw_project__c where id=:testList[0].Id];
    System.assertEquals(TeamMemberUser2+',' + updatedProj0[0].project_team_members__c , updatedProj3[0].project_team_members__c);
    
    Undelete objProjecTM;
    List<MW_Project__c> updatedProj4 = [Select Id, project_team_members__c from mw_project__c where id=:testList[0].Id];
    System.assertEquals(TeamMemberUser2+',' + updatedProj1[0].project_team_members__c , updatedProj4[0].project_team_members__c);
 }
 
 
 
}