/**
 *author Original: Jaspreet Monga (Mathworks)
 *date Original: 10/1/2014
 *description : class have following methods
 
 updateRequester: this methods gets called on before insert event of trigger 
    param: list of projectTeamMember
    assigns requester from parent project record to projectTeamMember 
 makeDataSets: this method gets called on after insert,update,undelete and before delete events of trigger
    param: map of projectTeamMember
        - queries parent project record of project team member
        - queries relared project team members to those project records
        - creates a map of project id and string with resource ids from projectTeamMember
        - converts map to list of projects
        - updates list of projects
       
 */

public class ProjectTMDML{


public void updateRequester(LIST<Project_Team_Member__c> listProjectTM){

List<ID> listIDproject = new List<ID>();
for(Project_Team_Member__c objProjectTM : listProjectTM){
listIDproject.add(objProjectTM.Project__c);
}

Map<Id,MW_Project__c> mapIdProject = new map<Id,MW_Project__c>([Select Id,Requester__c from MW_Project__c where ID IN:listIDproject limit 50000]);

for(Project_Team_Member__c objProjectTM : listProjectTM){
    if(null != mapIdProject.get(objProjectTM.Project__c)){
        objProjectTM.Requester__c = mapIdProject.get(objProjectTM.Project__c).Requester__c;
    }    

}

}



public void makeDataSets(Map<Id,Project_Team_Member__c> mapProjectTeamMemeber){

    List<Id> listProjectIdProjectTM = new List<Id>();
    Map<Id,String> mapProjectIdRequester = new Map<Id,String>();
    List<MW_Project__c> listProject = new List<MW_Project__c>(); 

    for(Project_Team_Member__c projectTMObj: mapProjectTeamMemeber.values())
    {
      listProjectIdProjectTM.add(projectTMObj.project__c);
    }
    Map<Id,MW_Project__c> mapIdProject = new map<Id,MW_Project__c>([Select Id,Project_Team_Members__c from MW_Project__c where Id IN:listProjectIdProjectTM limit 500000]);
    List<Project_Team_Member__c> listRelatedProjectTM = [Select id,Resource__c,Project__c,Isdeleted  from Project_Team_Member__c where Project__c IN :listProjectIdProjectTM limit 50000];
     
    for(Project_Team_Member__c objProjectTM:listRelatedProjectTM)
    {
        if(!objProjectTM.isDeleted){
         String  strReqId = string.valueof(objProjectTM.Resource__c).substring(0,15).substring(10,15);
         
          if(null != mapProjectIdRequester.get(objProjectTM.Project__c))
          {
            strReqId = strReqId+','+ mapProjectIdRequester.get(objProjectTM.Project__c);
          }
          
          mapProjectIdRequester.put(objProjectTM.Project__c,strReqId);
        }
    
    }
    
    for(Id idProjecId: mapIdProject.keyset()){
        MW_Project__c objProject = new MW_Project__c();
        objProject = mapIdProject.get(idProjecId);
        
        if(null !=mapProjectIdRequester.get(idProjecId)){
            objProject.Project_Team_Members__c = mapProjectIdRequester.get(idProjecId)+',';
        }
        else
        {
            objProject.Project_Team_Members__c ='';
        }
        listProject.add(objProject );
        Logger.debug(idProjecId);
    }
    
   
         try{
                update listProject;
            }
         catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //capture Dml  Process exception 
                   Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
}
 /** 
     *@Author Original: Sagar Talele
     *@Last Modified:Sagar Talele - Cloud Sherpas/Mathworks
     *@Date Original: 26 November 2014
     *@Description: It will check First Assigned Date value if null then set value to current date/time on Project
     */ 
        public void insertFirstAssignedDateForProject(Map<Id,Project_Team_Member__c> mapProjectTeamMemeber){
        
            List<Project_Team_Member__c> projectTMList = new List<Project_Team_Member__c>();
            List<MW_Project__c> mwProjectList = new  List<MW_Project__c>();
            
            projectTMList = [SELECT id, 
                                    Project__c, 
                                    Project_Team_Member__c.Project__r.First_Assigned_Date__c 
                                    FROM  Project_Team_Member__c WHERE Id IN :mapProjectTeamMemeber.keyset()];
                                    
            for(Project_Team_Member__c ptm : projectTMList){
                if(ptm.Project__r.First_Assigned_Date__c == null  ){
                    MW_Project__c proj = new MW_Project__c();
                    proj.id = ptm.Project__c;
                    proj.First_Assigned_Date__c = DateTime.now();
                    mwProjectList.add(proj);
                }
            }
            try{
                update mwProjectList;
            
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //capture Dml  Process exception 
                   Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
            
        }
        /*End Of Class*/
}