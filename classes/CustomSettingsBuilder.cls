/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade
* @date Original: 07 May 2013, Last Modified: 1 August 2014
* @description Global utility class that contains different record builders for custom setting.
* @revision: 18 June 2014  | Archana Lohar | Added Account object in bypass.Trigger_Objects__c at buildBypassTriggerSettings method
* @revision: 30 July 2014  | Divya Gawade  | Added method to recreate Address latin translation custom settings.
* @revision: 1 August 2014 | Divya Gawade  | Added method to recreate Country custom settings.
* @revision: 30 Oct 2014   | Sagar Talele  | added field in general setting.
* @revision: 18 Sept 2017  | Dennis Atwood | added data for CommerceQuoteURL__c in buildQuoteIntegrationSettings()
*/
public class CustomSettingsBuilder {
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013
    * @description Helper method to return Profile Id of MW Custom Service Standard User
    */
    public String getUtilMWCustomerServiceStdUserProfileId(){
        Profile p = [select pf.id from profile pf WHERE pf.name= 'MW Customer Service Standard User' limit 1];
        return p.Id;
    } 
    
   
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 09 Sept 2013
    * @description Helper method to return Profile Id of Overage High Volume Customer Portal User
    */
    public String getUtilOverageHighVolumCustomerPortalUserProfileId(){
        Profile p = [select pf.id from profile pf WHERE pf.name= 'Custom HVCP User' limit 1];
        return p.Id;
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Andy Ognenoff (Cloud Sherpas)
    * @date Original: 29 May 2013, Last Modified: 21 Nov 2014
    * @description Helper method to re-create Integration 'On Support' Setting
    */
    public void buildIntegrationSetting(){
        //Custom Object treated as Custom Setting - Set Defaults
        Integration_Settings__c intSet = new Integration_Settings__c();
        intSet.Name = 'On Support';
        intSet.Username__c = 'Salesforce';
        intSet.Password__c = 'XXX';
        intSet.Clientname__c = 'Salesforce';
        intSet.Timeout__c = 10000;
        intSet.Endpoint__c = 'https://sf-ext-dev3.mathworks.com/';
        intSet.CA_Cert__c = 'MW_SF_SALESDEV_CLIENT';
        intSet.Caller_ID__c = 'SFDC';
        intSet.Retry_Attempts__c = 5;
        intSet.Locale__c = 'en_US';
        intSet.Token__c = '2fe432a2e8ca0b5438387ca0a72bb';
        intSet.Batch_Size__c = 9;
        insert intSet;
        
        Integration_Settings__c intSet2 = new Integration_Settings__c();
        intSet2.Name = 'Send Articles to MW Answers';
        intSet2.Username__c = 'Salesforce';
        intSet2.Password__c = 'XXX';
        intSet2.Clientname__c = 'Salesforce';
        intSet2.Timeout__c = 60000;
        intSet2.Endpoint__c = 'https://sf-ext-dev3.mathworks.com/mwsbservice/KAProxy/service/KAProxy';
        intSet2.CA_Cert__c = 'MW_SF_SALESDEV_CLIENT';
        intSet2.Caller_ID__c = 'SFDC';
        intSet2.Retry_Attempts__c = 5;
        intSet2.Locale__c = 'en_US';
        intSet2.Token__c = '2fe432a2e8ca0b5438387ca0a72bb';
        intSet2.Batch_Size__c = 9;
        insert intSet2;
        
        Integration_Settings__c intSet3 = new Integration_Settings__c();
        intSet3.Name = 'MW Integrations';
        intSet3.Username__c = 'Salesforce';
        intSet3.Password__c = 'XXX';
        intSet3.Clientname__c = 'Salesforce';
        intSet3.Timeout__c = 60000;
        intSet3.Endpoint__c = 'https://sf-ext-dev3.mathworks.com/';
        intSet3.CA_Cert__c = 'MW_SF_SALESDEV_CLIENT';
        intSet3.Caller_ID__c = 'SFDC';
        intset3.Retry_Attempts__c = 5;
        intSet3.Locale__c = 'en_US';
        intSet3.Token__c = '2fe432a2e8ca0b5438387ca0a72bb';
        intSet3.Batch_Size__c = 9;
        insert intSet3;
        
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified by: Andre Calimlim
    * @date Original: 06 June 2013, Last Modified: 7 Aug 2014, 11 July 2016
    * @description Helper method to re-create General Setting
    */
    public void buildGenSetting(){
        List<General_Settings__c> genSettings = new List<General_Settings__c>([SELECT Id FROM General_Settings__c WHERE SetupOwnerId =: UserInfo.getOrganizationId()]);
            General_Settings__c getSet = new General_Settings__c();
            if(genSettings != null && !genSettings.IsEmpty()){
                getSet.Id = genSettings[0].Id;
            }            
            getSet.ACE_Url__c = 'http://mathworks.com';
            getSet.Escalate_To_Dev_Email__c = 'devsupp@mathworks.com';
            getSet.SetupOwnerId = UserInfo.getOrganizationId();
            getSet.EmailRoutingRule_Current_ResponseTo__c = 'Response_to_PROD__c';
            getSet.Opportunity_Close_Date__c = Date.valueof('2099-01-01');
            getSet.CDSBaseUrl__c='https://sf-ext-dev3.mathworks.com/customerDataStoreWS/rest/v2/';
            getSet.RegEx_Latin__c='^[\u0000-\u04FF]+';
            User usrObj=TestDataBuilder.buildTestUser(0);
            getSet.Default_Opportunity_Owner__c=usrObj.alias;
            //getSet.Default_Opportunity_Owner__c='mwsadmin';
            getSet.RTToIncludeAddingProjTeamMemberOnInsert__c='Marketing Request,Sales Request';
            getSet.Batch_Size_For_Territory2Trigger__c = '2000';
            getSet.Batch_Schedule_Time_Territory2Trigge__c = '15';
            getSet.Bypass_Assignment_Of_Account_To_Territor__c = false;
            getSet.CaseDeleteOverride_Excluded_Profile_1__c = 'MathWorks Data Management';
            getSet.CaseDeleteOverride_Excluded_Profile_2__c = 'System Administrator';
            getSet.CDS_IsChanged_Interval__c = 0.0003472220;
            getSet.Current_Domain__c = 'https://mathworks--salesdev.cs15.my.salesforce.com/';
            getSet.Emailaddress_Territory2Dml__c = ' sfdcsupport@mathworks.com';
            getSet.HideCheckBoxForDoNotCreateActivity__c = true;
            getSet.HideCheckBoxForSendEmailNotification__c = true;
            getSet.HideOpportunityOwnerSearchBox__c = true;
            getSet.Open_Preference_Center__c = 'https://go2.mathworks.com/mwint00qe000000431aheay';
            getSet.ORC_Url__c = 'http://inside-apps-dev3.mathworks.com/orclookups/contactDetails.do';
            getSet.RegEx_To_Check_ID__c ='[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ;
            getSet.Research_Team_Owner__c ='mwsadmin';
            getSet.OnSupportURL__c = 'https://sf-ext-msg-dev3.mathworks.com/onsupportws/v1/licenses/';
            upsert getSet;
     
    }
    
    /**
    * @author Original: Robbie Macatbag- Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 29 May 2013, Last Modified: 30 September 2013
    * @description Helper method to create records on Forwarding Rule custom setting
    */
    public void buildTestForwardRule(){
        List<Forwarding_Rule__c> fRList = new List<Forwarding_Rule__c>();
        //Create test mathworks office record
        Forwarding_Rule__c fR = new Forwarding_Rule__c();
        fR.name = 'ad';
        fR.Forwarding_Email_Address__c = 'dvessopo@mathworks.com';
        fR.Distributor_Name__c = 'Distributor Name';
        fR.Dommain_Country_Code__c = 'ad';
        fR.Case_Area_Country_Code__c = 'ES';
        fr.MathWorks_Office__c = true;
        fRList.add(fR);
        
        //Create test non mathworks office record
       Forwarding_Rule__c fR2 = new Forwarding_Rule__c();
        fR2.name = 'ph';
        fR2.Forwarding_Email_Address__c = 'test@test.ph';
        fR2.Distributor_Name__c = 'PH Distributor Name';
        fR2.Dommain_Country_Code__c = 'ph';
        fR2.MathWorks_Office__c = false;
        fRList.add(fR2);
        
        insert fRList;
    }
    
    /**
    * @author Original: Robbie Macatbag- Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 29 May 2013, Last Modified: 30 September 2013
    * @description Helper method to create records on Email Routing Rules custom setting
    */
    public void buildTestRoutingRule(){
        //list <EmailServicesAddress> emailservlist = getEmailServicesAddress();
        list <Email_Routing_Rules__c> rRuleList = new list <Email_Routing_Rules__c>();
        //Create Test Support record
        Email_Routing_Rules__c rRule0 = new Email_Routing_Rules__c();
        rRule0.name = 'support@mathworks.com';
        rRule0.Area_on_SR__c = 'Natick - Technical Support';
        rRule0.Response_to_DEV_email__c = 'devsupp@mathworks.com';
        rRule0.Response_to_PROD__c = 'support@mathworks.com';
        rRule0.Response_to_TEST_email__c ='testsupp@mathworks.com';
        rRule0.Sub_Area_on_SR__c = 'Test subArea';
        rRule0.Email_Service_Address__c = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        rRule0.Generic_Email__c = true;
        rRuleList.add(rRule0);
        
        //Create Test Support UK record
        Email_Routing_Rules__c rRule0a = new Email_Routing_Rules__c();
        rRule0a.name = 'support@mathworks.co.kr';
        rRule0a.Area_on_SR__c = 'KR - Technical Support';
        rRule0a.Response_to_DEV_email__c = 'devsupp@mathworks.com';
        rRule0a.Response_to_PROD__c = 'support@mathworks.co.kr';
        rRule0a.Response_to_TEST_email__c ='testsupp@mathworks.com';
        rRule0a.Sub_Area_on_SR__c = 'Test subArea';
        rRule0a.Email_Service_Address__c = 'emailhandler@9alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        rRule0a.Generic_Email__c = true;
        rRuleList.add(rRule0a);
        
        //Create Test Service record
        Email_Routing_Rules__c rRule1 = new Email_Routing_Rules__c();
        rRule1.name = 'service@mathworks.com';
        rRule1.Area_on_SR__c = 'Natick - Customer Support';
        rRule1.Response_to_DEV_email__c = 'devserv@mathworks.com';
        rRule1.Response_to_PROD__c = 'service@mathworks.com';
        rRule1.Response_to_TEST_email__c ='testserv@mathworks.com';
        rRule1.Sub_Area_on_SR__c = 'Test subArea';
        rRule1.Email_Service_Address__c = 'emailhandler@7xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';
        rRule1.Generic_Email__c = true;
        rRuleList.add(rRule1);
        
        //Create Test direct email service record
        Email_Routing_Rules__c rRule2 = new Email_Routing_Rules__c();
        rRule2.name = 'info@mathworks.com.au';
        rRule2.Area_on_SR__c = 'AU - Customer Support';
        rRule2.Response_to_DEV_email__c = 'dvauinfo@mathworks.com';
        rRule2.Response_to_PROD__c = 'info@mathworks.com.au';
        rRule2.Response_to_TEST_email__c ='qeauinfo@mathworks.com';
        rRule2.Sub_Area_on_SR__c = 'Test subArea';
        rRule2.Email_Service_Address__c = 'emailhandler@0xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';
        rRule2.Generic_Email__c = false;
        rRuleList.add(rRule2);
        
        //Create Test direct email service record
        Email_Routing_Rules__c rRule3 = new Email_Routing_Rules__c();
        rRule3.name = 'NotGeneric@mathworks.com.ok';
        rRule3.Area_on_SR__c = 'AU - Customer Support1';
        rRule3.Response_to_DEV_email__c = 'dvauinfo@mathworks1.com';
        rRule3.Response_to_PROD__c = 'info@mathworks1.com.au';
        rRule3.Response_to_TEST_email__c ='qeauinfo@mathworks1.com';
        rRule3.Sub_Area_on_SR__c = 'Test subArea';
        rRule3.Email_Service_Address__c = 'EmailToCase@NotGeneric.com';
        rRule3.Generic_Email__c = false;
        rRuleList.add(rRule3);
        
       
        insert rRuleList;
    }
    
   /*
    * @author Original:Faina Gorelik - MathWorks
    * @data Original: 29 July 2016, modified: 1 Nov 2017
    * description: Helper method to recreated Territory Management Custom Setting
    * */
        
    public void buildTerritoryManagementSettings(){
        Territory_Management_Settings__c tmsetting = new Territory_Management_Settings__c();
        tmsetting.Pending_Rules_Publish__c = false;
        tmsetting.Rules_Last_Published_By__c = UserInfo.getOrganizationId();
        tmsetting.Rules_Last_Published_On__c = datetime.now();
        tmsetting.Add_users_To_Territory_URL__c = '/setup/territory2/AddUsersToTerritory.apexp?territoryId=';
        tmsetting.Unique_Record__c = 'PRTOCDS'; 
        tmsetting.Criteria_Value_Page_Size__c='100';
        
        insert tmsetting;      
    }
    
     /*
    * @author Original:Faina Gorelik - MathWorks, Modified - Faina Gorelik
    * @data Original: 08 August 2016, 18 September 2016 - added Generate Master Territory Flag
    * description: Helper method to recreated Territory Settings Custom Setting
    * */
    public void buildTerritorySettings(){
       // Territory_Settings__c terrsetting = new Territory_Settings__c();
        List<Territory_Settings__c> terrsetting = new List<Territory_Settings__c>([SELECT ID FROM Territory_Settings__c where SetupOwnerId =: UserInfo.getOrganizationId()]);
        Territory_Settings__c getSet = new Territory_Settings__c();
            if(terrsetting != null && !terrsetting.isEmpty()){
                getSet.Id = terrsetting[0].Id;
            }
            getSet.SetupOwnerId = UserInfo.getOrganizationId();
            getSet.Assignment_Status__c = 'Pending Assignment - Retry';
            getSet.Character_Set__c = '0;1;2;3;4;5;6;7;8;9;A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z';
            getSet.Max_TA_Attempts__c = 5;
           // getSet.Territory_Assignment_Lookup_Field__c ='Siebel';
           	getSet.Territory_Assignment_Lookup_Field__c ='Master';//fg
            getSet.Territory_Master_Id_Length__c = 10;
            getSet.TA_Retry_Batch_Size__c = 100;
            getSet.Generate_Master_Territory_Flag__c = true;//fg
        	getSet.Publish_Territory_Assignment_URL__c = 'https://sf-ext-msg-dev.mathworks.com/bodiservice/v1/jobs/';
            upsert getSet;
   
    }

     /*
    * @author Original:Haigang Wu - MathWorks
    * @data Original: 15 August 2016
    * description: Helper method to recreated Territory Settings Custom Setting
    * */
    public void buildTerritorySettingsMaster(){
       // Territory_Settings__c terrsetting = new Territory_Settings__c();
        List<Territory_Settings__c> terrsetting = new List<Territory_Settings__c>([SELECT ID FROM Territory_Settings__c where SetupOwnerId =: UserInfo.getOrganizationId()]);
        Territory_Settings__c getSet = new Territory_Settings__c();
            if(terrsetting != null && !terrsetting.isEmpty()){
                getSet.Id = terrsetting[0].Id;
            }
            getSet.SetupOwnerId = UserInfo.getOrganizationId();
            getSet.Assignment_Status__c = 'Pending Assignment - Retry';
            getSet.Character_Set__c = '0;1;2;3;4;5;6;7;8;9;A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z';
            getSet.Max_TA_Attempts__c = 5;
            getSet.Territory_Assignment_Lookup_Field__c ='Master';
            getSet.Territory_Master_Id_Length__c = 10;
            getSet.TA_Retry_Batch_Size__c = 100;
            getSet.Generate_Master_Territory_Flag__c = true;//fg
            getSet.Publish_Territory_Assignment_URL__c = 'https://sf-ext-msg-dev.mathworks.com/bodiservice/v1/jobs/';
            upsert getSet;
   
    }

    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 08 October 2013
    * @description Helper method to recreate Send Articles Custom Setting
    */
    public void buildSendArticlesSettings(){
        Send_Article_Settings__c saset = new Send_Article_Settings__c();
        saset.SetupOwnerId = UserInfo.getOrganizationId();
        //saset.SchedulerName__c = 'Send Articles To MW Answers';
        saset.SchedulerName__c = 'Delete Cancelled Cases';
        saset.Last_Run_Status__c ='No articles to be sent.';
        saset.Last_Scheduled_Run__c = datetime.now();
        saset.Number_of_Articles_Sent__c = 0;
        insert saset;
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 21 October 2013
    * @description Helper method to recreate Country List Custom Setting
    */
    public void buildCountryList(){
        list <Country_List__c> CountryList = new list<Country_List__c>();
        CountryList.add(new Country_List__c(Name='Afghanistan', Country_Code__c = 'AF'));
        CountryList.add(new Country_List__c(Name='Albania', Country_Code__c = 'AL'));
        CountryList.add(new Country_List__c(Name='Algeria', Country_Code__c = 'DZ'));
        CountryList.add(new Country_List__c(Name='American Samoa', Country_Code__c = 'AS'));
        CountryList.add(new Country_List__c(Name='Andorra', Country_Code__c = 'AD'));
        CountryList.add(new Country_List__c(Name='Angola', Country_Code__c = 'AO'));
        CountryList.add(new Country_List__c(Name='Anguilla', Country_Code__c = 'AI'));
        CountryList.add(new Country_List__c(Name='Antarctica', Country_Code__c = 'AQ'));
        CountryList.add(new Country_List__c(Name='Antigua and Barbuda', Country_Code__c = 'AG'));
        CountryList.add(new Country_List__c(Name='Argentina', Country_Code__c = 'AR'));
        CountryList.add(new Country_List__c(Name='Armenia', Country_Code__c = 'AM'));
        CountryList.add(new Country_List__c(Name='Aruba', Country_Code__c = 'AW'));
        CountryList.add(new Country_List__c(Name='Australia', Country_Code__c = 'AU'));
        CountryList.add(new Country_List__c(Name='Austria', Country_Code__c = 'AT'));
        CountryList.add(new Country_List__c(Name='Azerbaijan', Country_Code__c = 'AZ'));
        CountryList.add(new Country_List__c(Name='Bahamas', Country_Code__c = 'BS'));
        CountryList.add(new Country_List__c(Name='Bahrain', Country_Code__c = 'BH'));
        CountryList.add(new Country_List__c(Name='Bangladesh', Country_Code__c = 'BD'));
        CountryList.add(new Country_List__c(Name='Barbados', Country_Code__c = 'BB'));
        CountryList.add(new Country_List__c(Name='Belarus', Country_Code__c = 'BY'));
        CountryList.add(new Country_List__c(Name='Belgium', Country_Code__c = 'BE'));
        CountryList.add(new Country_List__c(Name='India', Country_Code__c = 'IN'));
        CountryList.add(new Country_List__c(Name='China', Country_Code__c = 'CN'));
        
        insert CountryList;
        
    }
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 22 October 2013
    * @description Helper method to recreate Bypass Triggers custom setting
    */
    public void buildBypassTriggerSettings(){
            List<Bypass_Triggers__c> bypassSettings = new List<Bypass_Triggers__c>([SELECT Id FROM Bypass_Triggers__c WHERE SetupOwnerId =: UserInfo.getOrganizationId()]);
            Bypass_Triggers__c bypass = new Bypass_Triggers__c();
            if(bypassSettings != null && !bypassSettings.IsEmpty()){
                bypass.Id = bypassSettings[0].Id;
            } 
           
            bypass.SetupOwnerId = UserInfo.getOrganizationId();
            bypass.Trigger_Objects__c = 'Case;Account;Contact;FeedItem;EmailMessage;Task;Opportunity;Project;Territory2;e2a Email;UserTerritory2Association;TrainingLocation;Enrollment;Class;Course;EnterpriseTrainingAgreement;EnrollmentCode;EnrollmentRequest;ETAClass;TerritoryAssignmentRule;';
            bypass.Triggers_Disabled__c = false;
            upsert bypass;
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 31 October 2013
    * @description Helper method to recreate Email To Case Override custom setting
    */
    public void buildEmailToCaseOverrideSetting(){
        Email_To_Case_Override_Setting__c ecoset = new Email_To_Case_Override_Setting__c();
        ecoset.SetupOwnerId = UserInfo.getOrganizationId();
        ecoset.Forwarding_Email_Address__c = 'test@mathworks.com';
        ecoset.Forward_Change_Email_Request_Email__c = false;
        ecoset.Allow_Email_Logs__c= true;
        insert ecoset;
    }
    
    /**
    * @author Original: Divya Gawade - Cloud Sherpas/Mathworks
    * @date Original: 31 July 2013
    * @description : Helper method to recreate Address latin translation custom settings.
    */
    
    public void buildAddressLatinTranslation(){
        
        List<Address_Latin_Translation__c> addLatTransLst = new List<Address_Latin_Translation__c> ();
        
        Address_Latin_Translation__c addLatTrans1 = new Address_Latin_Translation__c();
        addLatTrans1.SetupOwnerId = UserInfo.getOrganizationId();
        addLatTrans1.Country__c = 'China';
        addLatTrans1.Country_Code__c = 'CN';
        addLatTrans1.State_Code__c = '11';
        addLatTrans1.State_Latin__c = 'Beijing';
        addLatTrans1.State_Local__c = '北京';
        addLatTrans1.Name = 'CN-11' ;
        addLatTransLst.add(addLatTrans1);
       
        Address_Latin_Translation__c addLatTrans2 = new Address_Latin_Translation__c();
        addLatTrans2.Country__c = 'Japan';
        addLatTrans2.Country_Code__c = 'JP';
        addLatTrans2.State_Code__c = '28';
        addLatTrans2.State_Latin__c = 'Hyogo';
        addLatTrans2.State_Local__c = '兵庫県';
        addLatTrans2.Name = 'JP-28' ;
        addLatTransLst.add(addLatTrans2);
      
        insert addLatTransLst;
    }
    
     /**
    * @author Original: Divya Gawade - Cloud Sherpas/Mathworks
    * @date Original: 31 July 2013
    * @description : Helper method to recreate Country custom settings.
    */
    
    public void buildcontSett(){
        
        List<Country_Settings__c> contSettLst = new List<Country_Settings__c> ();
        
        Country_Settings__c contSett1 = new Country_Settings__c();
        contSett1.SetupOwnerId = UserInfo.getOrganizationId();
        contSett1.Name = 'United States';
        contSett1.Country_Code__c = 'US';
        contSett1.Country_Name__c = 'United States';
        contSett1.Office_Name__c = 'MathWorks Natick';
        contSett1.CurrencyIsoCode = 'USD';
        contSettLst.add(contSett1);
        
        Country_Settings__c contSett2 = new Country_Settings__c();
        contSett2.SetupOwnerId = UserInfo.getOrganizationId();
        contSett2.Name = 'China';
        contSett2.Country_Code__c = 'CN';
        contSett2.Country_Name__c = 'China';
        contSett2.Office_Name__c = 'MathWorks China';
        contSett2.CurrencyIsoCode = 'CNY';
        contSettLst.add(contSett2);
        
        insert contSettLst;
    }
    
      /**
    * @author Original: Shweta Shanbhag
    * @date Original: 4 Feb 2015
    * @description : Helper method to recreate Areas Case Task Closure custom settings.
    */
    
    public void buildAreaTaskClosure(){
        
        List<Areas_Case_Task_Closure__c> AreaTaskCloseLst = new List<Areas_Case_Task_Closure__c> ();
        
        Areas_Case_Task_Closure__c AreaTaskClose1 = new Areas_Case_Task_Closure__c();
        AreaTaskClose1.Name = 'Customer Support';
        AreaTaskCloseLst.add(AreaTaskClose1);
        
         Areas_Case_Task_Closure__c AreaTaskClose2 = new Areas_Case_Task_Closure__c();
        AreaTaskClose2.Name = 'Technical Support';
        AreaTaskClose2.UserArea__c = 'Advanced Support';
         
        AreaTaskCloseLst.add(AreaTaskClose2);
        
        insert AreaTaskCloseLst;
    }
     /**
    * @author Original: - Cloud Sherpas/Mathworks
    * @date Original: 31 July 2013
    * @description : Helper method to recreate Country custom settings.
    */
    public void buildTimeCardControllerList(){
        List<TimeCardController__c> TimeCardControllerList=new List<TimeCardController__c>();
        TimeCardControllerList.add(new TimeCardController__c(Name='TestCustomSet_1',Dependent_Activity_Type_Values__c='Customer Interaction',Project_Purpose__c='Opportunity Support'));
        TimeCardControllerList.add(new TimeCardController__c(Name='TestCustomSet_2',Dependent_Activity_Type_Values__c='Customer Interaction',Project_Purpose__c='Opportunity Support'));
        insert TimeCardControllerList;
    }
    
    /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified by: Archana Lohar
    * @date Original: 3 Nov 2013, Last Modified:  3 Nov 2014
    * @description Helper method to re-create General Setting
    */
    public void buildTrialsIntegrationSetting(){
        TrialsIntegrationSetting__c getSet = new TrialsIntegrationSetting__c();
       
        getSet.PageSizeForPaginationToShowTrials__c='2';
        getSet.PaginationPageSizeContactRelatedList__c='1';
        getSet.TrialBaseUrl__c='https://sf-ext-dev3.mathworks.com/intactws/services/EntitlementService';
        getSet.AUIUrl__c='http://inside-apps-dev3.mathworks.com/aui/trial/create_trial?clear_session=true&contactId=';
      
        insert getSet; 
    }
    
    /**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified by:Sagar Talele
    * @date Original: 3 Nov 2014, Last Modified:  3 Nov 2014
    * @description Helper method to re-create Integration License Setting_
    */
    public void buildLicensesIntegrationSetting(){
        LicenseIntegrationSetting__c getSetLicense = new LicenseIntegrationSetting__c();
       
        getSetLicense.LicenseLimitPage__c = '10';
        getSetLicense.PageSizeForPaginationToShowLicenses__c='10';
        getSetLicense.LicenseMWUrl__c = 'https://sf-ext-dev3.mathworks.com/legacycommercews/v1/licenses';
        getSetLicense.LimitSizeOfProduct__c = '10';
        getSetLicense.URLForNonProfLicenses__c = 'http://inside-apps-dev3.mathworks.com/licensing/masterLicense/list?q=https://mathworks--dev.cs23.my.salesforce.com/s.gif';
        insert getSetLicense; 
    }
    
    /**
    * @author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified by:Divya Gawade
    * @date Original: 3 Nov 2013, Last Modified:  3 Nov 2014, 18 Sept 2017 Dennis Atwood (DMA)
    * @description Helper method to re-create Quote Integration Settings
    */
    public void buildQuoteIntegrationSettings (){
        QuoteIntegrationSettings__c getSetQuotes = new QuoteIntegrationSettings__c();        
        getSetQuotes.GQOQuoteBaseURL__c ='https://sf-ext-dev3.mathworks.com/legacycommercews/v1/quotes';
        getSetQuotes.Mathwork_Quote_Url__c ='http://inside-apps-dev3.mathworks.com/gqo/main?com_mathworks_internal_gqo_ControllerGQO_event=com.mathworks.internal.gqo.EventSiebel';
        getSetQuotes.PageSizeForPaginationToShowQuotes__c = '10';
        getSetQuotes.CommerceQuoteURL__c = 'http://inside-apps-dev3.mathworks.com/commerce/quote/';
        insert getSetQuotes ;
        
    }
  /**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified by:Sagar Talele, Faina Gorelik added record to the custom settings for the ProjectActivityType__c
    * @date Original: 12 Dec 2014, Last Modified:  3 Nov 2014, 09 Nov 2016
    * @description Helper method to re-create Project validation Rule Setting_
    */
    public void buildProjectValidationRuleSettings(){
        Project_Validation_Rule_Settings__c projectSetting = new Project_Validation_Rule_Settings__c ();
        projectSetting.Prevent_Deleting_Closed_Projects__c = true;
        projectSetting.ProjectActivityType__c = 'Traveling';//fg
        insert projectSetting;
    
    }
     /**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified by:Sagar Talele
    * @date Original: 23 Dec 2014, Last Modified:  23 Dec 2014
    * @description Helper method to re-create Remote Application Settings.
    */
    public void buildRemoteAppSettings(){
        RemoteAppSettings__c remoteSettings = new RemoteAppSettings__c();
        remoteSettings.name='articlestoanswers';
        remoteSettings.consumer_key__c = '3MVG9A2kN3Bn17ht6oliu3B7zuq2m8DT0.2DIagDwevR8AHVFERaH4LAhoeGaraRL.abdwB4fOgRG5b4YuIQt';
        remoteSettings.consumer_secret__c = '5008745838253737423';
        remoteSettings.endpoint_url__c = 'https://login.salesforce.com/services/oauth2/token';
        remoteSettings.password__c = 'm@thw0rks';
        remoteSettings.username__c = 'mwsf_integration@mathworks.com';
        insert remoteSettings;
        
    }
     /**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified by:Sagar Talele
    * @date Original: 26 Dec 2014, Last Modified:  23 Dec 2014
    * @description Helper method to re-create SendArticlesSession__c .
    */
    public void buildSendArticlesSession(){
    SendArticlesSession__c sendArticleSession = new SendArticlesSession__c();
    sendArticleSession.SetupOwnerId = UserInfo.getOrganizationId();
    sendArticleSession.SessionId__c = '00Di0000000Ha1u!ARAAQCFxfUpvvYpDPvBzPtQk9uj59YT3pdf65TG3dJTYrMJpIcSIcS5w7s6iabzIMhRJzwMFoGegyVdTkzyWuDRo.qzuzLOk';
    insert sendArticleSession;
    }
    
     /**
    * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified by:Archana Lohar
    * @date Original: 20 July 2015, Last Modified:11 March 2015
    * @description Helper method to re-create StateCodeList__c  .
    */
    public  void buildStateCodeList(){
    
        Country_Settings__c contSett3 = new Country_Settings__c();
        contSett3.SetupOwnerId = UserInfo.getOrganizationId();
        contSett3.Name = 'India';
        contSett3.Country_Code__c = 'IN';
        contSett3.Country_Name__c = 'India';
        contSett3.Office_Name__c = 'MathWorks India';
        contSett3.CurrencyIsoCode = 'INR';
        insert contSett3;
        
        List<StateCodeList__c> stateCodelst = new List<StateCodeList__c>();      
        
        StateCodeList__c  stateList = new StateCodeList__c ();
        stateList.name='India';
        stateList.StateCodesUnderCountryCode__c ='AN,AP,AR,AS,BR,CH,CT,DD,DL,DN,GA,GJ,HP,HR,JH,JK,KA,KL,LD,MH,ML,MN,MP,MZ,NL,OR,PB,PY,RJ,SK,TG,TN,TR,UL,UP,UT,WB';
        stateList.CountryCode__c ='IN';
        stateCodelst.add(stateList);
        
        StateCodeList__c  stateList1 = new StateCodeList__c ();
        stateList1.name='Italy';
        stateList1.StateCodesUnderCountryCode__c ='AG,AL,AN,AO,AP,AQ,AR,AT,AV,BA,BG,BI,BL,BN,BO,BR,BS,BT,BZ,CA,CB,CE,CH,CI,CL,CN,CO,CR,CS,CT,CZ,EN,FC,FE,FG,FI,FM,FR,GE,GO,GR,IM,IS,KR,LC,LE,LI,LO,LT,LU,MB,MC,ME,MI,MN,MO,MS,MT,NA,NO,NU,OG,OR,OT,PA,PC,PD,PE,PG,PI,PN,PO,PR,PT,PU,PV,PZ,RA,RC,RE,RG,RI,RM,RN,RO'; 
        stateList1.CountryCode__c ='IT';
        stateCodelst.add(stateList1);
        
        StateCodeList__c  stateList2 = new StateCodeList__c ();
        stateList2.name='Italy1';
        stateList2.StateCodesUnderCountryCode__c ='SA,SI,SO,SP,SR,SS,SV,TA,TE,TN,TO,TP,TR,TS,TV,UD,VA,VB,VC,VE,VI,VR,VS,VT,VV';
        stateList2.CountryCode__c ='IT';
        stateCodelst.add(stateList2);
        
        insert stateCodelst;
    }
    
    
}