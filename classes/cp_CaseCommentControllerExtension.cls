public class cp_CaseCommentControllerExtension{

    public ApexPages.StandardController controller {get;set;}
    public String language { get; set; }
    public Case parentCase {get; set;}
    public String parentId{get; set;}
    public CaseComment ccObj;
    public Case caseObj {get;set;}
    
    public cp_CaseCommentControllerExtension(){
    }
    
    public cp_CaseCommentControllerExtension(ApexPages.StandardController stdController){
        this.controller = stdController;
        parentId = ApexPages.currentPage().getParameters().get('ParentId');
        caseObj = [select Id, caseNumber, contactId, subject, description, status, substatus__c,OwnerId, Owner.Type from Case where Id = :parentId];
        setPageLanguage();
    }
    
    public CaseComment getCCObj() {
        if(ccObj== null) ccObj= new CaseComment();
        return ccObj;
    }
    
    public Case getCaseObj(){
        if(caseObj ==null){
            caseObj = [select Id, caseNumber, contactId, subject, description, status, substatus__c,OwnerId, Owner.Type from Case where Id = :parentId];
        }
        return caseObj;
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
    
    public PageReference save() {
        try{
        if(caseObj.status != 'Closed'){
            ccObj.isPublished = true;
            ccObj.parentId = this.ParentId;
            insert ccObj;
            
            if(caseObj.substatus__c == 'Waiting for Customer' || caseObj.substatus__c == 'Waiting for Internal'){
                caseObj.substatus__c = 'In Progress';
                update caseObj;
            }
            
            if(caseObj.owner.Type!= 'Queue'){            
                Task tk = new Task();
                tk.whatId = caseObj.Id;
                tk.Subject = 'Case Comment added for Case -' + caseObj.CaseNumber;
                tk.Description = ccObj.CommentBody;
                tk.OwnerId = caseObj.OwnerId;
                tk.Status = 'Open';
                tk.WhoId = caseObj.contactId;
                tk.Type = 'To Do';
                
                Database.DMLOptions dmlo = new Database.DMLOptions();
                dmlo.EmailHeader.triggerUserEmail  = true;
                database.insert(tk, dmlo);
                
            }
        
        }        
        else if(caseObj.Status =='Closed'){
            if(caseObj.owner.Type!= 'Queue'){
            Task tk = new Task();
            tk.whatId = caseObj.Id;
            tk.Subject = Label.Comment_on_closedcase + caseObj.CaseNumber;
            tk.Description = ccObj.CommentBody;
            tk.OwnerId = caseObj.OwnerId;
            tk.Status = 'Open';
            tk.WhoId = caseObj.contactId;
            tk.Type = 'To Do';
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail  = true;
            database.insert(tk, dmlo);
            
            }
            ccObj.isPublished = true;
            ccObj.parentId = this.ParentId;
            insert ccObj;
        }
        
        }catch(Exception ex){            
        }
        
        PageReference pg = new PageReference('/apex/cp_case_detail?cc='+ApexPages.currentPage().getParameters().get('cc'));
        pg.getParameters().put('id',ParentId);
        pg.setredirect(true);
        return pg;
    }
    
    public PageReference cancel() {
        
        PageReference pg = new PageReference('/apex/cp_case_detail?cc='+ApexPages.currentPage().getParameters().get('cc'));
        pg.getParameters().put('id',ParentId);
        pg.setredirect(true);
        return pg;
    }
}