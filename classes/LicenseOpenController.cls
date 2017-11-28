/**
*@Author Original: Faina Gorelik, Last Modified : Faina Gorelik AtTask 1675534
*@date Original: 11 Sept 2015, Last Modified Date : 09/27/2016
*@Description: This method will be called from the LicenseOpen page action to validate Contact and Account CDS ids, modified code to pass MW Account Id to the LicenseOpen Page
*@return: PageReference | If null, it will stay on the LicenseOpen page with the Errors from validation.
*                       | else it will redirect to new License App URL
*/

public with sharing class LicenseOpenController {
private Id conId;
    //Constructor to get Contact Id from url parameter
    public LicenseOpenController(ApexPages.StandardController controller){
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
            this.conId = (Id)ApexPages.currentPage().getParameters().get('id');  
        }
    }  
    public PageReference redirectToLicenseApp() {
        Logger.push('redirectToLicenseApp','LicenseOpenController');
        if(conId != null){
            LicenseIntegrationSetting__c settings = LicenseIntegrationSetting__c.getInstance();
           Contact conRec;
           
            // fg 
              conRec = [SELECT Id,MathWorks_Account_ID__c 
                              FROM Contact WHERE Id = : conId];
  				
               if ( conRec.MathWorks_Account_ID__c != null && conRec.MathWorks_Account_ID__c !=''){                  
                        Logger.debug(conRec.MathWorks_Account_ID__c);
                        PageReference reference=new PageReference(settings.URLForNonProfLicenses__c + conRec.MathWorks_Account_ID__c);
                   		reference.setRedirect(true);
                        Logger.pop();
                        return reference;
                }
                else{
                    
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+ System.Label.ConLicMsgNoMWAccntId));
                }
         
        }
        
        
        Logger.pop();
        return null;
    }
    
    public PageReference redirectAccountToLicenseApp() {
        Logger.push('redirectAccountToLicenseApp','LicenseOpenController');
        if(conId != null){
            LicenseIntegrationSetting__c settings = LicenseIntegrationSetting__c.getInstance();
            //Integer counter = 0;
           //Contact conRec;
           Account accRec;
            
            accRec = [SELECT Id,CDS_Account_Id__c 
                              FROM Account WHERE Id = : conId];
  
               if ( accRec.CDS_Account_Id__c != null && accRec.CDS_Account_Id__c !=''){
                        Logger.debug(accRec.CDS_Account_Id__c);
                        //HW 1762386 start
                        PageReference reference=new PageReference(settings.URLForNonProfLicensesAccount__c + accRec.CDS_Account_Id__c);
                        //HW 1762386 end
                        //licenseeAccountId:C22871509 
                        reference.setRedirect(true);
                        Logger.pop();
                        return reference;
                }
                else{
                     Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+System.Label.AccounttLicMsgNoCDSID));
                }
         
        }
        
        
        Logger.pop();
        return null;
    }

}