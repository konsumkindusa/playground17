/*
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade- Cloud Sherpas/Mathworks
 *@date Original: 19 May 2014, Last Modified: 24 Nov 2014
 *@description This  is Test class for 'ContactTriggerHandlerTest' class . 
 */

@isTest
public class ContactTriggerHandlerTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
        
    /*
      @name    createLatinConverForNonLatin 
      @date    19.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method to Implement test for Latin data.                              
     */

      static testMethod void createLatinConverForLatin() {
      
        //intialize all variable
        List<Contact> contLLst =new List<Contact>();
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //re-create general Custom Setting
        custsettbuild.buildGenSetting();
        
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();

        //create Contact record from TestDataBuilder.
        for(Integer i=0;i<1;i++){
            Contact contL = TestDataBuilder.buildTestContact(i,UserInfo.getUserId(),null);
            contL.MailingCity = 'Bombay';
            contL.MailingCountry = 'India';
            contL.MailingCountryCode = 'IN';
            contL.MailingPostalCode ='400011';
            contL.MailingState ='Maharashtra';
            contL.MailingStateCode = 'MH';
            contL.MailingStreet = 'MG Street';
            contL.County_Local__c = 'abc';
            contL.email = 'john@gmail.com';
            contL.MathWorks_Account_ID__c = '34656';
            
            contLLst.add(contL);
        }

        test.startTest();
        insert contLLst;
        test.stopTest();
        
        Contact con = [select MailingState 
                        from Contact 
                        where id =:contLLst[contLLst.size() - 1].id];
                        
        System.assertEquals('Maharashtra',con.MailingState);
      
    }   

    /*
      @name    createLatinConverForNonLatin 
      @date    19.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method to Implement test for Non Latin data.                              
     */

     static testMethod void createLatinConverForNonLatin() { 
     
        //intialize all variable
        List<Contact> contNLLst =new List<Contact>();
        
        //intialize all variable
        List<User> usrL =new List<User>();
        
        //create User record from TestDataBuilder.
 
        for(Integer i=0;i<1;i++){
            User usr = TestDataBuilder.buildTestUser(i);
            //usr.userroleid = '00Ee0000000RiUi';
            usrL.add(usr);
            }
        test.startTest();
        insert usrL;
        System.runas(usrL[0]) { 
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
       //re-create general Custom Setting
        custsettbuild.buildGenSetting();
        
              
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();  
 
        //create Contact record from TestDataBuilder.

        for(Integer i=0;i<1;i++){
            Contact contNL = TestDataBuilder.buildTestContact(i+10,usrL[0].id,null);
            contNL.MailingCity ='Ningbo';
            contNL.MailingCountry = 'China';
            contNL.MailingCountryCode = 'CN';
            contNL.MailingPostalCode ='400012';
            contNL.MailingState = '北京';
            contNL.MailingStateCode ='11';
            contNL.MailingStreet = '宮崎県';
            contNL.County_Local__c = 'xyz';
            contNL.email = 'bob@gmail.com';
            contNLLst.add(contNL);

        }
        
        insert contNLLst;
        
        Contact cont = [select Account_Name_Latin__c,City_Latin__c,
                        State_Province_Latin__c,    Street_Latin__c
                        from Contact 
                        where id =:contNLLst[contNLLst.size() - 1].id];
                        
        System.assertEquals('Beijing',cont.State_Province_Latin__c);
        
        List<Contact> contList = [select MailingCity, MailingCountrycode, MailingPostalCode,
                MailingStatecode ,MailingStreet , County_Local__c, email
                        from Contact where id in :contNLLst];

        //updating the conatct records 
        List<Contact> contactList = new List<Contact>();
        for(Contact contUpd: contList){
            contUpd.MailingCity ='Beijin';
            contUpd.MailingCountrycode = 'JP';
            contUpd.MailingPostalCode ='400011';
            contUpd.MailingStatecode ='28';
            contUpd.MailingStreet = '崎兵';
            contUpd.County_Local__c = 'pqr';
            contUpd.email= 'abc@gmail.com';
            contactList.add(contUpd);
        }
        CheckRecursive.run = true;
                
        update contactList;
        cont = [select Account_Name_Latin__c,City_Latin__c,
                        State_Province_Latin__c,    Street_Latin__c
                        from Contact 
                        where id =:contNLLst[contactList.size() - 1].id];
        System.AssertEquals('Hyogo', cont.State_Province_Latin__c);
        
            }
            test.stopTest();
        }
   /*
      @name    createLatinConverForNonLatin 
      @date    2 April 2015
      @author  Sagar Talele
      @param   none.
      @return  Void. 
      @description Method to Implement test for coping  Latin city and street data from Account to contact.                              
     */
    static testMethod void testLatinDataFromAccountOnContact(){
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //re-create general Custom Setting
        custsettbuild.buildGenSetting();
        
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        //intialize all variable
        List<Account> acctList = new List<Account>();
        List<Contact> contNLLst = new List<Contact>();
        User usr = TestDataBuilder.buildTestUser(1);
        insert usr;
        
        for(Integer i=0;i<3;i++){
            Account accObj = TestDataBuilder.buildTestAccount(i,usr.Id);
            accObj.Account_Street_Latin__c = '12 Oscars WayApt 12 A';
            accObj.Account_City_Latin__c = 'Maynard';
            accObj.Account_State_Province_Latin__c ='Massachusetts';
            acctList.add(accObj);
        }
         test.startTest();
        insert acctList;
        
         //create Contact record from TestDataBuilder.
        for(Integer i=0;i<3;i++){
            Contact contNL = TestDataBuilder.buildTestContact(i,usr.Id,acctList[i].Id);
            contNLLst.add(contNL);
        }
        
        insert contNLLst;
        Contact cont=[Select Id,MailingCity,MailingStreet,Street_Latin__c,City_Latin__c from Contact where id=:contNLLst[0].id];
         System.assertEquals(cont.MailingCity,acctList[0].BillingCity);
         System.assertEquals(cont.MailingStreet,acctList[0].BillingStreet);
         System.assert(acctList[0].BillingCity!=null);
         System.assert(acctList[0].BillingStreet!=null);
         System.assert(acctList[0].BillingState!=null);
         System.assert(acctList[0].BillingCountry!=null);
         System.assertEquals(cont.MailingCity,acctList[0].BillingCity);
         System.assertEquals(cont.Street_Latin__c,acctList[0].Account_Street_Latin__c);
         System.assertEquals(cont.City_Latin__c,acctList[0].Account_City_Latin__c);
         test.stopTest(); 
    }
   /*
      @name    testUpdateAccountFromContactToLead  
      @date    31 March 2016
      @author  Haigang Wu
      @param   none.
      @return  Void. 
      @description in order to execute Story# 1418335.                              
     */
    static testMethod void testUpdateAccountFromContactToLead(){
		String kwncont = 'Known Contact';
        
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

        for(Integer i=0;i<2;i++){
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

        for(Integer i=0;i<2;i++){
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
        
        for(Integer i=0;i<2;i++){
            Lead led = TestDataBuilder.buildTestLead(i,kwncont);
            led.Email ='Jane.john@gmail.com'+i ;
            led.CountryCode ='US';
            led.Country_State_Code__c = 'AK';
            led.Contact__c = contLst[i].id;
            ledLst.add(led);         
        }
        insert ledLst;

        Lead led = [select Account__c,Contact__c,RecordTypeId,currencyISOCode 
                    from Lead 
                    where id =:ledLst[0].id];
                        
        System.assert(led.Account__c == accLLst[0].id);

        test.startTest();
        contLst[0].AccountId = accLLst[1].id;
        update contLst[0];
        test.stopTest();
        
        led = [select Account__c,Contact__c,RecordTypeId,currencyISOCode 
                    from Lead 
                    where id =:ledLst[0].id];
                        
        System.assert(led.Account__c == accLLst[1].id);
    }
}