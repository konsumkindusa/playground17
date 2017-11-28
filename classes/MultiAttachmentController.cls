public with sharing class MultiAttachmentController 
{
    // the parent object it
    public Id sobjId {get; set;}
    
    public String language { get; set; }

    // list of existing attachments - populated on demand
    public List<Attachment> attachments;
    
    // list of new attachments to add
    public List<Attachment> newAttachments {get; set;}
    
    public Case parentCase {get; set;}
    
    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD=1;

    // constructor
    public MultiAttachmentController()
    {
        sobjId = ApexPages.currentPage().getParameters().get('Id');
        // instantiate the list with a single attachment
        newAttachments=new List<Attachment>{new Attachment()};
        parentCase = [Select Id, CaseNumber, Subject, Description, OwnerId, contactId, Owner.Type from Case where Id = :sobjId limit 1];
        setPageLanguage();
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
    
    // retrieve the existing attachments
    public List<Attachment> getAttachments()
    {
        // only execute the SOQL if the list hasn't been initialised
        if (null==attachments)
        {
            attachments=[select Id, ParentId, Name, Description from Attachment where parentId=:sobjId order by createddate desc];
        }
        
        return attachments;
    }

    // Add more attachments action method
    public void addMore()
    {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
        {
            newAttachments.add(new Attachment());
        }
    }    
    
    // Save action method
    public void save()
    {
        List<Attachment> toInsert=new List<Attachment>();
        for (Attachment newAtt : newAttachments)
        {
            if (newAtt.Body!=null)
            {
                newAtt.parentId=sobjId;
                newAtt.ContentType += '; charset=UTF-8';
                toInsert.add(newAtt);
            }
        }
        try{
	        insert toInsert;
	        newAttachments.clear();
	        newAttachments.add(new Attachment());
	        
	        //HW, 2016.8.1, 1578527
            if(parentCase.owner.Type!= 'Queue'){            
                Task tk = new Task();
                tk.whatId = parentCase.Id;
                tk.Subject = 'Case Attachment added for Case -' + parentCase.CaseNumber;
                //tk.Description = ccObj.CommentBody;
                tk.OwnerId = parentCase.OwnerId;
                tk.Status = 'Not Started';
                tk.WhoId = parentCase.contactId;
                tk.Type = 'To Do';
                tk.Priority = 'Medium';
                
                Database.DMLOptions dmlo = new Database.DMLOptions();
                dmlo.EmailHeader.triggerUserEmail  = true;
                database.insert(tk, dmlo);
                
            }
	        //1578527
        }
        catch(DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment / creating task'));          
        }
        // null the list of existing attachments - this will be rebuilt when the page is refreshed
        attachments=null;
    }
    
    // Action method when the user is done
    public PageReference done()
    { 
        PageReference pg = new PageReference('/apex/cp_case_detail?cc='+ApexPages.currentPage().getParameters().get('cc'));
        pg.getParameters().put('id',sobjId);
        
        pg.setredirect(true);
        return pg;
   
    }
    
}