/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 9 Oct 2014, Last Modified:9 Oct 2014
 *@description This is Utility class for ViewTrials Page
 */
public virtual  with sharing class TrialsUtilityClass {
    
    //Initialize variables
    public static SerializedTrials trials{get;set;}
    public static TrialPeopleBean trialPeoples{get;set;}
    public static TrialProductBean trialProducts{get;set;}
    public static list<SerializedTrials.EntitlementBean> trialList{get;set;}
    public static list<SerializedTrials.EntitlementBean> selectedTrialList{get;set;}
    public static list<TrialProductBean.entitlementReleaseBean> relatedProductList{get;set;}
    public static list<TrialPeopleBean.entitlementPersonBean> relatedPeopleList{get;set;}
    public static String selectedTrialId {get;set;}
    public static String securityToken;

    //For Contact Pagination purpose
    public static integer contactTotalRecs{get; set;}  
    public static integer contactlistSize{get;set;}
    public static Integer noOfPagesForContact {get; set;} 
    public static String currentPageNumberForContact {get; set;} 
     
    //fetch general setting instance
    static TrialsIntegrationSetting__c settings = TrialsIntegrationSetting__c.getInstance();
    //Getting url from General setting
    public  static string url = settings.TrialBaseUrl__c ;

    //getting trials Page size from General setting
    public  static string pageSize=settings.PageSizeForPaginationToShowTrials__c ;
    
    //getting contact related list Page size from General setting
    public  static string pageSizeForContact=settings.PaginationPageSizeContactRelatedList__c ;
    
    public  static IntegrationUtilityHelper intUtilityHelper = new IntegrationUtilityHelper();
    
    
    private TrialsUtilityClass(){
    	
    }
    
    
  
     /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 July 2014
     *@Description: It will get people related list of trials
     */ 
    public static list<TrialPeopleBean.entitlementPersonBean> showEntitlementPeopleRelatedToTrial(string selTrialid,String pageNo,String bToken)
    { 
        
        selectedTrialId=selTrialid;
        
        currentPageNumberForContact=pageNo;
        
        //Getting payload to send in ws request
        String payloadStringForPeople=getPayLoadForEntitlementPeople(pageNo,'id='+selTrialid,pageSizeForContact, bToken);

        //Getting response jason string from response XML string from WS
        String trialPeopleJsonString= sendWSRequest(payloadStringForPeople,'getEntitlementPeople');

        system.debug('trialPeopleJsonStringtrialPeopleJsonString'+trialPeopleJsonString);   
       
        //Check For String value
        if(trialPeopleJsonString != null && trialPeopleJsonString!='NotFound'){

             //Map Jason String into SerializedTrials class
             trialPeoples=TrialPeopleBean.parse(trialPeopleJsonString);
    
             //Getting EntitlementBean list from SerializedTrials class
             relatedPeopleList=trialPeoples.People.entitlementPersonBean;
             
             //Set number of records 
             contactTotalRecs=trialPeoples.summaryCount;
             
             noOfPagesForContact=0;
             
             //Calculate number of pages
             noOfPagesForContact = (Integer)Math.ceil((Double)contactTotalRecs/ (Double)Integer.valueOf(pageSizeForContact));
    

            }  
            
         return relatedPeopleList;
            
    }
    
    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 July 2014
     *@Description: It will get product related list of trials
     */ 
    public static list<TrialProductBean.entitlementReleaseBean> showEntitlementProductRelatedToTrial(string selTrialid,String bToken)
    { 
        
         String pageNo='1';
         
            //Getting payload to send in ws request
            String payloadStringForProducts=getPayLoadForEntitlementProduct(pageNo,selTrialid,bToken);

            //Getting response jason string from response XML string from WS
            String trialProductsJsonString=sendWSRequest(payloadStringForProducts,'getEntitlementProducts');
            
            system.debug('trialProductsJsonStringtrialProductsJsonString'+trialProductsJsonString); 

            //Check For String value
            if(trialProductsJsonString != null && trialProductsJsonString!='NotFound'){

                //Map Jason String into SerializedTrials class
                trialProducts=TrialProductBean.parse(trialProductsJsonString);

                //Getting EntitlementBean list from SerializedTrials class
                relatedProductList=trialProducts.entitlementReleaseBean;
                
            } 
            
         return relatedProductList;
            
    }
    
    
    
    
    
    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method to get payload for WS call
     * @param: String
     */
    public static String getPayLoadToSendForTrials(String PageNumber,String queryTagInputString,String bToken){

        Logger.push('getPayLoadToSendForTrials','TrialsUtilityClass');
        
        System.debug(securityToken+'securityTokensecurityTokensecurityToken');

        String xmlRequest ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.intactws.internal.mathworks.com">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<ser:getEntitlements>'+
                '<request>'+
                '<caller_id>SFDC</caller_id>'+
                '<content><![CDATA[<?xml version="1.0" encoding="UTF-8"?>'+
                '<QueryOptions>'+
                '<limitResults>false</limitResults>'+
                '<limitQuantity></limitQuantity>'+
                '<pageSize>'+pageSize+'</pageSize>'+
                '<pageNumber>'+PageNumber+'</pageNumber><options></options>'+
                '</QueryOptions>'+
                ']]></content>'+
                '<locale>en_US</locale>'+
                //'<query>id = 1928338</query>'+
                '<query>'+queryTagInputString+'</query>'+
                '<returnData>ENTITLEMENT,RELEASEONLY</returnData>'+
                '<security_token>'+bToken+'</security_token>'+
                 '<sortOrder>Id asc</sortOrder>'+
                '<output>JSON</output>'+
                '</request>'+
                '</ser:getEntitlements>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';

        Logger.pop();

        return xmlRequest;

    }

    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method to get payload for WS call
     * @param: String
     */
    public static String getPayLoadForEntitlementPeople(String PageNumber,String entitlementId,string pageLimitFromSetting,String bToken){

        Logger.push('getPayLoadForEntitlementPeople','TrialsUtilityClass');
        
        System.debug(securityToken+'securityTokensecurityTokensecurityToken');

        String xmlRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.intactws.internal.mathworks.com">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<ser:getEntitlementPeople>'+
                '<request>'+
                '<caller_id>SFDC</caller_id>'+
                '<content><![CDATA[<?xml version="1.0" encoding="UTF-8"?>'+
                '<QueryOptions>'+
                '<limitResults>false</limitResults>'+
                '<pageSize>'+pageLimitFromSetting+'</pageSize>'+
                '<pageNumber>'+PageNumber+'</pageNumber>'+
                '</QueryOptions>]]></content>'+
                '<locale/>'+
                '<output>JSON</output>'+
                '<query>'+entitlementId+'</query>'+
                '<returnData>PERSON</returnData>'+
                '<security_token>'+bToken+'</security_token>'+
                '<sortOrder>person.roleId asc</sortOrder>'+
                '</request>'+
                '</ser:getEntitlementPeople>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';

        Logger.pop();

        return xmlRequest;

    }

    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method to get payload for WS call
     * @param: String
     */
    public static String getPayLoadForEntitlementProduct(String PageNumber,String entitlementId,String bToken){

        Logger.push('getPayLoadForEntitlementProduct','TrialsUtilityClass');


        String xmlRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.intactws.internal.mathworks.com">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<ser:getEntitlementProducts>'+
                '<standardRequest>'+
                '<caller_id>SFDC</caller_id>'+
                '<content><![CDATA[<?xml version="1.0" encoding="UTF-8"?>'+
                '<GetEntitlementProductsRequest>'+
                '<entitlementId>'+entitlementId+'</entitlementId>'+
                '</GetEntitlementProductsRequest>'+
                ']]></content>'+
                '<locale>en_US</locale>'+
                '<output>JSON</output>'+
                '<security_token>'+bToken+'</security_token>'+
                '</standardRequest>'+
                '</ser:getEntitlementProducts>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';


        Logger.pop();

        return xmlRequest;

    }

    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method to get json response
     * @param: String

     */
    public static String sendWSRequest(string payload,String soapAction){

        Logger.push('sendWSRequest','TrialsUtilityClass');

        String bodyRes = '';

        try{


            Http httpProtocol = new Http();
            // Create HTTP request 
            HttpRequest request = new HttpRequest();
            //set ClientCertificate if this code is not running in a test
            //this keeps the tests environment agnostic and the mock callouts do not need a certificate
            if(!Test.isRunningTest()){
            	request.setClientCertificateName(intUtilityHelper.getCACertIntegration());
            }
            //set Organization Id in request header
            request.setHeader('OrganizationID', UserInfo.getOrganizationId());
            //Set the endpoint URL.
            request.setEndPoint(url);
            //Set the HTTP verb to GET.
            request.setMethod('GET');
            //Set Content type
            request.setHeader('Content-Type','text/xml;charset=UTF-8');
            //Set Soap Action
            request.setHeader('SOAPAction',soapAction);
            //Set body
            request.setBody(payload);
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);

            bodyRes = response.getBody();
            //Dom.Document domDoc = res.getBodyDocument();

            system.debug('Response.getStatusCode()'+Response.getStatusCode());

            if(Response.getStatusCode()==200) {

                Dom.Document domDoc = response.getBodyDocument();
                System.debug('Soap response:' + domDoc.toXMLString());
                Dom.XmlNode results = domDoc.getRootElement().getChildElements()[0].getChildElements()[0].getChildElements()[0].getChildElements()[0];
                return results.getText();

            }
            else if (Response.getStatusCode()==408) {

                return 'There are no trials related to this opportunity';

            }
            else { 

                return 'NotFound';
            }

        }Catch(Exception ex){

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex);
            Logger.pop();
            System.Debug('Exception on entitlements:'+ex.getMessage());
            System.Debug('Exception::stackTrace on entitlements:'+ex.getStackTraceString());
            System.Debug('Exception::getTypeName on entitlements:'+ex.getTypeName());
            System.Debug('Exception::getCause on entitlements:'+ex.getCause());
            return null;
        }       
       

    }
    
   

}