/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik, Dennis Atwood
 *@date Original: 9 June 2014, Last Modified: 10th April 2015, 21th July 2015, 3rd September 2015
 *@description This is controller for LeadConversion Page
 *             Updated the code to set the proper owner of the task on lead conversion
 *@revision: Archana Lohar:set default system owner for opportunity/Task by using name stored in general custom setting.
             Archana lohar|1st April 2015|Modified code for diffrent account options selected by user for unknown contact record type
             Archana lohar|10th April 2015|Modified code for reducing number of soql queries
             Faina Gorelik|21th July 2015|Modified code to fix assigning Opportunity Contact Role for the existing opportunity
             Faina Gorelik|3rd September|Modified code to fix sending email notification to the converted lead opportunity owner AtTask 1062737
             Faina Gorelik|5th May 2016|Modified code to default task type to To Do on Lead Conversion AtTask 1514606
             Dennis Atwood|26th May 2017|Added code to concatenate Competitor__c multi-picklist values from Lead to Task Comments text field
 */
public with sharing class LeadConversionController {
    //Initializing variables
    public Boolean doNotCreateOpty{get; set;}
    public Boolean doNotCreateActivity{get; set;}
    public Boolean accountFound{get; set;}
    public String leadId;
    public Lead leadObj{get;set;}
    public String ownerID{get;set;}
    public Account acc{get;set;}
    public String knownContRT{get;set;}
    public String unKnownContRT{get;set;}
    //public String Subject{get;set;}
    //public String Status{get;set;}
    public String errorMessage=System.Label.LeadConversionErrorMessage;
    public String covertedLeadURL=System.Label.ConvertedLeadPageURL;
    public String TaskSubjectOnLeadConversion = System.Label.Task_subject_on_lead_conversion;
    General_Settings__c settings ;

    //FG
    public Boolean isExistingOpty{get; set;}
    public List<OpportunityContactRole> lstOptyContactRole;
    Public Boolean FoundContactId;
    Public String HandRaiserInfo;
    //FG
    
    public Database.LeadConvertResult lcr;
    public List<Contact> contObjList;
    public List<Account> accObjList{get;set;}
    public List<Account> accObjListByLoc=new List<Account>();
    public boolean selected {get; set;} 
    public Boolean knownContactLead;
    public Boolean runAssignmentRules; 
    public String selectedValue { get; set; }
    public Map<id,Account> accMap;
    String pleaseSelectAccountMessage= Label.Unknown_Contact_Lead_Select_Account_message_for_partial_match;
    String seleactatleastOneOptionMessage=Label.UnknownContactLeadIndicatorAccountOptionLabel;



    //Fetching Lead status
    public LeadStatus convertStatus; 

    //public String testError {get;set;}


    //This is to select Account for conversion
    public String selAccountid;

    //This is to select Account for conversion
    public String accountId;
    public list<User> usrObjByName;

    //For task creation
    public Task taskID {get; set;}

    // this is the checkbox indicating whether to send an email notification
    public Boolean sendNotificationEmail {get; set;}
    
    
    
    //JM - Create picklist of Task Status values

    public String selectedStatus {get;set;}

    public List<SelectOption> getStatusOptions() {
        List<SelectOption> statusOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> listStatusValue = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry statusValue : listStatusValue)
        {
             if(statusValue.getValue() != 'Completed')
             {
                 statusOptions.add(new SelectOption(statusValue.getLabel(), statusValue.getValue()));
             }    
        }     
        
        return statusOptions;
    }
    

    public LeadConversionController(ApexPages.StandardController controller){}

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 18 June 2014 
     *@Last Modified: 08 Sept 2014
     *@Description: . It will query the lead record by id passed in url
     *@revision:      Updated the method to check if Account is already associated with the Unknown Contact Lead
     */ 
    public void getLeadRecordToConvert(){

        Logger.push('getLeadRecordToConvert','LeadConversionController');

        try{
            //Fetching date from General custom setting
            settings = General_Settings__c.getInstance();

            //Set accountFound
            accountFound=false;
            
            isExistingOpty = false;

            selectedValue='';

            convertStatus= [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];

            //Getting recordtype id 
            knownContRT=UtilityHelper.getLeadRecordTypeId('Known Contact');
            unKnownContRT=UtilityHelper.getLeadRecordTypeId('Unknown Contact');

            //Get user to set default opportunity and task owner by custom setting
            //We will query using alias as querying by name has issues with different locales
            usrObjByName=new List<User>();
            usrObjByName=[select id,name from User where alias=:settings.Default_Opportunity_Owner__c ];

            //Getting lead id from url
            leadId=System.currentPageReference().getParameters().get('id');

            //Checking for null and  blank value
            if(leadId!=null && leadId!=''){
                //FG added new existing opportuity field to the query, added 2 handraiser fields to the query AtTask
                //DMA added Competitor__c field to query for story 1770924
                leadObj=Database.query('select account__c,Existing_Opportunity__c,Company,name,Country,contact__C,account__r.name,email,contact__r.name,ownerid,recordtypeid,Owner.Type,isConverted,Location__c, account__r.Territory_Name__c,Hand_Raiser_Responses__c,Hand_Raiser_Type__c, Competitor__c from lead  where id= \'' + String.escapeSingleQuotes(leadId) + '\''+ ' LIMIT 1');

            }
            if(leadObj!=null)
            {
                /*For showing only simple user lookup instead of 
                                  showing dropdown of user and queue on leadconversion page*/
                acc = new account();
                //acc.ownerid = leadObj.ownerid;

            }

            accObjList=new List<Account>();


            //create the Task object with task subject default
            
            //fg Insert Hand Raiser type and Hand Raiser response into new task description field AtTask
            if ( String.isNotBlank(leadObj.Hand_Raiser_Responses__c ) ||  String.isNotBlank(leadObj.Hand_Raiser_Type__c) ){
            
           
                        if ( String.isNotBlank(leadObj.Hand_Raiser_Responses__c)){
                            if (String.isBlank(leadObj.Hand_Raiser_Type__c)){
                            HandRaiserInfo = leadObj.Hand_Raiser_Responses__c ;  
                            }
                            else
                            {
                                HandRaiserInfo = leadObj.Hand_Raiser_Type__c +': ' + leadObj.Hand_Raiser_Responses__c ; 
                            }
                        }
                    else if (String.IsBlank(leadObj.Hand_Raiser_Responses__c) && String.isNotBlank(leadObj.Hand_Raiser_Type__c)){
                        HandRaiserInfo = leadObj.Hand_Raiser_Type__c; 
                    }
                       
                        if (HandRaiserInfo.length() > 32000){
                            HandRaiserInfo.substring(0,31995);
                        }                         
               taskId = new Task(subject=TaskSubjectOnLeadConversion,Status='Not Started',Priority='Medium',Description = HandRaiserInfo,Type='To Do');                 
                }// both type and response are not null
            else{
                taskId = new Task(subject=TaskSubjectOnLeadConversion,Status='Not Started',Priority='Medium',Type ='To Do');
                }
                
            //DMA - Story 1770924 - Add concatenated values from Lead Competitor__c multi-picklist to Task Description
            If(leadObj.Competitor__c != null){
                if(taskId.Description == null || taskId.Description == '') 
                    taskId.Description = 'Competitors: ' + leadObj.Competitor__c.replace(';',', '); //not using += since null value in Description would be converted to "null"
                else
                    taskId.Description += ' : Competitors: ' + leadObj.Competitor__c.replace(';',', ') ; //add separator before new text        
            }
            
            System.debug(LeadObj.Account__c+'LeadObj.Account__cLeadObj.Account__cLeadObj.Account__cLeadObj.Account__c');
            
            //FG check if there is existing opportunity selected on the lead
            if(LeadObj.Existing_Opportunity__c != null ){
                isExistingOpty = true;
                doNotCreateOpty = true;
                doNotCreateActivity = true;
                lstOptyContactRole = [select ContactId from OpportunityContactRole  WHERE OpportunityId = :LeadObj.Existing_Opportunity__c limit 1000 ]; 
            }

            //For UnknownContact Record Type
            if(LeadObj.RecordTypeId==unKnownContRT){

                //Check for Email field on Lead Object 
                if(leadObj.Email!=null){

                    contObjList=[Select id, AccountId from contact where email=: leadObj.Email];

                }

                if( contObjList!= null && !contObjList.isEmpty() && leadObj.isConverted!=true  )
                {
                    leadObj.contact__c=contObjList[0].id;
                    leadObj.Account__c = contObjList[0].AccountId;
                    //set record type to Known Contact
                    leadObj.recordtypeid=knownContRT;

                    try{
                        //Update Lead Object with Account and Contact lookup By Email
                        update leadObj;
                    }
                    catch (System.DmlException e) {
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            //capture Dml  Process exception 
                            Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                        }
                    }
                }

                else if(LeadObj.Account__c == null){//Search Account by Lead Company and Location, KAN added the check to see if account is associated to the Lead
                    System.Debug('checking if lead has exact match');
                    accObjListByLoc=[Select id, territory_Name__c from Account where name=:LeadObj.company and site=:LeadObj.Location__c limit 1];
                    System.Debug('Acct Exact match:'+accObjListByLoc);

                    if(accObjListByLoc.isEmpty()){
                        System.Debug('Checking for partial match');

                        //Search Account by Lead Company and country
                        //AO: Removed BillingCountryCode and Territory Name from field set so 
                        //they can still be used in the controller but do not need to be displayed to the end user
                        String query = 'SELECT BillingCountryCode, Territory_Name__c,';
                        for(Schema.FieldSetMember f : this.getFields()) {

                            query += f.getFieldPath() + ', ';

                        }   
                        query+= 'FROM Account where name = '+'\'' +String.escapeSingleQuotes(LeadObj.company) + '\' and BillingCountry = '+'\'' + String.escapeSingleQuotes(LeadObj.Country) + '\'';

                        query=query.replace(', FROM', ' FROM');
                        accObjList=Database.query(query);
                        
                        accMap=new Map<id,Account>();
                        for(Account accObj:accObjList){
                        
                         if(!accMap.containsKey(accObj.Id)){
                              accMap.put(accObj.Id, accObj);
                           }
                        
                        }

                    }
                    else{

                        accountFound=true;
                        System.Debug('Account Exact match found');

                    }
                }
            }  
        }
        catch(Exception ex){

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex.getMessage()+'for Lead Id'+leadId);
        }
        Logger.pop();
    }
/*


*/
    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Kishore AN - Cloud Sherpas/Mathworks
     *@Date Original: 9 June 2014 
     *@Last Modified: 08 Sept 2014, updated the code to set the proper task owner
     *@Description:   It will convert the lead and redirect to converted lead page
     *                Optionally can set the opportunity owner, create a task and send email notification. 
     *@revision:      Archana Lohar:set default system owner for opportunity/Task by using name stored in general custom setting.
     *                KAN - Updated code to check if Accoutn already exists on Lead and run the assignment rules.
     */ 
    public PageReference convertLeadObj() 

    {
  system.debug('I am here ' + isExistingOpty + ' -- ' + doNotCreateOpty); 
        Logger.push('convertLeadObj','LeadConversionController');

            doNotCreateActivity = false;
           
        
        if(selectedValue.length()==0 && LeadObj.RecordTypeId==unKnownContRT){

            UtilityHelper.addErrorMessage(seleactatleastOneOptionMessage);
            //DMA - 1281088 do not log an exception for this validation logic
            //Logger.debugException(seleactatleastOneOptionMessage);
            //Logger.pop(); //added logger.pop() call to write to Logs object
            return null;

        }


        try{
            if(leadObj!=null){
                knownContactLead = false;
                runAssignmentRules = false;
                Database.LeadConvert lc = new database.LeadConvert();

                lc.setLeadId(leadObj.Id);

                lc.setConvertedStatus(convertStatus.MasterLabel);

                //Checking for option to create opportunity on conversion
                if(doNotCreateOpty){

                    //do not create opportunity
                    lc.setDoNotCreateOpportunity(true);
                  

                }
                else 
                {
                    if(acc.ownerid!=null){
                        //set changed opportunity owner
                        lc.setOwnerId(acc.ownerid);

                    }
                    else
                    {  
                        if(usrObjByName!=null && !usrObjByName.isEmpty()){
                            //set default opportunity owner from general setting 
                            lc.setOwnerId(usrObjByName[0].id);
                        }

                    }

                }
                //checking account and contact lookup for null for knownContact Record type
                if(LeadObj.RecordTypeId==knownContRT  && leadObj.Account__c!=null && leadObj.Contact__c!=null){
                    lc.setAccountId(leadObj.Account__c);
                    lc.setContactId(leadObj.Contact__c);
                    system.debug('Territory Name : '+leadObj.Account__r.Territory_Name__c);
                    if(leadObj.Account__r.Territory_Name__c != '' || leadObj.Account__r.Territory_Name__c != null)
                        knownContactLead = true;

                    //set opportunity name to Contact Name
                    if(!doNotCreateOpty)
                        lc.setOpportunityName(leadObj.Contact__r.Name);

                }
                else if(LeadObj.RecordTypeId==knownContRT)
                {
                    UtilityHelper.addErrorMessage(errorMessage);
                    Logger.debugException(errorMessage);
                    Logger.pop(); //added logger.pop() call to write to Logs object
                    return null;
                }

                //Logic for unKnownContact record type
                if(LeadObj.RecordTypeId==unKnownContRT) 
                {
                    //set opportunity name to Lead Name
                    if(!doNotCreateOpty)
                        lc.setOpportunityName(leadObj.Name);

                    //KAN 09082014-  check to see if account is already associated with the Lead and use it for conversion
                    if(LeadObj.Account__c != null){


                        lc.setAccountId(LeadObj.Account__c);

                        //KAN 09082014 - Check if the territory assignment is proper on the account so that the opty after lead conversion can be run through assignment
                        if(leadObj.Account__r.Territory_Name__c != '' || leadObj.Account__r.Territory_Name__c != null)
                            runAssignmentRules = true;


                    }
                    //For Exact account match scenario
                    else if(!accObjListByLoc.isEmpty() && accObjListByLoc!=null){

                        //If user wants to go for different account from lookup
                        if(selectedValue=='exsAcc'){

                            //check whether user selected account otherwise show message to select account
                            if(LeadObj.Account__c != null){

                                lc.setAccountId(LeadObj.Account__c);

                                //KAN 09082014 - Check if the territory assignment is proper on the account so that the opty after lead conversion can be run through assignment
                                if(leadObj.Account__r.Territory_Name__c != '' || leadObj.Account__r.Territory_Name__c != null)
                                    runAssignmentRules = true;

                            }
                            else
                            {

                                UtilityHelper.addErrorMessage(pleaseSelectAccountMessage);
                                Logger.debugException(pleaseSelectAccountMessage);
                                return null;
                            }

                        }
                        //If user wants to go for exact  account for lead conversion
                        if(selectedValue=='exactAccount'){

                            lc.setAccountId(accObjListByLoc[0].id);
                            if(accObjListByLoc[0].Territory_Name__c != '' || accObjListByLoc[0].Territory_Name__c != null)
                                runAssignmentRules = true;

                        }

                    }
                    //For partial account match scenario
                    else if(selectedValue=='reccAccs'){
                    
                        system.debug(selAccountid+'selAccountidselAccountidselAccountid');

                        //Check if user selected account from partial matched account
                        if(selAccountid!=null && selAccountid.length()!=0){

                            lc.setAccountId(selAccountid);

                            //List<Account> selAccount = (List<Account>)[select Id, territory_name__c from Account where Id = :selAccountId];
                            
                            if(accMap.get(selAccountid)!= null && (accMap.get(selAccountid).Territory_Name__c != '' ||accMap.get(selAccountid).Territory_Name__c != null)){
                                runAssignmentRules = true;
                                System.Debug('is Account selected to run assignment'+runAssignmentRules);
                            }
                        }
                        else{

                            UtilityHelper.addErrorMessage(pleaseSelectAccountMessage);
                            Logger.debugException(pleaseSelectAccountMessage);
                            return null;
                        }
                    }

                    else if(selectedValue=='exsAcc'){

                        if(LeadObj.Account__c != null){

                            lc.setAccountId(LeadObj.Account__c);

                            //KAN 09082014 - Check if the territory assignment is proper on the account so that the opty after lead conversion can be run through assignment
                            if(leadObj.Account__r.Territory_Name__c != '' || leadObj.Account__r.Territory_Name__c != null)
                                runAssignmentRules = true;


                        }
                        else
                        {

                            UtilityHelper.addErrorMessage(pleaseSelectAccountMessage);
                            Logger.debugException(pleaseSelectAccountMessage);
                            Logger.pop(); //added logger.pop() call to write to Logs object
                            return null;
                        }

                    }

                }

                try{
                    //converting lead
                    lcr= Database.convertLead(lc);
                }
                catch (System.DmlException e) {
                    System.debug('Exception during Lead convert:'+e.getMessage());
                    Logger.debugException(e.getMessage()+'for Lead Id'+leadId);
                    UtilityHelper.addErrorMessage(e.getMessage());
                    Logger.pop(); //added logger.pop() call to write to Logs object
                    return null;
                }
        
                //Set opportunity Close date
                if(!doNotCreateOpty && lcr.success){

                    Map<Id, Opportunity> oppOwners=new Map<Id, Opportunity>();
                    List<id> opptyList = new List<id>();
                    opptyList.add(lcr.getOpportunityId());
                    //Passing the opportunity created during the lead conversion through the Opportunity Assignment Manager 
                    if(knownContactLead || runAssignmentRules) {

                        System.Debug('LCC before running assignment');

                        //Opportunity assignment by roles 
                        OpportunityAssignmentManager.setExecuteDML(false);                            
                        OpportunityAssignmentManager.assignOpportunitiesByTerritoryTeamRoles(opptyList);
                        oppOwners = OpportunityAssignmentManager.oppOwners;

                    }


                    List<Opportunity> OpptyUpdateList = new List<Opportunity>(); 
                    for(Id opptyId:OpptyList){
                        //only the accounts/oppty with territory will run the assignment rules 
                        if(oppOwners.containsKey(opptyId)){
                            Opportunity opptyObj = oppOwners.get(opptyId);
                            //Assigning custom setting's date to converted opportunity close date
                            opptyObj.closeDate=Date.valueOf(settings.Opportunity_Close_Date__c);

                            //Assigning contactID as a primary Contact on Opportunity
                            opptyObj.Primary_Contact__c =lcr.getContactId();

                            OpptyUpdateList.add(opptyObj);
                        }
                        else{
                            //Query converted opportunity
                            Opportunity opptyObj=[Select id,closedate,Primary_Contact__c  from opportunity where id =: opptyId];
                            //Assigning custom setting's date to converted opportunity close date
                            opptyObj.closeDate=Date.valueOf(settings.Opportunity_Close_Date__c);

                            //Assigning contactID as a primary Contact on Opportunity
                            opptyObj.Primary_Contact__c =lcr.getContactId();

                            OpptyUpdateList.add(opptyObj);                            
                        }
                    }

                    try{
                        //update converted opportunity with new close date
                        System.debug('Updating the opportunity during lead conversion');
                        if(OpptyUpdateList.size()> 0)
                            update OpptyUpdateList;

                    }
                    catch (System.DmlException e) {
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            //capture Dml  Process exception 
                            Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                        }
                    }




                }
//FG add converted contact to the opportunity contact role for new unknown lead or check if known contact is already there 
    if (lcr.success && isExistingOpty){
    
                    FoundContactId = false;
                    
                     //List to insert new Contact into OpportunityContactRole table
                     List<OpportunityContactRole> optyConRoleLst=new List<OpportunityContactRole>();            
                    //check if there are any opportunity contact roles existing on the Lead Opportunity. 
                    // build the list of all contact ids from the OpportunityContactRole
                    if (lstOptyContactRole != null && lstOptyContactRole.size()>0 )
                    {

                        for (OpportunityContactRole OptyContacts:lstOptyContactRole){
                        
                           If(OptyContacts.ContactId == lcr.getContactId())
                           {
                             FoundContactId  = true;
                           }

                        }

                    }

                   if (FoundContactId == false){
                               // create new record in OptyContactRole table, Set opty as existing opportunity,set contact to converted contact
                                OpportunityContactRole OptyContactRoleUpdate = new  OpportunityContactRole();
                                OptyContactRoleUpdate.ContactId = lcr.getContactId();
                                OptyContactRoleUpdate.OpportunityId = LeadObj.Existing_Opportunity__C;
                                OptyContactRoleUpdate.Role ='Other';
                                optyConRoleLst.add(OptyContactRoleUpdate);
                    }
                    
                    
              // Added by Jaspreet for AttTask Story# 1061176
 
              List<Task> listTask = [Select Id,Existing_Opportunity_Id__c, WhatId, WhoId from Task where Existing_Opportunity_Id__c != null AND  WhoId = :lcr.getContactId()];
  
system.debug('I am here ' + isExistingOpty + ' -- ' + doNotCreateOpty);                         
              
              for(Task objTask: listTask)
              {
                  objTask.WhatId = objTask.Existing_Opportunity_Id__c;
              }             
                    
system.debug('--- List Task ---' + listTask);
                           
                      try{
                      if (optyConRoleLst.size() > 0){
                          system.debug('faina contact role list to insert:'+ OptyConRoleLst.size());
                      insert(optyConRoleLst);
                      }
               
                       
                      if(listTask.size() > 0)
                      {
                       update listTask;
                      }                       
                      
                       }
                           catch(exception ex)
                        {
                
                            UtilityHelper.addErrorMessage(ex.getMessage());
                            Logger.debugException(ex.getMessage()+'for Lead Id'+leadId);
                            Logger.pop(); //added logger.pop() call to write to Logs object
                            return null;
                        }
                    // Query Opty table by Existing Opty id to find if there is a primary contact, if not set the current contact as a primary on opportunity
                
                }             
//FG end

                // if the lead converting was a success then create a task and also check for checkbox for creating activity
                if (lcr.success  && !doNotCreateActivity && !doNotCreateOpty)
                {
                    // make sure that  user has filled out the Subject field 
                    if(taskID.subject != null)
                    {

                        //set the whatId to the Opportunity Id            
                        taskID.WhatId = lcr.getOpportunityId();

                        //set the whoId to the contact Id
                        taskID.WhoId =  lcr.getContactId();
                        
                        //JM- set TaskStatus
                        
                        taskID.Status = selectedStatus;

                        //set owner of task to create.                        
                        //Get oppty owner after assignment and use that as the task ownerId
                        //Query converted opportunity
                        Opportunity opptyOBj=[Select id,OwnerId from opportunity where id =: lcr.getOpportunityId()];
                        taskId.OwnerId = opptyOBj.OwnerId;  
                        //if the sendNotificationEmail variable  is set then send an email
                        //AC 6.25.2015 - Modified with the requirement that it will send a notification based on ASAP Priority
                        // FG 09.03.15 - remove filter for ASAP 
                      
                            //HW 1673898
                            //create a new DMLOptions class instance
                            Database.DMLOptions dmlo = new Database.DMLOptions();

                            //No need for the following codes since winter 17, email can be turned off by unchecking
                            //My Settings -> Calendar and Reminder -> Activity Reminders -> Email me when someone assigns me a task
                            //Query id for "SFDC Admin"
                            //Id idAdmin = [select id from user where Name = 'SFDC Admin' limit 1] [0].Id;
                            //Supress the email for "SFDC Admin"
                            //if (taskId.OwnerId != idAdmin) {
                                //set the trigger user email flag to true
                                dmlo.EmailHeader.triggerUserEmail = true;
                            //}
                            //insert the task record 
                            database.insert(taskID, dmlo); 
                            //1673898
                    }
                }
            }
        }
        catch(exception ex)
        {

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex.getMessage()+'for Lead Id'+leadId);
            Logger.pop(); //added logger.pop() call to write to Logs object
            return null;
        }
        Logger.pop();
        //redirect to either opportunity or contact only when lead conversion is successful
        if(lcr.success){
            if(!doNotCreateOpty){
                //Redirecting to converted lead page after lead conversion to opportunity detail page
                return new PageReference('/' + lcr.getOpportunityId());
            }
            else{
                //Redirecting to converted lead page after lead conversion to contact detail page
                return new PageReference('/' + lcr.getContactId() );
            }
        }
        else
        {
            return null;
        }

    }

    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 24 June 2014 
     *@Last Modified: 25 June 2014
     *@Description: It will get  the selected account from list 
     */ 
    public void selectAccount()
    {
        selAccountid = System.currentPagereference().getParameters().get('accountId');
        system.debug(selAccountid +'selAccountid selAccountid selAccountid ');

    }

    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
 private static List<RecordType> recordTypes = [SELECT Id, Name from RecordType WHERE SobjectType =: 'Log__c'];

system.debug('recordTypesrecordTypes'+recordTypes);

 Map<string, schema.recordtypeinfo> recordTypeInfo = Schema.getGlobalDescribe().get('Log__c').getDescribe().getRecordTypeInfosByName();

system.debug('recordTypeInfo55555555555555'+recordTypeInfo);

system.debug(recordTypeInfo.get('Debug').getRecordTypeId());    *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 24 June 2014 
     *@Last Modified: 22 June 2014
     *@Description: It will get the fields of account field set
     */ 
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Account.FieldSets.Account_Field_On_Lead_Conversion.getFields();
    }

}