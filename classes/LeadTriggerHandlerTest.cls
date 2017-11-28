/*
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade- Cloud Sherpas/Mathworks
 *@date Original:  30 May 2014, Last Modified: 18 June 2014
 *@description This  is Test class for 'LeadTriggerHandler' class . 
 */

@isTest 
public with sharing class LeadTriggerHandlerTest {
     public static String kwncont = 'Known Contact';
     public static String unkwncont = 'Unknown Contact';
     
     //re-create custom setting test records when running the test class
     static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();

    /*
      @name    testCreateLeadRelatedCont
      @date    30.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record no Contact Id and Email which exist for contact is supplied.                              
     */

      static testMethod void testCreateLeadRelatedContId() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
          
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
         

        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
         
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Rio De Janeiro';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;

        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            //cont.AccountId=accLLst[i].id;
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode ='MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.email = 'john@gmail.com'+i ;
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'AK';
            ledLst.add(led);         
        }
        test.startTest();
        insert ledLst;
        test.stopTest();
        
        Lead led = [select Account__c,Contact__c,RecordTypeId,currencyISOCode 
                    from Lead 
                    where id =:ledLst[ledLst.size() - 1].id];
                        
        System.assertEquals('Unknown Contact',Schema.SObjectType.Lead.getRecordTypeInfosById().get(led.RecordTypeId).getName());
        System.assertEquals('USD', led.CurrencyIsoCode);

        //updating the Lead records 
       for(Lead ledUpd: ledLst){
            ledUpd.Email ='test@gmail.com';      
        
       
        ledUpd.Contact__c = contLst[0].id ; 
        ledUpd.CountryCode ='CN';
        ledUpd.Country_State_Code__c ='CN-11';
        ledUpd.Account__c = contLst[0].AccountId;
           
         }

        update ledLst; 
        
        System.assertEquals('Known Contact',Schema.SObjectType.Lead.getRecordTypeInfosById().get(ledLst[0].RecordTypeId).getName());
        Lead updatedlaed = [select Account__c,Contact__c,RecordTypeId,currencyISOCode 
                    from Lead 
                    where id =:ledLst[0].id];
        //System.assertEquals('CNY', updatedlaed.CurrencyIsoCode);
    }   
    
    
     /*
      @name    testCreateLeadRelatedContEmail
      @date    30.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record where Contact Id is supplied.                              
     */ 
     
     static testMethod void testCreateLeadRelatedContEmail() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
         
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
       
        test.startTest();
        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Santos';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;

        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            cont.Email = 'abc@gmail.com';
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode = 'MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Contact__c =contLst[i].id ;
            led.CountryCode ='JP';
            led.Country_State_Code__c = 'JP-02';
            ledLst.add(led);         
        }
        
        insert ledLst;
        test.stopTest();
        
        Lead led = [select Account__c,Contact__c,RecordTypeId, currencyISOCode 
                    from Lead 
                    where id =:ledLst[ledLst.size() - 1].id];

        System.assertEquals('Known Contact',Schema.SObjectType.Lead.getRecordTypeInfosById().get(led.RecordTypeId).getName());
       
    }   
    
    /*
      @name    testCreateLead
      @date    30.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record where Email exist for contact is supplied.                              
     */ 
     
      static testMethod void testCreateLead() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
          
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
                        
        
        test.startTest();
        
        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
       //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Sao Paolo';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;
        
        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode = 'MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.Email = 'abc@gmail.com';
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email = 'abc@gmail.com';
            ledLst.add(led);         
        }
        
        insert ledLst;
        test.stopTest();
        Lead led = [select Account__c,Contact__c,RecordTypeId, currencyISOCode
                    from Lead 
                    where id =:ledLst[ledLst.size() - 1].id];
        System.assertEquals('Known Contact',Schema.SObjectType.Lead.getRecordTypeInfosById().get(led.RecordTypeId).getName());
        
       
    }
    
    /*
      @name    testCreateLeadQueueOwner
      @date    15.Aug.2014
      @author  Andre alimlim
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record having a Queue owner.                              
     */

      static testMethod void testCreateLeadQueueOwner() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
          
         //Inserting state code list custom settings
         custsettbuild.buildStateCodeList();
          
      
        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
        //create Group
        Group grp = TestDataBuilder.buildTestGroup('Lead');
        
        
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Rio De Janeiro';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;

        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            //cont.AccountId=accLLst[i].id;
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode ='MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.email = 'john@gmail.com'+i ;
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.OwnerId = grp.Id;
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'AK';
            ledLst.add(led);         
        }
        test.startTest();
        insert ledLst;
        test.stopTest();
        
        Set<Id> ldIds = new Set<Id>();
        for(Lead l: ledLst){
            ldIds.add(l.Id);
        }
        
        List<Lead> led = [select OwnerId
                    from Lead 
                    where id in :ldIds];
                        
        for(Lead l2: led){
            String txtId = l2.OwnerId;
            System.assertEquals(true,txtId.startsWith('00G'));
            
        }
        
    }
    
    /*
      @name    testCreateLeadQueueOwner
      @date    15.Aug.2014
      @author  Andre alimlim
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record having a Queue owner and QueueId__c.                              
     */

      static testMethod void testCreateLeadQueueOwnerQueueId() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
          
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();        
           

        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
        //create Group
        Group grp = TestDataBuilder.buildTestGroup('Lead');
        
        
        
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Rio De Janeiro';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;

        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            //cont.AccountId=accLLst[i].id;
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode ='MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.email = 'john@gmail.com'+i ;
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.
        
        
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.OwnerId = grp.Id;
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'AK';
            led.OwnerId__c = UserInfo.getUserId();
            ledLst.add(led);         
        }
        test.startTest();
        insert ledLst;
        test.stopTest();
        
        Set<Id> ldIds = new Set<Id>();
        for(Lead l: ledLst){
            ldIds.add(l.Id);
        }
       
        List<Lead> led = [select OwnerId
                    from Lead 
                    where id in :ldIds];
                        
        for(Lead l2: led){
            
            System.assertEquals(UserInfo.getUserId(),l2.OwnerId);
            
        }
        
        
        
    }
// fg Feb 2016
/*
      @name    UpdateLeadRequester
      @date    04 February 2016
      @author  Faina Gorelik
      @param   none.
      @return  Void. 
      @description Method to update Read Requester name if Ownerid__c is not null    and id is not in User table                       
     */

    static testMethod void UpdateLeadRequester() {
      
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();

        List<Lead> ledLst =new List<Lead>();
 
        //create Lead record from TestDataBuilder.
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email ='Jane.john1@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'MA';
            led.OwnerId__c = '7ABC3'+i ;
            ledLst.add(led);    
                 
        }
        test.startTest(); 
        insert ledLst;  
        
        List<Lead> LeadRequester = [SELECT Lead_Requester__c FROM Lead WHERE Id IN :ledLst];
        for(Lead l : LeadRequester){
            System.assertEquals(null,l.Lead_Requester__c);
        }  
       test.stopTest();
   
    } 
    
    
//  end fg Feb 2016    
//fg

 /*
      @name    UpdateLeadStatus
      @date    07.May.2015
      @author  Faina Gorelik
      @param   none.
      @return  Void. 
      @description Method to update Lead status to closed unconverted when outcome set                            
     */

    static testMethod void UpdateLeadStatus() {
      
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
   
        List<Lead> ledLst =new List<Lead>();
 
        //create Lead record from TestDataBuilder.
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email ='Jane.john1@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'MA';
            ledLst.add(led);         
        }
        
        insert ledLst;  
        test.startTest();
         for(Lead ledUpd: ledLst){
            ledUpd.Outcome__C ='Student';
            
        }
        update ledLst ;     
        
     // test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Status FROM Lead WHERE Id IN :ledLst];
        for(Lead l : updatedLeads){
            System.assertEquals(
            'Closed - Unconverted',l.Status);
        }  
       test.stopTest();
   
    } 
//fg
    
    
     /* @name    testCreateLeadQueueOwner
      @date    15.Aug.2014
      @author  Andre alimlim
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record having a QueueId__c.                              
     */

    static testMethod void testCreateLeadQueueId() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
        
        //Inserting state code list custom settings
       custsettbuild.buildStateCodeList();      
              

        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        

        
        //create User owner
        User u = TestDataBuilder.buildTestUser(1);
        insert u;
        
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Rio De Janeiro';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;

        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            //cont.AccountId=accLLst[i].id;
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode ='MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.email = 'john@gmail.com'+i ;
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.
        
        
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.Email ='Jane.john123'+i+'@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'AK';
            led.OwnerId__c = u.Id;
            ledLst.add(led);         
        }
        test.startTest();
        insert ledLst;
        test.stopTest();
        
        Set<Id> ldIds = new Set<Id>();
        for(Lead l: ledLst){
            ldIds.add(l.Id);
        }
        
        List<Lead> led = [select OwnerId
                    from Lead 
                    where id in :ldIds];
                        
        for(Lead l2: led){
            
            System.assertEquals(UserInfo.getUserId(),l2.OwnerId);
            
        }
        
        
        
    }
    /*
      @name    testCreateLeadQueueOwner
      @date    15.Aug.2014
      @author  Andre alimlim
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record having a Queue owner.                              
     */

   static testMethod void testUpdateLeadQueueOwner() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
       
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
       

        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
        //create Group
        Group grp = TestDataBuilder.buildTestGroup('Lead');
        
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Rio De Janeiro';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        
        insert accLLst;

        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<50;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            cont.AccountId=accLLst[i].id;
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode ='MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.email = 'john@gmail.com'+i ;
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.
        
        
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.OwnerId = grp.Id;
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='IN';
            led.Country_State_Code__c = 'MH';
            led.Contact__c = contLst[i].Id;
            led.Account__c = accLLst[i].Id;
            ledLst.add(led);         
        }
       
        insert ledLst;
        
        
        Set<Id> ldIds = new Set<Id>();
        for(Lead l: ledLst){
            ldIds.add(l.Id);
            l.Email = 'test@test.com';
            l.CountryCode ='US';
            l.Country_State_Code__c ='AK';
            l.OwnerId__c = UserInfo.getUserId();
        }
        
        Test.startTest();}
    
    /*
      @name    testCreateLeadQueueOwner
      @date    15.Aug.2014
      @author  Andre alimlim
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record having a Queue owner.                              
     */

   static testMethod void testAssociateLeadToCampaign() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
       
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();

        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Campaign> campLst =new List<Campaign>();
        List<Lead> ledLst =new List<Lead>();
        
        //create Group
        Group grp = TestDataBuilder.buildTestGroup('Lead');
        
        //create Campaign record from TestDataBuilder.
        
        Test.startTest();
        
        for(Integer i=0;i<50;i++){
            Campaign campObj = TestDataBuilder.buildTestCampaign(i);
            campLst.add(campObj);         
        }
       
        insert campLst;
        
        //create Lead record from TestDataBuilder.
        
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.OwnerId = grp.Id;
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='IN';
            led.Country_State_Code__c = 'MH';
            //led.SFDC_Campaign_ID__c=String.valueOf(campLst[i].id).substring(0, 15);
            led.SFDC_Campaign_ID__c=(campLst[i].id);
            
            ledLst.add(led);         
        }
       
        insert ledLst;
        
        List<CampaignMember> memberList = [select id
                    from CampaignMember 
                    ];
                        
        
        System.assertEquals(memberList.size(),ledLst.size());
               
        Test.stopTest();
       
    }
    
    
     /*
      @name    testCreateLeadRelatedContEmail
      @date    30.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record to update lead office                             
     */ 
 
   static testMethod void testUpdateOfficeCountryCode() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
       
         //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();         
      
        
        test.startTest();
        //intialize all variable
        List<Lead> ledLst =new List<Lead>();
        List<Lead> ledLstToUpdate =new List<Lead>();
        
        //create Lead record from TestDataBuilder.
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email ='Jane.john@gmail.com'+i ;
            //led.CountryCode ='IN';
            led.Country = 'India';
            led.Country_State_Code__c ='IN-MH';
            ledLst.add(led);         
        }
        
        insert ledLst;
       
        for(Lead ldObj:[select office__C,countryCode,statecode from Lead where id in:ledLst]){
           
         
           System.assertNotEquals(ldObj.office__c, null, True);
           System.assertEquals(ldObj.CountryCode, 'IN');
            System.assertEquals(ldObj.statecode, 'MH');
            
        }
       
        //Update Lead record from TestDataBuilder.
        for(Integer i=0;i<50;i++){
            Lead led = ledLst.get(i);
            led.CountryCode ='US';
            led.Country_State_Code__c ='AA';
            //ledLstToUpdate.add(led);         
        }
       
        update ledLstToUpdate; 
       
        for(Lead ldObj:[select office__C,countrycode from Lead where id in:ledLstToUpdate]){
        
         System.assertEquals(ldObj.office__c,'MathWorks Natick');
            
        }
       
        test.stopTest();    
       
    }  
        
    /*
      @name    testInsertStateCodeByCountrystateCode
      @date    10.July.2015
      @author  Achana Lohar
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record to check if statecde is valid and update statecode by CountrystateCode.                              
     */ 
 
   static testMethod void SetStateCodeBycountryStateCodeTest() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
       
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
        
        test.startTest();
        //intialize all variable
        List<Lead> ledLst =new List<Lead>();
        List<Lead> ledLstToUpdate =new List<Lead>();
        
        //create Lead record from TestDataBuilder.
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='IN';
            led.Country_State_Code__c ='IN-MB';
            ledLst.add(led);         
        }
        
        insert ledLst;
       
        for(Lead ldObj:[select office__C,CountryCode,Country_State_Code__c,statecode from Lead where id in:ledLst]){
           
            System.assert(ldObj.statecode!='MB');
            System.assert(ldObj.CountryCode=='IN');
            System.assert(ldObj.Country_State_Code__c=='IN-MB');
            
        }
       
       //Update Lead record from TestDataBuilder.
        for(Integer i=0;i<50;i++){
            Lead led = ledLst.get(i);
            led.CountryCode ='US';
            led.Country_State_Code__c ='BadUSState';
            ledLstToUpdate.add(led);         
        }
       
        update ledLstToUpdate; 
      
       
        for(Lead ldObj:[select office__C,countrycode,statecode,Country_State_Code__c from Lead where id in:ledLstToUpdate]){
        
            System.assert(ldObj.statecode!='BadUSState');
            System.assert(ldObj.CountryCode=='US');
                       
        }
       
        //Update Lead record from TestDataBuilder.
        for(Integer i=0;i<50;i++){
            Lead led = ledLstToUpdate.get(i);
            led.CountryCode ='IN';
            led.Country_State_Code__c ='IN-MH';
                 
        }
       
        update ledLstToUpdate; 
       
        for(Lead ldObj:[select office__C,countrycode,statecode,Country_State_Code__c from Lead where id in:ledLstToUpdate]){
        
            System.assert(ldObj.statecode=='MH');
            System.assert(ldObj.CountryCode=='IN');
            System.assert(ldObj.Country_State_Code__c=='IN-MH');
            
        }
      
        test.stopTest();    
       
    }  
    
    /*
      @name    testInsertStateCodeByCountrystateCode
      @date    11.March.2016
      @author  Achana Lohar
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record to check if statecode is valid and update statecode by CountrystateCode.                              
     */ 
 
   static testMethod void SetStateCodeBycountryStateCodeForItalyTest() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
       
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
        
        test.startTest();
        //intialize all variable
        List<Lead> ledLst =new List<Lead>();
        List<Lead> ledLstToUpdate =new List<Lead>();
        
        //create Lead record from TestDataBuilder.
        for(Integer i=0;i<50;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='IT';
            led.Country_State_Code__c ='IT-VV';
            ledLst.add(led);         
        }
        
        insert ledLst;
       
        for(Lead ldObj:[select office__C,CountryCode,Country_State_Code__c,statecode from Lead where id in:ledLst]){
            System.debug('****'+ldObj.statecode);
            System.assertEquals(ldObj.statecode,'VV');
            System.assert(ldObj.CountryCode=='IT');
            System.assert(ldObj.Country_State_Code__c=='IT-VV');
        }

        test.stopTest();    
       
    }  
    
    
    
     /*
      @name    testsetLeadOwnerIfQueue
      @date    18.Dec.2015
      @author  Abhay Verma
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record having a Queue owner.                              
     */

   static testMethod void testsetLeadOwnerIfQueue() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
       
        //Inserting state code list custom settings
        custsettbuild.buildStateCodeList();
       
        //Creating Test data user.
        User usrObj = TestDataBuilder.buildTestUser(0);
        insert usrObj;

        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
        //create Group
        Group grp = TestDataBuilder.buildTestGroup('Lead');
        
        //create Account record from TestDataBuilder.

        for(Integer i=0;i<=2;i++){
            Account accL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accL.BillingCity ='Rio De Janeiro';
            accL.BillingCountry = 'Brazil';
            accL.BillingCountryCode ='BR';
            accL.BillingState ='Acre';
            accL.BillingStateCode = 'AC';
            accLLst.add(accL);         
        }
        //Inserting Account List.
        insert accLLst;
        
        //Query the account list.
        List<Account> accList = [SELECT Id FROM Account WHERE Id IN: accLLst];
        System.assertEquals(accList.size(), 3, True);
        
        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<=2;i++){
            Contact cont = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),accLLst[i].id);
            cont.AccountId=accLLst[i].id;
            cont.MailingCity = 'Bombay';
            cont.MailingCountry = 'India';
            cont.MailingCountryCode = 'IN';
            cont.MailingPostalCode ='400011';
            cont.MailingState ='Maharashtra';
            cont.MailingStateCode ='MH';
            cont.MailingStreet = 'MG Street';
            cont.County_Local__c = 'abc';
            cont.email = 'john@test.xyz'+i ;
            contLst.add(cont);         
        }
        
        //Inserting contact List.
        insert contLst;
        List<Contact> conList = [SELECT Id FROM Contact WHERE Id IN: contLst];
        System.assertEquals(conList.size(),3, True);
        
        //create Lead record from TestDataBuilder.
        System.debug('**UserInfo.getUserId()**' +UserInfo.getUserId());
        
        for(Integer i=0;i<=2;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.OwnerId = grp.Id;
            led.Status = 'Open';
            led.Email ='Jane.john'+i+'@test.xyz' ;
            led.CountryCode ='IN';
            led.Country_State_Code__c = 'MH';
            led.Contact__c = contLst[0].Id;
            led.Account__c = accLLst[0].Id;            
            led.Lead_Score__c='A1';
            ledLst.add(led);         
        }
       
        insert ledLst;
        
        List<Lead> updateleadLst =new List<Lead>();
        for(Lead l: ledLst){
            l.OwnerId__c = usrObj.Id;            
            updateleadLst.add(l);
        }
        
        
        Test.startTest();
            update updateleadLst;
        Test.stopTest();
        
        List<Lead> leadOwnersList = [select Id, ownerId,Lead_Requester__c from lead where id in :updateLeadLst];
        for(Integer i=0;i<=2;i++){
            System.assertEquals(leadOwnersList[i].ownerId, usrObj.Id);
            System.assertEquals(leadOwnersList[i].Lead_Requester__c, usrObj.Id);// fg 
            
        }
    }
    
    
    
}