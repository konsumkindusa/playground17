/**
*@Author Original: Faina Gorelik, Last Modified : 
*@date Original: 10 Oct 2016, Last Modified Date : 
*@Description: This method will be called from the MasterLicenseOpen vf page action to validate if Master License id is not null on opportunity
*@return: PageReference | If null, it will stay on the LicenseOpen page with the Errors from validation.
*                       | else it will redirect to new Master License App URL
*/
Public with sharing class MasterLicenseOpenController{
    private Id optId;
    
    public MasterLicenseOpenController(ApexPages.StandardController controller){
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
            this.optId = (Id)ApexPages.currentPage().getParameters().get('id');  
        }
    }// end public MasterLicenseOpenConroller
    public PageReference redirectToMasterLicenseApp() {
        Logger.push('redirectToLicenseApp','LicenseOpenController');
        if(optId != null){
            LicenseIntegrationSetting__c settings = LicenseIntegrationSetting__c.getInstance();
            Opportunity optyRec;
            
            optyRec = [SELECT Id,Master_License_Id__c 
                       FROM Opportunity WHERE Id = : optId];
            if (!String.isBlank(optyRec.Master_License_Id__c)){                 
                PageReference reference=new PageReference(settings.UrlForShowingMasterLicense__c + optyRec.Master_License_Id__c+'#');
                reference.setRedirect(true);
                Logger.pop();
                return reference;
            }
            else{
                
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+ System.Label.OptLicenseMsgNoMasterLicenseId));
            }
        }
        
        Logger.pop();
        return null;
    }
}