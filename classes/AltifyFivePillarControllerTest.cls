/*
 *@author Original: Shweta Shanbhag - Mathworks
 *@Last Modified: Shweta Shanbhag - Mathworks, 
 *@date Original: 10/27/2017
 *@Last Modified: 10/27/2017
 *@description This is Test class for 'AltifyFivePillarController' class . 
*/

@isTest
public class AltifyFivePillarControllerTest {
	public static DMAPP__DM_Account_Plan__c accplnObj {get; set;}
    public static DMAPP__Plan_Type__c accplnTypeObj {get;set;}
	
	static CustomSettingsBuilder csb = new CustomSettingsBuilder();	
    
    static testMethod void Testfivepillarpage(){
	
         User usr = TestDataBuilder.buildTestUser(1);
          insert usr;
        
          csb.buildBypassTriggerSettings();
          csb.buildGenSetting();
		
		System.runAs(usr){
	 
            DMAPP__Plan_Type__c accntplantype = new DMAPP__Plan_Type__c();
            accntplantype.name = 'Commercial Account Plan';
            accntplantype.DMAPP__Horizontal_Axis__c = 'Importance to Customer';
            accntplantype.DMAPP__Vertical_Axis__c = 'Importance to MathWorks';
            accntplantype.BA_MLUsers__c = True;
            accntplantype.BA_SLUsers__c = True;
            insert accntplantype;
            
         
            DMAPP__DM_Account_Plan__c accntplan = new DMAPP__DM_Account_Plan__c();
            accntplan.name = 'Account Plan Test';
            accntplan.DMAPP__Plan_Type__c = accntplantype.id;
            accntplan.DMAPP__From_Date__c = System.today();
            accntplan.DMAPP__To_Date__c = System.today() + 90;           
            insert accntplan;

            //set current page
            PageReference fivepillarpage = Page.Five_Pillar_Questions;
            Test.setcurrentpage(fivepillarpage);
	
            //put id into url
            fivepillarpage.getparameters().put('id', accntplan.id);
	
         	Test.startTest();
            
            AltifyFivePillarController controller = new AltifyFivePillarController();
            controller.getPlan();
            controller.getPlan(accntplan.id);
            controller.getSections();
            controller.getItems();
            controller.getQuestionTexts();
            AltifyFivePillarController.updateField(accntplan.id, 'BA_MLUsers__c', '3');
         
         	DMAPP__DM_Account_Plan__c accntpln = [SELECT BA_MLUsers__c from DMAPP__DM_Account_Plan__c where id =: accntplan.id ];
            system.assertEquals(accntpln.BA_MLUsers__c, '3', True);
         
         Test.stopTest();
	
	
	
	}	 
}
    
}