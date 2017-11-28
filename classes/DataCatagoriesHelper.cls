/**
* @author Original: Kishore AN - Cloud Sherpas
* @date Original: 24 July, 2013
* @description: Class to get the category names for a given data category group
*/ 

public with sharing class DataCatagoriesHelper {
    
    public DataCatagoriesHelper(){
    }

    private static List<DescribeDataCategoryGroupResult> describeDataCategoryGroup(){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        try {
            //Creating the list of sobjects to use for the describe
            //call
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            
            //Describe Call
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);        
        } catch(Exception e){
            System.Debug('Exception in describeDataCategoryGroup:'+e.getMessage());
        }
        return describeCategoryResult;
        
    }
    
    public static List<DataCategoryInfo> getAllDataCategoryNames(String GroupName){
        List<DataCategory> allCategories = new List<DataCategory>();
        List<DataCategoryInfo> allCategoriesInfo = new List<DataCategoryInfo>();
                
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        List<DescribeDataCategoryGroupResult> describeCategoryResult = describeDataCategoryGroup();
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        try{    
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
            DataCategoryGroupSobjectTypePair p =
            new DataCategoryGroupSobjectTypePair();
            if(singleResult.getLabel().containsIgnoreCase(GroupName)){
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
            }
       }
       
       //describeDataCategoryGroupStructures()
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
        //Getting data from the result
        for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){        
            //Get the top level categories
            DataCategory [] toplevelCategories = singleResult.getTopCategories();
            String CategoryGroupName =  singleResult.getName();
            //DataCategory[] allChildCategories = getAllCategories(toplevelCategories);
            List<DataCategoryInfo> allChildCategoriesInfo = getAllCategories(toplevelCategories,CategoryGroupName);            
            allCategoriesInfo.addAll(allChildCategoriesInfo );          
            
        }
       
        System.debug('allcategories size:'+allCategories.size());
        
        }catch (Exception ex){
            System.debug('Exception in getAllDataCategoryNames: '+ ex.getMessage());
        }
        
        return allCategoriesInfo;
    }
    
    public static List<DataCategoryInfo> getAllCategories(DataCategory [] categories, String CategoryGroupName){
        try{
        if(categories.isEmpty()){
           System.Debug('getAllCategories::categories is empty'); 
        return new DataCategoryInfo[]{};
        } else {
            DataCategory[] allCategories = new DataCategory[]{};
            for(DataCategory category : categories){ 
            allCategories.addAll(category.getChildCategories());           
            
            }
            List<DataCategoryInfo> allChildCategoriesInfo = new List<DataCategoryInfo>();
            for(DataCategory category : allCategories){
                DataCategoryInfo categoryInfo = new DataCategoryInfo(category.getName(),category.getLabel(), CategoryGroupName);
                allChildCategoriesInfo.add(categoryInfo);
            } 
            System.Debug('size of categories:'+allChildCategoriesInfo.size());
            System.Debug('size of categories for CategoryGroupName:'+CategoryGroupName+'::::'+allChildCategoriesInfo.size());            
            return allChildCategoriesInfo;
        }
        }catch(Exception ex){
        System.Debug('Exception in getAllCategories:'+ex.getMessage());
        return new DataCategoryInfo[]{};
        }
    } 

}