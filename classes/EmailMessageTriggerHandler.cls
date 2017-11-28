/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 11 June 2013, Last Modified: 29 October 2013
* @description Trigger handler class for EmailMessage
*/
public class EmailMessageTriggerHandler {
    
    /**
      * @author Original: Jesfer Baculod - Cloud Shepras/Mathworks
      * @date Original: 11 June 2013, Last Modified: 29 October 2013
      * @description Method that handles after insert trigger event on the Case object
      * @param List_Emails A collection of Email Messages with related open activity to be closed
    */
    public void onAfterInsert(List<EmailMessage> List_Emails){
         
         EmailMessageDML emDML = new EmailMessageDML();
         //calls the EmailMessageDML CloseActivityAndGetThreadID method that updates the Activities' status to Completed and gets the ThreadID of the EmailMessage
         emDML.CloseActivity(List_Emails);
         //emDML.setParentCaseToWaitingForInternal(List_Emails);
    }
    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks 
    * @date Original: 7 July 2013
    * @description Trigger handler class for EmailMessage
    */
    public void onBeforeInsert(List<EmailMessage> List_Emails){
         
        EmailMessageDML emDML = new EmailMessageDML();
        //calls the EmailMessageDML to populate emailHtmlBody.
        emDML.setEmailHtmlBody(List_Emails);
    }

    
    /**
    * @author Original: Robbie Macatbag - Cloud Sherpas/Mathworks 
    * @date Original: 11 July 2013
    * @description Trigger handler class for EmailMessage
    */
    public void onAfterUpdate(List<EmailMessage> List_Emails){
        EmailMessageDML emDML = new EmailMessageDML();
        emDML.setParentCaseToWaitingForInternal(List_Emails);
    }

}