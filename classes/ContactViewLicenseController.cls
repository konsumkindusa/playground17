/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   9 October 2014, Last Modified: 9 October 2014
 *@description:     This is a controller class for viewing License  on contact page.
 */
public with sharing class ContactViewLicenseController {

    //Boolean variable  use for rendering condition on visualforce  page
    public boolean errMsg{get;set;}
    public String licenseJsonString;
    public LicenseBean  LicenseBeanVar;
    public String setLicenseid{get;set;}
    public List<LicenseBean.License> LicenseBeanLst {get;set;}
    public List<LicenseBean.License> SelectedLicenseBeanLst {get;set;}
    public String mapKeyValue{get; set;}
   
    public String LicenseServerError= System.Label.LicenseServerError;
    public String LicenseNotFoundForContact = System.Label.LicenseNotFoundForContact;
    public String LicensesNotFound = System.Label.LicensesNotFound;
    public String SeibelContactIdNotFound = System.Label.ContactLicMsgNoSiebelId;    
    public Map<String,List<LicenseBean.License>> mapRelatedProduct{get;set;}
    
    public Contact cont {get;set;}
    public String contId;
    public String url;
    IntegrationUtilityHelper intUtilityHelper; 
    public static  LicenseIntegrationSetting__c integrationLicenseSettingObj;
    //Pagination for Licenses List
    public String pageNumberToSet{get;set;} 
    public integer totalRecsOfLicense;
    public integer mod {get; set;} 
    public String pageSize;
    public Integer pageIndex;
    //For Product List
    public integer totalRecsOfProduct {get;set;} 
    public integer OffsetSize {get;set;} 
    public list<String> OverrideAccountIdLst=new  list<String>();
    public Map<String,Account> OverrideAccountIdMap{get;set;}
    public list<String> LicenseAdministratorIdLst=new  list<String>();
    public Map<String,Contact> LicenseAdministratorIdMap{get;set;} 
    public list<String> LicenseAccountIdLst=new  list<String>();
    public Map<String,Account> LicenseAccountIdMap{get;set;} 
    public Integer mapRelatedProductSize{get;set;}

    public ContactViewLicenseController(ApexPages.StandardController controller){
        integrationLicenseSettingObj = LicenseIntegrationSetting__c.getInstance();
        intUtilityHelper = new IntegrationUtilityHelper();
        url=integrationLicenseSettingObj.LicenseMWUrl__c;
        //getting pageSize from LicenseIntegrationSetting setting
        pageSize = integrationLicenseSettingObj.PageSizeForPaginationToShowLicenses__c;
        errMsg = false;
        this.cont = (Contact)controller.getRecord();
        OffsetSize =0;
        pageNumberToSet ='1';
        totalRecsOfLicense = 0;
        //0 based page index to calculate the page offset
        pageIndex = 0;
        mapRelatedProductSize=0;
        SelectedLicenseBeanLst = new List<LicenseBean.License>();

        LicenseAdministratorIdMap=new Map<String,Contact>();
        OverrideAccountIdMap=new Map<String,Account>();
        LicenseAccountIdMap=new Map<String,Account>(); 

    }

    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original:   9 October 2014, Last Modified: 9 October 2014
     *@description:  This will query Contact record by id passed in url
     */

    public Pagereference getLicenseOfContactRecord(String pageOffsetToSet){
        Logger.push('getLicenseOfContactRecord','ContactViewLicenseController');
        try{
            List<Contact> conts = [Select id,Siebel_Contact_Id__c From Contact where id =:cont.id];

            if(!conts.isempty())
                contId = conts[0].Siebel_Contact_Id__c;
            
            //Checking for null value
            if(contId!= null){

                //Get contact json string from endpoint Url
                licenseJsonString = getJsonString(url+'?contactId='+contId,pageOffsetToSet);
                
                //Get jason string into searilized list
                if(licenseJsonString != null&& licenseJsonString!='NotFound'){

                LicenseBeanVar = LicenseBean.getParsedLicenseJson(licenseJsonString);
                //Set Total Number of Records
                totalRecsOfLicense = LicenseBeanVar.totalNumber;
                //calculate the number of pages count
                mod = (Integer)Math.floor((Double)totalRecsOfLicense/ (Double)Integer.valueOf(pageSize));
                    
                //check to see if the number of pages returned are correct as we use the math.floor
                if(totalRecsOfLicense >  (mod * Integer.valueOf(pageSize)))
                    mod += 1;
                    
                System.Debug('Total number of pages:'+mod);
                LicenseBeanLst = LicenseBeanVar.licenses;
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
                    For(Account accObj:[select id,Siebel_Account_Id__c,name,Account_Name_Latin__c from account where Siebel_Account_Id__c in:OverrideAccountIdLst]){

                        OverrideAccountIdMap.put(accObj.Siebel_Account_Id__c,accObj);
                    }

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
                        if(!LicenseAccountIdMap.containskey(lisenceAccountIdKey)){
                         LicenseAccountIdMap.put(lisenceAccountIdKey,new Account(name='DummyAccount'));
                         }
                    }
                    
                    //Fill map With  LicenseAdministratorIdLst Keys with Null Values so we can not get Map Key Not Found 
                    For(String administratorIdKey: LicenseAdministratorIdLst){
                        if(!LicenseAdministratorIdMap.containskey(administratorIdKey)){
                         LicenseAdministratorIdMap.put(administratorIdKey,new contact(lastName='DummyContact') );
                         }
                    }
                    
                   
                    if(LicenseBeanLst.size()==0) {
                        errMsg = true;
                        UtilityHelper.addErrorMessage(LicenseNotFoundForContact);
                        return null;
                    }
                }
                else{
                    errMsg = true;
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, LicenseNotFoundForContact));
                    return null;

                }
            }
            else{
                errMSg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, SeibelContactIdNotFound));
                return null;                
            }

        }
        catch(Exception ex){
            errMsg = true;
            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'ContactId'+cont.id);
            Logger.pop();
            return null;
        }
        Logger.pop();
        return null;

    }

    /**
     * @author Original: Sagar Talele
     * @date Original: , Last Modified: Sagar Talele
     * @description: Method to get json string from endpointurl
     * @param: String

     */
    public String getJsonString(String endpointUrl,String pageOffsetToSet){
        Logger.push('getJsonString','ContactViewLicenseController');
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
            System.debug('page Off set:'+pageOffsetToSet);
           //set limit 
            request.setHeader('X_MW_WS_limit',pageSize);            
            // Set the endpoint URL.
            request.setEndPoint(endpointUrl);
            // Set the Timeout 
             request.setTimeout(20000);
            // Set the HTTP verb to GET.
            request.setMethod('GET');
            //send the Http request and get responce in Json format
            HttpResponse response = httpProtocol.send(request);
            //get the Json String
            String jsonData;
            if(Response.getStatusCode()==200 && !response.getBody().Contains('No results found for')) {
                jsonData = response.getBody();                                
                return jsonData;
            }
            else if (Response.getStatusCode()==408) {
                return LicenseNotFoundForContact;
            }
            else { 
                return LicensesNotFound;
            }

        }
        catch(Exception ex){
            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'For ContactId'+cont.id);
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
         Logger.push('showRelatedProducts','ContactViewLicenseController');
        try{
        
        ApexPages.getMessages().clear();

        if(!Test.isRunningtest()){
            setLicenseid= System.currentPagereference().getParameters().get('relatedLicenseId');
        }
        OffsetSize =0;
        totalRecsOfProduct = mapRelatedProduct.get(setLicenseid)[0].licensedProducts.size() ;
        SelectedLicenseBeanLst.clear();
        //Get selected Licenses on Page
        for(LicenseBean.License licensesObj:LicenseBeanLst){

            if(licensesObj.id==setLicenseid)
                  SelectedLicenseBeanLst.add(licensesObj);
        }
        }
         catch(Exception ex){
            errMsg = true;
            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'For ContactId'+cont.id);
            Logger.pop();
           
         }

    }

    public Pagereference getLicenseOfRelatedContact(){
        //get the licenses starting from 0 offset
        getLicenseOfContactRecord('0');
        return null;
    }

    //Pagination for licences
    public void FirstPage(){

        pageNumberToSet='1';
        pageIndex = 0;
        //getLicenseOfContactRecord(String.valueOf((Integer.valueOf(pageNumberToSet) -1)));
        getLicenseOfContactRecord(String.valueOf(pageIndex));
    }
    public void previous(){

        pageNumberToSet=String.valueOf((Integer.valueOf(pageNumberToSet) -1));
        pageIndex = pageIndex - 1;
        if(pageIndex < 0)
            pageIndex = 0;
        Integer offset = pageIndex*Integer.valueOf(pageSize);       
        getLicenseOfContactRecord(String.valueOf(offset));
    }

    public void next(){

        pageNumberToSet = String.valueOf((Integer.valueOf(pageNumberToSet) + 1));
        pageIndex = pageindex + 1;
        Integer offset = pageIndex * Integer.valueOf(pageSize);
        if(offset == totalRecsOfLicense)
            offset = offset - Integer.valueOf(pageSize);        
        getLicenseOfContactRecord(String.valueOf(offset));
    }

    public void LastPage(){        
        pageNumberToSet = String.valueOf(mod);
        pageIndex = mod;
        Integer offset = pageIndex * Integer.valueOf(pageSize);
        if(offset >= totalRecsOfLicense){
            offset = offset - Integer.valueOf(pageSize);
            pageIndex = pageIndex - 1;
        }

        getLicenseOfContactRecord(String.valueOf(offset));
    }

    public boolean getprevOfLicense(){

        return pageNumberToSet == '1';
                            
    }
    public boolean getnxtOfLicense(){

          return Integer.valueOf(pageNumberToSet)== mod;
    }
  
    public Integer getCurrentPageNumber(){


        return Integer.ValueOf(pageNumberToSet);

    }

    public Integer getTotalPages(){
        //mod is calculated as the floor of total licenses/pagesize as the page index starts from 0.
        if(mod!=0) 
            return mod ;
        else
            return mod + 1 ;
   }
   
   public boolean getMapKeyFound(){

          ApexPages.getMessages().clear();
          mapKeyValue= System.currentPagereference().getParameters().get('mapKey');
          return LicenseAdministratorIdMap.containsKey(mapKeyValue);
    }
   
}