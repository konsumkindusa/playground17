/*
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade- Cloud Sherpas/Mathworks
 *@date Original: 15 May 2014, Last Modified: 2nd Dec 2014
 *@description This is Test class for 'AccountTriggerHandler' class . 
 */

@isTest
public class AccountTriggerHandlerTest {
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
   /*
 *@author Original: Faina Gorelik AtTask 1919914
 *@date Original: 20 Feb 2017
 *@description This is Test class for Count Children on CPN 
 */
 
    /*static testMethod void testCPNAccount (){
            //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //re-create general Custom Setting
        custsettbuild.buildGenSetting();
        
        //intialize all variable
        List<Account> accLst =new List<Account>();
        List<Account> accChildLst = new List<Account>();

        //create CPN Account record from TestDataBuilder 

        Account acct = TestDataBuilder.buildTestAccount(0,UserInfo.getUserId());
        acct.Name = 'CPNACcount';
        acct.Is_Corporate_Parent__c = true;
        accLst.add(acct);
        insert accLst;
        
        test.startTest(); 
      //  create child accounts for CPN
         for(Integer i=0;i<3;i++){
            Account childac = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            childac.Name = 'ChildAccountTest' + i;
            childac.BillingCity ='Boston';
            childac.BillingCountry = 'United States';
            childac.BillingCountryCode = 'US';
            childac.BillingPostalCode ='400011';
            childac.BillingState ='New York';
            childac.BillingStateCode = 'NY';
            childac.BillingStreet = 'Test Street';
            childac.County__c = 'xyz';
            childac.Siebel_Territory_ID__c = '1-TEST';
            childac.Corporate_Parent_Name__c = acct.Id;
            accChildLst.add(childac);
            
       } 
        insert accChildLst;
    //    test.startTest();     
        Account acc = [Select Child_Accounts__c from Account 
                       where id =:accLst[0].Id];
        System.assertEquals(3,acc.Child_Accounts__c);
        
        Account accremove = [select id, Corporate_Parent_Name__c from account where id =: accChildLst[0].id ]; 
        id parentid =  accremove.Corporate_Parent_Name__c;
        accremove.Corporate_Parent_Name__c = Null;
        update accremove;
        Account accparent = [Select Child_Accounts__c from Account 
                             where id =:parentid];
        System.assertEquals(2,accparent.Child_Accounts__c);
        test.stopTest();
        
    }
*/
    //fg end
    /*
      @name    testCreateLatinConverForNonLatin 
      @date    16.May.2014
      @author  Divya Gawade
      @param   none.
      @return  Void. 
      @description Method Implement test for Non-Latin data.                              
     */
   
    static testMethod void testCreateLatinConverForNonLatin() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //re-create general Custom Setting
        custsettbuild.buildGenSetting();
        
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        
        //intialize all variable
        List<Account> accNLLst =new List<Account>();

        //create Account record from TestDataBuilder.

        for(Integer i=0;i<3;i++){
            Account accNL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accNL.Name = 'SmithTest' + i;
            accNL.BillingCity ='Ningbo';
            accNL.BillingCountry = 'China';
            accNL.BillingCountryCode = 'CN';
            accNL.BillingPostalCode ='400011';
            accNL.BillingStatecode ='11';
            accNL.BillingState ='北京';
            accNL.BillingStreet = '宮崎県';
            accNL.County__c = 'xyz';
            accNL.Siebel_Territory_ID__c = '1-TEST';

            accNLLst.add(accNL);

        }
        test.startTest();
       
        insert accNLLst;
      
        test.stopTest();

        Account acc = [select Account_Name_Latin__c,Account_City_Latin__c, 
                       Account_State_Province_Latin__c,Account_Street_Latin__c,Account_County_Latin__c
                       from Account 
                       where id =:accNLLst[0].id];   
                            
        System.assertEquals('Beijing',acc.Account_State_Province_Latin__c);

        //updating account records 

        for(Account accUpd: accNLLst){
            accUpd.BillingCity ='Ningbo2';
            accUpd.BillingCountrycode = 'JP';
            accUpd.BillingPostalCode ='400011';
            accUpd.BillingStatecode ='28';
            accUpd.BillingState ='兵庫県';
            accUpd.BillingStreet = '宮兵';
            accUpd.County__c = 'pqr';
            accUpd.Siebel_Territory_ID__c = null;

        }
        update accNLLst ; 

    }

    /*
      @name    testCreateLatinConverForNonLatinMaster 
      @date    14.Aug.2016
      @author  Haigang Wu
      @param   none.
      @return  Void. 
      @description Method Implement test for Non-Latin data.                              
     */

    static testMethod void testCreateLatinConverForNonLatinMaster() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //re-create general Custom Setting
        custsettbuild.buildGenSetting();
        
        //re-create terrritory Custom Setting using master id
        custsettbuild.buildTerritorySettingsMaster();
        
        //re-create address latin conversion Custom Setting
        custsettbuild.buildAddressLatinTranslation();
        
        //intialize all variable
        List<Account> accNLLst =new List<Account>();

        //create Account record from TestDataBuilder.

        for(Integer i=0;i<3;i++){
            Account accNL = TestDataBuilder.buildTestAccount(i,UserInfo.getUserId());
            accNL.Name = 'SmithTest' + i;
            accNL.BillingCity ='Ningbo';
            accNL.BillingCountry = 'China';
            accNL.BillingCountryCode = 'CN';
            accNL.BillingPostalCode ='400011';
            accNL.BillingStatecode ='11';
            accNL.BillingState ='北京';
            accNL.BillingStreet = '宮崎県';
            accNL.County__c = 'xyz';
            accNL.Master_Territory_ID__c = 'T-' + i;

            accNLLst.add(accNL);

        }
        test.startTest();
       
        insert accNLLst;
      
        test.stopTest();

        Account acc = [select Account_Name_Latin__c,Account_City_Latin__c, 
                       Account_State_Province_Latin__c,Account_Street_Latin__c,Account_County_Latin__c
                       from Account 
                       where id =:accNLLst[0].id];   
                            
        System.assertEquals('Beijing',acc.Account_State_Province_Latin__c);

        //updating account records 

        for(Account accUpd: accNLLst){
            accUpd.BillingCity ='Ningbo2';
            accUpd.BillingCountrycode = 'JP';
            accUpd.BillingPostalCode ='400011';
            accUpd.BillingStatecode ='28';
            accUpd.BillingState ='兵庫県';
            accUpd.BillingStreet = '宮兵';
            accUpd.County__c = 'pqr';
            accUpd.Master_Territory_ID__c = null;

        }
        update accNLLst ; 

    }

}