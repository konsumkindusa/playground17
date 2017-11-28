/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original: 28 Jan 2016, Last Modified: 
 *@description This  is Test class for 'CountryStatePickListController' . 
 *@Revision:
 */

@isTest 
private class CountryStatePickListControllerTest{
    
    /*
      @name         countryStatePickListTest
      @date         5.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  To test the functionality that the state should be visible if the country has states associated with it. 
        */
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();
    
    private static testMethod void countryStatePickListTest(){
        
        //Create test data user. 
        user testUser = TestDataBuilder.buildTestUser(1);
        insert testUser;
         
        system.runAs(testUser){
        
            //test start
            test.startTest();
            
            //Initialising the controller 
            CountryStatePickListController controllerObj = new CountryStatePickListController();
            controllerObj.cData = new ComponentData();
            controllerObj.countrySelected='IN';
            controllerObj.getCountryList();
            controllerObj.getStateList();
            controllerObj.getCountryRequiringStateList();
            controllerObj.getStateCode();
            controllerObj.getCountryCode();
            
            //Querying the State Code List metadata.
            List<State_Code_List__mdt> stateCodeMdtLst = [SELECT State_Code__c FROM State_Code_List__mdt WHERE Country_Code__c =: controllerObj.countrySelected];
            //Asserting if the state count is same as in the State_Code_List__mdt list.
            System.assertEquals((controllerObj.getStateList().size()), stateCodeMdtLst.size()+1);
            //stop test
            test.stopTest();
        }//End of runAs User
    }//End of Method.
    
     /*
      @name         countryStateWithCodesPickListTest
      @date         11.April.2016
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  To test the functionality that the state should be visible if the country has states associated with it. 
        */
   
    private static testMethod void countryStateWithCodesPickListTest(){
        
        //Create test data user. 
        user testUser = TestDataBuilder.buildTestUser(1);
        insert testUser;
         
        system.runAs(testUser){
        
            //test start
            test.startTest();
            
            //Initialising the controller 
            CountryStatePickListController controllerObj = new CountryStatePickListController();
            controllerObj.showCountryLongNamesWithCode = true;
            controllerObj.cData = new ComponentData();
            controllerObj.countrySelected='IN';
            controllerObj.getCountryList();
            controllerObj.getStateList();
            controllerObj.getCountryRequiringStateList();
            controllerObj.getStateCode();
            controllerObj.getCountryCode();
            
            //Querying the State Code List metadata.
            List<State_Code_List__mdt> stateCodeMdtLst = [SELECT State_Code__c FROM State_Code_List__mdt WHERE Country_Code__c =: controllerObj.countrySelected];
            //Asserting if the state count is same as in the State_Code_List__mdt list.
            System.assertEquals((controllerObj.getStateList().size()), stateCodeMdtLst.size()+1);
            //stop test
            test.stopTest();
        }//End of runAs User
    }//End of Method.
    
    
    /*
      @name         countryRequireStateListTest
      @date         5.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality to do not show the states if the country has no state associated with it.
        */
    
    private static testMethod void countryRequireStateListTest(){
        
        //Create test data user. 
        user testUser = TestDataBuilder.buildTestUser(1);
        insert testUser;
        
        system.runAs(testUser){
            //Start Test
            test.startTest();
            
            //Initialising the controller.
            CountryStatePickListController controllerObj = new CountryStatePickListController();
            controllerObj.cData = new ComponentData();
            controllerObj.countrySelected='AD';
            controllerObj.getCountryList();
            controllerObj.getStateList();
            controllerObj.getCountryRequiringStateList();
            controllerObj.getStateCode();
            controllerObj.getCountryCode();
            
            //Asserting for the country donot have any state associated with it. Only None is present in the getStateList method.
            System.assertEquals((controllerObj.getStateList().size()), 1);
            //Stop test
            test.stopTest();
        }//End of runAs User
    }//End of Method. 
    
}