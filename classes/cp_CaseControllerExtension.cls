/**
* @author Original: Limo Sadalla - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod, kishore AN, Robbie Macatbag  
* @date Original: 26 June 2013, Last Modified: 07 August 2013, 08 August 2013
* @description controller class of page on Customer Portal for creating Case  
*/ 
public class cp_CaseControllerExtension {
    
    public ApexPages.StandardController controller {get;set;}
    public ApexPages.StandardSetController setController {get;set;}
    public String language { get; set; }
    public string pageUrl {get;set;}
    public string confirmmsg {get; set;}
    public boolean showconfirmmsg { get; set;}
    public string errormsg {get; set;}
    public boolean showerrormsg { get; set;}
    User TheUser;
    public boolean showcaseclose {get; set;}    
    Case caseObj;
    //Case Detail Page
    public list <Task> CaseOpenActivities;
    public list <Task> CaseActivityHistory;
    public List <EmailMessage> CaseEmails;
    public List<CaseComment> CaseComments;
    public List<CaseActivityInfo> AllCaseActivities;
    public List<Attachment> CaseAttachments;
    
    public string selTask {get;set;}
    public SelectOption[] Countries{get; set;}
    public SelectOption[] Salutations{get; set;}
    public SelectOption[] Releases{get; set;}
    public String SelectedRelease {get; set;}
    public SelectOption[] allProductList { get; set;}
    public String SelectedProduct { get; set;}
    public integer choiceNum { get; set;}
    public String filebody{get; set;}
    public String filename{get; set;}
    public String title{get;set;}
    public String license{get;set;}
    
    public String caseclosecomment{get; set;}
    public Boolean isssoenabled {get; set;}
    
    public list <String> CSPassCodeDesc {get;set;}
    public list <String> CSLicenseContact {get;set;}
    public list <String> CSTransfer1 {get; set;}
    public list <String> CSTransfer2 {get; set;}
    public list <String> CSTransfer3 {get; set;}
    public list <String> CSTransfer4 {get; set;}
    public list <String> CSTransfer5 {get; set;}
    public list <String> CSCombineLic {get; set;}
    public list <String> CSProductActFields {get; set;}
    public Attachment attNew  {get; set;}
    public Attachment attlicensedat {get; set;}
    public Attachment attlmdebugout {get;set;}
    public boolean CreateSuccess {get; set;}
    
    public List<FAQ__Kav> results {get; set;} //HW, 1832966
   
   public cp_CaseControllerExtension(){
   /*
        attNew = new Attachment();
        attlicensedat = new Attachment();
        attlmdebugout = new Attachment();
        selTask = '';
        CSProductActFields = new list <string>{'','',''};
        CSPassCodeDesc = new list <string>{'','','','','',''};
        CSLicenseContact = new list <string>{'','','','','','','','','','','','','','','','','','','','','','','','','',''};
        
        CSTransfer1 = new list <string>{'','','',''}; // Transfer #1
        CSTransfer2 = new list <string>{'','','',''}; //Transfer #2
        CSTransfer3 = new list <string>{'','','',''}; //Transfer #3
        CSTransfer4 = new list <string>{'','','',''}; //Transfer #4
        CSTransfer5 = new list <string>{'','','',''}; //Transfer #4
        
        CSCombineLic = new list <string>{'','','',''};
        
        getSalutations();
        getReleases();
        allProductList = new List<SelectOption>();
       */
   }
   
   public cp_CaseControllerExtension (ApexPages.StandardSetController stdController){
        this.setController = stdController;
        setPageLanguage();
   }

   public cp_CaseControllerExtension (ApexPages.StandardController stdController){
        this.controller = stdController;
        Case cse = (Case)stdController.getRecord();
        
        selTask = '';
        //getCountries();
        //getSalutations();
        //getReleases();
        //allProductList = new List<SelectOption>();
        caseObj = (Case)stdController.getRecord();
        confirmmsg = Label.case_created_confirmation_message;
        String isnew =  ApexPages.currentPage().getParameters().get('isnew');
        if(isnew =='yes')showconfirmmsg = true;
        List<Case> cses = [select Id, subject, ownerid, status, case_status__c, substatus__c,Description from Case where Id = :this.controller.getId()];
        If(cses!=null && cses.size() > 0){
            cse = cses[0];
        }
        if(cse!=null && cse.status!='Closed')showcaseclose = true;
        
        isssoenabled = false;
        TheUser = [SELECT Id, federationIdentifier,isPortalEnabled,Student__c, Portal_User_Status__c, ContactId  FROM User WHERE Id = :UserInfo.getUserId()];
        if(TheUser!= null && TheUser.isPortalEnabled && TheUser.FederationIdentifier!=null 
            && TheUser.FederationIdentifier!='' && Integer.ValueOf(TheUser.FederationIdentifier) > 0){
            isssoenabled = true;
        }
        showerrormsg=false;
        setPageLanguage();
        fetchSuggestedAnswers();
    }
    
    public Case getCaseObj() {
        if(caseObj == null) caseObj = new Case();
        return caseObj;
    }
    public Case getCase() {
        if(caseObj == null) caseObj = new Case();
        return caseObj;
    }
   
    public PageReference setUrl() {
        return null;
    }
    
    //HW
    private void setPageLanguage() {
        language = 'en_US';
		List<Portal_CountryCode_Language_Mapping__mdt> CountryCodeLangList = new List<Portal_CountryCode_Language_Mapping__mdt>();	
        Portal_CountryCode_Language_Mapping__mdt ObjCCLang;
    	 String countrycode = ApexPages.currentPage().getParameters().get('cc');
		
        if (!String.isEmpty(countrycode))
        {
            CountryCodeLangList = [select DeveloperName, CountryCode__c, LanguageCode__c from Portal_CountryCode_Language_Mapping__mdt where  CountryCode__c= : countrycode  limit 1];
            if (!CountryCodeLangList.IsEmpty()){
                language = CountryCodeLangList[0].LanguageCode__c;}
		}	
    }
    
    //tw
    private  PageReference getiFrameUrl(String page, String id) {
        PageReference iframe = getiFrameUrl(page);
        iframe.getParameters().put('id',id);
       // iframe.setRedirect(true);
        return iframe;
    }
    //tw
    private  PageReference getiFrameUrl(String page) {
        if (pageUrl == null) {
            pageUrl = '/apex/cp_service_frame';
        }
        PageReference iframe = new PageReference(pageUrl);
        iframe.getParameters().put('page',  page);
        return iframe;
    }
    
    public PageReference createComment(){
    
     PageReference pref = new PageReference('/apex/cp_create_casecomment?parentid='+this.controller.getId()+'&cc='+ApexPages.currentPage().getParameters().get('cc'));
     
     return pref;
    }
    
    public PageReference closecasePage(){
     showerrormsg=false;
     PageReference pref = new PageReference('/apex/cp_case_close?Id='+this.controller.getId()+'&cc='+ApexPages.currentPage().getParameters().get('cc'));
     pref.getParameters().put('cc',ApexPages.currentPage().getParameters().get('cc'));
     pref.setRedirect(true);
     return pref;
    }
    
    public PageReference closecasecancel(){
        PageReference pg = new PageReference('/apex/cp_case_detail?cc='+ApexPages.currentPage().getParameters().get('cc'));
        pg.getParameters().put('id',this.controller.getId());
        pg.getParameters().put('cc',ApexPages.currentPage().getParameters().get('cc'));
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference save() {
        this.controller.save();
        return getiframeUrl('cp_case_detail', this.controller.getId());
    }
    
    public PageReference edit() {
        this.controller.save();
        return getiframeUrl('cp_case_edit', this.controller.getId());
    }
    
    public PageReference cancel() {
        this.controller.cancel();
        return getiframeUrl('cp_case_home');
    }
    
    public PageReference newcase() {
        PageReference pg = new PageReference('/apex/cp_case_new?cc='+ApexPages.currentPage().getParameters().get('cc'));
        return pg;
    }
    
    public list <Task> getCaseOpenActivities(){
        String cseId = this.controller.getId();
        list <Task> openActs = new list <Task>();
        for (Task tsk : [SELECT Id, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, Type FROM Task Where WhatId = : cseId AND Status <> 'Completed']){
            openActs.add(tsk);
        }
        system.debug('@@openaActs:'+openActs.size()+openActs);
        return openActs;
    }
    
    public list <Task> getCaseActivityHistory(){
        String cseId = this.controller.getId();
        system.debug('@@cseID:'+cseId);
        list <Task> closeActs = new list <Task>();
        for (Task tsk : [SELECT Id, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, Type FROM Task Where WhatId = : cseId AND Status = 'Done' and Type !='Email']){
            closeActs.add(tsk);
        }
        system.debug('@@closeActs:'+closeActs.size()+closeActs);
        return closeActs;
    }
    
    public list <EmailMessage> getCaseEmails(){
        try{
            Case cse = (Case)this.controller.getRecord();
            list <EmailMessage> emailsList = new list <EmailMessage>();            
            for (EmailMessage eMsg: [SELECT Id, Subject, toaddress,fromaddress,createddate FROM EmailMessage Where ParentId = :cse.Id and (toaddress=:cse.contact.Email or fromaddress = :cse.Contact.Email)]){
                emailsList.add(eMsg);
            }
            system.debug('@@case Email Messages:'+emailsList.size()+emailsList);
            return emailsList;
       }catch(Exception ex){
           System.Debug('@@Case GetCaseEmails Exception:'+ex.getMessage());
           return null;
       }
    }
    
    public List<CaseComment> getCaseComments(){
        try{
            Case cse = (Case)this.controller.getRecord();
            list <CaseComment> commentList = new list <CaseComment>();            
            for (CaseComment cComment: [SELECT Id, commentBody, isPublished, createdById,createddate FROM CaseComment Where ParentId = :cse.Id and isPublished=true order by createddate desc]){
                commentList.add(cComment);
            }
            system.debug('@@case Comments:'+commentList.size()+commentList);
            return commentList;
       }catch(Exception ex){
           System.Debug('@@Case getCaseComments Exception:'+ex.getMessage());
           return null;
       }
        
    }
    /*
    public List<SelectOption> getCountries(){
        Countries = new List<SelectOption>();
        for(String lval: UtilityHelper.getFieldPickListValues('Account', 'BillingCountry')){
            Countries.add(new SelectOption(lval,lval));
        } 
        return Countries;
    }
    */
    /*
    public List<SelectOption> getSalutations(){
        Salutations = new List<SelectOption>();
        for(String lval: UtilityHelper.getFieldPickListValues('Contact', 'Salutation')){
            Salutations.add(new SelectOption(lval,lval));
        } 
        return Salutations;
    }
    */
    /*
    public List<SelectOption> getReleases(){
        Releases = new List<SelectOption>();
        Releases.add(new selectOption('selectRelease', '-- Select Release --'));
        for(Release__c rel: [Select Name, release_type__c from release__c where Show_in_portal__c=true]){
            Releases.add(new SelectOption(rel.Name,rel.Name));
        }
        
        return Releases;
    }
    */
    /*
     public PageReference refreshProductList(){
     allProductList.clear();
       allProductList.add(new selectOption('selectProduct', '-- Select Product--'));
        for(product2 prod: [Select Id, Name, product_name__c, Version__c from Product2 where release__c= :SelectedRelease]){
            allProductList.add(new SelectOption(prod.Id,prod.Name));
        }
        
        return null;
    }
    */
    public List<Task> getAllCaseActivity(){

        List<Id> allTasksIds = new List<Id>();
        
        Case cse = (Case)this.controller.getRecord();
        
        for(Task tk : [SELECT Id FROM Task Where WhatId = :cse.Id AND Status = 'Completed' and Type !='Email']){
        
            allTasksIds.add(tk.Id);
        }
        
        
        for(EmailMessage tk:[SELECT ActivityId FROM EmailMessage Where ParentId = :cse.Id and (toaddress=:cse.contact.Email or fromaddress = :cse.Contact.Email)]){
            allTasksIds.add(tk.ActivityId);           
        }
        
        
        List<Task> allTasks = [Select Id, Subject, createddate, type from Task where Id in :allTasksIds];       
        
        
        return allTasks;
        
    }
    
    public List<CaseActivityInfo> getAllCaseActivities(){

        //List<Task> AllTasks = getAllCaseActivity();
        List<CaseActivityInfo> AllCaseActivity = new List<caseActivityInfo>();
        /*
        for(Task tk : alltasks){
            caseActivityInfo actInfo = new CaseActivityInfo();
            actInfo.activityId = tk.Id;
            actInfo.activitySubject = tk.Subject;
            actInfo.activityCreateddate = tk.createddate;
            actInfo.activityType = tk.Type;
            
            AllCaseActivity.add(actInfo);
        }
        */
        for(EmailMessage em : getCaseEmails()){
        
            caseActivityInfo actInfo = new CaseActivityInfo();
            actInfo.activityId = em.Id;
            actInfo.activitySubject = em.Subject;
            actInfo.activityCreateddate = em.createddate;
            actInfo.activityType = 'Email';            
            
            AllCaseActivity.add(actInfo);
        }
        
        for(CaseComment cComment : getCaseComments()){
            caseActivityInfo actInfo = new CaseActivityInfo();
            actInfo.activityId = cComment.Id;
            actInfo.activitySubject = cComment.CommentBody;
            actInfo.activityCreateddate = cComment.createddate;
            actInfo.activityType = 'Comment';
                    
            AllCaseActivity.add(actInfo);
            
        }
        
        AllCaseActivity = getSortedActivities(AllCaseActivity , 'activityCreateddate', 'desc');
        
        return AllCaseActivity ;
    
    
    }

    private List<CaseActivityInfo> getSortedActivities(List<CaseActivityInfo> allActivity, String sortField, String sortOrder){

        List<CaseActivityInfo> resultList = new List<CaseActivityInfo>();
        Map<object, List<CaseActivityInfo>> objectMap = new Map<object, List<CaseActivityInfo>>();
        
        for(CaseActivityInfo cInfo : allActivity){
            if(objectMap.get(cInfo.activityCreateddate) == null){
                objectMap.put(cInfo.activityCreateddate, new List<CaseActivityInfo>());
            }
            objectMap.get(cInfo.activityCreateddate).add(cInfo);
        }
        
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
            keys.sort();
            
            for(object key : keys){ 
                resultList.addAll(objectMap.get(key)); 
            }
            
        //Apply the sorted values to the source list
        allActivity.clear();
        if(sortOrder.toLowerCase() == 'asc'){
            for(CaseActivityInfo cInfo : resultList){
            allActivity.add(cInfo); 
            }
        }else if(sortOrder.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                allActivity.add(resultList[i]); 
            } 
        }
        
        return allActivity;
    }
    
    public PageReference closeCase() {
        showerrormsg=false;
        Case cse = [Select Id, OwnerId, Status, SubStatus__c, Owner.Type, CaseNumber,Description  from Case where Id = :this.controller.getId()];
        
        try{
        if(caseclosecomment != null && caseclosecomment!= ''){//create  a task and assign it to case owner
            //create a case and assign it to the case owner
            if(cse.owner.Type!= 'Queue'){
            Task tk = new task();
            tk.whatId = cse.Id;
            tk.Subject = Label.Comment_during_closedcase + cse.CaseNumber;
            tk.Description = caseclosecomment;
            
            tk.OwnerId = cse.OwnerId;
            tk.status= 'Open';
            tk.Type = 'To Do';
            
            insert tk;
            }
            //create a case comment
            CaseComment cc = new CaseComment();
            cc.ParentId = cse.Id;
            cc.isPublished = true;
            cc.CommentBody = caseclosecomment;
            
            insert cc;
            
            
        }
        cse.SubStatus__c = 'Closed by Customer';
        cse.Status='Closed';
        update cse;
        
        
        }catch(Exception ex){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,''));
           // showerrormsg=true;
            //errormsg='Error while closing the case';
           // return null;
        }
        PageReference pg = new PageReference('/apex/cp_case_detail?cc='+ApexPages.currentPage().getParameters().get('cc'));
        pg.getParameters().put('id',cse.Id);
        
        pg.setredirect(true);
        return pg;
        
    }
    
    public List<Attachment> getCaseAttachments(){
    
        List<Attachment> caseAttachments = new List<Attachment>();
        
        for(Attachment attch: [select Id, bodyLength, Name, ParentId, ContentType, LastModifieddate,CreatedById, CreatedDate,description from Attachment where ParentId = :this.controller.getId() order by createddate desc]){
            caseAttachments.Add(attch);
        }
        return caseAttachments;
    }
    
    public PageReference attachfile(){
    
     PageReference pref = new PageReference('/apex/cp_case_attachfile?Id='+this.controller.getId()+'&cc='+ApexPages.currentPage().getParameters().get('cc'));
     
     return pref;
    }

	//HW, 1832966
    public void fetchSuggestedAnswers() {
    	Logger.push('fetchSuggestedAnswers','cp_CaseControllerExtension');
    	if (CaseObj == null) {
    		Logger.pop();
    		return;
    	}
	    results = [SELECT
	                 Id, Title, Answers_URL__c 
	               FROM FAQ__Kav
	    		   WHERE
	    		     KnowledgeArticleId IN (SELECT KnowledgeArticleId FROM CaseArticle WHERE CaseId =: CaseObj.Id)
                   AND Language = 'en_US' 
                   AND PublishStatus = 'Online'
                   AND Answers_URL__c != null 
                   LIMIT 100
                  ];
	    Logger.pop();
    }
    
 }