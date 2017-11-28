/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original:23 Feb 2016, Last Modified: 10 March 2016
 *@description:This is a controller class for TerritorySummary page.
 */

public with sharing class TerritorySummaryController {

    public Id territory2Id {get;set;}
    public Id TerritoryShadowObjId {get;set;}
    public Id assignmentRuleIdToEdit {get;set;}
    public boolean showCriteria{get;set;}
    public boolean needreloadAgain{get;set;}
    public boolean showCriteriaValue{get;set;}
    public boolean isOnlyOneRule{get;set;}
    public boolean showCriteriaObj{get;set;}
    public String ruleObjId{get;set;}
    public String ruleObjIdMatched{get;set;}
    public String criteriaObjId{get;set;}
    
    public Map<id,boolean> showHideCriteriasMap{get;set;}
   
    Territory_Management_Settings__c settings ;
    
    public List<Territory_Assignment_Rule__c> assignmentRuleList {get; set;}
    public Map<id,Territory_Assignment_Rule__c> assignmentRuleMap;
    public Map<id,id> territoryCriteriaSelectedMap{get; set;}
       
    public List<Territory_Rule_Criteria__c>  criteriaList {get; set;}

    public TerritorySummaryController(ApexPages.StandardController controller) {
    
        territoryCriteriaSelectedMap = new Map<id,id>();
        showHideCriteriasMap = new Map<id,boolean>();
        showCriteriaObj = true;
    
        assignmentRuleMap = new Map<id,Territory_Assignment_Rule__c>();
        
        //For Reloading Page to reflect Updated data
        String reloadAgain = ApexPages.currentPage().getParameters().get('reload');
        if(reloadAgain=='true'){needreloadAgain=true;}
        
        TerritoryShadowObjId= ApexPages.currentPage().getParameters().get('ID');
        
        assignmentRuleList = new List<Territory_Assignment_Rule__c>();
        
        //Get List of Assignment rules        
        String query = UtilityHelper.generateQueryFromFieldSet('Territory_Assignment_Rule__c','AssignmentRuleFieldSet',null,'Territory__c =\'' + TerritoryShadowObjId + '\' ORDER BY Name'); 
        assignmentRuleList = database.query(query);
     
        //Getting map of Assignment Rules For Delete functionality 
        for(Territory_Assignment_Rule__c ruleObj:assignmentRuleList ){
            
            assignmentRuleMap.put(ruleObj.id,ruleObj);
            showHideCriteriasMap.put(ruleObj.id,true);
        
        }
        
        criteriaList = new List<Territory_Rule_Criteria__c>();
        
    }
    
    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 24 Feb 2016
     *@Date Original: 24 Feb 2016
     *@Description: Method to redirect to edit page of Territory2 Object
     *               
     */
   
    public PageReference getTerritory2Id() {
    
       Territory_Shadow__c shadowObj = [select Salesforce_Territory_ID__c  from Territory_Shadow__c where id=:TerritoryShadowObjId Limit 1];
       territory2Id = shadowObj.Salesforce_Territory_ID__c;
       return null;     
       
    }
    
    
    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 23 Feb 2016
     *@Date Original: 23 Feb 2016
     *@Description: Method to redirect to edit page of Territory2 Object
     *               
     */ 
    public PageReference redirectToTerritory2Edit() {
    
        PageReference pg = new PageReference('/'+territory2Id+'/e');
        String returlstr='/apex/Territorysummary?id='+TerritoryShadowObjId;
        String encreturl=EncodingUtil.URLEncode(returlstr,'UTF-8');
        pg.getParameters().put('retURL', returlstr);
        pg.getParameters().put('isdtp','vw');
        return pg;     
       
    }
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 23 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to redirect to ManageTerritoryUsers of Territory2 Object
     *               
     */ 
    public PageReference redirectToManageTerritoryUsersEdit() {
    
        //Fetching date from Territory Management Settings 
        settings = Territory_Management_Settings__c.getInstance();
        
        return new PageReference(settings.Add_users_To_Territory_URL__c+territory2Id+'&retURL=/apex/Territorysummary?id='+TerritoryShadowObjId);      
         
    }
    
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 26 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to redirect to edit page of Assignment Rule Object
     *               
     */ 
    public PageReference editAssignmentRule() {
    
        PageReference pg = new PageReference('/'+assignmentRuleIdToEdit +'/e');
        String returlstr='/apex/Territorysummary?id='+TerritoryShadowObjId;
        //String encreturl=EncodingUtil.URLEncode(returlstr,'UTF-8');
        pg.getParameters().put('retURL', returlstr);
        //pg.getParameters().put('isdtp','vw');
        return pg;   
         
    }
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 26 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to delete Assignment Rule
     *               
     */ 
    public PageReference deleteAssignmentRule() {
         
      delete assignmentRuleMap.get(assignmentRuleIdToEdit);
      return null;   
          
    }
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 26 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to redirect to new page of Territory Asignment Rule Object
     *               
     */ 
    public PageReference newAssignmentRule() {
   
      Schema.DescribeSObjectResult r = Territory_Assignment_Rule__c.sObjectType.getDescribe();
      String keyPrefix = r.getKeyPrefix();
      
      Territory_Shadow__c shadowObj = new Territory_Shadow__c();
      shadowObj = [select id,name from Territory_Shadow__c where id=:TerritoryShadowObjId limit 1];
      
      settings = Territory_Management_Settings__c.getInstance();
      String fieldId = settings.Territory_Shadow_Field_Id__c;
        
      PageReference pg = new PageReference('/'+keyPrefix+'/e');
        String returlstr='/apex/Territorysummary?id='+TerritoryShadowObjId;
        String encreturl=EncodingUtil.URLEncode(returlstr,'UTF-8');
        pg.getParameters().put('retURL', returlstr);
        pg.getParameters().put('CF'+fieldId,shadowObj.name);
        pg.getParameters().put('CF'+fieldId+'_lkid',TerritoryShadowObjId);
        pg.getParameters().put('Name',shadowObj.name);

        return pg;
    }
    
    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 26 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to redirect to clone page of Territory Asignment Rule Object
     *               
     */ 
    public PageReference CloneAssignmentRule() {
   
        PageReference pg = new PageReference('/'+assignmentRuleIdToEdit +'/e?clone=1');
        String returlstr='/apex/Territorysummary?id='+TerritoryShadowObjId;
        String encreturl=EncodingUtil.URLEncode(returlstr,'UTF-8');
        pg.getParameters().put('retURL', returlstr);
        return pg;      
    }
    
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 29 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to get all Criteria objects related to assignment Rule
     *               
     */ 
   public PageReference getCriteriaObjs() {
       
       
       ruleObjId = ApexPages.CurrentPage().getParameters().get('AssignmentRuleId');  
       system.debug(ruleObjId );
       If(ApexPages.CurrentPage().getParameters().get('isShowCriteriaObj')!=null){      
           showCriteriaObj= Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('isShowCriteriaObj'));
           showHideCriteriasMap.put(ruleObjId,showCriteriaObj);
       }
       return null;
      
    }
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 29 Feb 2016
     *@Date Original: 10 March 2016
     *@Description: Method to get selected Criteria Value objects Id
     *               
     */ 
    public PageReference getCriteriaValueObjs() {
       if(ApexPages.CurrentPage().getParameters().get('showCriteriaObj')!=null){
           showCriteria = Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('showCriteriaObj'));
       }
       criteriaObjId  = ApexPages.CurrentPage().getParameters().get('CriteriaId'); 
       Territory_Rule_Criteria__c criteriaObj = new Territory_Rule_Criteria__c();
       criteriaObj = [select Territory_Assignment_Rule__c from Territory_Rule_Criteria__c where id=:criteriaObjId limit 1];
       ruleObjIdMatched = criteriaObj.Territory_Assignment_Rule__c; 
       showCriteriaValue = true;
       return null;
      
    }
}