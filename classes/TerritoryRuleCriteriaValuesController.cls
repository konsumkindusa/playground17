/**
*@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik - MathWorks, AtTask 2197272 
*@date Original:20 Jan 2016, Last Modified: 9 Feb 2016, 18 October 2017
*@description:This is a controller class for TerritoryRuleCriteriaValues page.
*/
public with sharing class TerritoryRuleCriteriaValuesController {
    
    public ApexPages.StandardController sController;
    public Territory_Rule_Criteria__c currentRecord {get;set;}
    
    public Territory_Rule_Criteria_value__c criteriaValueRec {
        get;
        set;
    }
    public Territory_Rule_Criteria_value__c criteriaValueRecObj {
        get;
        set;
    }
    
    public List < FieldSetMember > fieldnames {
        get;
        set;
    }
    public List < FieldSetMember > TRCFieldSetNames {
        get;
        set;
    }
    public List < FieldSetMember > TRCVAdditionalFieldSet {
        get;
        set;
    }
    public String fieldSetLabel;
    public String recordTypeName;
    
    public String countryCodeToEdit {
        get;
        set;
    }
    public String stateCodeToedit {
        get;
        set;
    }
    public String stateCodeLongName {
        get;
        set;
    }
    public String countryCodeLongName {
        get;
        set;
    }
    
    public Id tCRVId;
    
    public List < Territory_Rule_Criteria_value__c > tRCVObjLst {
        get;
        set;
    }
    
    public boolean showEdit {
        get;
        set;
    }
    public boolean showNew {
        get;
        set;
    }
    public boolean showComponent {
        get;
        set;
    }
    public boolean showStates {
        get;
        set;
    }
    public boolean showOnEditTRCV {
        get;
        set;
    }
    public boolean showOnNewTRCV {
        get;
        set;
    }
    public boolean CountryWithStates {
        get;
        set;
    }
    public boolean RequiredCountry {
        get;
        set;
    }
    public boolean RequiredState {
        get;
        set;
    }
    public ComponentData theData {
        get;
        set;
    }
    public Id territoryShadowId;
    
    List < TRCRecordTypeToTRCVFieldSetMapping__mdt > TRCRecordTypeToTRCVFieldSetLst = new List < TRCRecordTypeToTRCVFieldSetMapping__mdt > ();
    Map < String, String > TRCRecordTypeToTRCVFieldSetMap = new Map < String, String > ();
    
    public TerritoryRuleCriteriaValuesController(ApexPages.StandardController stdCtrl) {
        
        theData = new ComponentData();
        criteriaValueRec = new Territory_Rule_Criteria_value__c();
        
        sController = stdCtrl;
        System.debug('**sController**'+sController);
        fieldnames = new List < FieldSetMember > ();
        
        //Query TRCRecordTypeToTRCVFieldSetMapping__mdt MetaDataType
        TRCRecordTypeToTRCVFieldSetLst = [select Field_Set__c, Record_Type_Developer_Name__c from TRCRecordTypeToTRCVFieldSetMapping__mdt];
        
        //Get Map from TRCRecordTypeToTRCVFieldSetLst 
        for (TRCRecordTypeToTRCVFieldSetMapping__mdt mdtObj: TRCRecordTypeToTRCVFieldSetLst) {
            TRCRecordTypeToTRCVFieldSetMap.put(mdtObj.Record_Type_Developer_Name__c, mdtObj.Field_Set__c);
        }
        
        //Check Territory_Rule_Criteria_value__c id is there
        tCRVId = ApexPages.currentPage().getParameters().get('ID');
        
        //For editing exsisting record
        if (tCRVId != null) {
            
            //For showing edit page on VF
            showEdit = true;
            //Show Additional field when Territory Rule Criteria Value is Edited.
            showOnEditTRCV = True;
            
            
            //Query Territory Rule Criteria Value Object
            criteriaValueRecObj = [SELECT Id, Territory_Rule_Criteria__r.Territory_Assignment_Rule__c, Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c, Territory_Rule_Criteria__r.Territory__c, Territory_Rule_Criteria__r.RecordType.DeveloperName, Territory_Rule_Criteria__r.Score__c FROM Territory_Rule_Criteria_Value__c WHERE Id = : tCRVId];
            
            recordTypeName = criteriaValueRecObj.Territory_Rule_Criteria__r.RecordType.DeveloperName;
            territoryShadowId = criteriaValueRecObj.Territory_Rule_Criteria__r.Territory_Assignment_Rule__r.Territory__c;
            
            //Initialising the list of field set member for territory rule criteria value Object.
            TRCVAdditionalFieldSet = new List <FieldSetMember>();
            
            //Iterating over the List of FieldSetMember to get territory rule criteria value fields
            for (Schema.FieldSetMember s: Schema.SObjectType.Territory_Rule_Criteria_Value__c.fieldSets.getMap().get('Edit_TRCVViewFieldSet').getFields()) {
                TRCVAdditionalFieldSet.add(s);
            }
            
        } else {
            
            //For showing New page on VF
            showNew = true;
            //Show additioanl field when Creating the Territory Rule Criteria Value
            showOnNewTRCV = True;
            Id recId;
            
            //Get Territory Rule Criteria Id
            String retURL = ApexPages.currentPage().getParameters().get('retURL');
            
            if ((retURL.contains('Territorysummary'))) {
                
                recId = ApexPages.currentPage().getParameters().get('criteriaId');
                
            } else {
                
                String recURL = retURL.replace('/', '');
                recId = recURL.left(15);
                
            }
            //Initialise the field set member list for territory criteria list. 
            TRCFieldSetNames = new List <FieldSetMember>();
            
            
            //Query Territory Rule Criteria Object
            currentRecord = [SELECT Id, Territory_Assignment_Rule__r.Territory__c, Territory__c, Territory_Assignment_Rule__c, Score__c, RecordType.Name, RecordType.DeveloperName FROM Territory_Rule_Criteria__c WHERE Id = : recId];
            
            recordTypeName = currentRecord.RecordType.DeveloperName;
            territoryShadowId = currentRecord.Territory_Assignment_Rule__r.Territory__c;
            
            //Iterating over the List of FieldSetMember to get territory rule criteria fields
            for (Schema.FieldSetMember s: Schema.SObjectType.Territory_Rule_Criteria__c.fieldSets.getMap().get('TRCFieldSetForCriteriaValuePage').getFields()) {
                TRCFieldSetNames.add(s);
            }
            
        }
        
        //Get Field set label Name
        if (TRCRecordTypeToTRCVFieldSetMap.containsKey(recordTypeName)) {
            
            fieldSetLabel = TRCRecordTypeToTRCVFieldSetMap.get(recordTypeName);
            
            if (fieldSetLabel.startsWith('TS_')) {
                fieldSetLabel = fieldSetLabel.removeStart('TS_');
            }
            
            System.debug('&&fieldSetLabel&&'+fieldSetLabel);
            
            for (Schema.FieldSetMember s: Schema.SObjectType.Territory_Rule_Criteria_Value__c.fieldSets.getMap().get(fieldSetLabel).getFields()) {
                fieldnames.add(s);
            }
        }
        
        if (recordTypeName == 'Account_Country_Code' || recordTypeName == 'Account_State_Code' || recordTypeName == 'Account_Name') {
            
            //show component on Page
            showComponent = true;
            
            //check if record type is Account_Country_Code
            if (recordTypeName == 'Account_Country_Code') {
                showStates = false;
                CountryWithStates = false;
                RequiredCountry = true;
                RequiredState = false;
            }
            //check if record type is Account_State_Code
            else if (recordTypeName == 'Account_State_Code') {
                showStates = true;
                CountryWithStates = true;
                RequiredCountry = true;
                RequiredState = true;
            } else if (recordTypeName == 'Account_Name') {
                showStates = true;
                CountryWithStates = false;
                RequiredCountry = false;
                RequiredState = false;
            }
        }
        
        if (tCRVId != null) {
            Set < String > additionalfields = new Set < String > ();
            // Add two strings to it
            additionalfields.add('Country_Code__c');
            additionalfields.add('state_code__c');
            additionalfields.add('State_LongName__c');
            additionalfields.add('Country_LongName__c');
            String query;
            
            if(fieldSetLabel!=null && fieldSetLabel!=''){
                query = UtilityHelper.generateQueryFromFieldSet('Territory_Rule_Criteria_value__c', fieldSetLabel, additionalfields, 'id =\'' + criteriaValueRecObj.id + '\'');
             //   System.debug('Faina return query' + query);
            }
            else{
                
                query = 'select Country_Code__c,state_code__c,State_LongName__c,Country_LongName__c from Territory_Rule_Criteria_value__c where id =\'' + criteriaValueRecObj.id + '\'';
            }
            tRCVObjLst = database.query(query);
            countryCodeToEdit = tRCVObjLst[0].Country_Code__c;
            countryCodeLongName = tRCVObjLst[0].Country_LongName__c;
            stateCodeToedit = tRCVObjLst[0].state_code__c;
            stateCodeLongName = tRCVObjLst[0].State_LongName__c;
            
        }
    } //end of TerritoryRuleCriteriaValuesController
    
    /** 
*@Author Original: Archana Lohar - Cloud Sherpas/Mathworks , Faina Gorelik - MathWorks AtTask 2197272 
*@Last Modified: 4 Feb 2016 , 18 October 2018
*@Date Original: 9 Feb 2016 
*@Description: Method to Save TerritoryRuleCriteriaValue Object
*               
*/
    public PageReference saveCustom() {
        
        Logger.push('saveCustom', 'TerritoryRuleCriteriaValuesController');
        PageReference pr;
        //Check If there is CountryState Picklist component on page
        if (showComponent == true) {
            
            if (RequiredCountry && (theData.countrycode == null || theData.countrycode == '--None--')) {
                
                if (showComponent && (countryCodeToEdit == null || countryCodeToEdit == '--None--')) {
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, System.Label.Country_Required);
                    apexpages.addmessage(msg);
                    return null;
                }
            } else if ((RequiredState && (theData.statecode == null || theData.statecode == '--None--'))) {
                
                if (showComponent && (stateCodeToedit == null || stateCodeToedit == '--None--')) {
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, System.Label.State_Required);
                    apexpages.addmessage(msg);
                    return null;
                }
            }
        }
        
        //For Editing exsisting record
        if (tCRVId != null) {
            try {
                if (!tRCVObjLst.isEmpty()) {
                    
                    Territory_Rule_Criteria_value__c valueObj = new Territory_Rule_Criteria_value__c();
                    valueObj = (Territory_Rule_Criteria_value__c) this.sController.getRecord();
                    
                    //first erase all values to avoid bad data(inconsistent Data)
                    tRCVObjLst[0].state_code__c = null;
                    tRCVObjLst[0].State_LongName__c = null;
                    
                    boolean isCountryCodeSame = (countryCodeToEdit == tRCVObjLst[0].Country_Code__c);
                    
                    //  if (theData.countrycode != null && theData.countrycode != '--None--') {
                    if (theData.countrycode != null && theData.countrycode != '--None--' || ( theData.countrycode == '--None--' && theData.CountryName == null )) {
                        
                      //  tRCVObjLst[0].Country_Code__c = theData.countrycode;
                      //  tRCVObjLst[0].Country_LongName__c = theData.countryName;
                      if (theData.countrycode == '--None--'){
                            tRCVObjLst[0].Country_Code__c = null;
                            tRCVObjLst[0].Country_LongName__c = null;
                        }
                        else
                        {
                           
                            tRCVObjLst[0].Country_Code__c = theData.countrycode;
                            tRCVObjLst[0].Country_LongName__c = theData.countryName;
                            
                        } 
                        
                    } //To populate record's countryCode and countryLongName on edit page
                    else if (theData.countrycode != null && theData.countrycode != '--None--' || ( theData.countrycode == '--None--' && theData.CountryName == null )) {
                        //else if (countryCodeToEdit != null && countryCodeToEdit != '--None--')         
                        //  tRCVObjLst[0].Country_Code__c = countryCodeToEdit;
                        // tRCVObjLst[0].Country_LongName__c = countryCodeLongName;
                        // start
                        if (CountryCodeToEdit == '--None--'){
                            tRCVObjLst[0].Country_Code__c = null;
                            tRCVObjLst[0].Country_LongName__c = null;
                        }
                        else
                        {          
                            tRCVObjLst[0].Country_Code__c = countryCodeToEdit;
                         //   tRCVObjLst[0].Country_LongName__c = countryCodeLongName;
                        tRCVObjLst[0].Country_LongName__c = theData.countryName;
                     
                        }
                        //end
                    }
                    if (theData.statecode != null && theData.statecode != '--None--') {            
                        tRCVObjLst[0].state_code__c = theData.statecode;
                        tRCVObjLst[0].State_LongName__c = theData.stateName;
                        
                    } //To populate record's stateCode and stateLongName on edit page
                    else if (stateCodeToedit != null && stateCodeToedit  != '--None--' && isCountryCodeSame  ) {
                        
                        tRCVObjLst[0].state_code__c = stateCodeToedit;
                        tRCVObjLst[0].State_LongName__c = stateCodeLongName;
                        
                    }
                    
                    tRCVObjLst[0].score__c = valueObj.score__c;

                        Update tRCVObjLst; 
                    
                    String urlVal = Apexpages.currentPage().getUrl();
                    
                    if (!(urlVal.contains(territoryShadowId))) {
                        
                        return new PageReference('/' + criteriaValueRecObj.Territory_Rule_Criteria__c);
                    } else {
                        return new PageReference('/apex/Territorysummary?id=' + territoryShadowId);
                    }
                }
            } catch (Exception ex) {
                System.debug('**msg1***'+ex);
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ex.getMessage());
                apexpages.addmessage(msg);
                Logger.debugException(ex.getMessage());
                Logger.pop();
            }
            return null;
            
            
        } //Check If there is CountryState Picklist component on page for new record Page
        else if (showComponent == true) {
            Territory_Rule_Criteria_value__c valueObj = new Territory_Rule_Criteria_value__c();
            valueObj = (Territory_Rule_Criteria_value__c) this.sController.getRecord();
            //Changes By Abhay
            System.debug('Territory Name = '+valueObj.Territory_Rule_Criteria__r.Territory__c);
            //Changes By Abhay
            system.debug(theData.countrycode);
            
            if (theData.countrycode != null || theData.countrycode != '--None--') {
                valueObj.Country_Code__c = theData.countrycode;
                valueObj.Country_LongName__c = theData.countryName;
            } else {
                valueObj.Country_Code__c = null;
            }
            if (theData.statecode != null || theData.statecode != '--None--') {
                valueObj.state_code__c = theData.statecode;
                valueObj.State_LongName__c = theData.stateName;
            }
            try {
                insert valueObj;
                String urlVal = Apexpages.currentPage().getUrl();
                
                if (!(urlVal.contains(territoryShadowId))) {
                    
                    return new PageReference('/' + valueObj.Territory_Rule_Criteria__c);
                    
                } else {
                    return new PageReference('/apex/Territorysummary?id=' + territoryShadowId);
                }
            } catch (Exception ex) {
                System.debug('**msg2***'+ex);
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ex.getMessage());
                apexpages.addmessage(msg);
                Logger.debugException(ex.getMessage());
                Logger.pop();
            }
            return null;
        } else { //For new record
           
            
            try {
                pr = this.sController.save();
                
            } catch (Exception ex) {
                System.debug('**msg3***'+ex);
                apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ex.getMessage());
                apexpages.addmessage(msg);
                Logger.debugException(ex.getMessage());
                Logger.pop();
                return null;
            }
            
            String urlVal = Apexpages.currentPage().getUrl();
            if(pr != null){
                if (!(urlVal.contains(territoryShadowId))) {
                    
                    return new PageReference('/' + currentRecord.id);
                    
                } else {
                    return new PageReference('/apex/Territorysummary?id=' + territoryShadowId);
                }
            }
            return null;
        }
    }
}