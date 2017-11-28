/**
 *@author Original: Haigang Wu - Mathworks
 *@date Original: 24 Feb 2016
 *@description This is Controller class for LaunchRecord.Page
 *             
 */
@isTest
public class LaunchRecordControllerTest {
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

    public static TestMethod void testBlankCdsId(){
        Pagereference pref = Page.LaunchRecord;
        Test.setCurrentPage(pref);
        LaunchRecordController ctlr = new LaunchRecordController ();
        ctlr.redirect ();

		List<ApexPages.Message> msgs = ApexPages.getMessages();
		for (ApexPages.Message msg : msgs) {
			system.assertEquals(system.label.Commerce_CDS_Id_Not_Attached, msg.getDetail());
		}
    }

    public static TestMethod void testNoRecord(){
        Pagereference pref = Page.LaunchRecord;
        pref.getParameters().put('opportunityId', '4353dfy45dfg');
        Test.setCurrentPage(pref);
        LaunchRecordController ctlr = new LaunchRecordController ();
        ctlr.redirect ();

		List<ApexPages.Message> msgs = ApexPages.getMessages();
		for (ApexPages.Message msg : msgs) {
			system.assertEquals(system.label.Commerce_CDS_Record_Not_Found, msg.getDetail());
		}
    }

    public static TestMethod void testAccount(){
        custsettbuild.buildBypassTriggerSettings();
	    Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
        acc.CDS_Account_Id__c = '4353dfy45dfg';
        insert acc;
        Pagereference pref = Page.LaunchRecord;
        pref.getParameters().put('CDSAccountId', '4353dfy45dfg');
        Test.setCurrentPage(pref);
        LaunchRecordController ctlr = new LaunchRecordController ();

        system.assertEquals(ctlr.redirect().getUrl(), '/ui/support/servicedesk/ServiceDeskPage#/' + acc.id);
    }

    public static TestMethod void testContact(){
        custsettbuild.buildBypassTriggerSettings();
        Contact con = TestDataBuilder.buildTestContact(0,UserInfo.getUserId(),null);
        con.CDS_Contact_Id__c = '4353dfy45dfg';
        insert con;
        Pagereference pref = Page.LaunchRecord;
        pref.getParameters().put('CDSContactId', '4353dfy45dfg');
        Test.setCurrentPage(pref);
        LaunchRecordController ctlr = new LaunchRecordController ();

        system.assertEquals(ctlr.redirect().getUrl(), '/ui/support/servicedesk/ServiceDeskPage#/' + con.id);
    }

    public static TestMethod void testOpportunity(){
        custsettbuild.buildBypassTriggerSettings();
        custsettbuild.buildGenSetting();
        
	    Account acc = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
        insert acc;
        Opportunity opp = TestDataBuilder.buildTestOpportunity(0);
        opp.AccountId = acc.Id;
        insert opp;
        Pagereference pref = Page.LaunchRecord;
        pref.getParameters().put('opportunityId', opp.id);
        Test.setCurrentPage(pref);
        LaunchRecordController ctlr = new LaunchRecordController ();

        system.assertEquals(ctlr.redirect().getUrl(), '/ui/support/servicedesk/ServiceDeskPage#/' + opp.id);
    }

}