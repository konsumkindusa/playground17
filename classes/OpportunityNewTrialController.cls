/**
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks,
 *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
 *@date Original: 26 Sept 2014, Last Modified: 25 Nov 2014
 *@description This is controller for OpportunityNewQuote Page
 *             
 */
public class OpportunityNewTrialController {

    //Initialize variables
    public String optyId;
    public List<OpportunityContactRole> relatedContactsList{get; set;}
    public List<OpportunityLineItem> opportunityLineItemList{get; set;}
    public String selContactid {get; set;}
    public String prevselContactid {get; set;}
    
    public boolean isError;
    public String query;
    public string productCodes='';
    public String Url{get; set;}
    public Integer counter;
    TrialsIntegrationSetting__c settings ;

    //Constructor
    public OpportunityNewTrialController(ApexPages.StandardController controller)
        {
            optyId = ((Opportunity)controller.getRecord()).Id;
        
        }

    /*
     *@author Original: Divya Gawade - Cloud Sherpas/Mathworks,
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@date Original: 26 Sept 2014, Last Modified: 26 Sept 2014
     *@Description: . It will query the Opportunity record by id passed in url
     */ 
    public void getContactsOfOpportunityRecord(){

        Logger.push('getContactsOfOpportunityRecord','OpportunityNewTrialController ');

        try{
        
            //Checking for null and  blank value
            if(optyId!=null && optyId!=''){

                relatedContactsList = [SELECT Id,contact.CDS_Contact_Id__c,contact.name,contact.id,isPrimary FROM OpportunityContactRole where  opportunity.id=:optyId];

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
                query+= 'FROM OpportunityLineItem where Product2.Trialable__c=true and OpportunityId = '+'\'' +optyId + '\'';
                query=query.replace(', FROM', ' FROM');

                opportunityLineItemList=Database.query(query);

                System.debug('************************opportunityLineItemList'+opportunityLineItemList);


                //making the product code string with '-'
                if(opportunityLineItemList!=null && !opportunityLineItemList.isEmpty())
                {
                    for(Integer i=0;i < opportunityLineItemList.size(); i++){

                        if(opportunityLineItemList.size()==1){

                            productCodes=productCodes+opportunityLineItemList[i].ProductCode;
                        }
                        else
                        {
                            if(i!=opportunityLineItemList.size()-1){
                                productCodes=productCodes+opportunityLineItemList[i].ProductCode+',';
                            }
                            else
                            {
                                productCodes=productCodes+opportunityLineItemList[i].ProductCode;
                            }
                        }
                    }

                }

            }

        }
        catch(Exception ex){
            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex.getMessage()+'For Opportunity'+optyId);
        }
        Logger.pop();
    }

    /**
     *
     *@author Original: Divya Gawade - Cloud Sherpas/Mathworks,
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@date Original: 26 Sept 2014, Last Modified: 26 Sept 2014
     *@Description: It will validate the fields of opportunity account and contact
     */ 
    public PageReference validateFields()
    {
        if(selContactid==null || selContactid=='') {

            UtilityHelper.addErrorMessage(system.label.OppoNewTrialSelectContErr);
            return null;

        }
        else{

            //prevselContactid =selContactid;

            Contact conToValidate=[SELECT First_Name_Latin__c,FirstName,Last_Name_Latin__c,LastName,
                                   CDS_Contact_Id__c,accountid
                                   FROM Contact
                                   WHERE id =:selContactid];
                                   
            System.debug('************conToValidate*****'+ conToValidate);
            System.debug('*********conToValidate!=null****'+conToValidate!=null);
                                   
            Account accToValidate=[SELECT CDS_Account_Id__c,name,BillingCity,Account_City_Latin__c,
                                   Account_Name_Latin__c,Is_Individual_Account__c
                                   FROM Account
                                   WHERE id =:conToValidate.accountid];
           
            counter=0;

            if(conToValidate!=null){
                
                isError=EnforceValidationsUtility.isindividualaccountOnTrial(accToValidate);
                
                System.debug('***isError****'+ isError);
                
                if(isError==false){
                
                   //if(EnforceValidationsUtility.hasSiebelAccountId(accToValidate)){counter++;}
                   //if(EnforceValidationsUtility.hasSiebelContactId(conToValidate)){counter++;}
                   if(EnforceValidationsUtility.hasCDSAccountId(accToValidate)){counter++;}
                   if(EnforceValidationsUtility.hasCDSContactId(conToValidate)){counter++;}
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
            
                PageReference trialPage;
                
                //Fetching date from General custom setting
                settings = TrialsIntegrationSetting__c.getInstance();
                system.debug('*****optyId***'+optyId);
                
                if(opportunityLineItemList==null || opportunityLineItemList.isEmpty() ){
                    //trialPage= new PageReference(settings.AUIUrl__c+conToValidate.Siebel_Contact_Id__c+'&opptyId='+optyId);
                    trialPage= new PageReference(settings.AUIUrl__c+conToValidate.CDS_Contact_Id__c+'&opptyId='+optyId);
                    trialPage.setRedirect(true);
                    system.debug('***trialPage if***'+trialPage);
                }
                else{

                   // trialPage= new PageReference(settings.AUIUrl__c+conToValidate.Siebel_Contact_Id__c+'&opptyId='+optyId+'&products='+productCodes);
                     trialPage= new PageReference(settings.AUIUrl__c+conToValidate.CDS_Contact_Id__c+'&opptyId='+optyId+'&products='+productCodes);
                    trialPage.setRedirect(true);
                    system.debug('***trialPage else***'+trialPage);
                }
                return trialPage;

            }

            return null;
        }


    }
    
    /**
     *
     *@author Original: Divya Gawade - Cloud Sherpas/Mathworks,
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@date Original: 26 Sept 2014, Last Modified: 26 Sept 2014
     *@Description: It will get the selected Contact from list 
     */ 
    public void selectContact()
    {
         ApexPages.getMessages().clear();
        selContactid = System.currentPagereference().getParameters().get('contactId');
        
    }
      /**
     *
     *@author Original: Divya Gawade - Cloud Sherpas/Mathworks,
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@date Original: 26 Sept 2014, Last Modified: 26 Sept 2014
     *@Description: It will get the fields of Opportunity product field set
     */ 
    public List<Schema.FieldSetMember> getOptyProductFields() {
        return SObjectType.OpportunityLineItem.FieldSets.OpportunityProduct.getFields();
    }


}