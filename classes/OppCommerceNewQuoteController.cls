/**
 *@Author Original: Shweta Shanbhag - Mathworks
 *@Date Original: 2/25/2016
 *@Last modified: 9/13/2017 Dennis Atwood 1946380
 *@Description This is controller for OpportunityCommerceCreateQuote Page          
 */

public class OppCommerceNewQuoteController {

     //Initialize variables
    public String optyId;
    public List<OpportunityContactRole> relatedContactsList{get; set;}   
    public String selContactid {get; set;} 
    public boolean isError;
    public Integer counter;
    QuoteIntegrationSettings__c settings ;
    
    public String selectContactMessage=System.Label.OpportunityNewQuoteSelectContactMessage;

    //Constructor
    public OppCommerceNewQuoteController(ApexPages.StandardController controller)
    {
        optyId = ((Opportunity)controller.getRecord()).Id;
    
    }

    /*
     *@Author Original:  Shweta Shanbhag - Mathworks  
     *@Date Original: 2/25/2016
     *@Last Modified: 2/25/2016
     *@Description: Query Opportunity record by id passed in url
     */ 
    public void getContactsOfOpportunityRecord(){

        Logger.push('getContactsOfOpportunityRecord','OpportunityCommerceCreateQuoteController');

        try{      
            
            if(optyId!=null && optyId!=''){

                relatedContactsList = [SELECT Id,contact.CDS_Contact_Id__c,contact.name,contact.id,isPrimary FROM OpportunityContactRole where  opportunity.id=:optyId];
          
                //get primary contact id  
                for(OpportunityContactRole optyContact:relatedContactsList){
                    if(optyContact.isPrimary){
                        selContactid=optyContact.contact.id;
                        break;
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
     *@Author Original:  Shweta Shanbhag - Mathworks 
     *@Last Modified: Shweta Shanbhag - Mathworks 
     *@Date Original: 2/25/2016 
     *@Last Modified: 2/25/2016
     *@Description: Validation of the account and contact fields associated to the Opportunity
     */ 
    public PageReference validateFields()
    {
        if(selContactid==null || selContactid=='') {

            UtilityHelper.addErrorMessage(selectContactMessage);
            return null;

        }
        else{

            Contact conToValidate=[SELECT First_Name_Latin__c,FirstName,Last_Name_Latin__c,LastName,CDS_Contact_Id__c,accountid FROM Contact WHERE id =:selContactid];
                             
            Account accToValidate=[SELECT CDS_Account_Id__c,name,BillingCity,Account_City_Latin__c, Account_Name_Latin__c,Is_Individual_Account__c FROM Account WHERE id =:conToValidate.accountid];
                                     
            counter=0;

            if(conToValidate!=null){
                
                isError=EnforceValidationsUtility.isIndividualAccount(accToValidate);
                
                if(!isError){
                
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
            
                PageReference quotePage;
                
                //Fetching date from General custom setting
                settings = QuoteIntegrationSettings__c.getInstance();
       			//DMA 1946380 Add Master License ID to url args
                Opportunity opp = [SELECT Master_License_Id__c from Opportunity where ID = :optyId ];
                String masterLicenseArg = '';
                if(opp.Master_License_Id__c != null) masterLicenseArg = '&masterLicenseId='+opp.Master_License_Id__c;
                quotePage= new PageReference(settings.CommerceQuoteURL__c+'create?contactId='+conToValidate.CDS_Contact_Id__c+'&opportunityId='+optyId+masterLicenseArg);
                quotePage.setRedirect(true);

                return quotePage;

            }

            return null;
        }


    }

   /**
     *
     *@Author Original:  Shweta Shanbhag - Mathworks 
     *@Last Modified: Shweta Shanbhag - Mathworks 
     *@Date Original: 2/25/2016 
     *@Last Modified: 2/25/2016
     *@Description: Get selected contact from the list
     */ 

 
    public void selectContact()
    {
         ApexPages.getMessages().clear();
         selContactid = System.currentPagereference().getParameters().get('contactId');
    }
}