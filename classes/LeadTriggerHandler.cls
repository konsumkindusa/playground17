/** 
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Kishore AN - Cloud Sherpas/Mathworks, Faina Gorelik - MW
 *@date Original: 26 May 2014, Last Modified: 22 July 2015, September 23 2015
 *@description This  is handler class for 'LeadMasterTrigger' . 
 *@revision: 5 June 2014 | Archana Lohar | Moved the code to method ChangeLeadRecordType of 
 *                                        LeadDml class of onBeforeInsert and onBeforeUpdate method
 *          9 June 2014  | Archana Lohar | removed the null check for contact  at onBeforeUpdate   
 *          8 July 2014  | Divya Gawade  | Encode Product Interest fields from Eloqua
 *          14 July 2014 | Divya Gawade | Eloqua State Code Integration 
 *          30 Oct 2014  | Kishore AN    | Eloqua country state code integration, Latin Translation,
 *                                         removed product interest fields encoding
 *          04 Nov 2014  | Kishore AN    | Added checks to the sizes of the lists before calling methods
 *                                         on LeadDML class  
 *          11 Nov 2014  | Archana Lohar  | added call to associateLeadToCampaign in onAfterInsert method
 *          22 July 2015 | Kishore AN    | 805367 - Updated the beforeInsert and beforeUpdate methods to set teh office and currency
 *          21 September | Faina Gorelik |1012504 - Updated logic to do not close opportunity when outcome status Existing Opportunity
 *                         
 */

public class LeadTriggerHandler {

    set<String> leadset = new set<String>();
    Map<String,QueueSobject> leadQueuesMap  = UtilityHelper.getLeadQueuesMap();
    List<Lead> ListUpdateLeadRequesterName = new List<Lead>();//fg
    
    //Custom setting for validating contry code requiring states from Eloqua
    Countries_Requiring_States__c cRSSettings;
 

    /**
     * @author Original:Divya Gawade Last Modified: Archana Lohar - Cloud Sherpas/Mathworks , Faina Gorelik AtTask 1271575
     * @date Original: 26 May 2014, Last Modified: 02 February 2016
     * @description Method that handles before insert trigger event on the Lead object
     * @param Account A collection of Lead to create new Lead
     * revision : 04 Nov 2014  | Kishore AN    | Added checks to the sizes of the lists 
     *                 before calling methods on LeadDML class
     */
    public void onBeforeInsert(List<Lead> List_Lead){

        Logger.push('onBeforeInsert','LeadTriggerHandler');
        LeadDml lDml=new LeadDml();
        List<Lead> updateLeadOwners = new List<Lead>();
        List<Lead> LeadListAddrUpdate = new List<Lead>();
        List<Lead> LeadListstateCUpdate = new List<Lead>();
        List<User> LeadListRequester = new List<User>();//fg
        LatinAddressUtilityHelper addrHelper=new LatinAddressUtilityHelper();
      
        //  adding all the email and contacts from lead to the leadset
        for(Lead Lc : List_Lead)
        {
            If(Lc.country!=null && Lc.countrycode==null){
                Country_Settings__c cntrySetting = Country_Settings__c.getValues(Lc.Country);
                if(cntrySetting!=null){
                    Lc.CountryCode = cntrySetting.Country_Code__c;
                }
            }
            System.Debug('Lead Country state code-::'+Lc.Country_State_Code__c+'::'+Lc.CountryCode);
            
         
          //Check if CountryCode from Eloqua is not null
          if(Lc.CountryCode!=null && Lc.Country_State_Code__c!=null && Lc.Country_State_Code__c!=''){
          System.Debug('Lead Country code-::'+Lc.CountryCode+'::');
          System.Debug('Lead Country state code-::'+Lc.Country_State_Code__c+'::');
         
         
             
              //Check if countrycode requires state
            if(addrHelper.getStateListByCountryCode(Lc.CountryCode)!='stateNotFound'){
          
                  LeadListstateCUpdate.add(Lc);
                  
               }
            }
        
            if(Lc.Contact__c !=null){
                {
                    leadset.add(lc.contact__c);
                }
            }
            else if(Lc.Email!=null){
                leadset.add(lc.Email);
            }
        
            if(Lc.OwnerId__c != null && leadQueuesMap.ContainsKey(Lc.ownerId)){
            
                updateLeadOwners.add(Lc);
              }
            // check if the lead requester id is valid user and populate the requester name on UI
            if(Lc.OwnerId__c != null){ 
                   ListUpdateLeadRequesterName.add(Lc);
             
                }
            
            //Eloqua State Code Integration, office
            if( Lc.CountryCode != null ){            
                
                LeadListAddrUpdate.add(Lc);
            }   


        }

            if (ListUpdateLeadRequesterName.size()>0){
                
                lDml.UpdateLeadRequester(ListUpdateLeadRequesterName);
            }  
            
        
        
       if(LeadListAddrUpdate.size() > 0){
        lDml.updateOfficeByCountryCode(LeadListAddrUpdate); 
        }


        if(LeadListstateCUpdate.size() > 0){
            System.Debug('set statecode for the leads:'+LeadListstateCUpdate);
         
            lDml.setStateCodeBycountryStateCode(LeadListstateCUpdate); 
        }
        
      
        //Set Lead Owner if Queue and hidden text field OwnerId has changed
        if(updateLeadOwners.size() > 0)               
            lDml.setLeadOwnerIfQueue(updateLeadOwners);

        if(leadset.size() > 0){                   
            lDml.ChangeLeadRecordType(leadset,List_Lead);
        }
       
        
        
        Logger.pop(); 
    }

    /**
     * @author Original: Divya Gawade, Last Modified: kishore AN
     * @date Original: 26 May 2014, Last Modified: 04 Nov 2014
     * @description Method that handles before update trigger event on the Lead object
     * @param oldmap Lead records with old values
     * @param newmap Lead records with new values
     * revision : 04 Nov 2014  | Kishore AN    | Added checks to the sizes of the lists 
     * before calling methods on LeadDML class
     * revision : 07 May 2014 | Faina Gorelik | Set Status when Outcome updated
     */
    public void onBeforeUpdate(map<Id, Lead> oldmap, map<Id, Lead> newmap){

        Logger.push('onBeforeUpdate','LeadTriggerHandler');

        LeadDml lDml=new LeadDml();
        List<Lead> leadListUpdate = new List<Lead>();
        List<Lead> LeadListAddrUpdate = new List<Lead>();  
        List<Lead> LeadListUpdateStatus = new List<Lead>(); //fg 
        List<User> LeadListRequester = new List<User>();//fg
        List<Lead> LeadListstateCUpdate = new List<Lead>();
        List<Lead> LeadListofficeUpdate = new List<Lead>();
        LatinAddressUtilityHelper addrHelper=new LatinAddressUtilityHelper();
        
       
        for(Lead Lc : newmap.values())
        {
          
            //Updated by Haigang Wu on 04/18/2016, for story 1429194
            //If(Lc.country!=null &&oldmap.get(Lc.Id).country !=Lc.country && oldmap.get(Lc.Id).countrycode != Lc.countrycode){
            If(Lc.country!=null &&oldmap.get(Lc.Id).country !=Lc.country){
                Country_Settings__c cntrySetting = Country_Settings__c.getValues(Lc.Country);
                if(cntrySetting!=null){
                    Lc.CountryCode = cntrySetting.Country_Code__c;
                }
            }
            
            //Check if countrycode from Eloqua is not null
            if(oldmap.get(Lc.Id).countrycode != Lc.countrycode && Lc.CountryCode!=null && Lc.country_state_code__c!=null){
          
              //Check if countrycode requires state
              if(addrHelper.getStateListByCountryCode(Lc.CountryCode)!='stateNotFound'){
          
                  LeadListstateCUpdate.add(Lc);
                  
               }
            }
            
           //Eloqua State Code Integration, office
            if( Lc.CountryCode != null){            
                
                LeadListofficeUpdate.add(Lc);
            }   


            //adding all the email and contacts from lead to the leadset
            if(Lc.Contact__c !=null && Lc.Contact__c != oldmap.get(Lc.ID).Contact__c ){
                leadset.add(lc.contact__c);

            }
            else if(Lc.Email!=null && Lc.Email != oldmap.get(Lc.Id).Email ){
                leadset.add(lc.Email);
            }

            // fg set Status to Closed when outcome populated 5/23/2016 commented
            // if((Lc.Outcome__c != null && oldmap.get(Lc.Id).Outcome__c == null && Lc.Outcome__c != 'Converted' && Lc.Outcome__c !='Existing Opportunity' )|| (Lc.Outcome__c != null && oldmap.get(Lc.Id).Outcome__c == 'Existing Opportunity' && Lc.Outcome__c != 'Existing Opportunity')){  
              if((Lc.Outcome__c != null && oldmap.get(Lc.Id).Outcome__c == null && Lc.Outcome__c != 'Converted' && Lc.Outcome__c !='Existing Opportunity' && Lc.Existing_Opportunity__c ==null )|| (Lc.Outcome__c != null && oldmap.get(Lc.Id).Outcome__c == 'Existing Opportunity' && Lc.Outcome__c != 'Existing Opportunity' && Lc.Existing_Opportunity__c == null)){    
                leadListUpdateStatus.add(lc);

            }
            
             //check if hidden text field ownerId__c is not null, value has changed and the lead status should be Open with Lead Score not equals to 1          
            if(Lc.OwnerId__c != null && Lc.OwnerId__c != oldmap.get(Lc.ID).OwnerId__c
                    && leadQueuesMap.ContainsKey(Lc.ownerId) && (Lc.Status != 'Closed - Converted' || Lc.Status != 'Closed - Unconverted') 
                    && Lc.SFDC_Lead_Score__c != 1 && Lc.SFDC_Lead_Score__c != null){
                    
                leadListUpdate.add(lc);
                System.debug('**Test Lead**' +lc);

            }
            
            //Eloqua State Code Integration, office
            if( Lc.CountryCode != null &&                
                    (lc.CountryCode != oldmap.get(Lc.Id).CountryCode
                    || lc.StateCode != oldmap.get(Lc.Id).StateCode)){
                LeadListAddrUpdate.add(Lc);

            }  
            
             if (Lc.OwnerId__c !=null && Lc.OwnerId__c != oldmap.get(Lc.ID).OwnerId__c){
 
                     ListUpdateLeadRequesterName.add(Lc);
 
            }

        }
        
        
        if(LeadListofficeUpdate.size() > 0){
           lDml.updateOfficeByCountryCode(LeadListofficeUpdate); 
        }
        
        if(LeadListstateCUpdate.size() > 0){
            lDml.setStateCodeBycountryStateCode(LeadListstateCUpdate); 
        }

        //Set Lead Owner if Queue and hidden text field OwnerId has changed
        if(leadListUpdate.size() > 0)
            lDml.setLeadOwnerIfQueue(leadListUpdate); 

        if(leadset.size() > 0)       
            lDml.ChangeLeadRecordType(leadset,newmap.values());
        //fg    
        if ( leadListUpdateStatus.size() >0)
            lDml.UpdateStatusFromOutcome(leadListUpdateStatus);

        //fg
        if (ListUpdateLeadRequesterName.size() >0)
            lDml.UpdateLeadRequester(ListUpdateLeadRequesterName);
        
        if(LeadListAddrUpdate.size() > 0)               
            lDml.updateAddrByCountryCode(LeadListAddrUpdate);
       
        Logger.pop(); 
    }

    /**
     * @author Original: Kishore AN, Last Modified: kishore AN
     * @date Original: 28 October 2014, Last Modified: 04 Nov 2014
     * @description Method that handles AfterUpdate trigger event on the Lead object - Eloqua state code integration , 
     * settig office base on country code
     * @param oldmap Lead records with old values
     * @param newmap Lead records with new values
     * revision : 04 Nov 2014  | Kishore AN    | Added checks to the sizes of the lists 
     *                 before calling methods on LeadDML class
     */
    public void onAfterUpdate(map<Id, Lead> oldmap, map<Id, Lead> newmap){

        Logger.push('onAfterUpdate','LeadTriggerHandler');

        LeadDml ldDml=new LeadDml();
        List<Lead> leadListUpdate = new List<Lead>();
        Map<Id,Id> mapleadExistingOpportunity = new Map<Id,Id>();

        for(Lead Lc : newmap.values())
        {
            //Eloqua State Code Integration, office
            if(Lc.Country_State_Code__c  != null && Lc.CountryCode != null && 
                    (lc.Country_State_Code__c != oldmap.get(Lc.Id).Country_State_Code__c
                    || lc.CountryCode != oldmap.get(Lc.Id).CountryCode
                    //|| lc.StateCode != oldmap.get(Lc.Id).StateCode
                            )){
                leadListUpdate.add(Lc);                
            }
                  
           // If exisiting opportunity opportunity on lead 
             
           if(Lc.Existing_Opportunity__c!=  oldmap.get(Lc.Id).Existing_Opportunity__c)
           {
             mapleadExistingOpportunity.put(Lc.Id, Lc.Existing_Opportunity__c);
           }

        }
        System.Debug('Lead update list:'+leadListUpdate);
        if(leadListUpdate.size() > 0){
            List<Lead> leadList = [SELECT Id, Country,CountryCode,Country_State_Code__c,
                                   Name,StateCode, state, office__c,State_Province_Latin__c, 
                                   CurrencyISOCode FROM Lead where id in :leadListUpdate];

            ldDml.updateAddrByCountryStateCode(leadList);
        }

       //Added by Jaspreet for AtTask Story# 1061176
       
       if(mapleadExistingOpportunity.size() > 0)
       {
           ldDml.leadExistingOpportunity(mapleadExistingOpportunity);
       } 


        Logger.pop(); 

    }

    /**
     * @author Original: Sagar Talele, Last Modified: Archana Lohar
     * @date Original: 8 October 2014, Last Modified: 11 Nov 2014
     * @description Method that handles After insert trigger event on the Lead object
     * revision : 04 Nov 2014  | Kishore AN    | Added checks to the sizes of the lists 
     *                 before calling methods on LeadDML class
     * revision : 11 Nov 2014  | Archana Lohar | Lead to campaign association
     */
    public void onAfterInsert(List<Lead> List_Lead){

        Logger.push('onAfterInsert','LeadTriggerHandler');
        set<Id> leadIdSet = new set<Id>();
        List<Lead> leadListAsso = new  List<Lead>();
        Map<Id,Id> mapleadExistingOpportunity = new Map<Id,Id>();

        for(Lead leadobj:List_Lead ){

            leadIdSet.add(leadobj.id);
     
            //Check if SFDC_Campaign_ID__c of lead record is not null
            if(leadobj.SFDC_Campaign_ID__c!=null) {

                leadListAsso.add(leadobj);

            }   

       // If exisiting opportunity opportunity on lead 
            
            if(leadobj.Existing_Opportunity__c!=  null)
            {
             mapleadExistingOpportunity.put(leadobj.Id, leadobj.Existing_Opportunity__c);
            }   

        }
           
        LeadDml ldDML = new LeadDml();
       
         //Added by Jaspreet for AtTask Story# 1061176
        if(mapleadExistingOpportunity.size() > 0)
         {
               ldDml.leadExistingOpportunity(mapleadExistingOpportunity);
         } 
        
        
        List<Lead> leadList = [SELECT Id, currencyISOCode, Country,CountryCode,Country_State_Code__c,Name,StateCode, state, office__c,State_Province_Latin__c FROM Lead where id in :leadIdSet];

        ldDML.associateLeadToCampaign(leadListAsso);
        ldDML.updateAddrByCountryStateCode(leadList);           
        Logger.pop();

    }   

}