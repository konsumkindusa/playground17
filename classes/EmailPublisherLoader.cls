/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   21 Jan 2016, Last Modified: 21 Jan 2016
 *@description:     this is a  class Which set the sender address on case feed if user sender address is not null elase set 
                    user's email address
 */
global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {
    
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original:   21 Jan 2016, Last Modified: 21 Jan 2016
     *@description:     This Method set the sender email address
     */
   global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
         Logger.push('onInitDefaults','EmailPublisherLoader');
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
    
        // Check if the quick action is the standard Case Feed send email action
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
               defaults.get(j).getTargetSObject().getSObjectType() == 
                   EmailMessage.sObjectType && 
               defaults.get(j).getActionName().equals('Case.Email') && 
               defaults.get(j).getActionType().equals('Email')) {
                   sendEmailDefaults = 
                       (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                   break;
            }
        }
       if (sendEmailDefaults != null) {
           
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();
            //get the userId
            Id userID = UserInfo.getUserId();
            if(userID != null){
                emailMessage.FromAddress = fromAddress(userID );
            }
        }
         Logger.pop();
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original:   21 Jan 2016, Last Modified: 21 Jan 2016
     *@description:     This Method is for getting the user sender Address if it is not null else Get the user's email address
     */
    global String fromAddress(Id uid) {
        Logger.push('fromAddress','EmailPublisherLoader');
        string senderEmail;
        User userObj = [select id,SenderEmail,Email from user where id =:uid limit 1];
        if(userObj.SenderEmail != null){
           senderEmail  = userObj.SenderEmail;
        }
        else{
           senderEmail  = userObj.Email;
        }
        Logger.pop();
        return senderEmail ;
    }
    
}