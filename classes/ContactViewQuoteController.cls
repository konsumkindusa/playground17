/**
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
 *@date Original:   8 Sept 2014, Last Modified: 24 Nov 2014
 *@description:  this is a controller class for viewing Quote on contact page.
 */
public with sharing class ContactViewQuoteController {
    
    //Initialize variables
    public String quoteJsonString;
    public string selectedquoteId{get; set;}
    public List<Opportunity> opptyList{get; set;}
    // public List <Opportunity> opptyList  = new List <Opportunity>();
    public String contId;
    public transient List<QuoteObject> GQOQuotLst{get;set;}    
    public boolean errMsg{get;set;}
    public String jsonDataopp{get;set;}
    public Boolean jsonMessage {get; set;}
    QuoteIntegrationSettings__c settings ;
    String urljsonData;
    Set<String> opportunitySiebelId;
    Set<String> accountSiebelId;
    public Map<String,Account> mapAccount{get; set;}
    public Map<String,Opportunity> mapOpportunity{get; set;}
    String url;
    public string param{get; set;}
    public Contact cont {get;set;}
    public transient Integer prodSubTot;
    public String body = '{"opportunityId":"OptyId"}' ;
    public String quoteUrl ;
    public id selectedoppoId{get; set;}
    IntegrationUtilityHelper intUtilityHelper; 
    
    //Pagination for Quotes
    public Integer pageIndexOfQuote;
    
    //public double checkModzeroOfQuote;
    public integer pageNumberToSetForQuote {get;set;} 
    public integer totalRecsOfQuote {get;set;} 
    public integer OffsetStart{get;set;}
    public String pageSize;
    public integer modOfQuote{get; set;}
    public integer offsetEnd { get; set;}
    public List<QuoteObject> pageQuotList{get;set;}
    
    public ContactViewQuoteController (ApexPages.StandardController controller)
    {    
        //fetch general setting instance
        settings = QuoteIntegrationSettings__c.getInstance();
        //Getting url from General setting
        url = settings.GQOQuoteBaseURL__c ;
        //Instantiating GOQ Quote list
        GQOQuotLst = new List<QuoteObject> ();
        pageQuotList = new List<QuoteObject> ();
        errMsg = false;
        
        //fetch Integration setting instance
        intUtilityHelper = new IntegrationUtilityHelper();
        
        pageSize = settings.PageSizeForPaginationToShowQuotes__c;
       
        OffsetStart =0;
        
        pageNumberToSetForQuote = 1;
        pageIndexOfQuote = 0;
        Logger.debug('**pageNumberToSetForQuote **'+pageNumberToSetForQuote );
        Logger.debug('**pageSize**'+pageSize);
        offsetEnd = pageNumberToSetForQuote * Integer.valueOf(pageSize);
        System.debug('**offsetEnd **'+offsetEnd);
        modOfQuote = 0;
        this.cont = [select id,Siebel_Contact_Id__c,Account.Name
                     from Contact 
                     where id=:controller.getRecord().Id];
       
    }
    
    /*
     *@Author Original: Divya Gawade - Cloud Sherpas/Mathworks 
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@Date Original: 8 Sept 2014 
     *@Last Modified: 24 Nov 2014
     *@Description: . It will query the Contact record by id passed in url
     */ 
    public void getQuotesOfContactRecord(){

        Logger.push('getQuotesOfContactRecord','ContactQuoteController');
       
        mapAccount = new Map<String,account>();
        mapOpportunity = new Map<String,Opportunity>();
        
       
        contId = this.cont.Siebel_Contact_Id__c;
        
        //Checking for null and  blank value
        if(contId!= null) {
            
            //Get contact json string from endpoint Url
              quoteJsonString = getJsonString(url+'?contactId='+contId );
              
           // Hardcoded Json string for testing purpose
              //quoteJsonString ='[{"id":4350357,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-25 00:00:00.0","createdBy":"aboerman","dateCreated":"2014-08-26 00:00:00.0","productTotal":5400.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":0.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"aboerman","dateUpdated":"2014-08-26 11:58:12.0","accountId":"1-CS15"},{"id":4350358,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-25 00:00:00.0","createdBy":"aboerman","dateCreated":"2014-08-26 00:00:00.0","productTotal":5887.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":287.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"aboerman","dateUpdated":"2014-08-26 12:06:31.0","accountId":"1-CS15"},{"id":4350359,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-25 00:00:00.0","createdBy":"aboerman","dateCreated":"2014-08-26 00:00:00.0","productTotal":2150.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":0.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"aboerman","dateUpdated":"2014-08-26 12:25:39.0","accountId":"1-CS15"},{"id":4350360,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-25 00:00:00.0","createdBy":"cmaniar","dateCreated":"2014-08-26 00:00:00.0","productTotal":2150.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":0.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"cmaniar","dateUpdated":"2014-08-26 12:59:09.0","accountId":"1-CS15"}]';
            
            //Get jason string into searilized list
            if(quoteJsonString != null && quotejsonString!='NotFound')
                GQOQuotLst =GQOQuote.getParsedQuoteJson(quoteJsonString);
            
            if(GQOQuotLst == null || GQOQuotLst.isEmpty()) {
                errMsg= true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.NoQuote));
            }
            else {
            
                  param = '';
                if(ApexPages.currentPage().getparameters().containsKey('isdtp'))
                     param = '?isdtp='+ ApexPages.currentPage().getparameters().get('isdtp');
                 
                totalRecsOfQuote =  GQOQuotLst.size();   
                modOfQuote = (Integer)Math.floor((Double)totalRecsOfQuote/ (Double)Integer.valueOf(pageSize));
                
                //check to see if the number of pages returned are correct as we use the math.floor
                if(totalRecsOfQuote >  (modOfQuote * Integer.valueOf(pageSize)))
                    modofQuote += 1;

                opportunitySiebelId = new set<String>();
                accountSiebelId = new set<String>();
                for(QuoteObject quote : GQOQuotLst ) {
                    opportunitySiebelId.add(quote.opportunityId);
                    accountSiebelId.add(quote.accountId);
                    quote.prodSubTot = quote.productTotal - (quote.handlingTotal + quote.taxTotal);
                }

                if(!accountSiebelId.isEmpty()) {
                    mapAccount = new Map<String,Account>();
                    for(Account acc : [SELECT id, Siebel_Account_Id__c, Name, Account_Name_Latin__c 
                                       FROM Account 
                                       WHERE Siebel_Account_Id__c in : accountSiebelId]) {
                        mapAccount.put(acc.Siebel_Account_Id__c,acc);
                    }
                    
                    For(String quoteAccountIdKey: accountSiebelId){
                        if(!mapAccount.containskey(quoteAccountIdKey)){
                         mapAccount.put(quoteAccountIdKey,new Account(name='DummyAccount'));
                         }
                    }
                }
            
               
                    mapOpportunity = new Map<String,Opportunity>();
                    for(Opportunity oppo: [Select id, Siebel_Opportunity_ID__c, Name 
                                           FROM Opportunity 
                                           WHERE Id in : opportunitySiebelId]){
                        system.debug('Opportunity: '+oppo);
                        mapOpportunity.put(oppo.id,oppo);
                        system.debug('mapOpportunity : '+mapOpportunity);
              }
              
              System.debug(mapOpportunity+'mapOpportunitymapOpportunitymapOpportunitymapOpportunity111111111111111111111');
                
                For(String quoteOpportunityIdKey: opportunitySiebelId){
                        if(!mapOpportunity.containskey(quoteOpportunityIdKey)){
                         mapOpportunity.put(quoteOpportunityIdKey,new Opportunity(name='DummyOpportunity'));
                         }
                    }
                    
               System.debug(mapOpportunity+'mapOpportunitymapOpportunitymapOpportunitymapOpportunity');
                
            }
        } 
        
        else{
            errMsg= true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.ContQuoreMsg));
            Logger.pop();
        }
    }
    
    /**
     * @author Original: Divya Gawade
     * @date Original:8 Sept 2014 , Last Modified: Divya Gawade
     * @description: Method to get json string from endpointurl
     * @param: String

     */
    public String getJsonString(String endpointUrl){
        Logger.push('getJsonString','ContactViewQuoteController');
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
            //set business process token in request header
            if(!Test.isrunningTest())
            request.setHeader('X_MW_WS_securityToken',intUtilityHelper.getBusinessServiceToken());
            //set the caller Id in the request Header
            request.setHeader('X_MW_WS_callerId',intUtilityHelper.getCallerId());
            // Set the endpoint URL.
            request.setEndPoint(endpointUrl);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);

            //Get json String 
            String jsonData;
            if(Response.getStatusCode()==200) {
                jsonData = response.getBody();                
                return jsonData;
             }
            else if (Response.getStatusCode()==408) {
                return system.label.ContQuoteFailResp;
             }
             else { 
                return 'NotFound';
             }
        }
        catch(Exception ex) {

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex.getMessage()+'for contactId'+contId);
            Logger.pop();
            return null;
        }
    }
    
    /**
     * @author Original: Divya Gawade
     * @date Original:8 Sept 2014 , Last Modified: Divya Gawade
     * @description: Method to get json string from endpointurl
     * @param: String

     */
    public PageReference setJsonStringForOpp(){
        Logger.push('setJsonStringForOpp','ContactViewQuoteController');
      //  try{
        
            quoteUrl = settings.GQOQuoteBaseURL__c + '/' + selectedquoteId;
            Http httpProtocol = new Http();
            // Create HTTP request 
            HttpRequest request = new HttpRequest();
            
            //set the contents of the body for this request
            request.setBody(body.replace('OptyId',selectedoppoId));
            system.debug('body.replace********'+body.replace('OptyId',selectedoppoId));
            //set ClientCertificate if this code is not running in a test
            //this keeps the tests environment agnostic and the mock callouts do not need a certificate
            if(!Test.isRunningTest()){
                request.setClientCertificateName(intUtilityHelper.getCACertIntegration());
            }
            //set Organization Id in request header
            request.setHeader('OrganizationID', UserInfo.getOrganizationId());
            //set business process token in request header
            if(!Test.isrunningTest())
            request.setHeader('X_MW_WS_securityToken',intUtilityHelper.getBusinessServiceToken());
            //set the caller Id in the request Header
            request.setHeader('X_MW_WS_callerId',intUtilityHelper.getCallerId());
            //set the Content Type
            request.setHeader('Content-Type', 'application/json');
            // Set the endpoint URL.
            request.setEndPoint(quoteUrl);
            // Set the HTTP verb to GET.
            request.setMethod('POST');
            system.debug('***selectedquoteId***'+selectedquoteId );
            system.debug('***selectedoppoId***'+selectedoppoId);
            // Set the Timeout
            request.setTimeout(20000);
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);
            
            //Get json response
            
            if(Response.getStatusCode()==200) {
                jsonDataopp = system.label.ContQuoteSuccessResp +selectedquoteId; 
             }
            else if (Response.getStatusCode()==404) {
                jsonDataopp = system.label.ContQuoteFailResp ;
             }
             else { 
                jsonDataopp = system.label.NoQuote;
             }
              
             jsonMessage = true;
            
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,jsonDataopp);
             ApexPages.addMessage(myMsg);
             return null;
    }
    
     /**
     * @author Original:Divya Gawade 
     * @date Original: 10/10/2014, Last Modified: Divya Gawade , Last Modified : Faina Gorelik Atttask 883989 
     * @description: This method is used to query opportunities and related account. FG refined search to created for the last 12 months and contact exists in  contact role table
     * @param: Void

     */
    
    public void getOppty(){
        
        Date lastDays = Date.today().addDays(-365);
        String currentContId = cont.Id;
        String accName =cont.Account.Name;
        String query = 'SELECT id,Name ';
        for(Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.QuoteOppoCont.getFields()){
            query += ', ' + f.getFieldPath() + ' ';
        }
      
        query += 'from Opportunity where  isclosed=false and CreatedDate >=:lastDays and Id in (select OpportunityId from OpportunityContactRole where ContactId =:currentContId ) order by CloseDate desc limit 1000';
                      
        opptylist = database.query(query);
    }
    
    //Pagination for quotes Page

     public void firstPageOfQuote()
    {
        getQuotesOfContactRecord();
        pageNumberToSetForQuote = 1;
        OffsetStart =0;
        pageIndexOfQuote = 0;
        offsetEnd = pageNumberToSetForQuote * Integer.valueOf(pageSize);
        if(offsetEnd > totalRecsOfQuote){
            offsetEnd = totalRecsOfQuote;
        }
        
        pageQuotList = getPageQuoteList(OffsetStart, offsetEnd);        
        
    }


    public void previousOfQuote()
    {
        getQuotesOfContactRecord();
        pageNumberToSetForQuote=pageNumberToSetForQuote - 1;        
        pageIndexOfQuote = pageIndexOfQuote - 1;
        if(pageIndexOfQuote < 0)
            pageIndexOfQuote = 0;
         OffsetStart = pageIndexOfQuote*Integer.valueOf(pageSize);
         
        offsetEnd = pageNumberToSetForQuote * Integer.valueOf(pageSize);
        if(offsetEnd > totalRecsOfQuote){
            offsetEnd = totalRecsOfQuote;
        }
        
        pageQuotList = getPageQuoteList(OffsetStart, offsetEnd);   

    }

    public void nextOfQuote()
    {
        getQuotesOfContactRecord();
        pageNumberToSetForQuote=pageNumberToSetForQuote + 1;
        pageIndexOfQuote = pageIndexOfQuote + 1;
        //OffsetStart = OffsetStart + LimitSizeOfQuote;
        OffsetStart = pageIndexOfQuote * Integer.valueOf(pageSize);
        if(OffsetStart == totalRecsOfQuote)
            OffsetStart = OffsetStart - Integer.valueOf(pageSize);
        
        offsetEnd = pageNumberToSetForQuote * Integer.valueOf(pageSize);
        if(offsetEnd > totalRecsOfQuote){
            offsetEnd = totalRecsOfQuote;
        }
        System.Debug('page offset start:'+ offsetStart);
        System.Debug('page offset End:'+ offsetEnd);
        
        pageQuotList = getPageQuoteList(OffsetStart, offsetEnd); 

    }


    public void LastPageOfQuote()
    {
        getQuotesOfContactRecord();
        
       // OffsetStart = totalRecsOfQuote-(math.mod(totalRecsOfQuote,pagesize))-pageSize;
       pageNumberToSetForQuote=modOfQuote ;
       pageIndexOfQuote = modOfQuote ;
       OffsetStart = pageIndexOfQuote * Integer.valueOf(pageSize);
       if(OffsetStart == totalRecsOfQuote){
            OffsetStart = OffsetStart - Integer.valueOf(pageSize);
            pageIndexOfQuote = pageIndexOfQuote - 1;
       }
       offsetEnd = totalRecsOfQuote;
       pageQuotList = getPageQuoteList(OffsetStart, offsetEnd);      
    
    }
    
     public boolean getprev()
    {
            return pageNumberToSetForQuote == 1;
    }

    public boolean getnxt()
    { 
            return Integer.valueOf(pageNumberToSetForQuote) == modOfQuote ;
    }
    
    public List<QuoteObject> getPageQuoteList(Integer startIndex, Integer endIndex){
        List<QuoteObject> quoteList = new List<QuoteObject>();
        System.Debug('offset start:'+startIndex);
        System.Debug('offset End:'+endIndex);
        try{
            if(GQOQuotLst!= null && GQOQuotLst.size() > 0){
                for(Integer i= startIndex;i<endIndex;i++){
                    quoteList.add(GQOQuotLst[i]);
                }
            }
        }
        catch(Exception ex){
            System.Debug('Exception in getPageQuoteList:'+ex.getMessage());
        }
        System.Debug('getpageQuoteList:'+quoteList);
        return quoteList;
    }

   
}