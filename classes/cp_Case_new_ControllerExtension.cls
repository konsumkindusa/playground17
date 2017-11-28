/**
* @author Original: Limo Sadalla - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod 
* @date Original: 26 June 2013, Last Modified: 23 Sep 2016 Last Modified By : Shweta Shanbhag 
* @description controller class of page on Customer Portal for creating Case  
*/ 
global class cp_Case_new_ControllerExtension {
   public static boolean skipUpdateCaseArea = false;
   // public ApexPages.StandardController controller {get;set;} not used
   // public string pageUrl {get;set;} not used
    Case caseObj;
    User TheUser;
    public Boolean isssoenabled {get; set;}
    public string pageFrame {get; set; }
    public string selTask {get; set;}
    public String language { get; set; } //SS 9/27/16
    public SelectOption[] Salutations{get; set;}
    public SelectOption[] Releases{get; set;}
    public String SelectedRelease {get; set;}
    public SelectOption[] allProductList { get; set;}
    
    public list <string> CSCustomerInfo {get;set;}
    public list <String> CSPassCodeDesc {get;set;}
    public list <String> CSLicenseContact {get;set;}
    public list <String> CSTransfer1 {get; set;}
    public list <String> CSTransfer2 {get; set;}
    public list <String> CSTransfer3 {get; set;}
    public list <String> CSTransfer4 {get; set;}
    public list <String> CSTransfer5 {get; set;}
    public list <String> CSCombineLic {get; set;}
    public list <String> CSProductActFields {get; set;}
    list <string> selTaskCSlist;
    public string distributoremailaddress {get; set;}
    public string tempoutputver{get; set;}
    
    transient public blob attlicensedatBody {get; set;}
    transient public blob attlmdebugoutBody {get; set;}
    transient public string outputver {get; set;}
    transient public string outputerr {get; set;}
    public list <Attwrapper> attwrapperlist {get; set;}
    public Attachment attlicensedat {get; set;}
    public Attachment attlmdebugout {get;set;}
    public Attachment attoutputver {get; set;}
    public Attachment attoutputerror {get;set;}
    
    public Boolean isStudent {get; set;}
    public Boolean isDistributor {get; set;}
    public boolean hasMWOffice {get; set;}
    public boolean isValidVer {get; set;}
    public boolean isDisplaySuggestedArticles {get; set;}
    public List<FAQ__Kav> results {get; set;}
	public integer iSuggestedContentFeedbackStep {get; set;}
	public integer iSuggestedContentLimit;
	public integer iSuggestedContentSummaryLength;
	public boolean isSuggestedContentDisplaySummary;
	public String strSuggestedContentRedirectUrl;
	public string strKeywords;
	public string strLastClickedArticleId {get; set;}   
	public string strLastClickedArticleTitle {get; set;}    
	Case_Deflection__c cdObj;
    public string cdObjId {get; set;}
    public string caseType{get; set;}  //DMA 2245014
    
    public class Attwrapper{
        public string attName {get; set;}
        transient public Blob attBody {get; set;}
        public string attContType {get; set;} //SS 1204037 - save attachments as utf-8
        public AttWrapper (String attNames, Blob attBodys, String attContTypes){    
            attName = attNames;
            attBody = attBodys;
            attContType = attContTypes;
        }
    }
    
    Contact con;
    map<String,Schema.SobjectField> ConfieldMap;
    @TestVisible
    Forwarding_Rule__c fwdRule; 
    
   public cp_Case_new_ControllerExtension(){
    	Logger.push('cp_Case_new_ControllerExtension','cp_Case_new_ControllerExtension');
        system.debug('onload current user:'+UserInfo.getUserName());

		//DMA 2245014 - setting case type based on which page is bound to this controller       
        String currentURL = ApexPages.currentPage().getUrl();
        if(currentURL.contains('cp_case_new_ts_opt1')) caseType = 'Technical Support';
        else if(currentURL.contains('cp_case_new_cs_opt6')) caseType = 'Customer Service';
       
        distributoremailaddress = '';
        tempoutputver = '';
        TheUser = [SELECT Id, Fax, Phone, Email, LastName, FirstName, Student__c, Portal_User_Status__c, ContactId, country_code__c,FederationIdentifier,IsPortalEnabled  FROM User WHERE Id = :UserInfo.getUserId()];
        attlicensedat = new Attachment(); attlmdebugout = new Attachment(); attoutputver = new Attachment();attoutputerror = new Attachment();
        attwrapperlist = new list <Attwrapper>{ new AttWrapper('',Blob.valueof(''), ''),new AttWrapper('',Blob.valueof(''),''),new AttWrapper('',Blob.valueof(''),''),new AttWrapper('',Blob.valueof(''),''),new AttWrapper('',Blob.valueof(''),'')};
        selTask = '';
        pageFrame = '';
        selTaskCSList = new list <string>{'ProductActivation','PasscodeLicense','AddChangeLicense','RedesignateProducts','CombineLicenses','GeneralCustomerService'};
        CSProductActFields = new list <string>{'','',''};
        CSPassCodeDesc = new list <string>{'','','','','','',''};
        CSCustomerInfo = new list <string>{'','',''};
        /* Customer Support -  Passcode/license file or redesignate (transfer) license to new server Description fields
        [0] Release
        [1] Primary Host ID
        [2] Backup Host ID 1
        [3] Backup Host ID 2
        [4] Additional Details
        */
        CSLicenseContact = new list <string>{'','','','','','','','','','','','','','','','','','','','','','','','','',''};
        /* Customer Support - Add, change, or remove a license contact Description Fields
        CSLicenseContact
        [0] - what would you like to do: *
        [1] - License contact *
        -- Current Contact Information --
        [2] - Salutation (current)
        [3] - first name (* on Change an existing license contact)
        [4] - middle name
        [5] - last name (* on Change an existing license contact)
        [6] - email (* on Change an existing license contact)
        -- New Contact Information --
        [7] - country/region (* on Add or Change license contact)
        [8] - Salutation (new)
        [9] - First Name (* on Add or Change license contact)
        [10]- Middle Name 
        [11]- Last Name (* on Add or Change license contact)
        [12]- Job Title
        [13]- Department
        [14]- Mail Stop
        [15]- Company/University (* on Add or Change license contact)
        [16]- Street Address 1 (* on Add or Change license contact)
        [17]- Street Address 2
        [18]- City (* on Add or Change license contact)
        [19]- Zip Code (* on Add or Change license contact)
        [20]- Email (* on Add or Change license contact)
        [21]- Phone (* on Add or Change license contact)
        [22]- Extension
        [23]- Fax
        [24]- Mobile Phone
        [25]- Additional Details 
        */
        CSTransfer1 = new list <string>{'','','',''}; // Transfer #1
        CSTransfer2 = new list <string>{'','','',''}; //Transfer #2
        CSTransfer3 = new list <string>{'','','',''}; //Transfer #3
        CSTransfer4 = new list <string>{'','','',''}; //Transfer #4
        CSTransfer5 = new list <string>{'','','',''}; //Transfer #4
        /* Customer Support - Redesignate (transfer) products between licenses Description Fields
        [0] - Product Name (* on first list)
        [1] - Quantity (* on first list)
        [2] - From License (* on first list)
        [3] - To License (* on first list)
        */
        CSCombineLic = new list <string>{'','','',''};
        /* Customer Support - Combine Licenses Description fields
        [0] Destination License (*)
        [1] List Licenses to Combine (*)
        [2] Host ID for New Combined License
        */
        getSalutations();
        getReleases();
        getCountries();
        setPageLanguage();//SS 9/26/16
        allProductList = new List<SelectOption>();
        refreshProductList();
        isStudent = TheUser.Student__c;
        isDistributor = false;
        if (TheUser.Portal_User_Status__c == 'Distributor' && !isStudent){
            isDistributor = true;
        }
        
        hasMWOffice = true;
        if(TheUser.Country_Code__c != null){
            fwdRule = Forwarding_Rule__c.getValues(TheUser.Country_Code__c.toLowerCase());
            if (fwdRule != null && !fwdRule.MathWorks_Office__c){
                distributoremailaddress = fwdRule.Forwarding_Email_Address__c;
                hasMWOffice = false;
            }
        } 
        
        isssoenabled = false;
        if(TheUser!= null && TheUser.isPortalEnabled && TheUser.FederationIdentifier!=null 
            && TheUser.FederationIdentifier!='' && Integer.ValueOf(TheUser.FederationIdentifier) > 0){
            isssoenabled = true;
        }
        
        if (Test.isRunningTest()){
            outputver = 'test ouput ver';
            attlicensedatBody = Blob.valueof('UNIT.Test');
            attlmdebugoutBody = Blob.valueof('UNIT.Test');
            outputerr = 'test ouput err';
        }
        isDisplaySuggestedArticles = false;
        iSuggestedContentFeedbackStep = 1;
        Logger.pop();
   }
   
   public void getPageFrame(){
   		Logger.push('getPageFrame','cp_Case_new_ControllerExtension');
        this.pageFrame = '/apex/cp_case_new';
        if (selTask == 'ProductActivation'){ pageFrame += '_cs_opt1'; }
        else if (selTask == 'PasscodeLicense'){ pageFrame += '_cs_opt2'; }
        else if (selTask == 'AddChangeLicense'){ pageFrame += '_cs_opt3'; }
        else if (selTask == 'RedesignateProducts'){ pageFrame += '_cs_opt4'; }
        else if (selTask == 'CombineLicenses'){ pageFrame += '_cs_opt5'; }
        else if (selTask == 'GeneralCustomerService'){ pageFrame += '_cs_opt6'; }
        else if (selTask == 'Installation'){ pageFrame += '_ts_opt1'; }
        else if (selTask == 'Producthelp'){ pageFrame += '_ts_opt2'; }
        
        pageFrame =pageFrame + '?cc='+ApexPages.currentPage().getParameters().get('cc');
        Logger.pop();
   } 
   
    public Case getCaseObj() {
    	Logger.push('getCaseObj','cp_Case_new_ControllerExtension');
        if(outputver != null && outputver != '' )
        {
            if(outputver.length() > 32767)
            { tempoutputver = outputver.substring(0,32767);}
        	else
            {tempoutputver = outputver;}
        }
        if(caseObj == null) caseObj = new Case();
        caseObj.Usage_Type__c = 'PC Install'; 
        caseObj.Ver_Command__c = tempoutputver; // fg 
  		string str = ApexPages.currentPage().getParameters().get('LicenseNum');
  		if (string.isNotBlank(str)) {
  			caseObj.License__c = str;
  		}
  		Logger.pop();
        return caseObj;
    }

 /*
        @author         Shweta Shanbhag
        @date           9/27/2016 
        @description    Deduce the language code that needs to be used for the page based on the country code parameter of cc
    */
    private void setPageLanguage() {
        Logger.push('cp_Case_new_ControllerExtension', 'setPageLanguage');
        
        language = 'en_US'; //HW
		
		List<Portal_CountryCode_Language_Mapping__mdt> CountryCodeLangList = new List<Portal_CountryCode_Language_Mapping__mdt>();	
		
        Portal_CountryCode_Language_Mapping__mdt ObjCCLang;
		 String countrycode = ApexPages.currentPage().getParameters().get('cc');
		
        if (!String.isEmpty(countrycode))
        {
            CountryCodeLangList = [select DeveloperName, CountryCode__c, LanguageCode__c from Portal_CountryCode_Language_Mapping__mdt where  CountryCode__c= : countrycode  limit 1];
            if (!CountryCodeLangList.IsEmpty()){
                language = CountryCodeLangList[0].LanguageCode__c;}
		}	
		//else language = 'en_US'; //HW

        Logger.pop();
    }
    
    public String getdistributoremailaddress(){
        return distributoremailaddress;
    }
   
    public PageReference setUrl() {
        return null;
    }
    
    public PageReference createcase(){
    	Logger.push('createcase','cp_Case_new_ControllerExtension');
        system.debug('@@selTask:'+selTask);
        if(caseObj == null) caseObj = new Case();
        	caseObj.Origin = 'Web';
            if(selTask == 'PasscodeLicense'){
              caseObj.Description = '';
              //caseObj.Subject = 'PLP Request - ' + caseObj.Subject;
              caseObj.Subject = 'Passcode/license file or redesignate (transfer) license to new server';
              caseObj.Topic__c = 'Passcodes';
              caseObj.Sub_Topic__c = 'Generate';
              if (isDistributor){
                  
                  String preDescription = 'Customer First Name: ' + CSCustomerInfo[0]; 
                  preDescription += '\r\n Customer Last Name: ' + CSCustomerInfo[1];
                  preDescription += '\r\n Customer Email: ' + CSCustomerInfo[2] + '\r\n\r\nNotes:\r\n';
                  caseObj.Description = preDescription;
              }
              for (Integer i=0; i < CSPassCodeDesc.size(); i++){
                 //Populate Description from Customer Support PassCode request
                 if (CSPassCodeDesc[i] != ''){
                    if (i == 1) CSPassCodeDesc[i] = 'What would you like to do: ' + CSPassCodeDesc[i];
                    if (i == 2 && CSPassCodeDesc[1] != '') CSPassCodeDesc[i] = 'Release: ' + CSPassCodeDesc[i];
                    else if (i == 3) CSPassCodeDesc[i] = 'Host ID: ' + CSPassCodeDesc[i];
                    else if (i == 4) CSPassCodeDesc[i] = 'Backup Host ID 1: ' + CSPassCodeDesc[i];
                    else if (i == 5) CSPassCodeDesc[i] = 'Backup Host ID 2: ' + CSPassCodeDesc[i];
                    caseObj.Description += '\r\n' + CSPassCodeDesc[i];
                 }
              }
            }
            else if (selTask == 'AddChangeLicense'){
              caseObj.Subject = CSLicenseContact[0];
              caseObj.Topic__c = 'License Modifications';
              caseObj.Sub_Topic__c = 'Administrator Change';
              caseObj.Description = '';
                 //Populate Description field from Customer Support Add/Change/Remove License Contact request
                 CSLicenseContact[0] = 'What would you like to do: ' + CSLicenseContact[0] + '\r\n';
                 CSLicenseContact[1] = 'For which contact: ' + CSLicenseContact[1] + '\r\n\r\n';
                 //Current Contact Infromation
                 CSLicenseContact[2] = 'Current Contact Information: \r\n Salutation: ' + CSLicenseContact[2] + '\r\n';
                 CSLicenseContact[3] = 'First Name: ' + CSLicenseContact[3] + '\r\n';
                 CSLicenseContact[4] = 'Middle Name: ' + CSLicenseContact[4] + '\r\n';
                 CSLicenseContact[5] = 'Last Name: ' + CSLicenseContact[5] + '\r\n';
                 CSLicenseContact[6] = 'Email: ' + CSLicenseContact[6] + '\r\n\r\n';
                 //New Contact Information
                 CSLicenseContact[7] = 'New Contact Information: \r\n Country/Region: ' + CSLicenseContact[7] + '\r\n';
                 CSLicenseContact[8] = 'Salutation: ' + CSLicenseContact[8] + '\r\n';
                 CSLicenseContact[9] = 'First Name: ' + CSLicenseContact[9] + '\r\n';
                 CSLicenseContact[10] = 'Middle Name: ' + CSLicenseContact[10] + '\r\n';
                 CSLicenseContact[11] = 'Last Name: ' + CSLicenseContact[11] + '\r\n';
                 CSLicenseContact[12] = 'Job Title: ' + CSLicenseContact[12] + '\r\n';
                 CSLicenseContact[13] = 'Department: ' + CSLicenseContact[13] + '\r\n';
                 CSLicenseContact[14] = 'Mail Stop: ' + CSLicenseContact[14] + '\r\n';
                 CSLicenseContact[15] = 'Company / University: ' + CSLicenseContact[15] + '\r\n';
                 CSLicenseContact[16] = 'Street 1: ' + CSLicenseContact[16] + '\r\n';
                 CSLicenseContact[17] = 'Street 2: ' + CSLicenseContact[17] + '\r\n';
                 CSLicenseContact[18] = 'City: ' + CSLicenseContact[18] + '\r\n';
                 CSLicenseContact[19] = 'Zip Code: ' + CSLicenseContact[19] + '\r\n';
                 CSLicenseContact[20] = 'Email: ' + CSLicenseContact[20] + '\r\n';
                 CSLicenseContact[21] = 'Phone: ' + CSLicenseContact[21] + '\r\n';
                 CSLicenseContact[22] = 'Extension: ' + CSLicenseContact[22] + '\r\n';
                 CSLicenseContact[23] = 'Fax: ' + CSLicenseContact[23] + '\r\n';
                 CSLicenseContact[24] = 'Mobile Phone ' + CSLicenseContact[24] + '\r\n\r\n';
                 CSLicenseContact[25] = 'Notes: \r\n ' + CSLicenseContact[25];
                 if (caseObj.Subject == 'Add a new administrator'){
                     
                    for (Integer i = 0; i < CSLicenseContact.size(); i++){
                        if (i == 0 || i == 1 || i > 6){
                            caseObj.Description += CSLicenseContact[i];
                        }
                    }
                 }
                 else if (caseObj.Subject == 'Change an existing administrator'){
                     
                    for (Integer i = 0; i < CSLicenseContact.size(); i++){
                            caseObj.Description += CSLicenseContact[i];
                    }
                 }
                 else if (caseObj.Subject == 'Remove an existing administrator'){
                     
                    for (Integer i = 0; i < CSLicenseContact.size(); i++){
                        if (i <7 || i == 25){
                            caseObj.Description += CSLicenseContact[i];
                        }
                    }
                 }
          
            }
            else if (selTask == 'RedesignateProducts'){
                  string[] transfer = new list <String>{'','','','',''};
                  map <string,list<string>> transferMap = new map <string,list<string>>();
                  transferMap.put('CSTransfer1',CSTransfer1); //Transfer #1
                  transferMap.put('CSTransfer2',CSTransfer2); //Transfer #2
                  transferMap.put('CSTransfer3',CSTransfer3); //Transfer #3
                  transferMap.put('CSTransfer4',CSTransfer4); //Transfer #4
                  transferMap.put('CSTransfer5',CSTransfer5); //Transfer #5
                  list <string> transferMapkeys = new list <string>();
                  transferMapkeys.addAll(transferMap.keySet());
                  transferMapKeys.sort();
                  Integer tctr=0; Integer ctr=1;
                  //Populate Description from Customer Support Redesignate (transfer) products between licenses
                  for (String trs : transferMapKeys){
                    if (transferMap.containskey(trs) ){
                        if (transferMap.get(trs)[0] != ''){
                            transferMap.get(trs)[0] = 'Transfer Product Name ' + ctr + ':' + transferMap.get(trs)[0];
                            transferMap.get(trs)[1] = 'Quantity ' + ctr + ': ' + transferMap.get(trs)[1];
                            transferMap.get(trs)[2] = 'From ' + ctr + ': ' + transferMap.get(trs)[2];
                            transferMap.get(trs)[3] = 'To ' + ctr + ': ' + transferMap.get(trs)[3];
                            transfer[tctr] = transferMap.get(trs)[0] + '\r\n\r\n' +
                                             transferMap.get(trs)[1] + '\r\n\r\n' + 
                                             transferMap.get(trs)[2] + '\r\n\r\n' + 
                                             transferMap.get(trs)[3];
                            ctr++;
                        }  
                    }
                    tctr++; 
                  }
                  
          		 caseObj.Subject = 'Combine Licenses/Transfer products between licenses';
                 //HW, 1637556 
              	 //caseObj.Topic__c = 'Activation';
              	 //caseObj.Sub_Topic__c = 'Redesignate';
              	 caseObj.Topic__c = 'License Modifications';
              	 caseObj.Sub_Topic__c = 'Product Move/Transfer'; //HW 1895503
                  if (isDistributor){                         
                     
                      String preDescription = 'Customer First Name: ' + CSCustomerInfo[0]; 
                      preDescription += '\r\n Customer Last Name: ' + CSCustomerInfo[1];
                      preDescription += '\r\n Customer Email: ' + CSCustomerInfo[2] + '\r\n\r\nNotes:\r\n';
                      caseObj.Description = preDescription + caseObj.Description + '\r\n\r\n';
                  }
                  for (integer i=0; i<transfer.size();i++){
                    if (transfer[i] != ''){
                        caseObj.Description = transfer[i] + '\r\n' + caseObj.Description;
                    }
                  }
            }
            else if(selTask == 'CombineLicenses'){
                 if (isDistributor){
                     
                      String preDescription = 'Customer First Name: ' + CSCustomerInfo[0]; 
                      preDescription += '\r\n Customer Last Name: ' + CSCustomerInfo[1];
                      preDescription += '\r\n Customer Email: ' + CSCustomerInfo[2] + '\r\n\r\nNotes:\r\n';
                      caseObj.Description = preDescription + caseObj.Description;
                 }
                 for (Integer i=0; i < CSCombineLic.size(); i++){
                     //Populate Description from Customer Support PassCode request
                     if (CSCombineLic[i] != ''){
                        if (i == 0) CSCombineLic[i] = '\r\n Surviving License: ' + CSCombineLic[i];
                        else if (i == 1) CSCombineLic[i] = '\r\n List Licenses to Combine: \r\n' + CSCombineLic[i];
                        else if (i == 2) CSCombineLic[i] = '\r\n Host ID: ' + CSCombineLic[i] + '\r\n';
                        caseObj.Description += CSCombineLic[i] + '\r\n';
                     }
                 }
            }
            else if (selTask == 'GeneralCustomerService'){
          		caseObj.Subject = 'General CS Request (Activation, Invoice, etc.)';
                if (isDistributor){
                    
                    String preDescription = 'Customer First Name: ' + CSCustomerInfo[0]; 
                    preDescription += '\r\n Customer Last Name: ' + CSCustomerInfo[1];
                    preDescription += '\r\n Customer Email: ' + CSCustomerInfo[2] + '\r\n\r\nNotes:\r\n';
                    caseObj.Description = preDescription + caseObj.Description;
                } 
            }
            system.debug('@@selTask:'+selTask);
            system.debug('@@Description:'+caseObj.Description);
        try{
            con = new Contact();
            ConfieldMap = Schema.SObjectType.Contact.fields.getMap();
            //Forwarding_Rule__c fwdRule = new Forwarding_Rule__c();
            if (TheUser.ContactId != null){
                String theQuery = 'Select Account.Name, ';
                String conID = TheUser.ContactId;
                for (Schema.Sobjectfield field : ConfieldMap.values()){
                    //do not add MaillingAddress or OtherAddress to the query because they are compound fields and not queryable in this way
                    if(field.getDescribe().getName()!= 'MailingAddress' && field.getDescribe().getName()!= 'OtherAddress'){
                        theQuery+= field.getDescribe().getName() + ',';
                    }
                }
                theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
                theQuery+= ' FROM Contact Where id = : conID';
                con = database.query(theQuery);
            }
            
            if (TheUser.Country_Code__c != null){
                fwdRule = Forwarding_Rule__c.getValues(TheUser.Country_Code__c.toLowerCase());
                if(fwdRule!= null){
                    distributoremailaddress = fwdRule.Forwarding_Email_Address__c;                  
                    system.debug('@@distributoremailaddress:'+distributoremailaddress);
                }
            }
            
            //Prevent updating of substatus trigger to execute
            CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
            
            /* Changed by jaspreet on 5/13/2014 
             Commented stopUpdateSubStatus method so that status of all type of cases should change to in progress 
             */
            
            //cseTrigHandler.stopUpdateSubStatus(); 
            if (!Test.isRunningTest()){
                //Fetching the assignment rules on case
                AssignmentRule AR = new AssignmentRule();
                AR = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true];
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                //Setting the DMLOption on Case instance
                caseObj.setOptions(dmlOpts);
            }
            caseObj.SubStatus__c= 'In Progress';
            if(Test.IsRunningTest() && cp_case_new_controllerextension.skipUpdateCaseArea) {
                caseObj.Area__c = null;
            } else {
                caseObj.Area__c = updateCaseArea();
            }
            
            if(selTask == 'Producthelp'){
                System.debug('selTask == ProducthelpIN IF'+selTask);
                caseObj.sub_area__c = updateCaseSubArea();
            }
            
            //HW, sprint 2016.7.2, story 1595166
            /*
            if (isStudent){
                //caseObj.License__c = 'STUDENT';
                caseObj.License_Type__c = 'Student Version';
            }
            else{
                caseObj.License_Type__c = (caseObj.License__c!=null ? 'Professional' : 'No License Number');
            }*/
            
            if (caseObj.Area__c != null){
                if(isDistributor){
                    caseObj.Subject = 'DISTRIBUTOR:'+ caseObj.Subject;
                }
                System.debug('**BeforeInsertcaseObj**'+caseObj);
                
                //HW, sprint 2016.8.2, 1618935
                if (caseObj.description.length() >= 32000) {
	                caseObj.description = caseObj.description.substring(0,31999);
                }
                //1618935
                
                insert caseObj;
                System.debug('**AfterInsertcaseObj**'+caseObj);

			    //HW 1776003
			    if (cdObj != null) {
			    	cdObj.Case__c = caseObj.Id;
				    try {
				    	update cdObj;
				    } catch(exception ex) {
				        System.Debug('@@Exception updating Case_Deflection__c:'+ex.getMessage());
				        Logger.debugException(ex);
				    }
			    }
			    //HW 1776003

                //Add attachments to Case
                list <Attachment> newCaseAttachments = new list <Attachment>();
                //Attachmens on Add More
                for (Attwrapper attwr : Attwrapperlist){
                    if (attwr.attBody != null && attwr.attBody.size() > 0){
                        string remname = 'C:\\fakepath\\'; //remove fakepath on attachment name
                        string fixedName = String.valueof(attwr.attName).replace(remname,'');
                        string contType = (String.isEmpty(String.valueof(attwr.attContType))) ? 'text/plain; charset=UTF-8' : String.valueof(attwr.attContType) + '; charset=UTF-8';
                        System.debug('Checking the content type in string ' +String.valueof(attwr.attContType));
                        System.debug('Checking the content type in variable contType '+contType);
                        Attachment att = new Attachment(
                                        parentId = caseObj.Id,
                                        Body = attwr.attBody,
                                        ContentType = contType,
                                        Name = fixedName
                                        );
                        newCaseAttachments.add(att);
                        attwr.attBody = null;
                    }
                }
                //Attachment on Output of ver command textArea
                if (outputver != null && outputver != ''){ // Added  outputver != '' by Jaspreet Singh to check empty text
                    attoutputver.Name = 'output_of_ver.txt';
                    attoutputver.Body = Blob.valueof(outputver);
                    attoutputver.parentId = caseObj.Id;
                    attoutputver.ContentType = 'text/plain; charset=UTF-8'; //SS 12/10/15 Story: 1201100
                    newCaseAttachments.add(attoutputver);
                }
                //Attachment on License.dat
                if (attlicensedatBody != null){
                    attlicensedat.Body = attlicensedatBody;
                    attlicensedat.parentId = caseObj.Id;
                    //set the name of attachment only for the test class/method
                    if(Test.isRunningTest()){                    
                        attlicensedat.Name = 'License.txt';
                    }
                   
                    newCaseAttachments.add(attlicensedat);
                    attlicensedatBody = null;
                    attlicensedat = null;
                }
                //Attachment on Lmdebug
                if (attlmdebugoutBody != null){
                    attlmdebugout.Body = attlmdebugoutBody;
                    attlmdebugout.parentId = caseObj.Id;
                    //set the name of attachment only for the test class/method
                    if(Test.isRunningTest()){                    
                        attlmdebugout.Name = 'lmdebug.txt';
                    }
                    newCaseAttachments.add(attlmdebugout);
                    attlmdebugoutBody = null;
                    attlmdebugout = null;
                    
                }
                //Attachment on Output of Errors textArea
                if (outputerr != null && outputerr != ''){
                    attoutputerror.Name = 'output_of_errors.txt';
                    attoutputerror.Body = Blob.valueof(outputerr);
                    attoutputerror.parentId = caseObj.Id;
                    attoutputerror.ContentType = 'text/plain; charset=UTF-8'; //SS 12/10/15 Story: 1201100
                    newCaseAttachments.add(attoutputerror);
                }
                
                
                //Insert attachments on Case
                if (newCaseAttachments.size() > 0 ){
                    
                try{
                    insert newCaseAttachments;
                   }
                   catch(exception ex)
                   {
                    System.Debug('@@Exception inserting attachments:'+ex.getMessage());
                    apexpages.Message msg;
                    msg = new Apexpages.Message(ApexPages.Severity.Info,'Attachment file size can not be greater than 5 MB');
                    apexpages.addmessage(msg);
                    Logger.debugException(ex);
                    Logger.pop();
                    return null;
                   }
                }
                
                //Technical Support task pages will be redirected to a blank page
                if (selTask == 'Installation' || selTask == 'Producthelp'){
                    //Redirect page to a blank to refresh parent page for allowing attachments
                    PageReference pg = new PageReference('/apex/cp_Case_new_ts_attachments_fix?cc='+ApexPages.currentPage().getParameters().get('cc'));
                    pg.getParameters().put('de',distributoremailaddress);
                    system.debug('@@@@@:'+distributoremailaddress);
                    pg.getParameters().put('id',caseObj.Id);
                    pg.setredirect(true);
                    Logger.pop();
                    return pg;
                }
                //Customer Service task pages will perform redirect of page on OnComplete
                else {
                	Logger.pop();
                    return null;    
                }
            }
            else {
                //Customer portal did not create a Case, will redirect on some page
                if (selTask == 'Installation' || selTask == 'Producthelp'){
                    PageReference pg = new PageReference('/apex/cp_Case_new_ts_attachments_fix?cc='+ApexPages.currentPage().getParameters().get('cc'));
                    pg.getParameters().put('de',distributoremailaddress);
                    system.debug('@@@@@:'+distributoremailaddress);
                    pg.getParameters().put('id',caseObj.Id);
                    pg.setredirect(true);
                    Logger.pop();
                    return pg;
                }
                else {
                	Logger.pop();
                    return null;    
                }
            }
        }catch(Exception ex){
            System.Debug('Exception in createCase method:'+' ('+ex.getLineNumber()+')'+ex.getMessage());
            Logger.debugException(ex);
        }
        Logger.pop();
        return null;
        
    }
    
    public List<SelectOption> getCountries(){
    	Logger.push('getCountries','cp_Case_new_ControllerExtension');
        list <SelectOption> options = new List<SelectOption>();
        
        //Retrieve all the countries in the custom setting CountryList
        map <String, Country_List__c> countrylist = Country_List__c.getAll();
        //Sort all Countries by Name
        list <String> countryNames = new list<String>();
        countryNames.addAll(countrylist.keySet());
        countryNames.sort();
        
        //Create the Select Options
        Integer ctr=0;
        for (String countryName : countryNames) {
            Country_List__c country = countrylist.get(countryName);
            options.add(new SelectOption(country.Country_Code__c, country.Name));
            if (countryName == 'United States') {
            	CSLicenseContact[7] = country.Country_Code__c;
            }
        }
        Logger.pop();
        return options;
    }
    
    public List<SelectOption> getSalutations(){
    	Logger.push('getSalutations','cp_Case_new_ControllerExtension');
        Salutations = new List<SelectOption>();
        for(String lval: UtilityHelper.getFieldPickListValues('Contact', 'Salutation')){
            Salutations.add(new SelectOption(lval,lval));
        }
        Logger.pop(); 
        return Salutations;
    }
    
    public List<SelectOption> getReleases(){
    	Logger.push('getReleases','cp_Case_new_ControllerExtension');
        Releases = new List<SelectOption>();
        Releases.add(new selectOption('', '-- Select Release --'));
        for(Release__c rel: [Select Name, release_type__c from release__c where Show_in_portal__c=true order by Sort_Order_in_Portal__c desc]){
            Releases.add(new SelectOption(rel.Name,rel.Name));
        }
        
        SelectedRelease = '-- Select Release --';
        Logger.pop();
        return Releases;
    }
    
     public PageReference refreshProductList(){
     	Logger.push('refreshProductList','cp_Case_new_ControllerExtension');
         Boolean hasMatlab = false;
         Boolean hasSimulink = false;
         SelectOption[] productList = new List<SelectOption>();
         SelectOption matlabOption;
         SelectOption simulinkOption;
         allProductList.clear();
         allProductList.add(new selectOption('', '-- Select Product--'));
         System.Debug('selected Release::'+SelectedRelease);
           if (String.isNotEmpty(SelectedRelease)){
         for(product2 prod: [Select Id, Name, product_name__c, Version__c from Product2 where release__c= :SelectedRelease and Hide_on_Portal__c <> true order by Name Asc]){
             if(prod.Name.equalsIgnoreCase('matlab')){
                 hasMatlab = true;
                 //allProductList[1] = new SelectOption(prod.Id,prod.Name);
                 matlabOption =  new SelectOption(prod.Id,prod.Name);
             }
             else if(prod.Name.equalsIgnoreCase('simulink')){
                 hasSimulink = true;
                 //allProductList[2] = new SelectOption(prod.Id,prod.Name);
                 simulinkOption = new SelectOption(prod.Id,prod.Name);
             }            
             else
                 productList.add(new SelectOption(prod.Id,prod.Name));
         }
         if(hasMatlab){
             allProductList.add(matlabOption);
         }
         if(hasSimulink){
             allProductList.add(simulinkOption);
         }
     }
        allProductList.addAll(productList);
        Logger.pop();
        return null;
    }
   
  
    public string updateCaseArea(){
    	Logger.push('updateCaseArea','cp_Case_new_ControllerExtension');
    	System.debug('**fwdRule **'+fwdRule);
        if (fwdRule != null){
            system.debug('@@crit1');
            system.debug('*MathWorks_Office__c***'+fwdRule.MathWorks_Office__c);
           
             system.debug('*isDistributor***'+isDistributor);
             
            if(!fwdRule.MathWorks_Office__c && !isDistributor){
                //CaseObj.status = 'Cancelled';
                //CaseObj.substatus__c = null;
                
                //Forward an email to the distributor; will not create a case
                String emailsubject = 'Web Service Request - '+fwdRule.Forwarding_Email_Address__c;
                List <EmailTemplate> emailTempList = [SELECT Name, Body, Subject, Id FROM EmailTemplate WHERE Name LIKE '%Distributor Send Email%'];
                String tempEmailBody = emailTempList[0].Body;
                System.debug('**tempEmailBody**'+tempEmailBody );
                //Replace all Contact Merge Fields
                while (tempEmailBody.contains('{!Contact.') == true){
                    if(tempEmailBody.contains('{!Contact.')){
                        for (Schema.Sobjectfield field : ConfieldMap.values()){
                            system.debug('@@field:'+field);
                            String mergefstring =  tempEmailBody.substring(tempEmailBody.indexOf('{'), tempEmailBody.indexOf('}') + 1);
                            system.debug('@@mergefstring:'+mergefstring);
                            if (mergefstring == '{!Contact.Account}'){
                                string mergefvalue;
                                if (con.AccountId != null){
                                    tempEmailBody = tempEmailBody.replace(mergefstring,con.Account.Name);   
                                }
                                else {
                                    tempEmailBody = tempEmailBody.replace(mergefstring,'');
                                }
                                break;
                            }
                            if (mergefstring == '{!Contact.MailingAddress}'){
                                string mergefvalue;
                                string mailingstreet = '';
                                string mailingcity = ''; 
                                string mailingstate = '';
                                string mailingpostalcode = '';
                                string mailingcountry = '';
                                if (con.MailingStreet != null){ mailingStreet = con.MailingStreet; }
                                if (con.MailingCity != null){ mailingCity = con.MailingCity; }
                                if (con.MailingState != null){ mailingState = con.MailingState; }
                                if (con.MailingPostalCode  != null){ mailingPostalCode = con.MailingPostalCode; }
                                if (con.MailingCountry != null){ mailingCountry = con.mailingCountry; }
                                string mailingaddress = mailingstreet + ' ' + mailingcity + ' ' + mailingstate + ' ' + mailingpostalcode + ' ' + mailingcountry;
                                if (con.AccountId != null){
                                    tempEmailBody = tempEmailBody.replace(mergefstring,mailingaddress); 
                                }
                                else {
                                    tempEmailBody = tempEmailBody.replace(mergefstring,'');
                                }
                                break;
                            }
                            if ( mergefstring.contains( field.getDescribe().getName() ) ){
                                string mergefvalue;
                                if (con.get(field.getDescribe().getName()) == null){
                                    mergefvalue = '';
                                }
                                else {
                                    mergefvalue = String.valueof( con.get(field.getDescribe().getName() ) );
                                }
                                tempEmailBody = tempEmailBody.replace(mergefstring,mergefvalue);
                                break;
                            }
                        }
                    }
                }
                //Replace all identified Case merge fields
                if(tempEmailBody.contains('{!Case.Subject}')){
                    tempEmailBody = tempEmailBody.replace('{!Case.Subject}', emailsubject);
                }
                
                if(tempEmailBody.contains('{!Case.Product_Lookup__c}')){
                    list <Product2> prod = [Select Id,Name, Release__c, Version__c From Product2 Where Id = : CaseObj.Product_Lookup__c limit 1];
                    if (CaseObj.Product_Lookup__c != null){
                        tempEmailBody = tempEmailBody.replace('{!Case.Product_Lookup__c}', prod[0].Name);
                        if(tempEmailBody.contains('{!Case.Release__c}')){
                            if (prod.size() > 0){
                                if (prod[0].Release__c != null){
                                    tempEmailBody = tempEmailBody.replace('{!Case.Release__c}', prod[0].Release__c);
                                }
                            }
                            /*else{
                                tempEmailBody = tempEmailBody.replace('{!Case.Release__c}', '');
                            } */
                        }
                        if(tempEmailBody.contains('{!Case.Version__c}')){
                            if (prod.size() > 0 ){
                                if (prod[0].Version__c != null){
                                    tempEmailBody = tempEmailBody.replace('{!Case.Version__c}', prod[0].Version__c);
                                }
                            }
                            /*else{
                                tempEmailBody = tempEmailBody.replace('{!Case.Version__c}', '');
                            } */
                        }
                    }
                    else {
                        tempEmailBody = tempEmailBody.replace('{!Case.Product_Lookup__c}', '');
                        if(tempEmailBody.contains('{!Case.Release__c}')){
                            tempEmailBody = tempEmailBody.replace('{!Case.Release__c}', '');
                        }
                        if(tempEmailBody.contains('{!Case.Version__c}')){
                            tempEmailBody = tempEmailBody.replace('{!Case.Version__c}', '');
                        }
                    }
                }
                if(tempEmailBody.contains('{!Case.Platform__c}')){
                    if (CaseObj.Platform__c != null){
                        tempEmailBody = tempEmailBody.replace('{!Case.Platform__c}', CaseObj.Platform__c);
                    }
                    else{
                        tempEmailBody = tempEmailBody.replace('{!Case.Platform__c}', '');
                    }
                }
                if(tempEmailBody.contains('{!Case.OS__c}')){
                    if (CaseObj.OS__c != null){
                        tempEmailBody = tempEmailBody.replace('{!Case.OS__c}', CaseObj.OS__c);
                    }
                    else{
                        tempEmailBody = tempEmailBody.replace('{!Case.OS__c}', '');
                    }
                }
                if(tempEmailBody.contains('{!Case.License__c}')){
                    if (CaseObj.License__c != null){
                        tempEmailBody = tempEmailBody.replace('{!Case.License__c}', CaseObj.License__c);
                    }
                    else{
                        tempEmailBody = tempEmailBody.replace('{!Case.License__c}', '');
                    }
                }
                if(tempEmailBody.contains('{!Case.Description}')){
                    tempEmailBody = tempEmailBody.replace('{!Case.Description}', CaseObj.Description);
                }
                
                String[] DistributorToAddress = new list <String>();
                DistributorToAddress.add(fwdRule.Forwarding_Email_Address__c);
                //DistributorToAddress.add('jbaculod@cloudsherpas.com');
                
                String[] CustomerToAddress = new list <String>();
                CustomerToAddress.add(con.Email);
                
                list <Messaging.Emailfileattachment> efalist = new list <Messaging.Emailfileattachment>();
                //Attachments from addmore
                for (Attwrapper attwr : Attwrapperlist){
                    if (attwr.attBody != null){
                        string remname = 'C:\\fakepath\\'; //remove fakepath on attachment name
                        string fixedName = String.valueof(attwr.attName).replace(remname,'');
                        Messaging.Emailfileattachment efaadd = new Messaging.Emailfileattachment();
                        efaadd.setFileName(fixedName);
                        efaadd.setBody(attwr.attBody);
                        efaadd.setInline(false);
                        efalist.add(efaadd);
                        attwr.attBody = null;
                    }
                }
                //Attachment from lmdebugout
                if (attlmdebugoutBody != null){
                    Messaging.Emailfileattachment efadebugout = new Messaging.Emailfileattachment();
                    efadebugout.setFileName(attlmdebugout.Name);
                    efadebugout.setBody(attlmdebugoutBody);
                    efadebugout.setInline(false);
                    efalist.add(efadebugout);
                    attlmdebugoutBody = null;
                }
                //Attachment from license.dat
                if (attlicensedatBody != null){
                    Messaging.Emailfileattachment efalicensedat = new Messaging.Emailfileattachment();
                    efalicensedat.setFileName(attlicensedat.Name);
                    efalicensedat.setBody(attlicensedatBody);
                    efalicensedat.setInline(false);
                    efalist.add(efalicensedat);
                    attlicensedatBody = null;
                }
                //Attachment from output ver command 
                if (outputver != null && outputver != ''){ // Added  outputver != '' by Jaspreet Singh 
                    Messaging.Emailfileattachment efaoutputver = new Messaging.Emailfileattachment();
                    efaoutputver.setFileName('output_of_ver.txt');
                    efaoutputver.setBody(Blob.valueof(outputver));
                    efaoutputver.setInline(false);
                    efalist.add(efaoutputver);
                    outputver = null;
                }
                //Attachment from output errors
                if (outputerr != null && outputerr != ''){
                    Messaging.Emailfileattachment efaoutputerr = new Messaging.Emailfileattachment();
                    efaoutputerr.setFileName('output_of_error.txt');
                    efaoutputerr.setBody(Blob.valueof(outputerr));
                    efaoutputerr.setInline(false);
                    efalist.add(efaoutputerr);
                    outputerr = null;
                }
                system.debug('@@efalist:'+efalist+efalist.size());
                //Set email for Distributor
                Messaging.Singleemailmessage mailsendtoDistributor = new Messaging.Singleemailmessage();
                mailsendtoDistributor.setReplyTo(con.Email);
                mailsendtoDistributor.setSubject(emailsubject);
                mailsendtoDistributor.setToAddresses(DistributorToAddress);
                mailsendtoDistributor.setPlainTextBody(tempEmailBody);
                if (efalist.size() > 0){
                    mailsendtoDistributor.setFileAttachments(efalist);
                }
                
                //Set email for Customer
                Messaging.Singleemailmessage mailsendToCustomer = new Messaging.Singleemailmessage();
                mailsendToCustomer.setSubject(emailsubject);
                mailsendToCustomer.setToAddresses(CustomerToAddress);
                mailsendToCustomer.setPlainTextBody(tempEmailBody);
                if (efalist.size() > 0){
                    mailsendToCustomer.setFileAttachments(efalist);
                }
                
                //Send email to distributor
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailsendtoDistributor });
                //Send email to customer
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailsendToCustomer });
                
                CaseObj.Area__c = null;
                
            }
            else{
             System.debug('**selTask IN Else **'+selTask );
                //Populate Area if selected task is on CS - option 1-6
                for (String selTaskCS : selTaskCSlist){
                    if (selTask == selTaskCS){
                        CaseObj.Area__c = fwdRule.Case_Area_Country_Code__c +' - Customer Support';
                        break;                      
                    }
                }
                //Populate Area if selected task is on TS - option 1
                System.debug('***selTask 822 ***'+selTask );
                if (selTask == 'Installation'){
                System.debug('**selTask **'+selTask );
                    System.debug('**fwdRule.Case_Area_Country_Code__c**'+fwdRule.Case_Area_Country_Code__c);
                    CaseObj.Area__c = fwdRule.Case_Area_Country_Code__c +' - Install';
                    System.debug('**CaseObj.Area__cAfter**'+CaseObj.Area__c);
                    
                }
                //Populate Area if selected task is on TS - option 2
                else if (selTask == 'Producthelp'){
                    CaseObj.Area__c = fwdRule.Case_Area_Country_Code__c +' - Technical Support';
                }
            }
            
        }
        else{
            system.debug('@@crit2');
            //Populate Area if selected task is on CS - option 1-6
            for (String selTaskCS : selTaskCSlist){
                if (selTask == selTaskCS){
                    CaseObj.Area__c = 'Natick - Customer Support';
                    break;                      
                }
            }
            //Populate Area if selected task is on TS - option 1
            if (selTask == 'Installation'){
                System.debug('**selTask**'+selTask );
                CaseObj.Area__c = 'Natick - Install';
            }
            //Populate Area if selected task is on TS - option 2
            else if (selTask == 'Producthelp'){
                CaseObj.Area__c = 'Natick - Technical Support';
            }
        }
        
        system.debug('@@Area:'+CaseObj.Area__c);
        Logger.pop();
        return CaseObj.Area__c;
        
        
    }
    
    public string updateCaseSubArea(){
    	Logger.push('updateCaseSubArea','cp_Case_new_ControllerExtension');
        Product2 prod = null;
                If(CaseObj.product_lookup__c != null){                   
                  Product2 prod1 = [Select Name, Id,ProductCode  from Product2 where Id = :CaseObj.Product_Lookup__c limit 1];
                     
                     // modified by Jaspreet To filter by product code
                     if(prod1 !=null){
                         prod = [Select Id, release__C, Portal_Sub_Area__c from Product2 where ProductCode = :prod1.ProductCode and release__c = 'No Release' limit 1];
                     } 
                }
                        
        if(prod != null){
            CaseObj.sub_area__c = prod.Portal_Sub_Area__c;
        }
        Logger.pop();
        return CaseObj.sub_area__c;
    }
    
     //Initiated by Haigang Wu on 04/21/2016, for Sprint 2016.5.1, story 1259147
     public PageReference refreshProductRelease(){
        Logger.push('refreshProductRelease','cp_Case_new_ControllerExtension');
        if (outputver.trim().length() <= 0) {
            //outputver = 'Invalid ver conmmand output \n\n' + outputver;
            isValidVer = false;
            CaseObj.License__c = null;
            getReleases();
            refreshProductList();
            Logger.pop();
            return null;
        }

        //Extract release and perform quick validation. 
        string strRelease = outputver.substringAfter('(').substringBefore(')').trim();
        if (strRelease.length() <= 0) {
            //outputver = 'Invalid ver conmmand output \n\n' + outputver;
            isValidVer = false;
            CaseObj.License__c = null;
            getReleases();
            refreshProductList();
            Logger.pop();
            return null;
        }

        //Extract License Number. 
        string strLicenseNum = outputver.substringAfter(':').substringAfter(':').substringBefore('\n').trim();
            if ((strLicenseNum.length() > 1 && strLicenseNum.length() <= 10 ) && //SS 9/23/16 1642886 - added additional criteria for license number population
            (strLicenseNum.isNumeric() || strLicenseNum.toUpperCase() == 'STUDENT' || strLicenseNum.toUpperCase() == 'DEMO' ) ) {
        	isValidVer = true;
            CaseObj.License__c = strLicenseNum;
        } else {
            isValidVer = false;
        }
        
        List<Release__c> lstRelease = [Select Id from release__c where Name =: strRelease and Show_in_portal__c=true limit 1];
        if (lstRelease.size() <= 0) {
            //outputver = 'Release not found \n\n' + outputver;
            getReleases();
            refreshProductList();
            Logger.pop();
            return null;
        }
        
        //Set default release
        Releases = new List<SelectOption>();
        Releases.add(new selectOption('', '-- Select Release --'));
         Map<Id, Release__c> mapRel = new Map<Id, Release__c>([
         	Select Id, Name, release_type__c from release__c where Show_in_portal__c=true order by Sort_Order_in_Portal__c desc limit 10000]);
         
         Map<string, Id> mapNameIdRel = new Map<string, Id>();
         for (Release__c rel : mapRel.values()) {
         	mapNameIdRel.put(rel.Name.toLowerCase(), rel.Id);
         }
         if (mapNameIdRel.containsKey(strRelease.toLowerCase())) {
         	string strRelName = mapRel.get(mapNameIdRel.get(strRelease.toLowerCase())).Name;
         	Releases.add(new SelectOption(strRelName,strRelName));
	        Releases.add(new selectOption('', '', true));
            mapRel.remove(mapNameIdRel.get(strRelease.toLowerCase()));
            SelectedRelease = strRelName;
         }

        for(Release__c rel: mapRel.values()){
            Releases.add(new SelectOption(rel.Name,rel.Name));
        }
        

        //Extract and set default Product 
         Boolean hasVer = false;
         Boolean hasMatlab = false;
         Boolean hasSimulink = false;
         SelectOption[] productList = new List<SelectOption>();
         SelectOption verOption;
         SelectOption matlabOption;
         SelectOption simulinkOption;
         allProductList.clear();
         allProductList.add(new selectOption('', '-- Select Product--'));
         
         Map<Id, product2> mapProd = new Map<Id, product2>([
         	Select Id, Name, product_name__c, Version__c from Product2 where release__c= :strRelease and Hide_on_Portal__c <> true order by Name Asc limit 10000]);
		 system.debug('mapProd >>>>>>>' + mapProd );         	
         
         Map<string, Id> mapNameId = new Map<string, Id>();
         for (product2 prod : mapProd.values()) {
         	mapNameId.put(prod.Name.toLowerCase(), prod.Id);
         }
		 system.debug('mapNameId >>>>>>>' + mapNameId );         	
         	
        string str = outputver.substringAfterLast('-----\n');
        while (str.length() > 0) {
            string strProd = str.substringBefore('    ').trim().toLowerCase();

            //HW, sprint 2016.8.2, 1618995, add the condition after &&
            if (mapNameId.containsKey(strProd) && mapProd.containsKey(mapNameId.get(strProd))) {
        	//1618995
            	hasVer = true;
            	verOption = new SelectOption(mapProd.get(mapNameId.get(strProd)).Id, mapProd.get(mapNameId.get(strProd)).Name);
		 		system.debug('verOption >>>>>>>' + verOption );    
		 		allProductList.add(verOption);     	
            	mapProd.remove(mapNameId.get(strProd));
            }
            str = str.substringAfter('\n');
        }
         if(hasVer){
             allProductList.add(new selectOption('', '', true));
         }
         
         for(product2 prod : mapProd.values()) {
         	system.debug('prod.Name >>>>>>>' + prod.Name ); 
             if(prod.Name.equalsIgnoreCase('matlab')){
                 hasMatlab = true;
                 //allProductList[1] = new SelectOption(prod.Id,prod.Name);
                 matlabOption =  new SelectOption(prod.Id,prod.Name);
             }
             else if(prod.Name.equalsIgnoreCase('simulink')){
                 hasSimulink = true;
                 //allProductList[2] = new SelectOption(prod.Id,prod.Name);
                 simulinkOption = new SelectOption(prod.Id,prod.Name);
             }            
             else
                 productList.add(new SelectOption(prod.Id,prod.Name));
         }
         if(hasMatlab){
             allProductList.add(matlabOption);
         }
         if(hasSimulink){
             allProductList.add(simulinkOption);
         }
         allProductList.addAll(productList);
         
		Logger.pop();
		return null;
    }

    //HW, 1656885
    //DMA,2245014 Adding Case_Deflection__c.Type__c to capture what type of Case was being logged by user
    public PageReference fetchSuggestedArticles() {
    	Logger.push('fetchSuggestedArticles','cp_Case_new_ControllerExtension');
    	isDisplaySuggestedArticles = false;
    	iSuggestedContentFeedbackStep = 1;
    	if (CaseObj.Subject.trim().length() <= 0 || language != 'en_US') {
    		Logger.pop();
    		return null;
    	}
	    strKeywords = String.escapeSingleQuotes(CaseObj.Subject.trim());
	    General_Settings__c settings;
	    settings = General_Settings__c.getInstance();
	    iSuggestedContentLimit = Integer.valueOf(settings.SuggestedContentLimit__c);
	    iSuggestedContentSummaryLength = Integer.valueOf(settings.SuggestedContentSummaryLength__c);
	    isSuggestedContentDisplaySummary = settings.SuggestedContentDisplaySummary__c;
	    strSuggestedContentRedirectUrl = settings.SuggestedContentRedirectUrl__c;
	    string strCaseDeflectionOwnerQueueName = settings.CaseDeflectionOwnerQueueName__c;
	    
	    if(Test.isRunningTest()) return null;
	    results = [FIND :strKeywords IN ALL FIELDs Returning FAQ__kav(ID, Title, Summary, Answers_URL_with_Postfix__c WHERE PublishStatus = 'Online' AND Language = 'en_US' AND Answers_URL__c != null LIMIT :iSuggestedContentLimit)] [0];

	    if (results.size() > 0) {
		    for (FAQ__kav faq : results) {
		    	if (string.isNotBlank(faq.Summary)) {
			    	if (isSuggestedContentDisplaySummary) {
				    	if (faq.Summary.length() > iSuggestedContentSummaryLength) {
					    	faq.Summary = faq.Summary.substring(0, iSuggestedContentSummaryLength) + '...';
				    	}
				    	faq.Summary = '- ' + faq.Summary;
			    	} else {
			    		faq.Summary = '';
			    	}
		    	}
		    }
	    	isDisplaySuggestedArticles = true;

		    //HW 1776003
		    if (cdObj == null) {
		    	//Create Case_Deflection__c
		    	cdObj = new Case_Deflection__c();
		    	cdObj.Subject__c = strKeywords;
                cdObj.Type__c = caseType;  //DMA 2245014
		    	if (strCaseDeflectionOwnerQueueName != null) {
			    	cdObj.OwnerId = [SELECT Id FROM Group WHERE name =: strCaseDeflectionOwnerQueueName AND Type = 'Queue' LIMIT 1][0].Id;
		    	}
			    try {
			    	insert cdObj;
			    	cdObjId = cdObj.id;
			    } catch(exception ex) {
			        System.Debug('@@Exception inserting Case_Deflection__c:'+ex.getMessage());
			        Logger.debugException(ex);
			    }
		    	
		    } else {
		    	//Update Case_Deflection__c
		    	cdObj.Subject__c = strKeywords;
                cdObj.Type__c = caseType; //DMA 2245014
			    try {
			    	update cdObj;
			    } catch(exception ex) {
			        System.Debug('@@Exception updating Case_Deflection__c:'+ex.getMessage());
			        Logger.debugException(ex);
			    }
		    }
	    
	    } else {
	    	//If no suggested articl found, delete Case_Deflection__c if exists
	    	if (cdObj != null) {
			    try {
			    	delete cdObj;
			    	cdObj = null;
			    } catch(exception ex) {
			        System.Debug('@@Exception deleting Case_Deflection__c:'+ex.getMessage());
			        Logger.debugException(ex);
			    }
	    	}	
	    }
	    //HW 1776003
	    
	    Logger.pop();
        return null;
    }

    //HW 1776003
	@RemoteAction
    global static void passArticleIdRemote(string articleId, string articleTitle, string caseDeflectionId) {
    	Logger.push('passArticleIdRemote','cp_Case_new_ControllerExtension');
    	system.debug('>>>>>>>>> articleId: ' + articleId + ' >>>>>>>>> caseDeflectionId: ' + caseDeflectionId);
	    
	    if (caseDeflectionId == null) {
	    	Logger.pop();
	        return;
	    }
	    
    	//Update Case_Deflection__c
    	Case_Deflection__c cd = [SELECT Id FROM Case_Deflection__c WHERE Id =: caseDeflectionId];
    	cd.Article_ID__c = articleId;
    	cd.Article_Title__c = articleTitle;
	    try {
	    	update cd;
	    } catch(exception ex) {
	        System.Debug('@@Exception updating Case_Deflection__c:'+ex.getMessage());
	        Logger.debugException(ex);
	    }

    	Logger.pop();
    }

    public PageReference doNotHelpful() {
    	Logger.push('doNotHelpful','cp_Case_new_ControllerExtension');
    	isDisplaySuggestedArticles = false;
    	iSuggestedContentFeedbackStep = 3;
    	Logger.pop();
        return null;
    }

    public PageReference doNotHelpful1() {
    	Logger.push('doNotHelpful1','cp_Case_new_ControllerExtension');
    	iSuggestedContentFeedbackStep = 1;
    	Logger.pop();
        return null;
    }
    //1656885
 }