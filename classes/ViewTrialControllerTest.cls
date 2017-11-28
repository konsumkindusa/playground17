/*
 *    @description: tests the ViewTrialController
 */
@isTest
public  class ViewTrialControllerTest { 

    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    /*
    @ name    TestShowTrialsRelatedToOpportunity
    @ date    10.Oct.2014
    @ author  Archana Lohar
    @ param   none.
    @ return  Void. 
    @ description :Expected that it  will show all the trials related to the Opportunity record. 
     */
    @isTest private static  void TestShowTrialsRelatedToOpportunity(){

        List<Opportunity> opptyLst =new List<Opportunity>();
        
       
        
        User usr = TestDataBuilder.buildTestUser(1);
        usr.Functional_Role__c = 'Sales Manager';
        insert usr;
        csb.buildBypassTriggerSettings();
        csb.buildTrialsIntegrationSetting();
        csb.buildIntegrationSetting();
        csb.buildLicensesIntegrationSetting();
        csb.buildGenSetting();
        
        Account acctL = TestDataBuilder.buildTestAccount(1, UserInfo.getUserId());
        insert acctL;
        
        System.runAs(usr){
            
       

            for(Integer i=0;i<3;i++){
                Opportunity opp = TestDataBuilder.buildTestOpportunity(i);
                opp.AccountId = acctL.Id;
                opptyLst.add(opp);         
            }

            insert opptyLst;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

            //set current page 
            PageReference trialsPage = Page.ViewTrials;
            Test.setCurrentPage(trialsPage);
            Test.startTest();
        
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(opptyLst[1]);
            ViewTrialController controller = new ViewTrialController(standardCtrlCon);
            
            
            
            controller.getshowTrialsRelatedToOpportunityTest(); 
            
            controller.FirstPage();
            controller.previous();
            controller.next();
            controller.LastPage();
            controller.getprev();
            controller.getnxt();
            
            system.assertEquals(controller.trialList.size(),3);
            
            controller.selTrialid='1930281';
            controller.selectTrial();
            
            system.assert(controller.relatedProductList.size()!=null);
            system.assert(controller.relatedPeopleList.size()!=null);
            
            
            controller.FirstConPage();
            controller.previousCon();
            controller.nextCon();
            controller.LastConPage();
            controller.getConprev();
            controller.getConnxt();
            
            system.assertEquals(controller.selectedTrialList.size(),1);
            
            system.assert(controller.trialList.size()!=null);
            Test.stopTest();
        }

    }
}