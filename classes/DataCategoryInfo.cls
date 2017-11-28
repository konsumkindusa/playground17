/**
* @author Original: kishore AN - Cloudsherpas
* @date Original: 24 July,2013
* @description: This class holds the Data Category Info from the describe result
*/ 


public class DataCategoryInfo {
    private String name;
    private String label;
    private String categoryName;
    public DataCategoryInfo(String name, String label, String categoryName) {
    this.name = name;
    this.label = label;
    this.categoryName = categoryName;
    }
    public String getName() {
    return this.name;
    }
    public String getLabel() {
    return this.label;
    }
    public String getcategoryName() {
        return this.categoryName;
    }
}