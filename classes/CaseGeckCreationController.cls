/**
* @author Original: Limo Sadalla - Cloud Sherpas, LastModified: Robbie Macatbag - Cloud Sherpas, kishore AN - CloudSherpas
* @date Original: 13 June 2013, LastModified: 12 July, 2013, 23 July, 2013
* @description Extension class for Geck creation page
*/ 
public class CaseGeckCreationController 
{
    public Case thisCase {get;set;}
    public  List<SelectOption> gecks {get;set;}
    public String selectedGeck{get;set;}    
    public String caseId{get;set;}    
    public String gekoURL {get;set;}
    
    public CaseGeckCreationController(ApexPages.Standardcontroller controller)
    {
        
        this.thisCase = (Case)controller.getRecord();
        caseId = thisCase.id;
        
        if(ApexPages.currentPage().getParameters().containsKey('articleNumber'))
        {
            generateGekoURL();
        }
        else
        {
            populateArticles();
        }
            
    }
    
    public void generateGekoURL()
    {
        
        String articleNumber=  ApexPages.currentPage().getParameters().get('articleNumber');
        String articleLanguage = ApexPages.currentPage().getParameters().get('lang');
        
        if(String.isEmpty(articleLanguage)){
            articleLanguage = 'en_US';
        }
        
        
        
        List<FAQ__kav> articles  = [Select Id, Site__c, Question__c, Answer__c
                                                From FAQ__kav
                                                    where  articleNumber=:articleNumber
                                                        AND publishStatus= 'Online'
                                                            AND Language = :articleLanguage];
                                
                                                        
        if(!articles.isEmpty())
        {
            List<String> platformOSList = new List<String>();
            List<String> releaseList = new List<String>();
            List<String> productList = new List<String>();
            List<String> typeList = new List<String>();
            
            for(FAQ__DataCategorySelection faqCategory : [select Id, DatacategoryGroupName, DatacategoryName
                                                                from FAQ__DataCategorySelection
                                                                where parentId = :articles[0].Id]){
            
                if(faqCategory.DatacategoryGroupName=='Product'){
                    productList.add(faqCategory.DatacategoryName);
                }else if(faqCategory.DatacategoryGroupName=='Type'){
                    typeList.add(faqCategory.DatacategoryName);
                }else if(faqCategory.DatacategoryGroupName == 'Verified_in_Release'){
                    releaseList.add(faqCategory.DatacategoryName);
                }else if(faqCategory.DatacategoryGroupName == 'Platform_OS'){
                    platformOSList.add(faqCategory.DatacategoryName);
                }
            }
            
                        
             
            //gekoURL =  'http://geckotest.mathworks.com/main/gecko/ndnew?';
            gekoURL = Label.Gecko_Integration_URL + '?';
            if(typeList.size()>0) gekoURL += 'Type=' + typeList[0];
            
            if(releaseList.size()>0){
                 System.Debug('Release selected for gecko URL:'+releaseList[releaseList.size()-1]);       
                String releaseName= this.getCategoryLabel('Verified in Release', releaseList[releaseList.size()-1]);
                if(releaseName!=null)
                    gekoURL +=  '&FoundIn=' + releaseName;
                //gekoURL += '&FoundIn=' + releaseList[releaseList.size()-1];
            }
            
            if(productList.size()>0){
                String productName = this.getCategoryLabel('Product', productList[productList.size()-1]);
                if(productName!=null)
                    System.Debug('Product selected for gecko URL:'+productName);
                    if(productName.equalsIgnoreCase('MATLAB') || productName.equalsIgnoreCase('Simulink')){
                        gekoURL += '&FormType=Component&Component=';
                    }else{
                        gekoURL +=  '&Product=' + productName;
                    } 
            }
            
            if(platformOSList.size() > 0){
                List<SFDC_Gecko_Platform_Mapping__c> sfdcgeckoMapping = [select sfdc_platform_os_Name__c,Gecko_Platform_Name__c,
                                                                        Gecko_OS_Name__c
                                                                        from SFDC_Gecko_Platform_Mapping__c
                                                                        where sfdc_platform_os_Name__c = :platformOSList[platformOSList.size()-1]];
                
                if(sfdcgeckoMapping!=null && sfdcgeckoMapping.size()>0){
                    gekoURL +=  '&Architecture=' + sfdcgeckoMapping[0].Gecko_Platform_Name__c;
                    gekoURL +=  '&OS=' + sfdcgeckoMapping[0].Gecko_OS_Name__c;
                }
            }            
            
           
            if(articles[0].Site__c != null ) gekoURL +=  '&Site=' + articles[0].Site__c; 
            gekoURL +=  '&CustomerReported=Y';
            gekoURL += '&ArticleId='+articleNumber; 
            if(articles[0].Question__c != null ) {
                String articleQuestion = articles[0].Question__c;
                //articleQuestion = articleQuestion.replaceAll('<[^>]+>','');
                //articleQuestion = articleQuestion.escapeHtml4();
                
                //articleAnswer = '<span>what it is with the test text and we need to see how this works.</span>';
                gekoURL +=  '&Problem=' + articleQuestion; 
                
                System.Debug('gecko Article Url:'+gekoURL);
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Malfunctioned URL.'));
        
        }
    }


    public void populateArticles()
    {
 
        Set<Id> knowledgeArticleIds = new Set<Id>();
        gecks = new List<SelectOption>();
        List<Faq__KAV> kavArticles  = new List<Faq__KAV>();
        
        for (CaseArticle  ca :[Select Id,  KnowledgeArticleId,  ArticleLanguage,CaseId From CaseArticle where caseId = :thisCase.id])
        {   
            //KAN 101113
            //knowledgeArticleIds.add(ca.KnowledgeArticleId);
            List<FAQ__Kav> faqkav = [Select Id,  ArticleNumber, Language, Title From FAQ__kav 
                                where  knowledgeArticleId = :ca.KnowledgeArticleId 
                                AND language = :ca.ArticleLanguage AND publishStatus = 'Online' and GeckId__c = null];
                                
            if(faqkav != null && faqkav.size() > 0){                
                kavArticles.addAll(faqkav);
            }
             
        }
        
        for (FAQ__kav kva  :kavArticles)
        {
            gecks.add(new SelectOption(kva.ArticleNumber+'|'+kva.language, kva.ArticleNumber  + ' | '+  kva.title));
        }
                                                
        /*
        for (KnowledgeArticleVersion kva  :[Select Id,  ArticleNumber,  Title
                                                From KnowledgeArticleVersion 
                                                    where  knowledgeArticleId in :knowledgeArticleIds
                                                        AND publishStatus = 'Online'])
        {
            gecks.add(new SelectOption(kva.ArticleNumber, kva.ArticleNumber  + ' | '+  kva.title));
        }
        */
        /* KAN 101113
        for (FAQ__kav kva  :[Select Id,  ArticleNumber,  Title
                                                From FAQ__kav
                                                    where  knowledgeArticleId in :knowledgeArticleIds
                                                        AND publishStatus = 'Online' and GeckId__c = null])
        {
            gecks.add(new SelectOption(kva.ArticleNumber, kva.ArticleNumber  + ' | '+  kva.title));
        }
        */
        if (gecks.isEmpty())
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No articles without GeckId attached to this case.'));
            
        }
    }
    
   public void submitToGecko()
   {
    
   }
   
   private String getCategoryLabel(String categoryGroupName, String categoryAPIName){
   
       List<DataCategoryInfo> allCategories = DataCatagoriesHelper.getAllDataCategoryNames(categoryGroupName);
       for(DataCategoryInfo catInfo : allcategories){
           if(categoryAPIName==catInfo.getName())
               return catInfo.getLabel();
       }
       return null;
   }
    
    public void caseCreateEscalationURL() {
    	Case cse = [SELECT Id, CaseNumber, Contact.Name, Account.Name, Account.Country_State_Code__c, 
    					Platform__c, OS__c, Product_Lookup__r.Name, Release__c, Email_Ref_Id__c,
    					Attachments_Folder__c, Owner.Name, Category__c, Area__c, Status, SubStatus__c
    				FROM Case
    				WHERE Id =: caseId];

    	gekoURL = General_Settings__c.getInstance().Gecko_Escalation_URL__c + '?';
    	gekoURL += 'ContactName=' + cse.Contact.Name;
    	gekoURL += '&accountName=' + cse.Account.Name;
    	gekoURL += '&accountcountry=' + cse.Account.Country_State_Code__c;
    	gekoURL += '&platform=' + cse.Platform__c;
    	gekoURL += '&os=' + cse.OS__c;
    	gekoURL += '&release=' + cse.Release__c;
    	gekoURL += '&attachmentsfolderlocation=' + cse.Attachments_Folder__c;
    	gekoURL += '&emailrefid=' + cse.Email_Ref_Id__c;
    	gekoURL += '&Product=' + cse.Product_Lookup__r.Name;
    	gekoURL += '&CaseOwner=' + cse.Owner.Name;
    	gekoURL += '&Category=' + cse.Category__c;
    	gekoURL += '&Area=' + cse.Area__c;
    	gekoURL += '&Status=' + cse.Status;
    	gekoURL += '&SubStatus=' + cse.SubStatus__c;
    	gekoURL += '&caseid=' + cse.CaseNumber;
    	gekoURL += '&salesforceid=' + cse.Id;
    	gekoURL += '&SalesforceLinkId=' + cse.Id;
    	
    	gekoURL = gekoURL.replaceAll(' ', '%20').replaceAll('=null&', '=&');
    	System.Debug('caseCreateEscalationURL:'+gekoURL);
    }

}