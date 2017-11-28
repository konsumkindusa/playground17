/**
* @author Original: Jaspreet - Mathworks, 
* @Last Modified: Shweta Shanbhag - Mathworks  
* @description this class is used for custom just in time provesioning, this class does following tasks:
  - Checks whether user exists and active, if yes then login
  - If user is inactive, then activate and login
  - If user doesn't exist, then call global contact search to see if contact exists in salesforce 
  - If contact exists then create user and login 
  - If contact doens't exist , get the contact from CDS and create user
  - If contact does not exist in CDS, then show the temp form
*/

global class CustomJITClass implements Auth.SamlJitHandler {

private class JitException extends Exception{}
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
                   
    //Call push method from logger class to handle logs
    system.debug('samlSsoProviderId --- ' + samlSsoProviderId);       
 
    system.debug('assertion ------ ' + assertion);
 
    Logger.push('createHVCPUser','ContactDML');
        
        // Instantiate a user object
        
        User newUser = new user();
        if(attributes.containsKey('EmailAddress'))
        {
         List<Organization> listOrg =[select Id, IsSandbox from Organization limit 1];
         String UserEmailAddress = attributes.get('EmailAddress');
        
         if(listOrg[0].IsSandbox) // If current org is sandbox then append .mwtest to email address
         {
           UserEmailAddress =UserEmailAddress +'.mwtest';
         }
         
        system.debug(UserEmailAddress  + ' -- UserEmailAddress  --' + federationIdentifier);      
            
        List<user> usersList = [SELECT Id, FirstName, ContactId,IsActive FROM User WHERE FederationIdentifier = :federationIdentifier limit 1];
        
        if(usersList.size() > 0)
        {
             newUser =  usersList[0]; 
        }
        
        if(usersList.size() ==0) // Call global search 
        {
           
            // Instantiate inner class SearchContactResponse 
           
           GlobalContactSearchController.SearchContactResponse objSearchContactResponse = new GlobalContactSearchController.SearchContactResponse();
           
           // Call searchContactByEmail static method of class GlobalContactSearchController
           objSearchContactResponse = GlobalContactSearchController.searchContactByEmail(UserEmailAddress);
            
             
           
           // if contact and user were created, query user by contact Id
         //  if(objSearchContactResponse != null && objSearchContactResponse.contactId != null) SS Commented 01/26/2015
           if(objSearchContactResponse.ErrorCode == 'SUCCESS' && objSearchContactResponse.ErrorReason == 'Ok') //SS Added 01/26/2015
           {
             List<Contact> listContacts = [Select Id,MathWorks_Account_ID__c,FirstName,LastName,country_code__c,MailingCountry,Email,Siebel_Contact_id__c,Student__c  from contact where ID = :objSearchContactResponse.contactId];
             
             List<User> listNewUsers = createHVCPUser(listContacts);
             
             if(listNewUsers.size() >0)
             {
                 newUser = listNewUsers[0];
             }
        
             //u = [SELECT Id, FirstName, ContactId,IsActive,FederationIdentifier  FROM User WHERE ContactId= :objSearchContactResponse.contactId];
           }
           else
           {
                throw new JitException('User does not exist'); //SS Added to redirect to custom error url
                newUser = null;  //SS return null if contact not found
           }     
        }
        }
            Logger.pop();
            return newUser;
            }
            
          
    
  
  // This method will be called if user has logged using SSO even once
  
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        
            //Call push method from logger class to handle logs
        system.debug('samlSsoProviderId --- ' + samlSsoProviderId);       
        system.debug('assertion ------ ' + assertion);
   
       User u = [SELECT Id, FirstName, ContactId,Isactive FROM User WHERE Id=:userId];
       if(u.Isactive == false)
       {
           u.Isactive = true;
       }    
       update u;
    }


  // This method will create a customer portal user
  
  private List<User> createHVCPUser(List<Contact> List_Contacts){
       
      list<Profile> profileList = 
            new list<Profile>([SELECT p.name, p.id FROM Profile p WHERE p.UserLicense.Name like '%Overage High Volume Customer Portal%' AND p.Name like '%Custom HVCP User%']);

        String profileId = profileList[0].Id;
        list<User> listInsertNewUser = new list<User>(); 
        
        for(Contact contactUser: List_Contacts){
            if(contactUser.MathWorks_Account_ID__c != null && contactUser.MathWorks_Account_ID__c != '' && Integer.valueOf(contactUser.MathWorks_Account_ID__c) > 0){
                
                    User hvcpUser = new User();
                    hvcpUser.FederationIdentifier = contactUser.MathWorks_Account_ID__c;
                    hvcpUser.ProfileId = profileId;

                    hvcpUser.Alias = contactUser.FirstName.left(1) + contactUser.LastName.left(4);
                    hvcpUser.CommunityNickName = contactUser.FirstName.left(1) + contactUser.LastName + contactUser.MathWorks_Account_ID__c;
                    hvcpUser.ContactId = contactUser.Id;
                    //hvcpUser.CompanyName = contactUser.AccountId.Name;
                    hvcpUser.Country = contactUser.MailingCountry;
                    hvcpUser.country_code__c = contactUser.country_code__c;
                    hvcpUser.Email = contactUser.Email;
                    hvcpUser.EmailEncodingKey = 'UTF-8';
                    hvcpUser.FirstName = contactUser.FirstName;
                    hvcpUser.IsActive = true;
                    hvcpUser.IsPortalSelfRegistered = false;
                    hvcpUser.LanguageLocaleKey = 'en_US';
                    hvcpUser.LastName = contactUser.LastName;
                    hvcpUser.LocaleSidKey = 'en_US';          
                    hvcpUser.ReceivesAdminInfoEmails = false;
                    hvcpUser.ReceivesInfoEmails = false;
                    hvcpUser.Siebel_User_ID__c = contactUser.Siebel_Contact_id__c;
                    if(contactUser.Student__c){ 
                        hvcpUser.Portal_User_Status__c = 'Student';
                        hvcpUser.Student__c = contactUser.Student__c;
                    }
                    else{
                        hvcpUser.Portal_User_Status__c = 'Customer';
                        hvcpUser.Student__c = contactUser.Student__c;
                    }
                    hvcpUser.TimeZoneSidKey = 'GMT';
                    hvcpUser.Username = contactUser.MathWorks_Account_ID__c + '@mwprofile.com';

                    listInsertNewUser.add(hvcpUser);
            }
        }
        if(listInsertNewUser.size() >0)
        {
            try{
                insert listInsertNewUser;  // By jaspreet moved dml opertion outside for loop
            }
            catch(Exception ex){
                 Logger.Debug('hvcpUser creation Error:'+ex.getMessage());
                 Logger.debugException(ex);
            }
            
        }
        return listInsertNewUser;
    }

}