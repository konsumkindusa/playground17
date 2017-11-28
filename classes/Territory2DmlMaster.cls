/**
 *author Original: Faina Gorelik 
 *date Original: 16 August 2016
 *description This trigger is used to handle different trigger actions for Territory2 when custom settings Territory Setting set to Master - territory lookup field Master_Territory_id__c 
 */

global class Territory2DmlMaster implements Database.Batchable <sObject> {

    //Instantiate SiebelTerritoryIdToTerritory2
  Map<String,Territory2>TerritoryIdToTerritory2=new map<String,Territory2>();

  General_Settings__c settings;

  //AccountList To Update fields
  List<Account> accListToUpdate=new List<Account>();

  global Territory2DmlMaster(Map<String,Territory2> STIToTerritory2Map) {

    TerritoryIdToTerritory2 = STIToTerritory2Map;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {

    return DataBase.getQueryLocator([select id,Siebel_Territory_ID__c,Global_Region__c,Territory_Name__c,
                                     Region__c,Office_Group__c,Office__c,Office_Channel__c,
                                     Territory_Industry__c,Territory_Sales_Group__c,Territory_Sales_Team_Type__c,
                                     Account_Territory_Sector__c,Account_Territory_Type__c,Master_Territory_ID__c
                                     from Account 
                                     where is_individual_account__c = false and Master_Territory_ID__c != null and Master_Territory_ID__c in :TerritoryIdToTerritory2.keyset()]);
  }
  global void execute(Database.BatchableContext BC,List<Account> accObjListToSync) {

    for(Account accToUpdate:accObjListToSync){

      Territory2 territoryObj;

      if(TerritoryIdToTerritory2.get(accToUpdate.Master_Territory_ID__c)!=null){

        territoryObj=TerritoryIdToTerritory2.get(accToUpdate.Master_Territory_ID__c);

        //Populate fields of Territory2 to Account
        accToUpdate.Territory_Name__c=territoryObj.name;
        accToUpdate.Global_Region__c=territoryObj.Global_Region__c;
        accToUpdate.Region__c=territoryObj.Region__c;
        accToUpdate.Office_Group__c=territoryObj.Office_Group__c;
        accToUpdate.Office__c=territoryObj.Office__c;
        accToUpdate.Office_Channel__c=territoryObj.Office_Channel__c;
        accToUpdate.Territory_Industry__c=territoryObj.Territory_Industry__c;
        accToUpdate.Territory_Sales_Group__c=territoryObj.Territory_Sales_Group__c;
        accToUpdate.Territory_Sales_Team_Type__c=territoryObj.Territory_Sales_Team_Type__c;
        accToUpdate.Account_Territory_Sector__c=territoryObj.Territory_Sector__c;
        accToUpdate.Account_Territory_Type__c= territoryObj.Territory2Type.MasterLabel;
        accToUpdate.Siebel_Territory_id__c = territoryObj.Siebel_Territory_id__c;

        //add the account to update
        accListToUpdate.add(accToUpdate);
        Logger.debug(accToUpdate.Id);

      }//if

    }//for

    if(!accListToUpdate.isEmpty())
    {

      try{
        Update accListToUpdate;
      }
      catch (System.DmlException e) {
        for (Integer i = 0; i < e.getNumDml(); i++) {
          //capture Dml  Process exception 
          Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
        }
      }
    }//if

  }
  global void finish(Database.BatchableContext BC) {
    //Send an email to the User after your batch completes
    String emailSubject = System.Label.Territory2Dml_batch_apex_message_subject;
    String emailBody = System.Label.Territory2Dml_batch_apex_message_emailbody;
    settings=General_Settings__c.getInstance();
    List<String> emailAddressList = settings.Emailaddress_Territory2Dml__c.split(',');
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(emailAddressList);
    mail.setSubject(emailSubject);
    mail.setPlainTextBody(emailBody);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
}