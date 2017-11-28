/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks  
* @date Original: 06 May 2013, Last Modified: 06 June 2013
* @description Extension class for Account/Contact Override for opening ACE from salesforce
*/ 
public class OverrideForACEExtension {
    
    public Id ACId              {get; set;}
    public string URLpath       {get; set;}
    public string URLreferer    {get; set;}
    public string ACEon         {get; set;}
    Sobject ACobj               {get; set;}
    General_Settings__c aceset  {get; set;}
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 06 May 2013, Last Modified: 06 June 2013
    * @description Class constructor
    */ 
    public OverrideForACEExtension(ApexPages.Standardcontroller controller){
        //URLpath = '';
        //Determines where the user came from if its on a Standard or on the Service Console
        URLreferer = ApexPages.currentPage().getHeaders().get('referer');
        //Determine whether the ACE link is already opened
        ACEon = '0';
        ACEon = ApexPages.currentPage().getParameters().get('o');
        //Load default values from general custom setting
        aceset = General_Settings__c.getInstance();
        //VF page is on Edit
        if (controller.getId() != null){
            ACid = controller.getId();
            ACobj = controller.getRecord();
        }
    }
    
    /**
    * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks  
    * @date Original: 06 May 2013, Last Modified: 09 May 2013
    * @description method that redirects the user to ACE Edit page when Account/Contact Edit button is clicked
    */ 
    public PageReference ACEonEdit(){
        
        Pagereference pref;
        
        try {
            //Set ACE URL path
            URLpath = aceset.ACE_Url__c; 
            //Edit is on Account
            if (ACobj.getSObjectType() == Account.sObjectType){
                //Retrieve Account
                Account acc = [Select Siebel_Account_Id__c From Account Where Id = : ACid limit 1];
                //Add Siebel Account Id on ACE link
                URLpath+= '/ace/openAccount.do?objectId=' + Encodingutil.urlEncode(String.valueof(acc.Siebel_Account_Id__c), 'UTF-8');
            }
            //Edit is on Contact
            else if (ACobj.getSObjectType() == Contact.sObjectType){
                Contact con = [Select Siebel_Contact_Id__c From Contact Where Id = : ACid limit 1];
                //Add Siebel Contact Id on ACE link
                URLpath+= '/ace/openContact.do?objectId=' + Encodingutil.urlEncode(String.valueof(con.Siebel_Contact_Id__c), 'UTF-8');
            }
            
        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '|' + e.getLineNumber()));    
        }
        //Demo purpose only
        //URLpath = 'http://www.mathworks.com';
        return null;
        
        
    }
    
    /**
    * @author Original: Robbie Dell Macatbag - Cloud Sherpas/Mathworks , Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks 
    * @date Original: 06 May 2013, Last Modified: 09 May 2013
    * @description method that redirects the user to ACE page when Account/Contact Create button is clicked
    */ 
    public PageReference ACEonNew(){
        
        try {
            //Set ACE URL path
            URLpath = aceset.ACE_Url__c + '/ace/main.do'; 
            //Demo purpose only
            //URLpath = 'http://www.mathworks.com';

        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '|' + e.getLineNumber()));
        }
        
        return null;
        
    }

}