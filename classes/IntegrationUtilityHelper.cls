/**
 * @Author Original:Sagar Talele
 * @Date Original: 10 October 2014
 * @Description: Methods Related to integrations
 * @Revision:Archana Lohar|19 Nov 2014|
 */
public without sharing class IntegrationUtilityHelper {

    //Instantiating Integration_Settings__c object
    public  Integration_Settings__c integrationSettingRec=new Integration_Settings__c();
    public IntegrationUtilityHelper(){

        // Query the Integration_Settings__c and get the Username,Password,Clientname,Endpoint ,Timeout details for name =  'On Support'.
        List<Integration_Settings__c> integrationSettingRecs = [Select Id, Name, Username__c, Password__c, Clientname__c,
                                 Endpoint__c, Timeout__c,
                                 Locale__c,Retry_Attempts__c,
                                 Caller_ID__c,CA_Cert__c
                                 From Integration_Settings__c
                                 Where Name = 'MW Integrations' limit 1];
        
        if(integrationSettingRecs != null && integrationSettingRecs.size()> 0){
            integrationSettingRec = integrationSettingRecs[0];        
        }

    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: Utility method to get a business security token which is used for authenticating all inbound integrations at MathWorks
     */
    public  String getBusinessServiceToken(){

        Logger.push('IntegrationUtilityHelper','getBusinessServiceToken');
        Map<String,String> nodeElementsMap=new Map<String,String>();
        Integer noOfAttempts=0; //how many times have we tried to get a business security token from the service
        Boolean retry = True; //flag for whether or not to continue attempting to retrieve a business security token
        //build a soap message to retrieve a business security token, retrieve credentials from the Integration Settings object
        String xml ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://internal.mathworks.com/businessprocesstokenws/services">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<ser:getBusinessProcessToken>'+
                '<ser:user>'+integrationSettingRec.Username__c+'</ser:user>'+
                '<ser:password>'+integrationSettingRec.Password__c+'</ser:password>'+
                '<ser:clientString>'+integrationSettingRec.Clientname__c+'</ser:clientString>'+
                '</ser:getBusinessProcessToken>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';

        Do{
            
            noOfAttempts++;
            
            try{
                //Build the Http callout to the business security token service
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(integrationSettingRec.Endpoint__c+'businessprocesstokenws/services/BusinessProcessTokenService');
                req.setMethod('GET');
                req.setHeader('Content-Type','text/xml;charset=UTF-8');
                req.setHeader('SOAPAction','getBusinessProcessToken');
                //Not setting the certificate while running the test so that the unit test could
                //run environment agnostic.
                if(!Test.isRunningTest()){
                    req.setClientCertificateName(integrationSettingRec.CA_Cert__c);
                }
                req.setBody(xml);
                string bodyRes = '';
                HttpResponse res = new httpResponse();
                
                //call the service with the request body and parse the response
                res = h.send(req);
                bodyRes = res.getBody();                
                
                nodeElementsMap= XMLParser(bodyRes);
                
                //check if we got a business security token in the response
                if(nodeElementsMap.containskey('token')){
                    
                    //successfully got a token, return to the calling method with the result
                    retry=false;                     
                    return nodeElementsMap.get('token');
                }       

            }     
            catch(Exception e){
                
                //log the attempt as an exception and try the call again
                retry=true;
                Logger.debugException(e.getMessage());
                Logger.pop();
            }
            
        //attempt to call the business security token service for X times defined in Retry_Attempts__c
        }While(retry && noOfAttempts<=integrationSettingRec.Retry_Attempts__c);
        
        //if the security token could not be retrieved after X attempts, return an error code to the calling method
        return 'SecurityTokenNotFound';
        
    }

    /**
     * @Author Original:Sagar Talele (Cloud Sherpas)
     * @Date Original: 10 October 2014
     * @Description: utility method to parse an XML string and build a map of document elements
     */
    public Map<String,String>  XMLParser(String strXml){

        Dom.Document doc = new Dom.Document();

        Map<String,String> stockMap=new Map<String,String>();

        doc.load(strXml);

        Dom.XMLNode Envelope = doc.getRootElement();

        for(Dom.XMLNode firstChild: Envelope.getChildElements()){

            for(Dom.XMLNode moreChilds: firstChild.getChildElements()){

                stockMap.put(moreChilds.getName(), moreChilds.getText());

                for(Dom.XMLNode moreChilds1: moreChilds.getChildElements()){

                    stockMap.put(moreChilds1.getName(), moreChilds1.getText());

                    for(Dom.XMLNode moreChilds2: moreChilds1.getChildElements()){

                        stockMap.put(moreChilds2.getName(), moreChilds2.getText());

                    }

                }
            }

        } return stockMap;
    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: getting the callerId  from Integration_Settings__c.
     */

    public  String getCallerId(){

        return  integrationSettingRec.Caller_ID__c;
    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: getting the Locale value from Integration_Settings__c.
     */

    public  String getLocale(){

        return  integrationSettingRec.Locale__c;
    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: getting the CACertIntegration value from Integration_Settings__c.
     */

    public  String getCACertIntegration(){

        return integrationSettingRec.CA_Cert__c;

    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: getting the UserName value from Integration_Settings__c.
     */

    public  String getUserName(){

        return integrationSettingRec.Username__c;
    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: getting the password value from Integration_Settings__c.
     */

    public  String getPassword(){

        return integrationSettingRec.Password__c;

    }

    /**
     * @Author Original:Sagar Talele
     * @Date Original: 10 October 2014
     * @Description: getting the EndPoint value from Integration_Settings__c.
     */

    public  String getEndPoint(){

        return integrationSettingRec.Endpoint__c;
    }
    
    /**
     * @Author Original:kishore AN
     * @Date Original: 12 November 2015
     * @Description: getting the timeout value from Integration_Settings__c.
     */

    public Integer getTimeout(){

        return integrationSettingRec.Timeout__c.intValue();
    }



}