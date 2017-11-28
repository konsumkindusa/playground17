/**
 *@author Original: Haigang Wu - Mathworks,
 *@date Original: 26 Feb 2016
 *@description This is controller for CreateNewQuoteFromContact Page
 *             
 */
public with sharing class ContactNewQuoteCommerceController{

   //Initialize variables
    public String contactId;
    public boolean isError;
    public String query;
    QuoteIntegrationSettings__c settings ;
    public Integer counter;


    //Constructor
    public ContactNewQuoteCommerceController(ApexPages.StandardController controller){}

   public PageReference getContactRecord(){

        Logger.push('getContactRecord','ContactNewQuoteCommerceController');

        try{
            //get contact id from url
            contactId=System.currentPageReference().getParameters().get('id');

            //Checking for null and  blank value
            if(contactId!=null && contactId!=''){

                //Query to get contact object to validate fields
                Contact conToValidate=[SELECT First_Name_Latin__c,FirstName,Last_Name_Latin__c,LastName,
                                       CDS_Contact_Id__c,accountid
                                       FROM Contact
                                       WHERE id =:contactId];

                //Query to get contact's Account object to validate fields
                Account accToValidate=[SELECT CDS_Account_Id__c,name,BillingCity,Account_City_Latin__c,
                                       Account_Name_Latin__c,Is_Individual_Account__c
                                       FROM Account
                                       WHERE id =:conToValidate.accountid];
                //set isError to false 
                isError=false;

                //set counter to 0
                counter=0;

                if(conToValidate!=null){

                    isError=EnforceValidationsUtility.isIndividualAccount(accToValidate);

                    if(isError==false){
                        
                        //Check for validations
                        if(EnforceValidationsUtility.hasCDSAccountId(accToValidate)){counter++;}
                        if(EnforceValidationsUtility.hasCDSContactId(conToValidate)){counter++;}
                        if(EnforceValidationsUtility.hasAccountNameLatin(accToValidate)){counter++;} 
                        if(EnforceValidationsUtility.hasAccountCityLatin(accToValidate)){counter++;}
                        if(EnforceValidationsUtility.hasFirstNameLatin(conToValidate)){counter++;}
                        if(EnforceValidationsUtility.hasLastNameLatin(conToValidate)){counter++;}

                    }//if
                    else
                    {
                        counter++;
                    }//else
                }

                //Redirect to new quote page if counter is  0
                if(counter==0){
                
                    //Fetching date from General custom setting
                    settings = QuoteIntegrationSettings__c.getInstance();

                    PageReference quotePage= new PageReference(settings.CommerceQuoteURL__c+'create?contactId='+conToValidate.CDS_Contact_Id__c);
                    quotePage.setRedirect(true);
                    return quotePage;

                }//if
                
                
               Logger.debug('Contact Id is:'+contactId);


            }//if
            
            
            return null;

        }//try

        catch(Exception ex){
            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException('Exception Occured for Contact Id :'+contactId);
            Logger.pop();
            return null;

        }//catch

    }
}