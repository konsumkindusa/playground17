/**
* @author Original: Limo Sadalla- Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 17 June 2013, Last Modified: 31 July 2013
* @description Webservice to update articles with geck ID
*/ 

global class  UpdateArticleWithGeckId
{
    webService static String findAndUpdateArticles(String articleNumber, String geckId) 
    {
    
        try
        {
            list<SObject> OnlineArticles = new list<SObject>();
            list<Sobject> OrigDraftArticles = new list <Sobject>();
            list<Sobject> DraftArticles = new list <Sobject>();
            list<Sobject> ArchivedArticles = new list <Sobject>();
            list<Sobject> ArchivedOnlineArticles = new list <Sobject>();
            list<SObject> articlesToUpdate = new list<SObject>();
            map <ID,string> ReturnOnlineStatusMap = new map <ID,string>();
            
            for(String articleTypeApiName :createDescribeMap())
            {
                //Retrieve all existing Draft articles
                OrigDraftArticles.addAll(Database.query(generateQuery(articleNumber, articleTypeApiName, 'Draft')));
                
                //Retrieve all Online articles
                OnlineArticles.addAll(Database.query(generateQuery(articleNumber, articleTypeApiName, 'Online')));
                for (SObject article  :OnlineArticles)
                {
                    String ArticleEdit;
                    if (!OrigDraftArticles.isEmpty())
                    {
                        //Populate Draft Article with a GeckID
                        OrigDraftArticles[0].put('geckid__c', geckId);
                        articlesToUpdate.add(OrigDraftArticles[0]);
                        ArticleEdit = (String)OrigDraftArticles[0].get('Id');
                    }
                    else
                    {
                        //unpublish Online article to become Draft
                        ArticleEdit = KbManagement.PublishingService.editOnlineArticle((Id) article.get('KnowledgeArticleId'), false);
                    }
                    ReturnOnlineStatusMap.put( ArticleEdit,'Online');
                }
                
                //Retrieve all Archived articles
                ArchivedArticles.addAll(Database.query(generateQuery(articleNumber, articleTypeApiName, 'Archived')));
                for (SObject article  :ArchivedArticles)
                {
                    String ArticleEdit;
                    if (!OrigDraftArticles.isEmpty())
                    {
                        //Populate Draft Article with a GeckID
                        OrigDraftArticles[0].put('geckid__c', geckId);
                        articlesToUpdate.add(OrigDraftArticles[0]);
                        ArticleEdit = (String)OrigDraftArticles[0].get('Id');
                    }
                    else
                    {
                        //make Archived article to Draft
                        ArticleEdit = KbManagement.PublishingService.editArchivedArticle((Id) article.get('KnowledgeArticleId'));
                    }
                    ReturnOnlineStatusMap.put( ArticleEdit,'Archived');
                }
                
                if (OrigDraftArticles.isEmpty()){
                    //Retrieve all Draft articles that were unpublished from Online and Archived
                    DraftArticles.addAll(Database.query(generateQuery(articleNumber, articleTypeApiName, 'Draft')));
                    for (SObject article  :DraftArticles)
                    {
                        //Populate Draft Article with a GeckID
                        article.put('geckid__c', geckId);
                        articlesToUpdate.add(article);
                    }
                }
                
                //Update Draft Articles
                if (articlesToUpdate.size() > 0)
                {
                    update articlesToUpdate;
                }
                //Return status of each Draft Article
                for (SObject article : articlesToUpdate)
                {
                    if (ReturnOnlineStatusMap.containskey( (ID)article.get('Id') ) )
                    {
                        String articleID;
                        if (ReturnOnlineStatusMap.get( (ID)article.get('Id')) == 'Archived')
                        {
                            //set status of Article to 'Online'
                            KbManagement.PublishingService.publishArticle( (Id)article.get('KnowledgeArticleId'), false);
                            ArchivedOnlineArticles.addAll(Database.query(generateQuery(articleNumber, articleTypeApiName, 'Online')));
                        }
                        else if (ReturnOnlineStatusMap.get( (ID)article.get('Id')) == 'Online')
                        {
                            //set status of Article to 'Online'
                            KbManagement.PublishingService.publishArticle( (Id)article.get('KnowledgeArticleId'), false);
                        }
                    }
                }
                if (ArchivedOnlineArticles.size()>0)
                {
                    for (SObject article : ArchivedOnlineArticles)
                    {
                        //set status of Article to 'Archived'
                        KbManagement.PublishingService.archiveOnlineArticle( (Id)article.get('KnowledgeArticleId'), null);
                    }
                }
                
            }
            
        }
        catch (Exception ex)
        {
            return ex.getMessage();
        }
    
         return 'Updated successfully';
         
    }
    
   public static string generateQuery(String articleNumber, String articleTypeApiName, string publishStatus)
    {
        String query = 'SELECT Id, KnowledgeArticleId, geckid__c, Answers_URL__c,publishStatus,  ArticleNumber from '+ articleTypeApiName +' WHERE   publishStatus = \''+publishStatus+'\'  AND Language = \'en_US\' AND articleNumber = \''+articleNumber+'\'';
        
        return query;
    }
    
    //Gets all knowledge article API names dynamically
    public static Set<String> createDescribeMap() 
     {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> articlesNames = new Set<String>();
        for (String key :  gd.keySet()) 
        {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav'))
            {
                articlesNames.add(objectType.getDescribe().getName());
            }
        }
        
        return articlesNames;
    }

}