/*
*@author Original: Priyank Saxena - Mathworks
*@date Original: 17 September 2013, Last Modified: 17 September 2013
*@description:Class for sending Articles to MWAnswers for Data migration
*/ 
public class SendBulkArticlesToMWAnswers {
    
    
   //@future
    public static void sendArticles(List<String> articleIdList){
        
        //Custom Object holding information on Send Articles to Answers Integration data
        list <Integration_Settings__c> integrationSetting = new list <Integration_Settings__c>();
        integrationSetting = [Select Id, Name, Username__c, Password__c, Clientname__c, Endpoint__c, Timeout__c From Integration_Settings__c Where Name = 'Send Articles to MW Answers' limit 1];
        
        List<SObject> articles = new List<SObject>();
        List<SObject> temparticles = new List<SObject>();
        
        try{
            //Retrieves all Articles that will be sent to Mathworks
            
            
            
            list <SendArticlesWSDL.ArticleType> wsartlist = new list <SendArticlesWSDL.ArticleType>();
            
           
                
                list <Sobject> tempremArticles = new list <Sobject>();
                list <Id> articleIDs = new list <Id>();
                
                //Unpublish all Articles that will be updated
                Set <String> articleEditSet = new set <string>();
               
              
                    
                    Integer ctr=1;
                  
                           
                 List<FAQ__KAV> arList = [Select Id, KnowledgeArticleId from FAQ__KAV where language='ja' and publishstatus='online' and KnowledgeArticleId in :articleIdList ];

                           integer counter = 0 ;
                           integer i;
                           integer j= 49;//arList.size();
                           
                           system.debug('@@ArticleSize:'+arList.size());
                           
                           /* if(arList.size() > 3)
                            {
                            j = 3;
                            system.debug('@@ArticleSize:'+arList.size());
                            }
                            
                            else 
                            {
                            j = arList.size();
                            system.debug('@@ArticleSize:'+arList.size());
                            }*/
                            //while ( counter < j ) 
                            // {
                              system.debug('@@Counter1:'+counter);
                              for (i= counter;i<j;i++)
                                {
                                
                                    system.debug('@@Counter_i:'+i);
                                    SendBulkArticlesToMWAnswers.CreateKnowledgeArticle(String.valueof(arList[i].Id),integrationSetting[0].UserName__c,
                                                integrationSetting[0].password__c,integrationSetting[0].Endpoint__c,integrationSetting[0].timeout__c, counter,j);
                               
                               
                               

                            }
                             
                       
        }
        catch(exception e){            
            system.debug('@@error:'+e.getLineNumber()+e.getMessage());
        }
        
    }
    
    /*
    *@author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    *@date Original: 02 July 2013, Last Modified: 12 September 2013
    *@description: Web service method for sending articles to Mathworks
    */ 
     
    public static void CreateKnowledgeArticle(Id articleId, string integuser, string integpass, string integendpoint, decimal integtimeout, integer RecCounter, integer numarticles){
        
            SendArticlesWSDL.KARequestType karequest = new SendArticlesWSDL.KARequestType();        
            SendArticlesWSDL.KAResponseType karesponse = new SendArticlesWSDL.KAResponseType();
            SendArticlesWSDL.ArticleType wsarticle = new SendArticlesWSDL.ArticleType();
            SupportAnswersBulk.SupportAnswer wsarticlebulk = new SupportAnswersBulk.SupportAnswer();
            
            map <string,string> DataCatMap = new map <string,string>();
            map <string, SupportAnswersBulk.Attachments> richtextIMGMap = new map <string, SupportAnswersBulk.Attachments>();
            map <string,SendArticlesWSDL.DatacategoryType> ArtDCMap = new map <string,SendArticlesWSDL.DatacategoryType>();
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
            theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'ja\' AND PublishStatus = \'' + 'Online' + '\' AND Id = : articleId limit 1';
            Sobject art = Database.query(theQuery);
            //Get rich text fields
            list <string> richtextfieldlist = ArticleRichTextFields(objectType);
            //Get available Data Category on current Article Type
            String ArticleTypePrefix = String.valueof(articleTypeApiName).substring(0, String.valueof(articleTypeApiName).indexOf('__kav')) + '__';
            DataCatMap.put(ArticleTypePrefix+'kav',ArticleTypePrefix+'DataCategorySelection');
            
            map<string,string> wsartMap = new map <string,string>();
            
            system.debug('@@Article to be sent:'+String.valueof(art.get('ArticleNumber'))+'::::'+articleId);
                    
            //Identify each Article Type and its DataCategorySelection s
            //Populate fields of the Article that will be sent to Mathworks
            wsarticle = new SendArticlesWSDL.ArticleType();
            wsarticle.ArticleID = String.valueof(art.get('KnowledgeArticleId'));
            wsarticle.ArticleNumber = String.valueof(art.get('ArticleNumber'));
            wsarticle.Title = String.valueof(art.get('Title'));
            wsarticle.Answer = String.valueof(art.get('Answer__c'));
            wsarticle.siebel_solution_id  = String.valueof(art.get('Siebel_Solution_ID__c'));
            wsarticle.Question = String.valueof(art.get('Question_RT__c'));
            wsarticle.Tags = String.valueof(art.get('Tags__c'));
            wsarticle.ValidationStatus = String.valueof(art.get('ValidationStatus'));
            wsarticle.PublishStatus = String.valueof(art.get('PublishStatus'));
            wsarticle.AnswersURL = String.valueof(art.get('Answers_URL__c'));
            wsarticle.RelatedArticles = String.valueof(art.get('Related_Articles__c'));
            wsarticle.language = String.valueof(art.get('language'));
            wsarticle.CreatedDate = Date.valueof(art.get('CreatedDate'));
            string createdById = String.valueof(art.get('CreatedById'));
            string LastPublished  =   String.valueof(art.get('LastPublishedDate'));
            User createdByuser = [Select Name From User Where Id =: createdById];
            wsarticle.CreatedBy = (String) createdByUser.Name; 
                
            //Get 5 attachments on the article
           SupportAnswersBulk.Attachments atsAttach = new SupportAnswersBulk.Attachments();
           list <SupportAnswersBulk.Attachment> wsattachList = new list <SupportAnswersBulk.Attachment>();
           if((art.get('attachments__body__s')) != null)
                {
                  SupportAnswersBulk.Attachment wsimgattach1 = new SupportAnswersBulk.Attachment();
                  wsimgattach1.url  = String.valueof(art.get('attachments__name__s'));
                  
                  wsimgattach1.data = Encodingutil.base64Encode((Blob)art.get('attachments__body__s'));
                   system.debug('@@wsimg.AttachmentURL bulkattach1:'+wsimgattach1.url); 
                  system.debug('@@wsimg.AttachmentBinaryin bulkattach1:'+wsimgattach1.data);
                  
                  wsattachList.add(wsimgattach1);
                }
                 
            if((art.get('Attachment_2__body__s')) != null)
                {
                  SupportAnswersBulk.Attachment wsimgattach2 = new SupportAnswersBulk.Attachment();
                  wsimgattach2.url  = String.valueof(art.get('Attachment_2__Name__s'));
                  wsimgattach2.data = Encodingutil.base64Encode((Blob)art.get('attachment_2__body__s'));
                  
                   system.debug('@@wsimg.AttachmentURL bulkattach2:'+wsimgattach2.url); 
                  system.debug('@@wsimg.AttachmentBinaryin bulkattach2:'+wsimgattach2.data);
                  
                  wsattachList.add(wsimgattach2);
                }      
                 
             if((art.get('Attachment_3__Body__s')) != null)
                {
                  SupportAnswersBulk.Attachment wsimgattach3 = new SupportAnswersBulk.Attachment();
                  wsimgattach3.url  = String.valueof(art.get('Attachment_3__Name__s'));
                  wsimgattach3.data = Encodingutil.base64Encode((Blob)art.get('attachment_3__body__s'));
                  
                   system.debug('@@wsimg.AttachmentURL bulkattach3:'+wsimgattach3.url); 
                  system.debug('@@wsimg.AttachmentBinaryin bulkattach3:'+wsimgattach3.data);
                  
                  wsattachList.add(wsimgattach3);
                }      
            if((art.get('Attachment_4__Body__s')) != null)
                {
                  SupportAnswersBulk.Attachment wsimgattach4 = new SupportAnswersBulk.Attachment();
                  wsimgattach4.url  = String.valueof(art.get('Attachment_4__Name__s'));
                  wsimgattach4.data = Encodingutil.base64Encode((Blob)art.get('attachment_4__body__s'));
                 
                   system.debug('@@wsimg.AttachmentURL bulkattach2:'+wsimgattach4.url); 
                  system.debug('@@wsimg.AttachmentBinaryin bulkattach2:'+wsimgattach4.data);
                  
                  wsattachList.add(wsimgattach4);
                }   
           
           if((art.get('Attachment_5__body__s')) != null)
                {
                  SupportAnswersBulk.Attachment wsimgattach5 = new SupportAnswersBulk.Attachment();
                  wsimgattach5.url  = String.valueof(art.get('Attachment_5__Name__s'));
                  wsimgattach5.data = Encodingutil.base64Encode((Blob)art.get('attachment_5__body__s'));
                  
                   system.debug('@@wsimg.AttachmentURL bulkattach5:'+wsimgattach5.url); 
                  system.debug('@@wsimg.AttachmentBinaryin bulkattach5:'+wsimgattach5.data);
                  
                  wsattachList.add(wsimgattach5);
                } 
           atsAttach.Attachment = wsattachList;
           
            //Get attachments - images on every richtext fields on every Article
            list <SupportAnswersBulk.Attachment> wsimglist = new list <SupportAnswersBulk.Attachment>();
           SupportAnswersBulk.Attachments ats = new SupportAnswersBulk.Attachments();
           
            String articletype = String.valueof(art.get('ArticleType'));
           
            if( richtextfieldlist.size() > 0 ){
                for (String rtfield : richtextfieldlist){
                    system.debug('@@current rich text field:'+rtfield+String.valueof(art.get(rtfield)));
                    String rtfieldvalue = String.valueof(art.get(rtfield));
                    if  (rtfieldvalue != null){
                        String imgaddress = '';
                        integer matchCount = rtfieldvalue.countMatches('<img');
                        for (integer i=0; i < matchCount; i++){
                            SupportAnswersBulk.Attachment wsimg = new SupportAnswersBulk.Attachment();
                            integer firstIndex = rtfieldvalue.indexOf('<img');
                            integer secondIndex = rtfieldvalue.indexOf('</img>')+6;
                            String imgTag = rtfieldvalue.substring(firstIndex,secondIndex);
                            imgaddress = imgTag.substringAfter('src="').substringBefore('"').replace('amp;','');
                            rtfieldvalue = rtfieldvalue.replace(imgTag,''); //remove retrieved image to get next image
                            system.debug('@@imgaddress:'+imgaddress);
                            //Populate image attributes
                            wsimg.url = imgaddress;
                            //wsimg.Data = Encodingutil.base64Encode(Blob.valueof(imgaddress));
                            
                            if (!Test.isRunningTest()){
                              wsimg.Data = Encodingutil.base64Encode(new PageReference(imgaddress).getContent());
                            }
                            else{
                              wsimg.Data = Encodingutil.base64Encode(Blob.valueof('UNIT.Test'));
                            }
                            
                            //wsimg.Data = Encodingutil.base64Encode(new PageReference(imgaddress).getContent());
                            system.debug('@@wsimg.AttachmentBinary:'+wsimg.data);
                            wsimglist.add(wsimg);
                        }
                        //Include Attachments to Article that will be sent
                        
                        ats.Attachment = wsimglist;
                        //system.debug('@@wsimglist.count:'+wsimglist.size());
                        system.debug('@@wsimg.AttachmentBinaryin bulkanswer:'+ats.Attachment);
                        if (wsimglist.size() > 0){
                            richtextIMGMap.put(String.valueof(art.get('Id')), ats);
                        }
                    }
                }
            }
                
            //Identify Data Categories on every Article Type
            if (art.get('ArticleType') != null){
                if (DataCatMap.containskey( String.valueof(art.get('ArticleType') ) ) ){
                    DataCatMap.put(ArticleTypePrefix+'kav',ArticleTypePrefix+'DataCategorySelection');
                }
                datacatIdSet.add(String.valueof(art.get('Id')));
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
            list <String> platformOSTypes = new list <string>();
            list <String> topicTypes = new list <string>();
            list <String> productTypes = new list <string>();
            list <String> releaseTypes = new list <String>();
          
          SendArticlesWSDL.DatacategoryType wsdct = new SendArticlesWSDL.DatacategoryType();
            //Populate datacategorytype attributes
            for (Sobject artDC : dataCatArticles){
                string dataCatGroupName = String.valueof(artDC.get('DataCategoryGroupName'));
                String parentID = String.valueof(artDC.get('ParentId'));
               
                
                if (dataCatGroupName == 'Product'){
                    productTypes.add(String.valueof(artDC.get('DataCategoryName')));
                }
                else if (dataCatGroupName == 'Topic'){
                    topicTypes.add(String.valueof(artDC.get('DataCategoryName')));
                }
                else if (dataCatGroupName == 'Platform_OS'){
                    platformOSTypes.add(String.valueof(artDC.get('DataCategoryName')));
                }
                else if (dataCatGroupName == 'Verified_in_Release'){
                    releaseTypes.add(String.valueof(artDC.get('DataCategoryName')));
                }
                
                SendArticlesWSDL.TopicType wstt = new SendArticlesWSDL.TopicType();
                SendArticlesWSDL.ProductType wspt = new SendArticlesWSDL.ProductType();
                SendArticlesWSDL.PlatformType wspft = new SendArticlesWSDL.PlatformType();
                SendArticlesWSDL.ReleaseType wsrt = new SendArticlesWSDL.ReleaseType();
                
                if (productTypes.size() > 0 ){
                    wspt.Product = productTypes;
                    wsdct.Products = wspt;
                }
                if (topicTypes.size() > 0){
                    wstt.Topic = topicTypes;
                    wsdct.Topics = wstt;
                }
                if (platformOSTypes.size() > 0){
                    wspft.Platform = platformOSTypes;
                    wsdct.Platforms = wspft;
                }
                if (releaseTypes.size() > 0){
                    wsrt.Release = releaseTypes;
                    wsdct.VerifiedInReleases = wsrt;
                }
                
                
             /*   //add new data categories on non-existing ParentID in map
              //  if (!ArtDCMap.containskey(parentId)){
                //    wsdct = new SendArticlesWSDL.DatacategoryType();
                }
                //add new data categories on existing ParentID in map
                else{
                    wsdct = ArtDCMap.get(parentID);
                }*/
                
                
            }
                ArtDCMap.put(wsarticle.ArticleId,wsdct);
                            
            //Include DataCategories and Attachments to Article that will be sent
            /*if (wsartMap.containskey(wsarticle.ArticleId)){
                //Add dataCategories attributes to related Article
                if (ArtDCMap.containskey(wsArtMap.get(wsarticle.ArticleID))){
                   
                }
                //Add attachments attributes to related Article
               // if (richtextIMGMap.containskey(wsArtMap.get(wsarticle.ArticleID))){
                 //   wsarticle.Attachments = richtextIMGMap.get(wsArtMap.get(wsarticle.ArticleID));
               // }
            }*/
            
             wsarticle.Datacategories = ArtDCMap.get(wsArtMap.get(wsarticle.ArticleID));
             wsarticlebulk.Attachments = richtextIMGMap.get(wsArtMap.get(wsarticle.ArticleID));
                 system.debug('@@Attachment getarticle id'+wsarticle.ArticleID);
                 system.debug('@@Attachment getARTMAP'+wsArtMap.get(wsarticle.ArticleID));
                system.debug('@@Attachment getlhs'+wsarticlebulk.Attachments);
                system.debug('@@Attachment getRhs'+richtextIMGMap.get(wsArtMap.get(wsarticle.ArticleID)));
       //Prepare XML file using XMLwriter 
            
         XmlStreamWriter writer = new XmlStreamWriter();
         writer.writeStartDocument('utf-8', '1.0');        
         writer.writeStartElement(null, 'response', null);

           writer.writeStartElement(null, 'support_answer', null);
              
               writer.writeStartElement(null,'article_id',null);
                writer.writeCharacters(wsarticle.ArticleID);
               writer.writeEndElement();
               writer.writeStartElement(null,'tags',null);
               if(wsarticle.Tags != null )
               writer.writeCharacters(wsarticle.Tags);
               writer.writeEndElement();
               
               writer.writeStartElement(null,'related_questions',null);
                if(wsarticle.RelatedArticles != null )
                writer.writeCharacters(wsarticle.RelatedArticles);
               writer.writeEndElement();
               
               writer.writeStartElement(null,'article_number',null);
               writer.writeCharacters(wsarticle.ArticleNumber);
               writer.writeEndElement();
               writer.writeStartElement(null,'language',null);
               writer.writeCharacters(wsarticle.language);
               writer.writeEndElement();
               writer.writeStartElement(null,'siebel_solution_id',null);
               if(wsarticle.siebel_solution_id != null )
               writer.writeCharacters(wsarticle.siebel_solution_id);
               writer.writeEndElement();
              
               
              writer.writeStartElement(null, 'question', null);
                 
                 writer.writeStartElement(null,'question',null);
                 if(wsarticle.Title != null )
                  writer.writeCharacters(wsarticle.Title);
                 writer.writeEndElement();
               
                writer.writeStartElement(null,'body_html',null);
                  if(wsarticle.Question != null )
                  writer.writeCharacters(wsarticle.Question);
                writer.writeEndElement();
                writer.writeStartElement(null,'published_at',null);
                  if(LastPublished != null )
                  writer.writeCharacters(LastPublished);
                 // writer.writeAttribute(null, null,published_at, LastPublished);
                 // writer.writeAttribute(LastPublished);
                writer.writeEndElement();
            
              writer.writeEndElement();
               
               writer.writeStartElement(null, 'answer', null);
                 writer.writeStartElement(null,'body_html',null);
                  if(wsarticle.Answer != null )
                  writer.writeCharacters(wsarticle.Answer);
                 writer.writeEndElement();
                 writer.writeStartElement(null,'published_at',null);
                  if(LastPublished != null )
                  writer.writeCharacters(LastPublished);
                writer.writeEndElement();

              writer.writeEndElement();
              
             
              
              writer.writeStartElement(null, 'categories', null);
                for (String eachCategories: topicTypes)
                  {
                    if(eachCategories != null )
                    {
                    writer.writeStartElement(null, 'category', null);
                     writer.writeCharacters(eachCategories);
                    writer.writeEndElement();
                    
                    }
                  }
              writer.writeEndElement(); 
                  
              writer.writeStartElement(null, 'products', null);
              
                  for (String eachProduct: productTypes)
                  {
                   if(eachProduct != null )
                   {
                    writer.writeStartElement(null, 'product', null);
                     writer.writeCharacters(eachProduct);
                    writer.writeEndElement();
                    
                   } 
                  }  
               writer.writeEndElement();
               
               writer.writeStartElement(null, 'releases', null);
                 for (String eachRelease: releaseTypes)
                  {
                    if(eachRelease != null )
                    { 
                     writer.writeStartElement(null, 'release', null);
                     writer.writeCharacters(eachRelease);
                     writer.writeEndElement();
                   
                    }
                  }  
               writer.writeEndElement(); 
               
               writer.writeStartElement(null, 'platforms', null);     
                for (String eachPlatformOS: platformOSTypes)
                  {
                    if(eachPlatformOS != null )
                    { 
                     writer.writeStartElement(null, 'os', null);
                     writer.writeCharacters(eachPlatformOS);
                     writer.writeEndElement();
                    
                    }
                  }  
               writer.writeEndElement(); 
  
                   
              writer.writeStartElement(null, 'attachments', null);
              
              ///image attachments 
              if(ats.Attachment != null )
              {
              for (SupportAnswersBulk.Attachment eachAttachmentimg: ats.Attachment)
                 {
                    writer.writeStartElement(null, 'attachment', null);
                    writer.writeStartElement(null, 'url', null);
                    writer.writeCharacters(eachAttachmentimg.url);
                     writer.writeEndElement();
                    
                  
                    writer.writeStartElement(null, 'data', null);
                    writer.writeCharacters(eachAttachmentimg.data);
                     writer.writeEndElement();
                      writer.writeEndElement();
                  
                  
                    
                 }
              }
              
              //Document attachments 
              if(atsAttach.Attachment != null )
              {
              for (SupportAnswersBulk.Attachment eachAttachment: atsAttach.Attachment)
                 {
                    writer.writeStartElement(null, 'attachment', null);
                    writer.writeStartElement(null, 'url', null);
                    writer.writeCharacters(eachAttachment.url);
                     writer.writeEndElement();
                     
                    //writer.writeAttribute(null, null, 'url', eachAttachment.url);
                    writer.writeStartElement(null, 'data', null);
                    writer.writeCharacters(eachAttachment.data);
                     writer.writeEndElement();
                      writer.writeEndElement();
                  
                   // writer.writeAttribute(null, null, 'data', eachAttachment.data);
                 }
              }
            writer.writeEndElement();  
                
          
                   
                   

          writer.writeEndElement();  
          writer.writeEndElement();
          
            writer.writeEndDocument();
            //End of XML writer
            
             system.debug('@@xmlstring:'+ writer.getXmlString());
            
           ArticleBulkData__c newArticleBulkData = new ArticleBulkData__c();
        newArticleBulkData.Name = wsarticle.ArticleID;
        newArticleBulkData.Article_Id__c = wsarticle.ArticleNumber;
        
        insert newArticleBulkData;
            
            
        Attachment attach = new Attachment();
        attach.Name = newArticleBulkData.Id+'-'+wsarticle.ArticleNumber+'.xml';
        attach.Body = Blob.valueOf(writer.getXmlString());
        attach.ContentType= 'text/xml';
        attach.ParentID = newArticleBulkData.Id;
        insert attach;

            
         /*   //Establish connection details with Articles to Answers service
            SendArticlesWSDL.KASrv wscall = new SendArticlesWSDL.KASrv();
            Blob headerValue = Blob.valueOf(integuser + ':' + integpass);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            wscall.inputHttpHeaders_x=new Map<String,String>();
            wscall.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            wscall.timeout_x = Integer.valueof(integtimeout);
            wscall.endpoint_x = integendpoint;
            karequest.Article = wsarticle;
            //execute WebService callout for sending Article to Mathworks
            karesponse = wscall.createKA(wsarticle);
            system.debug('@@wsarticles:'+wsarticle);
            system.debug('@@karesponse.Result:'+karesponse.result);
            system.debug('@@karesponse:'+karesponse);
            
            //Update Send Article Setting Custom Setting
            Send_Article_Settings__c saset = Send_Article_Settings__c.getInstance();
            saset.Last_Scheduled_Run__c = DateTime.now();
            saset.Last_Run_Status__c = karesponse.Result;
            
            if (karesponse.Result == 'SUCCESS'){
                //unpublish Online article to become Draft
                String ArticleEdit = KbManagement.PublishingService.editOnlineArticle((Id) art.get('KnowledgeArticleId'), true);
                
                String kavQuery = 'SELECT ';
                for (Schema.Sobjectfield field : fieldMap.values()){
                    kavQuery+= field.getDescribe().getName() + ',';
                }
                kavQuery = kavQuery.substring(0, kavQuery.length() - 1); //trim last comma
                system.debug('@@articleId:'+articleId);
                
                //Retrieve Draft Article
                
                sObject upArt = database.query(kavQuery);
                upArt.put('Answers_URL__c', (String)karesponse.URL);
                upArt.put('Article_To_Be_Sent__c', 'false');
                update upArt;
                system.debug('@@upArt:'+upArt);
                
                //Republish Article
                KbManagement.PublishingService.publishArticle((String)UpArt.get('KnowledgeArticleId'), true);
                saset.Number_of_Articles_Sent__c = recCounter;
                
                if (numarticles >= 11){
                    saset.Last_Run_Status__c += ' with ' +  String.valueof(numarticles - 10) + ' pending Article(s) on next run.';
                }
                
            }
            
            update saset;
            system.debug('@@saet-success:'+saset); */
            
        
    }
    
    //Gets all article fields dynamically on every article type  
    /* 
    public static string generateQuery(Schema.Sobjecttype articleTypeApiName, String pubstatus){
        Schema.SobjectType objectType = articleTypeAPIName;
        Schema.DescribeSObjectResult objdescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        String theQuery = 'SELECT ';
        
        for (Schema.Sobjectfield field : fieldMap.values()){
            theQuery+= field.getDescribe().getName() + ',';
        }
        theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
       
        
        system.debug('@@theQuery:'+theQuery);   
        return theQuery;
    }
    */
    
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
    
    
    /*    
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
    
    */
    
}