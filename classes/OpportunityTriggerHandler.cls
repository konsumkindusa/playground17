/** 
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
 *@date Original: 18 August 2014, Last Modified: 14 March 2016
 *@description This  is handler class for 'OpportunityTrigger' . 
 */ 
public with sharing class OpportunityTriggerHandler {

    /**
     * @author Original: 
     * @Last Modified By: Abhay Verma
     * @date Original: , Last Modified: 9 June 2016
     * @description Method that handles before insert trigger event on the Opportunity object
     * @param Account A collection of Opportunity to create new Opportunity
     */
        public void onBeforeInsert(List<Opportunity> List_Oppty){        

        Logger.push('onBeforeInsert','OpportunityTriggerHandler ');
        OpportunityDml dml=new OpportunityDml();
        List<Opportunity> optyList = new List<Opportunity>();
        
        //For loop travers the Opportunities
        if(!List_Oppty.isEmpty()){

            for(Opportunity optyObj: List_Oppty){

                if(optyObj.Amount != null){

                    optyList.add(optyObj);

                }
            }
        } 
        
        if(optyList!=null && !optyList.isEmpty()){
            dml.CalculateUSDAmount(optyList);
        }
        //Added by Abhay Verma - 7 June 2016
        if(!List_Oppty.isEmpty() && List_Oppty != null){
            dml.assignTerritoryTeamRoleToOptyOwner(List_Oppty);
        }
        
        Logger.pop();
    }
    /**
     * @author Original:Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original: 18 August 2014, Last Modified: 
     * @description Method that handles before update trigger event on the Opportunity object
     * @param oldmap Opportunity records with old values
     * @param newmap Opportunity records with new values
     */
    public void onBeforeUpdate(map<Id, Opportunity> newmap, map<Id, Opportunity> oldmap){

        Logger.push('onBeforeUpdate','OpportunityTriggerHandler ');
        OpportunityDml dmlObj =new OpportunityDml();
        List<Opportunity> optyList = new List<Opportunity>();
        List<Opportunity> oppLstToCheckCompetitors = new List<Opportunity>();
        List<Id> listOptyId = new List<Id>();  // Added by Jaspreet
        List<Id> listOptyOwnerId = new List<Id>(); // Added by Jaspreet
        List<Opportunity> opportunityLst = new List<Opportunity>(); // Added by Abhay
        Boolean blnownerChanged = false;
        Map<Id,Opportunity> optyMap= new  Map<Id,Opportunity>();// Added by Neha
        for(Id tempOpty:newmap.keySet()){

            //Check Amount or CurrencyIsoCode has been changed and opportunity is open
            if((newmap.get(tempOpty).Amount != oldmap.get(tempOpty).Amount || 
                    newmap.get(tempOpty).CurrencyIsoCode != oldmap.get(tempOpty).CurrencyIsoCode) && !oldmap.get(tempOpty).isclosed && newmap.get(tempOpty).Amount != null){

                optyList.add(newmap.get(tempOpty));
            }
            
            // Changes by neha - Cloud Sherpas
            //Check Reason has been changed for the opportunity
            // Check if the StageName and Reason is set to Non-win and Competition
            if( newmap.get(tempOpty).Reason__c != oldmap.get(tempOpty).Reason__c && 
                newmap.get(tempOpty).Reason__c=='Competition' && newmap.get(tempOpty).StageName=='Non-Win'
                   ){
                   
                    // add those opportunities to a list 
                    oppLstToCheckCompetitors.add(newmap.get(tempOpty));
                    
            }
            // Changes by Neha Ends
            
        /* Updates made by Japsreet
         * Populate the list of opportunity ids and owner ids if owner changes 
         * Query related tasks for the opportunities whos owner has changed
         * Create map of opportunity Id and earliest activity date for related tasks
         * Assign activity date to next activity due date of opportunity 
         */
            
        if(newmap.get(tempOpty).OwnerId != oldmap.get(tempOpty).OwnerId)
        {
           opportunityLst.add(newmap.get(tempOpty));//Adding the oppotunity to the list if the owner of the opportunity has changed
           listOptyId.add(tempOpty);  
           listOptyOwnerId.add(newmap.get(tempOpty).OwnerId);          
           listOptyOwnerId.add(oldmap.get(tempOpty).OwnerId);  // adding old owner to list because this will be replaced with new owner 
           blnownerChanged = true;
        }
        }
        
        // Check if the list of opportunities with Stage name and reason as Non-Win and Competiton is null and if not process further 
        if(oppLstToCheckCompetitors!=null && !oppLstToCheckCompetitors.isEmpty()){        
            dmlObj.CheckOpportunityComptetitors(oppLstToCheckCompetitors);
        }
        
        
        if(blnownerChanged){
        List<Task> listTask = [Select WhoId, WhatId, ActivityDate,OwnerId,Status From Task where WhatiD IN:listOptyId and OwnerId IN:listOptyOwnerId and Status != 'Completed' limit 50000];
    

        Map<Id,Date>  mapOppIDTask = new Map<Id,Date>(); // Map of Oppurtunity Id and next due date 
    
        for(Task objTask : listTask)
            {
             if(objTask.Status != 'Completed'  && newmap.get(objTask.WhatId) != null && 
                (newmap.get(objTask.WhatId).OwnerID == objTask.OwnerID || oldmap.get(objTask.WhatId).OwnerID == objTask.OwnerID)) // Checking if owner of task is same as owner of opportunity
                 {
                  if(mapOppIdTask.get(objTask.WhatId) != null)
                  {
                      if(mapOppIdTask.get(objTask.WhatId) > objTask.ActivityDate)
                      {
                          mapOppIdTask.put(objTask.WhatId,objTask.ActivityDate); 
                      }
                      
                      /*
                      else
                      {
                        skip
                      }
                      */
                      
                  }
                  else
                  {
                    mapOppIdTask.put(objTask.WhatId,objTask.ActivityDate); 
                  }
                 }
               
            } 
             
            for(Id tempOpty:mapOppIdTask.keySet())
            {    
                if(mapOppIdTask.containsKey(tempOpty)){
                     newMap.get(tempOpty).Next_Activity_Due_Date__c = mapOppIdTask.get(tempOpty);
                 }              
            }
          }  // Changes by Jaspreet Ends 

        

        if(optyList!=null && !optyList.isEmpty()){            
            dmlObj.CalculateUSDAmount(optyList);
        }
        
        //Changes By Abhay - 8 June 2016
        if(opportunityLst != null && !opportunityLst.isEmpty()){            
            dmlObj.assignTerritoryTeamRoleToOptyOwner(opportunityLst);
        }
        
        Logger.pop();
    }

    /**
     * @author Original: 
     * @date Original: , Last Modified: 14 March 2016 - Shweta Shanbhag
     * @description Method that handles after insert trigger event on the Opportunity object
     * @param List_Oppty A collection of Opportunity to create new Opportunity
     */
    public void onAfterInsert(List<Opportunity> List_Oppty){ 
        
        List<Opportunity> optyList=new List<Opportunity>();
         List<Opportunity> optyAssignList = new List<Opportunity>();
        for(Opportunity optyObj:List_Oppty){
            
            if(optyObj.Primary_Contact__c!=null){           
                optyList.add(optyObj);
            }
            
            if(String.IsBlank(optyObj.Salesforce_Lead_ID__c)){
                optyAssignList.add(optyObj);
            }
            
        }//for
        
        OpportunityDml dml=new OpportunityDml();
        if(optyList.size() > 0){
            dml.addPrimaryContactRoleToOpty(optyList);
        }
        if(optyAssignList!=null && !optyAssignList.isEmpty())
        {
            dml.AutoAssignOpps(optyAssignList);
       }

    }//onAfterInsert

    /**
     * @author Original: 
     * @date Original: , Last Modified:12 sep 2014 
     * @description Method that handles after update trigger event on the Opportunity object
     * @param oldmap Opportunity records with old values
     * @param newmap Opportunity records with new values
     */
    public void onAfterUpdate(map<Id, Opportunity> newmap, map<Id, Opportunity> oldmap){
        
        List<Opportunity> optyList=new List<Opportunity>();
        
        //TaskTriggerHandler.blnupdateopty = true;
        map<Id, Opportunity> ownerChangednewmap=new map<Id, Opportunity>();
        
        map<Id, Opportunity> closedWithExistingOpp=new map<Id, Opportunity>(); // Added by Jaspreet
        
        for(Opportunity tempOpty:newmap.values()){

            if(newmap.get(tempOpty.id).ownerid != oldmap.get(tempOpty.id).ownerid){
                
                ownerChangednewmap.put(tempOpty.id,tempOpty);
 
            }//if
            
            if(newmap.get(tempOpty.id).Primary_Contact__c != oldmap.get(tempOpty.id).Primary_Contact__c){
                
                optyList.add(newmap.get(tempOpty.id));
 
            }//if
 
          //Will add those opp to list whose stage is Non-Win and reasong is existing opp - modified by Jaspreet
            if((oldmap.get(tempOpty.id).StageName != 'Non-Win' || oldmap.get(tempOpty.id).Reason__c != 'Existing Opportunity')  // Comparing prev stage and reason values on opp
                && newmap.get(tempOpty.id).StageName == 'Non-Win' && newmap.get(tempOpty.id).Reason__c == 'Existing Opportunity' // comparing new stage and reason values on opp
                && newmap.get(tempOpty.id).Existing_Opportunity__c !=null) // checking if opp have any exisiting opp 
                {
                    closedWithExistingOpp.put(tempOpty.id,tempOpty);
                }
          
             
        }
        OpportunityDml dml=new OpportunityDml();
        if(!ownerChangednewmap.isEmpty()){
            dml.transferOnlyOldOwnersActivities(ownerChangednewmap,oldmap);
        }
        if(!closedWithExistingOpp.isEmpty()){
            dml.assignProjectstoExistingOpp(closedWithExistingOpp); // method to assign projects of current opp to its existing opp
        }
        if(optyList.size() > 0){
            dml.addPrimaryContactRoleToOpty(optyList);
        }

    }//onAfterUpdate

}