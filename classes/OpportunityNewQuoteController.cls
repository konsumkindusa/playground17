/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 17 July 2014, Last Modified:   22 July 2014
 *@description This is controller for OpportunityNewQuote Page
 *             
 */
public with sharing class OpportunityNewQuoteController {

    //Initialize variables
    public String optyId;
    public List<OpportunityContactRole> relatedContactsList{get; set;}
    public List<OpportunityLineItem> opportunityLineItemList{get; set;}
    public String selContactid {get; set;}
    public String prevselContactid {get; set;}
    
    public boolean isError;
    public String query;
    public string productCodes='';
    public string productQuantities='';
    public String Url{get; set;}
    public Integer counter;
    QuoteIntegrationSettings__c settings ;
    
    public String selectContactMessage=System.Label.OpportunityNewQuoteSelectContactMessage;

    //Constructor
    public OpportunityNewQuoteController(ApexPages.StandardController controller)
    {
        optyId = ((Opportunity)controller.getRecord()).Id;
    
    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 July 2014
     *@Description: . It will query the Opportunity record by id passed in url
     */ 
    public void getContactsOfOpportunityRecord(){

        Logger.push('getContactsOfOpportunityRecord','OpportunityNewQuoteController');

        try{

            
            //Checking for null and  blank value
            if(optyId!=null && optyId!=''){

                relatedContactsList = [SELECT Id,contact.Siebel_Contact_Id__c,contact.name,contact.id,isPrimary FROM OpportunityContactRole where  opportunity.id=:optyId];

                 
                //get primary contact id  
                for(OpportunityContactRole optyContact:relatedContactsList){

                    if(optyContact.isPrimary){

                        selContactid=optyContact.contact.id;
                        break;

                    }


                }
                //Query for getting opportunty products to show on the page
                query = 'SELECT ';

                for(Schema.FieldSetMember f : this.getOptyProductFields()) {

                    query += f.getFieldPath() + ', '; 

                }   
                query+= 'FROM OpportunityLineItem where Product2.Quotable__c=true and OpportunityId = '+'\'' +optyId + '\'';
                query=query.replace(', FROM', ' FROM');

                opportunityLineItemList=Database.query(query);

                System.debug('opportunityLineItemList'+opportunityLineItemList);


                //making the product code and quantity string with '-'
                if(opportunityLineItemList!=null && !opportunityLineItemList.isEmpty())
                {
                    for(Integer i=0;i < opportunityLineItemList.size(); i++){

                        if(opportunityLineItemList.size()==1){

                            productCodes=productCodes+opportunityLineItemList[i].ProductCode;
                            productQuantities=productQuantities+opportunityLineItemList[i].Quantity.IntValue();
                        }
                        else
                        {
                            if(i!=opportunityLineItemList.size()-1){
                                productCodes=productCodes+opportunityLineItemList[i].ProductCode+'-';
                                productQuantities=productQuantities+opportunityLineItemList[i].Quantity.IntValue()+'-';
                            }
                            else
                            {
                                productCodes=productCodes+opportunityLineItemList[i].ProductCode;
                                productQuantities=productQuantities+opportunityLineItemList[i].Quantity.IntValue();
                            }
                        }
                    }

                }

            }

        Logger.debug('Opportunity Id is:'+optyId);
            

        }
        catch(Exception ex){
            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException('Exception Occured for Opportunity Id :'+optyId);
            Logger.debugException(ex);

        }
        Logger.pop();
    }

    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 July 2014
     *@Description: It will validate the fields of opportunity account and contact
     */ 
    public PageReference validateFields()
    {
        if(selContactid==null || selContactid=='') {

            UtilityHelper.addErrorMessage(selectContactMessage);
            return null;

        }
        else{

            //prevselContactid =selContactid;

            Contact conToValidate=[SELECT First_Name_Latin__c,FirstName,Last_Name_Latin__c,LastName,
                                   Siebel_Contact_Id__c,accountid
                                   FROM Contact
                                   WHERE id =:selContactid];
                                   
            Account accToValidate=[SELECT Siebel_Account_Id__c,name,BillingCity,Account_City_Latin__c,
                                   Account_Name_Latin__c,Is_Individual_Account__c
                                   FROM Account
                                   WHERE id =:conToValidate.accountid];
           
            counter=0;

            if(conToValidate!=null){
                
                isError=EnforceValidationsUtility.isIndividualAccount(accToValidate);
                
                if(!isError){
                
                   if(EnforceValidationsUtility.hasSiebelAccountId(accToValidate)){counter++;}
                   if(EnforceValidationsUtility.hasSiebelContactId(conToValidate)){counter++;}
                   if(EnforceValidationsUtility.hasAccountNameLatin(accToValidate)){counter++;} 
                   if(EnforceValidationsUtility.hasAccountCityLatin(accToValidate)){counter++;}
                   if(EnforceValidationsUtility.hasFirstNameLatin(conToValidate)){counter++;}
                   if(EnforceValidationsUtility.hasLastNameLatin(conToValidate)){counter++;}
                    
                }
                else
                {
                    counter++;
                }
            }

            if(counter==0){
            
                PageReference quotePage;
                
                //Fetching date from General custom setting
                settings = QuoteIntegrationSettings__c.getInstance();
            
                if(opportunityLineItemList==null || opportunityLineItemList.isEmpty() || opportunityLineItemList.isEmpty()){
                    quotePage= new PageReference(settings.Mathwork_Quote_Url__c+'&ContactId='+conToValidate.Siebel_Contact_Id__c+'&OpportunityId='+optyId);
                    quotePage.setRedirect(true);

                }
                else{

                    quotePage= new PageReference(settings.Mathwork_Quote_Url__c+'&ContactId='+conToValidate.Siebel_Contact_Id__c+'&OpportunityId='+optyId+'&Prods='+productCodes+'&Qtys='+productQuantities);
                    quotePage.setRedirect(true);

                }
                return quotePage;

            }

            return null;
        }


    }



    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 July 2014
     *@Description: It will get  the selected Contact from list 
     */ 
    public void selectContact()
    {
         ApexPages.getMessages().clear();
        selContactid = System.currentPagereference().getParameters().get('contactId');
       

    }


    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 Julye 2014
     *@Description: It will get the fields of Opportunity product field set
     */ 
    public List<Schema.FieldSetMember> getOptyProductFields() {
        return SObjectType.OpportunityLineItem.FieldSets.OpportunityProduct.getFields();
    }


}