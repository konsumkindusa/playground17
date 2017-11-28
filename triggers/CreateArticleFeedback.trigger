/**
*author Original: Eric Schoenfeld - Cloud Sherpas/Mathworks, Last Modified: Eric Schoenfeld - Cloud Sherpas/Mathworks
*date Original: 9 July 2013, Last Modified: 24 April 2015
*description This trigger is used to handle different trigger actions for Feeditem 
*@Revision: updated code to handle a null value in the feed item body, could not write a null test as feeditem.body is required by the API
*/
trigger CreateArticleFeedback on FeedItem (after insert) {

    //Get defaults from Bypass Triggers Custom Setting for  enabling/disabling the trigger
    Bypass_Triggers__c bypass = Bypass_Triggers__c.getOrgDefaults();
    
    if (bypass.Trigger_Objects__c.contains('FeedItem') && !bypass.Triggers_Disabled__c){
        
        for (FeedItem f : trigger.new) {
        String parentId = f.parentId;
        String Id = f.Id;
            String fdBody = NULL;
            
            if (f.body != NULL){
                fdBody = String.valueof(f.Body).toLowerCase();
            }
            if (parentID.startsWith('kA') && f.type == 'TextPost' && fdBody.contains('#feedback') ) {
            
                list <sobject> kav = new list <sobject>();
                list<Sobject> dataCatArticles = new list <Sobject>();
                map <string,string> DataCatMap = new map <string,string>();
                
                //Retrieve Knowledge Articles
                for(Schema.Sobjecttype articleTypeApiName :createDescribeMap()){
                    kav.addAll(Database.query(generateQuery(articleTypeApiName, 'Online', parentId)));
                    if (kav.isEmpty()){
                        kav.addAll(Database.query(generateQuery(articleTypeApiName, 'Draft', parentId)));   
                    }
                    //Get available Data Category on current Article Type
                    String ArticleTypePrefix = String.valueof(articleTypeApiName).substring(0, String.valueof(articleTypeApiName).indexOf('__kav')) + '__';
                    DataCatMap.put(ArticleTypePrefix+'kav',ArticleTypePrefix+'DataCategorySelection');
                }
                
                String kavId = (String)kav[0].get('Id');
                
                //Retrieve all Data Categories on all Knowledge Article Types
                for (String atype : DataCatMap.keySet()){
                    String datquery = 'Select Id, ParentId, DataCategoryGroupName, DataCategoryName, CreatedDate, CreatedById, IsDeleted, SystemModstamp FROM ' + DataCatMap.get(atype) + ' Where ParentId =: kavId';
                    dataCatArticles.addAll(database.query(datquery));
                }
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
                //SS 4/24/15 Added Feed_Id__c field for story: 840580
                Article_Feedback__C afd = new Article_Feedback__C (
                    Feed_Id__c = Id,
                    Article_ID__C = parentId,
                    Article_Number__C = (String)kav[0].get('articleNumber'),
                    Article_Author__C = (Id)kav[0].get('CreatedById'),
                    Article_Title__C = (String)kav[0].get('title'),
                    Article_Version__C = (Integer)kav[0].get('VersionNumber'),
                    Article_Link__C = 'https://'+URL.getSalesforceBaseUrl().getHost() + '/' + (Id)kav[0].get('KnowledgeArticleId') + '?popup=true',
                    Comments__C = f.Body
                );
                
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
            }
        }
    
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
    
    //Gets all article fields dynamically on every article type  
    public static string generateQuery(Schema.Sobjecttype articleTypeApiName, String pubstatus, String parentId){
        Schema.SobjectType objectType = articleTypeAPIName;
        Schema.DescribeSObjectResult objdescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        String theQuery = 'SELECT ';
        
        for (Schema.Sobjectfield field : fieldMap.values()){
            theQuery+= field.getDescribe().getName() + ',';
        }
        theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
        theQuery+= ' FROM ' + articleTypeApiName + ' WHERE Language = \'en_US\' AND PublishStatus = \'' + pubstatus + '\' AND KnowledgeArticleId = \'' + parentId +'\' limit 1';
        
        system.debug('@@theQuery:'+theQuery);   
        return theQuery;
    }
    
}