/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 30 May 2013, Last Modified: 22 October 2013
* @description class to verify the functionality of Product Search
* @author modified: Marc Ouimet; Date: 9 May 2014; Method: testDisplayExistingProduct(); Desc: commented out lines 377,379,380 for G1018081
*/
@isTest
private class ProductSearchControllerTest {

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 30 May 2013, Last Modified: 22 October 2013
    * @description test method for testing Product Search functionality
    */
    static testMethod void testProductSearch() {
        
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
    
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test Products
        list <Product2> prod2list = new list <Product2>();
        for (Integer i=0; i<20; i++){
            Product2 prod2 = TestDataBuilder.buildTestProduct(i);
            prod2.ProductCode = 'TP'+i;
            prod2.Version__c = '1.'+i;
            prod2.Release__c = '200'+i;
            prod2list.add(prod2);
        }
        insert prod2list;
        
        //Run as MW standard User
        system.runAs(stdUser){
            
            //Prevent On Support trigger from running
            CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler(); 
			cseTrigHandler.stopTrigger();
            
            //create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Product_Base_Code__c = 'ML';
            cse.License__c = '491381';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Test.startTest();
            
                //Filter criteria combinations abcd: a=Name, b=ProductCode, c=Release, d=Version; X=with value O=no value
                //XXXX 
                ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'TProd';
                psc.prodPCode = 'TP';
                psc.prodRelease = '200';
                psc.prodVersion = '1.';
                psc.ProductSearch();
                
                //XXOX
                ProductSearchController psc2 = new ProductSearchController();
                psc2.prodName = 'TProd';
                psc2.prodPCode = 'TP';
                psc2.prodRelease = '';
                psc2.prodVersion = '1.';
                psc2.ProductSearch();
                
                //XXXO
                ProductSearchController psc3 = new ProductSearchController();
                psc3.prodName = 'TProd';
                psc3.prodPCode = 'TP';
                psc3.prodRelease = '200';
                psc3.prodVersion = '';
                psc3.ProductSearch();
                
                //XOXX
                ProductSearchController psc4 = new ProductSearchController();
                psc4.prodName = 'TProd';
                psc4.prodPCode = '';
                psc4.prodRelease = '200';
                psc4.prodVersion = '1.';
                psc4.ProductSearch();
                
                //XXOO
                ProductSearchController psc5 = new ProductSearchController();
                psc5.prodName = 'TProd';
                psc5.prodPCode = 'TP';
                psc5.prodRelease = '';
                psc5.prodVersion = '';
                psc5.ProductSearch();
                
                //XOXO
                ProductSearchController psc6 = new ProductSearchController();
                psc6.prodName = 'TProd';
                psc6.prodPCode = '';
                psc6.prodRelease = '200';
                psc6.prodVersion = '';
                psc6.ProductSearch();
                
                //XOOX
                ProductSearchController psc7 = new ProductSearchController();
                psc7.prodName = 'TProd';
                psc7.prodPCode = '';
                psc7.prodRelease = '';
                psc7.prodVersion = '1.';
                psc7.ProductSearch();
                
                //XOOO
                ProductSearchController psc8 = new ProductSearchController();
                psc8.prodName = 'TProd';
                psc8.prodPCode = '';
                psc8.prodRelease = '';
                psc8.prodVersion = '';
                psc8.ProductSearch();
                
                //OXXX
                ProductSearchController psc9 = new ProductSearchController();
                psc9.prodName = '';
                psc9.prodPCode = 'TP';
                psc9.prodRelease = '200';
                psc9.prodVersion = '1.';
                psc9.ProductSearch();
                
                //OXXO
                ProductSearchController psc10 = new ProductSearchController();
                psc10.prodName = '';
                psc10.prodPCode = 'TP';
                psc10.prodRelease = '200';
                psc10.prodVersion = '';
                psc10.ProductSearch();
                
                //OXOX
                ProductSearchController psc11 = new ProductSearchController();
                psc11.prodName = '';
                psc11.prodPCode = 'TP';
                psc11.prodRelease = '';
                psc11.prodVersion = '1.';
                psc11.ProductSearch();
                
                //OXOO
                ProductSearchController psc12 = new ProductSearchController();
                psc12.prodName = '';
                psc12.prodPCode = 'TP';
                psc12.prodRelease = '';
                psc12.prodVersion = '';
                psc12.ProductSearch();
                
                //OOXX
                ProductSearchController psc13 = new ProductSearchController();
                psc13.prodName = '';
                psc13.prodPCode = '';
                psc13.prodRelease = '200';
                psc13.prodVersion = '1.';
                psc13.ProductSearch();
                
                //OOXO
                ProductSearchController psc14 = new ProductSearchController();
                psc14.prodName = '';
                psc14.prodPCode = '';
                psc14.prodRelease = '200';
                psc14.prodVersion = '';
                psc14.ProductSearch();
                
                //OOOX
                ProductSearchController psc15 = new ProductSearchController();
                psc15.prodName = '';
                psc15.prodPCode = '';
                psc15.prodRelease = '';
                psc15.prodVersion = '1.';
                psc15.ProductSearch();
                
                //No Product results
                ProductSearchController psc16 = new ProductSearchController();
                psc16.prodName = 'jkflfj';
                psc16.prodPCode = '2093';
                psc16.prodRelease = '300';
                psc16.prodVersion = '1.';
                psc16.ProductSearch();
                
                //Get product list for #1
                psc.getProdWRlist();
                //Cover methods for Pagination
                psc.selectedpage = 1;
                psc.getProdPageSelect();
                psc.getProdmaxPageNumber();
                psc.prodprevious();
                psc.prodnext();
                psc.prodsetPageNumber();
                
            Test.stopTest();
            
            //Verify search returns Products (Maximum display count of products is 10)
            system.assertEquals(psc.prodWrList.size(),10);
            //Verify Navigation is shown when search returned Products
            system.assertEquals(psc.showNavi,'true');
            
        }
    }
    static testMethod void checkOnSupportResponseError(){
     //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupportProductSearch');
        multimockgetOnSupport.setStatusCode(404);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Matlab';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'ML';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test account
        	Account acc = TestDataBuilder.buildTestAccount(1, stdUser.Id);
        	acc.CDS_Account_Id__c = 'B0876123';
        	insert acc;
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Case UpCse = new Case();
            Case ValUpCse = new Case();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
	            //Test Successful Response
	            ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'Matlab';
            	psc.prodPCode = 'ML';
            	psc.prodRelease = '2010';
            	psc.prodVersion = '1.0';
            	psc.ProductSearch();
	            psc.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '491381';
	            }
	            psc.saveProduct();
	            
	            //Retrieve updated Case
                UpCse = [Select Id, On_Support__c,On_Support_Reason__c,Support_Status__c,License__c  From Case Where Id = : cse.Id];
                Test.stopTest();
                system.assertEquals(UpCse.On_Support_Reason__c,'License 491381 Not Found');
                system.assertEquals(UpCse.Support_Status__c ,'No');		
            }  
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 30 May 2013, Last Modified: 22 October 2013
    * @description test method for testing saving of selected Product to the Case
    */
    static testMethod void testSaveProduct() {
        
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
       	csb.buildBypassTriggerSettings();
        //re-create General Setting fg
        csb.buildGenSetting();
        General_Settings__c onSupportSetting = General_Settings__c.getInstance();
        string url = onSupportSetting.OnSupportURL__c;
        
       	StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupportProductSearch');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json');     
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test Products
        list <Product2> prod2list = new list <Product2>();
        for (Integer i=0; i<20; i++){
            Product2 prod2 = TestDataBuilder.buildTestProduct(i);
            prod2.ProductCode = 'TP'+i;
            prod2.Version__c = '1.'+i;
            prod2.Release__c = '200'+i;
            prod2list.add(prod2);
        }
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Matlab';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'ML';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        prod2list.add(MWprod);
        insert prod2list;
        
         //create account
         Account acc = TestDataBuilder.buildTestAccount(0, UserInfo.getUserId());
         acc.CDS_Account_Id__c = 'B0876123';
         insert acc;
  
        //Run as MW standard User
        system.runAs(stdUser){
           
            //create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Product_Base_Code__c = 'ML';
            cse.License__c = '491381';
            cse.Area__c = 'Natick - Technical Support';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
            insert cse;
            Test.stopTest();
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            ProductSearchController psc = new ProductSearchController();
            //Set filter criteria - will only return 1 record
            psc.prodName = 'Matlab';
            psc.prodPCode = 'ML';
            psc.prodRelease = '2010';
            psc.prodVersion = '1.0';
            psc.ProductSearch();
            
            Case UpCse = new Case();
            String SelprodId;
           
                //Select product from the displayed list of returned products
                for (ProductSearchController.ProductWrapper pw: psc.prodWrList){
                    pw.isSelected = true;
                    //get selected product's ID
                    SelprodId = pw.prod.Id; 
                }
                
                //Pick and save product to Case
                psc.saveProduct();
            
                //Retrieve updated Case
                UpCse = [Select Id, Product_Lookup__c, Product_Base_Code__c, Release__c, Version__c From Case Where Id = : cse.Id];
                //Verify search returns a Product (Expected count is 1 because only 1 record is found on the search)
                system.assertEquals(psc.ProdWrlist.size(),1);
                //Verify Case has been updated
                system.assertEquals(UpCse.Product_Base_Code__c,'ML');
                //system.assertEquals(UpCse.Product__c,'Matlab');
                system.assertEquals(UpCse.Release__c,'2010');
                system.assertEquals(UpCse.Version__c,'1.0');
            
        }
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 10 September 2013, Last Modified: 22 October 2013
    * @description test method for testing displaying of existing product on Product Search
    * @author modified: Marc Ouimet; Date: 9 May 2014; Method: testDisplayExistingProduct(); Desc: commented out lines 377,379,380 for G1018081
    */
    static testMethod void testDisplayExistingProduct() {
    	
    	//re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //create Mock responses for OnSupport integration fg commented to replace with REST API
       /* MW_OnSupportTestMock mock = new MW_OnSupportTestMock();
        mock.isMockSuccess = true;
        Test.setMock(WebServiceMock.class,mock);*/
        
        //create test User
       User stdUser = TestDataBuilder.buildTestUser(0); 
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Matlab';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'ML';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Product_Lookup__c = MWProd.Id;
            cse.Product_Base_Code__c = 'ML';
          //  cse.License__c = '491381';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Test.startTest();
            
	            ProductSearchController psc = new ProductSearchController();
	            
	            //Prevent On Support trigger from running
	            CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler(); 
				cseTrigHandler.stopTrigger();
			
			Test.stopTest();
			
			//Verify that existing Product's info is already displayed on the page
			system.assertEquals(psc.prodName,MWProd.Name);
		
			
        }
        
    }
    static testMethod void testCheckOnSupportAccountNotFound(){
        
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupportProductSearch');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Matlab';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'ML';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test account
        	Account acc = TestDataBuilder.buildTestAccount(1, stdUser.Id);
        	acc.CDS_Account_Id__c = 'B0776123';
        	insert acc;
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Case UpCse = new Case();
            Case ValUpCse = new Case();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
	            //Test Successful Response
	            ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'Matlab';
            	psc.prodPCode = 'ML';
            	psc.prodRelease = '2010';
            	psc.prodVersion = '1.0';
            	psc.ProductSearch();
	            psc.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '491381';
	            }
	            psc.saveProduct();
	            
	            //Retrieve updated Case
				UpCse = [Select Id, License__c, On_Support__c, License_Account_Lookup__c From Case Where Id = : cse.Id];
	            
	            //Test Validation
	            ProductSearchController psc2 = new ProductSearchController();
	            psc2.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '1234560984580580580345'; //exceeds character length
	            }
	            psc2.saveProduct();
	            
	            //Retrieve Case after save - will be the same as UpCse because of a validation
				ValUpCse = [Select Id, License__c, Support_Status__c, Support_Reason__c, License_Account_Lookup__c From Case Where Id = : cse.Id];

			Test.stopTest();
			//Verify that Account lookup didn't find account and return null
			system.assertEquals(UpCse.License_Account_Lookup__c,null);
        }
    }
    
    /**
    * @author Original: Faina Gorelik - Mathworks
    * @date Original: 16 July 2016
    * @description test method for testing Check On Support functionality for the success response license not eligible reason Not Active
    */
    static testMethod void testCheckOnSupportLicenseNotEligible(){
          //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseLicenseNotEligible');// 
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Model-Based Calibration Toolbox';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'MB';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test account
        	Account acc = TestDataBuilder.buildTestAccount(1, stdUser.Id);
        	acc.CDS_Account_Id__c = 'B0876123';
        	insert acc;
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Case UpCse = new Case();
            Case ValUpCse = new Case();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
	            //Test Successful Response
	            ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'Model-Based Calibration Toolbox';
            	psc.prodPCode = 'MB';
            	psc.prodRelease = '2010';
            	psc.prodVersion = '1.0';
            	psc.ProductSearch();
	            psc.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '491381';
	            }
	            psc.saveProduct();
	            
	            //Retrieve updated Case
                UpCse = [Select Id, On_Support__c,On_Support_Reason__c,Support_Status__c,License__c  From Case Where Id = : cse.Id];
                Test.stopTest();
                // verify Support status equals no when license eligible and product is not eligible
                system.assertEquals(UpCse.Support_Status__c ,'No');		
            }
           
    }
     /**
    * @author Original: Faina Gorelik - Mathworks
    * @date Original: 16 July 2016
    * @description test method for testing Check On Support functionality for the success response pirated license
    */
    static testMethod void testCheckOnSupportPirated(){
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseLicenseNotEligiblePirated');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Model-Based Calibration Toolbox';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'MB';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test account
        	Account acc = TestDataBuilder.buildTestAccount(1, stdUser.Id);
        	acc.CDS_Account_Id__c = 'B0876123';
        	insert acc;
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Case UpCse = new Case();
            Case ValUpCse = new Case();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
	            //Test Successful Response
	            ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'Model-Based Calibration Toolbox';
            	psc.prodPCode = 'MB';
            	psc.prodRelease = '2010';
            	psc.prodVersion = '1.0';
            	psc.ProductSearch();
	            psc.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '9087123';
	            }
	            psc.saveProduct();
	            
	            //Retrieve updated Case
                UpCse = [Select Id, On_Support__c,On_Support_Reason__c,Support_Status__c,License__c  From Case Where Id = : cse.Id];
                Test.stopTest();
                // verify Support status equals no when license eligible and product is not eligible
                system.assertEquals(UpCse.Support_Status__c ,'No');	
            	system.assertEquals(UpCse.On_Support_Reason__c, 'Pirated');
            }
    }
    /**
    * @author Original:  Faina Gorelik - Mathworks
    * @date Original:  16 July 2016
    * @description test method for testing Check On Support functionality for the success response license eligible product not eligible
    */ 
    static testMethod void testCheckOnSupportProductNotEligible(){
        //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseProductNotEligible');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Model-Based Calibration Toolbox';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'MB';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test account
        	Account acc = TestDataBuilder.buildTestAccount(1, stdUser.Id);
        	acc.CDS_Account_Id__c = 'B0876123';
        	insert acc;
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Case UpCse = new Case();
            Case ValUpCse = new Case();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
	            //Test Successful Response
	            ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'Model-Based Calibration Toolbox';
            	psc.prodPCode = 'MB';
            	psc.prodRelease = '2010';
            	psc.prodVersion = '1.0';
            	psc.ProductSearch();
	            psc.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '491381';
	            }
	            psc.saveProduct();
	            
	            //Retrieve updated Case
                UpCse = [Select Id, On_Support__c,On_Support_Reason__c,Support_Status__c,License__c  From Case Where Id = : cse.Id];
                Test.stopTest();
                // verify Support status equals no when license eligible and product is not eligible
                system.assertEquals(UpCse.Support_Status__c ,'No');		
            }   
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Modified: Faina Gorelik - Mathworks
    * @date Original: 12 September 2013, Last Modified: 22 October 2013, 16 July 2016
    * @description test method for testing Check On Support functionality for the success response
    */
    static testMethod void testCheckOnSupport() { 
    	
    	//re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();

        StaticResourceCalloutMock multimockgetOnSupport = new StaticResourceCalloutMock();
        multimockgetOnSupport.setStaticResource('MockResponseOnSupportProductSearch');
        multimockgetOnSupport.setStatusCode(200);
        multimockgetOnSupport.setHeader('Content-Type', 'application/json'); 
        
        //create test User
        User stdUser = TestDataBuilder.buildTestUser(0);
        stdUser.ProfileId = csb.getUtilMWCustomerServiceStdUserProfileId();
        insert stdUser;
        
        //create test product sample for mW
        Product2 MWprod = new Product2();
        MWprod.Name = 'Matlab';
        MWprod.Product_Unique_Identifier__c = 'UniqueIDML';
        MWprod.ProductCode = 'ML';
        MWprod.Release__c = '2010';
        MWprod.Version__c = '1.0';
        insert MWProd;
        
        //Run as MW standard User
        system.runAs(stdUser){
        	
        	//create test account
        	Account acc = TestDataBuilder.buildTestAccount(1, stdUser.Id);
        	acc.CDS_Account_Id__c = 'B0876123';
        	insert acc;
        	
        	//create test case
            Case cse = new Case();
            cse.status = 'Open';
            cse.Area__c = 'Natick - Technical Support';
            insert cse;
            
            //Set current page and extension class
            Pagereference pref = Page.ProductSearch;
            pref.getParameters().put('id', cse.Id);
            Test.setCurrentPage(pref);
            
            Case UpCse = new Case();
            Case ValUpCse = new Case();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockgetOnSupport);
	            //Test Successful Response
	            ProductSearchController psc = new ProductSearchController();
                psc.prodName = 'Matlab';
            	psc.prodPCode = 'ML';
            	psc.prodRelease = '2010';
            	psc.prodVersion = '1.0';
            	psc.ProductSearch();
	            psc.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '491381';
	            }
	            psc.saveProduct();
	            
	            //Retrieve updated Case
				UpCse = [Select Id, License__c, On_Support__c, License_Account_Lookup__c From Case Where Id = : cse.Id];
	            
	            //Test Validation
	            ProductSearchController psc2 = new ProductSearchController();
	            psc2.getProdWRlist();
	            for (ProductSearchController.ProductWrapper pwr : psc.ProdWRlist){
	            	pwr.isSelected = true;
	            	pwr.newLicNum = '1234560984580580580345'; //exceeds character length
	            }
	            psc2.saveProduct();
	            
	            //Retrieve Case after save - will be the same as UpCse because of a validation
				ValUpCse = [Select Id, License__c, Support_Status__c, Support_Reason__c, License_Account_Lookup__c From Case Where Id = : cse.Id];

			Test.stopTest();
			
			//Verify that Case License is updated
			system.assertEquals(UpCse.License__c, '491381');
			//Verify that Account lookup is updated with Test Account
			system.assertEquals(UpCse.License_Account_Lookup__c,acc.Id);
			//Verify that On Support field is updated
			system.assertEquals(UpCse.On_Support__c, 'Yes 2026-06-30'); // change based on REST API		
			//Verify that Case License is not updated
			system.assertEquals(ValUpCse.License__c, UpCse.License__c);
			
        }
        
    }
}