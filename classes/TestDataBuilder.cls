/**
 * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
 * @date Original: 07 May 2013, Last Modified: 13 June 2016
 * @description Global utility class that contains different record builders for unit testing.
 * @revision:Archana Suryawanshi|13 June 2016| chnaged method buildPortalTestUser to get Custom HVCP User 
 */ 
public with sharing class TestDataBuilder {  

    static  Map<String,schema.Recordtypeinfo> leadRtmap = Schema.SObjectType.Lead.getRecordTypeInfosByName();
  
    //Create new instance of CustomSettingsBuilder
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 07 May 2013
     * @description Helper method to create a test user record(can be called iteratively to create more than 1 user.)
     * @param i An integer that will serve as index for iteration (bulk).
     */
    public static User buildTestUser(Integer i){
        Profile p = [select pf.id from profile pf WHERE pf.name= 'System Administrator' limit 1];
        User usr = new User();
        usr.emailencodingkey    = 'UTF-8';
        usr.languagelocalekey   = 'en_US';
        usr.localesidkey        = 'en_US';
        usr.timezonesidkey      = 'America/Los_Angeles'; 
        usr.ProfileId = p.Id;
        usr.alias           = 'TUser' + i;
        usr.email           = 'TUser' + i + '@mathworks.com';
        usr.lastname        = 'TUser' + i;
        usr.username        = 'TUser' + i + '@mathworks.com';
        usr.Area__c         = 'ES - Customer Support';
        usr.Portal_User_Status__c = 'Student';
        usr.Student__c = false;
        usr.Country_Code__c = 'ph';
        usr.Is_Test_User__c = true;
        return usr; 
    }
    
    
     /**
     * @author Original: Shweta Shanbhag - Mathworks  
     * @date Original: 13 June 2016
     * @description Helper method to create a test portal user record
     * @param i An integer that will serve as index for iteration (bulk).
     */
    public static User buildPortalTestUser(Integer i){
        Profile p = [select pf.id from profile pf WHERE pf.name= 'Custom HVCP User' limit 1];
        User portalusr = new User();
        portalusr.emailencodingkey    = 'UTF-8';
        portalusr.languagelocalekey   = 'en_US';
        portalusr.localesidkey        = 'en_US';
        portalusr.timezonesidkey      = 'America/Los_Angeles'; 
        portalusr.ProfileId = p.Id;
        portalusr.alias           = 'TUser' + i;
        portalusr.email           = 'TUser' + i + '@test.com';
        portalusr.lastname        = 'TUser' + i;
        portalusr.username        = 'TUser' + i + '@mwprofile.com';
        portalusr.Portal_User_Status__c = 'Student';
        portalusr.Student__c = false;
        portalusr.Country_Code__c = 'US';
        portalusr.Is_Test_User__c = true;
        return portalusr; 
    }
    
    /**
     * @author Original: Original: Andre Calimlim  
     * @date Original: 15 Aug 2014
     * @description Helper method to create a test queue record and Group
     * @param sObj a String that will have the sObject for the Queue.
     */
    public static Group buildTestGroup(String sObj){
        User u = buildTestUser(1);
        insert u;
        Group grp;
        System.runAs(u){
            grp = new Group(name = 'TestGroup', type = 'Queue');
            insert grp;
            QueueSobject q = new QueueSobject(QueueID = grp.id, SobjectType = sObj);
            insert q;
            
        }
        return grp;
    }
    
    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 07 May 2013
     * @description Helper method to create a test account record(can be called iteratively to create more than 1 user.)
     * @param i An integer that will serve as index for iteration (bulk).
     * @param OwnerId User's Id whose creating the Account
     */
    public static Account buildTestAccount(Integer i, id OwnerId){
        Account acc = new Account();
        acc.Name = 'TAccount' + i;
        acc.ownerId     = ownerId;
        acc.BillingStreet = 'test street';
        acc.BillingCity = 'test city';
        acc.BillingCountryCode = 'US';
        acc.BillingCountry = 'United States';
        acc.BillingStateCode = 'NY';
        acc.BillingState = 'New York';
        acc.BillingPostalCode = '00000';
        return acc;
    }

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 07 May 2013
     * @description Helper method to create a test contact record(can be called iteratively to create more than 1 user.)
     * @param i An integer that will serve as index for iteration (bulk).
     * @param AccId Account Id
     * @param OwnerId User's Id whose creating the Contact
     */
    public static Contact buildTestContact(Integer i, id OwnerId, id AccId){

        Contact con = new Contact();
        con.AccountId = AccId;
        con.OwnerId = OwnerId;
        con.LastName = 'TLastName' + i;
        con.FirstName = 'TFirstname' + i;
        con.MailingStreet = 'test street';
        con.MailingCity = 'test city';
        con.MailingCountryCode = 'US';
        con.MailingCountry = 'United States';
        con.MailingState='New York';
        con.MailingStateCode = 'NY';        
        con.MailingPostalCode = '00000';
        con.Email = 'test@test.com';
        con.MathWorks_Account_ID__c = '1234'+i;
        con.Country_Code__c = 'US';
        con.Siebel_Contact_Id__c = '12345'+i;
        con.Student__c = false;
        return con;

    }       

    /**
     * @author Original: Robbie Macatbag- Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Robbie Macatbag - Cloud Sherpas/Mathworks  
     * @date Original: 29 May 2013, Last Modified: 30 May 2013, Last Modified: 05 Jun 2013
     * @description Helper method to create a test Case record
     * @param status a String that can either be 'Open' or 'Spam'
     */
    public static Case buildTestCase(String status){
        Case newCase = new Case();
        newCase.Status = status;
        if(status == 'Open'){
            newCase.SubStatus__c= 'Waiting for Internal';
        }
        if(status == 'Closed'){
            newCase.SubStatus__c= 'Cancelled';
        }
        return newCase;
    }

    /**
     * @author Original: Robbie Macatbag- Cloud Sherpas/Mathworks  
     * @date Original: 29 May 2013
     * @description Helper method to create a test Email template record
     * @param tempName a String template name.
     */
    public static EmailTemplate buildTestEmailTemplate(String tempName){ 
        EmailTemplate emailTemp = new EmailTemplate();
        emailTemp.name = tempName;
        emailTemp.body = 'Email Template Body';
        emailTemp.Subject = 'Test Subject';
        return emailTemp;
    }

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 29 May 2013
     * @description Helper method to create a test product record(can be called iteratively to create more than 1 user.)
     * @param i An integer that will serve as index for iteration (bulk).
     */
    public static Product2 buildTestProduct(Integer i){
        Product2 prod2 = new Product2();
        prod2.Name = 'TProduct' + i;
        prod2.Product_Unique_Identifier__c = 'TUniqueID' + i;
        return prod2;
    }


    /**
     * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks  
     * @date Original: 05 Jun 2013
     * @description Helper method to create Task Record;
     * @param userId an id which defines the owner of the Task.
     * @param taskStatus a String that describes the the status of the task.(values can either be: 'Not Started', 'In Progress', 'Completed', 'Waiting on someone else')
     * @param taskType a String that describes the type of the task.(values can either be: 'Call - Inbound', 'Call - Outbound', 'Email', 'To Do', 'TS Opportunity – Sales', 'TS Opportunity – Training', 'TS Opportunity – Other', 'Escalation')
     * @param taskSubject a string that tells the subject of the task.
     */
    public static Task buildTestTask(Id userId, String taskStatus, String taskType, String taskSubject){
        Task newTask = new Task();
        newTask.OwnerId = userId;
        newTask.Status = taskStatus;
        newTask.Type = taskType;
        newTask.Subject = taskSubject;
        return newtask;
    }

    /**
     * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 11 June 2013
     * @description Helper method to create EmailMessage records
     * @param i An integer that will serve as index for iteration (bulk).
     * @param tskId Task Activity Id where Email is referenced to 
     * @param parentId Case Id where Email is referenced to
     * @param status Status of Email Message
     */
    public static EmailMessage buildTestEmailMessage(Integer i, Id tskId, Id parentId, String status){
        EmailMessage em = new EmailMessage();
        em.ActivityId = tskId;
        em.BccAddress = 'bcctest'+i+'@mathworks.com';
        em.CcAddress = 'cctest'+i+'@mathworks.com';
        em.ToAddress = 'totest'+i+'@mathworks.com';
        em.FromAddress = 'fromtest'+i+'@mathworks.com';
        em.Status = status;
        em.ParentId = parentId;
        em.TextBody = 'test';
        return em;
    }

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 25 July 2013, Last Modified: 29 July 2013
     * @description Helper method to create a test feedItem record(can be called iteratively to create more than 1 user.)
     * @param i An integer that will serve as index for iteration (bulk).
     * @param Id ParentId Parent Id of feedItem record
     */
    public static FeedItem buildTestFeedItem(Integer i, Id ParentID, String typ){
        FeedItem fi = new FeedItem();
        fi.Title = 'FeedItemTest'+i;
        fi.ParentId = ParentId;
        fi.Body = 'test body'+i;
        fi.Type = typ;
        return fi;
    }
/**
    * @author Original: Faina Gorelik
    * @date Original: 25 July 2016
    * description: This method will be used to create test record  for Territory_Publish_Rule__c custom object
 **/
          
/*public static Territory_Publish_Rule__c buildTerritoryPublishRule(integer i){
    Territory_Publish_Rule__c tpr = new Territory_Publish_Rule__c();
    tpr.Pending_Rule_Publish__c = false;
    tpr.Rule_Identifier__c =  'xyz';
    tpr.Rules_Last_Published_By__c = UserInfo.getUserId();
    tpr.Rules_Last_Published_On__c = DateTime.now();
    return tpr;  
}*/

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 09 October 2013, Last Modified: 17 October 2013
     * @description Helper method to create a test Document record
     * @param i An integer that will serve as index for iteration (bulk).
     **/
    public static Document buildTestDocument(Integer i){
        //Folder fold = [Select Id From Folder Where AccessType = 'Public' AND IsReadOnly = true limit 1];
        Document doc = new Document();
        doc.Name = 'Attachment' + i + '.txt';
        doc.FolderId = UserInfo.getUserId();//fold.Id;
        doc.ContentType = 'text/plain';
        doc.Body = Blob.valueof('test');
        return doc;
    }

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks , modified by Faina Gorelik 
     * @date Original: 09 October 2013, modified: 06 July 2017 AtTask 1725966 
     * @description Helper method to create a test Article Type FAQ record
     * @param i An integer that will serve as index for iteration (bulk).
     **/
    public static FAQ__kav buildTestFAQkav(Integer i){
        FAQ__kav faq = new FAQ__kav();
        faq.Title = 'test article' + i + DateTime.now().getTime();
        faq.UrlName = 'test-article'+i + DateTime.now().getTime();
        return faq;
    }

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 09 October 2013
     * @description Helper method to create a test Article Type FAQ DataCategorySelection record
     * @param parentID Parent Id of CategorySelection record
     * @param categorygroupName Data Category Group Name
     * @param categoryName Data Category Name
     */
    public static FAQ__DataCategorySelection buildTestFAQDataCategories(Id ParentID, String categorygroupName, String categoryName){
        FAQ__DataCategorySelection faqdc = new FAQ__DataCategorySelection();
        faqdc.ParentId = parentId;
        faqdc.DataCategoryGroupName = categorygroupName;
        faqdc.DataCategoryName = categoryName;
        return faqdc;
    }

    /**
     * @author Original: Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
     * @date Original: 21 October 2013
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     * @param reltype Release Type
     */
    public static Release__c buildTestRelease(Integer i,String reltype, Boolean showPortal){
        Release__c rel = new Release__c();
        rel.Name = 'release'+i;
        rel.Release_Type__c = reltype;
        rel.Show_in_Portal__c = showPortal;
        return rel;
    }

    /**
     * @author Original: Original: Divya Gawade - Cloud Sherpas/Mathworks  
     * @date Original: 4 June 2014
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     * @param recordTyName RecordTypeId
     */

    public static Lead buildTestLead(Integer i,String recordTyName ){
        Lead led = new Lead ();
        led.LastName = 'Bob'+i;
        led.Company ='CS';
        led.RecordTypeId =leadRtmap.get(recordTyName).getRecordTypeId();
        return led;
    } 

    /**
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 16 July  2014
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     */

    public static Opportunity buildTestOpportunity(Integer i){
        datetime TodayDate = System.now();
        date clsDate = Date.newInstance(TodayDate.year(),TodayDate.month(),TodayDate.day());

        Opportunity opp = new Opportunity();
        opp.Name = 'Bob'+i;
        opp.CloseDate =clsDate; 
        opp.StageName = 'Pending';

        return opp;
    } 
    
   //fg
    /**
     * @author Original: Faina Gorelik
     * @date Original: 03 March  2017
     * @description Helper method to create a test MW_Project__c record for non Oppty Support Purpose
     * @param i An integer that will serve as index for iteration (bulk).
     */

   public static MW_Project__c buildTestProjectNonOppty(Integer i, Id recTypeId, Id conId){

        MW_Project__c rec = new MW_Project__c(
                                RecordTypeId = recTypeId,
                                Project_Status__c = 'New',
                               Purpose__c ='Other Dept Support', 
                                Expected_Date_Time__c = System.now().addDays(2),
                                Outcome__c = 'Departmental Support',
            					Selling_Priorities__c ='None',
                                Is_decision_maker_involved__c = 'No',
                                Do_they_have_budget__c = 'Yes',
                                Application_of_Interest__c = 'Test Application Interest ' + i
                                );

        return rec;
    }  
   //  //fg 
    /**
     * @author Original: Andre Calimlim  
     * @date Original: 5 Aug  2014
     * @description Helper method to create a test MW_Project__c record
     * @param i An integer that will serve as index for iteration (bulk).
     */

   public static MW_Project__c buildTestProject(Integer i, Id recTypeId, Id conId){

        MW_Project__c rec = new MW_Project__c(
                                RecordTypeId = recTypeId,
                                Project_Status__c = 'New',
                               // Purpose__c = 'NPS Opp Supportm',
                               Purpose__c ='Opportunity Support', //fg
                                Expected_Date_Time__c = System.now().addDays(2),
                               // Outcome__c = 'Visit Customer - Technical Proof',// fg
                                Outcome__c = 'WebEx',
            					Selling_Priorities__c ='None',
                                Is_decision_maker_involved__c = 'No',
                                Do_they_have_budget__c = 'Yes',
                                //Primary_Customer_Contact__c = conId,
                                Application_of_Interest__c = 'Test Application Interest ' + i
                                );

        return rec;
    } 
  
    
    /**
     * @author Original: Original: Divya Gawade - Cloud Sherpas/Mathworks  
     * @date Original: 23 July  2014
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     */

    public static PricebookEntry buildTestPricebookEntry(Integer i){

        return new PricebookEntry();
    } 

    /**
     * @author Original: Original: Divya Gawade - Cloud Sherpas/Mathworks  
     * @date Original: 23 July  2014
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     */

    public static OpportunityLineItem buildTestOpportunityLineItem(Integer i){

       return new OpportunityLineItem();
    } 

    /*
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 25 July  2014
     * @description Helper method to create a test Territory2Model record
     * @param i An integer that will serve as index for iteration (bulk).

     */

    public static Territory2Model buildTestTerritory2Model(Integer i){
        Territory2Model model=new Territory2Model();
        model.Name='MW'+i;
        model.DeveloperName='MWTestdev';
        model.CurrencyIsoCode='USD'; 
        
        return model;
    } 
    
    /*
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 25 July  2014
     * @description Helper method to create a test Territory2 record
     * @param i An integer that will serve as index for iteration (bulk).

     */

    public static Territory2 buildTestTerritory2(Integer i){
    
        Territory2 t2=new Territory2();
        t2.name='TestTerritory'+i;
        t2.AccountAccessLevel='Edit';
        t2.CaseAccessLevel='None';
        t2.ContactAccessLevel='Edit';
        t2.CurrencyIsoCode='USD';
        t2.DeveloperName = 'TestTerritory'+i; // Added by jaspreet as this is required field on territory
        t2.Master_Territory_ID__c = 'TM-'+ i; //SS 8/17/16 - Added so that new test territory is created with a master terr id
        t2.Unique_Master_Territory__c = t2.Master_Territory_ID__c + t2.Territory2ModelId;//fg
        t2.Include_In_Sales_Hierarchy__c = true; //HW

        return t2;
    }
    
    /**
     * @author Original: Original: Divya Gawade - Cloud Sherpas/Mathworks  
     * @date Original: 29 July  2014
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     */

    public static Topic buildTestTopic(Integer i){

            return new Topic();
    } 
    
    /**
     * @author Original: Original: Divya Gawade - Cloud Sherpas/Mathworks  
     * @date Original: 29 July  2014
     * @description Helper method to create a test Release record
     * @param i An integer that will serve as index for iteration (bulk).
     */

    public static TopicAssignment buildTestTopicAssignment(Integer i){

      return new TopicAssignment();
    } 
    
     /**
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 25 August  2014
     * @description Helper method to create a test userterritory2Association record
     * @param user id and Territory2 id
     */

    public static userterritory2Association buildTestUserterritory2Association(id usrObjId,id t2ObjId){

        userterritory2Association usrAssObj = new userterritory2Association();
        usrAssObj.userid=usrObjId;
        usrAssObj.territory2id=t2ObjId;
        return usrAssObj;
    } 
    /**
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 15 Sep  2014
     * @description Helper method to create a test Campaign record
     * @param :integer index
     */

    public static Campaign buildTestCampaign(Integer index){

        Campaign campObj = new Campaign();
        campObj.name='TestCampaign'+index;
        campObj.Status='Active';
        return campObj;
    } 
    
    /**
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 15 Sep  2014
     * @description Helper method to create a test ProjectTeamMember record
     * @param :Id UserId,Id projectId
     */

    public static Project_Team_Member__c buildTestProjectTeamMember(Id UserId,Id projectId){

        Project_Team_Member__c teamObj = new Project_Team_Member__c();
        teamObj.Project__c=projectId;
        teamObj.Resource__c=UserId;
        return teamObj;
    } 
    
    /**
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 15 Sep  2014
     * @description Helper method to create a test TimeCard record
     * @param :Id UserId,Id projectId
     */

    public static Project_Time_Card__c buildTestProjectTimeCard(Id UserId,Id projectId){

        Project_Time_Card__c timeCardObj = new Project_Time_Card__c();
        timeCardObj.Project__c=projectId;
        timeCardObj.AE_PE__c=UserId;
        timeCardObj.Hours__c=8;
        return timeCardObj;
    } 
    
    /**
     * @author Original: Original: Archana Lohar - Cloud Sherpas/Mathworks  
     * @date Original: 15 Sep  2014
     * @description Helper method to create a test TimeCard record
     * @param :Id UserId,Id projectId
     */

    public static Event buildTestEvent(Id UserId,String Subject){

        Event eventObj = new Event();
        eventObj.OwnerId = UserId;
        eventObj.StartDateTime = System.Today(); 
        eventObj.EndDateTime =  System.Today()+1; 
        eventObj.Subject = Subject;
        eventObj.Description ='Test';
        return eventObj;
    } 
    
    /**
     * @author Original:  
     * @date Original: 16 Sept  2014
     * @description Helper method to create a test MW_Project__c record with Type = 'Project'
     * @param i An integer that will serve as index for iteration (bulk).
     */

    public static MW_Project__c buildTestProjectRef(Integer i, Id recTypeId, Id UserId){

        MW_Project__c p1 = new MW_Project__c(Project_Name__c = 'TestProject' + i,
                                             Project_Status__c = 'New',
                                             Technical_Resource_Group__c = 'Pilot Engineering',
                                             Product_Area__c = 'LTC',
                                             Expected_Date_Time__c = Date.Today(),
                                             Location_of_Request__c = 'TestLoc',
                                           //  Purpose__c = 'NPS Opp Support',
                                           	Purpose__c ='Opportunity Support', //fg
                                            // Outcome__c = 'WebEx - Technical Proof',
                                            Outcome__c = 'WebEx',// fg
                                             Project_Level__c = 'AE Project',
                                             Project_Strategic_Importance__c = 'Initial Succes',
                                             Is_decision_maker_involved__c = 'Yes',
                                             Do_they_have_budget__c = 'Yes',
                                             Competitors__c = 'Yes',
                                             //Exit_Strategy__c = 'Long Term Consulting', //Commented out by MPO for WF 1261388, sprint 1.2.2016
                                             //Is_Travel_Required__c = 'No',
                                             CurrencyIsoCode = 'USD',
                                             RecordTypeId = recTypeId,
                                             Requester__c = UserId,
                                             Selling_Priorities__c='None'
                                             );
        return p1;
    } 

     /**
       * author Original: Andre Calimlim
       * date Original: 5 Aug 2014
       * @param: numRec | accepts the number of data to create
       * @return: a collection of MW_Project__c records
       * description: This method will be used by testMethods to create Test Data
       */
  public static List<MW_Project__c> buildTestMWProject(Integer numRec, String taskCategory){
    
        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        custsettbuild.buildAddressLatinTranslation();
        
        Account acctL = buildTestAccount(1, userInfo.getUserId());
        insert acctL;
        //Create Contact
        Contact contL = buildTestContact(1,UserInfo.getUserId(),null);
        insert contL;
    
        //Create Opportunity
        Opportunity opp = buildTestOpportunity(1);
        opp.AccountId = acctL.Id;
        insert opp;
    
        //Create Activity
        Task ta = buildTestTask(UserInfo.getUserId(), 'Not Started', 'To Do', 'Sales');
        ta.category__c = taskCategory;
        ta.whatId = opp.Id;
        insert ta;
    
        List<MW_Project__c> recList = new List<MW_Project__c>();
        for(Integer i = 0; i < numRec; i++){
          MW_Project__c rec = buildTestProject(i, Schema.SObjectType.MW_Project__c.getRecordTypeInfosByName().get('Sales Request').getRecordTypeId(), contL.Id);
          rec.Opportunity__c = opp.Id;
          recList.add(rec);
        }
        return recList;
      }
    /**
       * @author Original: Sagar Talele
       * @date Original: 26 dec 2014
       * @description: This method will be used  to create test data for Integration_Settings__c object
       */
    public static Integration_Settings__c  builIntegrationSettings(){
        Integration_Settings__c integrationSetting = new Integration_Settings__c();
        
        integrationSetting.name = 'Send Articles to MW Answers';
        integrationSetting.Username__c = 'test';
        integrationSetting.Password__c = 'testPassword';
        integrationSetting.Clientname__c = 'Salesforce';
        integrationSetting.Endpoint__c = 'https://sf-ext-dev2.mathworks.com/mwsbservice/KAProxy/service/KAProxy';
        integrationSetting.Timeout__c = 60000;
        return integrationSetting ;
          
        }
        
       /**
       * @author Original: Archana Lohar
       * @date Original: 4 Feb 2015
       * @description: This method will be used  to create OpportunityContactRole record
       */
        public static OpportunityContactRole  builOpportunityContactRole(Id contactId,Id OpportunityId){
        OpportunityContactRole roleObj = new OpportunityContactRole();
        
        roleObj.contactid=contactId;
        roleObj.OpportunityId=OpportunityId;
        roleObj.role='Business User';
        return roleObj ;
          
        } 
       /**
       * @author Original: Sagar Talele
       * @date Original: 1 April 2015
       * @description: This method will be used  to create OpportunityProject record
       */
       public static Opportunity_Projects__c buildOpportunityProject(Id projectId,Id oppId){
       Opportunity_Projects__c oppProjObj = new  Opportunity_Projects__c();
       oppProjObj.Project__c = projectId;
       oppProjObj.Opportunity__c = oppId;
       return oppProjObj;
       }
  
       /**
       * @author Original: Archana Lohar
       * @date Original: 20 Jan 2016
       * @description: This method will be used  to create Territory Assignment Rule record
       */
       
           public static Territory_Assignment_Rule__c buildTerritoryAssignmentRule(Id TerritoryShadowObjId){
           Territory_Assignment_Rule__c assignmentRuleObj = new  Territory_Assignment_Rule__c();
           assignmentRuleObj.Territory__c = TerritoryShadowObjId;
           return assignmentRuleObj;
           }
       
       /**
       * @author Original: Archana Lohar
       * @date Original: 20 Jan 2016
       * @description: This method will be used  to create Territory Rule Criteria record
       */
       
        public static Territory_Rule_Criteria__c buildTerritoryRuleCriteria(String name,Id TerritoryAssignmentRuleId ){
            Territory_Rule_Criteria__c territoryCriteriaObj = new  Territory_Rule_Criteria__c();
            
            territoryCriteriaObj.Territory_Assignment_Rule__c = TerritoryAssignmentRuleId;
            territoryCriteriaObj.Score__c = 100;
            territoryCriteriaObj.Required__c ='Always';
            
            return territoryCriteriaObj;
        }
        
         /**
       * @author Original: Abhay Verma
       * @date Original: 2 March 2016
       * @description: This method will be used  to create Territory Rule Criteria Value record
       */
      
       public static Territory_Rule_Criteria_Value__c buildTerritoryRuleCriteriaValue(Id territoryRuleCriteriaId){
           Territory_Rule_Criteria_Value__c territoryCriteriaValueObj = new Territory_Rule_Criteria_Value__c();
           territoryCriteriaValueObj.Territory_Rule_Criteria__c = territoryRuleCriteriaId;
           territoryCriteriaValueObj.Score__c = 10;
           return territoryCriteriaValueObj;
       }
       
      /***************************************************************************************
        * author Original: Neha Mahajan - Cloud Sherpas/Mathworks, Last Modified:
        * date Original: 03 March 2016, Last Modified: 
        * description This method will be used  to create OpportunityCompetitor record
        ****************************************************************************************/
        public static OpportunityCompetitor buildTestOpportunityCompetitor(Integer i, id OpportunityId){
        
        OpportunityCompetitor oppCompetitor = new OpportunityCompetitor();
        oppCompetitor.CompetitorName='Bob'+i;
        oppCompetitor.OpportunityId=OpportunityId;
        return oppCompetitor;
        } 
        
       /***************************************************************************************
        * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele 
        * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
        * description This method will be used  to create ObjectTerritory2Association record
        ****************************************************************************************/
        public static ObjectTerritory2Association  buildObjectTerritory2Association(Id territoryId, Id objId){
            ObjectTerritory2Association objT2A = new ObjectTerritory2Association();
            objT2A.AssociationCause = 'Territory2Manual';
            objT2A.ObjectId = objId;
            objT2A.Territory2Id = territoryId;
            return objT2A;
        }
        
          
 /***************************************************************************************
        * author Original: Shweta Shanbhag - MathWorks 
        * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
        * description This method will be used  to create ObjectTerritory2Association record
        ****************************************************************************************/
        public static Get_Feedback__c  buildgetfeedback(Integer i){
            Get_Feedback__c objGetFB = new Get_Feedback__c(); 
            objGetFB.name = 'GetFB' + i;
            return objGetFB;
        }          
    
     
}