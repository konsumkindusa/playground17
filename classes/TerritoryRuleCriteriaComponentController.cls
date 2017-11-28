/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified:
 *@date Original: 25 Feb 2016, Last Modified: 
 *@description This  is Controller class for 'TerritoryRuleCriteriaComponent' . 
 *@Revision:
 */


public class TerritoryRuleCriteriaComponentController {

    public Territory_Rule_Criteria__c territoryRuleCriteriaObj;
    public Territory_Rule_Criteria__c territoryRuleObj{get; set;}
    public List<Territory_Rule_Criteria__c> territoryRuleCriteriaLst{get; set;}
    public Id territoryRuleCriteriaId{get; set;}
    public Id territoryShadowId{get;set;}
    public Id ruleObjId{get;set;}
    public String criteriaObjId{get;set;}
    public boolean show{get;set;}
    Map<id,Territory_Rule_Criteria__c> criteriaMap = new Map<id,Territory_Rule_Criteria__c>();
    Territory_Management_Settings__c settings ;
    
    
      /*
      @name         getTerritoryRuleCriteriaValueLst1
      @date         29.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       List. 
      @description  Method to get the territoryRuleCriteriaValueLst associated to territory rule criteria. 
      */  
    
    
    public List<Territory_Rule_Criteria__c> getTerritoryRuleCriteriaList(){
    
       territoryRuleObj = new Territory_Rule_Criteria__c();
     
       Set<String> additionalfields= new Set<String>();
       // Add one string to it
       additionalfields.add('RecordType.DeveloperName');
       if(ruleObjId != null){
           //Generate query using the field set from generateQueryFromFieldSet() Method.        
           String query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria__c','TerritoryRuleCriteriaFieldSet',additionalfields,'Territory_Assignment_Rule__c =\'' + ruleObjId + '\' ORDER BY RecordType.DeveloperName'); 
           territoryRuleCriteriaLst = database.query(query);
      }
       //Check if the list is empty or not.
       if(territoryRuleCriteriaLst != null && !territoryRuleCriteriaLst.isEmpty()){      
           //iterate over the territory rule criteria list and fill the criteria map.
           for(Territory_Rule_Criteria__c criteriaObj:territoryRuleCriteriaLst ){
               criteriaMap.Put(criteriaObj.id,criteriaObj);
           }
       }
       
       //check if the list is empty or not and return the list of criteria records.
       if((territoryRuleCriteriaLst != null) && !territoryRuleCriteriaLst.isEmpty()){
            return territoryRuleCriteriaLst;   
       }
        else{
            //if no criteria records are found then return null.
            return null;
        }
    }
    
      /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 29 Feb 2016
     *@Date Original: 29 Feb 2016
     *@Description: Method to selected Criteria object Id
     *               
     */ 
    public PageReference getCriteriaValueObjs() {
       
         
       criteriaObjId  = ApexPages.CurrentPage().getParameters().get('CriteriaId');  
       //territoryRuleObj =criteriaMap.get(Id.valueof(criteriaObjId));
       
       show = true;
       return null;
    }
    
    /*
      @name         editCriteriaObj
      @date         26.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       pageReference. 
      @description  Method is use to redirect the page to the edit detail pages of the record. 
        */  
    
    public PageReference editCriteriaObj() {
    
        //Create the instance of page reference and redirect to the criteria detail page.
        PageReference pg = new PageReference('/'+territoryRuleCriteriaId+'/e');
        String returlstr='/apex/Territorysummary?id='+territoryShadowId;
        pg.getParameters().put('retURL', returlstr);
        pg.getParameters().put('isdtp','vw');
        return pg;  
    
    }

    /*
      @name         deleteCriteriaRule
      @date         26.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Method is use to delete the Territory Rule Criteria associated to the Territory Assignment Rule 
        */  

    public PageReference deleteCriteriaRule(){
        
        Territory_Rule_Criteria__c territoryRuleCriteriaObj = null;
        //Iterate over the list of territory rule criteria object and delete the selected record.
        if(territoryRuleCriteriaLst != null && !(territoryRuleCriteriaLst.isEmpty())){
            for(Territory_Rule_Criteria__c territoryCriteriaObj : territoryRuleCriteriaLst){
                if(territoryCriteriaObj.Id == territoryRuleCriteriaId){
                    territoryRuleCriteriaObj = territoryCriteriaObj;
                    break; 
                }
            }
        }
        
        try{
            if(territoryRuleCriteriaObj != null){
                //Delete the  selected territory rule criteria record.
                delete territoryRuleCriteriaObj;
            }
        }
        
        catch(DMLException ex){
             for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
        }
        //Redirect to the terriotry shadow record page.
        return new PageReference('/apex/Territorysummary?id='+territoryShadowId+'&reload=true');
    }//End of Method


      /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 26 Feb 2016
     *@Date Original: 26 Feb 2016
     *@Description: Method to redirect to new page of Territory2 Object
     *               
     */ 
    public PageReference newTerritoryCriteria() {
   
        //Fetching date from Territory Management Settings 
        settings = Territory_Management_Settings__c.getInstance();
        String fieldId = settings.Territory_Assignment_Rule_field_Id__c;
           
        Territory_Assignment_Rule__c ruleObj = new Territory_Assignment_Rule__c ();
        ruleObj = [select id,name from Territory_Assignment_Rule__c where id=:ruleObjId limit 1];
        
   
        Schema.DescribeSObjectResult r = Territory_Rule_Criteria__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String ruleCriteriaObjMetadataId = settings.Territory_Rule_Criteria_Metadata_Id__c;
        PageReference pg = new PageReference('/setup/ui/recordtypeselect.jsp?ent='+ruleCriteriaObjMetadataId+'&nooverride=1&save_new_url=%2F'+keyPrefix+'%2Fe');
        String returlstr='/apex/Territorysummary?id='+territoryShadowId;
        String encreturl=EncodingUtil.URLEncode(returlstr,'UTF-8');
        pg.getParameters().put('retURL', returlstr);
        pg.getParameters().put('CF'+fieldId,ruleObj.name);
        pg.getParameters().put('CF'+fieldId+'_lkid',ruleObj.id);
        return pg;   
    }
}//End of class.