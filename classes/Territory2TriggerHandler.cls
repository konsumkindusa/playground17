/** 
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik - Mathworks
 *@date Original: 22 Oct 2014, Last Modified: 22 Oct 2014, 17 August 2016, 25 August 2016 
 *@description This is handler class for 'Territory2MasterTrigger'
  @Revision:Faina Gorelik|16 August 2016| Added logic to support Territory ID Lookup  based on Custom Setting , AtTask 1637272 
 */
public with sharing class Territory2TriggerHandler {

    public Territory_Settings__c terrsettings = Territory_Settings__c.getOrgDefaults();
    public boolean GenerateMasterFlag = terrsettings.Generate_Master_Territory_Flag__c;//fg
    
    /**
     * @author Original: Shweta Shanbhag, Faina Gorelik AtTask 1637272 
     * @date Original: 8/12/16 , Last Modified: 9/1/16
     * @description Method that handles before insert trigger event on the Territory2 object
     * @param Territory2 A collection of Territory2 to create new Territory2
     */
    
     public void onBeforeInsert(List<Territory2> territory2Lst) {
      
        Logger.push('onBeforeInsert', 'Territory2TriggerHandler');
        System.debug('**In the Territory2Triggerhandler Class - onBeforeInsert**');
        
        List<Territory2> ter2List = new List<territory2>();
        List<Territory2> ter2Listunique = new List<territory2>();
        
		
         if(territory2Lst != null && territory2Lst.size() > 0) {
             for(Territory2 terr2Obj : territory2Lst) {
                 //fg
              if (GenerateMasterFlag == true){ 
                     if (terr2Obj.Master_Territory_Id__c == null || terr2Obj.Master_Territory_Id__c == '') //fg put original back
                     {     
                         ter2List.add(terr2Obj);  
                     }
                     
                     if (String.isNotBlank(terr2Obj.Master_Territory_Id__c))      
                     {
                         ter2Listunique.add(terr2Obj);
                     }
                 }
                 //fg
                 else{ // if user enters master territory id on insert we want to generate the unique key
                     if (String.isNotBlank(terr2Obj.Master_Territory_Id__c)) {
                         ter2Listunique.add(terr2Obj);
                     }
                     else {// on cloned operation if master territiry id is not populated but unique master territory is  null, we need to set it to null
                         if (String.isNotBlank(terr2Obj.Unique_Master_Territory__c) && String.isBlank(terr2Obj.Master_Territory_Id__c)){
                             ter2Listunique.add(terr2Obj);
                         }
                     }
                 }
                 
             }

             if(!ter2List.isEmpty()){
                 Territory2HandlerDML.setMasterTerrId(ter2List);
             }
             
             if(!ter2Listunique.isEmpty()){
                 Territory2HandlerDML.setUniqueMasterTerritory(ter2Listunique);
             }

         }
     }
    
    /**
     * @author Original: Shweta Shanbhag, Modified by: Faina Gorelik AtTask 1637272 
     * @date Original: 8/16/16 , Last Modified: 8/16/16, 09/02/2016
     * @description Method that handles before update trigger event on the Territory2 object
     * @param Territory2 A collection of Territory2 to create new Territory2
     */
    
     public void onBeforeUpdate(map<Id, Territory2> oldmap, map<Id, Territory2> newmap){
           
        Logger.push('onBeforeUpdate', 'Territory2TriggerHandler');
        System.debug('**In the Territory2Triggerhandler Class - onBeforeUpdate**');
        
        List<Territory2> ter2List = new List<territory2>();
        List<Territory2> ter2ListUnique = new List<territory2>();//fg
         
        
         for( Territory2 tempTerritory2: newmap.values()){
             if (GenerateMasterFlag == true) {
                 
                 if(newmap.get(tempTerritory2.id).Master_Territory_ID__c !=oldmap.get(tempTerritory2.id).Master_Territory_ID__c 
                    && (newmap.get(tempTerritory2.id).Master_Territory_ID__c =='' || newmap.get(tempTerritory2.id).Master_Territory_ID__c == null) 
                    || (newmap.get(tempTerritory2.id).Master_Territory_ID__c =='' || newmap.get(tempTerritory2.id).Master_Territory_ID__c == null))
                 {        
                     ter2List.add(newmap.get(tempTerritory2.id));
                 } 
                 //fg - generates Unique Master Territory only
                 if(newmap.get(tempTerritory2.id).Master_Territory_ID__c !=oldmap.get(tempTerritory2.id).Master_Territory_ID__c 
                    && (newmap.get(tempTerritory2.id).Master_Territory_ID__c !='' || newmap.get(tempTerritory2.id).Master_Territory_ID__c != null) ||(newmap.get(tempTerritory2.id).Unique_Master_Territory__c =='' || newmap.get(tempTerritory2.id).Unique_Master_Territory__c == null)
                    ||(newmap.get(tempTerritory2.id).Master_Territory_ID__c == oldmap.get(tempTerritory2.id).Master_Territory_ID__c && newmap.get(tempTerritory2.id).Unique_Master_Territory__c !=oldmap.get(tempTerritory2.id).Unique_Master_Territory__c ))
                 {
                     ter2ListUnique.add(newmap.get(tempTerritory2.id));
                 }  
                 
             }// end flag = true  
             else{ // flag = false don't generate Master Territory ID but we still want to generate unique master territory when master territory id is not null
                 if (String.isBlank(newmap.get(tempTerritory2.id).Master_Territory_ID__c) && string.isNotBlank(newmap.get(tempTerritory2.id).Unique_Master_Territory__c) // always set unique master territory id to null
                     ||(newmap.get(tempTerritory2.id).Master_Territory_ID__c == oldmap.get(tempTerritory2.id).Master_Territory_ID__c  && newmap.get(tempTerritory2.id).Unique_Master_Territory__c != oldmap.get(tempTerritory2.id).Unique_Master_Territory__c)
                    //||(String.isNotBlank(newmap.get(tempTerritory2.id).Master_Territory_ID__c) && String.isBlank(newmap.get(tempTerritory2.id).Unique_Master_Territory__c)))
                ||(newmap.get(tempTerritory2.id).Master_Territory_ID__c !=oldmap.get(tempTerritory2.id).Master_Territory_ID__c))
                     // if (newmap.get(tempTerritory2.id).Master_Territory_ID__c !=oldmap.get(tempTerritory2.id).Master_Territory_ID__c || (String.isNotBlank(newmap.get(tempTerritory2.id).Master_Territory_ID__c) && String.isBlank(newmap.get(tempTerritory2.id).Unique_Master_Territory__c)))
                     
                 {

                     ter2ListUnique.add(newmap.get(tempTerritory2.id)); // add to the list and  set to null on dml operation
                 }
                 
             }
         }// end for
		         
         if(!ter2List.isEmpty()){
                Territory2HandlerDML.setMasterTerrId(ter2List);
            }
         
         //fg
          if(!ter2ListUnique.isEmpty()){
                Territory2HandlerDML.setUniqueMasterTerritory(ter2ListUnique);
            }
         
     }
  
     /**
     * @author Original: , Last Modified : Faina Gorelik
     * @date Original: 8/16/16 , Last Modified: 8/16/16
     * @description Method that handles After update trigger event on the Territory2 object
     * @revision : Added logic to support Territory Id lookup based on Territory Custom Setting 
     */ 
    public void onAfterUpdate(map<Id, Territory2> oldmap, map<Id, Territory2> newmap){
        Logger.push('onAfterUpdate', 'Territory2TriggerHandler');
        
        System.debug('**In the Territory2Triggerhandler Class - After Update**');
        
        List<Territory2> territory2List=new List<Territory2>();
        List<Territory2> territory2Lst=new List<Territory2>();
        List<territory2> terrmasterid = new List<Territory2>();
        //Instantiate TerritoryIdToTerritory2 - fg renamed 
        Map<String,Territory2>TerritoryIdToTerritory2=new map<String,Territory2>();
        //Fetch general setting instance
        General_Settings__c settings= General_Settings__c.getInstance();
		string TerritoryAssignLookupField;
        TerritoryAssignLookupField = terrsettings.Territory_Assignment_Lookup_Field__c;

        for(Id tempTerritory2:oldmap.keySet()){

            if( newmap.get(tempTerritory2).Global_Region__c != oldmap.get(tempTerritory2).Global_Region__c 
                    || newmap.get(tempTerritory2).Region__c != oldmap.get(tempTerritory2).Region__c 
                    || newmap.get(tempTerritory2).Office_Group__c != oldmap.get(tempTerritory2).Office_Group__c
                    || newmap.get(tempTerritory2).Office__c != oldmap.get(tempTerritory2).Office__c
                    || newmap.get(tempTerritory2).Office_Channel__c != oldmap.get(tempTerritory2).Office_Channel__c 
                    || newmap.get(tempTerritory2).Territory_Industry__c != oldmap.get(tempTerritory2).Territory_Industry__c
                    || newmap.get(tempTerritory2).Territory_Sales_Group__c != oldmap.get(tempTerritory2).Territory_Sales_Group__c
                    || newmap.get(tempTerritory2).Territory_Sales_Team_Type__c != oldmap.get(tempTerritory2).Territory_Sales_Team_Type__c 
                    || newmap.get(tempTerritory2).name != oldmap.get(tempTerritory2).name 
                    || newmap.get(tempTerritory2).Territory_Sector__c !=oldmap.get(tempTerritory2).Territory_Sector__c
                    || newmap.get(tempTerritory2).Territory2TypeId !=oldmap.get(tempTerritory2).Territory2TypeId
                    || newmap.get(tempTerritory2).Siebel_Territory_ID__c !=oldmap.get(tempTerritory2).Siebel_Territory_ID__c
                    || newmap.get(tempTerritory2).DeveloperName !=oldmap.get(tempTerritory2).DeveloperName
                    || newmap.get(tempTerritory2).Description !=oldmap.get(tempTerritory2).Description
                    || newmap.get(tempTerritory2).is_Active__c !=oldmap.get(tempTerritory2).is_Active__c 
               		|| newmap.get(tempTerritory2).Master_Territory_ID__c !=oldmap.get(tempTerritory2).Master_Territory_ID__c 
               		|| newmap.get(tempTerritory2).Unique_Master_Territory__c !=oldmap.get(tempTerritory2).Unique_Master_Territory__c 
                	|| newmap.get(tempTerritory2).Include_In_Sales_Hierarchy__c !=oldmap.get(tempTerritory2).Include_In_Sales_Hierarchy__c 
                    ){
                System.debug('**deveName**'+newmap.get(tempTerritory2).Territory2Type.MasterLabel);
                territory2List.add(newmap.get(tempTerritory2));
            }
        }
            territory2Lst = [Select Id,Global_Region__c,Region__c,Office_Group__c,Office__c,Office_Channel__c,
                                Territory_Industry__c,Territory_Sales_Group__c,Territory_Sales_Team_Type__c,
                                name,Territory_Sector__c,Territory2Type.MasterLabel,Siebel_Territory_ID__c,Master_Territory_ID__c 
                                 From Territory2 where Id In: territory2List];
                                
            if(territory2Lst != NULL && !territory2Lst .isEmpty()){

                //Form a map of siebelTerritoryId to Territory2  
                //fg
                for(Territory2 territoryObj:territory2Lst ){ 
                    if (TerritoryAssignLookupField == 'Siebel'){
                        if(territoryObj.Siebel_Territory_ID__c!=null && territoryObj.Siebel_Territory_ID__c!=''){                       
                            TerritoryIdToTerritory2.put(territoryObj.Siebel_Territory_ID__c,territoryObj);
                        } 
                    }
                    else{
                        if(territoryObj.Master_Territory_ID__c!=null && territoryObj.Master_Territory_ID__c!=''){                       
                            TerritoryIdToTerritory2.put(territoryObj.Master_Territory_ID__c,territoryObj);  
                        } 
                    }
                    //fg
                }
            }

            //if there are already five queued or active batch jobs can be at one time.
            if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 4){

                if (TerritoryIdToTerritory2.size() > 0) {
					if (TerritoryAssignLookupField == 'Siebel')//fg
                    {
                        Database.executeBatch(new Territory2Dml(TerritoryIdToTerritory2),Integer.valueOf(settings.Batch_Size_For_Territory2Trigger__c));
                    }
                    else{
                        Database.executeBatch(new Territory2DmlMaster(TerritoryIdToTerritory2),Integer.valueOf(settings.Batch_Size_For_Territory2Trigger__c));//fg
                    }
                }
                

            }
            else{
                 
                Logger.debug('Apex jobs still in queue,Try after some time');
            }

        Set<Id> territory2set = new Set<Id>();
        //Check if the TerritoryIdToTerritory2 is Empty or not.
        if(!(TerritoryIdToTerritory2.isEmpty())){
            //Fill the Territory2 Object List.
            for(Territory2 territory2Obj : TerritoryIdToTerritory2.values()){
                territory2set.add(territory2Obj.Id);                
            }
        }
        if(!(territory2set.isEmpty())){
            //Calling the updateTerritory2Obj Method.
            System.debug('**Going for the HandlerDML Class**' +territory2set);
                Territory2HandlerDML.updateTerritoryShadowObjRec(territory2set);
        }
        Logger.pop();
    }//onAfterUpdate
    
     /**
     * @author Original: Abhay Verma - Cloud Sherpas/Mathworks
     * @date Original: 17Nov2015 , Last Modified: 
     * @description Method that handles after insert trigger event on the Territory2 object
     * @param 
     */
    
    public void onAfterInsert(List<Territory2> territory2Lst){
        
        Logger.push('onAfterInsert', 'Territory2TriggerHandler');
        Set<Id> territory2set = new Set<Id>();
        
        if(!territory2Lst.isEmpty()){
            for(Territory2 territory2Obj : territory2Lst){
                territory2set.add(territory2Obj.Id);
                              
            }
        }   
        if(!(territory2set.isEmpty())){
                Territory2HandlerDML.InsertTerritoryShadowObjRec(territory2set);
        }
        Logger.pop();
    }
    
    /**
     * @author Original: Abhay Verma - Cloud Sherpas/Mathworks
     * @date Original: 8Dec2015 , Last Modified: 
     * @description Method that handles before delete trigger event on the Territory2 object
     * @param 
     */
    
    public void onBeforeDelete(List<Territory2> territory2Lst){
        Logger.push('onBeforeDelete', 'Territory2TriggerHandler');
        
        String territory2ErrorMsg = System.Label.Territory2DeleteErrorMessage;
        //Set of territory2 Id.
        Set<Id> territory2set = new Set<Id>();
        //Map of Territory2 Id and ObjectTerritory2Association.
        Map<String, ObjectTerritory2Association> territoryIdAndTerritoryassociatedObjMap = new Map<String, ObjectTerritory2Association>();
        List<ObjectTerritory2Association> territoryAssociationObjLst = new List<ObjectTerritory2Association>();
        
        System.debug('**territory2Lst**' +territory2Lst);
        //Querying the ObjectTerritory2Association Object. 
        territoryAssociationObjLst = [SELECT Territory2Id, SobjectType, ObjectId FROM ObjectTerritory2Association WHERE Territory2Id IN: territory2Lst];
        System.debug('**territoryAssociationObjLst**' +territoryAssociationObjLst);
        
        //Check if thee List is empty or not.
        if(!territoryAssociationObjLst.isEmpty()){
            for(ObjectTerritory2Association territoryassociatedObj : territoryAssociationObjLst){
                //Filling the map territoryIdAndTerritoryassociatedObjMap.
                territoryIdAndTerritoryassociatedObjMap.put(territoryassociatedObj.Territory2Id, territoryassociatedObj);
            }
        }  
        
        //Check if territory2Lst List is empty or not.
        if(!territory2Lst.isEmpty()){
            for(Territory2 territory2Obj : territory2Lst){
                //Filtering the Territory2 Object which is not associated to any account.
                if(!(territoryIdAndTerritoryassociatedObjMap.containsKey(territory2Obj.Id))){
                    territory2set.add(territory2Obj.Id);
                }
                else{
                    //Show error if the territory2 Object is associated to the account.
                    territory2Obj.addError(territory2ErrorMsg);
                }
            }  
        } 
        
        if(!(territory2set.isEmpty())){
            //Calling the deleteTerritory2Obj Method.
            System.debug('**in the delete handler method**' +territory2set);
                Territory2HandlerDML.deleteTerritoryShadowObjRec(territory2set);
        }
        Logger.pop();
    }

}