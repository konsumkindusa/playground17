/**
     * Author Original:Sagar Talele
     * Date Original: 29 September 2014
     * Description: This is Test class for TimecardTriggerHandler
     */
@isTest
private class TimecardTriggerHandlerTest {
    //Create new instance of CustomSettingsBuilder
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

    public static Account accObj;
    public static Contact conObj;
    /**
     * Author Original:Sagar Talele
     * Date Original: 29 September 2014
     * Description: This is Test Method  for onBeforeDelete
     */
    static testMethod void TestonBeforeDelete() {
        
        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();
        custsettbuild.buildProjectValidationRuleSettings();
        String ApplicationEngineerFRole=System.Label.ProjectTeamMemeberFunctionalRole_ApplicationEngineer;
        
        List<MW_Project__c> projectList=new List<MW_Project__c>();
        List<MW_Project__c> projectListToUpdate=new List<MW_Project__c>();
        List<Project_Team_Member__c> projectTeamList=new List<Project_Team_Member__c>();
        List<Project_Time_Card__c> projectTimeCardList=new List<Project_Time_Card__c>();
        List<Account>accountList=new List<Account>();
        List<Contact>contList=new List<Contact>();
       
        //Create a user for TestDataBuilder
        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;
        
        User teamMember=TestDataBuilder.buildTestUser(3);
        teamMember.Functional_Role__c=ApplicationEngineerFRole;
        insert teamMember;

        
        //Create A Acocunt records for TestBuilder
        for(Integer i =0; i<10;i++){
            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';
            accountList.add(accObj);
        }
        insert accountList;
        System.AssertEquals(accountList.size(),10);
        //Create a contact recoords for TestBuilder
        for(Integer i =0;i<10;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accountList[i].id);
            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'China';
            contNL.MailingCountryCode = 'CN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = '北京';
            contNL.MailingStateCode ='11';
            contNL.MailingStreet = '宮崎県';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gmail.com';

            contList.add(contNL);

        }
        insert contList;
        System.AssertEquals(contList.size(),10);
System.runas(teamMember){
        //Create a Project for TestBuilder
        for( Integer i =0;i<10;i++ ){
           // MW_Project__c proObj=TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contList[i].Id); 
          // MW_Project__c proObj=TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), contList[i].Id);  
            MW_Project__c proObj=TestDataBuilder.buildTestProjectNonOppty(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId(), contList[i].Id);  
            proObj.requester__C=usrObj.id;
            proObj.Project_Status__c='In Progress';
            projectList.add(proObj);

        }
        Test.startTest();
        insert projectList;
        System.AssertEquals(projectList.size(),10);
        for(Integer i=0;i<10;i++){
            
               for(Integer j=0;j<2;j++){
                    //Create a Timecard for TestBuilder
                    Project_Time_Card__c proTimeCardObj=TestDataBuilder.buildTestProjectTimeCard(teamMember.id,projectList[i].id);
                    proTimecardObj.Week_Date__c = System.today();
                    projectTimeCardList.add(proTimeCardObj);
               }
        }
        
        //insert projectTimecardList
        insert projectTimeCardList;
       
       //update the status of timecard as Closed for test
        for(MW_Project__c proObj : projectList){
            
            proObj.Project_Status__c='Closed';
           
         }
    
       update   projectList;
       System.assertEquals(projectList[0].Project_Status__c,'Closed');    
            try{
            delete projectTimeCardList[0];
            }
            catch(Exception e){
                System.assert(e.getMessage().contains('Delete failed'));
            }
            Test.stopTest();
       }
    }
}