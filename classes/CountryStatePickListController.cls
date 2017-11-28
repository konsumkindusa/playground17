/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original: 28 Jan 2016, Last Modified: 
 *@description This  is Controller class for 'CountryStatePickListComponent' . 
 *@Revision:05 Jan 2016|Archana Lohar 
 */
public class CountryStatePickListController {

    public String countrySelected{get;set;}
    public String countrySelectedEdit{get;set;}
    public String stateSelectedEdit{get;set;}
    public String stateSelected{get;set;}
    public Boolean showStateLst{get; set;}
    public Boolean disableState{get; set;}
    public Boolean showCountryLongNamesWithCode{get; set;}
    public List<SelectOption> StateOptionLst{get; set;}
    public ComponentData cData {get;set;}
    Map<String, String> countrylabelToValueMap = new Map<String, String>();
    Map<String, String> statelabelToValueMap = new Map<String, String>();

    public CountryStatePickListController() {
        countrySelected=countrySelectedEdit;
        showCountryLongNamesWithCode = false;
    }

    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified: 28 Jan 2016
     *@Date Original: 28 Jan 2016
     *@Description: Method to get the country name for the country picklist.
     *               
     */ 
    public List<SelectOption> getCountryList(){ 

        Logger.push('getCountryList','CountryStatePickListController');
        
        //Querying the country name with the country metadata type.
        List<Country_Code_List__mdt> countryCodeLst = [SELECT Country_Code__c, Country_Long_Name_Latin__c FROM Country_Code_List__mdt order by Country_Code__c];

        //List to store the country code and country long name.
        List<SelectOption> countryOptionLst = new List<SelectOption>();
        //Store the first entry of the country picklist.
        countryOptionLst.add(new SelectOption('--None--', '--None--'));

        for(Country_Code_List__mdt countryCodeObj : countryCodeLst){
        
            if(showCountryLongNamesWithCode){
                countryOptionLst.add(new SelectOption(countryCodeObj.Country_Code__c, countryCodeObj.Country_Code__c+' - '+countryCodeObj.Country_Long_Name_Latin__c));
            }
            else{
                countryOptionLst.add(new SelectOption(countryCodeObj.Country_Code__c,countryCodeObj.Country_Long_Name_Latin__c));
            }
            //put values in Map
            countrylabelToValueMap.put(countryCodeObj.Country_Code__c,countryCodeObj.Country_Long_Name_Latin__c);
        }
        //Sorting the Country List
        countryOptionLst = UtilityHelper.SortOptionList(countryOptionLst);
        countryOptionLst.add(0,new SelectOption('--None--', '--None--'));
        
        Logger.pop();
        return countryOptionLst;    
    }

    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 29 Jan 2016 
     *@Date Original: 29 Jan 2016 
     *@Description:This method will get list countries which requires state
     *               
     */ 
    public List<SelectOption> getCountryRequiringStateList(){ 

        Logger.push('getCountryRequiringStateList','CountryStatePickListController');
        
        //disable State List on Load
        disableState = true;
        
        List<Country_Code_List__mdt> countryCodeRequiresStateLst = [SELECT Country_Code__c, Country_Long_Name_Latin__c FROM Country_Code_List__mdt where Require_States__c=true order by Country_Code__c];

        //List to store the country code and country long name.
        List<SelectOption> countryOptionLst = new List<SelectOption>();
        countryOptionLst.add(new SelectOption('--None--', '--None--'));

        for(Country_Code_List__mdt countryCodeObj : countryCodeRequiresStateLst){
            if(showCountryLongNamesWithCode){
                countryOptionLst.add(new SelectOption(countryCodeObj.Country_Code__c, countryCodeObj.Country_Code__c+' - '+countryCodeObj.Country_Long_Name_Latin__c));
            
            }
            else{
                countryOptionLst.add(new SelectOption(countryCodeObj.Country_Code__c,countryCodeObj.Country_Long_Name_Latin__c));
            }//put values in Map
            countrylabelToValueMap.put(countryCodeObj.Country_Code__c,countryCodeObj.Country_Long_Name_Latin__c);
        }
        StateOptionLst = new List<SelectOption>();
        StateOptionLst.add(new SelectOption('--None--', '--None--'));
        
        //countryOptionLst = UtilityHelper.SortOptionList(countryOptionLst);
        //countryOptionLst.add(0,new SelectOption('--None--', '--None--'));
        
        Logger.pop();
        return countryOptionLst;
        
    }


    /** 
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified: 28 Jan 2016
     *@Date Original: 28 Jan 2016 
     *@Last Modified: 28 Jan 2016
     *@Description: Method to get the state name associated to the selected country.
     *               
     */ 
    public List<SelectOption> getStateList(){

        Logger.push('getStateList','CountryStatePickListController');
        
        if(countrySelected==null){
        
            countrySelected=countrySelectedEdit;
        
        }
        
        cData.countrycode = countrySelected;
        cData.countryName = CountrylabelToValueMap.get(countrySelected);
        
        StateOptionLst = new List<SelectOption>();
        StateOptionLst.add(new SelectOption('--None--', '--None--'));

        showStateLst = false;
        //Queying the State Code record from the state code metadata.
        List<State_Code_List__mdt> stateCodeLst = [SELECT Country_Code_State_Code__c, State_Long_Name_Latin__c FROM State_Code_List__mdt WHERE Country_Code__c =:countrySelected];
        //Filling the stateOptionLst for the perticular country.
        for(State_Code_List__mdt stateCodeObj : stateCodeLst){
        
            stateOptionLst.add(new SelectOption(StateCodeObj.Country_Code_State_Code__c,stateCodeObj.State_Long_Name_Latin__c));
            //put values in Map
            statelabelToValueMap.put(StateCodeObj.Country_Code_State_Code__c, stateCodeObj.State_Long_Name_Latin__c);
        }
        
        if(!stateCodeLst.isempty()){
        
            //enable State List on Load
            disableState = false;  
            //cData.stateCode = '';
            //cData.stateName = '';     
        }
        else{
            
            //disable State List on Load
            disableState = true;
            
            //cData.stateCode = '';
            //cData.stateName = '';

        }
              
        Logger.pop();
        countrySelectedEdit='';
        return stateOptionLst;             
    } 

    /** 
     *@Author Original:Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 28 Jan 2016 
     *@Date Original: 28 Jan 2016 
     *@Last Modified: 28 Jan 2016 
     *@Description: Method to get the state code
     *               
     */ 
    public void getStateCode(){
    
        system.debug(stateSelected);
    
        if(stateSelected==null){
        
            stateSelected=stateSelectedEdit;
        
        }
        cData.stateCode = stateSelected;
        cData.stateName = statelabelToValueMap.get(stateSelected);
        
        system.debug('@@' + cData.stateCode);
        system.debug(cData.stateName);

    }     
    
     /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: 28 Jan 2016 
     *@Date Original: 28 Jan 2016 
     *@Last Modified: 28 Jan 2016 
     *@Description: Method to get the Country code
     *               
     */ 
    public void getCountryCode(){

        cData.countrycode = countrySelected;
        cData.countryName = CountrylabelToValueMap.get(countrySelected);
        
        List<State_Code_List__mdt> stateCodeLst = [SELECT Country_Code_State_Code__c, State_Long_Name_Latin__c FROM State_Code_List__mdt WHERE Country_Code__c =:countrySelected];
        
        if(stateCodeLst.size() == 0) {
            cData.stateCode = null;
            cData.stateName = '--None--';            
        }
        
        System.debug('@@' + cData);
    }    
}