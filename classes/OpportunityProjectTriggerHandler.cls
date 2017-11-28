/**
*author Original: Sagar Talele - Cloud Sherpas/Mathworks
*date Original: 1 April 2015, Last Modified:
*description : This  is handler class for 'OpportunityProjectTrigger'  
*revision:
*/
public class OpportunityProjectTriggerHandler {

      /**
        *author Original: Sagar Talele - Cloud Sherpas/Mathworks
        *date Original: 1 April 2015, Last Modified: 
        *description Method that handles before insert trigger event on the  Opportunity Project 
        */
    public void onBeforeInsert(List<Opportunity_Projects__c> List_OpportunityProject){
          Logger.push('onBeforeInsert','OpportunityProjectTriggerHandler');
          OpportunityProjectDml oppProDml = new OpportunityProjectDml();
          Map<Id,List<Opportunity_Projects__c>> mapOppProject = new Map<Id,List<Opportunity_Projects__c>>();
          set<Id> projectId = new set<Id>();
          List<MW_Project__c> UpdateProjectList = new List<MW_Project__c>();
          List<MW_Project__c> projectList = new List<MW_Project__c>();
         
            for(Opportunity_Projects__c oppProjObj:List_OpportunityProject){
                if(!mapOppProject.containsKey(oppProjObj.Project__c)){
                    mapOppProject.put(oppProjObj.Project__c,new List<Opportunity_Projects__c>{oppProjObj});
                }
                else{
                    mapOppProject.get(oppProjObj.Project__c).add(oppProjObj);
                }
                projectId.add(oppProjObj.Project__c);
            }
           projectList = [Select Id,Opportunity__c from MW_Project__c where Id in :projectId and Opportunity__c = null];
            if(projectList.size()>0){
                for(MW_Project__c proObj: projectList){
                        if(proObj.Opportunity__c==null){
                            proObj.Opportunity__c = mapOppProject.get(proObj.Id)[0].Opportunity__c;
                            UpdateProjectList.add(proObj);
                        }
                    }
           }
        if(UpdateProjectList.size()>0){
                 oppProDml.updateOpportunityOnProject(UpdateProjectList);
            }
              
          
        
          Logger.Pop();
    }   
    /**
    *author Original: Faina Gorelik 
    *date Original: 09 January 2016, Last Modified:
    *description : AtTask 1135328 - update Opty Id associated witht the project when the record has been removed from the junction object. 
    *Searching junction table for the earliest opty to associate with the project as primary project opportunity id
    *revision:
    */
    public void onAfterDelete(List<Opportunity_Projects__c> List_OpportunityProject){
    
        Logger.push('onAfterDelete','OpportunityProjectTriggerHandler');
        Map<Id,Set<Id>> mapProjIdOptyIds = new Map<Id, Set<Id>>();// map of the deleted project with opty records 
        set<Id> projectIdset = new set<Id>(); // deleted project ids from deleted opportunity project list 
        List<MW_Project__c> projectList = new List<MW_Project__c>();//list of projects ids in MW_Project table matching project ids in the deleted map
        List<MW_Project__c> projectwithPrimOppty = new List<MW_Project__c>();// list of the projects from the deleted list  with Primary Opportunity Id to be updated
        set <Id> projectIdupdset = new set<Id>(); // MW Projects table project Ids where Primary Opty will be updated or set to null
        List<Opportunity_Projects__c> UpdateProjectList = new List <Opportunity_Projects__c>();//Faina activated and updated the list after review with Kishore Opportunity Projects table records with the min created opportunity 
        List<MW_Project__c> ProjectUpdatePrimOpty =  new List <MW_Project__c>(); // the final list of the project with the updated opportunity value to be updated
        OpportunityProjectDml oppProDml = new OpportunityProjectDml();
        set<id> optyprojectidset = new set<Id>();// ids of the deleted records from Opportunity Project list

        for(Opportunity_Projects__c oppProjObj:List_OpportunityProject){// build the map with the deleted opty project records
            if(!mapProjIdOptyIds.containsKey(oppProjObj.Project__c)){

                mapProjIdOptyIds.put(oppProjObj.Project__c,new Set<Id>{oppProjObj.Opportunity__c});
            }
            else{
                mapProjIdOptyIds.get(oppProjObj.Project__c).add(oppProjObj.Opportunity__c);
            }
            projectIdset.add(oppProjObj.Project__c);// list of the  Project Ids for deleted opportunity project records    
            optyprojectidset.add(oppProjObj.Id);// ids of the deleted records from Opportunity Project list
            projectList = [Select Id,Opportunity__c from MW_Project__c where Id in :projectIdset];// list of project ids in MW_Project_c table with the current primary opty ids   
        }
        if (projectlist.size()>0){
                for(MW_Project__c ProjwithOpty : projectList){
          
                    if(mapProjIdOptyIds.containsKey(ProjwithOpty.Id) && mapProjIdOptyIds.get(ProjwithOpty.Id).contains(ProjwithOpty.Opportunity__c) ){// deleted from opty project table project id found in project table
                        projectwithPrimOppty.add(ProjwithOpty);// build list of the projects of MW_Project__c table where prim opportunity has to be updated
                        projectIdupdset.add(ProjwithOpty.Id); // list of the ids where primary opty will be updated or set to null
                    }
                    // find if there are more records in the junction table for list of the deleted with the primary opportunity projects
                    if (projectwithPrimOppty.size() >0){   
                        UpdateProjectList = [SELECT Project__c, Opportunity__c,Createddate from Opportunity_Projects__c where Project__c in : projectIdupdset and Id not in : optyprojectidset Order By Project__c,Createddate];
                        if (UpdateProjectlist.size()>0){
                            Id currentrecordId;
                            Id prevrecordid;
                      // list contains duplicates, since it's sorted the only the first (earliest) opportunity Id has to be in the final list. Duplicates will be removed                       
                            for ( integer i = 0;i<UpdateProjectList.size();i++)  {
                                Opportunity_Projects__c  newUpdateList = UpdateProjectList[i];
                                currentrecordId = newUpdateList.Project__c;
                                if (currentrecordid == prevrecordid){
                                    UpdateProjectList.remove(i);
                                    currentrecordid = prevrecordid;
                                }
                                // build the list of the projects with updated primary opportunithy id
                                ProjwithOpty.Opportunity__c = newUpdateList.Opportunity__c;
                                ProjectUpdatePrimOpty.add(ProjwithOpty);
                                i++;
                                
                            }// end for integer loop
                        
                        }// end if UpdateList.size
                        else{// no records in junction table, set Primary Opty Id on the project to null
                            ProjwithOpty.Opportunity__c = null;
                            ProjectUpdatePrimOpty.add(ProjwithOpty);
                        }               
                    }// end build list of the projects to be updated 
                }// end build ProjwithOpty list
            
            if(ProjectUpdatePrimOpty.size()>0){
                oppProDml.updateOpportunityOnProject(ProjectUpdatePrimOpty);
            }       
        }  // end of the projectlist.size ()
        Logger.Pop();
    }
}