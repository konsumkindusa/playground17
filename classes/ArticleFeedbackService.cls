/**
* @author Original: Krishna - Mathworks
* @date Original: June 12 2014 
* @description: GeckID:1031242, Webservice to set comments from Answers into Article Feedback.
*/


global class ArticleFeedbackService {
	
	webService static ArticleFeedbackResponse setArticleFeedback(String articleId, String articleNumber, CommentsInfo comments, String language){
		String email = comments.ownerEmail;
		list<User> user = new list<User>([Select id, profileid from user where email = :email]);
		
		// Verfiy if the user is a SFDC customer service user
		if(user.size() > 0){
			System.debug('User exists');
			for(User u : user){
				//Id id = u.ProfileId;
				System.debug('Profile Id:' +u.ProfileId);
				Profile profile = [Select id, name from profile where Id =: u.ProfileId];
				// Please move profile name to custom settings - KB
				if (profile.Name == 'MW Customer Service Standard User'){ return new ArticleFeedbackResponse('FAIL','User exists in SFDC'); }
				
			}
	
		}
		list <sobject> kav = new list <sobject>();
        list<Sobject> dataCatArticles = new list <Sobject>();
               
        kav.addAll(Database.query(generateQuery('Online', articleId, language)));
        if (kav.isEmpty()){
            kav.addAll(Database.query(generateQuery('Draft', articleId, language)));  
        }
          //Get available Data Category on current Article Type
        if (kav.isEmpty()){
        	return new ArticleFeedbackResponse('FAIL','Invalid Article Id');
        }       
         String kavId = (String)kav[0].get('Id');
         
        
        //Retrieve all Data Categories on all Knowledge Article Types
          String datquery = 'Select Id, ParentId, DataCategoryGroupName, DataCategoryName, CreatedDate, CreatedById, IsDeleted, SystemModstamp FROM FAQ__DataCategorySelection Where ParentId =: kavId';
          dataCatArticles.addAll(database.query(datquery));
        
        system.debug('@@dataCatArticles:'+dataCatArticles.size()+dataCatArticles);
        
        //Identify all Data Categories related to Knowledge Article
        list <String> platformOSGroup = new list <string>();
        list <String> topicGroup = new list <string>();
        list <String> typeGroup = new list <string>();
        list <String> productGroup = new list <string>();
        list <String> releaseGroup = new list <String>();
        for (Sobject dataCat : dataCatArticles){
          string dataCatGroupName = String.valueof(dataCat.get('DataCategoryGroupName'));
          if (dataCatGroupName == 'Platform_OS'){
            platformOSGroup.add((String)(dataCat.get('DataCategoryName')));
          }
          else if (dataCatGroupName == 'Topic'){
            topicGroup.add((String)(dataCat.get('DataCategoryName')));
          }
          else if (dataCatGroupName == 'Type'){
            typeGroup.add((String)(dataCat.get('DataCategoryName')));
          }
          else if (dataCatGroupName == 'Product'){
            productGroup.add((String)(dataCat.get('DataCategoryName')));
          }
          else if (dataCatGroupName == 'Verified_in_Release'){
            releaseGroup.add((String)(dataCat.get('DataCategoryName')));
          }
        }
        
        //Assign values to Article Feedback fields
            Article_Feedback__C afd = new Article_Feedback__C (
                Article_ID__C = articleId,
                Article_Number__C = (String)kav[0].get('articleNumber'),
                Article_Author__C = (Id)kav[0].get('CreatedById'),
                Article_Title__C = (String)kav[0].get('title'),
                Article_Version__C = (Integer)kav[0].get('VersionNumber'),
                Article_Link__C = 'https://'+URL.getSalesforceBaseUrl().getHost() + '/' + (Id)kav[0].get('KnowledgeArticleId') + '?popup=true',
                Comments__C = '',
                CommentsBy__c = email,    
                Language__c =  language,
                Answers_URL__c = (String)kav[0].get('Answers_URL__c')
            );
            
                	afd.Comments__C = comments.commentType+ ':' +comments.comment;
                
            
            //Include Data Categories on Article Feedback
            if (platformOSGroup.size() > 0){
              afd.Platform_OS_Group__c = '';
              for (String pos : platformOSGroup){
                afd.Platform_OS_Group__c += pos + ',';
              }
              afd.Platform_OS_Group__c = afd.Platform_OS_Group__c.subString(0, afd.Platform_OS_Group__c.length() - 1); //trim last comma
              if (afd.Platform_OS_Group__c.length() > 255) {
                afd.Platform_OS_Group__c = afd.Platform_OS_Group__c.subString(0, 254); //limit text to max character length - 255
              }
            }
            if (topicGroup.size() > 0){
              afd.Topic_Group__c = '';
              for (String topic : topicGroup){
                afd.Topic_Group__c += topic + ',';
              }
              afd.Topic_Group__c = afd.Topic_Group__c.subString(0, afd.Topic_Group__c.length() - 1); //trim last comma
              if (afd.Topic_Group__c.length() > 255) {
                afd.Topic_Group__c = afd.Topic_Group__c.subString(0, 254); //limit text to max character length - 255
              }
            }
            if (typeGroup.size() > 0){
              afd.Type_Group__c = '';
              for (String typ : typeGroup){
                afd.Type_Group__c += typ + ',';
              }
              afd.Type_Group__c = afd.Type_Group__c.subString(0, afd.Type_Group__c.length() - 1); //trim last comma
              if (afd.Type_Group__c.length() > 255) {
                afd.Type_Group__c = afd.Type_Group__c.subString(0, 254); //limit text to max character length - 255
              }
            }
            if (productGroup.size() > 0){
              afd.Product_Group__c = '';
              for (String prod : productGroup){
                afd.Product_Group__c += prod + ',';
              }
              afd.Product_Group__c = afd.Product_Group__c.subString(0, afd.Product_Group__c.length() - 1); //trim last comma
              if (afd.Product_Group__c.length() > 255) {
                afd.Product_Group__c = afd.Product_Group__c.subString(0, 254); //limit text to max character length - 255
              }
            }
            if (releaseGroup.size() > 0){
              afd.Verified_in_Release_Group__c = '';
              for (String rel : releaseGroup){
                afd.Verified_in_Release_Group__c += rel + ',';
              }
              afd.Verified_in_Release_Group__c = afd.Verified_in_Release_Group__c.subString(0, afd.Verified_in_Release_Group__c.length() - 1); //trim last comma
              if (afd.Verified_in_Release_Group__c.length() > 255) {
                afd.Verified_in_Release_Group__c = afd.Verified_in_Release_Group__c.subString(0, 254); //limit text to max character length - 255
              }
            }
            
            //Create Article Feedback
            insert afd;
            system.debug('@@Created Article Feedback:'+afd);
		return new ArticleFeedbackResponse('SUCCESS','Ok');		
	}
	//Gets all article fields dynamically on every article type  
  	public static string generateQuery(String pubstatus, String parentId, String language){
       String theQuery = 'SELECT Id, articleNumber, CreatedById, title, VersionNumber, KnowledgeArticleId, Answers_URL__c';
   	   theQuery+= ' FROM FAQ__kav WHERE Language = \'' + language+ '\' AND PublishStatus = \'' + pubstatus + '\' AND KnowledgeArticleId = \'' + parentId +'\' limit 1';
       
      system.debug('@@theQuery:'+theQuery);  
         return theQuery;
    }
	global class CommentsInfo {
		webservice String comment;
		webservice String commentType;
		webservice String ownerEmail;
		//Empty constructor
		public commentsInfo(){}
	}
	global class ArticleFeedbackResponse {
		webservice String Result;
		webservice String Reason;
		public ArticleFeedbackResponse(){}
		public ArticleFeedbackResponse(String Result, String Reason){
			this.Result=Result;
			this.Reason=Reason;
		}
	}
	
    

}