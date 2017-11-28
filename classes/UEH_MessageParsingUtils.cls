/**
   *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
   *@date Original: 3 July 2015, Last Modified:
   *@description : Utility class that contains utility methods for parsing and manipulating parts of the email message. 
   */

public class UEH_MessageParsingUtils{

     /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified:Sagar Talele  - Cloud Sherpas/Mathworks 
     *@Date Original: 3 July 2015
     *@Last Modified: 17 July 2015
     *@Description: helper method for truncating subject
     *@param: email - subject to truncate
     */ 
     
     public static String refOrgId; //cached Reference Org Id used for checking whether a string contains a Ref Id
     public static String refSFDCOrgId; //cached Reference Org Id used for Caseschecking whether a string contains a Ref Id
     
     public static string truncateSubject(String emailSubj){
     
      Logger.push('truncateSubject','UEH_MessageParsingUtils');
     
            String truncatedSubj;
            String OrganizationId = UserInfo.getOrganizationId();
            //Get the Ref Id to Search in the Email Body.
            refOrgId = getReferenceOrgID(OrganizationId);
            refSFDCOrgId = getSFDCReferenceOrgID(OrganizationId);
            //Get first 205 characters on email Subject
            String tempsubj = emailSubj.substring(0,205); 
            //Subjects with Thread ID
            if (emailSubj.contains(refOrgId) || emailSubj.contains(refSFDCOrgId)){
              //get the thread Id From  getThreadID() method
              String truncatedthreadID = getThreadID(emailSubj);
              //again append the thread Id 
              tempsubj = tempsubj + '... ' + truncatedthreadID ;
              truncatedSubj = tempsubj;
            }
            //Subjects without Thread ID
            else{
                truncatedSubj = emailSubj.substring(0,255);
            }
        Logger.pop();
        
        return truncatedSubj;
     }
     
     /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Sagar Talele - Cloud Sherpas/Mathworks 
     *@Date Original: 3 July 2015
     *@Last Modified: 17 July 2015
     *@Description: helper method for truncating subject
     *@param: email - plain text /html body to truncate
     */ 
     public static string truncateBody(String emailBody){
     
     Logger.push('truncateBody', 'UEH_MessageParsingUtils');
     
           String truncatedBody;
           String OrganizationId = UserInfo.getOrganizationId();
           //Get the Ref If to Search in the Email Body.
           refOrgId = getReferenceOrgID(OrganizationId);
           refSFDCOrgId = getSFDCReferenceOrgID(OrganizationId);
			//Fetching data from UEH General setting
			UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
           String tempBody = emailBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue()-250); //Get first 31750 characters on email Body and it will remove the last threadid from email body
           //Creates body with last Thread ID 
            if (emailBody.contains(refOrgId) || emailBody.contains(refSFDCOrgId)){
                    //get the thread Id From  getThreadID() method
                    String truncatedthreadID = getThreadID(emailBody);
                    // Again appends thread id to body
                    tempBody = tempBody + truncatedthreadID;
                    truncatedBody = tempBody;
            }
            else{
                truncatedBody = emailBody.substring(0,uehGeneralSettings.Max_Email_Body_Length__c.intValue());
            }
        Logger.pop();
            
        return truncatedBody;
    
     }
     
     /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Date Original: 3 July 2015
     *@Last Modified: 3 July 2015
     *@Description: helper method for getting reference Organization Id
     */ 
     public static string getReferenceOrgID(String orgRefId){

    Logger.push('getReferenceOrgID', 'UEH_MessageParsingUtils');
     if(refOrgId == null){
         String orgId = orgRefId.subString(0,15);
         String temporgId = orgId.right(11);
        
         String rightResult = '';
         String leftResult = orgId.left(4);
         
         IF(temporgId.startsWith('0000000')) {
             rightResult = orgId.right(4);
         } else IF(temporgId.startsWith('000000')) {
             rightResult = orgId.right(5);
         } else IF(temporgId.startsWith('00000')) {
             rightResult = orgId.right(6);
         } else IF(temporgId.startsWith('0000')) {
             rightResult = orgId.right(7);
         } else IF(temporgId.startsWith('000')) {
             rightResult = orgId.right(8);
         } else IF(temporgId.startsWith('00')) {
             rightResult = orgId.right(9);
         } else IF(temporgId.startsWith('0')) { 
             rightResult = orgId.right(10);
         } else {
             rightResult = orgId.right(11);
         }
   
        refOrgId = leftResult + rightResult;
        Logger.pop();
        return refOrgId;
     }
     else{
         Logger.pop();
         return refOrgId;
       }
        
     }
    
    /*
     *@Author Original: Andy Ognenoff - Cloud Sherpas/Mathworks 
     *@Last Modified: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Date Original: 13 July 2015
     *@Last Modified: 25 AUG 2015
     *@Description: helper method for parsing the thread id from a string
     */ 
     public static string getThreadID(String inputString){
     
     Logger.push('getThreadID', 'UEH_MessageParsingUtils');
        String threadID;
        //Get the thread Id of Format ref:_00De0VmMk._a1Ve0V8iA:ref
        if(inputString.contains('ref:_')){
            // will remove text before first ref 
            threadID = inputString.substringAfterLast('ref:_');
            // will remove text after last ref
            threadID = threadID.substringBefore(':ref');
            threadID = 'ref:_' + threadID + ':ref';
        }
        //Get the thread Id of Format 'ref:00De0VmMk.a1Ve0V8iA:ref
        else{
            // will remove text before first ref 
            threadID = inputString.substringAfterLast('ref:');
            // will remove text after last ref
            threadID = threadID.substringBefore(':ref');
            threadID = 'ref:' + threadID + ':ref';
        }
        Logger.pop();
        return threadID;
        }
        
        
      /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 24 July 2015
     *@Description: helper method for checking string contains threadid  
     */ 
     public static boolean containsThreadId(String stringToCheck){
     
         Logger.push('containsThreadId', 'UEH_MessageParsingUtils');
         
         String OrganizationId = UserInfo.getOrganizationId();
         String keyPrefix;
           
           if(stringToCheck != null){
           
               //Get the key prefix.
               keyPrefix = UEH_MessageParsingUtils.getKeyPrefixFromThreadId(stringToCheck);
               
               //Check if the key prefix is 500 or not.
               if(keyPrefix == '500'){
                   //Get the Ref If to Search in the Email Body.
                   refSFDCOrgId = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId);
                  
               }
               else{
                   //Get the Ref If to Search in the Email Body.
                   refOrgId = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId);
               }
               
               
               
               if((refOrgId!=null && stringToCheck.contains(refOrgId))|| (refSFDCOrgId!=null && StringToCheck.contains(refSFDCOrgId))){
               
                 Logger.pop();
                 return true;
               
               }
               else{
                   
                 Logger.pop();
                 return false;
               
               }
               
           }else{
                   
              Logger.pop();
              return false;
               
           }
        
            
        }   
        
     /*
     *@Author Original:     Priyank Saxena - Cloud Sherpas/Mathworks 
     *@Last Modified:       Abhay Verma - Cloud Sherpas/Mathworks
     *@Last Modified Date : 25AUG2015
     *@Date Original:       23 July 2015
     *@Description: helper method for parsing the keyPrefix from thread id 
     */ 
     public static string getKeyPrefixFromThreadId(String threadId){
     
        Logger.push('getKeyPrefixFromThreadId', 'UEH_MessageParsingUtils');
        String keyPrefix = '';
        String CollapsedId;
       
        //Calling the getCollapsedRecordId Method.
        CollapsedId = UEH_MessageParsingUtils.getCollapsedRecordId(threadId);
        
        //get first 3 characters of collapsed string
         IF(CollapsedId.length()>= 3){
            keyPrefix = CollapsedId.substring(0, 3);
         }
         else If(CollapsedId.length()!= 3){
           keyPrefix = '';
         }    
         
        Logger.pop();
        return keyPrefix;
     }    
        
    /*
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:   Abhay Verma - Cloud Sherpas/Mathworks 
     *@Date Original: 24 July 2015
     *@Last Modified: 21 AUG 2015
     *@Description: helper method for parsing the Record Id from a Thread Id
     */ 
     //String threadId9 =  'ref:00De0VmMk.a1Ve0V8iA:ref';
     
     public static String getRecordIdFromThreadId(String threadId){
     
     Logger.push('getRecordIdFromThreadId', 'UEH_MessageParsingUtils');
        String collapsedRecId;
        String recTempId;
        Id recordId;
     
        //Calling the getCollapsedRecordId Method.
        collapsedRecId = UEH_MessageParsingUtils.getCollapsedRecordId(threadId);
        
        if(collapsedRecId.length() == 8){
        try{
            recTempId = collapsedRecId.left(4) + '0000000' + collapsedRecId.right(4);
            //Convert the 15 Digit Record Id into 18 Digit Record Id.
            recordId = recTempId;
        }
        
        catch(Exception ex){
            recordId = null;
            Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
            Logger.pop();
          }
        }
        
        //Check if the Collapse Record Id having different Length.
       else if(collapsedRecId.length() == 9){
            try{
                recTempId = collapsedRecId.left(4) + '000000' + collapsedRecId.right(5);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
           }
        }
        
        else if(collapsedRecId.length() == 10){
        try{
            recTempId = collapsedRecId.left(4) + '00000' + collapsedRecId.right(6);
            //Convert the 15 Digit Record Id into 18 Digit Record Id.
            recordId = recTempId;
        }
        
        catch(Exception ex){
            recordId = null;
            Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
            Logger.pop();
       }
        }
        else if(collapsedRecId.length() == 11){
            try{
                recTempId = collapsedRecId.left(4) + '0000' + collapsedRecId.right(7);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 12){
            try{
                recTempId = collapsedRecId.left(4) + '000' + collapsedRecId.right(8);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 13){
            try{
                recTempId = collapsedRecId.left(4) + '00' + collapsedRecId.right(9);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 14){
            try{
                recTempId = collapsedRecId.left(4) + '0' + collapsedRecId.right(10);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 15){
            try{
                recordId = collapsedRecId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        } 
        Logger.pop();
        return recordId;
    }  
    
    /*
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:kishore AN  - Cloud Sherpas/Mathworks 
     *@Date Original: 21 Aug 2015
     *@Last Modified: 08 Oct 2015
     *@Description: helper method for parsing the CollapsedRecord Id from a Thread Id
     *@revision: KAN - Updated the code to check for the ref:_ in the whole string instead of just thre beginning
     */ 
     
     private static String getCollapsedRecordId(String threadId){
     
        Logger.push('getCollapsedRecordId', 'UEH_MessageParsingUtils');
        String collapsedRecId;    
        System.Debug('Input ThreadId:'+threadId);
         // get collapsed record Id if the threadId is belong to Standard fromat.
        if((threadId.startsWith('ref:_')||threadId.contains('ref:_')) && threadId.contains('._')){
            collapsedRecId = threadId.substringAfterLast('._'); 
            //Store the Collapsed Id.
            collapsedRecId = collapsedRecId.substringBefore(':ref');
        }
        // get collapsed record Id if the threadId is belong to Email to anything format.
        else{
            collapsedRecId = threadId.substringAfterLast('.'); 
            //Store the Collapsed Id.
            collapsedRecId = collapsedRecId.substringBefore(':ref');
        }
        
        Logger.pop();
        return collapsedRecId;
     }
     
     /*
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:  
     *@Date Original: 06 oct 2015
     *@Last Modified: 
     *@Description: helper method for getting SFDC reference Organization Id
     */ 
     
     public static String getSFDCReferenceOrgID(String orgRefId){
         
         Logger.push('getSFDCReferenceOrgID', 'UEH_MessageParsingUtils');
     if(refSFDCOrgId == null){
         String orgId = orgRefId.subString(0,15);
         String temporgId = orgId.right(10);
        
         String rightResult = '';
         String leftResult = orgId.left(5);
         
         IF(temporgId.startsWith('0000000')) {
             rightResult = orgId.right(3);
         } else IF(temporgId.startsWith('000000')) {
             rightResult = orgId.right(4);
         } else IF(temporgId.startsWith('00000')) {
             rightResult = orgId.right(5);
         } else IF(temporgId.startsWith('0000')) {
             rightResult = orgId.right(6);
         } else IF(temporgId.startsWith('000')) {
             rightResult = orgId.right(7);
         } else IF(temporgId.startsWith('00')) {
             rightResult = orgId.right(8);
         } else {
             rightResult = orgId.right(9);
         }
   
        refSFDCOrgId = leftResult + rightResult;
        Logger.pop();
        return refSFDCOrgId;
     }
     else{
         Logger.pop();
         return refSFDCOrgId;
       }
         
     }
     
     /*
     *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
     *@Last Modified:    
     *@Date Original: 6 oct 2015
     *@Last Modified: 
     *@Description: helper method for parsing the Record Id from a Standard SFDC Thread Id
     */ 
     
     public static String getRecordIdFromSFDCThreadId(String threadId){
     
     Logger.push('getRecordIdFromSFDCThreadId', 'UEH_MessageParsingUtils');
        String collapsedRecId;
        String recTempId;
        Id recordId;
     
        //Calling the getCollapsedRecordId Method.
        collapsedRecId = UEH_MessageParsingUtils.getCollapsedRecordId(threadId);
        
        //Check if the Collapse Record Id having different Length.
        if(collapsedRecId.length() == 9){
            try{
                recTempId = collapsedRecId.left(5) + '000000' + collapsedRecId.right(4);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
           }
        }
        
        else if(collapsedRecId.length() == 10){
        try{
            recTempId = collapsedRecId.left(5) + '00000' + collapsedRecId.right(5);
            //Convert the 15 Digit Record Id into 18 Digit Record Id.
            recordId = recTempId;
        }
        
        catch(Exception ex){
            recordId = null;
            Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
            Logger.pop();
       }
        }
        else if(collapsedRecId.length() == 11){
            try{
                recTempId = collapsedRecId.left(5) + '0000' + collapsedRecId.right(6);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 12){
            try{
                recTempId = collapsedRecId.left(5) + '000' + collapsedRecId.right(7);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 13){
            try{
                recTempId = collapsedRecId.left(5) + '00' + collapsedRecId.right(8);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 14){
            try{
                recTempId = collapsedRecId.left(5) + '0' + collapsedRecId.right(9);
                //Convert the 15 Digit Record Id into 18 Digit Record Id.
                recordId = recTempId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        }
        else if(collapsedRecId.length() == 15){
            try{
                recordId = collapsedRecId;
            }
            catch(Exception ex){
                recordId = null;
                Logger.debugException('Record Id ' + recordId + ' is not valid:'+ex.getMessage());
                Logger.pop();
            }
        } 
        Logger.pop();
        return recordId;
    }  
     
}