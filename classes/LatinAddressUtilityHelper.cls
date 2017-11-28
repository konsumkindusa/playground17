/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 14 May 2014, Last Modified: 15 July 2015
 *@description This  is handler class for Address .
 *@revision: 15 July 2015|Archana Lohar | 805367 - added getStateListByCountryCode method and code to get the statecode list for the countries that require states. 
 *@revision: 07 Aug 2017    | Donna Latte |1990230 - System.LimitException: Apex heap size too large. Add missing Logger.pop(); to methods: getlatinString and getStateListByCountryCode.
 */
public with sharing class LatinAddressUtilityHelper {

    public map<string,string> latinStateMap= new map<string,string>();
    public map<string,string> stateCodesUnderCountriesMap= new map<string,string>();
    string latinRegEx;
    string UnicodeRegEx;

    General_Settings__c settings ;

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 14 May 2014 
     *@Last Modified: 18 July 2015
     *@Description: . Constructor will get the values form custom setting named Address_Latin_Translation__c 
                     and store the values in latinStateMap for re usability
     */
    public LatinAddressUtilityHelper(){

        list<Address_Latin_Translation__c> custSetList 
        = Address_Latin_Translation__c.getAll().Values();

        if(!custSetList.isEmpty() && custSetList != NULL){

            for(Address_Latin_Translation__c aLT: custSetList){
                if(aLT.State_Local__c != '' && aLT.State_Local__c!= NULL){
                    //latinStateMap.put(aLT.State_Local__c,aLT.State_Latin__c != NULL ? aLT.State_Latin__c : '');
                    latinStateMap.put(aLT.Name,aLT.State_Latin__c != NULL ? aLT.State_Latin__c : '');  

                }//if
            }//for
        }//if   
        
        list<StateCodeList__c> stateCodesCustSetList = StateCodeList__c.getAll().Values();

        if(!stateCodesCustSetList.isEmpty() && stateCodesCustSetList != NULL){

            for(StateCodeList__c stateC: stateCodesCustSetList){
                if(stateC.StateCodesUnderCountryCode__c != '' && stateC.StateCodesUnderCountryCode__c!= NULL){
                    
                      if(stateCodesUnderCountriesMap.containsKey(stateC.CountryCode__c)){
                          
                          stateCodesUnderCountriesMap.put(stateC.CountryCode__c,stateCodesUnderCountriesMap.get(stateC.CountryCode__c)+stateC.StateCodesUnderCountryCode__c);  
                     
                      }
                      else{
                          stateCodesUnderCountriesMap.put(stateC.CountryCode__c,stateC.StateCodesUnderCountryCode__c != NULL ? stateC.StateCodesUnderCountryCode__c : '');  
                     
                      }
                }//if
            }//for
        }//if   

        //getting the vlaues for general settings
        settings = General_Settings__c.getInstance(); 
        //getting the vlaues of regular expression(non latin) from general settings
        latinRegEx = settings.RegEx_Latin__c != NULL ? settings.RegEx_Latin__c : '';
        //getting the vlaues of regular expression(Unicode characters) from general settings
        //UnicodeRegEx = settings.RegEx_Unicode__c != NULL ? settings.RegEx_Unicode__c : '';


    }//method


    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 14 May 2014 
     *@Last Modified: 14 May 2014
     *@Description: . It will accept the non latin text and will return the mapped latin text
     */ 
    public string getlatinString(String StlocalValue){
        
        Logger.push('StlocalValue','LatinAddressUtilityHelper');
        if(!latinStateMap.isEmpty() && latinStateMap.containsKey(StlocalValue)){
            Logger.pop();
            return latinStateMap.get(StlocalValue);
        } 
        Logger.pop();      

        return '';

    }

    public Address getLatinAddress(Address localAddress){ 

        Logger.push('getLatinAddress','LatinAddressUtilityHelper');
        Address replaceAddr = new Address();
        
        if(!isLatin(localAddress.getState())){
        replaceAddr.setCountry(localAddress.getCountry());
        replaceAddr.setState(getlatinString(localAddress.getStateCode())) ; 
        
        }
        Logger.pop(); 
        return replaceAddr;

    }

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 14 May 2014 
     *@Last Modified: 14 May 2014
     *@Description: . It will check the whteher the text is latin/non latin
     */ 
    public boolean isLatin(String state){
        Logger.push('isLatin','LatinAddressUtilityHelper');
        Boolean result = false;
        if(Pattern.matches(latinRegEx, state))
        {                         
            result=true;
        }
        Logger.pop(); 
        return result;
    }
    
    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 11 March 2016
     *@Description:It will Return statecodes under country
     */ 
    public String getStateListByCountryCode(String countryCode){
        Logger.push('getStateListByCountryCode','LatinAddressUtilityHelper');
       
        if(stateCodesUnderCountriesMap.containsKey(countryCode)){
           Logger.pop(); 
           return stateCodesUnderCountriesMap.get(countryCode);
            
        }
        else{
            Logger.pop();
            return 'stateNotFound';
            
        }
        
    }


    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 14 May 2014 
     *@Last Modified: 14 May 2014
     *@Description: method to return the map of country code and country names
     */
    public map<String,String> getCountryMap(List<Schema.PicklistEntry> values){
        Logger.push('getCountryMap','LatinAddressUtilityHelper');
        map<String,String> countryMap=new map<String,String>();


        for (Schema.PicklistEntry a : values) { 

            countryMap.put(a.getValue(),a.getLabel());
        }
        Logger.pop(); 
        return countryMap;

    }
    
    /**
     *@Author Original: Andre Calimlim 
     *@Last Modified: 25 May 2014
     *@Description: method to return the map of country code having a key of country names
     */
    public map<String,String> getLongCountryMap(List<Schema.PicklistEntry> values){
        Logger.push('getLongCountryMap','LatinAddressUtilityHelper');
        map<String,String> countryMap=new map<String,String>();


        for (Schema.PicklistEntry a : values) { 

            countryMap.put(a.getLabel(), a.getValue());
        }
        Logger.pop(); 
        return countryMap;

    }
    /**
     *@Author Original: kishore AN - Cloud Sherpas/Mathworks 
     *@Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *@Date Original: 19 May 2014 
     *@Last Modified: 19 May 2014
     *@Description: . method to return the statecode as countrycode-statecode
     */

    public String getStateCode(String countryCode, String stateCode){
        Logger.push('getStateCode','LatinAddressUtilityHelper');
       
        String countryStateCode = null;
        //Map<String, String> countryMap = this.getCountryMap();

        countryStateCode = countryCode != NULL ? countryCode : '';
        countryStateCode+= stateCode != null ? '-'+stateCode : '';

      
        Logger.pop(); 
        return countryStateCode;    
    }     
}