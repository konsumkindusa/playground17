/**
 *@author Original: Marc Ouimet - Mathworks,
 *@date Original: 03 Mar 2016
 *@description This is controller for ContactViewQuotesCommerce Page
 *             
 */
public class ContactViewQuotesCommerceController {

   //Initialize variables
    public String contactId;
    public boolean isError;
    public String query;
    QuoteIntegrationSettings__c settings ;
    public Integer counter;


    //Constructor
    public ContactViewQuotesCommerceController(ApexPages.StandardController controller){}

   public PageReference getContactRecord(){

        Logger.push('getContactRecord','ContactViewQuotesCommerceController');

        try{
            //get contact id from url
            contactId=System.currentPageReference().getParameters().get('id');

            //Checking for null and  blank value
            if(contactId!=null && contactId!=''){

                //Query to get contact object to validate fields
                Contact conToValidate=[SELECT CDS_Contact_Id__c
                                       FROM Contact
                                       WHERE id =:contactId];
                //set isError to false 
                isError=false;

                //set counter to 0
                counter=0;

                if(conToValidate!=null){
                    //Check for validations
                    //if(EnforceValidationsUtility.hasCDSContactId(conToValidate)){counter++;}
			
			        if(conToValidate.CDS_Contact_Id__c == '' || conToValidate.CDS_Contact_Id__c == null){
			            UtilityHelper.addErrorMessage(System.Label.Commerce_Contact_No_CDS_ID_Error);
			            isError=true;
			            counter++;
			        }
                }

                //Redirect to new quote page if counter is  0
                if(counter==0){
                
                    //Fetching date from General custom setting
                    settings = QuoteIntegrationSettings__c.getInstance();

                    PageReference quotePage= new PageReference(settings.CommerceQuoteURL__c+'list?q='+conToValidate.CDS_Contact_Id__c);
                    quotePage.setRedirect(true);
                    return quotePage;

                }//if
                
                
               Logger.debug('Contact Id is:'+contactId);


            }//if
            
            
            Logger.pop();
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