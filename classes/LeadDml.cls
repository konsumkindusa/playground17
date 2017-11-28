/** 
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks, Faina Gorelik AtTask 1271575
 *date Original: 5 June 2014, Last Modified: 22 July 2015, 03 February 2016
 *description: Class to handle delegated DML operations for Lead object.
 *revision: 04 Nov 2014    | kishore AN | updated the setLeadOwnerIfQueue method
 *revision: 11 Nov 2014    | Archana Lohar | added method associateLeadToCampaign
 *revision: 15 July 2015    | Archana Lohar |805367 - added setStateCodeBycountryStateCode,updateOfficeByCountryCode methods
 *revision: 04 Aug 2017    | Donna Latte |1990230 - System.LimitException: Apex heap size too large. Method ChangeLeadRecordType. in For Loop Logger.debug removed added System.debug
 */
public with sharing class LeadDml {

    //intialize all variable

    Id knownRtId,unknownRtId;
    Map<String,Contact> contMap = new Map<String,Contact> ();
    String kwncont ;
    String unkwncont ;
    // Getting the record type Id for the Lead
    public LeadDml()
    {
        kwncont=UtilityHelper.getLeadRecordTypeId('Known Contact');
        unkwncont=UtilityHelper.getLeadRecordTypeId('Unknown Contact');

    } 

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:5 June 2014, Last Modified: 5 June 2014
     * @description Method that check for existing contacts and change the record type aaccordingly.
     * @param leadset collection of Lead record Ids and List_Lead collection of lead records
     **/
    public  void ChangeLeadRecordType(set <String> leadset,list<Lead> List_Lead) {

        Logger.push('ChangeLeadRecordType', 'LeadDml');
        if(!leadset.isempty())
        {
            //  SOQL to get the contacts and then putting email and contact id in the contact map
            List<Contact> contList = [select Id, AccountId, Email
                                      from Contact
                                      where Email IN :leadset OR ID IN :leadset];
            for(Contact cont : contList){

                if(cont.Email != null && cont.Email != '')
                    contMap.put(cont.Email,cont);
                if(cont.Id != null)
                    contMap.put(cont.Id,cont);
            }


            for(Lead Lc : List_Lead)
            {
                // To populate the accountid on the Lead
                System.Debug('Lead Value : '+lc);

                if(contMap.containsKey(Lc.Contact__c) && Lc.Contact__c!= Null){

                    Lc.Contact__c = contMap.get(Lc.Contact__c).Id;
                    Lc.Account__c = contMap.get(Lc.Contact__c).AccountId;
                    Lc.RecordTypeId = kwncont;
                }
                else if(contMap.containsKey(Lc.email ) && Lc.email != Null){

                    Lc.Contact__c = contMap.get(Lc.email).Id;
                    Lc.Account__c = contMap.get(Lc.email).AccountId;
                    Lc.RecordTypeId = kwncont;
                }
                else if(Lc.Contact__c== Null){

                    Lc.RecordTypeId = unkwncont;

                }



            }
        }

        Logger.pop(); 

    }

    /**
     * @author Original: Faina Gorelik
     * @date Original:07 May 2015, Last Modified: 
     * @description: Method set Lead status to Closed when Outcome has been selected
     * @param leadList collection of Leads whose Outcome has been selected
     **/

    public void UpdateStatusFromOutcome(List<Lead> leadList){

        Logger.push('UpdateStatusFromOutcome','LeadDML');  

        for (Lead Lc: leadList){
            Lc.Status = 'Closed - Unconverted';

        }
        Logger.pop();
    }

    /**
     * @author Original: Kishore AN - Cloud Sherpas/Mathworks
     * @date Original:30 Oct 2014, Last Modified: 
     * @description: Method that updates the address and Latin address fields 
     *    based on the country state code and country code
     * @param leadList collection of Leads whose address needs to be set/updated
     **/

    public void updateAddrByCountryStateCode(List<Lead> leadList){

        Logger.push('updateAddrByCountryStateCode','LeadDML');

        List<Lead> leadListupdate = new List<Lead>();

        //instantiating CS_LatinAddressUtilityHelper class
        LatinAddressUtilityHelper utilObj = new LatinAddressUtilityHelper();

        //map to get the country code and names
        Map<string,string>countryMap=utilObj.getCountryMap(Lead.CountryCode.getDescribe().getPickListValues());


        for(Lead Lc : leadList){ 
            
            /*if(Lc.Country_State_Code__c  != null && Lc.CountryCode != null){

                if(Lc.CountryCode == 'US' || Lc.CountryCode == 'CA'){
                    Lc.StateCode=Lc.Country_State_Code__c;                     

                }
                else if((Lc.Country_State_Code__c).split('-').size() == 2 ){
                    
                    Lc.CountryCode = (Lc.Country_State_Code__c).substringBefore('-');
                    Lc.StateCode = (Lc.Country_State_Code__c).substringAfter('-');                       

                }
            }*/

            /* Create the Address object, assign the values to address variables and  pass the object to utility class to get the replaced or converted values if necessary*/
            Address addrObj = new Address();

            addrObj.setCountry(Lc.Countrycode != NULL ? countryMap.get(Lc.Countrycode) : '');    
            addrObj.setStateCode(utilObj.getStateCode(Lc.Countrycode, Lc.StateCode));
            addrObj.setState(Lc.State != NULL ? Lc.State :'');

            //calling utility class to replace the address
            addrObj = utilObj.getLatinAddress(addrObj);

            //setting the replaced values back to Lead address                
            Lc.State_Province_Latin__c = addrObj.getState();
            System.Debug('state latin value:'+ addrObj.getState());
            System.Debug('state latin value2:'+ Lc.State_Province_Latin__c);

            //Country to office mapping for Leads
            /*for(Country_Settings__c contOff: Country_Settings__c.getall().values())
            {
                if(Lc.CountryCode == contOff.Country_Code__c){

                    if(Lc.Office__c != contOff.Office_Name__c){

                        Lc.Office__c = contOff.Office_Name__c;
                        Lc.CurrencyIsoCode = contOff.CurrencyIsoCode; 
                    }
                }

            }*/

            //Logger.debug(Lc.Id);
            leadListupdate.add(Lc);
        }

        try{
            //Database.SaveResult[] srList=Database.update(leadListupdate, false);
            update leadListupdate;

        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }


        Logger.pop();    
    }

    /**
     * @author Original: Kishore AN - Cloud Sherpas/Mathworks
     * @date Original:30 Oct 2014, Last Modified: 
     * @description: Method that updates the Latin address fields based on the country code and state code
     * @param leadList collection of Leads whose latin address feilds needs to be set/updated
     **/

    public void updateAddrByCountryCode(List<Lead> leadList){

        Logger.push('updateLeadAddrByCountryCode','LeadDML');

        //instantiating CS_LatinAddressUtilityHelper class
        LatinAddressUtilityHelper utilObj = new LatinAddressUtilityHelper();

        //map to get the country code and names
        Map<string,string>countryMap=utilObj.getCountryMap(Lead.CountryCode.getDescribe().getPickListValues());


        for(Lead Lc : leadList){ 
            /* Create the Address object, assign the values to address variables and  pass the object to utility class to get the replaced or converted values if necessary*/
            Address addrObj = new Address();
            system.debug(Lc.State+'Lc.State****************');
            addrObj.setCountry(Lc.Countrycode != NULL ? countryMap.get(Lc.Countrycode) : '');    
            addrObj.setStateCode(utilObj.getStateCode(Lc.Countrycode, Lc.StateCode));
            addrObj.setState(Lc.State != NULL ? Lc.State :'');

            //calling utility class to replace the address
            addrObj = utilObj.getLatinAddress(addrObj);

            //setting the replaced values back to Lead address                
            Lc.State_Province_Latin__c = addrObj.getState();
            System.Debug('state latin value:'+ addrObj.getState());
            System.Debug('state latin value2:'+ Lc.State_Province_Latin__c);

        }                


        Logger.pop();    
    }

    /**
     * @author Original:Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:9th June 2014, Last Modified: 
     * @description: Method that updates the office based on the country code
     * @param leadList collection of Leads whose office needs to be set/updated
     **/

    public void updateOfficeByCountryCode(List<Lead> leadList){

        Logger.push('updateLeadAddrByCountryCode','LeadDML');


        for(Lead Lc : leadList){ 

            //Country to office mapping for Leads
            for(Country_Settings__c contOff: Country_Settings__c.getall().values())
            {
                if(Lc.CountryCode == contOff.Country_Code__c){
                    Lc.Office__c = contOff.Office_Name__c;
                    Lc.CurrencyIsoCode = contOff.CurrencyIsoCode;

                }

            }

        }                


        Logger.pop();    
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:5 June 2014, Last Modified: 04 Nov 2014
     * @description Method that check for existing contacts and change the record type aaccordingly.
     * @param leadList collection of Lead records whose owners needs to be set based on owner Id custom field
     * revision: 04 Nov 2014    | kishore AN | Moved the checking to the trigger handler class
     **/

    public void setLeadOwnerIfQueue(List<Lead> leadList){
        Logger.push('setLeadOwnerIfQueue','LeadDML');

        System.debug('**inDML**' +leadList);
        for(Lead Lc : leadList){                           
            Lc.OwnerId = Lc.OwnerId__c;                  
        }
        Logger.pop();
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:11 Nov 2014, Last Modified: 11 Nov 2014
     * @description Method that check for  SFDC_Campaign_ID__c on lead,  if the campaign exists, insert a campaign member for that Lead.
     * @param leadList collection of Lead records having SFDC_Campaign_ID__c
     **/

    public void associateLeadToCampaign(List<Lead> leadList){
        Logger.push('associateLeadToCampaign','LeadDML');

        //SFDC_Campaign_ID__c to associated Camapign Object
        Map<String,Campaign> campaignMap=new Map<String,Campaign>();

        //List of Campaign
        List<Campaign> campList=new List<Campaign>();

        //List of SFDC_Campaign_ID__c
        List<String> idList = new List<String>();

        //List of Campaign member to insert
        List<CampaignMember> campMemberList = new List<CampaignMember>();

        for(Lead LeadObj : leadList){ 

            idList.add(LeadObj.SFDC_Campaign_ID__c);

        }

        //Query Campaigns having SFDC_Campaign_ID__c
        campList=[select id from Campaign where id in:idList];

        for(Campaign campObj:campList){

            //Fill map campaignMap
            //campaignMap.put((String.valueOf(campObj.id)).substring(0, 15),campObj);
            campaignMap.put(campObj.id,campObj);

        }


        for(Lead LeadObj : leadList){ 

            if(campaignMap.containsKey(LeadObj.SFDC_Campaign_ID__c)){

                //Add CampaignMember if campaign exist
                CampaignMember member = new CampaignMember();

                member.CampaignId = campaignMap.get(LeadObj.SFDC_Campaign_ID__c).id;
                member.LeadId = LeadObj.Id;

                campMemberList.add(member);
            }
            else
            {
                //Add Error message in Logger object
                Logger.debugException('Error creating campaign member for Lead '+LeadObj.id+' with Campaign Id'+ LeadObj.SFDC_Campaign_ID__c);

            }
        }

        try{

            if(!campMemberList.isEmpty()){

                insert campMemberList;
            }

        }
        Catch(Exception ex){

            Logger.debug(ex.getMessage());
        }

        Logger.pop();
    }

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:15 July 2015, Last Modified: 15 July 2015
     * @description :set state code from country_state_code if it is valid from Eloqua
     * @param leadList collection of Lead records having country_state_code not null and countrycode requires state
     **/

    public void setStateCodeBycountryStateCode(List<Lead> leadList){
        
        Logger.push('setStateCodeBycountryStateCode','LeadDML');
        LatinAddressUtilityHelper addrHelper=new LatinAddressUtilityHelper();
        
        
        
        for(Lead Lc:leadList){
           
            if(Lc.CountryCode == 'US' || Lc.CountryCode == 'CA') {
                
                if(Lc.Country_State_Code__c!=null && addrHelper.getStateListByCountryCode(Lc.CountryCode)!='stateNotFound' && 
                     addrHelper.getStateListByCountryCode(Lc.CountryCode).contains((Lc.Country_State_Code__c))){
                    
                    Lc.StateCode=Lc.Country_State_Code__c;
                }
                else{
                   
                    Lc.StateCode=null;
                    //Lc.CountryCode=null;
                    
                }

            }
            //check if Country_State_Code__c is Valid
            else if(Lc.Country_State_Code__c!=null && addrHelper.getStateListByCountryCode(Lc.CountryCode)!='stateNotFound' && 
                    addrHelper.getStateListByCountryCode(Lc.CountryCode).contains((Lc.Country_State_Code__c).substringAfterLast('-'))){
               
                //Set stateCode from Country_State_Code__c if valid
                Lc.StateCode=(Lc.Country_State_Code__c).substringAfterLast('-');
                
            }
            else{
                
                 Lc.StateCode=null;
                 //Lc.CountryCode=null;
                 
            }
            
            system.debug(Lc.StateCode);
            system.debug(Lc.CountryCode);
            
        }
        Logger.pop();
    }
    /**
     * @author Original: Faina Gorelik AtTask 1271575
     * @date Original:02 February 2016, Last Modified: 
     * @description: Method set Lead Requester id to OwnerID__c Sales Rep 
     * @param leadList collection of Leads requested by Sales Rep
     **/

    public void UpdateLeadRequester(List<Lead> leadList){

        Logger.push('UpdateLeadRequester','LeadDML');
        Set<String> ownerIdList = new Set<String>();
        for (Lead Lc: leadList){
              ownerIdList.add(Lc.OwnerId__c);
        }
        
        if (ownerIdList.size()>0){
            Map<id,User> mapUserRequester =  new Map<Id,User>([Select id from user where id in : ownerIdList limit 50000]);
                
            for (Lead Lc: leadList){
                if(!mapUserRequester.isEmpty() && mapUserRequester.containsKey(Lc.OwnerId__c)){
                    Lc.Lead_Requester__c= Lc.OwnerId__c;
                }
                else
                {
                    Lc.Lead_Requester__c = null;
                }
            }     
        } 
 
        Logger.pop();
    }


    
     /**
     * @author Original: Jaspreet Monga - Mathworks
     * @date Original:17 Sept 2015, 
     * @description : will assign whatId to task if lead have existing opportunity Story# 1061176
     * @param : mapleadExistingOpportunity
     **/

    public void leadExistingOpportunity(Map<id,Id> mapleadExistingOpportunity){
    
    Set<Id> setLeadId = mapleadExistingOpportunity.keyset();
    
    List<Task> listTask = [Select Id, WhoId, WhatId from Task where WhoId IN : setLeadId limit 1000];
    
    Id IdExistingOpportunity;
    
    for(Task objTask : listTask)
        {
          
          String objTaskWhoId = objTask.WhoId;
          IdExistingOpportunity = mapleadExistingOpportunity.get(objTaskWhoId);
          objTask.Existing_Opportunity_Id__c = IdExistingOpportunity;
        }
        
     update listTask;   
    
    }
    }