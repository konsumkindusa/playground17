/** Original 
*@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Faina Gorelikk - MathWorks
*@date Original:   09 feb 2016, Last Modified: 28 July 2016
*@description:     this is a test class for PublishTMRulesViewPageController class.
*/
@isTest

public with sharing class PublishTMRulesViewPageControllerTest  {
    /***
@ name    publishTMRulesTest
@ date    09 feb 2016, Last Modified 28 July 2016
@ author  Sagar Talele, Faina Gorelik
@ param   none.
@ return  Void. 
@ description :Expected that it  will update or insert record into new customobject 
***/
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    
    static testMethod void RefreshCompleteTMRulesTest(){
        /* 
* call Refresh method on click Refresh button. Enable Publish button if record pending rule status = Complete
*/
        csb.buildTerritoryManagementSettings();
        
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;  
        System.runAs(usr){
            
            Territory_Publish_Rule__c tp = new Territory_Publish_Rule__c();
            
            tp.Pending_Rule_Publish__c ='COMPLETE';
            tp.Rule_Identifier__c = 'PRTOCDS';
            tp.Rules_Last_Published_By__c = UserInfo.getUserId();
            tp.Rules_Last_Published_On__c = DateTime.now();
            insert tp;   
            PageReference tmPage= Page.PublishTMRulesViewPage;
            Test.setCurrentPage(tmPage);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(tp);
            PublishTMRulesViewPageController controller = new PublishTMRulesViewPageController(standardCtrlCon);
            Test.startTest();
            controller.refresh();
            Test.stopTest();
            System.assertEquals(controller.isDisabled, false); 
            
        }
        
        
    }
    
    static testMethod void RefreshInProgressTMRulesTest(){
        /*
* call Refresh method on click Refresh button. Enable Publish button if record pending rule status <> Complete
*/
        csb.buildTerritoryManagementSettings();
        
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;  
        System.runAs(usr){
            
            Territory_Publish_Rule__c tp = new Territory_Publish_Rule__c();
            
            tp.Pending_Rule_Publish__c ='IN PROGRESS';
            tp.Rule_Identifier__c = 'PRTOCDS';
            tp.Rules_Last_Published_By__c = UserInfo.getUserId();
            tp.Rules_Last_Published_On__c = DateTime.now();
            insert tp;   
            PageReference tmPage= Page.PublishTMRulesViewPage;
            Test.setCurrentPage(tmPage);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(tp);
            PublishTMRulesViewPageController controller = new PublishTMRulesViewPageController(standardCtrlCon);
            Test.startTest();
            controller.refresh();
            Test.stopTest();
            System.assertEquals(controller.isDisabled, true); 
            
        }
        
    }
    static testMethod void publishTMRulesTestBadPIDResponse(){
         // test save(click publish button to get bad response from rest api <>201)
        csb.buildTerritoryManagementSettings();
        csb.buildTerritorySettings();//fg
        Territory_Settings__c terrset = Territory_Settings__c.getInstance();//fg
        //General_Settings__c onSupportSetting = General_Settings__c.getInstance();
       	string url = terrset.Publish_Territory_Assignment_URL__c;
        System.debug('Faina get url' + url);
        
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;        
        System.runAs(usr){
            
            Territory_Publish_Rule__c tp = new Territory_Publish_Rule__c();
            
            tp.Pending_Rule_Publish__c ='COMPLETE';
            tp.Rule_Identifier__c = 'PRTOCDS';
            tp.Rules_Last_Published_By__c = UserInfo.getUserId();
            tp.Rules_Last_Published_On__c = DateTime.now();
            insert tp;   
            PageReference tmPage= Page.PublishTMRulesViewPage;
            Test.setCurrentPage(tmPage);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(tp);
            PublishTMRulesViewPageController controller = new PublishTMRulesViewPageController(standardCtrlCon);
            //new fg
            StaticResourceCalloutMock multimockcallBodiService = new StaticResourceCalloutMock();   
            multimockcallBodiService.setStaticResource('MockPublishRulesSuccessPIDError');
            multimockcallBodiService.setStatusCode(201);
            multimockcallBodiService.setHeader('Content-Type', 'application/json');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockcallBodiService);
            controller.save();
            Test.stopTest();
            System.assertEquals(controller.isDisabled, false); 
            
        }
    }
    static testMethod void publishTMRulesTestBadResponse(){
        // test save(click publish button to get bad response from rest api <>201)
        csb.buildTerritoryManagementSettings();
        csb.buildTerritorySettings();//fg
        Territory_Settings__c terrset = Territory_Settings__c.getInstance();//fg
        string url = terrset.Publish_Territory_Assignment_URL__c;
        
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;        
        System.runAs(usr){
            
            Territory_Publish_Rule__c tp = new Territory_Publish_Rule__c();
            
            tp.Pending_Rule_Publish__c ='COMPLETE';
            tp.Rule_Identifier__c = 'PRTOCDS';
            tp.Rules_Last_Published_By__c = UserInfo.getUserId();
            tp.Rules_Last_Published_On__c = DateTime.now();
            insert tp;   
            PageReference tmPage= Page.PublishTMRulesViewPage;
            Test.setCurrentPage(tmPage);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(tp);
            PublishTMRulesViewPageController controller = new PublishTMRulesViewPageController(standardCtrlCon);
            //new fg
            StaticResourceCalloutMock multimockcallBodiService = new StaticResourceCalloutMock();   
            multimockcallBodiService.setStaticResource('MockPublishRulesSuccess');
            multimockcallBodiService.setStatusCode(200);
            multimockcallBodiService.setHeader('Content-Type', 'application/json');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockcallBodiService);
            controller.save();
            Test.stopTest();
            System.assertEquals(controller.isDisabled, false); 
            
        }
    }   
    
    static testMethod void publishTMRulesTest() {
        /*
		test saving records on clicking publish button when pending rule status = complete
		**/
        
        csb.buildTerritoryManagementSettings();
        csb.buildTerritorySettings();//fg
        Territory_Settings__c terrset = Territory_Settings__c.getInstance();//fg
        string url = terrset.Publish_Territory_Assignment_URL__c;
        
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;        
        System.runAs(usr){
            
            Territory_Publish_Rule__c tp = new Territory_Publish_Rule__c();
            
            tp.Pending_Rule_Publish__c ='COMPLETE';
            tp.Rule_Identifier__c = 'PRTOCDS';
            tp.Rules_Last_Published_By__c = UserInfo.getUserId();
            tp.Rules_Last_Published_On__c = DateTime.now();
            insert tp;   
            PageReference tmPage= Page.PublishTMRulesViewPage;
            Test.setCurrentPage(tmPage);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(tp);
            PublishTMRulesViewPageController controller = new PublishTMRulesViewPageController(standardCtrlCon);
            //new fg
            StaticResourceCalloutMock multimockcallBodiService = new StaticResourceCalloutMock();   
            multimockcallBodiService.setStaticResource('MockPublishRulesSuccess');
            multimockcallBodiService.setStatusCode(201);// 
            multimockcallBodiService.setHeader('Content-Type', 'application/json');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, multimockcallBodiService);
            controller.save();
            Test.stopTest();
            System.assertEquals(controller.isDisabled, true); 
            
        }
    }
}