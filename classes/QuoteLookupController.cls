/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 17 Feb 2015, Last Modified: 17 Feb 2015
 *@description This is controller for QuoteLookup Page
 */
public with sharing class QuoteLookupController {

    public String quoteId{get; set;}
    public String quoteJsonString;
    public QuoteBean quoteObjToShow{get; set;} 
    public List<QuoteBean> quoteBeanList{get; set;} 
    public boolean showDetails{get; set;} 
    public boolean isError{get; set;} 
    public boolean showLookupInput{get; set;} 
    public Map<String,Opportunity> mapOpportunity{get; set;} 
    public Map<String,Contact> mapContact{get; set;} 
    public Map<String,Account> mapAccount{get; set;} 
    
    String quoteNotFoundErrorMessage=System.Label.QuoteNotFoundErrorMessage;
    String quoteIdErrorMessage=System.Label.QuoteIdErrorMessage;
    
    QuoteIntegrationSettings__c settings ;
    String url;
    IntegrationUtilityHelper intUtilityHelper;
    public String gQOquoteId;

    public QuoteLookupController(ApexPages.StandardController controller)
    {  
        //hide Quote Detail Section on Page Load
        showDetails=false;

        //fetch general setting instance
        settings = QuoteIntegrationSettings__c.getInstance();

        //Getting url from General setting
        url = settings.GQOQuoteBaseURL__c ;
        //fetch Integration setting instance

        intUtilityHelper = new IntegrationUtilityHelper();
        
        quoteBeanList=new List<QuoteBean>();
        
         showLookupInput=true; 
    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Date Original: 17 Feb 2015,
     *@Last Modified: 17 Feb 2015
     *@Description:It will show all the trials related to the Opportunity record.
     */ 
    public PageReference viewQuote(){

        Logger.push('showTrialsRelatedToOpportunity','ViewTrialController');

        try{
        
                //get quoteId from page parameter
            gQOquoteId= ApexPages.currentPage().getParameters().get('QuoteId');
            
            //Check to show QuoteDetails section on page
            if(gQOquoteId != null && gQOquoteId .trim().length()!=0 && ApexPages.currentPage().getParameters().get('showDetails')=='true'){
            
                isError=false;

                //Get contact jason string from endpoint Url
                quoteJsonString=getJasonString(url+'/'+gQOquoteId );
                
                //Check for proper jason string
                if (quoteJsonString!='NotFound'){

                    //Get jason string into searilized object
                    quoteObjToShow=QuoteBean.parse(quoteJsonString);
                    quoteBeanList.add(quoteObjToShow);
                    showDetails=true; 
                     
                    //Build maps for showing drilldowns
                    QuoteUtilityHelper.BuildDrilldownMaps(quoteBeanList);
                    
                    //Get Maps from QuoteUtilityHelper
                    mapOpportunity=QuoteUtilityHelper.getOpportunityMap();
                    mapContact=QuoteUtilityHelper.getContactMap();
                    mapAccount=QuoteUtilityHelper.getAccountMap();
                    
                }

                else{

                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,quoteNotFoundErrorMessage));
                    isError=true;
                    return null;

                }
            }
            
           
           
        }       
        catch(Exception ex){

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex.getMessage());
            Logger.pop();
            return null;

        }
        return null;

    }
    
    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Date Original: 17 Feb 2015,
     *@Last Modified: 17 Feb 2015
     *@Description:It get Response jason string by webservice call from endpoint provided
     */ 
    public String getJasonString(String endpointUrl){

        Logger.push('getJasonString','QuoteLookupController');


        try{

            Http httpProtocol = new Http();

            // Create HTTP request 
            HttpRequest request = new HttpRequest();

            IntegrationUtilityHelper intUtilityHelper = new IntegrationUtilityHelper();

            //set ClientCertificate if this code is not running in a test
            //this keeps the tests environment agnostic and the mock callouts do not need a certificate
            if(!Test.isRunningTest()){
                request.setClientCertificateName(intUtilityHelper.getCACertIntegration());
            }

            //set Organization Id in request header
            request.setHeader('OrganizationID', UserInfo.getOrganizationId());

            // Set the endpoint URL.
            request.setEndPoint(endpointUrl);

            // Set Business Service Token
            request.setHeader('X_MW_WS_securityToken',intUtilityHelper.getBusinessServiceToken());

            //set the caller Id in the request Header
            request.setHeader('X_MW_WS_callerId',intUtilityHelper.getCallerId());

            // Set the HTTP verb to GET.
            request.setMethod('GET');

            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);


            if(Response.getStatusCode()==200){

                //Get Jason String 
                String jasonData = response.getBody();    

                return jasonData.substring(1, (jasonData.length())-1);

            }
            else
            {
                return 'NotFound';
            }

        }
        catch(Exception ex){

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex);
            Logger.pop();
            return null;
        }

    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Date Original: 19 Feb 2015,
     *@Last Modified: 19 Feb 2015
     *@Description:It will make showDetails boolean variable to false
     */ 
    public PageReference hideQuoteDetailSection(){

        showDetails=false;
        isError=false;
        return null; 

    }
    
}