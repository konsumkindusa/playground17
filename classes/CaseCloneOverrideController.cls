/*
* @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 17 Jun 2013, Last Modified:  04 November 2013
* @description: Controller Class for CaseCloneOverride VF page. 
* @Revision:Archana Lohar|17 Nov 2014|Added try catch CancelClonedCase method and logger.debugs
*/

public with sharing class CaseCloneOverrideController {
    
    public Case c {get;set;}
    public String newURL {get;set;}
    public String newCaseEditURL {get; set;}
    
    
    /*
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 17 Jun 2013
    * @description: returns a String url for cloning a record with parameter "saveURL".
    */
    public CaseCloneOverrideController (ApexPages.StandardController controller) {
        
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        c = [SELECT id,RecordTypeId FROM Case WHERE id = :caseId  ];
        RecordType rt = [SELECT id,name FROM RecordType WHERE id = :c.RecordTypeId ];
        newURL ='/'+caseId+'/e?clone=1&saveURL=%2F/'+caseID+'&retURL=%2F'+caseId+'&nooverride=1&subStatus=In%20Progress&saveURL=%2fapex%2fCaseCloneSaveBypass%3Fid%3D'+caseId;
        if(rt.name=='Open Case'){
            newURL +='&rectypeID='+rt.id;
        }
    }
    
    
    /*
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 17 Jun 2013, Last Modified: 04 November 2013
    * @description: method used in CloneCaseSaveBypass VF page. Updates the clone case and redirects to clone case view page.
    */
    public PageReference UpdateCloneCase(){
        boolean forProcessing = ApexPages.currentPage().getParameters().containsKey('newid');
        if(forProcessing){
            id cloneCaseId = ApexPages.currentPage().getParameters().get('newid');
            id referenceCaseId = ApexPages.currentPage().getParameters().get('id');
            
            String queryStatementReferenceCase = CaseQueryStatement('id = \''+referenceCaseId+'\'');
            Case referenceCase = (Case)Database.query(queryStatementReferenceCase);
            
            String queryStatementCloneCase = CaseQueryStatement('id = \''+cloneCaseId+'\'');
            Case cloneCase = (Case)Database.query(queryStatementCloneCase);
            
            //update Case fields here:
            cloneCase.ContactId = referenceCase.ContactId;
            cloneCase.AccountId = referenceCase.AccountId;
            cloneCase.License_Account_Lookup__c = referenceCase.License_Account_Lookup__c;
            cloneCase.Platform__c = referenceCase.Platform__c;
            cloneCase.OS__c = referenceCase.OS__c;
            cloneCase.OwnerId = UserInfo.getUserId();
            //cloneCase.Release__c = referenceCase.Release__c;
             Logger.debug(cloneCaseId);  
             Logger.debug(referenceCaseId);
            try{
                update cloneCase;
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //capture Dml  Process exception 
                  Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
            
            PageReference casePage = new ApexPages.StandardController(cloneCase).view();
            
            casePage.setRedirect(true);
            return casePage;
        }else{
            return null;
        }
    }
    
    /*
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 17 Jun 2013
    * @description: Method that returns a String query which selects all the fields of a Case.
    */    
    public static string CaseQueryStatement (String whereClause){
        map<String, Schema.SObjectField> CsefieldMap = Schema.SObjectType.Case.fields.getMap();
        Case cse = new Case();
        String theQuery = 'Select ';
        String conID = cse.ContactId;
        
        for (Schema.Sobjectfield field : CsefieldMap.values()){
            theQuery+= field.getDescribe().getName() + ',';
        }

        theQuery = theQuery.substring(0, theQuery.length() - 1); //trim last comma
        theQuery+= ' FROM Case Where '+whereClause;
        return theQuery;
    }
    
    /*
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks
    * @date Original: 19 Jun 2013
    * @description: Method that returns a String query which selects all the fields of a Case.
    */    
    public PageReference SaveCloneRedirectToEdit (){
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        String caseQueryStatment = CaseQueryStatement('id = \''+caseId+'\' ');
        Case sourceCase= (Case)Database.query(caseQueryStatment);
        Case newCase = new Case();
        
        //add fields to be copied from source here:
        newCase.Status = 'Open';
        newCase.SubStatus__c = 'In Progress';
        newCase.Sub_Area__c = null;
        newCase.ContactId = sourceCase.ContactId;
        newCase.AccountId = sourceCase.AccountId;
        newCase.Platform__c = sourceCase.Platform__c;
        newCase.Product_Lookup__c = sourceCase.Product_Lookup__c;
        
        newCase.OS__c = sourceCase.OS__c;
        newCase.RecordTypeId = sourceCase.RecordTypeId;
        //newCase.Product__c = sourceCase.Product__c;
        newCase.OwnerId = sourceCase.OwnerId;
        insert newCase;
        
        //String newCaseEditURL = '/'+newCase.id+'/e?retURL=%2F'+caseId;
        String retURL = Encodingutil.urlEncode('/apex/CaseCloneCancel?id='+newCase.Id+'&oldid='+caseId,'UTF-8');
        String savURL = Encodingutil.urlEncode('/apex/CaseCloneSaveByPass?id='+newCase.Id,'UTF-8');
        newCaseEditURL = '/'+newCase.id+'/e?saveURL='+savURL+'&retURL='+retURL;
        
        PageReference casePage = new PageReference(newCaseEditURL);
        casePage.setRedirect(true);
        return casePage;
    }
    
    /*
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
    * @date Original: 19 Jun 2013
    * @description: Method that returns the user to the original Case when hitting Cancel button
    */  
    public PageReference CancelClonedCase(){
        Id newcaseId = ApexPages.currentPage().getParameters().get('id');
        Id sourcecaseId = ApexPages.currentPage().getParameters().get('oldid');
        
        try{
        //Delete created Clone Case
        Case newCase = [Select Id From Case Where Id = : newcaseId limit 1];
        delete newCase;
        
        Logger.debug('Case id is'+sourcecaseId);
        
        }
        catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //capture Dml  Process exception 
                  Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
        }
        catch(Exception ex) {

          
            Logger.debugException(ex.getMessage()+'for Case'+sourcecaseId);
            Logger.pop();
            return null;
        }
        
        //Return user back to detail page of original Case
        PageReference casePage = new PageReference('/'+sourcecaseId);
        casePage.setRedirect(true);
        return casePage;
        
    }
    

}