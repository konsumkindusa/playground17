/**
 *@author Original: Haigang Wu - Mathworks
 *@date Original: 24 Feb 2016
 *@description This is Controller class for LaunchRecord.Page
 *             
 */

public with sharing class LaunchRecordController {
	// If the request sends in multiple parameters, the priority to handle is: Opportunity > Contact > Account
    private string oppId;
    private string conId;
    private string accId;
    //Constructor to get record Id from url parameter
    public LaunchRecordController(){
        if(ApexPages.currentPage().getParameters().get('opportunityId') != null && ApexPages.currentPage().getParameters().get('opportunityId') != ''){
            this.oppId = (string)ApexPages.currentPage().getParameters().get('opportunityId'); 
        }
        if(ApexPages.currentPage().getParameters().get('CDSContactId') != null && ApexPages.currentPage().getParameters().get('CDSContactId') != ''){
            this.conId = (string)ApexPages.currentPage().getParameters().get('CDSContactId');  
        }
        if(ApexPages.currentPage().getParameters().get('CDSAccountId') != null && ApexPages.currentPage().getParameters().get('CDSAccountId') != ''){
            this.accId = (string)ApexPages.currentPage().getParameters().get('CDSAccountId');  
        }
    }

    public PageReference redirect() {
    	PageReference pageRef;
        Logger.push('redirect','LaunchRecordController');
        
        if(oppId == null && conId == null && accId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.Commerce_CDS_Id_Not_Attached));
        	return null;
        }
        
        if (oppId != null) {
	        List<Opportunity> opRec = [SELECT Id FROM Opportunity WHERE id = : oppId];
	        if(! opRec.isEmpty() ){
	        	pageRef = new PageReference('/ui/support/servicedesk/ServiceDeskPage#/' + opRec[0].id);
	        	return pageRef;
	        }
        }
        
        if (conId != null) {
	        List<Contact> conRec = [SELECT Id FROM Contact WHERE CDS_Contact_Id__c = : conId];
	        if(! conRec.isEmpty() ){
	        	pageRef = new PageReference('/ui/support/servicedesk/ServiceDeskPage#/' + conRec[0].id);
	        	return pageRef;
	        }
        }

        if (accId != null) {
	        List<Account> accRec = [SELECT Id FROM Account WHERE CDS_Account_Id__c = : accId];
	        if(! accRec.isEmpty() ){
	        	pageRef = new PageReference('/ui/support/servicedesk/ServiceDeskPage#/' + accRec[0].id);
	        	return pageRef;
	        }
        }

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.Commerce_CDS_Record_Not_Found));
        Logger.pop();
    	return null;
    }
    
}