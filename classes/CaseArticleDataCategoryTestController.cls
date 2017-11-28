/**
 **@author Original: , Last Modified: Faina Gorelik - Cloud Sherpas/Mathworks  
 **@date Original: , Last Modified: 13 August 2015
 **@added method testProductSupportPackage AtTask 913339 
 */

@isTest

private class CaseArticleDataCategoryTestController{

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    
//fg
    static TestMethod void testProductSupportPackage(){
    
    //re-create Bypass Trigger Custom Setting
    csb.buildBypassTriggerSettings();
    // create support package
    PRODUCT_SUPPRT__c newProdSupport = new PRODUCT_SUPPRT__c();
    newProdSupport.Name = 'Test Support Package';
    newProdSupport.Name__c = 'Test Support Package';
    newProdSupport.VER_FULL__c = '1';
    newProdSupport.GR_Release_Name__c= 'R2013b';
    newProdSupport.BASE_PRDCT__c = 'TS';
    newProdSupport.SUPPRT_SFTWR_ID__c= 5555;
    newProdSupport.SUPPRT_SFTWR_VER_ID__c = 5555;
    newProdSupport.CODE__C = 'TEST';
    
    insert newProdSupport;
    string newProductSupportId = newProdSupport.Id;
    
    //create a new case with the package and base code 
    Case cse = TestDataBuilder.buildTestCase('open');
    cse.Subject = 'Test Support Package';
    cse.description = 'Test Support Package';
    cse.Area__c = 'Natick - Customer Support';
    cse.Product_Base_Code__c ='TS';
    cse.SupportPackageName__c = newProductSupportId;
    
    insert cse;
    String caseId = cse.Id;
    
    ApexPages.currentPage().getParameters().put('sourceId', caseId);
    ApexPages.currentPage().getParameters().put('sfdc.override', '1');
    
    FAQ__KAV articleObj = new FAQ__KAV();        
    
    ApexPages.KnowledgeArticleVersionStandardController ctl = new ApexPages.KnowledgeArticleVersionStandardController(articleObj);
    CaseArticleDataCategoryController cadcc = new CaseArticleDataCategoryController(ctl);
    }
//fg end

    static TestMethod void testDataCategoryCustomerSupport(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        Case cse = TestDataBuilder.buildTestCase('open');
        
        cse.Subject = 'create article from case';
        cse.description = 'creating article from case';
        cse.Area__c = 'Natick - Customer Support';
        cse.Topic__c = 'Activation.';
        cse.platform__c = 'Windows x32';
        cse.OS__c = 'Windows 8';
        
        insert cse;
        String caseId = cse.Id;
        
        ApexPages.currentPage().getParameters().put('sourceId', caseId);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        
        FAQ__KAV articleObj = new FAQ__KAV();        
       
        ApexPages.KnowledgeArticleVersionStandardController ctl = new ApexPages.KnowledgeArticleVersionStandardController(articleObj);
        CaseArticleDataCategoryController cadcc = new CaseArticleDataCategoryController(ctl);
        
    }
    
    static TestMethod void testDataCategoryTechnicalSupport(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        Case cse = TestDataBuilder.buildTestCase('open');
        
        cse.Subject = 'create article from case';
        cse.description = 'creating article from case';
        cse.Area__c = 'Natick - Technical Support';
        cse.Topic__c = 'Activation.';
        cse.platform__c = 'Windows x64';
        cse.OS__c = 'Windows 8';
        cse.Category__c = 'Data Import and Export';
        
        insert cse;
        String caseId = cse.Id;
        
        ApexPages.currentPage().getParameters().put('sourceId', caseId);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        
        FAQ__KAV articleObj = new FAQ__KAV();        
       
        ApexPages.KnowledgeArticleVersionStandardController ctl = new ApexPages.KnowledgeArticleVersionStandardController(articleObj);
        CaseArticleDataCategoryController cadcc = new CaseArticleDataCategoryController(ctl);
        
    }
    
    static TestMethod void testDataCategoryInstall(){
        
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        Case cse = TestDataBuilder.buildTestCase('open');
        
        cse.Subject = 'create article from case';
        cse.description = 'creating article from case';
        cse.Area__c = 'Natick - Install';
        cse.Topic__c = 'Activation.';
        cse.platform__c = 'Windows x32';
        cse.OS__c = 'Windows 8';
        
        insert cse;
        String caseId = cse.Id;
        
        ApexPages.currentPage().getParameters().put('sourceId', caseId);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        
        FAQ__KAV articleObj = new FAQ__KAV();        
       
        ApexPages.KnowledgeArticleVersionStandardController ctl = new ApexPages.KnowledgeArticleVersionStandardController(articleObj);
        CaseArticleDataCategoryController cadcc = new CaseArticleDataCategoryController(ctl);
        
    }
    
}