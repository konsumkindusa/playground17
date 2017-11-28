/**
 *@author Original: Haigang Wu - Mathworks,
 *@date Original: 03 Mar 2016
 *@description This is controller for AccountViewQuotesCommerce Page
 *             
 */
public class AccountViewQuotesCommerceController {

   //Initialize variables
    public String accountId;
    public boolean isError;
    public String query;
    QuoteIntegrationSettings__c settings ;
    public Integer counter;


    //Constructor
    public AccountViewQuotesCommerceController(ApexPages.StandardController controller){}

   public PageReference getContactRecord(){

        Logger.push('getContactRecord','AccountViewQuotesCommerceController');

        try{
            //get account id from url
            accountId=System.currentPageReference().getParameters().get('id');

            //Checking for null and  blank value
            if(accountId!=null && accountId!=''){

                //Query to get contact's Account object to validate fields
                Account accToValidate=[SELECT CDS_Account_Id__c,Is_Individual_Account__c
                                       FROM Account
                                       WHERE id =:accountId];
                //set isError to false 
                isError=false;

                //set counter to 0
                counter=0;

                if(accToValidate!=null){

                    //isError=EnforceValidationsUtility.isIndividualAccount(accToValidate);
			        if(accToValidate.Is_Individual_Account__c){
			            UtilityHelper.addErrorMessage(System.Label.Commerce_Account_Individual_Account_Error);
			            isError=true;
			        }

                    if(isError==false){
                        
                        //Check for validations
                        //if(EnforceValidationsUtility.hasCDSAccountId(accToValidate)){counter++;}
				        if(accToValidate.CDS_Account_Id__c == '' || accToValidate.CDS_Account_Id__c == null)
				        {
				            UtilityHelper.addErrorMessage(System.Label.Commerce_Account_No_CDS_ID_Error);
				            isError=true;
				            counter++;
				        }
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

                    PageReference quotePage= new PageReference(settings.CommerceQuoteURL__c+'list?q='+accToValidate.CDS_Account_Id__c);
                    quotePage.setRedirect(true);
                    return quotePage;

                }//if
                
                
               Logger.debug('Account Id is:'+accountId);


            }//if
            
            
            Logger.pop();
            return null;

        }//try

        catch(Exception ex){
            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException('Exception Occured for Account Id :'+accountId);
            Logger.pop();
            return null;

        }//catch

    }

}