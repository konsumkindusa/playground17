/**
    * @author Original: Archana Lohar- Cloud Sherpas/Mathworks, Last Modified by:
    * @date Original:  3 July 2015, 
    * @LastModified Date :14 December 2015
    * @description : This is an utility class for checking that inbound email message sender 
                     is present in the Black List and White List against the Custom Setting list of complete or partial email addresses.
    */

public class UEH_MessageCheckingUtils{
    
      /*
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified: 
     *@Date Original: 3 July 2015
     *@Last Modified: 14 Oct 2015
     *@Description:   It will accept the email address from Universal Email Handler and will check
                      inbound email messages against custom setting containing list of complete or 
                      partial email addresses in order to proceed to white list member.
     */ 
    
    public static Boolean isPresentInSenderWhiteList(String emailAddress){
    
        Logger.push('isPresentInSenderWhiteList','UEH_MessageCheckingUtils');
        
        //Get UEH_Sender_Whitelist custom setting
        List<UEH_Sender_Whitelist__c> whiteList = UEH_Sender_Whitelist__c.getAll().Values();
        
        
        //Check if the WihteList is empty or null
        if(!whiteList.isEmpty() && whiteList != null){
            
            //Initialise Variables
            Set<String> ExactMatchEmailAddrSet = new Set<String>();
            Set<String> StartsWithEmailAddrSet = new Set<String>();
            Set<String> EndsWithEmailAddrSet = new Set<String>(); 
            
            for(UEH_Sender_Whitelist__c whiteListRec : whiteList){
                
                if(whiteListRec.Email_Address__c != '' && whiteListRec.Email_Address__c != Null 
                   && whiteListRec.Match_Type__c != '' && whiteListRec.Match_Type__c != Null){
                    
                    //For Exact Match
                    if(whiteListRec.Match_Type__c == 'Exact'){
                        ExactMatchEmailAddrSet.add(whiteListRec.Email_Address__c);
                    }
                    //For UserName Match
                    else if(whiteListRec.Match_Type__c == 'Username'){
                        StartsWithEmailAddrSet.add(whiteListRec.Email_Address__c);
                    }
                    //For Domain Match
                    else if(whiteListRec.Match_Type__c == 'Domain'){
                        EndsWithEmailAddrSet.add(whiteListRec.Email_Address__c);
                    }
                }//if
            }//for
           
            
            //If the Sender's Email Address is Exactly matched with the Email Address in the ExactMatchEmailAddrSet.
            if(ExactMatchEmailAddrSet.contains(emailAddress)){
                Logger.pop();
               return true;
            }
            //If Sender UserName is same matched with the Username present in the StartsWithEmailAddrSet.
            else if(StartsWithEmailAddrSet.contains(emailAddress.subStringbefore('@'))){
                Logger.pop();
                return true;
            }
            //If Sender's Email Address Domain Name is present in the EndsWithEmailAddrSet.
            else if(EndsWithEmailAddrSet.contains(emailAddress.subStringAfter('@'))){
                Logger.pop();
                return true;
            }    
            else{
                Logger.pop();
                return false;
            }
        
        }//if
        //Return if the White List is Empty.
        else{
            Logger.pop();
            return false;
        }
    }
     
    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 3 July 2015
     *@Last Modified: 14 Oct 2015
     *@Description: It will accept the email address from Universal Email Handler and will check
                    inbound email messages against custom setting containing list of complete or 
                    partial email addresses in order to prevent unwanted messages from being 
                    further processed.     
     */ 
     
     public static Boolean isPresentInSenderBlackList(String emailAddress){

        Logger.push('isPresentInSenderBlackList','UEH_MessageCheckingUtils');
        
        //Get SenderBlacklistForUniversalEmailHandler custom setting
        list<UEH_Sender_Blacklist__c> blackList = UEH_Sender_Blacklist__c.getAll().Values();

        //Check if blackList is empty and null
        if(!blackList.isEmpty() && blackList != NULL){
            //Initialise Variables
           Set<String> ExactMatchEmailAddrSet = new Set<String>();
           Set<String> StartsWithEmailAddrSet = new Set<String>();
           Set<String> EndsWithEmailAddrSet = new Set<String>();
            
            for(UEH_Sender_Blacklist__c blackLstRec: blackList){

                if(blackLstRec.Email_Address__c != '' && blackLstRec.Email_Address__c != NULL  
                        && blackLstRec.Match_Type__c!='' &&  blackLstRec.Match_Type__c!= NULL){

                    //For Exact Match
                    if(blackLstRec.Match_Type__c=='Exact'){
                        ExactMatchEmailAddrSet.add(blackLstRec.Email_Address__c);
                    }
                    //For Username Match
                    else if(blackLstRec.Match_Type__c=='Username'){
                        StartsWithEmailAddrSet.add(blackLstRec.Email_Address__c);
                    }
                    //For Domain Match
                    else if(blackLstRec.Match_Type__c=='Domain'){
                        EndsWithEmailAddrSet.add(blackLstRec.Email_Address__c);
                    }

                }//if
            }//for
                
            //If the Sender's Email Address is Exactly matched with the Email Address in the ExactMatchEmailAddrSet.    
             if(ExactMatchEmailAddrSet.contains(emailAddress)){
                   Logger.pop();
                   return true;
             }
             //If Sender UserName is same matched with the Username present in the StartsWithEmailAddrSet. 
             else if(StartsWithEmailAddrSet.contains(emailAddress.substringBefore('@'))){
                   Logger.pop();
                   return true;
             }
             //If Sender's Email Address Domain Name is present in the EndsWithEmailAddrSet.
             else if(EndsWithEmailAddrSet.contains(emailAddress.substringAfter('@'))){
                   Logger.pop();
                   return true;
             }
        else{
            Logger.pop(); 
            return false;
        }
     }//if
        //Check if the BlackList is Null or Empty. 
        else{
             Logger.pop();
             return false;
        }
    }
    
    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 23 July 2015
     *@Last Modified: 14 December 2015
     *@Description: It will accept the email message from Universal 
                    Email Handler and it will check if it is spam or not
     */ 
        
     public static Boolean isInboundEmailSpam(Messaging.InboundEmail email){ 
     
        Logger.push('isInboundEmailSpam','UEH_MessageCheckingUtils');
        
        List<UEH_Inbound_Email_Log__c> logList = new List<UEH_Inbound_Email_Log__c>();
         
        List<UEH_Inbound_Email_Log__c> logListToCompare = new List<UEH_Inbound_Email_Log__c>();
        
        //Fetching data from Message Checking Settings
        UEHMessageCheckingSettings__c checkingSettings = UEHMessageCheckingSettings__c.getInstance();
        
        //store tuncated subject and body
        String truncatedSubject;
        String truncatedBody;
        String truncatedHTMLBody;
        
        //Get truncated subject in string if characters exceed than 255.
        if (email.Subject!=null){ 
        
            if(email.Subject.length()>255){
            
                 truncatedSubject = UEH_MessageParsingUtils.truncateSubject(email.Subject);  
                 
            }
            else{
            
                 truncatedSubject = email.Subject;
            
            }
        }
        
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
       //Get truncated body in string if characters exceed than 32500.
        if (email.PlainTextBody != null){
        
            if (email.PlainTextBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
            
                truncatedBody = UEH_MessageParsingUtils.truncateBody(email.PlainTextBody); 
                
            }
            else{
            
                truncatedBody = email.PlainTextBody; 
            }
        }
        
        //Get truncated body in string if characters exceed than 32500.
        if (email.htmlBody!= null){
        
            if (email.htmlBody.length() > uehGeneralSettings.Max_Email_Body_Length__c){
            
                truncatedHTMLBody = UEH_MessageParsingUtils.truncateBody(email.htmlBody); 
                
            }
            else{
            
                truncatedHTMLBody = email.htmlBody; 
            }
        }
        
        
       
        //Query UEH_Inbound_Email_Log__c to check if 
        logList = [Select id,UEH_Email_Text_Body__c,UEH_Email_HTML_Body__c,createdDate from 
                   UEH_Inbound_Email_Log__c where 
                   UEH_Email_From_Address__c=:email.FromAddress and
                   UEH_Email_Subject__c=:truncatedSubject 
                   ];
      
        
        if(logList.size()>=checkingSettings.SpamCheckCount__c){
        
            for(UEH_Inbound_Email_Log__c logObj:logList){ 
            
                  DateTime createdDateToCompare = logObj.createddate;
                  
                  //Check if body is also same and check if it has came within seconds defined in custom setting
                  if((createdDateToCompare!=null && createdDateToCompare.addSeconds(Integer.valueOf(checkingSettings.Check_Interval__c))> DateTime.now()) && ((truncatedHTMLBody!= null && logObj.UEH_Email_HTML_Body__c!= null && (logObj.UEH_Email_HTML_Body__c.trim()).equals(truncatedHTMLBody.trim()))|| (truncatedBody!= null && logObj.UEH_Email_Text_Body__c!= null && (logObj.UEH_Email_Text_Body__c.trim()).equals(truncatedBody.trim())))){
                
                     logListToCompare.add(logObj);
               
                  }
            }
            
            if(logListToCompare.size()>=checkingSettings.SpamCheckCount__c){
            
                Logger.pop();
                return true;
            
            }
            else{
               
               Logger.pop();
               return false;
        
            }        
        }
        else{
        
            Logger.pop();
            return false;
        
        }
        
    }
    
     /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Kishore AN - Cloud Sherpas/Mathworks 
     *@Date Original: 8 July 2015
     *@Last Modified: 14 Oct 2015
     *@Description: Check if Thread id is valid by checking record id from thread id exist.     
     */ 
     
     public static Boolean isValidThreadId(String threadId){

        Logger.push('isValidThreadId','UEH_MessageCheckingUtils');
        Id recordId;
        //Instantiate list of sObject
        List<sObject> sobjList = new List<sObject>();
        
        if(threadId!='ref::ref' && threadId!=null){
        
            String keyPrefix = UEH_MessageParsingUtils.getKeyPrefixFromThreadId(threadId);
            
            //Check if the key prefix is 500 or not
            if(keyPrefix == '500'){
                //Get record id from Thread Id based on the SFDC standard format
                recordId = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId);
            }
            else{
                //Get record id from Thread Id based on the Ortoo format
                recordId = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId);
            }
            
            if(recordId!=null){
                //Get Sobject type from record Id
                Schema.SObjectType sobjectName = UtilityHelper.ObjectTypeOf(recordId);              
                
                
                //Query record to check if thread id is valid
                sobjList = Database.query('SELECT Id FROM '+sobjectName+' WHERE id =:recordId');
            }
             if(sobjList.size()>0){
                 
                 Logger.pop();
                 return true;
             }
             else{
                  
                 Logger.pop();
                 return false;
             } 
             
         }  
         
         else{
         
            Logger.pop();
            return false;
         
         }     
     }  
}