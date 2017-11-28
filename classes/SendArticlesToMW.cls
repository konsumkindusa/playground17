/*
*@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
*@author Modified: Krishna B - Mathworks; Modified method(s): CreateKnowledgeArticle; DESC: Configured CA cert and OrganizationID in HTTP headers; gID: 1019977
*@author Modified: Krishna B; method(s): sendArticles, CreateKnowledgeArticle, generateQueryWithFewColumns. Desc: Added new feature to unpublish articles by changing Validation Status to 'Internally Validated'; gId:1016077
*@date Original: 02 July 2013, Last Modified: 09 Dec 2013; 26 Dec 2013
*@description: Web service class for sending Articles to MW
*/ 
global class SendArticlesToMW {
    
    public static boolean rtimg = false;
    public static boolean rtimagesTest(){
        return rtimg;
    }
    public void testTheImages(){ 
        rtimg = true;
    }
    
    /*
    *@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    *@date Original: 02 July 2013, Last Modified: 17 October 2013; 26 Dec 2013
    *@description: main method for sending articles to Mathworks
    */ 
    public static void sendArticles(String userSessionId){
        Logger.push('sendArticles','SendArticlesToMW');
        //Custom Object holding information on Send Articles to Answers Integration data
        list <Integration_Settings__c> integrationSetting = new list <Integration_Settings__c>();
        integrationSetting = [Select Id, Name, Username__c, Password__c, Clientname__c, Endpoint__c, Timeout__c, Token__c, Batch_Size__c From Integration_Settings__c Where Name = 'Send Articles to MW Answers' limit 1];
        list <Attachment> integattlist = [Select Id From Attachment Where ParentId = : integrationSetting[0].Id];
        //Remove RichText image attachments from previous scheduled run
        if (integattlist.size() > 0){
            delete integattlist;
        }
        
        List<SObject> articles = new List<SObject>();
        List<SObject> temparticles = new List<SObject>();
        List<SObject> tempAllArticles = new List<SObject>();
       
        try{
            //Retrieves all Articles that will be sent to Mathworks
            for(Schema.Sobjecttype articleTypeApiName :createDescribeMap()){
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'en_US', true, true)));
                //Get all US articles with validation status ='Internally Validated' - gId:1016077
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'en_US', true, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'en_US', true, true)));
                system.debug('@@temparticles:'+temparticles);
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'en_US', true, true)));
                system.debug('@@temparticles:'+temparticles);
                
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ja', true, true)));
                //Get all JP articles with validation status ='Internally Validated' - gId:1016077
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ja', true, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'ja', true, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'ja', true, true)));
                
                
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'en_US', false, true)));
                //Get all translated articles with validation status ='Internally Validated' - gId:1016077
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'en_US', false, false)));
                system.debug('@@temparticles:'+temparticles);
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'en_US', false, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'en_US', false, true)));
                
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ja', false, true)));
                //Get all translated articles with validation status ='Internally Validated' - gId:1016077
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ja', false, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'ja', false, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'ja', false, true)));
                
                // Get Korean Articles 
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ko', true, true)));
                //Get all JP articles with validation status ='Internally Validated' - gId:1016077
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ko', true, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'ko', true, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'ko', true, true)));
                
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ko', false, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'ko', false, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'ko', false, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'ko', false, true)));
                
                
                //Get Chinese Articles
                 temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'zh_CN', true, true)));
                //Get all JP articles with validation status ='Internally Validated' - gId:1016077
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'zh_CN', true, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'zh_CN', true, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'zh_CN', true, true)));
                
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'zh_CN', false, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Online', 'zh_CN', false, false)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Draft', 'zh_CN', false, true)));
                temparticles.addAll(Database.query(generateQueryWithFewColumns(articleTypeApiName, 'Archived', 'zh_CN', false, true)));
                system.debug('@@temparticles:'+temparticles);
                                
                
                
                for (Sobject tempart : temparticles){
                    system.debug('@@articlesadded:'+temparticles.size());
                    DateTime lastpubdate = DateTime.valueOf(tempart.get('LastPublishedDate'));
                    DateTime lastmoddate = DateTime.valueof(tempart.get('LastModifiedDate'));
                    DateTime lastarcdate = DateTime.valueof(tempart.get('ArchivedDate'));
                    Integer timeNowMinus15min = datetime.now().minute() - 15;
                    //Filter all Articles that were published/archived/remove from publication 15 minutes before current time OR all Articles that will be sent
                    system.debug('@@tempart:'+(String)tempart.get('title')+',lastpubdate='+lastpubdate+',lastmoddate='+lastmoddate+',lastarcdate'+lastarcdate);
                    if ( (datetime.now().date() == lastpubdate.date() && datetime.now().hour() == lastpubdate.hour() && lastpubdate.minute() > timeNowMinus15min) || //for Online Articles
                         (datetime.now().date() == lastmoddate.date() && datetime.now().hour() == lastmoddate.hour() && lastmoddate.minute() > timeNowMinus15min) || //for Articles to be removed from publication and Archived Articles
                         (tempart.get('Article_To_Be_Sent__c') == 'true' ) ){ //for pending articles from last scheduled run
                         articles.add(tempart);
                    }
                }
            }
            system.debug('@@articles:'+articles.size()+articles);
            
            if (articles.size() > 0){
                               
                
                list <Sobject> tempremArticles = new list <Sobject>();
                list <Sobject> tempremTransArticles = new list <Sobject>();
                list <Id> articleIDs = new list <Id>();
                List<Id> articleTransIds = new List<Id>();
                map <string,string> ArchivedIdMap = new map<string,string>();
                map <string,string> DraftIdMap = new map<string,string>();
                
                map<string, SObject> ArticleIdKavIdMap = new map<String, SObject>();
               // map<string, SObject> ArticleIdKavIdJPMap = new map<String, SObject>();
                 
                
                //Add/Unpublish/Unarchived all Articles that will be updated
                Set <String> articleEditSet = new set <string>();
                Set<String>articleTransEditSet = new Set<String>();
                               
                for (sobject art : articles){
                    try{
                        system.debug('@@publish status:'+(String)art.get('PublishStatus'));
                        system.debug('@@ArticleNumber:'+(String)art.get('ArticleNumber'));
                        System.Debug('@@Article Language:'+(String)art.get('Language'));
                        String lang = (String)art.get('Language');
                        if(art.get('Article_To_Be_Sent__c') == 'true'){
                        System.Debug('@@article to be sent:'+art.get('Article_To_Be_Sent__c'));
                        System.Debug('@@Article to be sent Id:'+art.get('Id'));
                        // Add drafts to the map to fix draft issue - KB
                        if((String)art.get('PublishStatus') == 'Draft'){
                            DraftIdMap.put((String)art.get('KnowledgeArticleId'),(String)art.get('KnowledgeArticleId'));
                            system.debug('@@DraftIDMap True:'+DraftIDMap.size()+':'+DraftIDMap);
                        }
                        if((String)art.get('PublishStatus') == 'Archived'){
                            ArchivedIdMap.put((String)art.get('KnowledgeArticleId'),(String)art.get('KnowledgeArticleId'));
                            system.debug('@@ArticleIDMap True:'+ArchivedIdMap.size()+':'+ArchivedIdMap);
                        }
                        
                            tempAllArticles.add(art);
                        }
                        else{
                        //add articles for removal of publication on update
                        if ((String)art.get('PublishStatus') == 'Draft'){
                                System.debug('@@@InDraft:');
                                String aNo = (String)art.get('ArticleNumber');
                                list<FAQ__kav> checkOnline = new list<FAQ__Kav>([Select id from FAQ__KAV where language =:lang and publishstatus = 'Online' and validationstatus='Externally Validated' and articlenumber =:aNo]);
                                if(checkOnline.size() <= 0){
                                    articleEditSet.add((String)art.get('Id'));
                                    // Adding Draft to the map - KB
                                    DraftIdMap.put((String)art.get('KnowledgeArticleId'),(String)art.get('KnowledgeArticleId'));
                                    system.debug('@@DraftIDMap:'+DraftIDMap.size()+':'+DraftIDMap);
                                }
                                
                            
                        }
                        //unpublish Online article to become Draft
                        if ((String)art.get('PublishStatus') == 'Online'){
                             Boolean isMastLang = (boolean)art.get('IsMasterLanguage');
                                if(isMastLang){                            
                                    String OlArticleEdit = KbManagement.PublishingService.editOnlineArticle((Id) art.get('KnowledgeArticleId'), false);
                                    articleEditSet.add(OlArticleEdit);
                                    System.debug('Online Article:' +OlArticleEdit);
                                }else{
                                    //edit a published translation.
                                    String OlArticleEdit = KbManagement.PublishingService.editPublishedTranslation((Id) art.get('KnowledgeArticleId'),lang,false);
                                    articleTransEditSet.add(OlArticleEdit);
                                }
                          
                        }
                        //unpublish Archived article to become draft both en_US and ja
                        if ((String)art.get('PublishStatus') == 'Archived'){
                             Boolean isMastLang = (boolean)art.get('IsMasterLanguage');
                                if(isMastLang){
                                    String ArcArticleEdit = KbManagement.PublishingService.editArchivedArticle((Id) art.get('KnowledgeArticleId'));
                                    articleEditSet.add(ArcArticleEdit); 
                                    ArchivedIdMap.put((String)art.get('KnowledgeArticleId'),(String)art.get('KnowledgeArticleId'));
                                }
                          }
                      }
                    }catch(Exception ex){
                        System.Debug('@@Exception while editing the article to set the flag:'+ex.getMessage());
                    }
                }
                
                //Retrieves all Articles that will be updated. Include the rich text feilds also in th query so that we can get the inline images data.
                //We cannot get the inline images data using getcontent in the future call. 
                for(Schema.Sobjecttype articleTypeApiName :createDescribeMap()){
                    //en_US articles
                    String tempartQuery = 'SELECT Article_To_Be_Sent__c, ArticleNumber, KnowledgeArticleId, Id, ArticleType, Language, IsMasterLanguage FROM ' + articleTypeApiName + ' WHERE Language IN (\'en_US\',\'ja\',\'ko\',\'zh_CN\') AND PublishStatus = \'' + 'Draft' + '\' AND Id in : articleEditSet';
                    tempremArticles.addAll(Database.query(tempartQuery));
                    String tempartTransQuery = 'SELECT Article_To_Be_Sent__c, ArticleNumber, KnowledgeArticleId, Id, ArticleType, Language, IsMasterLanguage FROM ' + articleTypeApiName + ' WHERE Language IN (\'en_US\',\'ja\',\'ko\',\'zh_CN\') AND PublishStatus = \'' + 'Draft' + '\' AND Id in : articleTransEditSet';
                    tempremTransArticles.addAll(Database.query(tempartTransQuery));
                   //english articles
                    for (Sobject tempart : tempremArticles){
                        //All article types must have this custom field to be able for the Articles to be updated
                        tempart.put('Article_To_Be_Sent__c','true');
                        articleIDs.add((String)tempart.get('KnowledgeArticleId'));
                        //ArticleIdKavIdMap.put((String)tempart.get('KnowledgeArticleId'), tempart);
                    }
                                                   
                    //english translation articles
                    for (Sobject tempart : tempremTransArticles){
                        //All article types must have this custom field to be able for the Articles to be updated
                        tempart.put('Article_To_Be_Sent__c','true');
                        articleTransIds.add((String)tempart.get('KnowledgeArticleId'));
                        ArticleIdKavIdMap.put((String)tempart.get('KnowledgeArticleId'), tempart);
                    }
                                   
                }
                
                system.debug('@@DraftIDMap:'+DraftIDMap.size()+':'+DraftIDMap);
                if (tempremArticles.size() > 0 || tempremTransArticles.size() > 0 || tempALlArticles.size()>0){
                    if(tempremArticles.size() > 0){
                    //Update articles
                    update tempremArticles;
                    system.debug('@@tempremArticles:'+tempremArticles.size()+tempremArticles);
                    }
                    if(tempremTransArticles.size() > 0){
                    update tempremTransArticles;
                    system.debug('@@tempremTransArticles:'+tempremTransArticles.size()+tempremTransArticles);
                    }
                    //republish english translation articles
                    for (String articleId : articleTransIds) {
                        //Republish Articles that were previously Online
                        system.debug('@@articleID:'+articleID);
                        if (!DraftIdMap.containskey(articleId)){
                            Boolean isMastLang = true;
                            String artkavId='';
                            Sobject kavArt = ArticleIdKavIdMap.get(articleId);
                            if(kavArt != null){
                                isMastLang = (Boolean)kavArt.get('IsMasterLanguage');
                                artkavId = (String)kavArt.get('Id');
                            }                            
                            KbManagement.PublishingService.completeTranslation(artkavId);
                      
                            
                        }
                     }
                    //Republish Updated master Articles
                    for (String articleId : articleIds) {
                        //Republish Articles that were previously Online
                        system.debug('@@articleID:'+articleID);
                        if (!DraftIdMap.containskey(articleId)){                            
                                KbManagement.PublishingService.publishArticle(articleId, false);
                        }
                        //Return Online Article as Archived article
                        if (ArchivedIdMap.containskey(articleId)){
                            KbManagement.PublishingService.archiveOnlineArticle(articleId, null);   
                        }
                    }
                    
                   tempAllArticles.addAll(tempremTransArticles);
                   tempAllArticles.addAll(tempremArticles);
                                  
                    Integer ctr=1;
                    for(Sobject art: tempAllArticles){ //maximum of 9 articles because there is a future call used to get the sessionId.
                        //reserve identified excess Articles on next batch run to avoid too many callouts error
                        system.debug('@@ctr:'+ctr);
                        
                        //Maximum number of methods with the future annotation allowed per Apex invocation  50
                        if (ctr <= integrationSetting[0].Batch_Size__c){
                            system.debug('@@tempremArt:'+art);
                            
                            //execute Webservice callout on every article to be sent
                            SendArticlesToMW.CreateKnowledgeArticle(String.valueof(art.get('title')),String.valueof(art.get('Id')),integrationSetting[0].UserName__c,
                                              integrationSetting[0].password__c,integrationSetting[0].Endpoint__c,integrationSetting[0].timeout__c,integrationSetting[0].token__c, Integer.valueof(integrationSetting[0].Batch_Size__c),ctr,tempAllArticles.size(),userSessionId, integrationsetting[0].Id, String.valueof(art.get('Language')));
                            ctr++;
                        }
                    }
                    
                }
            }
            else{
                //Update Send Article Setting Custom Setting
                Send_Article_Settings__c saset = Send_Article_Settings__c.getOrgDefaults();
                saset.Last_Run_Status__c = 'No articles to be sent.';
                saset.Last_Scheduled_Run__c = DateTime.now();
                saset.Number_of_Articles_Sent__c = 0;
                update saset;   
            }
            Logger.pop();
            
        }
        catch(exception e){
            //Update Send Article Setting Custom Setting
            Send_Article_Settings__c saset = Send_Article_Settings__c.getOrgDefaults();
            string str = e.getMessage();
            if (str.length() > 200) str = str.substring(0,200);
            saset.Last_Run_Status__c = 'Error occured:'+str+'-SendArticlesToMW['+e.getLineNumber()+']';
            saset.Last_Scheduled_Run__c = DateTime.now();
            saset.Number_of_Articles_Sent__c = 0;
            update saset;
            system.debug('@@saet-failed:'+saset);
            system.debug('@@error:'+e.getLineNumber()+e.getMessage());
            Logger.pop();
        }
        
    }
    
    /*
    *@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    *@date Original: 02 July 2013, Last Modified: 09 October 2013
    *@description: Web service method for sending articles to Mathworks
    */ 
    @future (callout=true)
    public static void CreateKnowledgeArticle(string title, Id articleId, string integuser, string integpass, string integendpoint, decimal integtimeout, string token, integer batchSize, integer RecCounter, integer numarticles, String sessionID, String attParentId, String lang){
        Logger.push('CreateKnowledgeArticle','SendArticlesToMW');
        try {
            system.debug('@@Article ID about to be processed:'+articleId);
            SendArticlesWSDL1.KAResponseType karesponse = new SendArticlesWSDL1.KAResponseType();
            SendArticlesWSDL1.SupportAnswer wsarticle = new SendArticlesWSDL1.SupportAnswer();
            
            map <string,string> DataCatMap = new map <string,string>();
            map <string, SendArticlesWSDL1.Attachments> richtextIMGMap = new map <string, SendArticlesWSDL1.Attachments>();
            map <string,SendArticlesWSDL1.Categories> ArtDCMap = new map <string,SendArticlesWSDL1.Categories>();
            set<string> datacatIdSet = new set<string>();
            List<Sobject> dataCatArticles = new list <Sobject>();
            
            Schema.SobjectType objectType = articleId.getSObjectType();
            String articleTypeApiName = String.valueof(objectType);
            Schema.DescribeSObjectResult objdescribe = objectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            //Get current Article to be sent
            String theQuery = 'SELECT ';
            for (Schema.Sobjectfield field : fieldMap.values()){
                theQuery+= field.getDescribe().getName() + ',';
            }
            theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
            theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'' + lang + '\' AND Id = : articleId limit 1';
            system.debug('@@query with lang:'+theQuery);
            Sobject art = Database.query(theQuery);
            system.debug('@@Art:'+art);
            string publishStatus = String.valueof(art.get('PublishStatus'));
            string answersURL = String.valueof(art.get('Answers_URL__c')); //2102931
            //HW 1835704
            if(publishStatus == 'Online' && 
                (String.valueof(art.get('ValidationStatus')) == 'Internally Validated' || String.valueof(art.get('ValidationStatus')) == 'Not Validated')){
                 publishStatus = 'Archived';
                 system.debug('@@@### Setting Validation Status as Archived');
            }    

            //Establish connection details with Articles to Answers service
            SendArticlesWSDL1.SupportAnswersService wscall = new SendArticlesWSDL1.SupportAnswersService();
            Blob headerValue = Blob.valueOf(integuser + ':' + integpass);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

            // Setting OrganizationID and authorization in HTTP headers - Krishna
            wscall.inputHttpHeaders_x=new Map<String,String>();
            wscall.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            wscall.inputHttpHeaders_x.put('OrganizationID', UserInfo.getOrganizationId());
            
            // Setting CA signed certificate for Apex Callout - Krishna
            IntegrationUtilityHelper intUtilityHelper = new IntegrationUtilityHelper();
            wscall.clientCertName_x = intUtilityHelper.getCACertIntegration();
            
            wscall.timeout_x = Integer.valueof(integtimeout);
            wscall.endpoint_x = integendpoint;
            
            //execute WebService callout for sending Article to Mathworks
            if (publishStatus == 'Online') {

                //Get rich text fields
                list <string> richtextfieldlist = ArticleRichTextFields(objectType);
                //Get available Data Category on current Article Type
                String ArticleTypePrefix = String.valueof(articleTypeApiName).substring(0, String.valueof(articleTypeApiName).indexOf('__kav')) + '__';
                DataCatMap.put(ArticleTypePrefix+'kav',ArticleTypePrefix+'DataCategorySelection');
                
                map<string,string> wsartMap = new map <string,string>();
                
                system.debug('@@Article to be sent:'+String.valueof(art.get('ArticleNumber'))+'::::'+articleId);
                        
                //Identify each Article Type and its DataCategorySelection s
                //Populate fields of the Article that will be sent to Mathworks
                wsarticle.article_id = String.valueof(art.get('KnowledgeArticleId'));
                wsarticle.article_number = String.valueof(art.get('ArticleNumber'));
                
                SendArticlesWSDL1.Question qu = new SendArticlesWSDL1.Question();
                //wsarticle.Title = String.valueof(art.get('Title'));
                qu.question = String.valueof(art.get('Title'));
                //wsarticle.Question = String.valueof(art.get('Question_RT__c'));
                qu.body_html = String.valueof(art.get('Question_RT__c'));
                //wsarticle.CreatedDate = Date.valueof(art.get('CreatedDate'));
                qu.published_at = Date.valueof(art.get('CreatedDate'));
                wsarticle.question = qu;
    
                SendArticlesWSDL1.Answer an = new SendArticlesWSDL1.Answer();
                //wsarticle.Answer = String.valueof(art.get('Answer__c'));
                an.body_html = String.valueof(art.get('Answer__c'));
                //wsarticle.CreatedDate = Date.valueof(art.get('CreatedDate'));
                an.published_at = Date.valueof(art.get('CreatedDate'));
                wsarticle.answer = an;
                
                wsarticle.Tags = String.valueof(art.get('Tags__c'));
                //wsarticle.ValidationStatus = String.valueof(art.get('ValidationStatus'));
                //string publishStatus = String.valueof(art.get('PublishStatus'));
                //wsarticle.AnswersURL = String.valueof(art.get('Answers_URL__c'));
                wsarticle.related_questions = String.valueof(art.get('Related_Articles__c'));
                wsarticle.language = String.valueof(art.get('language'));
                //string createdById = String.valueof(art.get('CreatedById'));
                //User createdByuser = [Select Name From User Where Id =: createdById];
                //wsarticle.CreatedBy = (String) createdByUser.Name; 
                // update the status as 'Archived' in the WS call for all articles which have vlaidation Status as 'Internally Validated'; gID: 1016077
                //Get attachments - images on every richtext fields on every Article
                list <SendArticlesWSDL1.Attachment> wsimglist = new list <SendArticlesWSDL1.Attachment>();
                list <string> imgaddresslist = new list <string>();
                String articletype = String.valueof(art.get('ArticleType'));
                if( richtextfieldlist.size() > 0 ){
                    for (String rtfield : richtextfieldlist){
                        system.debug('@@current rich text field:'+rtfield+String.valueof(art.get(rtfield)));
                        String rtfieldvalue = String.valueof(art.get(rtfield));
                        if  (rtfieldvalue != null){
                            String imgaddress = '';
                            integer matchCount = rtfieldvalue.countMatches('<img');
                            for (integer i=0; i < matchCount; i++){
                                SendArticlesWSDL1.Attachment wsimg = new SendArticlesWSDL1.Attachment();
                                integer firstIndex = rtfieldvalue.indexOf('<img');
                                integer secondIndex = rtfieldvalue.indexOf('</img>')+6;
                                String imgTag = rtfieldvalue.substring(firstIndex,secondIndex);
                                imgaddress = imgTag.substringAfter('src="').substringBefore('"').replace('amp;','');
                                rtfieldvalue = rtfieldvalue.replace(imgTag,''); //remove retrieved image to get next image
                                system.debug('@@imgaddress:'+imgaddress);
                                //Populate image attributes
                                wsimg.url = imgaddress;
                                if (!Test.isRunningTest()){
                                    //collect all rich text images to be created as Attachments
                                    if(!String.isBlank(imgaddress)){
                                        imgaddresslist.add(imgaddress);
                                        System.debug('$$imgaddress$$'+imgaddress);
                                    }  
                                    System.debug('##Test.isRunningTest()##'+Test.isRunningTest());                             
                                }
                                else{
                                    System.debug('##rtimagesTest()##');
                                    if (rtimagesTest()){
                                        SendArticlesToMWImages.LogInfo log = new SendArticlesToMWImages.LogInfo();
                                        SendArticlesToMWImages.AllowFieldTruncationHeader_element fieldtrunc = new SendArticlesToMWImages.AllowFieldTruncationHeader_element();
                                        SendArticlesToMWImages.DebuggingHeader_element debugh = new SendArticlesToMWImages.DebuggingHeader_element();
                                        SendArticlesToMWImages.CallOptions_element callopt = new SendArticlesToMWImages.CallOptions_element();
                                        SendArticlesToMWImages.DebuggingInfo_element debuginfo = new SendArticlesToMWImages.DebuggingInfo_element();
                                        system.debug('@@imgaddressTest:'+imgaddress);
                                        imgaddresslist.add(imgaddress); 
                                    }
                                    wsimg.data = Encodingutil.base64Encode(Blob.valueof('UNIT.Test'));
                                    wsimglist.add(wsimg);
                                }
                            }
                        }
                    }
                    
                    //Fix for getContent issue on @future and scheduled batch
                        System.debug('$$imgaddresslist$$'+imgaddresslist.size());
                        System.debug('$$imgaddresslist$$'+imgaddresslist);
                    if (imgaddresslist.size() > 0){
                        SendArticlesToMWImages.SendArticlesToMW sawa = new SendArticlesToMWImages.SendArticlesToMW();
                        SendArticlesToMWImages.SessionHeader_element  sawasi = new SendArticlesToMWImages.SessionHeader_element();                    
                        sawasi.sessionId = sessionId;
                        system.debug('@@sawasi.sessionId:'+sawasi.sessionId);
                        sawa.SessionHeader = sawasi;
                        sawa.timeout_x = 60000;
                        
                        list <Attachment> attlist = new list <Attachment>(); //HW 1816555
                        //Execute webservice method for creating Attachments from RichText Images
                        try{
                            //HW 1816555
    
                            //sawa.getRichTextImages(imgaddresslist,attParentId,recCounter);
    
                            Integer imgctr = 1;
                            for (String image : imgaddresslist){
                                Attachment attach = new Attachment();
                                Blob body;
    
                                body = new PageReference(image).getContent();
                                attach.Body = body;
                                attach.Name = 'inlineimage-[ArticleNo'+recCounter+']-['+imgctr+'].jpg';
                                attach.Description = image;
                                attach.IsPrivate = false;
                                attach.ParentId = attParentId;
                                attlist.add(attach);
                                imgctr++;
                            }
                            //HW 1816555
    
    
    
                        }catch(Exception ex){
                           // Send_Article_Settings__c saset = Send_Article_Settings__c.getOrgDefaults();
                           // saset.Last_Run_Status__c = 'Error occured in SOAP call:'+ex.getMessage()+'-SendArticlesToMW['+ex.getLineNumber()+']';
                           // saset.Last_Scheduled_Run__c = DateTime.now();
                          //  saset.Number_of_Articles_Sent__c = 0;
                           // update saset;
                           // system.debug('@@saet-failed in SOAP call:'+saset);
                            system.debug('Exception in ws:'+ex.getMessage());
                        }
                        //Retrieve created Attachments from RichText images and pass to SendArticlesWSDL1.AttachmentType
                        
                        //HW 1816555
                        //for (Attachment att : [Select Id, Body, Description From Attachment Where ParentId = : attParentId and Description in :imgaddresslist]){
                        for (Attachment att : attlist){
                                SendArticlesWSDL1.Attachment wsimg = new SendArticlesWSDL1.Attachment();
                                wsimg.url = att.Description;
                                system.debug('@@image addr:'+ att.Description);
                                wsimg.data = Encodingutil.base64Encode(att.Body);
                                system.debug('@@image binary:'+ wsimg.data);
                                wsimglist.add(wsimg);
                        }
                    } 
                }
                
                //Get attachments from Attachment fields - Attachments 1 to 5
                if (String.valueof(art.get('Attachments__Body__s')) != null ){
                    system.debug('@@attachment body is:'+art.get('Attachments__Body__s'));
                    SendArticlesWSDL1.Attachment wsatt = new SendArticlesWSDL1.Attachment();
                    //wsatt.SFURL = String.valueof((Blob)art.get('Attachments__Body__s'));
                    wsatt.url = String.valueof(art.get('Attachments__Name__s'));
                    //wsatt.AttachmentBinary = Encodingutil.base64Encode(Blob.valueof(wsatt.SFURL));
                    wsatt.data = Encodingutil.base64Encode((Blob)art.get('Attachments__Body__s'));
                    wsimglist.add(wsatt);
                }
                for (Integer i = 2; i < 6; i++){
                    String attfield = 'Attachment_'+i+'__Body__s';
                    String attNameField = 'Attachment_'+i+'__Name__s';
                    if (String.valueof(art.get(attfield)) != null){
                        system.debug('@@attfield:'+attfield);
                        system.debug('@@attfieldBody:'+String.valueof(art.get(attfield)));
                        SendArticlesWSDL1.Attachment wsatt = new SendArticlesWSDL1.Attachment();
                       // wsatt.SFURL = String.valueof((Blob)art.get(attfield));
                       wsatt.url = String.valueof(art.get(attNameField));
                        //wsatt.AttachmentBinary = Encodingutil.base64Encode(Blob.valueof(wsatt.SFURL));
                        wsatt.data = Encodingutil.base64Encode((Blob)art.get(attfield));
                        
                        wsimglist.add(wsatt);
                    }
                } 
                //Include Attachments to Article that will be sent
                SendArticlesWSDL1.Attachments ats = new SendArticlesWSDL1.Attachments();
                ats.attachment = wsimglist;
                system.debug('@@wsimglist:'+wsimglist);
                if (wsimglist.size() > 0){
                    richtextIMGMap.put(String.valueof(art.get('Id')), ats);
                }
                
                    
                //Identify Data Categories on every Article Type
                if (art.get('ArticleType') != null){
                    if (DataCatMap.containskey( String.valueof(art.get('ArticleType') ) ) ){
                        DataCatMap.put(ArticleTypePrefix+'kav',ArticleTypePrefix+'DataCategorySelection');
                    }
                    datacatIdSet.add(String.valueof(art.get('Id')));
                    //Getting datacategories for Translated articles - Krishna
                    if(!Boolean.valueof(art.get('IsMasterLanguage'))){
                         system.debug('@@## Fetching Master ArticleID');
                         datacatIdSet.add(String.valueof(art.get('MasterVersionId')));
                    }
                }
                    
                system.debug('@@richTextIMGMap:'+richtextIMGMap.size()+richtextIMGMap);
                system.debug('@@DataCatMap:'+DataCatMap.size()+DataCatMap);
                system.debug('@@datacatIdSet:'+datacatIdSet.size()+datacatIdSet);
                
                //Retrieve all Data Categories on all Knowledge Article Types
                for (String atype : DataCatMap.keySet()){
                    String datquery = 'Select Id, ParentId, DataCategoryGroupName, DataCategoryName, CreatedDate, CreatedById, IsDeleted, SystemModstamp FROM ' + DataCatMap.get(atype) + ' Where ParentId in : datacatIdSet ';
                    dataCatArticles.addAll(database.query(datquery));
                }
                system.debug('@@dataCatArticles:'+dataCatArticles.size()+dataCatArticles);
                
                //Identify all Data Categories related to Knowledge Article
                //list <String> platformOSTypes = new list <string>();
                list<SendArticlesWSDL1.Platform> wspfList = new list<SendArticlesWSDL1.Platform>();
                list <String> topicTypes = new list <string>();
                list <String> productTypes = new list <string>();
                list <String> releaseTypes = new list <String>();
                //SendArticlesWSDL1.DatacategoryType wsdct = new SendArticlesWSDL1.DatacategoryType();
                list <String> catTypes = new list <String>();
                //Populate datacategorytype attributes
                for (Sobject artDC : dataCatArticles){
                    string dataCatGroupName = String.valueof(artDC.get('DataCategoryGroupName'));
                    String parentID = String.valueof(artDC.get('ParentId'));
                    
                    system.debug('@@@DataCat groupname:'+ dataCatGroupName);
                    if (dataCatGroupName == 'Product'){
                        productTypes.add(String.valueof(artDC.get('DataCategoryName')));
                    }
                    else if (dataCatGroupName == 'Topic'){
                        topicTypes.add(String.valueof(artDC.get('DataCategoryName')));
                    }
                    else if (dataCatGroupName == 'Platform_OS'){
                        SendArticlesWSDL1.Platform wspf = new SendArticlesWSDL1.Platform();
                        wspf.platform = String.valueof(artDC.get('DataCategoryName'));
                        wspfList.add(wspf);
                    }
                    else if (dataCatGroupName == 'Verified_in_Release'){
                        releaseTypes.add(String.valueof(artDC.get('DataCategoryName')));
                    }
                    
                    SendArticlesWSDL1.Categories wstt = new SendArticlesWSDL1.Categories();
                    SendArticlesWSDL1.Products wspt = new SendArticlesWSDL1.Products();
                    SendArticlesWSDL1.Platforms wspft = new SendArticlesWSDL1.Platforms();
                    SendArticlesWSDL1.Releases wsrt = new SendArticlesWSDL1.Releases();
                    
                    if (productTypes.size() > 0 ){
                        wspt.product = productTypes;
                        wsarticle.products = wspt;
                        //wsdct.Products = wspt;
                        system.debug('@@ProductType:'+wspt);
                    }
                    if (topicTypes.size() > 0){
                        wstt.category = topicTypes;
                        wsarticle.categories = wstt;
                        //wsdct.Topics = wstt;
                        system.debug('@@TopicType:'+wstt);
                    }
                    if (wspfList.size() > 0){
                        wspft.platform = wspfList;
                        wsarticle.platforms = wspft;
                        //wsdct.Platforms = wspft;
                        system.debug('@@PlatformType:'+wspft);
                    }
                    if (releaseTypes.size() > 0){
                        wsrt.release = releaseTypes;
                        wsarticle.releases = wsrt;
                        //wsdct.VerifiedInReleases = wsrt;
                        system.debug('@@ReleaseType:'+wsrt);
                    }
                    
                    
                    //add new data categories on non-existing ParentID in map
                   // if (!ArtDCMap.containskey(parentId)){
                       // wsdct = new SendArticlesWSDL1.DatacategoryType();
                    //}
                    //add new data categories on existing ParentID in map
                   // else{
                    //    wsdct = ArtDCMap.get(parentID);
                   // }
                    
                }
                 //ArtDCMap.put(wsarticle.ArticleId,wsdct);               
                //Include DataCategories and Attachments to Article that will be sent
                
                /*
                if (wsartMap.containskey(wsarticle.ArticleId)){
                System.Debug('@@Article Exists in the wsartMap Map');
                    //Add dataCategories attributes to related Article
                    if (ArtDCMap.containskey(wsArtMap.get(wsarticle.ArticleID))){
                        wsarticle.Datacategories = ArtDCMap.get(wsArtMap.get(wsarticle.ArticleID));
                    }
                    //Add attachments attributes to related Article
                    if (richtextIMGMap.containskey(wsArtMap.get(wsarticle.ArticleID))){
                        wsarticle.Attachments = richtextIMGMap.get(wsArtMap.get(wsarticle.ArticleID));
                    }
                }
                */
                
                system.debug('@@richtextIMGMap.get(wsarticle.article_id):'+richtextIMGMap.get(wsarticle.article_id));
                system.debug('@@richtextIMGMap.get(ID):'+richtextIMGMap.get((String)art.get('Id')));
                //wsarticle.Datacategories = wsdct;
                wsarticle.attachments = richtextIMGMap.get((String)art.get('Id'));
                //system.debug('@@wsarticles:'+wsarticle);
            
                system.debug('@@publishSupportAnswer:');
                karesponse = wscall.publishSupportAnswer(token, wsarticle);
            //} else if (publishStatus == 'Draft' || publishStatus == 'Archived') { //2102931
            } else if (string.isNotBlank(answersURL) && (publishStatus == 'Draft' || publishStatus == 'Archived')) { //2102931
                system.debug('@@unpublishSupportAnswer:');
                karesponse = wscall.unpublishSupportAnswer(token, String.valueof(art.get('KnowledgeArticleId')), lang);
            }
            
            //system.debug('@@wsarticles:'+wsarticle);
            system.debug('@@karesponse.status:'+karesponse.status);
            system.debug('@@karesponse:'+karesponse);
            
            //Update Send Article Setting Custom Setting
            Send_Article_Settings__c saset = Send_Article_Settings__c.getOrgDefaults();
            saset.Last_Scheduled_Run__c = DateTime.now();
            saset.Last_Run_Status__c = karesponse.status;
            if (numarticles >= batchSize)
                saset.Last_Run_Status__c += ', ' + String.valueof(recCounter) + ' of ' + String.valueof(batchSize);
            else
                saset.Last_Run_Status__c += ', ' + String.valueof(recCounter) + ' of ' + String.valueof(numarticles);
            
            
            if (karesponse.status == 'OK' && String.isBlank(karesponse.error)){
                //unpublish Online article to become Draft
                String ArticleEdit = '';
                Boolean isMastLang = (Boolean) art.get('IsMasterLanguage');
                if ((String)art.get('PublishStatus') == 'Online'){
                    if(isMastLang){
                        ArticleEdit = KbManagement.PublishingService.editOnlineArticle((Id) art.get('KnowledgeArticleId'), false);
                    }
                    else{
                        ArticleEdit = KbManagement.PublishingService.editPublishedTranslation((Id) art.get('KnowledgeArticleId'),lang,false);
                    }
                }
                else if ((String)art.get('PublishStatus') == 'Archived'){
                    ArticleEdit = KbManagement.PublishingService.editArchivedArticle((Id) art.get('KnowledgeArticleId'));
                }
                else if ((String)art.get('PublishStatus') == 'Draft'){
                    ArticleEdit = articleId;
                }
                
                String kavQuery = 'SELECT ';
                for (Schema.Sobjectfield field : fieldMap.values()){
                    kavQuery+= field.getDescribe().getName() + ',';
                }
                kavQuery = kavQuery.substring(0, kavQuery.length() - 1); //trim last comma
                system.debug('@@articleId:'+articleId);
                
                //Retrieve Draft Article
                kavQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \''+ lang + '\' AND PublishStatus = \'' + 'Draft' + '\' AND Id = : ArticleEdit limit 1';
                sObject upArt = database.query(kavQuery);
                upArt.put('Answers_URL__c', (String)karesponse.URL);
                upArt.put('Article_To_Be_Sent__c', 'false');
                update upArt;
                system.debug('@@upArt:'+upArt);
                
                Boolean upArtIsMastLang = (Boolean)upArt.get('IsMasterLanguage');
                //Republish Article
                if ((String)art.get('PublishStatus') == 'Online'){
                    if(upArtIsMastLang){
                        KbManagement.PublishingService.publishArticle((String)UpArt.get('KnowledgeArticleId'), false);
                    }else{
                        KbManagement.PublishingService.completeTranslation((String)UpArt.get('Id'));
                        //KbManagement.PublishingService.publishArticle((String)UpArt.get('KnowledgeArticleId'), false);
                    }
                }
                //Rearchived Article
                else if ((String)art.get('PublishStatus') == 'Archived'){
                    KbManagement.PublishingService.publishArticle((String)UpArt.get('KnowledgeArticleId'), false);
                    KbManagement.PublishingService.archiveOnlineArticle((String)UpArt.get('KnowledgeArticleId'), null);
                }
                saset.Number_of_Articles_Sent__c = recCounter;
                
                if (numarticles >= batchSize){
                    saset.Last_Run_Status__c += ' with ' +  String.valueof(numarticles - batchSize) + ' pending Article(s) on next run.';
                }
                
            } else if (String.isNotBlank(karesponse.status)) {  //2102931
                Logger.debugException('Matlab Answer Integration Exception. Article Title: ' + title + '. Article Id: ' +(Id) art.get('KnowledgeArticleId') + '. Response status: '+karesponse.status + '. Response error: ' + karesponse.error);
            }
            
            update saset;
            system.debug('@@saet-success:'+saset);
            Logger.pop();
        }
        catch(Exception e){
            //Update Send Article Setting Custom Setting
            Send_Article_Settings__c saset = Send_Article_Settings__c.getOrgDefaults();
            string str = e.getMessage();
            if (str.length() > 200) str = str.substring(0,200);
            saset.Last_Run_Status__c = 'Error occured:'+str+'-SendArticlesToMW['+e.getLineNumber()+']';
            saset.Last_Scheduled_Run__c = DateTime.now();
            saset.Number_of_Articles_Sent__c = 0;
            update saset;
            system.debug('@@saet-failed:'+saset);
            system.debug('@@error:'+e.getLineNumber()+e.getMessage());
            Logger.debugException('Matlab Answer Integration Exception. Article Title: ' + title + '. Article Id: ' +articleId + '. Detail: '+e.getLineNumber()+', '+e.getMessage());
            Logger.pop();
        }   
        
    }
    /*
    //Gets all article fields dynamically on every article type  
    public static string generateQuery(Schema.Sobjecttype articleTypeApiName, String pubstatus){
        Schema.SobjectType objectType = articleTypeAPIName;
        Schema.DescribeSObjectResult objdescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        String theQuery = 'SELECT ';
        
        for (Schema.Sobjectfield field : fieldMap.values()){
            theQuery+= field.getDescribe().getName() + ',';
        }
        theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
        theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'en_US\' AND PublishStatus = \'' + pubstatus + '\' AND LastModifieddate = TODAY and IsVisibleInCsp=TRUE ';
        if (pubstatus == 'Draft'){
            theQuery+= ' AND LastPublishedDate != null';    
        }
        
        system.debug('@@theQuery:'+theQuery);   
        return theQuery;
    }
  */

    /*
    *@ Author Modified: Krishna. Desc: Added boolean variable to get articles where the status is changed to 'internally validated' to unpublish an article.
    */
    //Gets all article fields dynamically on every article type
    public static string generateQueryWithFewColumns(Schema.Sobjecttype articleTypeApiName, String pubstatus, String artLang, Boolean isMastLang, Boolean IsVisibleInCsp){
        Schema.SobjectType objectType = articleTypeAPIName;
        Schema.DescribeSObjectResult objdescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        String theQuery;
        if(IsVisibleInCsp){
            theQuery = 'SELECT Id, KnowledgeArticleId, title, PublishStatus, Language, IsMasterLanguage, LastPublishedDate, LastModifiedDate, ArchivedDate, Article_To_Be_Sent__c, ArticleNumber';
            theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'' + artLang + '\' AND PublishStatus = \'' + pubstatus + '\' AND LastModifieddate = TODAY and ISMasterLanguage = ' + isMastLang + ' and IsVisibleInCsp=TRUE ';
        } else {
            // Get all articles which have validationStatus="Internally Validated". these artticles will be marked for unpublish; gID:1016077
            theQuery = 'SELECT Id, KnowledgeArticleId, title, PublishStatus, Language, IsMasterLanguage, LastPublishedDate, LastModifiedDate, ArchivedDate, Article_To_Be_Sent__c, ArticleNumber';
            //HW 1835704
            //theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'' + artLang + '\' AND PublishStatus = \'' + pubstatus + '\' AND LastModifieddate = TODAY and ISMasterLanguage = ' + isMastLang + ' and IsVisibleInCsp=FALSE and ValidationStatus = \'Internally Validated\' and Answers_URL__c != null';
            theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'' + artLang + '\' AND PublishStatus = \'' + pubstatus + '\' AND LastModifieddate = TODAY and ISMasterLanguage = ' + isMastLang + ' and IsVisibleInCsp=FALSE and (ValidationStatus = \'Internally Validated\' or ValidationStatus = \'Not Validated\') and Answers_URL__c != null';
        }
       
        if (pubstatus == 'Draft'){
            theQuery+= ' AND LastPublishedDate != null';    
        }
        
        system.debug('@@theQueryWithFewColumns:'+theQuery);   
        return theQuery;
    }
    
    //Gets all rich text fields on every article type
    public static list <String> ArticleRichTextFields(Schema.Sobjecttype articleTypeApiName){
        list <string> richtextfields = new list <string>();
        Schema.SobjectType objectType = articleTypeAPIName;
        Schema.DescribeSObjectResult objdescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        for (Schema.Sobjectfield field : fieldMap.values()){
            //Check all field's maximum length to determine which is a RichText field
            if (field.getDescribe().getLength() > 32000){
                richtextfields.add(field.getDescribe().getName());
            }
        }
        return richtextfields;
        
    }
        
    //Gets all knowledge article API names dynamically
    public static Set<Schema.Sobjecttype> createDescribeMap() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<Schema.SobjectType> articlesNames = new Set<Schema.Sobjecttype>();
        for (String key :  gd.keySet()) {
            Schema.SObjectType objectType = gd.get(key);
            if (key.endsWith('kav')){
               articlesNames.add(objectType.getDescribe().getSObjectType());
            }
        }
        return articlesNames;
    }

   /*
    *@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    *@date Original: 16 October 2013, Last Modified: 17 October 2013
    *@description: webservice method for getting richText images as Attachment
                   workaround for fixing the getContent issue on scheduled batch and @future calls
   */ 
   webservice static void getRichTextImages(list<string> rtimages, string parentID, integer ctr){
        System.Debug('In the web service');
        list <Attachment> attlist = new list <Attachment>();
        Integer imgctr = 1;
        for (String image : rtimages){
            Attachment attach = new Attachment();
            Blob body;
            body = new PageReference(image).getContent();
            attach.Body = body;
            attach.Name = 'inlineimage-[ArticleNo'+ctr+']-['+imgctr+'].jpg';
            attach.Description = image;
            attach.IsPrivate = false;
            attach.ParentId = parentID;
            attlist.add(attach);
            imgctr++;
        }
        insert attlist;
   }
}