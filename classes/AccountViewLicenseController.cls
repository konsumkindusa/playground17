/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   9 October 2014, Last Modified: 9 October 2014
 *@description:     this is a controller class for viewing License  on Account page.
 */
public with sharing class AccountViewLicenseController {
   
    //Boolean variable  use for rendering condition on visualforce  page
    public boolean errMsg{get;set;}
    public String licenseJsonString;
    public LicenseBean  LicenseBeanVar;
    public String setLicenseid{get;set;}
    public List<LicenseBean.License> LicenseBeanLst {get;set;}
    public List<LicenseBean.License> SelectedLicenseBeanLst {get;set;}
    public String LicenseServerError= System.Label.LicenseServerError;
    public String LicenseNotFoundForAccount = System.Label.LicenseNotFoundForAccount;
    public String LicensesNotFound = System.Label.LicensesNotFound;
    public String SeibelAccountIdNotFound = System.Label.AccounttLicMsgNoSiebelId;  
    public Map<String,List<LicenseBean.License>> mapRelatedProduct{get;set;}
    public Account acct{get;set;}
    public String acctId;
    public String url;    
    IntegrationUtilityHelper intUtilityHelper; 
    public LicenseIntegrationSetting__c integrationLicenseSettingObj;
    public String mapKeyValue{get; set;}

    //Pagination for Licenses List
    public String pageNumberToSet{get;set;} 
    public integer totalRecsOfLicense;
    public integer mod {get; set;} 
    public Integer pageIndex;
    public String pageSize;
    public Integer mapRelatedProductSize{get;set;}
    public String LicenseLimitPage;

    //For Product List
    public integer totalRecsOfProduct {get;set;} 
    public integer OffsetSize {get;set;} 
    public list<String> OverrideAccountIdLst=new  list<String>();
    public Map<String,Account> OverrideAccountIdMap{get;set;}
    public list<String> LicenseAdministratorIdLst=new  list<String>();
    public Map<String,Contact> LicenseAdministratorIdMap{get;set;} 
    public list<String> LicenseAccountIdLst=new  list<String>();
    public Map<String,Account> LicenseAccountIdMap{get;set;} 
    
     public AccountViewLicenseController(ApexPages.StandardController controller){

        integrationLicenseSettingObj = LicenseIntegrationSetting__c.getInstance();
        intUtilityHelper = new IntegrationUtilityHelper();
        url=integrationLicenseSettingObj.LicenseMWUrl__c;
        totalRecsOfLicense = 0;
        //getting LicenseLimitPage size from General setting
        LicenseLimitPage = integrationLicenseSettingObj.LicenseLimitPage__c;
        //getting Page size from General setting
        pageSize =integrationLicenseSettingObj.PageSizeForPaginationToShowLicenses__c;

        errMsg = false;
        SelectedLicenseBeanLst = new List<LicenseBean.License>();
        this.acct= (Account)controller.getRecord();
       
        OffsetSize =0;
        pageNumberToSet ='1';
        totalRecsOfLicense = 0;
        //0 based page index to calculate the page offset
        pageIndex = 0;
        
        LicenseAdministratorIdMap=new Map<String,Contact>();
        OverrideAccountIdMap=new Map<String,Account>();
        LicenseAccountIdMap=new Map<String,Account>(); 
        mapRelatedProductSize=0;

    }

    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original:   9 October 2014, Last Modified: 9 October 2014
     *@description:  This will query Contact record by id passed in url
     */

    public void getLicenseOfAccountRecord(String pageOffsetToSet){
        Logger.push('getLicenseOfAccountRecord','AccountViewLicenseController');
        try{
            List<Account> accountList = [Select id,Siebel_Account_Id__c From Account where id =:acct.id];

            if(!accountList.isempty())
                acctId = accountList[0].Siebel_Account_Id__c;

            //Checking for null value
            if(acctId != null){

                //Get contact json string from endpoint Url
                licenseJsonString = getJsonString(url+'?accountId='+acctId,pageOffsetToSet);
                //Get jason string into searilized list
                if(licenseJsonString != null && licenseJsonString!='NotFound'){
                    LicenseBeanVar = LicenseBean.getParsedLicenseJson(licenseJsonString);
                    //Set Total Number of Records
                    totalRecsOfLicense = LicenseBeanVar.totalNumber;
                    //calculate the number of pages count
                    mod = (Integer)Math.floor((Double)totalRecsOfLicense/ (Double)Integer.valueOf(pageSize));
                    
                    //check to see if the number of pages returned are correct as we use the math.floor
                    if(totalRecsOfLicense >  (mod * Integer.valueOf(pageSize)))
                        mod += 1;
                   
                    LicenseBeanLst = LicenseBeanVar.licenses;
                    // Fill Map
                    mapRelatedProduct=new Map<String,List<LicenseBean.License>>();
                        
                    for(LicenseBean.License licenseobj :LicenseBeanLst){
                    
                       If(licenseobj.overrideAccountId!=null){ 
                            OverrideAccountIdLst.add(licenseobj.overrideAccountId);
                            LicenseAdministratorIdLst.add(licenseobj.administratorId);
                            LicenseAccountIdLst.add(licenseobj.licenseAccountId);
                        }

                        if(!mapRelatedProduct.containsKey(licenseobj.Id))
                            mapRelatedProduct.put(licenseobj.Id,new List<LicenseBean.License>{licenseobj});
                        else
                             mapRelatedProduct.get(licenseobj.id).add(licenseobj);
                        
                    }
                    mapRelatedProductSize=mapRelatedProduct.size();
                     //Fill map to get account ids having Override Account Id as siebel account id  
                    For(Account accObj:[select id,Siebel_Account_Id__c,name,Account_Name_Latin__c from account where Siebel_Account_Id__c in:OverrideAccountIdLst])
                              OverrideAccountIdMap.put(accObj.Siebel_Account_Id__c,accObj);
                    
                    //Fill map to get account ids having Lisence Account Id as siebel account id  
                    For(Account accObj:[select id,Siebel_Account_Id__c,name,Account_Name_Latin__c from account where Siebel_Account_Id__c in:LicenseAccountIdLst])
                              LicenseAccountIdMap.put(accObj.Siebel_Account_Id__c,accObj);
                 
                    //Fill map to get Contact ids having Administrator Id as sibel contact id  
                    For(Contact conObj:[select id,lastname,Siebel_Contact_Id__c,name, First_Name_Latin__c, Last_Name_Latin__c  from Contact where Siebel_Contact_Id__c in:LicenseAdministratorIdLst])
                              LicenseAdministratorIdMap.put(conObj.Siebel_Contact_Id__c,conObj);
                    
                     //Fill map With OverrideAccountIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String overrideAccountIdKey: OverrideAccountIdLst){
                        if(!OverrideAccountIdMap.containskey(overrideAccountIdKey)){
                         OverrideAccountIdMap.put(overrideAccountIdKey,new Account(name='DummyAccount'));
                         
                         }
                    }
                     
                    //Fill map With LicenseAccountIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String lisenceAccountIdKey: LicenseAccountIdLst){
                        if(!LicenseAccountIdMap.containskey(lisenceAccountIdKey))
                         LicenseAccountIdMap.put(lisenceAccountIdKey,new Account(name='DummyAccount'));
                         
                    }
                    
                    //Fill map With  LicenseAdministratorIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String administratorIdKey: LicenseAdministratorIdLst){
                        if(!LicenseAdministratorIdMap.containskey(administratorIdKey))
                         LicenseAdministratorIdMap.put(administratorIdKey,new contact(lastName='DummyContact') );
                         
                    }
               
                    if(LicenseBeanVar == null ) {
                       
                        errMsg = true;
                        UtilityHelper.addErrorMessage(LicenseNotFoundForAccount);
                    }
                }
                else{
                     errMsg = true;
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, LicenseNotFoundForAccount));
               }
            }//if
            else{
                errMSg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, SeibelAccountIdNotFound));                                
            }
           
        }
        catch(Exception ex){

            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'For AccountId'+acct.id);
            Logger.pop();
        }
        Logger.pop();
     
    }

    /**
     * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Kishore AN - Cloud Sherpas/Mathworks
     * @date Original: , Last Modified: 12 Nov 2015
     * @description: Method to get json string from endpointurl
     * @param: String

     */
    public String getJsonString(String endpointUrl,String pageOffsetToSet){
        Logger.push('getJsonString','AccountViewLicenseController');
        try{

            Http httpProtocol = new Http();
            //Create a Http request
            HttpRequest request = new HttpRequest();
            //set ClientCertificate if this code is not running in a test
            //this keeps the tests environment agnostic and the mock callouts do not need a certificate
            if(!Test.isRunningTest()){
                request.setClientCertificateName(intUtilityHelper.getCACertIntegration());
            }
            //set callerId
            request.setHeader('X_MW_WS_callerId',intUtilityHelper.getCallerId());
            //set securityToken
            request.setHeader('X_MW_WS_securityToken',intUtilityHelper.getBusinessServiceToken());
            //set Offset
            request.setHeader('X_MW_WS_offset',pageOffsetToSet);
            //set limit 
            request.setHeader('X_MW_WS_limit',LicenseLimitPage);
            // Set the endpoint URL.
            request.setEndPoint(endpointUrl);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            //Set the timeout
            request.setTimeout(intUtilityHelper.getTimeout());
            //send the Http request and get responce in Json format
            HttpResponse response = httpProtocol.send(request);
            //get the Json String
            String jsonData;
            if(Response.getStatusCode()==200 && !response.getBody().Contains('No results found for')) {
                jsonData = response.getBody();                
                return jsonData;
            }
            else if (Response.getStatusCode()==408) {
                return LicenseNotFoundForAccount;
            }
            else { 
                return LicensesNotFound;
            }

        }
        catch(Exception ex){
            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'For AccountId'+acct.id);
            Logger.pop();
            return null;

        }
    }

    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original:   9 October 2014, Last Modified: 9 October 2014
     *@description:   It will get  the selected product from list 
     */
    public void showRelatedProducts(){
        Logger.push('showRelatedProducts','AccountViewLicenseController');
        try{
        ApexPages.getMessages().clear();
        if(!Test.isRunningtest()){
            setLicenseid= System.currentPagereference().getParameters().get('relatedProductId');
        }
      
        SelectedLicenseBeanLst.clear();
        //Get selected License on Page
        for(LicenseBean.License licensesObj:LicenseBeanLst){

            if(licensesObj.id==setLicenseid){

                SelectedLicenseBeanLst.add(licensesObj);

            }

        }
        }
        catch(Exception ex){
            errMsg = true;
            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'For AccountId'+acct.id);
            Logger.pop();
           
         }

    }


    public void getLicenseOfRelatedAccount(){
        //get the licenses starting with 0 offset
        getLicenseOfAccountRecord('0');
    }

    //Pagination for licences
    public void FirstPage(){

        pageNumberToSet='1';
        pageIndex = 0;
        getLicenseOfAccountRecord(String.valueOf(pageIndex));
    }
 
    public void previous(){

        pageNumberToSet=String.valueOf((Integer.valueOf(pageNumberToSet) -1));
        pageIndex  = pageIndex -1;
        if(pageIndex < 0)
            pageIndex = 0;
        Integer offset = pageIndex * Integer.valueOf(pageSize);
        getLicenseOfAccountRecord(String.valueOf(offset));
    }
  
    public void next(){

        pageNumberToSet = String.valueOf((Integer.valueOf(pageNumberToSet) + 1));
        pageIndex = pageIndex + 1;
        Integer offset = pageIndex * Integer.valueOf(pageSize);
        if(offset == totalRecsOfLicense)
            offset = offset - Integer.valueOf(pageSize); 
        getLicenseOfAccountRecord(String.valueOf(offset));
    }

    public void LastPage(){

        pageNumberToSet = String.valueOf(mod);
        pageIndex = mod;
        Integer offset = pageIndex*Integer.valueOf(pageSize);
        if(offset >= totalRecsOfLicense){
            offset = offset - Integer.valueOf(pageSize);
            pageIndex = pageIndex - 1;
        } 
        getLicenseOfAccountRecord(String.valueOf(offset));
    }

    public boolean getprevOfLicense(){

        return pageNumberToSet == '1';
    }
    public boolean getnxtOfLicense(){

        return Integer.valueOf(pageNumberToSet)== mod;
    }

    public Integer getCurrentPageNumber(){
        return Integer.ValueOf(pageNumberToSet) ;
    }

    public Integer getTotalPages(){
        //mod is calculated as the floor of total licenses/pagesize as the page index starts from 0.
        if(mod!=0){ 
            return mod ;
        }
        else{
            return mod + 1 ;
        }

    }

     public boolean getMapKeyFound(){

          ApexPages.getMessages().clear();
          mapKeyValue= System.currentPagereference().getParameters().get('mapKey');
          return LicenseAdministratorIdMap.containsKey(mapKeyValue);

    }
}