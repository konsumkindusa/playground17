/**
 *@author Original: Andre Calimlim
 *@date Original: 6 Aug 2014
 *@description This is Controller class for AUIConnect
 *             
 */

public with sharing class AUIConnectController {
    private Id conId;
    //Constructor to get Contact Id from url parameter
    public AUIConnectController(ApexPages.StandardController controller){
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
            this.conId = (Id)ApexPages.currentPage().getParameters().get('id');  
        }
    }
    /**
     *@Author Original: Andre Calimlim 
     *@date Original: 6 Aug 2014
     *@Description: This method will be called from the AUIConnect page action to validate Contact and Account required field 
     *              to allow a call to the AUI Url set from the Custom Setting
     *@return: PageReference | If null, it will stay on the AUIConnect page with the Errors from validation.
     *                       | else it will redirect to AUI Url
     */ 
    public PageReference redirectToAUI() {
        Logger.push('redirectToAUI','AUIConnectController');
        if(conId != null){
            TrialsIntegrationSetting__c settings = TrialsIntegrationSetting__c.getInstance();
            Integer counter = 0;
            Contact conRec;
            
            conRec = [SELECT First_Name_Latin__c,FirstName,Last_Name_Latin__c,LastName,
                              CDS_Contact_id__c,accountid 
                              FROM Contact WHERE Id = : conId];// fg replace Siebel Contact Id
            
            if(conRec != null){
                Account accRec;
                
                accRec = [SELECT CDS_Account_Id__c,name,BillingCity,Account_City_Latin__c,
                                  Account_Name_Latin__c,Is_Individual_Account__c
                                  FROM Account WHERE Id = : conRec.AccountID];// fg replace Siebel Account Id
                
                if(accRec != null){
                    
                    if(EnforceValidationsUtility.hasAllRequired(conRec, accRec)){
                        Logger.debug(conRec.CDS_Contact_Id__c);//fg replace Siebel
                       // PageReference reference=new PageReference(settings.AUIUrl__c + conRec.Siebel_Contact_Id__c);
                       PageReference reference=new PageReference(settings.AUIUrl__c + conRec.CDS_Contact_id__c);//fg
                        reference.setRedirect(true);
                        Logger.pop();
                        return reference;
                    }

                    
                    
                }
                
                    
                    
                
            }
            
        }
        
        
        Logger.pop();
        return null;
    }
}