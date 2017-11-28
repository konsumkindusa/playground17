/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   18 Feb 2015, Last Modified: 18 Feb 2015
 *@description:     This is a controller class for viewing License lookup  page.
 */
public with sharing class LicenseLookupController{
    public String licenseJsonString;
    public String licenseID{get;set;}
    public LicenseBean  LicenseBeanVar{get;set;}
    public boolean isError{get; set;} 
    public boolean errMsg{get;set;}
    public boolean showDetails{get; set;} 
    IntegrationUtilityHelper intUtilityHelper; 
    public String pageSize ;
    public List<LicenseBean.License> LicenseBeanLst {get;set;}
    public String url;
    //List
    list<String> LicenseAccountIdLst=new  list<String>();
    //Maps for Drill Downs
    public  Map<String,Account> OverrideAccountIdMap{get;set;}
    public  Map<String,Contact> LicenseAdministratorIdMap{get;set;} 
    public  Map<String,Account> LicenseAccountIdMap{get;set;} 
    //labels
      public String licenseHelpText = System.Label.License_Lookup_Help_Text;
      public String licenseNotFound = System.Label.License_Lokkup_Not_Found;
      public String LicenseServerError= System.Label.LicenseServerError;
    //custom Settings
    public static  LicenseIntegrationSetting__c integrationLicenseSettingObj;
    public String licenseLookupId;
     public boolean showLookupInput{get; set;} 
    
    public LicenseLookupController(ApexPages.StandardController  controller){
   
        intUtilityHelper = new IntegrationUtilityHelper();
        integrationLicenseSettingObj = LicenseIntegrationSetting__c.getInstance();
        url=integrationLicenseSettingObj.LicenseMWUrl__c;
        pageSize = integrationLicenseSettingObj.PageSizeForPaginationToShowLicenses__c;
        showLookupInput=true;
        showDetails=false;
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original:   18 Feb 2015, Last Modified: 18 Feb 2015
     *@description:  This will show the license Information by passing License Id.
     */
    public Pagereference viewLicenses(){
        Logger.push('viewLicenses','LicenseLookupController');

        
        try{
             licenseLookupId= ApexPages.currentPage().getParameters().get('licenseID');
        if(licenseLookupId!=null && licenseLookupId.length()!=0 && ApexPages.currentPage().getParameters().get('showDetails')=='true'){
           
            //showLookupInput=false; 
            isError=false;
           //Get license json string from endpoint Url
                licenseJsonString = getJsonString(url+'/'+licenseLookupId);
                
                system.debug(licenseJsonString +'licenseJsonString licenseJsonString licenseJsonString ');
                  //licenseJsonString = '{"totalNumber":1,"licenses":[{"id":149544,"licenseAccountId":"1-G8I9","overrideAccountId":"1-G8I9","administratorId":"1-1O95QL","option":"Concurrent","use":"Commercial","term":"Perpetual","status":"Active","coreProductEndDate":"2015-08-01 00:00:00.0","prorateDate":"2015-08-01 00:00:00.0","maintenanceGroupId":6376,"licensedProducts":[{"productId":13,"productName":"Communications System Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":17,"productName":"Control System Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2008-08-01 00:00:00.0"},{"productId":17,"productName":"Control System Toolbox","quantity":3,"allocationStatus":"Unallocated","maintenanceEndDate":"2009-08-01 00:00:00.0"},{"productId":17,"productName":"Control System Toolbox","quantity":4,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":43,"productName":"Database Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":45,"productName":"DSP System Toolbox","quantity":7,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":55,"productName":"Extended Symbolic Math Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2008-08-01 00:00:00.0"},{"productId":65,"productName":"Simulink Fixed Point","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2013-08-01 00:00:00.0"},{"productId":86,"productName":"Image Processing Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2009-02-01 00:00:00.0"},{"productId":86,"productName":"Image Processing Toolbox","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":103,"productName":"MATLAB","quantity":55,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":124,"productName":"MATLAB C/C++ Math Library","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2003-08-01 00:00:00.0"},{"productId":126,"productName":"MATLAB Compiler","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":147,"productName":"Mu-Analysis and Synthesis Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2006-08-01 00:00:00.0"},{"productId":162,"productName":"Neural Network Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":174,"productName":"Simulink Response Optimization","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2009-08-01 00:00:00.0"},{"productId":182,"productName":"Optimization Toolbox","quantity":4,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":196,"productName":"Partial Differential Equation Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":208,"productName":"Simulink Coder","quantity":4,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":218,"productName":"Robust Control Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2009-08-01 00:00:00.0"},{"productId":218,"productName":"Robust Control Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":237,"productName":"Signal Processing Toolbox","quantity":17,"allocationStatus":"Unallocated","maintenanceEndDate":"2008-08-01 00:00:00.0"},{"productId":237,"productName":"Signal Processing Toolbox","quantity":17,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":259,"productName":"Simulink","quantity":8,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":309,"productName":"Stateflow","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":315,"productName":"Statistics Toolbox","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":332,"productName":"Symbolic Math Toolbox","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":341,"productName":"System Identification Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2008-08-01 00:00:00.0"},{"productId":341,"productName":"System Identification Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":2044,"productName":"Data Acquisition Toolbox","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":2050,"productName":"MATLAB Report Generator","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":2052,"productName":"Simulink Report Generator","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":2489,"productName":"Filter Design Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2011-08-01 00:00:00.0"},{"productId":2679,"productName":"Simulink Real-Time","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2008-08-01 00:00:00.0"},{"productId":2679,"productName":"Simulink Real-Time","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":2863,"productName":"Communications Blockset","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2011-08-01 00:00:00.0"},{"productId":2877,"productName":"Instrument Control Toolbox","quantity":4,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":3051,"productName":"Embedded Coder","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":3996,"productName":"SimMechanics","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":5104,"productName":"Image Acquisition Toolbox","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":5241,"productName":"Simulink Control Design","quantity":5,"allocationStatus":"Unallocated","maintenanceEndDate":"2008-08-01 00:00:00.0"},{"productId":5241,"productName":"Simulink Control Design","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":5979,"productName":"Simulink Verification and Validation","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":5996,"productName":"Fixed-Point Designer","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":6341,"productName":"Computer Vision System Toolbox","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":6739,"productName":"Parallel Computing Toolbox","quantity":2,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":8359,"productName":"Simscape","quantity":3,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":9925,"productName":"Simulink Design Optimization","quantity":1,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"},{"productId":11029,"productName":"MATLAB Coder","quantity":4,"allocationStatus":"Unallocated","maintenanceEndDate":"2015-08-01 00:00:00.0"}]}]} ';
               //Get jason string into searilized list
            if(licenseJsonString !='NotFound'){
                 LicenseBeanVar = LicenseBean.getParsedLicenseJson(licenseJsonString);
                 showDetails=true;
                 LicenseBeanLst = LicenseBeanVar.licenses;
                              //Build maps for showing drilldowns 
                LicenseUtilityHelper.BuildDrilldownMaps(LicenseBeanLst);
                //Get Maps From LicenseUtilityHelper
                OverrideAccountIdMap = LicenseUtilityHelper.getOverrideAccountIdMap();
                LicenseAdministratorIdMap = LicenseUtilityHelper.getLicenseAdministratorIdMap();
                LicenseAccountIdMap = LicenseUtilityHelper.getLicenseAccountIdMap();
            } 
              else{
                    showDetails=false;
                    isError=true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, licenseNotFound));
                    return null;

                }
            
               
        }
            
        
    }
    catch(Exception ex){
            isError=true;
            UtilityHelper.addErrorMessage(LicenseServerError);
            Logger.debugException(ex.getMessage()+'LicenseId'+licenseID);
            Logger.pop();
            return null;
        }
        
        return null;
    }
     /**
     * @author Original: Sagar Talele
     * @date Original: , Last Modified: Sagar Talele
     * @description: Method to get json string from endpointurl
     * @param: String

     */
    public String getJsonString(String endpointUrl){
        Logger.push('getJsonString','LicenseLookupController');
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
            request.setHeader('X_MW_WS_offset','10');
            //System.debug('page Off set:'+pageOffsetToSet);
            request.setHeader('OrganizationID', UserInfo.getOrganizationId());
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
                return 'License Not Found';
            }
            else { 
                return 'NotFound';
            }

        }
        catch(Exception ex){
            UtilityHelper.addErrorMessage('');
            Logger.debugException(ex.getMessage()+'For licenseId');
            Logger.pop();
            return null;

        }        
        
    }
    public PageReference hideLicenseDetailSection(){

        //showDetails=false;
        isError=false;
        return null; 

    }
    
}