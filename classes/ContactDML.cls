//Changes made by jaspreet on 4-22-2014 to keep users inactive i.e. IsActive = false instead of IsActive = true.
// Changes made by Jaspreet on 10-14-2014 to move dml operations outside for loop
// SS 1/26/2016 Commented the CreatedHVCPUser function as it will not be called from Contact, but only from CustomJIT class
// SS 1/26/2016 Also commented the else section of UpdateHVCPuser function
//Added Logger calls to methods gcalimlim on 5.21.2014
public with sharing class ContactDML{
 
  /*  public void createHVCPUser(List<Contact> List_Contacts){
        Logger.push('createHVCPUser','ContactDML');
        list<Profile> profileList = 
            new list<Profile>([SELECT p.name, p.id FROM Profile p WHERE p.UserLicense.Name like '%Overage High Volume Customer Portal%' AND p.Name like '%Overage High Volume Customer Portal User%']);

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
                    hvcpUser.EmailEncodingKey = 'ISO-8859-1';
                    hvcpUser.FirstName = contactUser.FirstName;
                    hvcpUser.IsActive = false;

                    if(Test.isRunningTest() == true) // Added By Jaspreet on 29-April-2014 To Pass test class 
                    {
                        hvcpUser.IsActive = true;
                    }

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
        
        Logger.pop();
    }*/


    @future
    public static void updateHVCPUser(Set<Id> contactIds){
        Logger.push('updateHVCPUser','ContactDML');
        Map<Id, user> userMap = new Map<Id, user>();
        
        list<Profile> profileList = 
            new list<Profile>([SELECT p.name, p.id FROM Profile p WHERE p.UserLicense.Name like '%Overage High Volume Customer Portal%' AND p.Name like '%Overage High Volume Customer Portal User%']);

        String profileId = profileList[0].Id;

        List<User> userList = [select Id, ContactId, FederationIdentifier, Alias,CommunityNickName, Country, country_code__c,Email,IsActive, FirstName, Portal_User_Status__c,Student__c, LastName from User where ContactId in :contactIds];
        List<Contact> updatedContactList = [select Id,student__c,MathWorks_Account_ID__c, FirstName, LastName, MailingCountry, country_code__c, Email, Siebel_Contact_id__c from Contact where Id in :contactIds];
        for(User usr : userList){
            userMap.put(usr.ContactId, usr);
        }
        
     //   list <User> listInserUser = new List<User>();
        list<User> listUsrUpdate = new List<User>();

        for(Contact cnt: updatedContactList){
            User usr = userMap.get(cnt.Id);
            if(usr != null){
                
                    //update user portal_user_status only of it is not distributor
                    if(usr.Portal_User_Status__c != 'Distributor'){
                        if(cnt.student__c){
                            usr.student__c = cnt.student__c;
                            usr.Portal_User_Status__c = 'Student';
                        }
                        else{
                            usr.student__c = cnt.student__c;
                            usr.Portal_User_Status__c = 'Customer';
                        }


                    }

                   Logger.Debug('mathworks AccountId:'+cnt.MathWorks_Account_ID__c+'::');

                //    if(usr.Federationidentifier!= null){ SS 2/19/16 Commented as it can be a valid scenario to update MW Accnt Id on Contact to null and then a valid value
                        if(cnt.MathWorks_Account_ID__c != null && cnt.MathWorks_Account_ID__c != '' && Integer.valueOf(cnt.MathWorks_Account_ID__c) > 0 )
                        {
                            usr.FederationIdentifier = cnt.MathWorks_Account_ID__c;
                            usr.Username = cnt.MathWorks_Account_ID__c + '@mwprofile.com';
                        }
                        else if((cnt.MathWorks_Account_ID__c == null)  || (cnt.MathWorks_Account_ID__c != null && Integer.valueOf(cnt.MathWorks_Account_ID__c) == 0)){
                            usr.FederationIdentifier ='';
                            usr.Username = cnt.Id + '@mwprofile.com';
                            
                        }
                     //   usr.isActive = false;

                 //   }


                    usr.Alias = cnt.FirstName.left(1) + cnt.LastName.left(4);
                    usr.CommunityNickName = cnt.FirstName.left(1) + cnt.LastName + cnt.MathWorks_Account_ID__c;                   

                    usr.Country = cnt.MailingCountry;
                    usr.country_code__c = cnt.country_code__c;
                    usr.Email = cnt.Email;

                    usr.FirstName = cnt.FirstName;
                    usr.LastName = cnt.LastName;
                    listUsrUpdate.add(usr);
                    Logger.debug(usr.Id);
             
            }
 /*           else{

                if(cnt.MathWorks_Account_ID__c != null && cnt.MathWorks_Account_ID__c != '' && Integer.valueOf(cnt.MathWorks_Account_ID__c) > 0){
                    
                        User hvcpUser = new User();
                        hvcpUser.FederationIdentifier = cnt.MathWorks_Account_ID__c;
                        hvcpUser.ProfileId = profileId;

                        hvcpUser.Alias = cnt.FirstName.left(1) + cnt.LastName.left(4);
                        hvcpUser.CommunityNickName = cnt.FirstName.left(1) + cnt.LastName + cnt.MathWorks_Account_ID__c;
                        hvcpUser.ContactId = cnt.Id;
                        //hvcpUser.CompanyName = contactUser.AccountId.Name;
                        hvcpUser.Country = cnt.MailingCountry;
                        hvcpUser.country_code__c = cnt.country_code__c;
                        hvcpUser.Email = cnt.Email;
                        hvcpUser.EmailEncodingKey = 'ISO-8859-1';
                        hvcpUser.FirstName = cnt.FirstName;
                        hvcpUser.IsActive = false;

                        hvcpUser.IsPortalSelfRegistered = false;

                        hvcpUser.LanguageLocaleKey = 'en_US';
                        hvcpUser.LastName = cnt.LastName;
                        hvcpUser.LocaleSidKey = 'en_US';          
                        hvcpUser.ReceivesAdminInfoEmails = false;
                        hvcpUser.ReceivesInfoEmails = false;
                        hvcpUser.Siebel_User_ID__c = cnt.Siebel_Contact_id__c;
                        if(cnt.Student__c){ 
                            hvcpUser.Portal_User_Status__c = 'Student';
                            hvcpUser.Student__c = cnt.Student__c;
                        }
                        else{
                            hvcpUser.Portal_User_Status__c = 'Customer';
                            hvcpUser.Student__c = cnt.Student__c;
                        }
                        hvcpUser.TimeZoneSidKey = 'GMT';
                        hvcpUser.Username = cnt.MathWorks_Account_ID__c + '@mwprofile.com';
                        listInserUser.add(hvcpUser);
Logger.Debug('Insert MW Account ID'+cnt.MathWorks_Account_ID__c + cnt.Email);

                }
            }   */         

        }
        
       try{
          /*if(listInserUser.size() > 0)
              {
                  insert listInserUser; // By jaspreet moved dml opertion outside for loop 
              } */
            
            if(listUsrUpdate.size() > 0)
            {
             try{
                 
                 if (Test.isRunningTest()) //SS added to resolve the mixed dml error when running test class
                 {
                     System.runAs(new User(Id = Userinfo.getUserId())) 
                     {
                 		system.debug('Inside the User Update function');//SS
                         update listUsrUpdate;  
             		}                
    			} 
                 else 
                 {
      					update listUsrUpdate;
    			}
             }
             catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Capture Dml exception here
                   Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
             }
          
            }
        }
        catch(Exception ex){
           Logger.Debug('hvcpUser creation Error:'+ex.getMessage());
           Logger.debugException(ex);
           Logger.pop();  
       }
        
    }    

    /**
     *Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *Date Original: 15 May 2014 
     *Last Modified: 16 May 2014
     *Description: . It will accept the list of accounts and replace the 
     *               non latin strings for address and update the list accordingly
     */ 
    public void replaceContactAddress(list<Contact> retContLst){
        Logger.push('replaceContactAddress','ContactDML');
        
        //List to add the contacts to insert 
        List<Contact> contactList=new List<Contact>();

        //instantiating CS_LatinAddressUtilityHelper class
        LatinAddressUtilityHelper utilObj = new LatinAddressUtilityHelper();


        //map to get the country code and names
        Map<string,string>countryMap=utilObj.getCountryMap(Contact.MailingCountryCode.getDescribe().getPickListValues());
        Map<string,string>countryLongMap=utilObj.getLongCountryMap(Contact.MailingCountryCode.getDescribe().getPickListValues());
        


        if(!retContLst.isEmpty() && retContLst != NULL){

            //For loop to traverse the accounts list which has latin state
            for(Contact conObj: retContLst){
                
                if(conObj.MailingCountryCode == NULL && conObj.MailingCountry != NULL ){
                    conObj.MailingCountryCode = countryLongMap.get(conObj.MailingCountry);
                }
                
                /* Create the Address object, assign the values to address variables and  pass the object to utility class to get the replaced or converted values if necessary*/
                Address addrObj = new Address();
               
                addrObj.setCountry(conObj.MailingCountrycode != NULL ? countryMap.get(conObj.MailingCountrycode) : '');    
                addrObj.setStateCode(utilObj.getStateCode(conObj.MailingCountrycode, conObj.MailingStateCode));
                addrObj.setState(conObj.MailingState != NULL ? conObj.MailingState :'');
               
                //calling utility class to replace the address
                addrObj = utilObj.getLatinAddress(addrObj);

                //setting the replaced values back to Account address                
                conObj.State_Province_Latin__c = addrObj.getState();
                Logger.debug(conObj.Id);
                contactList.add(conObj);

            }//for


        }//if
        
        try
        {
            if(!contactList.isEmpty())
            {
                
                update contactList;
            }
            
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }
        
        Logger.pop();

    }
    
    /**
     *Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *Last Modified: Krishna - Mathworks; Desc: update the Account Changed Date/Time field with the current system date and time
     *Date Original: 15 May 2014 
     *Last Modified: 16 May 2014
     *Description: . It will accept the list of contacts and will create
     *the dummy account record forcontacts
     */ 
    public void createDummyAccount(List<Contact> List_Contacts){
        Logger.push('createDummyAccount','ContactDML');
        
        
        //Map to store the accounts with corresponding contact id
        Map<id, Account> accMap = new Map<id, Account>();

        //List to store the contacts which have to update with new accountid
        List<Contact> updateContList=new List<Contact>();
        
      
        
        //For loop travers the contacts 
        if(!List_Contacts.isEmpty())
        {
            for(Contact contObj:List_Contacts){  
                if(contObj.AccountID == null){
                    Account acc = new Account();
                    //If the Account Name exceeds 100 chars,trim the LastName chars to fit the 100 chars length
                    String accName=((contObj.FirstName) != NULL ? (contObj.FirstName) : '') + ' ' + contObj.LastName + ' ' + DateTime.now().getTime();
                    Integer accNameLength =accName.length();
                    String lastName=contObj.LastName;
                    Integer lastNameLength=lastName.length();
                    Integer charTotrim=accNameLength-100;

                    if(accNameLength>100)
                    {
                        String trimmedLastName= lastName.Substring(0,lastNameLength-charTotrim);
                        acc.name = ((contObj.FirstName) != NULL ? (contObj.FirstName) : '') + ' ' + trimmedLastName+ ' ' + DateTime.now().getTime();
                    }
                    else
                    {
                        acc.name = accName;
                    }
                    System.Debug('Account Name:'+ accName);
                    //populating contact's mailing address fields to dummy account's billing address fields
                    acc.BillingCountrycode=((contObj.MailingCountrycode) != NULL ? (contObj.MailingCountrycode) : '');
                    acc.BillingStatecode=((contObj.MailingStatecode) != NULL ? (contObj.MailingStatecode) : '');
                    acc.BillingCity=((contObj.MailingCity) != NULL ? (contObj.MailingCity) : '');
                    acc.BillingStreet = contObj.MailingStreet != NULL ? contObj.MailingStreet :'' ;
                    acc.BillingPostalCode = contObj.MailingPostalCode != NULL ? contObj.MailingPostalCode :'';
                    acc.County__c = contObj.County_Local__c != NULL ? contObj.County_Local__c : ''; 
                    //set dummy account as indivisual
                    acc.Is_Individual_Account__c=true;
                    // Field added by Krishna - Mathworks see desc above
                    acc.Address_Changed_Date__c = DateTime.now();
                    //Field added by Divya
                    acc.Type = 'Individual';
                    accMap.put(contObj.id,acc);
                }

            }//for
        }//if
         
        //Inserting new accounts
        try
        {
            if (!accMap.isEmpty()){
                insert accMap.values();
            }
        }
        catch(exception ex)
        {
            System.debug(ex);
            Logger.debugException(ex);
        }

        //For loop travers the contacts
        if(!List_Contacts.isEmpty() && !accMap.isEmpty()){

            for(Contact contObj:List_Contacts){  


                Account acc = accMap.get(contObj.id); 
                contObj.AccountId = acc.id;
                updateContList.add(contObj);
                Logger.debug(contObj.id);
               Logger.debug('Create Dummy');
            }//for
        }//if
         try
        {
            if (!updateContList.isEmpty()){
                update updateContList;
            }
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Capture Dml exception here
               Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }
        Logger.pop();
    }

}