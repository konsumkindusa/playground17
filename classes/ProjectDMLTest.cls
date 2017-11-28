/**
 * author Original: Andre Calimlim, modified : Faina Gorelik
 * date Original: 5 Aug 2014, date modified: 29 Nov 2016 AtTask #1777908 
 * description: This class contains unit tests for validating the behavior of ProjectDML, ProjectTriggerHandler classes
 * and ProjectMasterTrigger trigger.
 */
@isTest
private class ProjectDMLTest {
    //Create new instance of CustomSettingsBuilder
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

    public static Account accObj;
    public static Contact conObj;
    
    /**
     * author Original: Archana lohar, Modified by: Faina Gorelik AtTask 1808978
     * date Original: 9 Sep 2014, Modified : 12 Dec 2016
     * description: bulk Test to ensure Account project object is getting created
     */

    static testMethod void testCreateAccountProject() {

        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();

        List<Account> accNLLst =new List<Account>();
        List<Contact> contNLLst =new List<Contact>();

        for(Integer i=0;i<=3;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;
        System.assertEquals(accNLLst.size(),4);
        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<=3;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
            
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;
        System.assertEquals(contNLLst.size(),4);
        List<MW_Project__c> recList = new List<MW_Project__c>();

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;

        for(Integer i = 0; i <=3; i++){

            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
            rec.account__C = accNLLst[i].id;
            rec.Purpose__c='Territory Support';
            rec.outcome__c = 'Internal';
            rec.Selling_Priorities__c ='None';
            rec.requester__C=usrObj.id;
            recList.add(rec);

        }

        Test.startTest();

        insert recList;
        System.assertEquals(recList.size(),4);
        
        system.assert(recList.size()!=0);
        
        List<Account_Project__c> accProjList=new  List<Account_Project__c>();
        
        accProjList=[select id,account__C  from Account_Project__c where Account__c in:accNLLst];
        
         System.assertEquals(accProjList.size(),4);

        Test.stopTest();

    }
    
    
     
     /**
     * author Original: Archana lohar
     * date Original: 9 Sep 2014
     * description: bulk Test to ensure Campaign project object is getting created
     */

    static testMethod void testCreateCampaignProject() {

        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();

        List<Account> accNLLst =new List<Account>();
        List<Contact> contNLLst =new List<Contact>();
        List<Campaign> campLst =new List<Campaign>();


        for(Integer i=0;i<200;i++){

            Campaign campObj = TestDataBuilder.buildTestCampaign(i);
            campLst.add(campObj);
        }

        insert campLst;

        for(Integer i=0;i<200;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<200;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
        
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';
                contNLLst.add(contNL);

        }

        insert contNLLst;

        List<MW_Project__c> recList = new List<MW_Project__c>();

        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;

        for(Integer i = 0; i < 200; i++){

            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
            rec.campaign__C = campLst[i].id;
            rec.purpose__c = 'Marketing';
            rec.Outcome__c = 'CME';
            rec.Selling_Priorities__c = 'None';
            rec.requester__C=usrObj.id;
            recList.add(rec);

        }

        Test.startTest();

        insert recList;
        
        List<Campaign_Project__c> campProjList=new List<Campaign_Project__c>();
        
        campProjList=[select id from Campaign_Project__c where Campaign__c in:campLst];
        
        system.assert(campProjList.size()!=0);

        Test.stopTest();

    }
    
     /**
     * author Original: Archana lohar
     * date Original: 9 Sep 2014
     * description: bulk Test to ensure that user has added to project team
     */

   static testMethod void testAddUsersToProjectTeam() {

        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();

        List<Account> accNLLst =new List<Account>();
        List<Contact> contNLLst =new List<Contact>();

        for(Integer i=0;i<200;i++){

            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';

            accNLLst.add(accObj);
        }

        insert accNLLst;

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<200;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
      
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

            contNLLst.add(contNL);

        }

        insert contNLLst;

        List<MW_Project__c> recList = new List<MW_Project__c>();
         List<MW_Project__c> ownerQueueList = new List<MW_Project__c>();
        List<Project_Team_Member__c> projectTeamList = new List<Project_Team_Member__c>();
        List<Project_Team_Member__c> projectTeamOwnerTypeList;
        //Changing the Owner Of opportunity
        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;

        for(Integer i = 0; i < 200; i++){

            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
            rec.requester__C=usrObj.id;
            rec.Project_Status__c='Accepted';
            recList.add(rec);

        }
        //check if  project ownerid id is queue then that Id not added into the project Team member
        
        Group grp = TestDataBuilder.buildTestGroup('MW_Project__c');
        for(Integer i = 0; i < 200; i++){

            MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
            rec.ownerId=grp.id;
            rec.requester__C=usrObj.id;
            rec.Project_Status__c='Accepted';
            rec.Selling_Priorities__c ='None';
            ownerQueueList.add(rec);

        }
        //check projectTeamOwner is not of type Queue
        projectTeamOwnerTypeList = [Select Id,Project__r.ownerid from Project_Team_Member__c where Project__r.ownerid =: grp.id];
        
        Test.startTest();
        insert recList;
        insert ownerQueueList;
        System.assertEquals(projectTeamOwnerTypeList.size(),0);
        Test.stopTest(); 

    }
    
    /*End of Test Class*/
    /*
     * author Original:
     * date Original:19 Sep 2014
     * description: Unit test to ensure that  Team member listed has hours that are greater than zero.
     */
    static testMethod void testValidateProjectBeforeClose(){

        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();
        String ApplicationEngineerFRole=System.Label.ProjectTeamMemeberFunctionalRole_ApplicationEngineer;
        boolean hasTimecard = false;
        List<MW_Project__c> projectList=new List<MW_Project__c>();
        List<MW_Project__c> projectListToUpdate=new List<MW_Project__c>();
        List<Project_Team_Member__c> projectTeamList=new List<Project_Team_Member__c>();
        List<Project_Time_Card__c> projectTimeCardList=new List<Project_Time_Card__c>();
        List<Account>accountList=new List<Account>();
        List<Contact>contList=new List<Contact>();

        User usrObj=TestDataBuilder.buildTestUser(2);
        insert usrObj;

        //Create A Acocunt records for TestBuilder
        for(Integer i =0; i<100;i++){
            accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accObj.BillingCountryCode = 'US';
            accObj.BillingCountry = 'United States';
            accObj.BillingStateCode = 'NY';
            accObj.BillingState = 'New York';
            accountList.add(accObj);
        }
        insert accountList;
        System.AssertEquals(accountList.size(),100);
        //Create a contact recoords for TestBuilder
        for(Integer i =0;i<100;i++){

            Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accountList[i].id);
          
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

            contList.add(contNL);

        }
        insert contList;
        System.AssertEquals(contList.size(),100);
        for( Integer i =0;i<100;i++ ){
            MW_Project__c proObj=TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contList[i].Id); 
            proObj.requester__C=usrObj.id;
            proObj.Project_Status__c='In Progress';
            projectList.add(proObj);

        }
       

        insert projectList;
        System.AssertEquals(projectList.size(),100);
         
        User teamMember=TestDataBuilder.buildTestUser(3);
        teamMember.Functional_Role__c=ApplicationEngineerFRole;
        insert teamMember;

        User timeCardResource=TestDataBuilder.buildTestUser(4);
        insert timeCardResource;
       
        Test.startTest();
 
        for(Integer i=0;i<100;i++){
            
            Project_Team_Member__c proTeamMemberObj =TestDataBuilder.buildTestProjectTeamMember(teamMember.id,projectList[i].id);
            projectTeamList.add(proTeamMemberObj);
            
            Project_Time_Card__c proTimeCardObj=TestDataBuilder.buildTestProjectTimeCard(teamMember.id,projectList[i].id);
            proTimeCardObj.Hours__c=123;
            proTimeCardObj.Week_Date__c = System.today();
           
            MW_Project__c proObj=projectList[i];
            Project_Time_Card__c proTimeCardObj1=TestDataBuilder.buildTestProjectTimeCard(UserInfo.getUserId(),projectList[i].id);
            proTimeCardObj1.Hours__c=123;
            proObj.Project_Status__c='Accepted';
            proTimeCardObj1.week_date__c = System.today();
            
            projectTimeCardList.add(proTimeCardObj);
            projectTimeCardList.add(proTimeCardObj1);
            projectListToUpdate.add(proObj);
            System.assert(projectTimeCardList[i].Hours__c > 0);
        }
       
        insert projectTeamList; 
        insert projectTimeCardList;
        update projectListToUpdate; 
        
        //System.AssertEquals(projectTeamList[0].id,projectTimeCardList[0].AE_PE__c);
        //test every team Member atleast one timecard
        for(Project_Team_Member__c teamObj: projectTeamList){
            
            for(Project_Time_Card__c timeCardObj: projectTimeCardList){
            
                if(teamObj.Resource__c == timeCardObj.AE_PE__c){
                    hasTimecard = true;
                }
            }
            System.AssertEquals(hasTimecard ,true);
        }
        System.assert(projectListToUpdate.size()!=0);
        Test.stopTest();

    }
   
    /*
     * @Author original: Sagar Talele 
     * @Date : 24 September
     * @Description: MW_Project__c having the related Opportunity that will Create New Opportunity Project juntion.
     */      
     static testMethod void testCreateOpportunityProject(){
         custsettbuild.buildBypassTriggerSettings();
         custsettbuild.buildGenSetting();
         custsettbuild.buildAddressLatinTranslation();
         
         List<Account> accNLLst=new List<Account>();
         List<Contact> contNLLst=new List<Contact>();
         List<Opportunity> oppLst=new List<Opportunity>();
         
           //create Opportunity record from TestDataBuilder.
         for(integer i=0;i<200;i++){
             Opportunity oppObj=TestDataBuilder.buildTestOpportunity(i);
             oppObj.amount=20;
             oppObj.CurrencyIsoCode='INR';
             oppLst.add(oppObj);
         }
       
        
         
         
         for(Integer i=0;i<200;i++){

                accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accObj.BillingCountryCode = 'US';
                accObj.BillingCountry = 'United States';
                accObj.BillingStateCode = 'NY';
                accObj.BillingState = 'New York';

                accNLLst.add(accObj);
            }

            insert accNLLst;
            System.AssertEquals(accNLLst.size(),200);
            //create Contact record from TestDataBuilder.
            for(Integer i=0;i<200;i++){

                Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
             
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

                contNLLst.add(contNL);

            }
            
            insert contNLLst;
            System.AssertEquals(contNLLst.size(),200);
            List<MW_Project__c> recList = new List<MW_Project__c>();

            //Changing the Owner Of opportunity
            User usrObj=TestDataBuilder.buildTestUser(3);
            insert usrObj;

            for(Integer i = 0; i < 200; i++){

                MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
                rec.Opportunity__c = oppLst[i].id;
                rec.requester__C=usrObj.id;
                recList.add(rec);

            }
            System.AssertEquals(recList.size(),200);
            Test.startTest();

            insert recList;
            System.AssertEquals(recList.size(),200);
            Test.stopTest();
     }  
    /* 
     *@Author Original: Sagar Talele
     *@Last Modified:Sagar Talele - Cloud Sherpas/Mathworks
     *@Date Original: 6 October 2014
     *@Description: Unit test to ensure that  setting  the office value on the project based on the project requestor's Area if office__c
     */
    
    static testMethod void testInsertProjectAreaFromRequestor(){
        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();
        
        List<Account> accNLLst=new List<Account>();
        List<Contact> contNLLst=new List<Contact>();
        
        
              //Create A Acocunt records for TestBuilder      
             for(Integer i=0;i<200;i++){

                accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accObj.BillingCountryCode = 'US';
                accObj.BillingCountry = 'United States';
                accObj.BillingStateCode = 'NY';
                accObj.BillingState = 'New York';

                accNLLst.add(accObj);
            }

            insert accNLLst;
            System.AssertEquals(accNLLst.size(),200);
            //create Contact record from TestDataBuilder.
            for(Integer i=0;i<200;i++){

                Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

                contNLLst.add(contNL);

            }

            insert contNLLst;
            System.AssertEquals(contNLLst.size(),200);
            
             List<MW_Project__c> recList = new List<MW_Project__c>();

            User usrObj=TestDataBuilder.buildTestUser(4);
            insert usrObj;
            //create Project record from TestDataBuilder.
            for(Integer i = 0; i < 200; i++){

                MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
                rec.Office__c = 'ES - Customer Support';
                rec.requester__C=usrObj.id;
                recList.add(rec);

            }
            
            Test.startTest();

            insert recList;
            System.AssertEquals(recList.size(),200);
            Test.stopTest();
        
      } 
    
    /**********************
     Added by Jaspreet 
     Date: 3/10/2015
     Reason: test Case for UpdateIsHrsOnTimeCard method of ProjectDML class
    *********************/
    
    static testMethod void testUpdateIsHrsOnTimeCard(){
        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();
        
        List<Account> accNLLst=new List<Account>();
        List<Contact> contNLLst=new List<Contact>();
        String ApplicationEngineerFRole=System.Label.ProjectTeamMemeberFunctionalRole_ApplicationEngineer;
        boolean hasTimecard = false;
        List<MW_Project__c> projectList=new List<MW_Project__c>();
        List<MW_Project__c> projectListToUpdate=new List<MW_Project__c>();
        List<Project_Team_Member__c> projectTeamList=new List<Project_Team_Member__c>();
        List<Project_Time_Card__c> projectTimeCardList=new List<Project_Time_Card__c>();
        
              //Create A Acocunt records for TestBuilder      
             for(Integer i=0;i<10;i++){

                accObj = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
                accObj.BillingCountryCode = 'US';
                accObj.BillingCountry = 'United States';
                accObj.BillingStateCode = 'NY';
                accObj.BillingState = 'New York';

                accNLLst.add(accObj);
            }

            insert accNLLst;
            System.AssertEquals(accNLLst.size(),10);
            //create Contact record from TestDataBuilder.
            for(Integer i=0;i<10;i++){

                Contact contNL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accNLLst[i].id);
                contNL.MailingCity ='Ningbo';
                contNL.MailingCountry = 'India';
                contNL.MailingCountryCode = 'IN';
                contNL.MailingPostalCode ='400012';
                contNL.MailingState = 'Gujarat';
                contNL.MailingStateCode ='GJ';
                contNL.MailingStreet = 'dgfd';
                contNL.County_Local__c = 'xyz';
                contNL.email = 'bob@gmail.com';

                contNLLst.add(contNL);

            }

            insert contNLLst;
            System.AssertEquals(contNLLst.size(),10);
            
             List<MW_Project__c> recList = new List<MW_Project__c>();

            User usrObj=TestDataBuilder.buildTestUser(4);
            insert usrObj;
            //create Project record from TestDataBuilder.
            for(Integer i = 0; i < 10; i++){

                MW_Project__c rec = TestDataBuilder.buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contNLLst[i].Id);
                rec.Office__c = 'ES - Customer Support';
                rec.requester__C=usrObj.id;
                recList.add(rec);

            }
            insert recList;
        
        
        User teamMember=TestDataBuilder.buildTestUser(3);
        teamMember.Functional_Role__c=ApplicationEngineerFRole;
        insert teamMember;

        User timeCardResource=TestDataBuilder.buildTestUser(9);
        insert timeCardResource;


        for(Integer i=0;i<10;i++){
            MW_Project__c proObj=recList[i];
            Project_Team_Member__c proTeamMemberObj =TestDataBuilder.buildTestProjectTeamMember(teamMember.id,recList[i].id);
            projectTeamList.add(proTeamMemberObj);
                        
            Project_Time_Card__c proTimeCardObj=TestDataBuilder.buildTestProjectTimeCard(teamMember.id,recList[i].id);
            proTimeCardObj.Hours__c=123;
            proTimeCardObj.Week_Date__c = System.today();
            
            Project_Time_Card__c proTimeCardObj1=TestDataBuilder.buildTestProjectTimeCard(UserInfo.getUserId(),recList[i].id);
            proTimeCardObj.Hours__c=123;
            proObj.Project_Status__c='Accepted';
            proTimeCardObj1.Week_Date__c = System.today();
            
            projectTimeCardList.add(proTimeCardObj);
            projectTimeCardList.add(proTimeCardObj1);
            projectListToUpdate.add(proObj);
            System.assert(projectTimeCardList[i].Hours__c > 0);
        }
        insert projectTeamList;
        insert projectTimeCardList;
        
         
            for(MW_Project__c objMWProject: recList)
            {
                objMWProject.Last_Project_Review_Date__c = system.today();
            }
        
            Test.startTest();
            update recList;
            System.AssertEquals(recList.size(),10);
            Test.stopTest();
        
      } 

    
  }