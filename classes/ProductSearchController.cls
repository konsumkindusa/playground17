/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 22 May 2013, Last Modified: 19 September 2013
* @author modified: Krishna Bhaskarla; Date: 10 Dec 2013; Method: checkOnSupport; DESC: Configured CA cert and OrganizationID in HTTP headers gId: 1019977
* @author modified: Donna Latte; Date: 23 Apr 2014; Method: ProductSearch(); Desc:  Added 'order by' clause G1015493
* @author modified: Marc Ouimet; Date: 9 May 2014; Method: ProductSearchController(); Desc: commented out lines to populate product search fields G1018081
* @description Controller class for Product Search
*/
public class ProductSearchController {

    //Filter Variables
    public String prodName                      {get; set;}
    public String prodPCode                     {get; set;}
    public String prodRelease                   {get; set;}
    public String prodVersion                   {get; set;}
    
    //Object variables
    public Case cse                             {get; set;}
    //Main List
    public list <ProductWrapper> prodWRlist;
    list <Integration_Settings__c> integrationSetting;
    //Render Variables
    public String isOnLoad                      {get; set;}
    public String showNavi                      {get; set;}
    public String NaviDisp                      {get; set;}
    public String disabledOK                    {get; set;}
    public String LicenseError                  {get; set;}
    public String LicenseMsg                    {get; set;}
    public integer callattempts                 {get; set;}                         
    public integer numDelay                     {get; set;}
    public integer ChkIndex                     {get; set;}
    public String SelLicenseValue               {get; set;}
    list <Product2> prodList;
    //Pagination Variables
    public string ProdMaxPageNumber             {get; set;}
    public integer selectedpage                 {get; set;}
    Integer recordsPerPage;
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks 
    * @date Original: 22 May 2013, Last Modified: 05 September 2013
    * @description Class Constructor
    * @author modified: Marc Ouimet; Date: 9 May 2014; Method: ProductSearchController(); Desc: commented out lines to populate product search fields G1018081
    */
    public ProductSearchController(){
        
        recordsPerPage = 10;
        selectedPage = 0; 
        numdelay = 3000;
        callattempts = 0;
        ProdMaxPageNumber = '0';
        showNavi = 'false';
        NaviDisp = 'none';
        isOnLoad = 'true';
        disabledOk = 'true';
        LicenseError = 'fasle';
        LicenseMsg = '';
        
        //Get Case Record
        String caseID = ApexPages.currentPage().getParameters().get('id');
        cse = [SELECT Id,License__c, Product_Lookup__c, Product_Lookup__r.Name, Product_Base_Code__c, Release__c, Version__c FROM Case Where id = : caseID];
                
        //Custom Object holding information on On Support Integration data
        integrationSetting = new list <Integration_Settings__c>();
        integrationSetting = [Select Id, Name, Username__c, Password__c, Clientname__c, Endpoint__c, Timeout__c From Integration_Settings__c Where Name = 'On Support' limit 1];
        
        prodWRlist = new list <ProductWrapper>();
        prodName = ''; prodPCode = ''; prodRelease = ''; prodVersion = '';
        prodlist = new list <Product2>();
        
        //Display Product on page if a product already exists on the case
        system.debug('@@cse.Product_Lookup__c:'+cse.Product_Lookup__c);
        if (cse.Product_Lookup__c != null){
            system.debug('@@test');
            //Populate Search fields
            prodName = cse.Product_Lookup__r.Name;
            //prodPCode = cse.Product_Base_Code__c; //Marc Ouimet for G1018081 for 5/21/2014 release
            //prodRelease = cse.Release__c; //Marc Ouimet for G1018081 for 5/21/2014 release
            //prodVersion = cse.Version__c; //Marc Ouimet for G1018081 for 5/21/2014 release
            //Display Product result
            //Query Products
            prodlist = [Select Id, IsActive, Name, ProductCode, Release__c, Version__c From Product2 Where Id = : cse.Product_Lookup__c];
            //Enable the use of pagination to list of Products
            prodpg = new ApexPages.StandardSetController(prodlist);
            //sets the number of records in each page set
            prodpg.setPageSize(recordsPerPage);
            //Add Products to the Wrapper List
            for (Product2 prod2 : (List<Product2>)prodpg.getRecords()){
                    ProdWRList.add(new ProductWrapper(prod2,cse.License__c));
            }
            showNavi = 'true';
            NaviDisp = 'block';
            disabledOk = 'false';  
            ChkIndex = 0;
            //Gets the maximum number of records and displays 
            prodlast(); prodfirst();
        }
        
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks 
    * @date Original: 22 May 2013, Last Modified: 05 September 2013
    * @author modified: Krishna Bhaskarla; Date: 10 Dec 2013; Method: checkOnSupport; DESC: Configured CA cert and OrganizationID in HTTP headers
    * @author modified: Donna Latte; Date: 23 Apr 2014; Method: ProductSearch(); Desc:  Added 'order by' clause G1015493
    * @author modified: Donna Latte; Date: 08 May 2014; Method: ProductSearch(); Desc:  Modified 'order by' clause G1083840
    * @description method for searching of available Products to be displayed on the list
    */
    public void ProductSearch(){
        
        isOnLoad = 'false';
        
        //Set Field Criterias
        String NameCrit = ' Name like \'%' + prodName + '%\' ';
        String ProdCodeCrit = ' ProductCode like  \'%' + prodPCode + '%\' ';
        String ReleaseCrit =  ' Release__c like \'%' + prodRelease + '%\' ';
        String VersionCrit = ' Version__c like  \'%' + prodVersion + '%\' ';
        
        prodWRlist = new list <ProductWrapper>();
        //Main Query For Products
        String ProdQuery = 'Select Id, IsActive, Name, ProductCode, Release__c, Version__c From Product2 '; 
        
        //WHERE clause conditions
        String whereClause = '';
        if (prodName != ''){
            whereClause += NameCrit;
        }
        if(prodPCode != ''){
            if(whereClause!=''){
                whereClause += ' AND ';
            }
            whereClause += ProdCodeCrit;
        }
        if(prodRelease != ''){
            if(whereClause!=''){
                whereClause += ' AND ';
            }
            whereClause += ReleaseCrit;
        }
        if (prodVersion != '' ){
            if(whereClause!=''){
                whereClause += ' AND ';
            }
            whereClause += VersionCrit; 
        }
        
        //Add String "WHERE " at the begining of the where clause if the variable is not empty.
        if(whereClause!=''){
            whereClause = ' WHERE '+whereClause;
        }
        
        //WHERE clause conditions to Main Query For Products
        ProdQuery += whereClause;
        
        // ORDER BY clause
        String orderByClause = '';
        orderByClause = 'Order by Name, Version__c DESC ';
        ProdQuery += orderByClause;
       
        //Query Products
        prodlist = database.query(ProdQuery);
        
        //Enable the use of pagination to list of Products
        prodpg = new ApexPages.StandardSetController(prodlist);
        //sets the number of records in each page set
        prodpg.setPageSize(recordsPerPage);
        
        
        //Add Products to the Wrapper List
        for (Product2 prod2 : (List<Product2>)prodpg.getRecords()){
                ProdWRList.add(new ProductWrapper(prod2,cse.License__c));
        }
        
        //Set render variables
        if (ProdWRList.size() > 0){
            showNavi = 'true';
            NaviDisp = 'block';
            disabledOk = 'false';   
        }
        else {
            showNavi = 'false';
            NaviDisp = 'none';
            disabledOk = 'true';
        }
        
        //Gets the maximum number of records and displays 
        prodlast(); prodfirst();
        
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks 
    * @date Original: 23 May 2013, Last Modified: 19 September 2013
    * @description Method for saving selected Product into Case
    */
    public void saveProduct(){
        try {
            for (ProductWrapper pwr : ProdWrList){
                if (pwr.isSelected){
                    //Assign Product field values to Case fields
                    cse.Product_Lookup__c = pwr.prod.Id;    
                    cse.Product_Base_Code__c = pwr.prod.ProductCode;
                    if (pwr.newLicNum != null){
                        //() - group of regular expression; | - either/or; \\d - Matches digits. Equivalent to [0-9]; ^ - Matches beginning of line; $ - Matches end of line; \\Q - escape start quote; \\E - escape end quote;
                        //(^DEMO-[\\d]+$)|(^STUDENT-[\\d]+$)|(^[\\d]+\\Q-STUDENT\\E+$)|(^[\\d]+\\Q-DEMO\\E+$)
                        Pattern isnumbers = Pattern.Compile('(^[\\d]+$)|(^DEMO+$)|(^STUDENT+$)');
                        String newLicNum = String.valueof(pwr.newLicNum).toUpperCase();
                        Matcher lidnumber = isnumbers.matcher(newLicNum);
                        //Check if License # matches regular expressions - Display Error message on page
                        if ( (!lidnumber.matches() || newLicNum.length() > 10 ) && newLicNum != ''){
                            SelLicenseValue = pwr.newLicNum;
                            LicenseError = 'true';
                            LicenseMsg = Label.Product_Search_License_Invalid;
                        }
                        //Proceed on update
                        else {
                            LicenseError = 'false';
                            cse.License__c = String.valueof(pwr.newLicNum).toLowerCase();
                           checkOnSupport(pwr.newLicNum); 
                        }
                    }
                }
            }
            
            //Instantiate CaseTriggerHandler class
            CaseTriggerHandler cseTriggerHandler = new CaseTriggerHandler();
            //Stops trigger when @future method is already running
            cseTriggerHandler.stopTrigger();
            
            //Update Case record
            update cse;
            }
        catch (Exception e){
            callattempts++;
            try{
                update cse;
            }
            catch(Exception ex){
                callattempts++;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '|' + e.getLineNumber()));
            }
        }
        system.debug('@@callattempts:'+callattempts);
        system.debug('@@updated Case:'+cse);
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks , Faina Gorelik - MathWorks
    * @date Original: 23 May 2013, Last Modified: 24 July 2013, 14 July 2016
    * @description Method for getting On Support Info from REST API
    * @author modified: Krishna Bhaskarla; Date: 10 Dec 2013; Method: checkOnSupport; DESC: Configured CA cert and OrganizationID in HTTP headers
    */
    
    public void checkOnSupport(String licensenum) {
        system.debug('@@licensenum:'+licensenum);
        
        if (licensenum != null)	{
        		General_Settings__c settings ;
        		String url;
                IntegrationUtilityHelper intHelper;
                string bToken;
                String supportJsonString;
                String strCallerId ='Salesforce';
         		String errorresponse = ''; // if response code 404
        		OnSupportUtilityClass.Rootboolean onSupportResponse;
         		String cdsAccountId = '';// 
        		String LicenseAcctId = '';
                String LicenseUse = '';
                String onSupportReason = '';
                String onSupportEligibleTrue = System.Label.On_Support_Eligible_True;
                String onSupportEligibleFalse = System.Label.On_Support_Eligible_False;
                String onSupportLicenseUnknown = System.Label.OnSupportLicenseUnknown;
                String onSupportLicenseNotFound = System.Label.On_Support_License_Not_Found;
                
                settings = General_Settings__c.getInstance();
                //Getting url from General setting
                url = settings.OnSupportURL__c;
                //Get Business Security token from IntegrationUtilityHelper log error message 
                try{
                    intHelper=new IntegrationUtilityHelper(); 
                    bToken=intHelper.getBusinessServiceToken();             
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

            	IntegrationUtilityHelper intUtilityHelper = new IntegrationUtilityHelper();
				
                //set ClientCertificate if this code is not running in a test
                //this keeps the tests environment agnostic and the mock callouts do not need a certificate
                if(!Test.isRunningTest()){
                    request.setClientCertificateName(intUtilityHelper.getCACertIntegration());
                }
            
                //set Organization Id in request header
                request.setHeader('OrganizationID', UserInfo.getOrganizationId());
                //set business tokens in request header
                request.setHeader('X_MW_WS_securityToken', bToken);
            
                //set Caller Id in request header
                request.setHeader('X_MW_WS_callerId', strCallerId);
        		url = url+licensenum +'?productcode='+cse.Product_Base_Code__c;
        		System.debug('Faina product search final url:'+ url);
        		
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
                    System.debug('JsonData License not found'+ jsonData);      
            	}
        
        		if (errorresponse == 'Error'){ // set all fields 
                    // update on support with error message
                    cse.On_Support__c = jsonData;
                    // new
                    cse.On_Support_Reason__c = jsonData;
                    cse.Support_Reason__c = onSupportLicenseNotFound;
                    cse.Support_Status__c = onSupportEligibleFalse;
                    //cse.License_Type__c = onSupportLicenseUnknown;
                    cse.License_Use__c = onSupportLicenseUnknown;
                    cse.License_Account__c = null;
                    cse.License_Account_Lookup__c = null;
                    
                }
                else
                {
                    // parse OnSupport json string
                    onSupportResponse = OnSupportUtilityClass.getParsedOnSupportJson(jsonData);
                    System.Debug('Validate Product jsonData string: '+jsonData);
                }
        		//start
        		  if (errorresponse != 'Error') {
                   if (string.isBlank(cse.Product_Base_Code__c) || (onSupportResponse.licenseSupportEligible == false && onSupportResponse.licenseReason == 'PIRATED' && string.isNotBlank(cse.Product_Base_Code__c)) ){
                        //get license eligible yes or no
                        if (onSupportResponse.licenseSupportEligible == true){
                            cse.Support_Status__c = onSupportEligibleTrue;
                            cse.On_Support__c = cse.Support_Status__c + ' '+ onSupportResponse.ControllingProductDetail.latestServiceEndDate;                  
                        }
                        else{
                            cse.Support_Status__c = onSupportEligibleFalse;
                            // if license not eligible for support then license reason is always populated
                           cse.On_Support_Reason__c = onSupportResponse.licenseReason;// save API response
                            //map API on Suppor Reason to Case Support Reason field On_Support__c
                           onSupportReason =  onSupportResponse.licenseReason;
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
                               // if (OnSupportResponse.ControllingProductDetail != null && onSupportResponse.ControllingProductDetail.latestServiceEndDate != null && onSupportResponse.ControllingProductDetail.latestServiceEndDate !=''){
                                if (onSupportResponse.RequestedProductDetail.latestServiceEndDate != null && onSupportResponse.RequestedProductDetail.latestServiceEndDate !=''){     
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
                        //Account lookupLicenseAccountId;
                        List<Account> lookupLicenseAccountlst = [Select id, Name From Account where CDS_Account_Id__c =: cdsAccountId Limit 1];
                        if(lookupLicenseAccountlst.size() >0 && lookupLicenseAccountlst != null){
                            cse.License_Account__c = lookupLicenseAccountlst[0].Name;
                            cse.License_Account_Lookup__c = lookupLicenseAccountlst[0].Id;
                        }    
                        else{
                            cse.License_Account__c = null;
                            cse.License_Account_Lookup__c = null;
                            
                        }
                        // add else to update to null
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
                    
                }
        }// end if license is not null
        		// end
    }

    
    /**
    * @author Original: Jesfer Baculod (502068421) Cloud Sherpas/Mathworks
    * @date Original: 23 May 2013
    * @description Pagination functionality for Products 
    */
    public ApexPages.StandardSetController prodpg {
        get {
        if(prodpg == null) {
            prodpg = new ApexPages.StandardSetController(prodlist);
            // sets the number of records in each page set
            prodpg.setPageSize(recordsPerPage);
        }
        return prodpg;
        }
        set;
    }
    //Returns current Page Number of the Product List
    public Integer prodpageNumber { get { return prodpg.getPageNumber(); } set;}
    //Returns First Page of the Product List
    public void prodfirst() { prodpg.first();}
    //Returns Last Page of the Product List
    public void prodlast() { prodpg.last(); ProdmaxPageNumber = String.valueof(prodpg.getPageNumber()); }
    //Returns Maximum Page Number of the Product List
    public String getProdmaxPageNumber(){ return ProdmaxPageNumber;}
    //Returns Previous page of the Product List
    public void prodprevious() { prodpg.previous(); }
    //Returns Next page of the Product list
    public void prodnext() { prodpg.next(); }
    //Sets the Selected Page of the Product List
    public void prodsetPageNumber(){ prodpg.setpageNumber(selectedpage); }
        
        
    /**
    * @author Original: Jesfer Baculod (502068421) Cloud Sherpas/Mathworks
    * @date Original: 23 May 2013
    * @description Getter method that populates the value of the SelectList with the number of Product pages searched
    */
    public list<SelectOption> getProdPageSelect(){
        list<SelectOption> pageList = new List<Selectoption>();
        for(Integer i=1;i<=Integer.valueof(ProdmaxPageNumber);i++){
            pageList.add(new SelectOption(String.valueOf(i) , String.valueOf(i)));
        }
        return pageList;
    }
    
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks 
    * @date Original: 22 May 2013, Last Modified: 23 May 2013
    * @description Getter method for retrieving Products upon search
    */
    public list <ProductWrapper> getProdWRlist(){
        ProdWRlist = new List<ProductWrapper>();
        for (Product2 prod2 : (List<Product2>)prodpg.getRecords()){
                ProdWRList.add(new ProductWrapper(prod2,cse.License__c));
        }
        return ProdWRlist;
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks 
    * @date Original: 22 May 2013
    * @description Wrapper class for selecting Products
    */
    public class ProductWrapper{
        public Product2 prod {get; set;}
        public Boolean isSelected {get; set;}
        public String newLicNum {get; set;}
        public ProductWrapper(Product2 prods, String newLicense){
            prod = prods;
            newLicNum = newLicense;
            isSelected = false;
        }
    }

}