/**
* @author Original: Krishna Bhaskarla
* @date Original: 17 Sept 2013 
* @Article Webservice  to update Answers/Articles
*/

global class MW_ArticlesService {
    webService static String updateArticleURL(String articleId, String articleURL, String language){
    	try{
            FAQ__kav[] faqObjects;
            faqObjects = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c, IsMasterLanguage From FAQ__kav WHERE Language= : language AND PublishStatus = 'Online' and KnowledgeArticleId= : articleId limit 1];
            if(faqObjects.size() <= 0) {
		           system.debug('@@@ NO Articles Present');
		           return 'No articles found with articleId:'+articleId;
		    }
            if(faqObjects[0].IsMasterLanguage){
		             try{
		            	//unpublish Online article to become Draft
		            	String ArticleEdit;
		            	try{
		            		ArticleEdit = KbManagement.PublishingService.editOnlineArticle(articleId, true);
		             		system.debug('ArticleEdit:' +ArticleEdit);
		            	} catch (Exception ex) {
		            		System.debug('Exception editing article:'+ex.getMessage());
		            	    return ex.getMessage();
		            	}
		            	//Retrieve and Update Draft Article
		                FAQ__kav[] masterFAQ;
		                masterFAQ = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE Language= : language AND PublishStatus = 'Draft' and Id= : ArticleEdit limit 1];
		            
				            /*if (faqObjects.size() <= 0) {
				            	system.debug('@@@ Checking for Japanese Articles');
				               faqObjects = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE Language = 'ja' AND PublishStatus = 'Draft' and Id= : ArticleEdit limit 1];
				            }*/
			            Id id = masterFAQ[0].Id;
			            system.debug('ID:' +String.valueof(id));
			            masterFAQ[0].Answers_URL__c=articleURL;
			            masterFAQ[0].Article_To_Be_Sent__c='false';
			            update masterFAQ[0];
			            //Republish Article
			            KbManagement.PublishingService.publishArticle(articleId, true);
			            }catch (Exception ex){
		            		KbManagement.PublishingService.deleteDraftArticle(articleId);
		            		System.debug('Exception updating Article:'+ex.getMessage());
		            		return ex.getMessage();
		        		}
        	return 'SUCCESS';
    		} else {
    			String OlArticleEdit;
    			Id id;
    			 try{
    			 	
    			 	try{
    			 		OlArticleEdit= KbManagement.PublishingService.editPublishedTranslation(articleId,language,false);
    			 		system.debug('Translation OlArticleEdit:' +OlArticleEdit);
    			 	} catch (Exception ex) {
    			 			System.debug('Exception editing translation article:'+ex.getMessage());
		            	    return ex.getMessage();
    			    }
    			    FAQ__kav[] transFAQ;
    			    transFAQ = [Select Id, KnowledgeArticleId, Answers_URL__c, Article_To_Be_Sent__c From FAQ__kav WHERE Language= : language AND PublishStatus = 'Draft' and Id= : OlArticleEdit limit 1];
    			    id = transFAQ[0].Id;
    			    system.debug('ID:' +String.valueof(id));
			        transFAQ[0].Answers_URL__c=articleURL;
			        transFAQ[0].Article_To_Be_Sent__c='false';
			        update transFAQ[0];
			        //Republish Article
			        KbManagement.PublishingService.completeTranslation(id);
			        
    			 	
    			 } catch (Exception ex) {
    			 	KbManagement.PublishingService.deleteDraftTranslation (id);
    			 	System.debug('Exception updating translation article:'+ex.getMessage());
		            return ex.getMessage();
    			 }
    			 return 'SUCCESS';
    		}
            	
      } catch(Exception ex) {
    			 	System.debug('Exception editing article:'+ex.getMessage());
		            return ex.getMessage();
    			 }
    } 
}