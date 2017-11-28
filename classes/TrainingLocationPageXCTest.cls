/**
 *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
 *@date Original: 1 July 2016, Last Modified: 
 *@description This  is test class for 'TrainingLocationPage Extension' . 
 *@Revision:
 */
@isTest
public class TrainingLocationPageXCTest{
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
    private static User usr; 
    
    /**
     *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
     *@date Original: 4 July 2016, Last Modified: 
     *@description: This method contain the test data use for different test method. 
     *@param: 
     *@Revision:
    */
    
    static void insertTestData() {
    
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        System.runAs(usr){
                   
            //Create Training Location Test data.
            Training_Location__c trainLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
            trainLocObj.State__c = 'Florida';
            insert trainLocObj;
        }//End of RunAs
    }//End of Method
    
    /**
     *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
     *@date Original: 4 July 2016, Last Modified: 
     *@description: Method to test the functionality to insert country as none of the training location Object. 
     *@param: 
     *@Revision:
    */
    
    private static testMethod void insertNoneTrainingLocationTest(){
        
        TrainingLocationPageXCTest.insertTestData();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        usr = [SELECT Id FROM User WHERE Id =: usr.Id];
        
        System.runAs(usr){                                  
            
            Training_Location__c traingLocObj = new Training_Location__c();
            
            traingLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
            traingLocObj.Publish_To_Web__c = False;
                       
            
            //Start Test
            test.startTest();
            
            PageReference pageRef = Page.TrainingLocationPage;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(traingLocObj);
            TrainingLocationPageXC controller = new TrainingLocationPageXC(standardCtrlCon);
            
            controller.trainingLocationObj = traingLocObj;
            //Assigning value to the component. 
            controller.compDataObj.countryCode = '--None--';
            controller.compDataObj.countryName = null;
            controller.compDataObj.StateName = null;
            controller.compDataObj.StateCode = null;
            controller.save();
            
            //Querying the Training Location.
            List<Training_Location__c> updatedTrainingLocObj = [SELECT Country__c, Country_Code__c,State__c, State_Code__c, Country_Code_State_Code__c 
                                                         FROM Training_Location__c];
            //Asserting the Training Location Country has the value as in the component.
            System.assertEquals(updatedTrainingLocObj[1].Country__c, null);
            System.assertEquals(updatedTrainingLocObj[1].Country_Code__c, null);
            System.assertEquals(updatedTrainingLocObj[1].State__c, null);
            System.assertEquals(updatedTrainingLocObj[1].State_Code__c, null);
            System.assertEquals(updatedTrainingLocObj[1].Country_Code_State_Code__c, null);
            
            
            //Stop Test
            test.stopTest();
        }//End of RunAs
    }//End of Method
    
    /**
     *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
     *@date Original: 4 July 2016, Last Modified: 
     *@description: Method to test the functionality to update the training location Object. 
     *@param: 
     *@Revision:
    */
 /*  SS - 1951614 - 2/23/17 - State should not be required when creating or editing locations 
    private static testMethod void checkStateRequireTest(){
        
        TrainingLocationPageXCTest.insertTestData();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        usr = [SELECT Id FROM User WHERE Id =: usr.Id];
        
        System.runAs(usr){
            //Querying the Training Location User.
            Training_Location__c trainingLocObj = [SELECT Id, Name, Location_Name_Latin__c, Region__c, Location_Type__c, 
                                    Status__c, Publish_To_Web__c, Account__c, Cancellation_Lead_Time__c,Address_Line_1__c,
                                    Address_Line_2__c, City__c, Country__c, Postal_Code__c, State__c, Admin_Contact__c, 
                                    Technical_Contact__c, Location_Email__c, Location_Fax__c, Location_Phone__c, Location_URL__c, Notes__c,
                                    Country_Code__c, State_Code__c, Country_Code_State_Code__c, Directions__c FROM Training_Location__c];
                                    
            //Start Test
            test.startTest();
            
            PageReference pageRef = Page.TrainingLocationPage;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(trainingLocObj);
            TrainingLocationPageXC controller = new TrainingLocationPageXC(standardCtrlCon);
            
            controller.trainingLocationObj = trainingLocObj;
            //Assigning value to the component. 
            controller.compDataObj.countryCode = 'IN';
            controller.compDataObj.stateCode = null;
            controller.compDataObj.stateName = null;
            controller.compDataObj.countryName = 'India';
            controller.save();
            
            PageReference trainingLocPageRef = controller.save();
            
            //Querying the Training Location.
            List<Training_Location__c> updatedTrainingLocObj = [SELECT Country__c, Country_Code__c,State__c, State_Code__c, Country_Code_State_Code__c 
                                                         FROM Training_Location__c];
            
            //Asserting the Training Location Country has the value as in the component.
            System.assertNotEquals(updatedTrainingLocObj[0].Country__c, 'India');
            System.assertNotEquals(updatedTrainingLocObj[0].Country_Code__c, 'IN');
            System.assertNotEquals(updatedTrainingLocObj[0].State__c, null);
            System.assertEquals(updatedTrainingLocObj[0].State_Code__c, null);
            System.assertEquals(updatedTrainingLocObj[0].Country_Code_State_Code__c, null);
            
            
            //Stop Test
            test.stopTest();
        }//End of RunAs
    }//End of Method
  */  
    
    /**
     *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
     *@date Original: 4 July 2016, Last Modified: 
     *@description: Method to test the functionality for insertion of Training Location Object.. 
     *@param: 
     *@Revision:
    */
    
    private static testMethod void insertTrainingLocationTest(){
        
        TrainingLocationPageXCTest.insertTestData();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        usr = [SELECT Id FROM User WHERE Id =: usr.Id];
        
        System.runAs(usr){
           
            Training_Location__c traingLocObj = new Training_Location__c();
            
            traingLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
            
            
            //Start Test
            test.startTest();
            PageReference pageRef = Page.TrainingLocationPage;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(traingLocObj);
            TrainingLocationPageXC controller = new TrainingLocationPageXC(standardCtrlCon);
            
            //Creating the value for the page.
            controller.trainingLocationObj = traingLocObj;
            controller.compDataObj.countryCode = 'IN';
            controller.compDataObj.stateCode = 'IN-MH';
            controller.compDataObj.stateName = 'Maharashtra';
            controller.compDataObj.countryName = 'India';
            controller.save();
            
            //Querying the Training Location Object.
            List<Training_Location__c> trainingLocRec =[SELECT Id,  Country__c, State__c, State_Code__c, Country_Code_State_Code__c
                                                        FROM Training_Location__c];   
            //Assert if the Record is created or not.
            System.assertNotEquals(trainingLocRec[1].Id, null);
            System.assertEquals(trainingLocRec[1].Country__c, 'India');
            System.assertEquals(trainingLocRec[1].State__c, 'Maharashtra');
            System.assertEquals(trainingLocRec[1].State_Code__c, 'MH');
            System.assertEquals(trainingLocRec[1].Country_Code_State_Code__c, 'IN-MH');
            
            //Stop Test
            test.stopTest();
        }//End of RunAs
    }//End of Method
    
    //Test case: Change status to 'Mark for Deletion' while publish to web is true.
    private static testMethod void SetStatusMarkForDeletion_1(){
        
        TrainingLocationPageXCTest.insertTestData();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        usr = [SELECT Id FROM User WHERE Id =: usr.Id];
        
        System.runAs(usr){

            Training_Location__c traingLocObj = new Training_Location__c();
            
            traingLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);          
            traingLocObj.Status__c = 'Mark for Deletion';
            traingLocObj.publish_to_web__c = true;
            
            //Start Test
            test.startTest();
            PageReference pageRef = Page.TrainingLocationPage;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(traingLocObj);
            TrainingLocationPageXC controller = new TrainingLocationPageXC(standardCtrlCon);
            
            //Creating the value for the page.
            controller.trainingLocationObj = traingLocObj;
            controller.compDataObj.countryCode = 'IN';
            controller.compDataObj.stateCode = 'IN-MH';
            controller.compDataObj.stateName = 'Maharashtra';
            controller.compDataObj.countryName = 'India';
            controller.save();
            
            test.stopTest();
        }//End of RunAs
        
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains(System.Label.Training_location_before_update_2)) b = true;
		}
		system.assert(b);
    }//End of Method
    
    //Test case: Change status to 'Mark for Deletion' while there is a class associated to the location.
    private static testMethod void SetStatusMarkForDeletion_2(){
        
        TrainingLocationPageXCTest.insertTestData();
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        usr = [SELECT Id FROM User WHERE Id =: usr.Id];
        
        System.runAs(usr){
            
            Training_Location__c traingLocObj = new Training_Location__c();

            //Creating the Class__c test data.
            Language__c langObj = CTrainingTestDataBuilder.buildTestLanguage(0);
            langObj.SF_ISO_Code__c = 'en_US';
            insert langObj;

            Id courserecTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Training').getRecordTypeId();
            Course__c courseObj = CTrainingTestDataBuilder.buildTestCourse(0);
            courseObj.recordTypeId = courserecTypeId;
            courseObj.Course_Code__c = 'TESTCODE';
            insert courseObj;

            traingLocObj = CTrainingTestDataBuilder.buildTestTrainingLoc(1);
            traingLocObj.Status__c = 'Active';
            traingLocObj.Publish_To_Web__c = False;
            insert traingLocObj;
            
            Id classrecTypeId = Schema.SObjectType.Class__c.getRecordTypeInfosByName().get('Instructor Led').getRecordTypeId();    
            Class__c clssObj = CTrainingTestDataBuilder.buildTestClass(0, courseObj.Id, langObj.Id);
            clssObj.Max_Seats__c  = 500;
            clssObj.recordTypeId = classrecTypeId;
            clssObj.Status__c='Active';
            clssObj.Training_Location__c = traingLocObj.id;
            insert clssObj;           
		
		
            
            //Start Test
            test.startTest();
            PageReference pageRef = Page.TrainingLocationPage;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController standardCtrlCon = new ApexPages.StandardController(traingLocObj);
            TrainingLocationPageXC controller = new TrainingLocationPageXC(standardCtrlCon);
            
            //Creating the value for the page.
            controller.trainingLocationObj = traingLocObj;
            controller.compDataObj.countryCode = 'IN';
            controller.compDataObj.stateCode = 'IN-MH';
            controller.compDataObj.stateName = 'Maharashtra';
            controller.compDataObj.countryName = 'India';
            controller.trainingLocationObj.Status__c = 'Mark for Deletion';
            controller.save();
            
            test.stopTest();
        }//End of RunAs
        
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains(System.Label.Training_location_before_update_2)) b = true;
		}
		system.assert(b);
    }//End of Method
    
}