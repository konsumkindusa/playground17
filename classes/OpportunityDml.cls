/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original:18 August 2014, Last Modified: 4 Feb 2015
 *@description This  is handler class for 'OpportunityTriggerHandler' . 
 *@revision :Archana Lohar|4 Feb 2015| Added new method addPrimaryContactRoleToOpty.
 */
public without sharing class OpportunityDml {

  /** 
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
   *@Last Modified:  Archana Lohar - Cloud Sherpas/Mathworks 
   *@Date Original: 18 August 2014 
   *@Last Modified: 18 August 2014
   *@Description: It will calculate USD Amount according to opprtunity currency and exchangerate
   */
  public void calculateUSDAmount(list<Opportunity> optyList){ 

    Logger.push('CalculateUSDAmount','OpportunityDml');
    //Initialize variables
    Map<string,Decimal> isoCodeToRateMap=new Map<string,Decimal>();
    List<CurrencyType> currencyTypeObjList=new List<CurrencyType>();

    //Query all active currencyCode and its ConversionRate map
    currencyTypeObjList=[select IsoCode,ConversionRate  from currencyType where isActive=true];

    for(currencyType typeObj:currencyTypeObjList){

      //Add IsoCode as key and ConversionRate against Corporate currency as value in map
      isoCodeToRateMap.put(typeObj.IsoCode,typeObj.ConversionRate);

    }

    //Update USD Ammount field
    for(Opportunity optyObj:optyList){

      Decimal rate=isoCodeToRateMap.get(optyObj.CurrencyIsoCode);

      //Update USD Ammount field and USD Exchange Rate
      optyObj.USD_Amount__c=(optyObj.Amount/rate);
      optyObj.USD_Exchange_Rate__c=rate;

    }

    Logger.pop();

  }

  /** 
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
   *@Last Modified:  Haigang Wu - Mathworks
   *@Date Original: 22 August 2014 
   *@Last Modified: 27 Oct 2016
   *@Description: It will transfer open activities of old user to new user
   */
  public void transferOnlyOldOwnersActivities(map<Id, Opportunity> newmap, map<Id, Opportunity> oldmap){ 

    Logger.push('transferOnlyOldOwnersActivities','OpportunityDml');

    //HW, 1693606
    //Trigger will fire twice due to workflow. Adding this check to avoid sending email twice.
    if(!CheckRecursive.runOnceTransferOnlyOldOwnersActivities()) return;

    list<Task> taskToUpdateList=new list<Task>();
    //list<Task> taskHighPriorityToUpdateList=new list<Task>();
    list<Event> eventToUpdateList = new List<Event>();
    //List<Id> taskIdList;
    //The purpose of using a map here is to send only one email if multiple tasks are assigned to the same user 
    //Map<Id, List<Id>> ownerIdTaskIdMap = new Map<Id, List<Id>>();

    General_Settings__c settings = General_Settings__c.getInstance();

    for(Opportunity tempOpty:[select id,ownerId,(select id,ownerId,isTask,Priority from OpenActivities) from Opportunity where id in :newmap.keyset()]){
      if(newmap.get(tempOpty.id).ownerid != oldmap.get(tempOpty.id).ownerid){
        for (OpenActivity tempActivity:tempOpty.OpenActivities){

          //SFDC task reassignment behavior is different between the UI and Apex
          //apex integration user need to be handled differently 
          //if (UserInfo.getUserName() == settings.TransferActivitiesIntegrationUserName__c) {
          	  //oldmap
	          if(tempActivity.ownerId==oldmap.get(tempOpty.id).ownerid){
	
	            if (tempActivity.IsTask) {
	            	//If Priority is 'ASAP', add task to taskHighPriorityToUpdateList, prepare map for single email
	            	/*
	            	if (tempActivity.Priority == 'ASAP') {
	        			taskHighPriorityToUpdateList.add(new Task(id=tempActivity.id,ownerId=tempOpty.ownerid));
						taskIdList = ownerIdTaskIdMap.get(newmap.get(tempOpty.id).ownerId);
			            if(taskIdList == null)
			                taskIdList = new List<Id>();
			            taskIdList.add(tempActivity.Id);
			            ownerIdTaskIdMap.put(newmap.get(tempOpty.id).ownerId, taskIdList);
	            	} else */
	        			taskToUpdateList.add(new Task(id=tempActivity.id,ownerId=tempOpty.ownerid));
	            } else 
	            	EventToUpdateList.add(new Event(id=tempActivity.id,ownerId=tempOpty.ownerid));
	            Logger.debug(tempActivity.Id);
	          }
          /*
          } else {
          	  //newmap
	          if(tempActivity.ownerId==newmap.get(tempOpty.id).ownerid){
	
	            if (tempActivity.IsTask) {
	            	/*
	            	if (tempActivity.Priority == 'ASAP') {
		        		taskHighPriorityToUpdateList.add(new Task(id=tempActivity.id,ownerId=tempOpty.ownerid));
						taskIdList = ownerIdTaskIdMap.get(newmap.get(tempOpty.id).ownerId);
			            if(taskIdList == null)
			                taskIdList = new List<Id>();
			            taskIdList.add(tempActivity.Id);
			            ownerIdTaskIdMap.put(newmap.get(tempOpty.id).ownerId, taskIdList);
	            	} else*/
          /*
		        		taskToUpdateList.add(new Task(id=tempActivity.id,ownerId=tempOpty.ownerid));
	            } else 
	            	EventToUpdateList.add(new Event(id=tempActivity.id,ownerId=tempOpty.ownerid));
	            Logger.debug(tempActivity.Id);
	          }
          }
          */
        }

      }
    }

    System.debug('taskToUpdateList: '+taskToUpdateList);
    //System.debug('taskHighPriorityToUpdateList: '+taskHighPriorityToUpdateList);

    try
    {
      //For non-priority tasks, use DMLOptions to send email, it does not use email quota
      //Email can be turned off by uncheck "Email me when someone assigns me a task"
      if (!taskToUpdateList.isEmpty()) {
	    Database.DMLOptions dmlo = new Database.DMLOptions();
	    dmlo.EmailHeader.triggerUserEmail  = true;

		//No need for the following codes since winter 17, email can be turned off by unchecking
		//My Settings -> Calendar and Reminder -> Activity Reminders -> Email me when someone assigns me a task
		//Query id for "SFDC Admin"
		//Id idAdmin = [select id from user where Name = 'SFDC Admin' limit 1] [0].Id;
	
		for (Task t : taskToUpdateList) {
        	//Supress the email for "SFDC Admin"
			//if (t.ownerId != idAdmin) {
				t.setOptions(dmlo);
			//}
		}
		update taskToUpdateList;
      }
      
      //For high-priority tasks, use "SingleEmailMessage" to send email, it does use email quota
      //Email will always be sent out, no matter "Email me when someone assigns me a task" is checked or not.
      //Unlike "DMLOptions", which sends out one email per task, "SingleEmailMessage" solution is customized
      //to handle multiple tasks per email, if the tasks share the same owner. Also, the email subject can be 
      //customized.
      /*
      if (!taskHighPriorityToUpdateList.isEmpty()) {
        Map<Id, User> userMap = new Map<Id, user>([select id, Name, email from user where id in: ownerIdTaskIdMap.keySet()]);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String userEmail, emailBody;
        String emailSubject = 'High priority Task(s) assigned to you, please process ASAP.';

        for(Id ownerId : ownerIdtaskIdMap.keySet()) {
        	
        	//Supress the email for "SFDC Admin"
        	if (userMap.get(ownerId).Name == 'SFDC Admin') continue;
            
            userEmail = userMap.get(ownerId).Email;
            taskIdList = ownerIdtaskIdMap.get(ownerId);
            emailBody = 'For more details, click the following link(s):\r\n';
            for(Id tskId : taskIdList){
            	emailBody = emailBody + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tskId + '\r\n';
            }
            Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
            singleMail.setToAddresses(new String[] {userEmail});
            singleMail.setSubject(emailSubject);
            singleMail.setPlainTextBody(emailBody);
            emails.add(singleMail);
        }

        if(emails.size() > 0) {
        	Messaging.sendEmail(emails);
        }
        update taskHighPriorityToUpdateList;
      }*/
      
      if (!eventToUpdateList.isEmpty()) update eventToUpdateList;
    }
    catch (System.DmlException e) {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        //capture Dml  Process exception 
        Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
      }
    }
    catch(Exception ex){
         Logger.Debug('Exception: '+ex.getMessage());
         Logger.debugException(ex);
    }
  }


  /** 
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
   *@Last Modified:  Archana Lohar - Cloud Sherpas/Mathworks 
   *@Date Original: 3 February 2015 
   *@Last Modified: 3 February 2015
   *@Description: This method will be called from two methods of OpportnityTriggerhandler  
                  AfterInsert and AfterUpdate
                 -Whenever new Opportunity will get Insert with Primary_Contact__c then it will add 
                  new OpportunityContactRole record with isPrimary flag true.
                 -Whenever update happens on opportunity with new value of Primary_Contact__c field,
                  This method will first search for Opportunity Contact role if found then updates  with isPrimary flag true,
                  else will insert new OpportunityContactRole record with isPrimary flag true.
   **/
  public void addPrimaryContactRoleToOpty(List<Opportunity> optyObjList){

    //Initialize Variables
    List<Opportunity> optyList=new List<Opportunity>();
    List<OpportunityContactRole> optyConRoleLst=new List<OpportunityContactRole>();
    List<OpportunityContactRole> optyConRoleLstToUpdate=new List<OpportunityContactRole>();
    Map<id,Map<id,OpportunityContactRole>> optyIdToMapofContactRoleMap = new Map<id,Map<id,OpportunityContactRole>>();

    //Query OpportunityContactRole
    List<OpportunityContactRole> conRoleObj=[Select id,
                                             isPrimary,
                                             OpportunityId,
                                             ContactId
                                             From OpportunityContactRole where OpportunityId in:optyObjList];


    //Fill  optyIdToMapofContactRoleMap
    for(OpportunityContactRole contactRoleObj:conRoleObj){

      if(optyIdToMapofContactRoleMap.containsKey(contactRoleObj.OpportunityId)){
        optyIdToMapofContactRoleMap.get(contactRoleObj.OpportunityId).put(contactRoleObj.ContactId,contactRoleObj);
      }//if
      else{
        optyIdToMapofContactRoleMap.put(contactRoleObj.OpportunityId, new map<id, OpportunityContactRole>
        {contactRoleObj.ContactId => contactRoleObj});
      }//else

    }//for



    for(Opportunity optyObj:optyObjList){

      //Check if there is any ContactRole exist for Opportunity.
      if(!optyIdToMapofContactRoleMap.containsKey(optyObj.id)){

        OpportunityContactRole optyContactRoleObj=new OpportunityContactRole();
        optyContactRoleObj.contactId=optyObj.Primary_Contact__c;
        optyContactRoleObj.OpportunityId=optyObj.id;
        optyContactRoleObj.IsPrimary=true;
        optyConRoleLst.add(optyContactRoleObj);

      }//if
      else
      {
        /*Check if Primary_Contact__c of opportunity is already a ContactRole for it and  
        check if Contact Role is primary or not(needs no update if Contact Role is already primary)*/
                if(optyIdToMapofContactRoleMap.get(optyObj.id).ContainsKey(optyObj.Primary_Contact__c)){  
            
                    if(!optyIdToMapofContactRoleMap.get(optyObj.id).get(optyObj.Primary_Contact__c).isprimary){

          OpportunityContactRole optyContactRoleObj=optyIdToMapofContactRoleMap.get(optyObj.id).get(optyObj.Primary_Contact__c);
          optyContactRoleObj.IsPrimary=true;
          optyConRoleLstToUpdate.add(optyContactRoleObj);
                    }

        }//if
        else
        {
          //Otherwise insert new OpportunityContactRole record.
          OpportunityContactRole optyContactRoleObj=new OpportunityContactRole();
          optyContactRoleObj.contactId=optyObj.Primary_Contact__c;
          optyContactRoleObj.OpportunityId=optyObj.id;
          optyContactRoleObj.IsPrimary=true;
          optyConRoleLst.add(optyContactRoleObj);
        }//else

      }//else

    }//for

    try{

      if(!OptyConRoleLst.isEmpty()){

        insert OptyConRoleLst;

      }//If

      if(!optyConRoleLstToUpdate.isEmpty()){

        update optyConRoleLstToUpdate;

      }//if

    }//try  
    catch (System.DmlException e) {

      for (Integer i = 0; i < e.getNumDml(); i++) {
        //capture Dml  Process exception 
        Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
      }//for

    }//Catch

  }//addPrimaryContactRoleToOpty


  /** 
   *@Author Original: Jaspreet Monga - Mathworks
   *@Last Modified: kishore AN - Cloud Sherpas/Mathworks
   *@Date Original: 15 Sept 2014, Last Modified: 28 Jan 2015 
   *@Description: It will transfer projects from opp to existing opp
                       - query opportunity project table in to list
                       - make list of project ids of projects in opportunity project list
                       - query MW_Project__c which has ids in project id list
                       - associate opportunities to projects in project list
                       - update project list 
   */
  public void assignProjectsToExistingOpp(map<Id, Opportunity> newmap){

    Set<Id>  idSetExistingOpp = new Set<Id>();
    List<Opportunity_Projects__c> associatedproject = new List<Opportunity_Projects__c>();


    for(Id idOpp: newmap.keyset())
    {
      idSetExistingOpp.add(newmap.get(idOpp).Existing_Opportunity__c);
    }

    idSetExistingOpp.addAll(newmap.keyset());        

    associatedproject = [Select Id,Project__c,Opportunity__c,Project__r.Opportunity__c, Opportunity__r.Id,Duplicate_Opportunity_Association__c from Opportunity_Projects__c where Opportunity__r.Id IN: idSetExistingOpp limit 10000]; 

    Set<String> listDupOppAss = new Set<String>();
    for(Opportunity_Projects__c objOppProj :associatedproject)
    {
      listDupOppAss.add(objOppProj.Duplicate_Opportunity_Association__c);
    }

    List<Opportunity_Projects__c> listNewOppproject = new List<Opportunity_Projects__c>();
    Set<String> setStrConctProjOppID = new Set<String>();
    for(Opportunity_Projects__c objOppProj :associatedproject)
    {
      if(null != newmap.get(objOppProj.Opportunity__r.Id)){

        String conctProjOppID = objOppProj.Project__c +''+newmap.get(objOppProj.Opportunity__r.Id).Existing_Opportunity__c;

        Opportunity_Projects__c objNewOppProj = new Opportunity_Projects__c();
        objNewOppProj.Project__c = objOppProj.Project__c;         
        objNewOppProj.Opportunity__c = newmap.get(objOppProj.Opportunity__r.Id).Existing_Opportunity__c;

        if(!listDupOppAss.contains(conctProjOppID) && !setStrConctProjOppID.contains(conctProjOppID) )
        {
          listNewOppproject.add(objNewOppProj);
          setStrConctProjOppID.add(conctProjOppID);
        }
      } 
    }
    insert listNewOppproject; 

  }
   /** 
   *@Author Original: Neha Mahajan - CloudSherpas
   *@Last Modified: 
   *@Date Original: 03 Mar 2016, Last Modified: 
   *@Description: It will collect opportunities and its related competitors
                  - check if there is no competitor for an opportunity which has Reason Competition and StageName non-Win and display a error.
   */
    public void CheckOpportunityComptetitors(List<Opportunity> oppList){
        
        Logger.push('CheckOpportunityComptetitors','OpportunityDml');
        
        // map to hold opportunity and its related competitors
        Map<Id,list<OpportunityCompetitor>> OppIdandOppCompMap= new Map<Id,list<OpportunityCompetitor>>();
        // list of the opportunitycompetitors related to opportunities
        List<OpportunityCompetitor> oppCompetetorLst = [select OpportunityId from OpportunityCompetitor where OpportunityId in :oppList];
        // iterate the list to fill the map 
        
        
        for(OpportunityCompetitor oppcompObj:oppCompetetorLst){
            // if map already contains an opportunity and its associated competitor 
            if(OppIdandOppCompMap.containsKey(oppcompObj.OpportunityId)){
            OppIdandOppCompMap.get(oppcompObj.OpportunityId).add(oppcompObj);
            }
            else{
            // fill the map
            OppIdandOppCompMap.put(oppcompObj.OpportunityId, new List<OpportunityCompetitor>{oppcompObj});
             }
        }
        
        // check for the opportunity reason and stage name
        for(Opportunity opp : oppList){
                
                //check if there is no related competitor 
                if(!OppIdandOppCompMap.containsKey(opp.Id)){
                    // display the error message
                     opp.addError(Label.Competitor_Required);
                }   
        } 
  Logger.pop();

  }
    
    
     /** 
   *@Author Original: Shweta Shanbhag - MathWorks
   *@Last Modified: Shweta Shanbhag - MathWorks
   *@Date Original: 14 Mar 2016, Last Modified: 14 Mar 2016
   *@Description: It will collect opportunities and its related competitors
                  - check if there is no competitor for an opportunity which has Reason Competition and StageName non-Win and display a error.
   */
    public void AutoAssignOpps(List<Opportunity> oppList){
        
        Logger.push('AutoAssignOpps','OpportunityDml');
      
        Map<String,String> OppAutoAssignExcludeRoleMap = new Map<String,String>();
        List<Opp_Assignment_Role_Exclusion__mdt> oppExRoleLst = new List<Opp_Assignment_Role_Exclusion__mdt>();
        List<id> oppAssignList = new List<id>();
        String  OppCreatorRole;
    
        oppExRoleLst = [select DeveloperName, User_Functional_Role__c from Opp_Assignment_Role_Exclusion__mdt];      
        
        for(Opp_Assignment_Role_Exclusion__mdt oppExRoleObj:oppExRoleLst){
           OppAutoAssignExcludeRoleMap.put(oppExRoleObj.User_Functional_Role__c, oppExRoleObj.DeveloperName );          
       }
             
        for(Opportunity opp : oppList){         
            OppCreatorRole = opp.Opp_Creator_Role__c;
            
             if ((String.isBlank(OppCreatorRole)) || (!(String.isBlank(OppCreatorRole)) && !OppAutoAssignExcludeRoleMap.containsKey(OppCreatorRole)))            
            {
                oppAssignList.add(opp.Id);       
            }
        }
        
        if(oppAssignList.size() > 0){ 
            OpportunityAssignmentManager.assignOpportunitiesByTerritoryTeamRoles(oppAssignList);           
        }                   
            Logger.pop();

  }
  
  /** 
     *@Author Original: Abhay Verma - Accenture/Mathworks 
     *@Last Modified:   
     *@Date Original: 6 June 2016 
     *@Last Modified: 
     *@Description: Assigning the Territory team role if the owner of the opportuniry has a role on the territory
     */
    public void assignTerritoryTeamRoleToOptyOwner(list<Opportunity> optyList){
        
        //Set of Account Id Associated to the Opportunity.
        Set<Id> accountIdSet = new Set<Id>();
        //Set of User Id who is the owner of Opportuniry.
        Set<Id> userIdSet = new Set<Id>();
        //Set of Territory Id associated to the Account.
        Set<Id> territory2IdSet = new Set<Id>();
        //Map of User Id and Functional Role
        Map<Id,String> userIdFunctionalRoleMap;
        //Map of Account Id and Territory Id
        Map<Id, Id> accIdTerritoryIdMap;
        //Map of Territory Id and User Territory2 Association Map.
        Map<Id, UserTerritory2Association> usrTerritoryAssocMap;
        //Filling the Set of Account Id and User Id by using Opportunity List
        for(Opportunity oppObj : optyList){
            accountIdSet.add(oppObj.AccountId);
            userIdSet.add(oppObj.OwnerId);
        }
        
        //Querying over the Account to get the Territory Id.
        List<Account> accList = [SELECT Id, Salesforce_Territory_Id__c FROM Account 
                                WHERE Id IN: accountIdSet AND Is_Individual_Account__c = False AND Salesforce_Territory_Id__c != null];
        
        userIdFunctionalRoleMap = new Map<Id, String>();
        List<User> ownerList = [Select Id, functional_Role__c from User where Id in :userIdSet];
            
        for(User usr : ownerList){
            userIdFunctionalRoleMap.put(usr.Id, usr.functional_Role__c);
        }   
        if(accList != null && !accList.IsEmpty()){ 
            
            //Map of Account Id and Territory Id
            accIdTerritoryIdMap = new Map<Id, Id>();
            //Set to collect the Territory Id from accounts
            for(Account accObj :accList){
                territory2IdSet.add(accObj.Salesforce_Territory_Id__c);
                accIdTerritoryIdMap.put(accObj.Id, accObj.Salesforce_Territory_Id__c);
            }
            
            List<UserTerritory2Association> userTerritoryList = new List<UserTerritory2Association>(); 
            if(userIdSet != null && territory2IdSet != null){    
                //Querying the User Territory2 Association Object to get the Territory Team Role and Functional Role of user.
                userTerritoryList = [SELECT Id, RoleInTerritory2, Territory2Id, UserId, User.Functional_Role__c FROM UserTerritory2Association
                                     WHERE UserId IN: userIdSet AND Territory2Id IN: territory2IdSet];                             
            }
            
            
            //Map of Territory Id and User Territory2 Association Map.
            usrTerritoryAssocMap = new Map<Id,UserTerritory2Association>();
            for(UserTerritory2Association utAssocObj : userTerritoryList){
                usrTerritoryAssocMap.put(utAssocObj.Territory2Id, utAssocObj);
            }
        }
        
        //Iterate over the opportunity List
        if(optyList != null && !optyList.isEmpty() ){
            for(Opportunity oppObj : optyList){
                //Check if the Account Id, Territory Id on the Account and owner Id on Opportunity are same for the opportunity record 
                if(accIdTerritoryIdMap!=null && usrTerritoryAssocMap!= null && accIdTerritoryIdMap.containsKey(oppObj.AccountId) && usrTerritoryAssocMap.containsKey(accIdTerritoryIdMap.get(oppObj.AccountId)) && oppObj.ownerId == usrTerritoryAssocMap.get(accIdTerritoryIdMap.get(oppObj.AccountId)).UserId){
                    //Set the Territory Team Role on opportunity as the Role in Territory Team.
                    if(usrTerritoryAssocMap.get(accIdTerritoryIdMap.get(oppObj.AccountId)).RoleInTerritory2 != null){
                        oppObj.Territory_Team_Role__c = usrTerritoryAssocMap.get(accIdTerritoryIdMap.get(oppObj.AccountId)).RoleInTerritory2;
                    }
                    //Set the Territory Team Role as the Functional Role of User
                    else{
                        oppObj.Territory_Team_Role__c = usrTerritoryAssocMap.get(accIdTerritoryIdMap.get(oppObj.AccountId)).User.Functional_Role__c;
                    }
                }
                //If the User is not a part of Territory Team then set Blank on the Field.
                else if(userIdFunctionalRoleMap.containsKey(oppObj.ownerId)){
                    oppObj.Territory_Team_Role__c = userIdFunctionalRoleMap.get(oppObj.ownerId);
                }
            }//End of For
        }//End of If
        
    }//End of Method
}