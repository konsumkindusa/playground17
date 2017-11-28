/**
 *author Original: Andre Calimlim
 *date Original: 4 Aug 2014
 *last modified by:Archana Lohar
 *description This  is handler class for 'MW_Project__c' custom object. 
 */

public with sharing class ProjectTriggerHandler {
    /**
     * @author Original: Andre Calimlim
     * @date Original: 11 Aug 2014
     * @description Method that handles before insert trigger event on the MW_Project__c object
     * @param recList | A collection of MW_Project__c that was inserted
     */
    public void onBeforeInsert(List<MW_Project__c> recList){
        Logger.push('onBeforeInsert', 'ProjectTriggerHandler');
        ProjectDML projDML = new ProjectDML();
        Map<Id, Id> mapOppOnProject = new Map<Id, Id>();
        
        //HW, Sprint 2016.7.2, story 1572316
        set<Id> setId = new set<Id>();
        map<Id, Contact> mapContact = new map<Id, Contact>();
        
        for(MW_Project__c pr : recList){
            if (pr.Customer_Contact__c != null) {
            	setId.add(pr.Customer_Contact__c);
            } 
        }
        if (! setId.isEmpty()) {
        	mapContact = new map<Id, Contact>([select Id, AccountId from Contact where Id in :setId]);
        }
        
        for(MW_Project__c pr : recList){
            if(pr.Opportunity__c != null){
                mapOppOnProject.put(pr.Id, pr.Opportunity__c);
            }
            
            if (pr.Customer_Contact__c != null) {
            	pr.Account__c = mapContact.get(pr.Customer_Contact__c).AccountId;
            } 
        }

        projDML.insertProjectAreaFromRequestor(reclist);
        Logger.pop();
    }
    
     /**
     * @author Original: Archana Lohar
     * @date Original: 12  Sep 2014
     * @description Method that handles before update trigger event on the MW_Project__c object
     * @param recList | A collection of MW_Projetct__c that was updated
     */
    public void onBeforeUpdate(List<MW_Project__c> recList){
        Logger.push('onBeforeUpdate', 'ProjectTriggerHandler');
        
        List<MW_Project__c> projList=new  List<MW_Project__c>();
        
        ProjectDML projDML = new ProjectDML();
       
        for(MW_Project__c pr : recList){
            
            if(pr.Project_Status__c == 'Closed'){
                
                projList.add(pr);
            }
            
            
        }

        projDML.validateProjectBeforeClose(projList);
        Logger.pop();
    }
    /**
     * @author Original: Andre Calimlim
     * @date Original: 4 Aug 2014
     * @description Method that handles after insert trigger event on the MW_Project__c object
     * @param recList | A collection of MW_Project__c that was inserted
     */
    public void onAfterInsert(List<MW_Project__c> recList){
        Logger.push('onAfterInsert', 'ProjectTriggerHandler');
        ProjectDML projDML = new ProjectDML(); 
        
        General_Settings__c genSet = General_Settings__c.getInstance();
        
        Map<Id, Id> mapOppOnProject = new Map<Id, Id>();
        Map<Id, Id> mapAccOnProject = new Map<Id, Id>();
        Map<Id, Id> mapCampOnProject = new Map<Id, Id>();
        
        List<MW_Project__c> projectList=new List<MW_Project__c>();
        List<id> ownerlist=new List<id>();
        List<String> recTypesToInclude = genSet.RTToIncludeAddingProjTeamMemberOnInsert__c.split(',');
       
        system.debug(recList+'recListrecListrecListrecListrecListrecListrecList');
        
        //Set<Id> projIds = new Set<Id>();
        for(MW_Project__c pr : recList){
            
            if(pr.Opportunity__c != null){
                //projIds.add(pr.Id);
                mapOppOnProject.put(pr.Id, pr.Opportunity__c);
            }
            
              if(pr.account__c != null){
              
                mapAccOnProject.put(pr.Id, pr.account__c);
               
            }
            
             if(pr.campaign__c != null){
              
                mapCampOnProject.put(pr.Id, pr.campaign__c);
               
             }
          
        }
        
        system.debug(mapAccOnProject+'mapAccOnProjectmapAccOnProjectmapAccOnProjectmapAccOnProject');
        
        projectList=[select id,ownerid,recordType.name from MW_Project__c where recordType.name in:recTypesToInclude and id in:recList];
      
        //add Users to ProjectTeam if owner is user not queue
        projDML.addUsersToProjectTeam(projectList);
        
        System.debug('***AfterInsert***');
        //Create Opportunity Project Junction
        projDML.createOpportunityProject(mapOppOnProject);
        projDML.createAccountProject(mapAccOnProject);
        projDML.createCampaignProject(mapCampOnProject);
        
        
        Logger.pop();
    }
    
    
    /**
     * @author Original: Archana Lohar
     * @date Original: 9 August 2014
     * @description Method that handles after update trigger event on the MW_Project__c object
     * @param oldmap MW_Project__c records with old values
     * @param newmap MW_Project__c records with new values
     */
    public void onAfterUpdate(map<Id, MW_Project__c> oldmap, map<Id, MW_Project__c> newmap){
        
        Logger.push('onAfterUpdate', 'ProjectTriggerHandler');
        
        ProjectDML projDML = new ProjectDML();
        
        List<MW_Project__c> projectList=new List<MW_Project__c>();
        List<MW_Project__c> projectListForTask=new List<MW_Project__c>();
        
            for(Id tempProject:oldmap.keySet()){
                
                if(newmap.get(tempProject).ownerid != oldmap.get(tempProject).ownerid ){
    
                    projectList.add(newmap.get(tempProject));
                    
                }
                
                // Added by jaspreet for user story : 7713004 
                if(newmap.get(tempProject).Last_Project_Review_Date__c != oldmap.get(tempProject).Last_Project_Review_Date__c){
                 projectListForTask.add(newmap.get(tempProject));
                 }
            }
            
                      
            projDML.addUsersToProjectTeam(projectList);
            projDML.updateIsHrsOnTimeCard(projectListForTask);
                    
        Logger.pop();
    }

}