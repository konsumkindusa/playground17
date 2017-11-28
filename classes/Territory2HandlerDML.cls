/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag
 *@date Original:20 Nov 2015, Last Modified: 15 August 2016
 *@description This is a DML class for Territory2TriggerHandler.
 */

public class Territory2HandlerDML{
    
     
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 20 Nov 2015 
     *@Last Modified: 
     *@Description: Method to Insert the Territory Shadow Object when Territory2 Object is get Inserted.
     *@Param: territory2Set - Set of the Territory2 Object.
     */
    @future
    public static void InsertTerritoryShadowObjRec(Set<id> territory2Set){
        
        Logger.push('InsertTerritoryShadowObjRec', 'Territory2HandlerDML');
        System.debug('**in the insert function territory2Set**' +territory2Set);
        //Map<Src Field API Name, Destination Field API Name> 
        Map<String, String> srcDesObjFieldAPIMap = new Map<String, String>();
        //Territory2 Object List to store record from SOQL.
        List<Territory2> territory2List = new List<Territory2>();
        //Territory Shadow Object List to store record from SOQL.
        List<Territory_Shadow__c> territoryShadowRecList = new  List<Territory_Shadow__c>();
        
        
        if(!(territory2Set.isEmpty())){
            //Dynamically get all the fiels of Territory2 Object.
            List<String> fields = new List<String>(Territory2.SObjectType.getDescribe().fields.getMap().keySet());
            String soql = ''
            + ' select ' + String.join(fields, ',')
            + ' from Territory2' + ' WHERE Id IN: territory2Set ';
            //Fill the Territory2 Object List.
            territory2List = Database.query(soql);
        }           
        System.debug('**territory2List**' +territory2List);
        //List of Custom Metadata Type.
        List<Object_Clone_Mapping__mdt> objClnMappingLst = [SELECT Destination_Obj_API_Name__c, Destination_Obj_Field_API_Name__c, Src_Obj_API_Name__c, Src_Obj_Field_API_Name__c FROM Object_Clone_Mapping__mdt WHERE Destination_Obj_API_Name__c = 'Territory_Shadow__c' AND Src_Obj_API_Name__c = 'Territory2'];
        
        //Check if the Metadata is Empty or Not.
        if(!(objClnMappingLst.isEmpty())){
            //Filling the srcDesObjFieldAPIMap Map.
            for(Object_Clone_Mapping__mdt clnMapMdtObj : objClnMappingLst){
                srcDesObjFieldAPIMap.put(clnMapMdtObj.Src_Obj_Field_API_Name__c, clnMapMdtObj.Destination_Obj_Field_API_Name__c);
            }    
        }
        
        
        //Calling the cloneSobject Method.
        List<Territory_Shadow__c> TerritoryShadowObjLst = SobjectCloningUtility.cloneSobject(srcDesObjFieldAPIMap, territory2List, 'Territory2', 'Territory_Shadow__c');
        
        System.debug('**TerritoryShadowObjLst **'+TerritoryShadowObjLst );

        try{
            //Inserting Territory_Shadow__c List.
            Insert TerritoryShadowObjLst ;
           
        }
        
        catch(System.DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                
            }
        }
        Logger.pop();
    }//End of Method
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 7 Dec 2015 
     *@Last Modified: 
     *@Description: Method to Update the Territory Shadow Object when Territory2 Object is get Update.
     *@Param: territory2Set - Set of the Territory2 Object.
     */
    @future
    public static void updateTerritoryShadowObjRec(Set<id> territory2Set){
    
        Logger.push('updateTerritoryShadowObjRec', 'Territory2HandlerDML');
         System.debug('**in the Territory2 HandlerDML update fuction**');
        //Territory2 Object List to store record from SOQL.
        List<Territory2> territory2List = new List<Territory2>();
        //Territory Shadow Object List to store record from SOQL.
        List<Territory_Shadow__c> territoryShadowRecList = new  List<Territory_Shadow__c>();
        //Map of Territory2 Id and Territory Shadow Obj.
        Map<String, Territory_Shadow__c> territory2IdTerritoryShadowObjMap = new Map<String, Territory_Shadow__c>();
        //Map<Src Field API Name, Destination Field API Name> 
        Map<String, String> srcDesObjFieldAPIMap = new Map<String, String>();
        //List of Territory Shadow to update the records.
        List<Territory_Shadow__c> updateTerritoryShadowObjLst = new List<Territory_Shadow__c>();
        
        //Querying all the Field of Territory2 Obj.
        if(!(territory2Set.isEmpty())){
            //Dynamically get all the fiels of Territory2 Object.
            List<String> fields = new List<String>(Territory2.SObjectType.getDescribe().fields.getMap().keySet());
            String soql = ''
            + ' select ' + String.join(fields, ',')
            + ' from Territory2' + ' WHERE Id IN: territory2Set ';
            //Fill the Territory2 Object List.
            territory2List = Database.query(soql);
        }   
        
        //Querying all the field of Territory Shadow Object.
        if(!(territory2Set.isEmpty())){
            //Dynamically get all the fiels of Territory2 Object.
            List<String> fields = new List<String>(Territory_Shadow__c.SObjectType.getDescribe().fields.getMap().keySet());
            String soql = ''
            + ' select ' + String.join(fields, ',')
            + ' from Territory_Shadow__c' + ' WHERE Salesforce_Territory_ID__c IN: territory2Set ';
            //Fill the Territory2 Object List.
            territoryShadowRecList = Database.query(soql);
        }
        
        //Filling the territory2IdTerritoryShadowObjMap Map. 
        if(!(territoryShadowRecList.isEmpty())){
            for(Territory_Shadow__c tsObj : territoryShadowRecList){
                territory2IdTerritoryShadowObjMap.put(tsObj.Salesforce_Territory_ID__c, tsObj);
            }    
        }
            
        //List of Custom Metadata Type.
        List<Object_Clone_Mapping__mdt> objClnMappingLst = [SELECT Destination_Obj_API_Name__c, Destination_Obj_Field_API_Name__c, Src_Obj_API_Name__c, Src_Obj_Field_API_Name__c FROM Object_Clone_Mapping__mdt WHERE Destination_Obj_API_Name__c = 'Territory_Shadow__c' AND Src_Obj_API_Name__c = 'Territory2'];
        
        //Check if the Metadata is Empty or Not.
        if(!(objClnMappingLst.isEmpty())){
            //Filling the srcDesObjFieldAPIMap Map.
            for(Object_Clone_Mapping__mdt clnMapMdtObj : objClnMappingLst){
                srcDesObjFieldAPIMap.put(clnMapMdtObj.Src_Obj_Field_API_Name__c, clnMapMdtObj.Destination_Obj_Field_API_Name__c);
            }    
        }
        
        //Calling the cloneSobject Method.
        List<Territory_Shadow__c> TerritoryShadowObjLst = SobjectCloningUtility.cloneSobject(srcDesObjFieldAPIMap, territory2List, 'Territory2', 'Territory_Shadow__c');
        System.debug('**TerritoryShadowObjLst**' +TerritoryShadowObjLst);
        
        //Check if the List is empty or not.
        if(!(TerritoryShadowObjLst.IsEmpty())){
            System.debug('**TerritoryShadowObjLst**' +TerritoryShadowObjLst);
            //Iterating over the list to get the Ids of Territory Shadow Object Record.
            for(Territory_Shadow__c tsObj : TerritoryShadowObjLst){
                if(territory2IdTerritoryShadowObjMap.containsKey(tsObj.Salesforce_Territory_ID__c)){
                    //Copying the Salesforce Territory Shadow Object Id to TerritoryShadowObjLst for updating TerritoryShadowObjLst.
                    tsObj.Id = territory2IdTerritoryShadowObjMap.get(tsObj.Salesforce_Territory_ID__c).Id;
                    //Add the record in the updateterritoryShadow List.
                    updateTerritoryShadowObjLst.add(tsObj);
                    System.debug('**tsObj**' +tsObj);
                }//End of if
                else{
                    System.debug('**tsObjelse**' +tsObj);
                    updateTerritoryShadowObjLst.add(tsObj);
                }
            }//End of For
        }//End of If
        System.debug('**in the update funtion.**' +updateTerritoryShadowObjLst);
        try{
        
        //Updating Territory_Shadow__c List.
        upsert updateTerritoryShadowObjLst;
        }
    
        catch(System.DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                System.debug('**ex**' +ex);
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                
            }
        }
        Logger.pop();            
    }//End of Method
    
    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 7 Dec 2015 
     *@Last Modified: 
     *@Description: Method to Delete the Territory Shadow Object when Territory2 Object is get Deleted.
     *@Param: territory2Set - Set of the Territory2 Object.
     */
    @future
    public static void deleteTerritoryShadowObjRec(Set<id> territory2Set){
        
        Logger.push('deleteTerritoryShadowObjRec', 'Territory2HandlerDML');
        //Querying the Territory Shadow Object record which is associated to the deleted territory2 Obj.
        List<Territory_Shadow__c> territoryShadowLst = [SELECT Salesforce_Territory_ID__c,Id FROM Territory_Shadow__c WHERE Salesforce_Territory_ID__c IN: territory2Set];
        System.debug('**in the delete handler DML**' +territory2Set);
        System.debug('**territoryShadowLst**' +territoryShadowLst);
        try{
            //Deleting territory Shadow Object Record after deleting Territory2 Object Records.
            System.debug('**DELETE LIST **' +territoryShadowLst);
            delete territoryShadowLst;
        }
        
        catch(Exception ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                System.debug('**EXCDEPTION**' +ex);
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                
            }
        }
        Logger.pop();
   }//End of Method 
    
    
    /**
    *    @author         Shweta Shanbhag
    *    @date           8/12/2016
    *    @description    This method generates a random master territory ID on Territory2 record
    *
    *                    The charset considered while generating the random code is 
    *                    specified by Character_Set__c and the desired length of the code is 
    *                    specified by Territory_Master_Id_Length__c from the Territory_Settings__c
    *                    Hierarchy Custom Setting.
    *                    The method makes sure that the id value retured is unique
    *                    by looking up on the existing id values for possible 
    *                    collisions. Story: 1617282
    *    @return         String
    */
    public static String generateMasterTerritoryId() {
        Logger.push('Territory2HandlerDML', 'generateMasterTerritoryId');

        String newTerrMasterId = '';
		Territory_Settings__c TerrCustSetting = Territory_Settings__c.getOrgDefaults();
            
        if(TerrCustSetting != null) {
            // Get the charset
            List<String> TMIdCharset = TerrCustSetting.Character_Set__c.split(';');
            
            // Get the charset size
            Integer upperLimit = TMIdCharset.size();
            
            // Generate random code from charset
            for(Integer i = 0; i < TerrCustSetting.Territory_Master_Id_Length__c; i++) {
                newTerrMasterId += TMIdCharset[randomWithLimit(upperLimit)];
            }

            // Check for possible collisions and re-generate the territory master id if required
            if(isDuplicate(newTerrMasterId)) {
                generateMasterTerritoryId();                
            }
        } else {
            Logger.debugException('Missing data setup for custom setting - Territory_Settings__c');
            
        }   
        
        Logger.pop();

        return newTerrMasterId;
    }
    
     /**
    *    @author        Shweta Shanbhag
    *    @date          8/12/16
    *    @description   Returns a random number between Zero and Maximum number of of unique 
    *                   characters used in construction of master territory id. Story: 1617282
    *    @param         upperLimit - The number of unique characters used in construction of 
    *                   master territory id
    *    @return        Integer
    */
    private static Integer randomWithLimit(Integer upperLimit) {
        Logger.push('Territory2HandlerDML', 'randomWithLimit');

        Integer rand = Math.round(Math.random() * 1000);
        Logger.pop();        
        return Math.mod(rand, upperLimit);
    }

    /**
    *    @author        Shweta Shanbhag
    *    @date          8/12/16
    *    @description   Performs collision detection against existing 
    *                   master territory ids. Story: 1617282
    *    @param         newTerrMasterId - The master territory id to check for collision
    *    @return        Boolean
    */
    private static Boolean isDuplicate(String newTerrMasterId) {
        Logger.push('Territory2HandlerDML', 'isDuplicate');

        Integer matchCount = Database.countQuery('Select COUNT() FROM Territory2 Where Master_Territory_ID__c = :newTerrMasterId');
        Logger.pop();
        
        return matchCount >= 1;
    }

    /**
    * @author       Shweta Shanbhag
    * @date         8/15/2016
    * @description  Updates master territory id on the territory2 record. Story: 1617282
    * @param        terr2list - List of territory2
    */
     public static void setMasterTerrId(List<Territory2> terr2list) {
        Logger.push('Territory2HandlerDML', 'setMasterTerrId');

        if(terr2list != null && terr2list.size() > 0) {
            for(Territory2 terr2 : terr2list) {        
              	terr2.Master_Territory_ID__c = 'TM-' +Territory2HandlerDML.generateMasterTerritoryId();  
                //fg
                terr2.Unique_Master_Territory__c = terr2.Territory2ModelId + terr2.Master_Territory_ID__c;
            }
        }

        Logger.pop();
    }
    
     /**
    * @author       Faina Gorelik
    * @date        9/02/2016
    * @description  Updates unique master territory  on the territory2 record. Story: TBD
    * @param        ter2Listunique - List of territory2
    */
     public static void setUniqueMasterTerritory(List<Territory2> ter2Listunique) {
        Logger.push('Territory2HandlerDML', 'setUniqueMasterTerritory');

        if(ter2Listunique != null && ter2Listunique.size() > 0) {
            for(Territory2 terr2 : ter2Listunique) {        
                if (terr2.Master_Territory_ID__c !='' && terr2.Master_Territory_ID__c != null){
                      terr2.Unique_Master_Territory__c = terr2.Territory2ModelId + terr2.Master_Territory_ID__c;
                }
                else
                {
                    
					 terr2.Unique_Master_Territory__c = null;                    
                }
              //  terr2.Unique_Master_Territory__c = terr2.Territory2ModelId + terr2.Master_Territory_ID__c;
            }
        }

        Logger.pop();
    }
    
    
    /**
    * @author :Shweta Shanbhag - MathWorks
    * @date : 9/5/2016    
    * @description :fetch the primary Sales rep details from territories 
    * @param : TerrIdSet - Terr Id set
    */
    public static Map<Id, UserTerritory2Association> getprimarysalesrep(Set<Id> TerrIdSet) {
        
		Logger.push('Territory2HandlerDML', 'getprimarysalesrep');
		Map<id,UserTerritory2Association> TerritoryPrimarySalesRep = new  Map<id,UserTerritory2Association>();

        if(TerrIdSet != null && TerrIdSet.size() > 0) {
			for (UserTerritory2Association  userT2AssociationObj: [Select Id,RoleInTerritory2,Territory2Id,User.email,User.Id, User.Name
                                                                    From UserTerritory2Association 
                                                                        where RoleInTerritory2 = 'Sales Rep Primary' 
                                                                        and Territory2Id in : TerrIdSet])
            {
				  TerritoryPrimarySalesRep.put(userT2AssociationObj.Territory2Id,userT2AssociationObj);        	
            }
        }
		
        System.debug('*****TerritoryPrimarySalesRep*****'+TerritoryPrimarySalesRep);
        Logger.pop();
        return TerritoryPrimarySalesRep;
    }


}