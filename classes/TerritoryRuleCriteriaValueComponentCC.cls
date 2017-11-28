/**
*@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: Faina Gorelik AtTask 2252571 
*@date Original: 29 Feb 2016, Last Modified: 30 October 2017
*@description This  is Controller class for 'TerritoryRuleCriteriaValueComponent' . 
*@Revision:
*/

public class TerritoryRuleCriteriaValueComponentCC {
    
    public Territory_Rule_Criteria__c territoryRuleCriteria;
    transient public List<Territory_Rule_Criteria_Value__c> territoryRuleCriteriaValueLstAll{get; set;}
    transient public List<Territory_Rule_Criteria_Value__c> territoryRuleCriteriaValueLst{get; set;}
    public List<FieldSetMember> fieldnames{get;set;} 
    public String fieldSetLabel;
    public Id territoryRuleCriteriaValueId{get; set;}
    public Id territoryRuleCriteriaId{get; set;}
    public Id territoryShadowId{get; set;}
    Territory_Management_Settings__c settings ;

    // variables for pagination 
 
    //public integer LimitSize;
    public integer LimitSize;
    //public integer LimitSize = 100;
    public integer PageSizeCustomSet;
    public integer totalrecords = 0;
    public integer OffsetSize = 0;
    public string query;
    
    
    /*
@name         getTerritoryRuleCriteriaValueList
@date         29.Feb.2016, 30 Oct 2017
@author       Abhay Verma, Faina Gorelik - modified query by adding variables for pagination
@param        none.
@return       List. 
@description  Method to get the territoryRuleCriteriaValueLst associated to territory rule criteria. 
*/  
    
    
    public  List<Territory_Rule_Criteria_Value__c> getTerritoryRuleCriteriaValueList(){
        String recordTypeName;
        territoryRuleCriteria = new Territory_Rule_Criteria__c();
        
        settings = Territory_Management_Settings__c.getInstance();
        PageSizeCustomSet = integer.valueof(settings.Criteria_Value_Page_Size__c);
      	LimitSize = PageSizeCustomSet;
        
        //Query to get the Record type of the criteria object.
        territoryRuleCriteria =[select RecordType.DeveloperName from Territory_Rule_Criteria__c where id=:territoryRuleCriteriaId];
        //Store the record type name.
        recordTypeName = territoryRuleCriteria.RecordType.DeveloperName;
        
        //List of TRCRecordTypeToTRCVFieldSetMapping__mdt custom metadata. 
        List<TRCRecordTypeToTRCVFieldSetMapping__mdt> TRCRecordTypeToTRCVFieldSetLst = new List<TRCRecordTypeToTRCVFieldSetMapping__mdt>();
        //Map of criteria record type and criteria field set.
        Map<String,String> TRCRecordTypeToTRCVFieldSetMap = new Map<String,String>();
        fieldnames = new List<FieldSetMember>();
        territoryRuleCriteriaValueLst = new List<Territory_Rule_Criteria_Value__c>();
        territoryRuleCriteriaValueLstAll  = new List<Territory_Rule_Criteria_Value__c>();
        
        //Query TRCRecordTypeToTRCVFieldSetMapping__mdt MetaDataType
        TRCRecordTypeToTRCVFieldSetLst = [select Field_Set__c,Record_Type_Developer_Name__c from TRCRecordTypeToTRCVFieldSetMapping__mdt];
        
        //Filling the TRCRecordTypeToTRCVFieldSetMap Map. 
        for(TRCRecordTypeToTRCVFieldSetMapping__mdt obj : TRCRecordTypeToTRCVFieldSetLst){
            TRCRecordTypeToTRCVFieldSetMap.put(obj.Record_Type_Developer_Name__c, obj.Field_Set__c);
        }
        
        //Get Field set label Name
        if(TRCRecordTypeToTRCVFieldSetMap.containsKey(recordTypeName)){
            
            fieldSetLabel = TRCRecordTypeToTRCVFieldSetMap.get(recordTypeName);
            //Get the appropriate field set for the related record type for the field set.
            if(!(fieldSetLabel.startsWith('TS_'))){
                fieldSetLabel = 'TS_'+fieldSetLabel;
            }
            //Fill the field in the list related to the field set.
            if(fieldSetLabel != null){
                for(Schema.FieldSetMember s:Schema.SObjectType.Territory_Rule_Criteria_Value__c.fieldSets.getMap().get(fieldSetLabel).getFields()){
                    fieldnames.add(s);
                }   
            }
        }
        
        
        //Generate the query from the generateQueryFromFieldSet() Method.
        if(territoryRuleCriteriaId != null){   
            //  String query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c',fieldSetLabel,null,' Territory_Rule_Criteria__c =\'' + territoryRuleCriteriaId+ '\''); 
            query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c',fieldSetLabel,null,' Territory_Rule_Criteria__c =\'' + territoryRuleCriteriaId+ '\''); 
            
            territoryRuleCriteriaValueLstAll = territoryRuleCriteriaValueLst= database.query(query);
            totalrecords = territoryRuleCriteriaValueLstAll.size();
            
            if(recordTypeName == 'Account_Sector'){
                
                query = query+' order by Sector__c';
                
            }
            else if(recordTypeName == 'Account_Country_Code'){
                
                query = query + 'order by Country_Code__c limit : LimitSize offset:OffsetSize';
                
            }
            else if(recordTypeName == 'Account_Name'){ 
                
                query = query + 'order by Account_Name__c limit : LimitSize offset:OffsetSize';
                
            }
            else if(recordTypeName == 'Account_City'){
                
                query = query+' order by City__c';
                
            }
            else if(recordTypeName == 'Account_Postal_Code'){
                
                query = query+' order by Postal_Code_Low__c limit : LimitSize offset:OffsetSize';
                
            }
            else if(recordTypeName == 'Account_State_Code'){
                
                query = query+' order by State_LongName__c limit : LimitSize offset:OffsetSize';
                
            }
            
            //Query the territory rule criteria value object to get the requeired records.
            try{
                territoryRuleCriteriaValueLst= database.query(query);
            }
            catch(Exception ex){
                System.debug('**Query Rule Criteria Value List Error***'+ex.getMessage());
            }
            
        }
        
        //Check if the list is empty or not and send the list of records.
        if((territoryRuleCriteriaValueLst != null) && !territoryRuleCriteriaValueLst.isEmpty()){
            
            return territoryRuleCriteriaValueLst; 
            
            
        }
        else{
            //If the list of criteria value is empty then send null.
            return null;
        }
        
        
    }
    
    /*
@name         editCriteriaValueObj
@date         29.Feb.2016
@author       Abhay Verma
@param        none.
@return       pageReference. 
@description  Method is use to redirect the page to the edit detail pages of the record. 
*/  
    
    public PageReference editCriteriaValueObj(){
        
        PageReference pg = new PageReference('/'+territoryRuleCriteriaValueId+'/e');
        String returlstr='/apex/Territorysummary?id='+territoryShadowId;
        pg.getParameters().put('retURL', returlstr);
        return pg;  
    }
    
    /*
@name         deleteruleCriteriaValue
@date         29.Feb.2016
@author       Abhay Verma
@param        none.
@return       Void. 
@description  Method is use to delete the Territory Rule Criteria Value associated to the Territory Rule Criteria
*/  
    
    public PageReference deleteruleCriteriaValue() {
        
        Territory_Rule_Criteria_Value__c territoryRuleCriteriaValueObj = null;
        if(territoryRuleCriteriaValueLst != null || !(territoryRuleCriteriaValueLst.isEmpty())){        
            for(Territory_Rule_Criteria_Value__c ruleCriteriaValueObj : territoryRuleCriteriaValueLst){
                if(ruleCriteriaValueObj.id == territoryRuleCriteriaValueId){
                    territoryRuleCriteriaValueObj = ruleCriteriaValueObj;
                    break;
                }    
            }
        }
        try{
            if(territoryRuleCriteriaValueObj != null){
                delete territoryRuleCriteriaValueObj;
            }
        }
        
        catch(DMLException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Process exception here
                Logger.debugException('DML Exception :'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
        }
        return new PageReference('/apex/Territorysummary?id='+territoryShadowId+'&reload=true');
        
    }
    
    /** 
*@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
*@Last Modified: 26 Feb 2016
*@Date Original: 10 March 2016
*@Description: Method to redirect to new page of Territory2 Object
*               
*/ 
    public PageReference newTerritoryCriteriaValue() {
        
        //Fetching date from Territory Management Settings 
        settings = Territory_Management_Settings__c.getInstance();
        String fieldId = settings.Territory_Rule_Criteria_field_Id__c;
        
        Territory_Rule_Criteria__c criteriaObj = new Territory_Rule_Criteria__c();
        criteriaObj = [select id,name from Territory_Rule_Criteria__c where id=:territoryRuleCriteriaId limit 1];
        
        Schema.DescribeSObjectResult r = Territory_Rule_Criteria_value__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pg = new PageReference('/'+keyPrefix+'/e');
        String returlstr='/apex/Territorysummary?id='+territoryShadowId;
        String encreturl=EncodingUtil.URLEncode(returlstr,'UTF-8');
        pg.getParameters().put('retURL', returlstr);
        pg.getParameters().put('criteriaId', territoryRuleCriteriaId);
        
        //For Prepopulation Lookup field
        pg.getParameters().put('CF'+fieldId,criteriaObj.name);
        pg.getParameters().put('CF'+fieldId+'_lkid',criteriaObj.id);
        return pg;  
        
    }
    // fg - methods to handle list pagination
    public void beginning()
    {
        OffsetSize = 0;
        query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c',fieldSetLabel,null,' Territory_Rule_Criteria__c =\'' + territoryRuleCriteriaId+ '\'');
        query = query + 'limit : LimitSize offset:OffsetSize';
        territoryRuleCriteriaValueLst= database.query(query);
    }
    
    public void previous()
    {
       // OffsetSize = OffsetSize - Integer.valueOf(LimitSize);//Integer.valueOf(pageSize)
        OffsetSize = OffsetSize - LimitSize;
        query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c',fieldSetLabel,null,' Territory_Rule_Criteria__c =\'' + territoryRuleCriteriaId+ '\'');
        query = query + 'limit : LimitSize offset:OffsetSize';
        territoryRuleCriteriaValueLst= database.query(query);
    }
    
    public void next()
    {   
        OffsetSize = OffsetSize + LimitSize;
        query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c',fieldSetLabel,null,' Territory_Rule_Criteria__c =\'' + territoryRuleCriteriaId+ '\'');
        query = query + 'limit : LimitSize offset:OffsetSize';
        territoryRuleCriteriaValueLst= database.query(query);
        
    }
    
    public void end()
    {
        
        query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c',fieldSetLabel,null,' Territory_Rule_Criteria__c =\'' + territoryRuleCriteriaId+ '\'');
        if(math.mod(totalRecords,LimitSize)==0)
            OffsetSize = totalRecords -Integer.valueOf(LimitSize); 
        else
            OffsetSize = totalRecords - math.mod(totalRecords,LimitSize);
        
        query = query + 'limit : LimitSize offset:OffsetSize';
        territoryRuleCriteriaValueLst= database.query(query);
    }       
    
    public boolean getprev()
    {
        if(OffsetSize == 0)
            return true;
        else
            return false;
    }  
    
    public boolean getnxt()
    {
        if(OffsetSize + LimitSize > totalRecords)
            return true;
        else
            return false;
    }     
}