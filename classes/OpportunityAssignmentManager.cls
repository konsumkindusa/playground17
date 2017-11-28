/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original:20 August 2014, Last Modified: 23 May 2016
 *@description This  is Utilty class for Opportunity Assignment. 
 *@last Modified By:kishore AN -09 July 2015|add one more condition to check for sales manager functional role
 * Added executeDML and OppOwners getters and setters and set the executeDML default to true
 * Attask:518008 - Added getters and setters for massreorg and added logic to set the opty owner on mass opty reorg
 * Attask:1211182 and 1362981 - Changed Opportunity assignment based on user territory association role in territory (and not on the User Default Functional Role).
 */
global without sharing class OpportunityAssignmentManager {

    //TO DO:set the executeDML to true as a default
    public static Boolean executeDML=true;
    public static Boolean MassReorg; 


    public static void setExecuteDML(Boolean isExecute){
        executeDML=isExecute;
    }

    public static boolean getExecuteDML(){
        return executeDML;
    }

    public static void setMassReorg(Boolean IsMassReorg){
        MassReorg=IsMassReorg;
    }

    public static boolean getMassReorg(){
        return MassReorg;
    }

    public static Map<Id, Opportunity> oppOwners {get; set;}

    private OpportunityAssignmentManager (){

    }
    /** 
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified:  Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 20 August 2014 
     *@Last Modified: 23 May 2016
     *@Description: It will get Territory Team members of territory2 object of Account and assign
     *          the opportunity to the proper sales rep
     * Added logic to genrate map of opportunity and the owners and execute the DML operation based on the executeDML flag
     * Attask - 518008 - Added logic for the mass opty reorg
     * Changed logic to have multiple users per functional role 
     * Attask:1211182 and 1362981 - Changed Opportunity assignment based on user territory association role in territory (and not on the User Default Functional Role).
     */
    webservice static void assignOpportunitiesByTerritoryTeamRoles(List<id> optyIdList){

        Logger.push('assignOpportunitiesByTerritoryTeamRoles','OpportunityAssignmentManager');

        Map<id,id> optyToAccountMap=new Map<id,id>();
        List<Account> accListToPass=new List<Account>();
        List<Opportunity> optyListToupdate=new List<Opportunity>();
        List<Opportunity> optyObjList=new List<Opportunity>();
        Map<id,Map<string,List<id>>> territoryTeamMembersMap=new Map<id,Map<string,List<id>>>();

        //Custom labels
        String SalesMaintenanceRep=System.Label.FunRole_SalesMaintenanceRep;
        String InsideSalesRep=System.Label.FunRol_InsideSalesRep;
        String NationalAccountSalesSpecialist=System.Label.FunRole_NationalAccountSalesSpecialist;
        String SalesRepPrimary=System.Label.FunRole_SalesRepPrimary;
        String SalesSpecialist=System.Label.FunRole_SalesSpecialist;
        String Distributor=System.Label.FunRole_Distributort;
        String SalesManager=System.Label.FunRole_SalesManager;
        
        Set<id> userIds;

        Map<string,List<id>> functionalroleToIdMap=new Map<string,List<id>>();

        //fetch general setting instance
        General_Settings__c settings= General_Settings__c.getInstance();

        //Get user to set default opportunity owner Research Team Owner by custom setting
        //We will query using alias as the name has issues with different locales
        List<User> usrObjByName=new List<User>();
        usrObjByName=[select id,name from User where alias =:settings.Research_Team_Owner__c];

        optyObjList=[SELECT id,name,locked__C,ownerid,primary_purpose__c,AccountId,sms__c,
                     closedate,Account.Siebel_Account_Id__c,Primary_Contact__c,Batch_Evaluate__c,
                     Territory_Team_Role__c
                     FROM Opportunity 
                     where Id in:optyIdList and Locked__c=false and isClosed=false];

        System.debug('OpptyList for re-org:'+optyObjList);
        //For loop to add opportunity id and associated accountid in map
        for(Opportunity optyObj:optyObjList){

            optyToAccountMap.put(optyObj.id,optyObj.AccountId);

        }

        //Get all account associated with opportunities
        accListToPass=[select id,Salesforce_Territory_Id__c from Account where id in:optyToAccountMap.values()];

        //Get Territory2 team members from utility class
        territoryTeamMembersMap=TerritoryTeamUtility.getTerritoryTeamMembers(accListToPass);
        System.Debug('TerritoryTeamMembers:'+territoryTeamMembersMap);

        for(Opportunity optyObjToAssign:optyObjList){

            if(!optyObjToAssign.Locked__c){

                if(territoryTeamMembersMap.get(optyObjToAssign.accountid)!=null){
                    functionalroleToIdMap=new Map<string,List<id>>();

                    System.Debug('Oppty id for assignment:'+optyObjToAssign.Id);
                    functionalroleToIdMap=territoryTeamMembersMap.get(optyObjToAssign.accountid);
                    
                    userIds=new Set<id>();
                    
                    
                    if(optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.get(optyObjToAssign.Territory_Team_Role__c)!=null){
                   
                        userIds.addAll(functionalroleToIdMap.get(optyObjToAssign.Territory_Team_Role__c));
                    }
                    
                    //If Opportunity is 'SMS'

                    if(optyObjToAssign.SMS__c && functionalroleToIdMap.containsKey(SalesMaintenanceRep)) {

                        optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesMaintenanceRep)[0];

                    }
                    else if(optyObjToAssign.SMS__c && functionalroleToIdMap.containsKey(NationalAccountSalesSpecialist)){

                        optyObjToAssign.ownerid=functionalroleToIdMap.get(NationalAccountSalesSpecialist)[0];
                    }
                    else if(optyObjToAssign.SMS__c && (optyObjToAssign.batch_evaluate__c == true || MassReorg == true)){

                        if(optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(optyObjToAssign.Territory_Team_Role__c) && !userIds.contains(optyObjToAssign.ownerId)){

                            optyObjToAssign.ownerid=functionalroleToIdMap.get(optyObjToAssign.Territory_Team_Role__c)[0];
                        }
                      
                    }

                    //If Opportunity is 'Non SMS'

                    else if(!optyObjToAssign.SMS__c && (optyObjToAssign.batch_evaluate__c == true || MassReorg == true)){
                        
                        if(optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(optyObjToAssign.Territory_Team_Role__c) ){

                            if(!userIds.contains(optyObjToAssign.ownerId)){
                                
                                 optyObjToAssign.ownerid=functionalroleToIdMap.get(optyObjToAssign.Territory_Team_Role__c)[0];
                                
                            }

                        }
                        
                        else if(!optyObjToAssign.SMS__c && optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(InsideSalesRep)){                        

                        	optyObjToAssign.ownerid=functionalroleToIdMap.get(InsideSalesRep)[0];

	                    }
	
	                    else if(!optyObjToAssign.SMS__c && optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(NationalAccountSalesSpecialist)){
	
	                        optyObjToAssign.ownerid=functionalroleToIdMap.get(NationalAccountSalesSpecialist)[0];
	                    }
	                    else
	                    {
	

	                        if(optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(SalesRepPrimary)){
	
	                            optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesRepPrimary)[0];
	                        }
	                        else if(optyObjToAssign.Territory_Team_Role__c!=null &&functionalroleToIdMap.containsKey(Distributor)){
	
	                            optyObjToAssign.ownerid=functionalroleToIdMap.get(Distributor)[0];
	                        }
	                        else if(optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(SalesManager)){
	
	                            optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesManager)[0];
	                        }
	                        else if(optyObjToAssign.Territory_Team_Role__c!=null && functionalroleToIdMap.containsKey(SalesSpecialist)){
	
	                            optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesSpecialist)[0];
	                        }
	
	                        else
	                        {
	                            //Assign new User from ganeral setting's Research_Team_Owner__c field
	                            if(optyObjToAssign.Territory_Team_Role__c!=null){
		                            optyObjToAssign.ownerid=usrObjByName[0].id;
	                            }
	
	                        }
	
	                    }
                        
                        //TODO: Need to handle the scenario where the Territory Team Role is null (FG to confirm logic)

                    }

                    else if(!optyObjToAssign.SMS__c && functionalroleToIdMap.containsKey(InsideSalesRep)){                        

                        optyObjToAssign.ownerid=functionalroleToIdMap.get(InsideSalesRep)[0];

                    }

                    else if(!optyObjToAssign.SMS__c && functionalroleToIdMap.containsKey(NationalAccountSalesSpecialist)){

                        optyObjToAssign.ownerid=functionalroleToIdMap.get(NationalAccountSalesSpecialist)[0];
                    }
                    else
                    {


                        if(functionalroleToIdMap.containsKey(SalesRepPrimary)){

                            optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesRepPrimary)[0];
                        }
                        else if(functionalroleToIdMap.containsKey(Distributor)){

                            optyObjToAssign.ownerid=functionalroleToIdMap.get(Distributor)[0];
                        }
                        else if(functionalroleToIdMap.containsKey(SalesManager)){

                            optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesManager)[0];
                        }
                        else if(functionalroleToIdMap.containsKey(SalesSpecialist)){

                            optyObjToAssign.ownerid=functionalroleToIdMap.get(SalesSpecialist)[0];
                        }

                        else
                        {
                            //Assign new User from ganeral setting's Research_Team_Owner__c field
                            optyObjToAssign.ownerid=usrObjByName[0].id;
                            System.Debug('Opptyid with no matching role:'+optyObjToAssign.Id);

                        }

                    }
                    
                }
                //If there is no user in Territory2 Team
                else
                {
                    //Assign new User from ganeral setting's Research_Team_Owner__c field
                    optyObjToAssign.ownerid=usrObjByName[0].id;
                    System.Debug('Opptyid that has no territory:'+optyObjToAssign.Id);

                }



                //Set Batch_Evaluate__c to false to avoid repetitive assignment
                //if(optyObjToAssign.Batch_Evaluate__c==true){

                    optyObjToAssign.Batch_Evaluate__c=false;
                //}
                
                

                optyListToupdate.add(optyObjToAssign);
               
                
            }
        }

        try{
            if(!executeDML){
                oppOwners = new Map<Id, Opportunity>();
                //TO DO:need to check if the key already exists and not add to the map
                for( Opportunity opp : optyListToupdate){
                    if(!oppOwners.containsKey(opp.Id)){
                        oppOwners.put(opp.Id, opp);
                    }
                }
            }

            //TO DO: change the !executeDML to executeDML after defaulting the value to true
            if(optyListToupdate!=null  && !optyListToupdate.isEmpty() && executeDML){
                
                //Update Opportunity list
                update optyListToupdate;

            }
        }

        catch(Exception ex){

            Logger.debugException(ex);

        }//catch
        Logger.pop();

    }


}