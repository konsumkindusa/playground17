/**
* @author Original:kishore AN - Cloud Sherpas/Mathworks, Modified : Faina Gorelik - AtTask913339 
* @ Added SupportPackageName__c field to the select statement
* @date Original: 15 July 2013 , date Modified : 12 August 2015
* @description Class to set the data catgories for the article based on case field values, and Support Product Package field on Article
*/ 

public class CaseArticleDataCategoryController{
    
    
    public CaseArticleDataCategoryController(ApexPages.KnowledgeArticleVersionStandardController ctl) {
        SObject article = ctl.getRecord();   //this is the SObject for the new article.
        String sourceId = ctl.getSourceId(); //this returns the id of the case
       Case c = [select subject, description,Area__c, Topic__c, product_lookup__c, product_lookup__r.Name,category__c, platform__c, OS__c, release__c,SupportPackageName__r.Id,SupportPackageName__r.Name__C from Case where id=:sourceId];
              
        //FG 
        if(c.SupportPackageName__r.Name__C != null){
            
               article.put('Product_Package__c',c.SupportPackageName__r.Id); 
            }     
        //FG
               
        if(c.Area__c != null && c.Area__c.Contains('Customer Support')){
            if(c.Topic__c != null){
                String topicName = c.Topic__c;
                System.Debug('CS tpoic:'+topicName);
                CaseArticle_CS__c CSTopic = CaseArticle_CS__c.getValues(c.Topic__c);
                if(CSTopic != null)topicName = CSTopic.Article_datacategory_name__c; 
                
                System.Debug('CS topicName:'+topicName);     
                ctl.selectDataCategory('Topic',buildCategoryName(topicName));
            }     
        }
        else if(c.Area__c != null && c.Area__c.Contains('Install')){
            if(c.Topic__c != null){
                String topicName = c.Topic__c;
                System.Debug('Install tpoic:'+topicName);
                CaseArticle_Install__c InstallTopic = CaseArticle_Install__c.getValues(c.Topic__c);
                if(InstallTopic != null)topicName = InstallTopic.Article_datacategory_name__c; 
                
                System.Debug('Install topicName:'+topicName);      
                ctl.selectDataCategory('Topic',buildCategoryName(topicName));
            }
        } 
        if(c.Area__c != null && c.Area__c.Contains('Technical Support')){
            if(c.Category__c != null){
                String categoryName = c.Category__c;
                CaseArticle_TS__c TSTopic = CaseArticle_TS__c.getValues(c.Category__c);
                if(TSTopic != null)categoryName = TSTopic.Article_datacategory_name__c;        
                ctl.selectDataCategory('Topic',buildCategoryName(categoryName));
            } 
        }
        
        if(c.Product_Lookup__c != null){
            ctl.selectDataCategory('Product',buildCategoryName(c.Product_LookUp__r.Name));
            if(c.Release__c!= null){
               ctl.selectDataCategory('Verified_in_Release',buildCategoryName(c.release__c));
           }
        }
        
        
        
        if(c.Platform__c != null ){
        String platformOS = c.Platform__c;
        System.Debug('platform OS:'+platformOS); 
            if(c.OS__c != null){
                platformOS = c.OS__c;
                System.Debug('platform OS in OS:'+platformOS); 
                CaseArticle_PlatformOS__c POSName = CaseArticle_PlatformOS__c.getValues(c.OS__c);
                if(POSName!= null)platformOS = POSName.Article_datacategory_name__c;
                System.Debug('platform OS in OS after CS:'+platformOS);
                if(c.Platform__c.Contains('x32')){ 
                    platformOS+= ' x32';
                }
                else if( c.Platform__c.Contains('x64')){
                    platformOS+= ' x64';
                }            
            }
            
            ctl.selectDataCategory('Platform_OS',buildCategoryName(platformOS));
        }                   
    }
   
   /*
    * @author Original: kishore AN - Cloud Sherpas/Mathworks
    * @date Original: 15 July 2013
    * @description: method used to build a proper category name based on the label or picklist value
    */
   private String buildCategoryName(String caseCategoryName) {
      
      if (String.isBlank(caseCategoryName)) return null;
      caseCategoryName = caseCategoryName.replaceAll('&','');
      caseCategoryName = caseCategoryName.replaceAll('  ','_');
      caseCategoryName = caseCategoryName.replaceAll(' ','_');
      caseCategoryName = caseCategoryName.replaceAll('/','_');
      caseCategoryName = caseCategoryName.replaceAll('\\.','_');
      caseCategoryName = caseCategoryName.replaceAll('\\)','');
      caseCategoryName = caseCategoryName.replaceAll('\\(','');
      
      
      System.Debug('BuildCategoryName:'+caseCategoryName);
      return caseCategoryName;
  }
 }