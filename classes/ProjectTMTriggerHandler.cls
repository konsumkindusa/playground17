/**
 *author Original: Jaspreet Monga (Mathworks)
 *date Original: 10/1/2014
 *description : this is handler class for trigger on project team member custom object     
       
 */


public class ProjectTMTriggerHandler{

    ProjectTMDML objprojectTMDML = new ProjectTMDML();
    
    public void onBeforeInsert(List<Project_Team_Member__c> listProjectTeamMemeber){
      objprojectTMDML.updateRequester(listProjectTeamMemeber);
    }
    public void onAfterInsert(Map<Id,Project_Team_Member__c> mapProjectTeamMemeber){
        objprojectTMDML.makeDataSets(mapProjectTeamMemeber);
        objprojectTMDML.insertFirstAssignedDateForProject(mapProjectTeamMemeber);
    }
    public void onAfterUpdate(Map<Id,Project_Team_Member__c> mapProjectTeamMemeber){
        objprojectTMDML.makeDataSets(mapProjectTeamMemeber);
    }
    public void onAfterDelete(Map<Id,Project_Team_Member__c> mapProjectTeamMemeber){
        objprojectTMDML.makeDataSets(mapProjectTeamMemeber);
    }
    public void onAfterUnDelete(Map<Id,Project_Team_Member__c> mapProjectTeamMemeber){
        objprojectTMDML.makeDataSets(mapProjectTeamMemeber);
    }
    
    
    
}