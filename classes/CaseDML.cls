/**
 * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks, Faina Gorelik - MathWorks; 
 * @author modified: Krishna Bhaskarla; Date: 10 Dec 2013; Method: checkOnSupport; DESC: Configured CA cert and OrganizationID in HTTP headers; gID:1019977
 * @author modified: Shweta Shanbhag;Date: 01/07/2014; Method: CloseOpenTasks; G1017545, Faina Gorelik : 13 July 2016 AtTask 1511713 , Faina Gorelik : 22 March 1975447
 * @author modified: Archana Lohar;Date: 27/11/2014; Method: updateCaseAccount, Faina Gorelik Method : OnSupport future REST API
 * @date Original: 03 June 2013, Last Modified: 19 April 2016,
 * @description Class to handle delegated DML operations for Case object.
 * @Revision Archana Lohar|27 Nov 2014|Added code to check if new Account to update on case is not same to old one in updateCaseAccount
 * @Revision Archana Lohar|15 May 2015|Added code to Update forward to distributor to true
 * @Revision Archana Lohar|19 April 2016|Modified closeTaskStatusForCloseCase method to reduce CPU time
 * @Revision Faina Gorelik||6 June- July 2016||Modified OnSupport Logic to replace MWSB with REST API
 */
public class CaseDML {

    /**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: kishore - Cloud Sherpas, Faina Gorelik - MathWorks
* @date Original: 04 June 2013, Last Modified: 05 May 2015, 29 June 2016
* @description method that updates On Support fields by calling a WebService callout from Mathwroks
* @param Set_CaseID collection of Case record Ids
* @Revision - Added limit to the query, fg - add custom Logger to the methods where it was missing: OnSupport ,updateCaseEmailTemplateInfo,updateCaseArea,UpdateCaseProductFields, inside on support business security tokens, http request

* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 11 June 2013, Last Modified: 26 June 2013
* @description method that updates Case Area and Email template info fields with values of Case Owner's Area and Email template info fields 
* @param List_Cases collection of Case records
**/

    String url;
    
    @future (callout=true)
    
    public static void checkOnSupport (set <Id> Set_CaseID){
        
    Logger.push('checkOnSupport','CaseDml');
        
    // get case records to be updated
    General_Settings__c settings ;
    String url;
    String STerrorMessage=System.Label.SecurityTokenNotFoundMessage;
    IntegrationUtilityHelper intHelper;
    string bToken;
    String supportJsonString;
    String strCallerId ='Salesforce';
    OnSupportUtilityClass.Rootboolean onSupportResponse;
    //variables mapped to json response
    String cdsAccountId = '';// 
    String errorresponse = ''; // invalid response code 404
    String LicenseAcctId = '';
    String LicenseUse = '';
    String onSupportReason = '';
    String onSupportEligibleTrue = System.Label.On_Support_Eligible_True;
    String onSupportEligibleFalse = System.Label.On_Support_Eligible_False;
    String onSupportLicenseUnknown = System.Label.OnSupportLicenseUnknown;
    String onSupportLicenseNotFound = System.Label.On_Support_License_Not_Found;
    intHelper=new IntegrationUtilityHelper();     
 
        // retrieve cases to be updated 
        list <Case> caselist = [select id, License__c, Product_Base_Code__c from Case where Id in : Set_CaseID];
        for (Case cse : caselist){
            if (cse.License__c !=null){
                //fetch general setting instance
                settings = General_Settings__c.getInstance();
                //Getting url from General setting
                url = settings.OnSupportURL__c;
                //Get Business Security token from IntegrationUtilityHelper log error message 
                try{
                    bToken=intHelper.getBusinessServiceToken();
                    // test business token service
                    System.Debug('@BusinessSecurityTokens:'+bToken);
                    
                }
                catch (System.DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        //capture Dml  Process exception 
                        Logger.debugException('DmlException On Support Get Business Security Tokens:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                    }
                }
                //now build json string to parse the response
                  Http httpProtocol = new Http();

                // Create HTTP request 
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
                
                //set Caller Id in request header
                request.setHeader('X_MW_WS_callerId', strCallerId);
                
                // build end point url and add product base code  if user selected the product code
                if (cse.Product_Base_Code__c == null){
                    url = url+cse.License__c;
                }
                else
                {
                    url = url+cse.License__c+'?productcode='+cse.Product_Base_Code__c;
                }             
                System.debug('@url:'+ url);
                // Set the endpoint URL.
                request.setEndPoint(url);
                // set Timeout
                request.setTimeout(20000);
                // Set the HTTP verb to GET.
                request.setMethod('GET');

                // Send the HTTP request and get the response.
                // The response is in JSON format.
                HttpResponse response = httpProtocol.send(request);
                //Get Jason String 
                String jsonData = response.getBody();
                System.Debug('Response status code:'+ Response.getStatusCode());
                if(Response.getStatusCode() != 200){
                    
                    jsonData = 'License'+ ' '+cse.License__c+' '+ 'Not Found';
                    errorresponse = 'Error';      
                }
        
                if (errorresponse == 'Error'){ // set all fields 
                    // update on support with error message
                    cse.On_Support__c = jsonData;
                    cse.On_Support_Reason__c = jsonData;
                    cse.Support_Reason__c = onSupportLicenseNotFound;
                    cse.Support_Status__c = onSupportEligibleFalse;
                    cse.License_Use__c = onSupportLicenseUnknown;
                    cse.License_Account__c = null;
                    cse.License_Account_Lookup__c = null;
                    
                }
                else { // license found
                    // parse OnSupport json string
                    onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
                    System.Debug('@json: '+jsonData);
                }
       
                // if product selected get the support status, otherwise get it from license. The value must be decoded to Yes or No 
                if (errorresponse != 'Error') {
                    if (string.isBlank(cse.Product_Base_Code__c) || (onSupportResponse.licenseSupportEligible == false && onSupportResponse.licenseReason == 'PIRATED' && string.isNotBlank(cse.Product_Base_Code__c)) ){
                        //  if (string.isBlank(cse.Product_Base_Code__c)){
                        //get license eligible yes or no
                        if (onSupportResponse.licenseSupportEligible == true){
                            cse.Support_Status__c = onSupportEligibleTrue;
                            cse.On_Support__c = cse.Support_Status__c + ' '+ onSupportResponse.ControllingProductDetail.latestServiceEndDate;   
                            //fg AtTask 1975447 
                            cse.on_support_reason__c = null;
                            cse.support_reason__c = null;                            
                        }
                        else{
                            cse.Support_Status__c = onSupportEligibleFalse;
                            // if license not eligible for support then license reason is always populated
                            cse.On_Support_Reason__c = onSupportResponse.licenseReason;// save API response
                            //map API on Suppor Reason to Case Support Reason field On_Support__c
                            onSupportReason =  onSupportResponse.licenseReason;
                            
                           // cse.Support_Reason__c = onSupportResponse.licenseReason;
                            List<On_Support_License_Reason_Mapping__mdt> LicenseReasonlst = [SELECT On_Support_Reason__c,On_Support_Reason_Mapping__c FROM On_Support_License_Reason_Mapping__mdt  where On_Support_Reason__c=: onSupportReason limit 1];                          
                            if(LicenseReasonlst.size() >0){
                                cse.On_Support_Reason__c = LicenseReasonlst[0].On_Support_Reason_Mapping__c;
                                cse.On_Support__c = cse.Support_Status__c +' '+ cse.On_Support_Reason__c;
                            }
                            else{
                                cse.On_Support__c = cse.Support_Status__c ;
                            }
                        }   
                    }
                    else{// product selected on the case
                        
                        if (onSupportResponse.productSupportEligible == true){
                            cse.Support_Status__c = onSupportEligibleTrue;
                            cse.On_Support__c = cse.Support_Status__c + ' '+ onSupportResponse.RequestedProductDetail.latestServiceEndDate;
                        }
                        else{
                            cse.Support_Status__c = onSupportEligibleFalse;                 
                            //map API Product On Support Reason to Case Support Reason field On_Support__c
                            onSupportReason =  onSupportResponse.productReason;  
                            List<On_Support_Product_Reason_Mapping__mdt> ProductReasonlst = [SELECT On_Support_Reason__c,On_Support_Reason_Mapping__c FROM On_Support_Product_Reason_Mapping__mdt  where On_Support_Reason__c=: onSupportReason limit 1];
                            if(ProductReasonlst.size()>0 && ProductReasonlst != null){
                                cse.On_Support_Reason__c = ProductReasonlst[0].On_Support_Reason_Mapping__c;
                                if (onSupportResponse.RequestedProductDetail.latestServiceEndDate != null && onSupportResponse.RequestedProductDetail.latestServiceEndDate !=''){
                            //if (OnSupportResponse.ControllingProductDetail != null && onSupportResponse.ControllingProductDetail.latestServiceEndDate != null && onSupportResponse.ControllingProductDetail.latestServiceEndDate !=''){    
                                  //  cse.On_Support__c = cse.Support_Status__c +' '+ cse.On_Support_Reason__c +' ' + onSupportResponse.ControllingProductDetail.latestServiceEndDate;
                                    cse.On_Support__c = cse.Support_Status__c +' '+ cse.On_Support_Reason__c +' ' + onSupportResponse.RequestedProductDetail.latestServiceEndDate;
                                }
                                else{
                                    cse.On_Support__c = cse.Support_Status__c +' '+ cse.On_Support_Reason__c ;
                                }       
                            }
                            else{
                                cse.On_Support__c = cse.Support_Status__c ;
                            } 
                        }      
                    }
                    
                    // set Account Lookup and Account Lookup Name
                    if (!string.isBlank(onSupportResponse.licenseeAccountId)){
                        cdsAccountId = onSupportResponse.licenseeAccountId;
                        List<Account> lookupLicenseAccountlst = [Select id, Name From Account where CDS_Account_Id__c =: cdsAccountId Limit 1];
                        if(lookupLicenseAccountlst.size() >0 && lookupLicenseAccountlst != null){
                            cse.License_Account__c = lookupLicenseAccountlst[0].Name;
                            cse.License_Account_Lookup__c = lookupLicenseAccountlst[0].Id;
                        }    
                        else{
                            cse.License_Account__c = null;
                            cse.License_Account_Lookup__c = null;
                            
                        }
                    }
                    // map API License Use field to SFDC License Type field
                    if (onSupportResponse.ControllingProductDetail != null){// license isn't pirated or inactive
                        if (!string.isBlank(onSupportResponse.ControllingProductDetail.use) ){
                            LicenseUse = onSupportResponse.ControllingProductDetail.use;        
                            
                            List<On_Support_License_Use_Mapping__mdt> CaseLicenseUselst = [SELECT License_Use__c,License_Use_Mapping__c FROM On_Support_License_Use_Mapping__mdt where License_Use__c =: LicenseUse limit 1]; 
                            if (CaseLicenseUselst.size() > 0 && CaseLicenseUselst != null){
                                cse.License_Use__c = CaseLicenseUselst[0].License_Use_Mapping__c;
                            }               
                        }
                    }
                    
                } //if valid license found no error
                // end setting fields when license is valid  and end json   
            } // end if not null  license entered on UI
            
            else{//fg AtTask 1975447
                if (string.isBlank(cse.License__c)){
                    //(string.isBlank(cse.License__c){
                  
                    cse.On_Support__c = null;
                    cse.On_Support_Reason__c =null;
                    cse.Support_Reason__c =null;
                    cse.Support_Status__c =null;
                    cse.License_Account__c =null;
                    cse.License_Account_Lookup__c =null;
                    cse.License_Type__c = null;// No License Reason label on UI
                }
            }
        }  // end for all cases list
        
        // update case list
        CaseTriggerHandler cseTriggerHandler = new CaseTriggerHandler();
        //Stops trigger when @future method is already running
        cseTriggerHandler.stopTrigger();
        try{
            
            update caselist;
        }
        catch (System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
            
        }
        // end update case list
        Logger.pop();
    }// end OnSupport REST API Call
    
    public void updateCaseEmailTemplateInfo(list <Case> List_Cases){
     Logger.push('updateCaseEmailTemplateInfo','CaseDml');
        map <Id,User> CaseUserMap = new map <Id,User>();
        set <Id> OwnerIDSet = new set <Id>();
        for (Case cse : List_Cases){
            //checks if case owner is a user
            if (String.valueof(cse.OwnerId).startsWith('005')){
                //Collect all Case Owner Id
                OwnerIDSet.add(cse.OwnerId);
            }
        }

        for (User CaseOwner : [Select Id, Email_Template_Signature__c, Disclosure__c From User Where Id in : OwnerIDSet]){
            //Assign User values to every case 
            CaseUserMap.put(CaseOwner.Id,CaseOwner);
        }
        
        //Update Email Template Info fields on every Case
        try{
             for (Case cse : List_Cases){
            if (CaseUserMap.containskey(cse.OwnerId)){
                cse.Email_Template_Disclosure__c = CaseUserMap.get(cse.OwnerId).Disclosure__c;
                cse.Email_Template_Signature__c = CaseUserMap.get(cse.OwnerId).Email_Template_Signature__c;
            }
        }
            
        }
        catch (System.DmlException e) {
      for (Integer i = 0; i < e.getNumDml(); i++) {
        //capture Dml  Process exception 
        Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
      }
    }
      
    }

   
    /**
     * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     * @date Original: 26 June 2013
     * @description method that updates Case Area field with value of Case Owner's Area field 
     * @param List_Cases collection of Case records
     **/
    public void updateCaseArea(list <Case> List_Cases){
    Logger.push('updateCaseArea','CaseDml');
        map <Id,User> CaseUserMap = new map <Id,User>();
        set <Id> OwnerIDSet = new set <Id>();
        for (Case cse : List_Cases){
            //checks if case owner is a user
            if (String.valueof(cse.OwnerId).startsWith('005')){
                //Collect all Case Owner Id
                OwnerIDSet.add(cse.OwnerId);
            }
        }

        for (User CaseOwner : [Select Id, Area__c From User Where Id in : OwnerIDSet]){
            //Assign User values to every case 
            CaseUserMap.put(CaseOwner.Id,CaseOwner);
        }

        try{
            for (Case cse : List_Cases){
            if (CaseUserMap.containskey(cse.OwnerId)){
                //Update Area field on every case 
                if (cse.Area__c == null){
                    cse.Area__c = CaseUserMap.get(cse.OwnerId).Area__c; 
                }
            }
        }
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //capture Dml  Process exception 
                Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }
        
    }

    /**
     * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
     * @date Original: 26 June 2013, Last Modified: 11 July 2013
     * @description Method that update the Case's Product fields (Product Lookup, Product Base Code) during Update and insert.
     * @param oldCaseMap Map<id,Case> case records with old values. value is null for Insert.
     * @param newCasMap Map<id,Case>  case records with new values. value is null for Insert.
     * @param newCaseInsert List of new case records. value is null for Update. 
     */
    public void UpdateCaseProductFields(map<Id,Case> oldCaseMap, map<Id,Case> newCasMap, List<Case> newCaseInsert){
        Logger.push('UpdateCaseProductFields','CaseDml');
        set<id> productLookUpIds = new set<id>();
        Map<id,Product2> productMap = new Map<ID,Product2>();
        if(oldCaseMap!=null && newCasMap!=null){
            //Collect all product IDs.
            for(Case c: newCasMap.values()){
                //compare if product lookup is updated and not null
                if(c.Product_Lookup__c!=oldCaseMap.get(c.id).Product_Lookup__c && c.Product_Lookup__c!=null){
                    productLookUpIds.add(c.Product_Lookup__c);
                }
            }
            //Map Product records where ID in productLookUpIds
            productMap = new Map<ID,Product2>([SELECT id,ProductCode FROM Product2 WHERE id IN :productLookUpIds]);
            for(Case c: newCasMap.values()){
                //compare if product lookup is updated and not null
                if(c.Product_Lookup__c!=oldCaseMap.get(c.id).Product_Lookup__c && c.Product_Lookup__c!=null){
                    c.Product_Base_Code__c = productMap.get(c.Product_Lookup__c).ProductCode;
                }
                if(c.Product_Lookup__c!=oldCaseMap.get(c.id).Product_Lookup__c && c.Product_Lookup__c==null){
                    c.Product_Base_Code__c = null;
                    c.Category__c = null;
                }
            }
        }else{
            //Collect all product IDs.
            for(Case c: newCaseInsert){
                if(c.Product_Lookup__c!=null){
                    productLookUpIds.add(c.Product_Lookup__c);
                }
            }
            //Map Product records where ID in productLookUpIds
            productMap = new Map<ID,Product2>([SELECT id,ProductCode FROM Product2 WHERE id IN :productLookUpIds]);
            for(Case c: newCaseInsert){
                //compare if product lookup is updated and not null
                if(c.Product_Lookup__c!=null){
                    c.Product_Base_Code__c = productMap.get(c.Product_Lookup__c).ProductCode;
                }
            }
        }
        Logger.pop();
    }

    /**
     * @author Original: Eric Schoenfeld - Cloud Sherpas/Mathworks
     * @date Original: 9 July 2013, Last Modified: 11 July 2013
     * @description Method that checks on Case Articles which updates the cases for easy reporting of KCS metrics
     * @param newCaseInsert List of case records that will be updated 
     */
    public void CaseArticleCheck(list <Case> CasesList){
    
        Map<String,Case> caseMap = new Map<String,Case>();
        Map<String,Case> noArticlesCase = new Map<String,Case>();

        for(case c: CasesList){
            caseMap.put(c.Id,c);
            noArticlesCase.put(c.Id,c);
        }

        Map<String,Case> casesWithArticles = new Map<String,Case>();
        Map<String,Case> ArticleCaseBridge = new Map<String,Case>();
        Map<String,String> ArticleCreatedBridge = new Map<String,String>();

        for(CaseArticle ca: [Select KnowledgeArticleId, CaseId, CreatedById from CaseArticle Where CaseId IN : caseMap.keyset()]){
            casesWithArticles.put(ca.CaseId,caseMap.get(ca.CaseId));
            ArticleCreatedBridge.put(ca.KnowledgeArticleId,ca.CreatedById);
            ArticleCaseBridge.put(ca.CreatedById,caseMap.get(ca.CaseId));
            noArticlesCase.remove(ca.CaseId);
        }

        List<Case> SourceCases = new List<Case>();
        List<Case> CitationCases = new List<Case>();

        for(KnowledgeArticleVersion kav: [SELECT SourceId, CreatedById, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND KnowledgeArticleId IN : ArticleCreatedBridge.keySet()]){        
            if(kav.CreatedById != ArticleCreatedBridge.get(kav.KnowledgeArticleId)){               
                CitationCases.add(ArticleCaseBridge.get(ArticleCreatedBridge.get(kav.KnowledgeArticleId)));
            }
            if(casesWithArticles.keySet().contains(kav.SourceId)){
                SourceCases.add(casesWithArticles.get(kav.SourceId));
                casesWithArticles.remove(kav.SourceId);
            }
        }

        for(Case c: CitationCases){
            c.Citation__c = true;
        }

        for(Case c: SourceCases){
            c.Known_Vs_New__c = 'New';
            c.Has_Linked_Article__c = true;
        }

        for(Case c: casesWithArticles.values()){
            c.Known_Vs_New__c = 'Known';
            c.Has_Linked_Article__c = true;
        }

        for(Case c: noArticlesCase.values()){
            c.Known_Vs_New__c = 'None';
        } 

    }

    /**
     * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     * @date Original: 16 July 2013, Last Modified: 04 November 2013
     * @description method that stops creating of Case to prevent email looping on inbound emails when both customer and sfdc have auto response 
     * @param newCasesList collection of Case records
     * @param beforeorafter identifies if the trigger is on before/after insert
     **/
    public void EmailToCaseLoopKiller(list<Case> newCasesList, string beforeorafter) {

        list <Case> cselist = newCasesList;
        boolean proceedCheck = false;

        //Validates the Case if its origin is from an Inbound Email
        if (cselist[0].SuppliedEmail != null && cselist[0].Subject != null){
            proceedCheck = true;
            system.debug('@@SuppliedEmail:'+cselist[0].SuppliedEmail);
            system.debug('@@Subject:'+cselist[0].Subject);
        }
        system.debug('@@proceedCheck:'+proceedCheck);
        if (proceedCheck){
            //Retrieve all Cases created by the same user with same subject and content
            list <Case> CaseCheck = [select ID, CreatedDate, subject, description,CaseNumber from Case where SuppliedEmail = :cselist[0].SuppliedEmail and subject = :cselist[0].subject and Origin = 'Email' and CreatedDate = TODAY and LastModifiedDate = TODAY order by CaseNumber asc limit 1000]; 

            if (CaseCheck.size() > 0){
                system.debug('@@SuppliedEmail:'+cselist[0].SuppliedEmail);
                system.debug('@@Subject:'+cselist[0].subject);
                system.debug('@@Case:'+cselist[0]);
                DateTime checkcreatedate = CaseCheck[0].createddate;
                checkcreatedate = checkcreatedate.addMinutes(1);
                checkcreatedate = checkcreatedate.addSeconds(30);  
                //We have a subject, proceed.
                if(!cselist[0].subject.contains('[ ref:')){
                    //Kill loop after creating three times with the same Case info within 90 second period
                    if(beforeorafter == 'after'){
                        //CaseCheck.size() > 2 && CaseCheck.size() <= 3
                        //if((checkcreatedate > System.now()) && CaseCheck[0].subject.contains(cselist[0].subject)){
                        list <Case> delCselist = new list <Case>();
                        //List <Case> cseDelList = new List<Case>();
                        Integer ctr=0;
                        for (Case delCse : CaseCheck){
                            DateTime checkcreateddate = delCse.createddate;
                            checkcreateddate = checkcreateddate.addMinutes(1);
                            checkcreateddate = checkcreateddate.addSeconds(30);
                            if (delCse.Description == cselist[0].Description && checkcreateddate > System.now()){
                                //Email contains same Subject and Body
                                if(ctr!=0){
                                    System.Debug('case marking to be cancelled:'+delcse.CaseNumber);
                                    delCse.Status = 'Cancelled';
                                    delCselist.add(delCse);
                                    Logger.debug(delCse.Id);
                                }
                                ctr++;
                            }
                        }
                        system.debug('@@ctr:'+ctr);
                        //Update all identified Case records except which will be included on deletion of Cancelled Case records
                        if (delCselist!= null && delCselist.size()>=2){
                            System.Debug('cases about to get updated:');
                            try{
                                update delCselist;
                            }
                            catch (System.DmlException e) {
                                for (Integer i = 0; i < e.getNumDml(); i++) {
                                    // Capture Dml exception here
                                    Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                                }
                            }
                        }
                        //}
                    }
                    else if (beforeorafter == 'before'){
                        //CaseCheck.size() >= 3 && 
                        //if((checkcreatedate > System.now()) && CaseCheck[0].subject.contains(cselist[0].subject)){
                        Integer ctr = 0;
                        for (Case cse : CaseCheck){
                            DateTime checkcreateddate = cse.createddate;
                            checkcreateddate = checkcreateddate.addMinutes(1);
                            checkcreateddate = checkcreateddate.addSeconds(30);
                            if (cse.Description == cselist[0].Description && checkcreateddate > System.now()){
                                //Email contains same Subject and Body
                                ctr++;
                            }
                            if (ctr >= 3){
                                cselist[0].addError('Automatic email loop has been terminated');
                                //Loop Was Killed.
                            }
                        }
                        // }
                    }
                }
                //else - No Errors.  Proceed creation of Case
            }
        }

    }

    /**
     * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
     * @date Original: 26 August 2013, Last Modified: 31 October 2013
     * @description method that updates the SubStatus to 'In Progress' when Case Owner was assigned from a queue to a new user nad SubStatus is 'Unassigned'
     * @param List_Cases collection of Case records
     **/
    public void updateSubStatusOnChangeOwnership(map<Id, Case> oldmap, map<Id, Case> newmap){

        Map <Id,Case> caseToUpdate = new map <Id,Case>();
        Map <Id,String> caseNewOwnerMap = new map <Id,String>();
        //Identify all Case records that have a Queue Case Owner and an Unassigned substatus
        for (Case oldcase : oldmap.values()){
            if ( String.valueOf(oldcase.OwnerId).substring(0, 3) != '005' && oldcase.SubStatus__c == 'Unassigned'){
                caseToUpdate.put(oldcase.Id, oldcase);
            }
        }
        //Update all Case records' SubStatus to In Progress
        for (Case newcase : newmap.values()){
            if (caseToUpdate.containskey(newcase.Id)){
                newcase.SubStatus__c = 'In Progress';
            }
            //Checks if the Owner is a User
            if (String.valueof(newCase.OwnerId).substring(0,3) == '005'){
                caseNewOwnerMap.put(newcase.Id,newcase.OwnerId);
            }
        }

        list <Task> openActivities = [Select Id, WhatId, OwnerId From Task Where WhatId in : caseNewOwnerMap.keyset() AND Status = 'Not Started'];
        if (openActivities.size() > 0){
            //Retrieve context user used on Email Service Address
            list <EmailServicesAddress> emailservadd = [SELECT Id, LocalPart, RunAsUserId FROM EmailServicesAddress limit 1];
            //AC - 8.12.2014: Query SFDC Admin
            List<User> sfAdmin = [SELECT Id FROM User WHERE alias = 'mwsadmin' LIMIT 1];            
            System.Debug('sfdc admin users:'+sfAdmin);
            list <Task> upActlist = new list<Task>();
            if (emailservadd.size() > 0){
                for (Task tsk : openActivities){
                    system.debug('@@emailservadd:'+emailservadd[0].RunAsUserId);
                    system.debug('@@tsk:'+tsk.OwnerId);
                    //emailservadd[0].RunAsUserID is the context user of an email service address
                    //005i00000014J5z is SFDC Admin in Production to update old cases created by email handler
                    if (tsk.OwnerId == emailservadd[0].RunAsUserId || (sfAdmin!= null && sfAdmin.size() > 0 &&  tsk.OwnerId == sfAdmin[0].Id)){
                        //Change Task owners with new Case Owner
                        tsk.OwnerId = caseNewOwnerMap.get(tsk.WhatId);
                        upActlist.add(tsk);
                        Logger.debug(tsk.Id);
                    }
                }
            }
            //Update all Open Activities
            if (upActlist.size() > 0){
                try{
                    update upActlist;
                }
                catch (System.DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        // Capture Dml exception here
                        Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                    }
                }
            }
        }

    }

    /**
     * @author Original: Kishore An - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
     * @date Original: 26 August 2013, Last Modified: 14 October 2013
     * @description method that updates the SubStatus to 'In Progress' when Case Owner was assigned from a queue to a new user nad SubStatus is 'Unassigned'
     * @param List_Cases collection of Case records
     **/
    public void updateCaseAreaSubArea(list<Case> newCasesList){

        //check the origin of the case
        //If the origin is ML_Desktop or ML_Web, check for the case contact country code
        //if the case contact country code is in the forwarding rules custom settings, set the case status to cancelled
        // else set the Area to country code + Technical Support'
        map <Id,Contact> CaseContactMap = new map <Id,Contact>();
        set <Id> CaseContactIdSet = new set <Id>();
        //Map<Id, Case> UpdatedCasesMap = new Map<Id, Case>();
        List<Case> UpdateCaseList = new List<Case>();
        for (Case cse : newCasesList){
            //checks if case owner is a user
            //HW 1017506, 1820717
            if (cse.Origin =='ML_Desktop' || cse.Origin == 'ML_Web' || cse.Origin == 'MATLAB Answers' 
               || cse.Origin == 'Bug Report Survey' || cse.Origin == 'ML_Academy' || cse.Origin == 'SegV'){
            //HW 1017506, 1820717
                //Collect all Case contact Id
                CaseContactIdSet.add(cse.ContactId);
                //UpdatedCasesMap.put(cse.Id, cse);
                UpdateCaseList.add(cse);
            }
        }

        list <Contact> CaseContactList = new list <Contact>();
        map<String, Schema.SObjectField> ConfieldMap = Schema.SObjectType.Contact.fields.getMap();
        if (CaseContactIdSet.size() > 0){
            String theQuery = 'Select Account.Name, ';
            for (Schema.Sobjectfield field : ConfieldMap.values()){
                //do not add MaillingAddress or OtherAddress to the query because they are compound fields and not queryable in this way
                if(field.getDescribe().getName()!= 'MailingAddress' && field.getDescribe().getName()!= 'OtherAddress'){
                    theQuery+= field.getDescribe().getName() + ',';
                }

            }
            theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
            theQuery+= ' FROM Contact Where id in : CaseContactIdSet';
            CaseContactList = database.query(theQuery);
        }


        for (Contact CaseContact : CaseContactList){
            //Assign Contact values to every case 
            CaseContactMap.put(CaseContact.Id,CaseContact);
        }
        
        system.debug('CaseContactMap'+CaseContactMap); 

        for (Case cse : UpdateCaseList){
            if (CaseContactMap.containskey(cse.ContactId)){
                system.debug('****************** CaseContactMap.get(cse.ContactId).Country_Code__c is ' 
                        + CaseContactMap.get(cse.ContactId).Country_Code__c);
                system.debug('cse.ContactId'+cse.ContactId);
                system.debug('cse.Country_Code__c'+CaseContactMap.get(cse.ContactId).Country_Code__c); 
                

                if( CaseContactMap.get(cse.ContactId).Country_Code__c!=null){
                    Forwarding_Rule__c fwdRule = Forwarding_Rule__c.getValues(CaseContactMap.get(cse.ContactId).Country_Code__c.toLowerCase());
                    system.debug('****************** fwdRule ' + 
                            fwdRule ); 
                    system.debug('****************** fwdRule ' + 
                            CaseContactMap.get(cse.ContactId).Country_Code__c); 

                    if (fwdRule != null){
                        if(!fwdRule.MathWorks_Office__c){
                            //cse.status = 'Cancelled';
                            cse.substatus__c = null;
                            //HW 1017506
                            if (cse.Origin == 'ML_Academy')
                                cse.Area__c = fwdRule.Case_Area_Country_Code__c +' - Customer Support'; 
                            else
                                cse.Area__c = fwdRule.Case_Area_Country_Code__c +' - Technical Support'; 

                            //check forwardToDistrbutor checkbox so that it will get processed in ForwardCaseToDistributorSchedulable class
                            cse.ForwardToDistributor__c=true;


                        }
                        else{
                            //HW 1017506
                            if (cse.Origin == 'ML_Academy')
                                cse.Area__c = fwdRule.Case_Area_Country_Code__c +' - Customer Support'; 
                            else
                                cse.Area__c = fwdRule.Case_Area_Country_Code__c +' - Technical Support';
                        }
                    }
                    else{
                        //HW 1017506
                        if (cse.Origin == 'ML_Academy')
                            cse.Area__c = 'Natick - Customer Support'; 
                        else
                            cse.Area__c = 'Natick - Technical Support'; 
                    }
                }                
                else{
                    //HW 1017506
                    if (cse.Origin == 'ML_Academy')
                        cse.Area__c = 'Natick - Customer Support'; 
                    else
                        cse.Area__c = 'Natick - Technical Support'; 
                }

                //Use the product Lookup value and get the product and use the product code.
                //Use product code and get the product for release 'No Release'
                // set the case sub area value as the product's portal case sub area field
                //if no product is found for the product code with no release, set the case sub area as empty/null
                // Changes Made by Jaspreet on 22-4-2013 : changed query filter from product name to product code i.e ProductCode  = :prod1.ProductCode
                
                Product2 prod = null;
                System.Debug('product lookup id before:'+cse.product_lookup__c);
                If(cse.product_lookup__c != null){                   
                    Product2 prod1 = [Select Name, Id,ProductCode   from Product2 where Id = :cse.product_lookup__c limit 1];
                    System.Debug('product lookup Name:'+prod1.Name);
                    if(prod1 !=null){
                        prod = [Select Id, release__C, Portal_Sub_Area__c from Product2 where ProductCode  = :prod1.ProductCode  and release__c = 'No Release'];
                    }
                }

                if(prod != null){
                    cse.sub_area__c = prod.Portal_Sub_Area__c;
                }

            }
        }
    }

    public void UpdateAreaChangedDates(map<Id, Case> oldmap, map<Id, Case> newmap){
    }



    /**
     * @author Original: Eric Schoenfeld - Cloud Sherpas/Mathworks
     * @date Original: 13 October 2014
     * @description method that updates Account look up on Case with value of the account related to the opportunity the case is created from 
     * @param CaseOppty collection of Case records with related Opportunity records
     * @Revision Archana Lohar|27 Nov 2014|Added code to check if new Account to update on case is not same to old one
     **/
    //Create the list containing Case ID and Opportnity ID
    public void updateCaseAccount(list<Case> List_Cases){
        Map<Id,Case> CaseOppty = new Map<Id, Case>();
        for (Case cse : List_Cases){

            //checks if case has an opporutnity ID
            if (cse.Opportunity__c != null){

                //Collect all Case Opportunity Id
                CaseOppty.put(cse.Opportunity__c,cse);
            }

        }
        //Takes Account ID from opportunities and inserts Account ID to Cases in the query if the list is not empty
        IF (! CaseOppty.ISEMPTY()){ 
            FOR   (Opportunity Opp : [Select Id, AccountId FROM Opportunity WHERE Id in: CaseOppty.keyset()])
            {
                IF (CaseOppty.containsKey(Opp.Id)) { 

                    if(CaseOppty.get(Opp.Id).Accountid!=Opp.AccountId){

                        CaseOppty.Get(Opp.Id).AccountId = Opp.AccountId; 
                    }
                }
            } 
        }
    } //end of method
  
     /**
     * @author Original: Sagar Talele
     * @date Original: 12/27/2013
     * @modified by :Archana Suryawanshi
     * @date modified: 19/4/2016
     * @description method that updates the status of open tasks to Completed when the Parent Case is Closed for area       Technical Support
            
     **/
    public void closeTaskStatusForCloseCase(Set <Id> Case_Id){
        Logger.Push('closeTaskStatusForCloseCase', 'CaseDML');
        
        //list to add tsak which is used to get task related to case
        list <Task> taskList = new list<Task>(); 
        //set to add user those are owner For task
        Set<Id> taskOwnerToUserSet = new Set<Id>();
        //list to add user
        List<User> userList = new List<User>();
        //list to add updated task list
        List<Task> UpdTaskList = new List<Task>();
        //list to add the case records
        List<Case> caseList = new List<Case>();
        Set<String> userArea = new Set<String>();
        //map of case area as key and userArea exclusion list as a value
        Map<String,Set<String>> caseAreaToUserAreaExclusionMap = new Map<String,Set<String>>();
        //Map of user Id as a key and user area as a value so can check for use area condition for respective case
        Map<Id,String> userIdToUserAreaMap = new Map<Id,String>();
        Map<Id,String> userIdToUserAreaMap1 = new Map<Id,String>();
        //get custom setting values in list
        List<Areas_Case_Task_Closure__c> areaCaseCloserList = Areas_Case_Task_Closure__c.getAll().Values();
        //list to add exclusionArea Values
        List<String> userAreaExclusionList = new List<String>();
        
        //Map of caseId to Task List
        Map<ID,List<Task>> caseIdToTaskListMap = new Map<ID,List<task>>();
        
        //boolean exclusion flag
        boolean exclusionFlag = false;  
        
        //Query case records
        caseList = [Select Id,Area__c,status From Case Where Id IN :Case_Id ];
        
        //build the map of caseAreaToUserAreaExclusionMap which contains case area and there respective user area exclusion set
        for(Case caseObj: caseList){
            if(caseObj.Area__c != null){
                for(Areas_Case_Task_Closure__c caseAreaRec : areaCaseCloserList){
                    userArea.add(caseAreaRec.name);
                    if(!caseAreaToUserAreaExclusionMap.containsKey(caseObj.Area__c) && caseObj.Area__c.contains(caseAreaRec.name)){
                        if(caseAreaRec.UserArea__c != null){
                            userAreaExclusionList = caseAreaRec.UserArea__c.split(';');
                            caseAreaToUserAreaExclusionMap.put(caseObj.Area__c,new Set<String>(userAreaExclusionList));
                        }
                        else{
                            caseAreaToUserAreaExclusionMap.put(caseObj.Area__c,new Set<String>());
                        }
                    }
                    else if(caseObj.Area__c.contains(caseAreaRec.name)){
                        caseAreaToUserAreaExclusionMap.get(caseObj.Area__c).add(caseAreaRec.UserArea__c);
                    }
                }
            }
        }
        
        //query the task list for whict whatId as a case Id and status is completed
        taskList =[select Type, Id, Status,Subject,OwnerId,whatId,Task_Owner_Area__c  from task where whatid IN :Case_Id and Status!= 'Completed' ];
        System.Debug('closeTaskStatusForCloseCase Case_Id: ' + Case_Id);
        System.Debug('closeTaskStatusForCloseCase taskList: ' + taskList);
        
        //iterate over the task list
        for(Task taskObj:taskList){
            taskOwnerToUserSet.add(taskObj.OwnerId);
            
            if(caseIdToTaskListMap.containsKey(taskObj.whatId)) {
                caseIdToTaskListMap.get(taskObj.whatId).add(taskObj);
            } else {
                caseIdToTaskListMap.put(taskObj.whatId, new List<Task> { taskObj });
            }
            
            if(!userIdToUserAreaMap.containsKey(taskObj.OwnerId)){
                userIdToUserAreaMap.put(taskObj.OwnerId,taskObj.Task_Owner_Area__c);
            }
        }
        
        //Commented by Archana 
        /*for(User  userObj: [Select Id,Area__c From User where Id In : taskOwnerToUserSet ]){
            if(!userIdToUserAreaMap1.containsKey(userObj.Id)){
                userIdToUserAreaMap1.put(userObj.Id,userObj.Area__c);
            }            
        }*/
        
       
        for(Case cse: caseList){
           
         if(caseIdToTaskListMap.get(cse.id)!=null){
           for(Task tsk : caseIdToTaskListMap.get(cse.id)){
               exclusionFlag= false;
               
               //check the case area is listed in custom setting with respective user area exclusion set
               //and also for case status as closed
               if(caseAreaToUserAreaExclusionMap.containsKey(cse.Area__c) && cse.status=='closed'){ 
               
                 
                    //iterate over the set of exclusion userAreas for respective case area so we can decide for  task owner user
                    //we have to exclude the user or we have to update the status of the task as closed
                    for(String sObj: caseAreaToUserAreaExclusionMap.get(cse.Area__c)){
                    
                        if(userIdToUserAreaMap.containsKey(tsk.ownerId) && userIdToUserAreaMap.get(tsk.ownerId) != null && userIdToUserAreaMap.get(tsk.ownerId).contains(sObj)){
                            exclusionFlag = true;
                            break;
                        }
                        else{
                            exclusionFlag = false;
                        }
                    }
                }
                
                if(tsk.whatId == cse.Id && (cse.status=='cancelled' || caseAreaToUserAreaExclusionMap.containsKey(cse.Area__c)) && !exclusionFlag ){
                    System.Debug('task can be closed');
                    if (tsk.Status <> 'Completed'){                       
                        tsk.status = 'Completed';
                        UpdTaskList.add(tsk);
                        Logger.debug(tsk.Id);
                    }
                }
            }
         }
            
        }
        
        try{
            if(!UpdTaskList.IsEmpty())
                update UpdTaskList;
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                Logger.Pop();
            }
        }
        Logger.Pop();        
    }

/*    //For SegV project. Populate article info on case
    public void populateArticleOnCase(list<Case> List_Cases){
        Logger.Push('populateArticleOnCase', 'CaseDML');
        
        //Prepare patterId Set
        Set<String> patterIdSet = new Set<String>();
        for (Case cse : List_Cases) {
            if (cse.Origin == 'SegV' && String.isNotBlank(cse.Geck_Pattern_ID__c)) {
                patterIdSet.add(cse.Geck_Pattern_ID__c);
            }
        }
        System.Debug('patterIdSet: ' + patterIdSet);

        if (patterIdSet.size() == 0) return;

        //Prepare patterId to SegV__kav Map
        Map<String, SegV__kav> patterIdArticleIdMap = new Map<String, SegV__kav>();
        List<SegV__kav> articleList = [SELECT Id, Geck_Pattern_ID__c, Title, Answers_URL__c, Questions_Specific_To_Issue__c FROM SegV__kav 
                                      WHERE PublishStatus = 'online' AND Language = 'en_US' AND Geck_Pattern_ID__c IN :patterIdSet 
                                      limit 1000];
        for (SegV__kav article : articleList) {
            patterIdArticleIdMap.put(article.Geck_Pattern_ID__c, article);
        }
        System.Debug('patterIdArticleIdMap: ' + patterIdArticleIdMap);

        //Populate article info ion case
        for (Case cse : List_Cases) {
            if (String.isNotBlank(cse.Geck_Pattern_ID__c) && patterIdArticleIdMap.containsKey(cse.Geck_Pattern_ID__c)) {
                SegV__kav article = patterIdArticleIdMap.get(cse.Geck_Pattern_ID__c);
                cse.Geck_Article_Title__c = article.Title;
                cse.Geck_Article_URL__c = article.Answers_URL__c;
                cse.Questions_Specific_To_Issue__c = article.Questions_Specific_To_Issue__c;
            }
        }
        Logger.Pop();        
    }

    //For SegV project. Create case article object record
    public void createCaseArticle(list<Case> List_Cases){
        Logger.Push('createCaseArticle', 'CaseDML');
        
        //Prepare patterId Set
        Set<String> patterIdSet = new Set<String>();
        for (Case cse : List_Cases) {
            if (cse.Origin == 'SegV' && String.isNotBlank(cse.Geck_Pattern_ID__c)) {
                patterIdSet.add(cse.Geck_Pattern_ID__c);
            }
        }
        System.Debug('patterIdSet: ' + patterIdSet);

        if (patterIdSet.size() == 0) return;

        //Prepare patterId to ArticleId Map
        Map<String, Id> patterIdArticleIdMap = new Map<String, Id>();
        List<SegV__kav> articleList = [SELECT Id, KnowledgeArticleId, Geck_Pattern_ID__c FROM SegV__kav 
                                      WHERE PublishStatus = 'online' AND Language = 'en_US' AND Geck_Pattern_ID__c IN :patterIdSet 
                                      limit 1000];
        for (SegV__kav article : articleList) {
            patterIdArticleIdMap.put(article.Geck_Pattern_ID__c, article.KnowledgeArticleId);
        }
        System.Debug('patterIdArticleIdMap: ' + patterIdArticleIdMap);

        //Prepare CaseArticle list
        List<CaseArticle> caList = new List<CaseArticle>();
        for (Case cse : List_Cases) {
            if (String.isNotBlank(cse.Geck_Pattern_ID__c) && patterIdArticleIdMap.containsKey(cse.Geck_Pattern_ID__c)) {
                CaseArticle ca = new CaseArticle();
                ca.CaseId = cse.Id;
                ca.KnowledgeArticleId = patterIdArticleIdMap.get(cse.Geck_Pattern_ID__c);
                ca.ArticleLanguage = 'en_US';   
                caList.add(ca);
            }
        }
        System.Debug('caList: ' + caList);
        
        //Insert CaseArticle list
        if (! caList.IsEmpty()) {
            try{
                insert caList;
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Capture Dml exception here
                    Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
        }

        Logger.Pop();        
    }
*/
}