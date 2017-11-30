/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
 *date Original:   2 June 2014, Last Modified: 30 March 2016
 *description:     this is a controller class for cds lookup page 
 *revision:        3 June 2014 | Andre Calimlim | Added jsonstring as holder of json in properties
 *                 4 June 2014 | Andre Calimlim | Modified searchContact()
 *                 4 June 2014 | Archana Lohar  | Modified searchContact()
 *                11 July 2014 | Archana Lohar  | Modified searchContact()
 *                 5 Aug 2014  | Jaspreet Monga | Modified createAccountFromCDS() - removed source value from JSON string, as source field doesn't exist in CDS anymore, Attask story# 1028509
 *                29 Mar 2016  | Shweta Shanbhag | Used derivedCountryCode to set Countrycode for individual contact for story : 1427676
 *                08 Apr 2016  | Donna Latte    |  Pull MWA Verified Email and Corporate Parent:  Story 1427895
 * 				  18 May 2016  | Donna Latte    |  Added logic to pass SecurityToken
 * 				  20 Jun 2016  | Donna Latte    |  Story: 1499217 Self Identified Country
 */
global class GlobalContactSearchController{

    //Initialize variables
    public String conJsonString;
    public String accJsonString;

    public CDSContact.Rootboolean CDSConObj; 
    public CDSAccount.RootString  CDSAccObj;

    public Contact contObj{get;set;}  

    public List<Contact> contList=new List<Contact>();
    General_Settings__c settings ;
    Countries_Requiring_States__c cRSSettings ;
    public List<Account> accountList;
    PageReference ContactDetailPage;
    PageReference CDSContactDetailPage;
    public boolean showHeader = true;
    public boolean showSidebar =  true;
    public boolean isWS = false;
    public String STerrorMessage=System.Label.SecurityTokenNotFoundMessage; //DL 1508448
   	public IntegrationUtilityHelper intHelper; //DL 1508448
    public string bToken;  //DL 1508448

    String urljasonData;
    String url;

    
    
    public GlobalContactSearchController(){
    }
    
    public GlobalContactSearchController(String email){
        //fetch general setting instance
        settings = General_Settings__c.getInstance();

        //fetch Countries requiring states setting instance
        cRSSettings = Countries_Requiring_States__c.getInstance();

        //Getting url from General setting
        url = settings.CDSBaseUrl__c;  

        //Instantiating Contact Object
        contObj=new Contact();
        contObj.Email = email;

        //SFDC Account List
        accountList= new List<Account>();
        
        isWS=true;
        
        
        
    }
    
    //constructor
    public GlobalContactSearchController(ApexPages.StandardController controller)
    {               
            
        //fetch general setting instance
        settings = General_Settings__c.getInstance();

        //fetch Countries requiring states setting instance
        cRSSettings = Countries_Requiring_States__c.getInstance();

        //Getting url from General setting
        url = settings.CDSBaseUrl__c;  

        //Instantiating Contact Object
        contObj=new Contact();     

        //SFDC Account List
        accountList= new List<Account>();
        
        //Checking query string paramater email 
        if(ApexPages.currentPage().getParameters().get('email') !='')
        {
            contObj.Email = ApexPages.currentPage().getParameters().get('email');
        }               

    }
    /**
     * @author Original: Krishna Bhaskarla
     * @date Original: , Last Modified: 
     * @description: Contact Search Webservice
     * @param: 
     */
     webService static SearchContactResponse searchContactByEmail(String email){
        SearchContactResponse searchContactResponse = new SearchContactResponse();
        searchContactResponse.ErrorCode = 'FAIL';
        if(nullOrEmpty(email)){
            searchContactResponse.ErrorReason = 'Please enter a valid email';
            return searchContactResponse;
         }
        System.debug('In GlobalContactSearchController method webService static SearchContactResponse method about to call Global Contact Search Controller passing email');
        GlobalContactSearchController search = new GlobalContactSearchController(email);
                       
         try{
         PageReference pf = search.searchContact();
         String responseurl = pf.getUrl();
         system.debug('responseurl :'+responseurl );
         String contactid = responseurl.substringAfterLast('/');
         system.debug('contactid:'+contactid);
         if(contactid == 'GlobalContactSearchOptions' || nullOrEmpty(contactid)){
             searchContactResponse.ErrorReason = 'No Contact found';
             return searchContactResponse;
         }
         searchContactResponse.ErrorCode = 'SUCCESS';
         searchContactResponse.ErrorReason = 'Ok';
         searchContactResponse.ContactId = contactid;
         return searchContactResponse;
         } catch (Exception e){
              return searchContactResponse;
          }  
    
     }
    
   /*
    * @param o the object to test 
    * @return true if the specified object is null, empty, or only whitespace
    */
    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
        ((o instanceof String) && (0 == ((String)o).trim().length())) ||
        ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
    
 /*Webservice Response Object*/
    global class SearchContactResponse {
     
      webservice    String ErrorCode;
      webservice String ErrorReason;
      webservice String ContactId; 
     
     /**
     * An empty constructor
     */
     public SearchContactResponse() {}
 
    
    }

    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method that search for contact
     * @param: PaageReference
     */
    public PageReference searchContact(){  


        Logger.push('searchContact','GlobalContactSearchController');
        
        try{  
            //Query Contact By Email
            system.debug('Contact:'+contObj.email);
            contList=[select id from contact where email=:contObj.email ];
            //If contact found in salesforce ,redirect it to the contact detail page
            if (contList!=null && !contList.isEmpty()){
                for (Contact conObj:contList){
                    //Redirect to Contact Detail Page
                    ContactDetailPage= new PageReference('/' + conObj.id);
                    return ContactDetailPage;
                }//for
            }//if
            else {//Search contact in CDS

                //Get contact jason string from endpoint Url
           		// DL: 1508448 Get Business Security token from IntegrationUtilityHelper */
           		intHelper=new IntegrationUtilityHelper ();
           		bToken=intHelper.getBusinessServiceToken();           		
           		
                 if(bToken!='SecurityTokenNotFound'){
                	conJsonString=getJasonString(url+'contacts?recordType=CRM&email='+contObj.email+'&X_MW_WS_securityToken='+bToken);
                	System.Debug('Json String for contact:'+conJsonString);
                 }else {
                      if(!isWS){
                		UtilityHelper.addErrorMessage(STerrorMessage);
            			}
                 	Logger.debugException(STerrorMessage);
                    Logger.pop();
                    return null; 
                 } // DL:  END 1508448

                //Check for proper Json string
                //DL: 1508448 added && conJsonString != '' 
                if (conJsonString!= null && conJsonString!='NotFound' && conJsonString != ''){
                	System.Debug('Thinks JSON is proper ' + conJsonString);

                    //Get jason string into searilized object
                    CDSConObj=CDSContact.getParsedContactJson(conJsonString); 

                    //Check if primary account id is not null
                    if(CDSConObj.primaryAccountId!=null && CDSConObj.primaryAccountId!=''){

                        //Check for duplicate account using CDS primaryAccountId
                        accountList=[select id from Account where CDS_Account_Id__C=:CDSConObj.primaryAccountId ];

                        System.debug('accountListaccountListaccountList'+accountList);

                        if(accountList==null ||  accountList.isEmpty()){

                            //Get jason Account string from endpoint Url
                            // DL: 1508448 added security token
                            accJsonString=getJasonString(url+'accounts/'+CDSConObj.primaryAccountId+'?X_MW_WS_securityToken='+bToken);

                            //Check accJsonString is not null
                            if(conJsonString!='NotFound' && conJsonString != ''){

                                //Get jason string into searilized object
                                CDSAccObj=CDSAccount.getParsedAccountJson(accJsonString);

                                //Create salesforce Account from cds record 
                                String  accountID=createAccountFromCDS(CDSAccObj,CDSConObj);


                                if(accountID!=null &&  accountID!='ImproperDataInCDS'){
                                    //Create salesforce Contact from cds record 
                                    String contactId=createContactFromCDS(CDSConObj,accountID);


                                    //Redirect to the newly created Contact detail page
                                    if(contactId!=null  && contactId!='ImproperDataInCDS'){


                                        //Redirect to the newly created contact detail page
                                        ContactDetailPage= new PageReference('/' +contactId);
                                        return ContactDetailPage;

                                    }//If
                                    else if(contactId=='ImproperDataInCDS')
                                    {
                                        //redirect to page with the search options                                                                              
                                        return new PageReference('/apex/GlobalContactSearchOptions');                                        

                                    }

                                }//If
                                else if(accountID=='ImproperDataInCDS'){

                                    //redirect to page with the search options
                                    return new PageReference('/apex/GlobalContactSearchOptions');                                    
                                    
                                }

                            }//If
                        }
                        else
                        {
                            //Create Contact Using exsisting SFDC account id
                            String contactId=createContactFromCDS(CDSConObj,accountList[0].id);

                            //Redirect to the newly created Contact detail page
                            if(contactId!=null && contactId!='ImproperDataInCDS'){

                                ContactDetailPage= new PageReference('/' +contactId);
                                return ContactDetailPage;

                            }
                            else if(contactId=='ImproperDataInCDS'){

                               //redirect to page with the search options
                               return new PageReference('/apex/GlobalContactSearchOptions');                                
                                
                            }

                        }
                    }
                    else{

                        String  contactId=createContactFromCDS(CDSConObj,null);

                        //Redirect to the newly created Contact detail page
                        if(contactId!=null && contactId!='ImproperDataInCDS'){

                            ContactDetailPage= new PageReference('/' +contactId);
                            return ContactDetailPage;

                        }
                        else if(contactId=='ImproperDataInCDS'){

                            //redirect to page with the search options
                            return new PageReference('/apex/GlobalContactSearchOptions');   
                            
                        }

                    }//else


                }//if
                else {//if contact not found in salesforce as well as in CDS then redirect it to the page with search options

                   //redirect to page with the search options - create new contact, search again or do a global search
                   return new PageReference('/apex/GlobalContactSearchOptions');
                    
                }//else

            }

        }
        catch(Exception ex){
        
            System.Debug('Exception in GlobalContactSearch:'+ex.getMessage());           
            
            if(!isWS){
                UtilityHelper.addErrorMessage(ex.getMessage());
            }
            Logger.debugException(ex);
            Logger.pop();
            return null;

        }//catch
        
        return null;

    }
    /**
     * @author Original:    Last Modified: kishore AN - cloud sherpas/Mathworks 
     * @date Original: , Last Modified: 28 April 2015
     * @description: Method to create contact in sfdc from cds contact details
     *  Added logic to set the mailing country code for the standalone contact
     */
    public String createContactFromCDS(CDSContact.Rootboolean  cdsConObj,Id accId){


        Logger.push('createContactFromCDS','GlobalContactSearchController');
        //System.Debug('Before creating contact in GlobalContactSearchController:'+ cdsConObj);
        //Create New Contact 
        Contact newContactObj=new Contact();

        //Assigning Values from cdsConObj

        //Assign cds record id to contact cds id
        newContactObj.CDS_Contact_Id__c=cdsConObj.id;
        newContactObj.Salutation=cdsConObj.Salutation;
        newContactObj.FirstName=cdsConObj.givenName;
        newContactObj.LastName=cdsConObj.familyName;
        newContactObj.First_Name_Latin__c = cdsConObj.latinGivenName;
        newContactObj.Last_Name_Latin__c = cdsConObj.latinFamilyName;
        newContactObj.Title = cdsConObj.jobTitle;
        newContactObj.Job_Title_Latin__c = cdsConObj.latinJobTitle;
        newContactObj.Contact_Role__c = cdsConObj.contactRole;

        newContactObj.AccountId=accId;

        //Always set contact status Active
        newContactObj.Contact_Status__c='Active';

        newContactObj.Department=cdsConObj.department;
        newContactObj.Department_Latin__c=cdsConObj.latinDepartment;
        
        newContactObj.Email=cdsConObj.emailAddress;
        
        system.debug(cdsConObj.emailAddress+'cdsConObj.emailAddresscdsConObj.emailAddress');
        
        newContactObj.Siebel_Contact_Id__c=cdsConObj.siebelId;
        newContactObj.Mathworks_Account_id__c=cdsConObj.webprofileId; 
        
        //DL: Story 1499217 added SelfIdentifiedCountry
        if(cdsConObj.selfIdentifiedCountryCode !=null){
                newContactObj.Self_Identified_Country__c = cdsConObj.selfIdentifiedCountryCode;              
          } //DL End                 
        
        
        //check if the contact is a business contact and set the mailing address from address
        //else the contact is a standalone contact(no account associated with the contact)
        //and set the derivedCountryCode as the mailingcountrycode
        
        if(accId!= null){
            if(cdsConObj.address.stateCode!=null){
                if((cdsConObj.address.stateCode).contains('-') ){
                    newContactObj.MailingCountryCode=(cdsConObj.address.countryCode).substringBefore('-');
                    newContactObj.MailingStateCode=(cdsConObj.address.stateCode).substringAfter('-');
    
                }
                else
                {	
                    newContactObj.MailingCountryCode=cdsConObj.Address.countryCode;
                    newContactObj.MailingStateCode=cdsConObj.Address.stateCode;
    
                }
    
            }
            else
            {
                newContactObj.MailingCountryCode=cdsConObj.Address.countryCode;
                newContactObj.MailingStateCode=cdsConObj.Address.stateCode;
    
            }
        }
        else{
            
            //set the derivedCountryCode as the mailing country code if it is not null
            //SS 3/29/16 Changed the field from selfidentifiedcountrycode to derivedCountryCode for story: 1427676
            if(cdsConObj.derivedCountryCode !=null){
                newContactObj.MailingCountryCode = cdsConObj.derivedCountryCode;              
            }else {
                //set the schoolcountry as the mailing country
                newContactObj.MailingCountryCode = cdsConObj.schoolCountry;
                 }
        	}
        
        newContactObj.MailingCity=cdsConObj.Address.city;
        newContactObj.MailingStreet = cdsConObj.Address.line1;
        newContactObj.MailingPostalcode = cdsConObj.Address.postalCode;
        newContactObj.County_Local__c = cdsConObj.Address.county;
        
        newContactObj.Street_Latin__c = cdsConObj.Address.latinLine1;
        newContactObj.City_Latin__c = cdsConObj.Address.latinCity;

        if(!cdsConObj.phones.isEmpty()){
            newContactObj.phone=cdsConObj.phones[0].number1; 
        }

        newContactObj.Contact_Warnings__c=cdsConObj.warning;
        if(cdsConObj.denied!= null){   
            newContactObj.Denied_On_Watch_List_checkbox__c=cdsConObj.denied;
        }
        

        newContactObj.Mail_Stop__c=cdsConObj.Address.mailStop;  
        newContactObj.Mail_Stop_Latin__c=cdsConObj.Address.latinMailStop;

        newContactObj.Middle_Name__c=cdsConObj.middleName; 

        if(cdsConObj.Student!=null){
            newContactObj.Student__c=cdsConObj.Student;
        }
        newContactObj.Student_School_Name__c=cdsConObj.schoolName;
        if(cdsConObj.licensed != null){
            newContactObj.Has_Licenses__c = cdsConObj.licensed;
        }
        if(cdsConObj.exportProhibited != null){
            newContactObj.Export_Prohibited_checkbox__c = cdsConObj.exportProhibited;
        }
        newContactObj.Greeting__c = cdsConObj.greeting;
        newContactObj.Web_Profile_Status__c = cdsConObj.webprofileStatus;
        
       
       //  DL: 4/8/2016 Story 1427895  added logic to set Mathworks_Account_Email_Verified__c.   Response from CDS "webprofileEmailVerified":"Y"
        if(cdsConObj.webprofileEmailVerified!=null && cdsConObj.webprofileEmailVerified.equalsIgnoreCase('y')){
            newContactObj.Mathworks_Account_Email_Verified__c=true;
        }  // DL END Story 1427895
        
        
        if(cdsConObj.disableMerge != null){
            newContactObj.Disable_Merge__c = cdsConObj.disableMerge;
        }
        if(cdsConObj.employee != null){
            newContactObj.Employee_Flag__c = cdsConObj.employee;
        }
        newContactObj.language__c = cdsConObj.language;
        

        try{
            //Insert Contact
            insert newContactObj; 
            
            system.debug(newContactObj+'newContactObjnewContactObjnewContactObjnewContactObjnewContactObj');

            return newContactObj.id;
        }
        Catch(Exception ex){
            System.Debug('Exception in GlobalContactSearch:'+ex.getMessage()); 


            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){


                return 'ImproperDataInCDS';


            }
            else{
                 if(!isWS){
                   UtilityHelper.addErrorMessage(ex.getDMLMessage(0));
                  }
                Logger.debugException(ex);
                Logger.pop();
                
                return null;
            }
        }
    }
    
    /**
     * @author Original: ,Last Modified: kishore AN - Cloudsherpas/Mathworks
     * @date Original: , Last Modified: 08 Oct 2015
     * @description: Method to create account in sfdc from cds account details
     * revision: set the siebel territory id on account with proper field from CDS
     * KAN Added logic to bypass the dupeblocker fuzzy logic matching during account creation
     */
    public String createAccountFromCDS(CDSAccount.RootString cdsAccObj,CDSContact.Rootboolean  cdsConObj){

        Logger.push('createAccountFromCDS','GlobalContactSearchController');


        //Create new Account
        Account accObjToInsert=new Account();

        //Assigning Values from cdsAccObj
        accObjToInsert.CDS_Account_Id__c=cdsAccObj.id;
        accObjToInsert.name=cdsAccObj.name;
        accObjToInsert.Account_Name_Latin__c=cdsAccObj.latinName;
       // accObjToInsert.AccountSource=cdsAccObj.source; // As source field isn't available in CDS, it can't be used in salesforce

        if((cdsAccObj.address.stateCode)!=null ){

            if( (cdsAccObj.address.stateCode).contains('-') ){

                accObjToInsert.BillingStatecode=(cdsAccObj.address.stateCode).substringAfter('-');
                accObjToInsert.BillingCountrycode=(cdsAccObj.address.countryCode).substringBefore('-');

            }
            else
            {
                accObjToInsert.BillingStatecode=cdsAccObj.address.stateCode;
                accObjToInsert.BillingCountrycode=cdsAccObj.address.countryCode;
            }
        }
        else
        {
            accObjToInsert.BillingStatecode=cdsAccObj.address.stateCode;
            accObjToInsert.BillingCountrycode=cdsAccObj.address.countryCode;
        }

        accObjToInsert.BillingCity=cdsAccObj.address.city;
        accObjToInsert.BillingPostalCode=cdsAccObj.address.postalCode;
        accObjToInsert.BillingStreet = cdsAccObj.address.line1;
        
        accObjToInsert.County__c=cdsAccObj.address.county;
        accObjToInsert.Account_City_Latin__c = cdsAccObj.Address.latinCity;
        accObjToInsert.Account_Street_Latin__c = cdsAccObj.Address.latinLine1;

        if(cdsAccObj.siebelId != null) {
            accObjToInsert.Siebel_Account_Id__c=cdsAccObj.siebelId;
        }
        
        accObjToInsert.Siebel_Territory_ID__c = cdsAccObj.sourcePrimaryPositionId;
        accObjToInsert.industry=cdsAccObj.industry;        
        accObjToInsert.Account_Sector__c=cdsAccObj.sector;
        
        //Always set Account status Active
        accObjToInsert.Account_Status__c='Active';
        
        accObjToInsert.Account_Warning__c=cdsAccObj.warning;        
        accObjToInsert.Website = cdsAccObj.website;
        accObjToInsert.Controlled_Technology_Alert__c = cdsAccObj.controlledTechnologyAlert;
        accObjToInsert.Export_Status__c = cdsAccObj.exportStatus;
        if(cdsAccObj.denied != null){
            accObjToInsert.Denied_Company__c = cdsAccObj.denied;
        }
        if(cdsAccObj.disableMerge != null){
            accObjToInsert.disable_Merge__c = cdsAccObj.disableMerge;
        }
        if(cdsAccObj.licensed != null){
            accObjToInsert.Has_License__c = cdsAccObj.licensed;
        }
        
        //bypass the dupe blocker fuzzy matching during the creation of the account
        accObjToInsert.Bypass_Fuzzy_Matching__c = true; 

        try{
            //Insert Account
            insert accObjToInsert;

            return accObjToInsert.id;

        }
        Catch(Exception ex){

            if((ex.getMessage()).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') && !(ex.getMessage()).contains('DupeBlocker Duplicate Prevention')){


                return 'ImproperDataInCDS';

            }
            else{
                if(!isWS){
                  UtilityHelper.addErrorMessage(ex.getDMLMessage(0));
                }      
                Logger.debugException(ex);
                Logger.pop();
                return null;
            }

        }

    } 
    /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description: Method to get jason string from endpointurl
     * @param: String

     */
    public String getJasonString(String endpointUrl){

        Logger.push('getJasonString','GlobalContactSearchController');
        System.Debug('URL Endpoint:'+endpointUrl);

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

            // Set the HTTP verb to GET.
            request.setMethod('GET');

            // Send the HTTP request and get the response.
            // The response is in JSON format.
            HttpResponse response = httpProtocol.send(request);

            //Get Jason String 
            String jasonData = response.getBody();
            if(Response.getStatusCode()==200){

                //if web service call is using Email field
                if(endpointUrl.contains('email')){
                    return jasonData.substring(1, (jasonData.length())-1);
                    
                }
                else
                {
                    return jasonData;
                }
            }
            else
            {
                return 'NotFound';
            }

        }
        catch(Exception ex){
            if(!isWS){
              UtilityHelper.addErrorMessage(ex.getMessage());
            }
            System.Debug('Exception:'+ex.getMessage());
            Logger.debugException(ex);
            Logger.pop();
            return null;
        }

    }
}