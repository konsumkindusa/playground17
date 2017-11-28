/**
 *author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
 *date Original:   5 August 2014, Last Modified: 5 August 2014
 *description:     this is a controller class for Quote lookup page.
 */
public class QuoteController {
    
    //Initialize variables
    public String quoteJsonString;
    public String opptyId;
    public transient List<QuoteObject> GQOQuotLst{get;set;}
    public boolean errMsg{get;set;}
    QuoteIntegrationSettings__c settings ;
    String urljsonData;
    Set<String> contactSiebelId;
    Set<String> accountSiebelId;
    public transient Map<String,Contact> mapContact{get; set;}
    public transient Map<String,Account> mapAccount{get; set;}
    public string param{get; set;}
    String url;
    public Opportunity oppty {get;set;}
    public transient Integer prodSubTot;
    
    IntegrationUtilityHelper intUtilityHelper;
    
    //Pagination for Quotes
    public Integer pageIndexOfQuote;    
    public integer pageNumberToSetForQuote {get;set;} 
    public integer totalRecsOfQuote {get;set;} 
    public integer OffsetStart{get;set;}
    public String pageSize;
    public integer modOfQuote{get; set;}
    public integer offsetEnd { get; set;}
    public List<QuoteObject> pageQuotList{get;set;}
    
    public QuoteController(ApexPages.StandardController controller)
    {    
        //fetch general setting instance
        settings = QuoteIntegrationSettings__c.getInstance();
        //Getting url from General setting
        url = settings.GQOQuoteBaseURL__c ;
        //Instantiating GOQ Quote list
        system.debug('******settings : '+settings);
        GQOQuotLst = new List<QuoteObject> ();
        pageQuotList = new List<QuoteObject> ();
        errMsg = false;
        pageSize = settings.PageSizeForPaginationToShowQuotes__c;
        
        //fetch integration setting instance
        intUtilityHelper = new IntegrationUtilityHelper();
       
        OffsetStart =0;        
        pageNumberToSetForQuote = 1;
        pageIndexOfQuote = 0;
        offsetEnd = pageNumberToSetForQuote * Integer.valueOf(pageSize);
        modOfQuote = 0;
        this.oppty = (Opportunity)controller.getRecord();
        
    }
    
    /*
     *@Author Original: Divya Gawade - Cloud Sherpas/Mathworks 
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@Date Original: 5 August 2014 
     *@Last Modified: 5 August 2014
     *@Description: . It will query the Opportunity record by id passed in url
     */ 
    public void getQuotesOfOpportunityRecord(){

        Logger.push('getQuotesOfOpportunityRecord','OpportunityViewQuoteController');
        system.debug('*****oppty.id'+oppty.id);
        mapContact = new Map<String,contact>();
        mapAccount = new Map<String,account>();
       
        opptyId = oppty.Id;
     
        if(oppty != null) {
            
            system.debug('******url'+url);
            //Get opportunity json string from endpoint Url
              quoteJsonString = getJsonString(url+'?opportunityId='+opptyId );
            //quoteJsonString = '[{"id":4350357,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-29 00:00:00.0","createdBy":"aboerman","dateCreated":"2014-08-26 00:00:00.0","productTotal":5400.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":0.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"aboerman","dateUpdated":"2014-08-26 11:58:12.0","accountId":"1-CS15"},{"id":4350358,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-2 00:00:00.0","createdBy":"aboerman","dateCreated":"2014-08-26 00:00:00.0","productTotal":5887.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":287.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"aboerman","dateUpdated":"2014-08-26 12:06:31.0","accountId":"1-CS15"},{"id":4350359,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-08-25 00:00:00.0","createdBy":"aboerman","dateCreated":"2014-08-26 00:00:00.0","productTotal":2150.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":0.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"aboerman","dateUpdated":"2014-08-26 12:25:39.0","accountId":"1-CS15"},{"id":4350360,"opportunityId":"006e0000006osYWAAY","contactId":"1-1JAHOZ","quoteStatus":"Working","expirationDate":"2014-09-25 00:00:00.0","createdBy":"cmaniar","dateCreated":"2014-08-26 00:00:00.0","productTotal":2150.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":0.0,"orderDate":null,"currencyCode":"USD","webViewable":false,"modifiedBy":"cmaniar","dateUpdated":"2014-08-26 12:59:09.0","accountId":"1-CS15"}]';
            
            //Get jason string into searilized list
            system.debug('******quoteJsonString'+quoteJsonString);
            if(quoteJsonString != null && quotejsonString!='NotFound')
                GQOQuotLst =GQOQuote.getParsedQuoteJson(quoteJsonString);
                
            system.debug('******GQOQuotLst'+GQOQuotLst);
            if(GQOQuotLst == null || GQOQuotLst.isEmpty()) {
                errMsg= true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.NoQuote));
            }
            else {
                
                param = '';
                if(ApexPages.currentPage().getparameters().containsKey('isdtp')){
                     param = '&isdtp='+ ApexPages.currentPage().getparameters().get('isdtp');
                   }
                
                totalRecsOfQuote =  GQOQuotLst.size();   
                modOfQuote = (Integer)Math.floor((Double)totalRecsOfQuote/ (Double)Integer.valueOf(pageSize));
                
                //check to see if the number of pages returned are correct as we use the math.floor
                if(totalRecsOfQuote >  (modOfQuote * Integer.valueOf(pageSize)))
                    modofQuote += 1;

                
                contactSiebelId = new set<String>();
                accountSiebelId = new set<String>();
                for(QuoteObject quote : GQOQuotLst ) {
                    contactSiebelId.add(quote.contactId);
                    accountSiebelId.add(quote.accountId);
                    quote.prodSubTot = quote.productTotal - (quote.handlingTotal + quote.taxTotal);
                }
               
                if(!contactSiebelId.isEmpty()) {
                    mapContact = new Map<String,Contact>();
                    for(Contact con : [SELECT id, lastName, Siebel_Contact_Id__c, Name, First_Name_Latin__c, Last_Name_Latin__c
                                       FROM Contact 
                                       WHERE Siebel_Contact_Id__c in : contactSiebelId]) {
                        system.debug('Contact : '+con);
                        mapContact.put(con.Siebel_Contact_Id__c,con);
                        
                    }
                    
                     //Fill map With quote contact seibel id Keys with Null Values so we can not get Map Key Not Found 
                    For(String quoteContactIdKey: contactSiebelId){
                        if(!mapContact.containskey(quoteContactIdKey)){
                         mapContact.put(quoteContactIdKey,new Contact(lastName='DummyContact'));
                         }
                    }
                }
                if(!accountSiebelId.isEmpty()) {
                    mapAccount = new Map<String,Account>();
                    for(Account acc : [SELECT id, Siebel_Account_Id__c, Name, Account_Name_Latin__c 
                                       FROM Account 
                                       WHERE Siebel_Account_Id__c in : accountSiebelId]) {
                        system.debug('Account : '+acc);
                        mapAccount.put(acc.Siebel_Account_Id__c,acc);
                        system.debug('mapAccount : '+mapAccount);
                    }
                    
                    For(String quoteAccountIdKey: accountSiebelId){
                        if(!mapAccount.containskey(quoteAccountIdKey)){
                         mapAccount.put(quoteAccountIdKey,new Account(name='DummyAccount'));
                         }
                    }
            }
                
        } 
        Logger.pop();
        }
        else{
            errMsg= true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.OppoQuoteMsg));
        }
    }
    
    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method to get json string from endpointurl
     * @param: String

     */
    public String getJsonString(String endpointUrl){
        Logger.push('getJsonString','QuoteController');
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
            //set the business process token in request header
            request.setHeader('X_MW_WS_securityToken',intUtilityHelper.getBusinessServiceToken());
            //set the caller Id in the request header
            request.setHeader('X_MW_WS_callerId', intUtilityHelper.getCallerId());
            // Set the endpoint URL.
            request.setEndPoint(endpointUrl);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            // Send the HTTP request and get the response.
            // The response is in JSON format.
            system.debug('Request : '+request);
            HttpResponse response = httpProtocol.send(request);

            //Get json String 
            String jsonData;
            if(Response.getStatusCode()==200) {
                jsonData = response.getBody();                
                return jsonData;
             }
            else if (Response.getStatusCode()==408) {
                return system.label.OppoQuoteFailResp;
             }
             else { 
                return 'NotFound';
             }
        }
        catch(Exception ex) {

            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex.getMessage()+'for OpportunityId'+opptyId);
            Logger.pop();
            return null;
        }
    }
    
    //Pagination for quotes Page

     public void firstPageOfQuote()
    {
        getQuotesOfOpportunityRecord();
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
        getQuotesOfOpportunityRecord();
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
        getQuotesOfOpportunityRecord();
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
        getQuotesOfOpportunityRecord();
        
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

        return Integer.valueOf(pageNumberToSetForQuote) == modOfQuote;
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