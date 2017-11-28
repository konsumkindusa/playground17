/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Shweta Shanbhag - Mathworks
 *@date Original: 18 July 2014, Last Modified:   2/25/2016
 *@description This is Utility Class for validation some contacts and accounts fields
 *             
 */

public with sharing class EnforceValidationsUtility{

    
    //Error message Custom Lables
    public static  String accountCityMessage=System.Label.Account_City_error_message; 
    public static String accountNameMessage=System.Label.Account_Name_error_message;
    public static String contactFirstNameMessage=System.Label.Contact_FirstName_error_message;
    public static String contactLastNameMessage=System.Label.Contact_LastName_error_message;
    public static String individualaccountMessage=System.Label.Quote_Creation_error_message_for_Indivisual_Account;
    public static String individualaccountOnTrial=System.Label.Trial_is_Individual_Error;
    public static String accountSiebelIdMessage=System.Label.Siebel_Account_ID_error_message;
    public static String contactSiebelIdMessage=System.Label.Siebel_Contact_ID_error_message;
    public static String contactCDSIdMessage = System.Label.CDS_Contact_Id_Error_Message;
    public static String accountCDSIdMessage = System.Label.CDS_Account_Id_Error_Message;
    //address utility for checking non latin characters
    public static LatinAddressUtilityHelper addressHelper=new LatinAddressUtilityHelper();
    
    private EnforceValidationsUtility(){
    }
    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether account is individual
     */ 
    public static boolean isIndividualAccount(Account acc){
        
        //set isError to false
        boolean isError=false;
        
        if(acc.Is_Individual_Account__c){

            UtilityHelper.addErrorMessage(individualaccountMessage);
            isError=true;

        }
        return isError;

    }
    
    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether account is individual
     */ 
    public static boolean isindividualaccountOnTrial(Account acc){
        
        //set isError to false
        boolean isError=false;
        
        if(acc.Is_Individual_Account__c){

            UtilityHelper.addErrorMessage(individualaccountOnTrial);
            isError=true;

        }
        return isError;

    }

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether account has SiebelAccountId
     */ 
    public static boolean  hasSiebelAccountId(Account acc){
        
      //  set isError to false
        boolean isError=false;
        
        if(acc.Siebel_Account_Id__c == '' || acc.Siebel_Account_Id__c == null)
        {
            UtilityHelper.addErrorMessage(accountSiebelIdMessage);
            isError=true;
        }
        return isError;

    }

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether Contact has SiebelContactId
     */ 
   public static boolean  hasSiebelContactId(Contact con){
        
    //    set isError to false
        boolean isError=false;

        if(con.Siebel_Contact_Id__c == '' || con.Siebel_Contact_Id__c == null){
            UtilityHelper.addErrorMessage(contactSiebelIdMessage);
            isError=true;
        }
        return isError;
    }
    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether account has hasLatinAccountName
     */ 
    public static boolean  hasAccountNameLatin(Account acc){
        
        //set isError to false
        boolean isError=false;

        if(acc.name!='' && acc.name != null)
        {
            if(!addressHelper.isLatin(acc.name))
            {
                if(acc.Account_Name_Latin__c=='' || acc.Account_Name_Latin__c==null)
                {
                    UtilityHelper.addErrorMessage(accountNameMessage);
                    isError=true;
                }

            }

        }
        /*else
        {
            UtilityHelper.addErrorMessage(accountNameMessage);
            isError=true;
        }*/
        return isError;
    }

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether Account has city latin
     */ 
    public static boolean  hasAccountCityLatin(Account acc){
        
        //set isError to false
        boolean isError=false;

        if(acc.BillingCity!='' && acc.BillingCity != null)
        {
            if(!addressHelper.isLatin(acc.BillingCity))
            {
                if(acc.Account_City_Latin__c=='' || acc.Account_City_Latin__c==null)
                {
                    UtilityHelper.addErrorMessage(accountCityMessage);
                    isError=true;
                } 

            }

        }
        else
        {
            UtilityHelper.addErrorMessage(accountCityMessage);
            isError=true;
        }
        return isError;



    }

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether Contact has FirstName Latin
     */ 
    public static boolean  hasFirstNameLatin(Contact con){
        
        //set isError to false
        boolean isError=false;

        if(con.FirstName!='' && con.FirstName!= null)
        {
            if(!addressHelper.isLatin(con.FirstName))
            {
                if(con.First_Name_Latin__c=='' || con.First_Name_Latin__c==null)
                {
                    UtilityHelper.addErrorMessage(contactFirstNameMessage);
                    isError=true;
                }

            }

        }
        else
        {
            UtilityHelper.addErrorMessage(contactFirstNameMessage);
            isError=true;
        }
        return isError;
    }

    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 22 July 2014
     *@Description: It will validate whether Contact has LastName Latin
     */ 
    public static boolean  hasLastNameLatin(Contact con){
        
        //set isError to false
        boolean isError=false;

        if(con.LastName!='' && con.LastName != null)
        {
            if(!addressHelper.isLatin(con.LastName))
            {
                if(con.Last_Name_Latin__c=='' || con.Last_Name_Latin__c==null)
                {
                    UtilityHelper.addErrorMessage(contactLastNameMessage);
                    isError=true;
                }

            }

        }
        else
        {
            UtilityHelper.addErrorMessage(contactLastNameMessage);
            isError=true;
        }
        return isError;

    }
    
     /**
     *@Author Original: Shweta Shanbhag - Mathworks 
     *@Last Modified: Shweta Shanbhag - Mathworks
     *@Date Original: 2/25/2016 
     *@Last Modified: 2/25/2016
     *@Description: Validation of whether Contact has CDSContactId
     */ 
    public static boolean  hasCDSContactId(Contact con){
        
        boolean isError=false;

        if(con.CDS_Contact_Id__c == '' || con.CDS_Contact_Id__c == null){
            UtilityHelper.addErrorMessage(contactCDSIdMessage);
            isError=true;
        }
        return isError;
    }
    
     /**
     *@Author Original: Shweta Shanbhag - Mathworks 
     *@Last Modified: Shweta Shanbhag - Mathworks
     *@Date Original: 2/25/2016 
     *@Last Modified: 2/25/2016
     *@Description: Validation of whether Account has CDSAccountId
     */ 
    public static boolean  hasCDSAccountId(Account acc){
        
        boolean isError=false;
        
        if(acc.CDS_Account_Id__c == '' || acc.CDS_Account_Id__c == null)
        {
            UtilityHelper.addErrorMessage(accountCDSIdMessage);
            isError=true;
        }
        return isError;

    }
    
    /**
     *@Author Original: Andre Calimlim 
     *@Date Original: 7 Aug 2014 
     *@Description: It will validate whether Contact and Account
     */ 
    public static boolean hasAllRequired(Contact con, Account acc){
        boolean isError=true;
        List<String> messages = new List<String>();
        if(acc.Is_Individual_Account__c){
            messages.add(individualaccountOnTrial);
        }
        if(acc.CDS_Account_Id__c == '' || acc.CDS_Account_Id__c == null){
            messages.add(accountCDSIdMessage);
        }
        if(acc.name!='' && acc.name != null)
        {
            if(!addressHelper.isLatin(acc.name))
            {
                if(acc.Account_Name_Latin__c=='' || acc.Account_Name_Latin__c==null)
                {
                    messages.add(accountNameMessage);
                }
            }
        }
        if(con.CDS_Contact_Id__c == '' || con.CDS_Contact_Id__c == null){
            messages.add(contactCDSIdMessage);
        }
        if(acc.BillingCity!='' && acc.BillingCity != null)
        {
            if(!addressHelper.isLatin(acc.BillingCity))
            {
                if(acc.Account_City_Latin__c=='' || acc.Account_City_Latin__c==null)
                {
                    messages.add(accountCityMessage);
                } 

            }

        }
        else
        {
            messages.add(accountCityMessage);
        }
        
        if(con.LastName!='' && con.LastName != null)
        {
            if(!addressHelper.isLatin(con.LastName))
            {
                if(con.Last_Name_Latin__c=='' || con.Last_Name_Latin__c==null)
                {
                    messages.add(contactLastNameMessage);
                }

            }

        }
        else
        {
            messages.add(contactLastNameMessage);
        }
        if(con.FirstName!='' && con.FirstName!= null)
        {
            if(!addressHelper.isLatin(con.FirstName))
            {
                if(con.First_Name_Latin__c=='' || con.First_Name_Latin__c==null)
                {
                    messages.add(contactFirstNameMessage);
                }

            }

        }
        else
        {
            messages.add(contactFirstNameMessage);
        }
        if(!messages.isEmpty()){
            String allMessages = '';
            for(String str: messages){
                allMessages += str + '<br/>';
            }
            
            UtilityHelper.addErrorMessage(allMessages);
            isError = false;
        }
        return isError;
    }

}