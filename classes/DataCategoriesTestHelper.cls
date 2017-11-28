@istest
public class DataCategoriesTestHelper{

    public static testmethod void getAllDataCategoryNamesTest()
    {
        DataCatagoriesHelper dcc = new DataCatagoriesHelper();        
        DataCatagoriesHelper.getAllDataCategoryNames('Product');
    }
    
    public static testmethod void getAllDatacatagoriesNoGroupTest(){
        DataCatagoriesHelper.getAllDataCategoryNames('Product2');
    }
    
    public static testmethod void dataCategoryInfoClassTest(){
    
        DataCategoryInfo dcinfo = new DataCategoryInfo('MATLAB', 'MATLAB', 'Product');
        
        System.AssertEquals('MATLAB', dcinfo.getName());
        System.AssertEquals('MATLAB', dcinfo.getLabel());
        System.AssertEquals('Product', dcinfo.getCategoryName());
        
    }

    
}