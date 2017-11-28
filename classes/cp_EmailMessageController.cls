public class cp_EmailMessageController{

    // the parent object it
    public Id sobjId {get; set;}
    
    // list of existing attachments
    public List<Attachment> attachments;
    
    public String language { get; set; }

    public ApexPages.StandardController controller {get;set;}
    
    public cp_EmailMessageController(){
        sobjId = ApexPages.currentPage().getParameters().get('Id');
        setPageLanguage();
    }
    
    public cp_EmailMessageController(ApexPages.StandardController stdController){
        this.controller = stdController;
        sobjId = this.controller.getId();
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
}