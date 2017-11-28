/**
*@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks, Faina Gorelik - MathWorks AtTask 1589562 , Faina Gorelik 
*@date Original:   05 feb 2016, Last Modified: 05 feb 2016, 22 July 2016
*@description:     this is a controller class for viewing PublishTMRulesViewPage settings page.
*/
public with sharing class PublishTMRulesViewPageController {
    
    public Territory_Management_Settings__c settings {get;set;}
    public Territory_Publish_Rule__c terrpublished {get;set;}//fg
    public Boolean isDisabled{get;set;}
    //used to post http call to cds territory assignment rules publishing job
    public String STerrorMessage=System.Label.SecurityTokenNotFoundMessage; 
    public IntegrationUtilityHelper intHelper; 
    public string bToken; 
    public string url;
    public integer returnresponse;
    public integer pid;
    public Territory_Settings__c territorysettings;
    public string Status = '';// set status based on the json response
    BodiServiceUtilityClass.Rootboolean bodiServiceResponse;
    
    
    public PublishTMRulesViewPageController (ApexPages.StandardController controller) {
        
        settings = Territory_Management_Settings__c.getInstance(UserInfo.getOrganizationId());
        string UniqueIdentifier;
        UniqueIdentifier = settings.Unique_Record__c;
        terrpublished = [SELECT Pending_Rule_Publish__c,Rules_Last_Published_By__c,Rules_Last_Published_On__c,Rule_Identifier__c FROM Territory_Publish_Rule__c WHERE Rule_Identifier__c =:UniqueIdentifier LIMIT 1];
        if (terrpublished.Pending_Rule_Publish__c != 'COMPLETE' && terrpublished.Pending_Rule_Publish__c != 'ERROR'){
            isDisabled = true;
        }
        
    }    
    /**
*@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks, Faina Gorelik - MathWorks
*@date Original:   09 feb 2016, Last Modified: 09 feb 2016, 22 July 2016
*@description:     this is a save method for upsert operation for Publish TM Rules custom settings. 
*/
    public void save(){
        Logger.push('save','PublishTMRulesViewPageController');
        string UniqueIdentifier;
        isDisabled = true;
        
        //new -  Post request for BODI to publish the assignment rule. 
        territorysettings = Territory_Settings__c.getInstance();
        url = territorysettings.Publish_Territory_Assignment_URL__c;// get base url 
        intHelper=new IntegrationUtilityHelper ();
        try{
            bToken=intHelper.getBusinessServiceToken(); 
            System.debug('Get business token' + bToken);
        }
        catch(Exception e){
            Logger.debugException(System.Label.Response_Error +' Get Business Security Tokens '+ e.getMessage());// workflow will trigger Email Alert to be sent to sfdcsupport
        }
        //now build json string to parse the response
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();  
        //set ClientCertificate if this code is not running in a test
        //this keeps the tests environment agnostic and the mock callouts do not need a certificate
        if(!Test.isRunningTest()){
            request.setClientCertificateName(intHelper.getCACertIntegration());
        }
        //set Organization Id in request header
        request.setHeader('OrganizationID', UserInfo.getOrganizationId());
        //set business tokens in request header
        request.setHeader('X_MW_WS_securityToken', bToken);
        request.setMethod('POST');
  		request.setHeader('Content-Type', 'application/json');
        //request set Body as json object , will remove repoName after Doug fix bodi access issue since repo name is not required and we will pass empty parameter
      //  request.setBody('{ "jobName" : "job_CDS_Get_SFDC_TerritoryInfo", "repoName" : "bodiAppSabboud", "jobSystemProfile"  : "" }');
      request.setBody('{ "jobName" : "job_CDS_Get_SFDC_TerritoryInfo", "repoName" : "", "jobSystemProfile"  : "" }');
        request.setEndpoint(url);
        request.setTimeout(20000);
        HttpResponse response = httpProtocol.send(request);
        String jsonData = response.getBody();
        
        // handle BODI Service response code 
        returnresponse = response.getStatusCode();
        //  returnresponse = 201;// used for debugging only 
        if (returnresponse !=201){
            // return error http call failed log error message and send email alert
            isDisabled = false;// don't disable the button as user might try again
            Status ='ERROR';
            Logger.debugException(system.Label.Response_Error + '.Could not get valid response. Response Status code: '+ returnresponse);
            Logger.pop();
        }
        else{
            /* used for testing only
            jsonData = '{"pid": -1,"cid": -1,"rid": -1,"repoName": "bodiAppTest","returnCode": null,"errorMessage": "User bodiwrapper does not have full access control on repository bodiAppTest. "}';
            jsonData ='{"pid": 19516, "cid": 24424, "rid": 134, "repoName": "bodiAppSabboud", "returnCode": null, "errorMessage": "" }';*/
            // parse json response
            bodiServiceResponse = BodiServiceUtilityClass.getParsedBodiServiceJson(jsonData);  
            pid = bodiServiceResponse.pid;
            
            if (pid < 1){
                // was able to get the valid response by bodi didnt' run the job due to the different issue. 
                isDisabled = false;// don't disable the button as user might try again
                Status = 'ERROR';
                Logger.debugException(system.Label.Response_Return_Error + ' ' + bodiServiceResponse.errorMessage +' '+'BODI json response pid'+ pid);
                Logger.pop();
            }
            else{// valid response request, BODI service is running
                
                Status ='REQUESTED';
                isDisabled = true; // disable button till job status becomes completed , status updated by BODI running user
            }
        }
        //end new
        
        UniqueIdentifier = settings.Unique_Record__c;
        //get the logged in user Id
        Id userId = UserInfo.getUserId();
        //terrpublished.Pending_Rule_Publish__c= 'REQUESTED'; // fg set to requested after object has been updated
        terrpublished.Pending_Rule_Publish__c= Status; // fg set to requested after object has been updated
        terrpublished.Rule_Identifier__c =  UniqueIdentifier;
        terrpublished.Rules_Last_Published_By__c = userId;
        terrpublished.Rules_Last_Published_On__c = DateTime.now();
        try{
            //perform Dml Operation
            upsert terrpublished;
            Logger.pop();
        }
        catch(Exception ex){
            Logger.debugException('Publish Assignment Rules Error. '+ ex.getMessage()+'Territory Management Settings Dml Operation ');
            Logger.pop();
        }
        
    }
    
    /**
*@author Original: Faina Gorelik - MathWorks
*@date Original:   22 July 2016
*@description:     the method invokes the refresh page and enable or keep disable publish button based on the running assignment status
*/
    public void refresh(){
        
        settings = Territory_Management_Settings__c.getInstance(UserInfo.getOrganizationId());
        string UniqueIdentifier;
        UniqueIdentifier = settings.Unique_Record__c;
        terrpublished = [SELECT Pending_Rule_Publish__c,Rules_Last_Published_By__c,Rules_Last_Published_On__c,Rule_Identifier__c FROM Territory_Publish_Rule__c WHERE Rule_Identifier__c =:UniqueIdentifier LIMIT 1];
        if (terrpublished.Pending_Rule_Publish__c =='COMPLETE' || terrpublished.Pending_Rule_Publish__c =='ERROR'){
            isDisabled = false;
        }
        PageReference RetPage = ApexPages.currentPage();
        
    }
    
}