/**
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks 
* @date Original: 03 July 2013, Last Modified: 22 October 2013
* @description 
*/ 
@isTest
private class CaseCloneOverrideControllerTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: Aug 2, 2013, Last Modified: 22 October 2013
    * @description test method to test the cloning of case records.
    */
    static testMethod void CloneACaseRecord() {
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();
        
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = null;
        
        system.assert(cse.Product_Base_Code__c == null);
        insert cse;

        Test.startTest();
            //make current page CasecloneOverride 
            PageReference pageRef = Page.CaseCloneOverride;
            pageRef.getParameters().put('Id', cse.Id);
            Test.setCurrentPage(pageRef);
                
            List<Case> insertedCase = [SELECT id FROM Case];
            system.assertEquals(1,insertedCase.size());
            
            //set controllers
            ApexPages.StandardController standardCon = new ApexPages.StandardController(insertedCase[0]);
            CaseCloneOverrideController  overrideController = new CaseCloneOverrideController (standardCon); 
            
            //clone Case and mock redirecting page to return value of method SaveCloneRedirectToEdit().
            PageReference caseEditPage = overrideController.SaveCloneRedirectToEdit();
            Test.setCurrentPage(caseEditPage);
            
            //There should be two cases.
            List<Case> insertedCaseWithClone = [SELECT id FROM Case];
            system.assertEquals(2,insertedCaseWithClone.size());
                    
        Test.stopTest();
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: Aug 2, 2013, Last Modified: 22 October 2013
    * @description test method to test cancel cloning case.
    */
    static testMethod void CancelTest() {
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();
        
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = null;
        
        system.assert(cse.Product_Base_Code__c == null);
        insert cse;

        Test.startTest();
            //make current page CasecloneOverride 
            PageReference pageRef = Page.CaseCloneOverride;
            pageRef.getParameters().put('Id', cse.Id);
            Test.setCurrentPage(pageRef);
                
            List<Case> insertedCase = [SELECT id FROM Case];
            system.assertEquals(1,insertedCase.size());
            
            //set controllers
            ApexPages.StandardController standardCon = new ApexPages.StandardController(insertedCase[0]);
            CaseCloneOverrideController  overrideController = new CaseCloneOverrideController (standardCon); 
            
            //clone Case and mock redirecting page to return value of method SaveCloneRedirectToEdit().
            PageReference caseEditPage = overrideController.SaveCloneRedirectToEdit();
            Test.setCurrentPage(caseEditPage);
            
            //There should be two cases.
            List<Case> insertedCaseWithClone = [SELECT id FROM Case];
            system.assertEquals(2,insertedCaseWithClone.size());
            
            List<Case> cloneCaseId = [SELECT id FROM Case WHERE id != :cse.id];
            
            system.debug(cloneCaseId[0].Id);
            
            //Mock clicking cancel button
            PageReference cancelPage = Page.CaseCloneCancel;
            cancelPage.getParameters().put('id', cloneCaseId[0].id);
            cancelPage.getParameters().put('oldid', cse.id);
            Test.setCurrentPage(cancelPage);
            
            overrideController.CancelClonedCase();
            
            List<Case> casesAfterCancel = [SELECT id FROM Case];
            system.assertEquals(1,casesAfterCancel.size());
            
                    
        Test.stopTest();
    }
    
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: Aug 2, 2013, Last Modified: 22 October 2013
    * @description test method to saving of clone case with newId parameter on URL.
    */
    static testMethod void SaveCloneTestWithParameterNewid() {
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();
        
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = null;
        
        system.assert(cse.Product_Base_Code__c == null);
        insert cse;

        Test.startTest();
            //make current page CasecloneOverride 
            PageReference pageRef = Page.CaseCloneOverride;
            pageRef.getParameters().put('Id', cse.Id);
            Test.setCurrentPage(pageRef);
                
            List<Case> insertedCase = [SELECT id FROM Case];
            system.assertEquals(1,insertedCase.size());
            
            //set controllers
            ApexPages.StandardController standardCon = new ApexPages.StandardController(insertedCase[0]);
            CaseCloneOverrideController  overrideController = new CaseCloneOverrideController (standardCon); 
            
            //clone Case and mock redirecting page to return value of method SaveCloneRedirectToEdit().
            PageReference caseEditPage = overrideController.SaveCloneRedirectToEdit();
            Test.setCurrentPage(caseEditPage);
            
            //There should be two cases.
            List<Case> insertedCaseWithClone = [SELECT id FROM Case];
            system.assertEquals(2,insertedCaseWithClone.size());
            
            List<Case> cloneCaseId = [SELECT id FROM Case WHERE id != :cse.id];
            
            system.debug(cloneCaseId[0].Id);
            
            //Mock clicking save button
            PageReference saveClonePage = Page.CaseCloneSaveByPass;
            saveClonePage.getParameters().put('id', cloneCaseId[0].id);
            saveClonePage.getParameters().put('newid', cloneCaseId[0].id);
            Test.setCurrentPage(saveClonePage);
            
            overrideController.UpdateCloneCase();
            
            List<Case> casesAfterCancel = [SELECT id FROM Case];
            system.assertEquals(2,casesAfterCancel.size());
            
                    
        Test.stopTest();
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: Aug 2, 2013, Last Modified: 22 October 2013
    * @description test method to saving of clone case without newId parameter on URL.
    */
    static testMethod void SaveCloneTestWithoutParameterNewid() {
         //re-create Integration Setting
        csb.buildIntegrationSetting();
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        //Disable On-Support trigger on Case
        CaseTriggerHandler cseTrigHandler = new CaseTriggerHandler();
        cseTrigHandler.stopTrigger();
        
        Case InsCse = new Case(); 
        Case UpdatedCase = new Case();
        
        //create test case
        Case cse = new Case();
        cse.status = 'Open';
        cse.License__c = '491381';
        cse.Product_Lookup__c = null;
        
        system.assert(cse.Product_Base_Code__c == null);
        insert cse;

        Test.startTest();
            //make current page CasecloneOverride 
            PageReference pageRef = Page.CaseCloneOverride;
            pageRef.getParameters().put('Id', cse.Id);
            Test.setCurrentPage(pageRef);
                
            List<Case> insertedCase = [SELECT id FROM Case];
            system.assertEquals(1,insertedCase.size());
            
            //set controllers
            ApexPages.StandardController standardCon = new ApexPages.StandardController(insertedCase[0]);
            CaseCloneOverrideController  overrideController = new CaseCloneOverrideController (standardCon); 
            
            //clone Case and mock redirecting page to return value of method SaveCloneRedirectToEdit().
            PageReference caseEditPage = overrideController.SaveCloneRedirectToEdit();
            Test.setCurrentPage(caseEditPage);
            
            //There should be two cases.
            List<Case> insertedCaseWithClone = [SELECT id FROM Case];
            system.assertEquals(2,insertedCaseWithClone.size());
            
            List<Case> cloneCaseId = [SELECT id FROM Case WHERE id != :cse.id];
            
            system.debug(cloneCaseId[0].Id);
            
            //Mock clicking save button
            PageReference saveClonePage = Page.CaseCloneSaveByPass;
            saveClonePage.getParameters().put('id', cloneCaseId[0].id);
            
            Test.setCurrentPage(saveClonePage);
            
            overrideController.UpdateCloneCase();
            
            List<Case> casesAfterCancel = [SELECT id FROM Case];
            system.assertEquals(2,casesAfterCancel.size());
            
                    
        Test.stopTest();
    }
    
}