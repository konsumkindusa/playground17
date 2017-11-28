/**
* @author Original: Limo Sadalla- Cloud Sherpas/Mathworks,LastModified: kishore AN- Cloud Sherpas/Mathworks
* @date Original: 17 June 2013, LastModified date: 31 July 2013 
* @description Webservice  to replace deprecated GeckIds with new ones
*/ 

global class GecksHouseCleaning 
{
    webService static String deprecateOldGecks(String survivorId, String deprecatedId) 
    {
    
        try
        {
            list<SObject> OnlineArticles = new list<SObject>();
            list<Sobject> OrigDraftArticles = new list <Sobject>();
            list<Sobject> DraftArticles = new list <Sobject>();
            list<Sobject> ArchivedArticles = new list <Sobject>();
            //list<Sobject> ArchivedOnlineArticles = new list <Sobject>();
            List<SObject> articlesToUpdate = new list<SObject>();
            //used to keep track of original statuses
            Map<Id, String> articleIdToOriginalStatus = new Map<Id, String>();
            List<SObject> articles = new List<SObject>();
            
                
            for(String articleTypeApiName :createDescribeMap())
            {
                //Retrieve all existing Draft articles
                OrigDraftArticles.addAll(Database.query(generateQuery(deprecatedId, articleTypeApiName, 'Draft')));
                Boolean isDraftAvailable = false;
                if(!OrigDraftArticles.isEmpty()) isDraftAvailable  = true;
                
                //Retrieve all Online articles
                OnlineArticles.addAll(Database.query(generateQuery(deprecatedId, articleTypeApiName, 'Online')));
                
                //Retrieve all Archived articles
                ArchivedArticles.addAll(Database.query(generateQuery(deprecatedId, articleTypeApiName, 'Archived')));
                
                
                if(!OnlineArticles.isEmpty() && !isDraftAvailable){
                    String ArticleEdit = KbManagement.PublishingService.editOnlineArticle((Id) OnlineArticles[0].get('KnowledgeArticleId'), false);
                    
                    articlesToUpdate.add(OnlineArticles[0]);
                    articleIdToOriginalStatus.put(ArticleEdit,'Online');
                
                }
                else if(!ArchivedArticles.isEmpty() && !isDraftAvailable){
                    String ArticleEdit = KbManagement.PublishingService.editArchivedArticle((Id) ArchivedArticles[0].get('KnowledgeArticleId'));
                    
                    articlesToUpdate.add(ArchivedArticles[0]);
                    articleIdToOriginalStatus.put(ArticleEdit,'Archived');
                    
                }
                else if(isDraftAvailable){
                    OrigDraftArticles[0].put('geckid__c', survivorId);
                    update OrigDraftArticles[0];
                    //articlesToUpdate.add(OrigDraftArticles[0]);
                }
                
                                
                //Update Draft Articles
                if (articlesToUpdate.size() > 0)
                {
                    Sobject articletoUpdate = articlesToUpdate[0];
                    SObject updatedArticle =Database.query(generateKAVQuery((String)articleToUpdate.get('KnowledgeArticleId'),articleTypeApiName, 'Draft'));
                    updatedArticle.put('geckid__c', survivorId);
                    update updatedArticle;
                
                    System.Debug('Article updated');            
                    if (articleIdToOriginalStatus.containskey( (ID)updatedArticle.get('Id') ) )
                    {
                        System.Debug('Article to be published or archived'); 
                        String articleID;
                        if (articleIdToOriginalStatus.get( (ID)updatedArticle.get('Id')) == 'Archived')
                        {
                            //set status of Article to 'Online'
                            KbManagement.PublishingService.publishArticle( (Id)updatedArticle.get('KnowledgeArticleId'), false);
                            KbManagement.PublishingService.archiveOnlineArticle( (Id)updatedArticle.get('KnowledgeArticleId'), null);
                        }
                        else if (articleIdToOriginalStatus.get( (ID)updatedArticle.get('Id')) == 'Online')
                        {
                            //set status of Article to 'Online'
                            KbManagement.PublishingService.publishArticle( (Id)updatedArticle.get('KnowledgeArticleId'), false);
                        }
                    }                
                
                }
                
            }
            
            
            
        }
        catch (Exception ex)
        {
        System.debug('Exception in the ws code:'+ex.getMessage());
            return ex.getMessage();
        }
    
         
         return 'Updated successfully';
         
    }
    
   public static string generateQuery(String deprecatedId, String articleTypeApiName, string publishStatus)
    {
        String query = 'SELECT Id,KnowledgeArticleId,  GeckId__c,  publishStatus  from '+ articleTypeApiName +' WHERE GeckId__c = \'' + deprecatedId +'\' AND publishStatus = \''+publishStatus+'\'  AND Language = \'en_US\' AND GeckId__c != \'\'';
        
        return query;
    }
    
    
    public static string generateKAVQuery(String KAVId, String articleTypeApiName, string publishStatus)
    {
        String query = 'SELECT Id,KnowledgeArticleId,  GeckId__c,  publishStatus  from '+ articleTypeApiName +' WHERE KnowledgeArticleId = \'' + KAVId+'\' AND publishStatus = \''+publishStatus+'\'  AND Language = \'en_US\' AND GeckId__c != \'\'';
        
        return query;
    }
    
    //Gets all knowledge article API names dynamically
    public static Set<String> createDescribeMap() 
     {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> articlesNames = new Set<String>();
        for (String key :  gd.keySet()) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav'))
            {
                //only query article types that have geckid field
                if (objectType.getDescribe().fields.getmap().keySet().contains('geckid__c'))
                {
                    articlesNames.add(objectType.getDescribe().getName());
                }
            }
        }
        
        return articlesNames;
    }

}