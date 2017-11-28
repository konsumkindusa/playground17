/**
 *@author Original: Andre Calimlim
 *@date Original: 4 Aug 2014
 *@Last Modified: kishore AN , 14 november 2014
 *@description This  is class to handle the DML operations for 'ProjectTriggerHandler' . 
 *@revision: Removed the methods assignProjectToOpp and clearOppOnProject as they are no longer reqquired and used, Faina Gorelik AtTask
 */
public without sharing class ProjectDML {

    /** 
     *@Author Original: Andre Calimlim
     *@Last Modified: Andre Calimlim - Cloud Sherpas/Mathworks
     *@Date Original: 4 Aug 2014 
     *@param: mapOppOnProject | Map of Project Id to Opportunity Id
     *@Description: It will accept the map of MW_Project__c having the related Opportunity 
     *               that will Create New Opportunity Project juntion
     */ 
    public void createOpportunityProject(Map<Id, Id> mapOppOnProject){
        Logger.push('createOpportunityProject','ProjectDML');
        if(!mapOppOnProject.isEmpty()){
            try{
                List<Opportunity> oppList = [SELECT Id, CurrencyIsoCode FROM Opportunity WHERE Id in : mapOppOnProject.values()];
                Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();

                for(Opportunity op: oppList){
                    mapOpp.put(op.Id, op);
                }
                if(!mapOpp.isEmpty()){

                    List<Opportunity_Projects__c> oppProjToAdd = new List<Opportunity_Projects__c>();
                    for(Id projId : mapOppOnProject.keyset()){

                        Opportunity_Projects__c newOppProj = new Opportunity_Projects__c();
                        newOppProj.Opportunity__c = mapOppOnProject.get(projId);
                        newOppProj.Project__c = projId;
                        newOppProj.CurrencyIsoCode = mapOpp.get(mapOppOnProject.get(projId)).CurrencyIsoCode;

                        oppProjToAdd.add(newOppProj);
                    }
                    insert oppProjToAdd;

                }

            }catch(Exception ex)
            {
                Logger.debugException(ex);
            }
        }
        Logger.pop();
    }

    /** 
     *@Author Original: Archana Lohar
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 9 Sep 2014 
     *@param: mapOppOnProject | Map of Project Id to Account Id
     *@Description: It will accept the map mapAccOnProject
     *               that will Create New Account Project juntion
     */ 
    public void createAccountProject(Map<Id, Id> mapAccOnProject){

        Logger.push('createAccountProject','ProjectDML');
        
       
        if(!mapAccOnProject.isEmpty()){

            try{
                
                List<Account> accList = [SELECT Id, CurrencyIsoCode FROM Account  WHERE Id in : mapAccOnProject.values()];

                Map<Id, Account> mapAcc = new Map<Id, Account>();

                for(Account acc: accList){

                    mapAcc.put(acc.Id, acc);
                }

                if(!mapAcc.isEmpty()){
                       
                    List<Account_Project__c> accProjToAdd = new List<Account_Project__c>();
                
                    for(Id projId : mapAccOnProject.keyset()){

                        Account_Project__c newAccProj = new Account_Project__c();
                        newAccProj.Account__c = mapAccOnProject.get(projId);
                        newAccProj.Project__c = projId;
                        newAccProj.CurrencyIsoCode = mapAcc.get(mapAccOnProject.get(projId)).CurrencyIsoCode;

                        accProjToAdd.add(newAccProj);
                    }
                    
                    insert accProjToAdd;

                }

            }catch(Exception ex)
            {
                Logger.debugException(ex);
            }
        }
        Logger.pop();
    }

    /** 
     *@Author Original: Archana Lohar
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 9 Sep 2014 
     *@param: mapCampOnProject | Map of Project Id to Campaign Id
     *@Description: It will accept the map mapCampOnProject
     *               that will Create New Campaign Project juntion
     */ 
    public void createCampaignProject(Map<Id, Id> mapCampOnProject){

        Logger.push('createCampaignProject','ProjectDML');

        if(!mapCampOnProject.isEmpty()){

            try{
                List<Campaign> campList = [SELECT Id, CurrencyIsoCode FROM Campaign  WHERE Id in : mapCampOnProject.values()];

                Map<Id, Campaign> mapCamp = new Map<Id, Campaign>();

                for(Campaign camp: campList){

                    mapCamp.put(camp.Id, camp);
                }


                if(!mapCamp.isEmpty()){

                    List<Campaign_Project__c> campProjToAdd = new List<Campaign_Project__c>();

                    for(Id projId : mapCampOnProject.keyset()){

                        Campaign_Project__c newCampProj = new Campaign_Project__c();
                        newCampProj.Campaign__c = mapCampOnProject.get(projId);
                        newCampProj.Project__c = projId;
                        newCampProj.CurrencyIsoCode = mapCamp.get(mapCampOnProject.get(projId)).CurrencyIsoCode;

                        campProjToAdd.add(newCampProj);
                    }

                    insert campProjToAdd;

                }

            }catch(Exception ex)
            {
                Logger.debugException(ex);
            }
        }
        Logger.pop();
    }

    /** 
     *@Author Original: Archana Lohar
     *@Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *@Date Original: 12 Sep 2014, Last Modified: 28 Jan 2015 
     *@param: projList | List of Project Object which has project status closed 
     *@Description: It will accept the List projList that will check that Every Project
     *              Team member listed has hours that are greater than zero. Added check for empty map
     */ 
    public void validateProjectBeforeClose(List<MW_Project__c> projListToAddError){

        Logger.push('validateProjectBeforeClose','ProjectDML');


        if(!projListToAddError.isEmpty()){

            try{

                //Initialize variables

                List<MW_Project__c> projList=new List<MW_Project__c>();

                String errorMessage=System.Label.ValidateProjectBeforeCloseErrorMessage;
                String errorMessageForRemainingMembers=System.Label.ValidateProjectBeforeCloseErrorMessage_NotAll;

                Map<id,Map<id,Id>> mapOfProjectIdToTimeCardOwner=new Map<id,Map<id,Id>>();

                Map<id,List<Project_Team_Member__c>> mapOfProjectIdToTeamList=new Map<id,List<Project_Team_Member__c>>();

                List<User> teamMemberList=new List<User>();

                //Query mw_project__c with related list Project_Teams__r and Project_Time_Cards__r
                projList=[select id, (select id,Resource__c,Resource__r.name from Project_Teams__r),
                          (select id,AE_PE__c from Project_Time_Cards__r) 
                          from mw_project__C 
                          where id in:projListToAddError];


                //For loop to fill map mapOfProjectIdToTimeCardOwner and mapOfProjectIdToTeamList
                for(MW_Project__c projObj:projList){


                    for (Project_Time_Card__c timeCards:projObj.Project_Time_Cards__r){

                        if(!mapOfProjectIdToTimeCardOwner.containsKey(projObj.id)){

                            mapOfProjectIdToTimeCardOwner.put(projObj.id,new Map<id,id>{timeCards.AE_PE__c => timeCards.id});
                        }
                        else{

                            mapOfProjectIdToTimeCardOwner.get(projObj.id).put(timeCards.AE_PE__c,timeCards.id);
                        }
                    }

                    for (Project_Team_Member__c teamMember:projObj.Project_Teams__r){

                        if(!mapOfProjectIdToTeamList.containsKey(projObj.id)){

                            mapOfProjectIdToTeamList.put(projObj.id,new list<Project_Team_Member__c>{teamMember});
                        }
                        else{

                            mapOfProjectIdToTeamList.get(projObj.id).add(teamMember);
                        }
                    }
                }

                //Check if there is a time card present for each member in Project Team
                for(MW_Project__c projObj:projListToAddError){
                    
                    String resourceNames='';
                    
                    if(!mapOfProjectIdToTeamList.isEmpty()){

                    for (Project_Team_Member__c teamMember:mapOfProjectIdToTeamList.get(projObj.id)){

                        if(mapOfProjectIdToTimeCardOwner.get(projObj.id)!=null){

                            if(!mapOfProjectIdToTimeCardOwner.get(projObj.id).containsKey(teamMember.Resource__c)){

                                String sBreak = '</br>';
                                resourceNames=resourceNames+sBreak+teamMember.Resource__r.name;
                                
                             }

                        }
                        else
                        {
                            String sBreak = '</br>';
                            resourceNames=resourceNames+sBreak+teamMember.Resource__r.name;
                        }
                    }
                    
                    if(resourceNames!=''){                        
                        String sBreak = '</br>';
                        projObj.addError(errorMessageForRemainingMembers+sBreak+resourceNames,false);

                    }

                }
                }

            }catch(Exception ex)
            {
                if(ex.getTypeName()=='DmlException'){                
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                           //capture Dml  Process exception 
                           Logger.debugException('DmlException :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                     }
                 }
                 else{                      
                      Logger.debugException('Exception :'+ex.getMessage());
                 }
            }
        }
        Logger.pop();
    }    
 

    /** 
     *@Author Original: Archana Lohar
     *@Last Modified:Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 9 Aug 2015
     *@param: projList | List of Project object and ownerList| list of user ids
     *@Description:Adds Project Owner to ProjectTeam if owner changes
     *@Revision:Sagar talele|20 Nov 2014|Added logic for checking owner Type
     */ 
    public void addUsersToProjectTeam(List<MW_Project__c> projList){

        Logger.push('addUsersToProjectTeam','ProjectDML');


        Map<String,id> teamMemberMap=new Map<String,id>();

        List<Project_Team_Member__c> memberList=new List<Project_Team_Member__c>();



        if(!projList.isEmpty()){

            try{

                //Get Project Team member from Project Lis
                for(Project_Team_Member__c teamMember:[SELECT Id,Duplicate_Team_Member__c FROM Project_Team_Member__c where Project__c in:projList ]){

                    teamMemberMap.put(teamMember.Duplicate_Team_Member__c,teamMember.id);

                }
               for(MW_Project__c project:projList){

                    if(!teamMemberMap.containsKey(String.ValueOf(project.id)+String.ValueOf(project.ownerId))){


                      
                        if(!(UtilityHelper.IsObjectTypeOfQueue(project.ownerId))){
                            
                            Project_Team_Member__c teamMember=new Project_Team_Member__c();
                            teamMember.Project__c=project.id;
                            teamMember.Resource__c=project.ownerId;
                            memberList.add(teamMember);
                        }
                       
                       
                    }

                }
                
                if(!(memberList.isEmpty())){
                 insert memberList;
                }

            }

            catch(Exception ex)
            {
                Logger.debugException(ex);
            }
        }
        Logger.pop();
    }
     /** 
     *@Author Original: Sagar Talele
     *@Last Modified:Sagar Talele - Cloud Sherpas/Mathworks
     *@Date Original: 1 October 2014
     *@Description: It will set the office value on the project based on the project requestor's Area
     */ 
      public void insertProjectAreaFromRequestor(List<MW_Project__c> recList){
       
        Logger.push('insertProjectAreaFromRequestor','ProjectDML');
        set<Id> userIdSet = new set<Id>();
        for(MW_Project__c proobj : recList){
            userIdSet.add(proobj.Requester__c);
        }
        
        
        Map<Id,User> userMap = new Map<Id,User>([Select id,Name,Area__c from user where id in :userIdSet ]);
      
        for(MW_Project__c proobj :recList ){
            // set the office only if the office value is null or empty
            if(proobj.office__c == null || proobj.office__c == ''){
                //check if the requester exists and the Requester Area__c is not null, else set the office to default to Natick
                if(proobj.Requester__c!= null && String.isNotBlank(userMap.get(proobj.Requester__c).Area__c)){
                    //Tokenize the requestor's area and use the first element of the token to set office__c on the project
                    
                    String Area = userMap.get(proobj.Requester__c).Area__c;
                    
                    List<String> AreaTokens = Area.split('-');
                    
                    
                    //get the list of piclist values for the office field on project
                    List<String> officeLOVList = UtilityHelper.getFieldPickListValues('MW_Project__c', 'Office__c');
                    
                    //Convert the list to a set to do a check if the value exists in the picklist values or not
                    Set<String> officeLOVSet = new Set<String>();
                    officeLOVSet.addAll(officeLOVList);
                    
                    //check if the Area token value exists in the office picklist values, if so set the value to office , else set it to default to Natick
                    if(AreaTokens!= null && AreaTokens.size() > 0 && officeLOVSet!= null && officeLOVSet.contains(AreaTokens[0].trim())){              
                        proobj.Office__c = AreaTokens[0].trim();
                    }
                    else{
                        proobj.Office__c = 'Natick';
                    }
                   
                }
                else
                {
                    proobj.Office__c = 'Natick';
                }
            }
            
        }
         Logger.pop();
         
     }
     
      /** 
     *@Author Original: Jaspreet Monga
     *@Last Modified: Jaspreet Monga - March 5 2015
     *@Date Original: 
     *@Description: will update Is hours since last reviewed date on timecard if timecard created date is greater than Last Review Date on project
     */ 
      public void updateIsHrsOnTimeCard(List<MW_Project__c> recList){
      
      List<Project_Time_Card__c> listProjectTC  = [Select Id,Is_Hours_Since_Last_Reviewed_Date__c,CreatedDate,Project__r.Id,Project__r.Last_Project_Review_Date__c from Project_Time_Card__c where Project__r.Id IN :recList limit 50000 ];
system.debug(listProjectTC + ' ---- ');      
      
      for(Project_Time_Card__c objProjectTC : listProjectTC)
      {
        Date TCCreateDate =  date.newinstance(objProjectTC.createdDate.year(), objProjectTC.createdDate.month(), objProjectTC.createdDate.day());
        if(TCCreateDate  > objProjectTC.Project__r.Last_Project_Review_Date__c)
        {
            objProjectTC.Is_Hours_Since_Last_Reviewed_Date__c = true;
        
        }
        else
        {
         objProjectTC.Is_Hours_Since_Last_Reviewed_Date__c = false;
        }
      }
      
      update listProjectTC;
    }
    
     /* End of Class */
}