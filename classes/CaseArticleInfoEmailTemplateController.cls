/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 27 June 2013, Last Modified: 01 Aug 2013
* @description Controller class for VF Email Template of displaying Case and Article information
*/
public class CaseArticleInfoEmailTemplateController {
    
    public String cseId {get;set;}
    public Case cse;
    public String size {get;set;}
    public list <ArticleWrapper> ArticleWrList;
    public List<String> imageURLs {get;set;}
    public String articleContents='';
    public String articleBody  
    {   
        get   
        {  
            return articleContents;  
        }  
        set;   
    } 
    public String getcseId(){
        return cseId;
    }
    
    
    
    public Case getcse(){
        
        map<String, Schema.SObjectField>  CasefieldMap = Schema.SObjectType.Case.fields.getMap();
        string theQuery = 'SELECT Contact.Name, Contact.Phone, Contact.Email, Account.Name, ';
        for (Schema.Sobjectfield field : CasefieldMap.values()){
            theQuery += field.getDescribe().getName() + ',';
        }
        
        //contstruct query      
        theQuery = theQuery.subString(0, theQuery.length() - 1); //trim last comma
        theQuery += ' FROM Case Where Id = : cseId';
        
        //Get Case Record
        cse = database.query(theQuery);
        
        return cse;
    }
    
    public list <ArticleWrapper> getArticleWrList(){
        imageURLs = new List<String> ();
        try {
                ArticleWrList = new list <ArticleWrapper>();
                list <CaseArticle> cseArticles = [Select Id, KnowledgeArticleId, CaseId From CaseArticle Where CaseId = : cse.Id];
                map <String,FAQ__ka> cseArticleMap = new map <String,FAQ__ka>();
                map <String,FAQ__kav> ArticleFAQkvMap = new map <String,FAQ__kav>();
                if (cseArticles.size() > 0){
                    //Identify all Knowledge Articles related to Case
                    for (CaseArticle ca: cseArticles){
                        cseArticleMap.put(ca.KnowledgeArticleId, new FAQ__ka());
                    }
                    //Identify each Knowledge Article's related subobject (FAQ__kav)
                    for (FAQ__ka fk : [Select Id, ArticleNumber, ArchivedDate From FAQ__ka Where Id in : cseArticleMap.keySet()]){
                        if (cseArticleMap.containskey(fk.Id)){
                            cseArticleMap.put(fk.Id,fk);
                            ArticleFAQkvMap.put(fk.Id,new FAQ__kav());
                        }
                    }
                    //Get all Knowledge Article Fields available 
                    
                    List<imgUrlTextBodyWrapper> forAttachmentsURL = new List <imgUrlTextBodyWrapper>();
                    
                    for (FAQ__kav fkv : [SELECT Id, KnowledgeArticleId, OwnerId, IsDeleted, ValidationStatus, PublishStatus, VersionNumber, IsLatestVersion, IsVisibleInApp, IsVisibleInPkb, IsVisibleInCsp, IsVisibleInPrm, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                                SystemModstamp, IsMasterLanguage, Language, Title, UrlName, ArchivedDate, ArchivedById, Summary, ArticleNumber, FirstPublishedDate, LastPublishedDate, SourceId, IsOutOfDate, MasterVersionId, TranslationCompletedDate, TranslationExportedDate, 
                                                TranslationImportedDate, ArticleType, Siebel_Solution_ID__c, /*Platform__c, Product__c, OS__c, Release__c,*/ Question__c, Answer__c, Internal_Notes__c, GeckId__c, Answers_URL__c, Publish_External__c, 
                                                Attachments__Name__s, Attachments__ContentType__s, Attachments__Length__s, Attachments__Body__s, Tags__c 
                                                FROM FAQ__kav Where KnowledgeArticleId in : ArticleFAQkvMap.keySet() AND PublishStatus = 'Online' AND Language = 'en_US']){
                        if (ArticleFAQkvMap.containskey(fkv.KnowledgeArticleId)){
                            
                            //Remove html tags for the following:
                                
                                //Answer
                                forAttachmentsURL = replaceImgTags(fkv.Answer__c,imageURLs);
                                system.debug('@@33forAttachmentsURL :'+forAttachmentsURL);
                                imageURLs = forAttachmentsURL[0].imgURLs;
                                String newTextBody = forAttachmentsURL[0].newBodyString;
                                fkv.Answer__c =htmlToText(newTextBody); 
                            
                                //Internal_Notes__c
                                forAttachmentsURL = replaceImgTags(fkv.Internal_Notes__c,imageURLs);
                                imageURLs = forAttachmentsURL[0].imgURLs;
                                newTextBody = forAttachmentsURL[0].newBodyString;
                                fkv.Internal_Notes__c = htmlToText(newTextBody);
                                
                            ArticleFAQkvMap.put(fkv.KnowledgeArticleId, fkv);
                        }                       
                    }
                    
                    //Add all identified Knowledge Articles on ArticleWrapper list
                    for (CaseArticle ca : cseArticles){
                        ArticleWrList.add(new ArticleWrapper(ca, cseArticleMap.get(ca.KnowledgeArticleId), ArticleFAQkvMap.get(ca.KnowledgeArticleId)));
                    }
                    return ArticleWrList;
                }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '|' + e.getLineNumber()));
        }
        return null;
    }
    
    public String getSize(){
        size = String.valueof(ArticleWrList.size());
        return size;
    }
    
    public String htmlToText(String htmlString){
        string result = htmlString;
        result = result.replaceAll('<br>', '\n');

        //regular expression to match all HTML/XML tags
        string HTML_TAG_PATTERN = '<.*?>';

        // compile the pattern     
        pattern myPattern = pattern.compile(HTML_TAG_PATTERN);

        // get your matcher instance
        matcher myMatcher = myPattern.matcher(result);

        //remove the tags     
        result = myMatcher.replaceAll('');
        
        return result;
    }
    
    public class ArticleWrapper{
        public CaseArticle cseArt {get; set;}
        public FAQ__ka  faqka {get; set;}
        public FAQ__kav faqkav {get; set;}
        public ArticleWrapper(CaseArticle Article, FAQ__ka faqa, FAQ__kav faqv){
            cseArt = Article;
            faqka = faqa;
            faqkav = faqv;
        }
    }
    
    
    public List<imgUrlTextBodyWrapper> replaceImgTags (String stringWithImgTag, List<String> oldImgUrlList){
        List<String> forAttachments = oldImgUrlList;
        String newString = stringWithImgTag;
        system.debug('@@stringWithImgTag:'+stringWithImgTag);
        //check if the article string is null
        if(stringWithImgTag!=null){
            String  imageAddress='';
            integer ctr = oldImgUrlList.size();
            integer ctr2 =0;
            integer matchCount = newString.countMatches('<img');
            
            for(ctr2=0;ctr2 < matchCount;ctr2++){
                imageAddress='';
                ctr++;
                integer firstIndex = newString.indexOf('<img');
                integer secondIndex = newString.indexOf('</img>')+6;
                String imgTag = newString.substring(firstIndex,secondIndex);
                
                imageAddress = imgTag.substringAfter('src="').substringBefore('"').replace('amp;','');
                //newString = newString.replace(imgTag,'\n[ See image: '+imageAddress+' ]\n');
                
                // replace HTML img Tag with [Image no.#] 
                newString = newString.replace(imgTag,'[ Image no.'+ctr+' ]');
                forAttachments.add(imageAddress);
                
                //add the images to PDF
                articleContents +='<br/><br/><strong>[Image no.'+ctr+']</strong><br/>'+imgTag;
            }
        }else{
            newString ='';
        }   
        List<imgUrlTextBodyWrapper> results = new List<imgUrlTextBodyWrapper>();
        results.add(new imgUrlTextBodyWrapper(forAttachments,newString));
        System.debug('---------------IMAGE URL :'+ imageURLs);
        return results;
    }

    public class imgUrlTextBodyWrapper{
        public List<String> imgURLs {get; set;}
        public String newBodyString {get; set;}
        public imgUrlTextBodyWrapper(List<String> imageURL, String bodyString){
            imgURLs = imageURL;
            newBodyString = bodyString;
        }
    }
    

}