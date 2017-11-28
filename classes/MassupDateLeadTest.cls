/*
 *@author Original: Jaspreet Monga - Mathworks
 *@date Original:  30 May 2014, Last Modified: 18 June 2014
 *@description This  is Test class for 'LeadTriggerHandler' class . 
 */

@isTest 
public with sharing class MassupDateLeadTest {
     public static String kwncont = 'Known Contact';
     public static String unkwncont = 'Unknown Contact';
     //re-create custom setting test records when running the test class
     static CustomSettingsBuilder custsettbuild = new CustomSettingsBuilder();
      /*
      @name    testUpdateLead
      @date    4/6/2015
      @author  Jaspreet Monga
      @param   none.
      @return  Void. 
      @description Method to Implement test for Lead Record for mass update.                              
     */ 
     
    static testMethod void testCreateLead() {
        
        //Inserting Bypass trigger custom setting
        custsettbuild.buildBypassTriggerSettings();
        
        //Inserting Country custom settings
        custsettbuild.buildcontSett();
        
        //intialize all variable
        List<Account> accLLst =new List<Account>();
        List<Contact> contLst =new List<Contact>();
        List<Lead> ledLst =new List<Lead>();
        
       //create Account record from TestDataBuilder.

        for(Integer i=0;i<100;i++){
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

        for(Integer i=0;i<100;i++){
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
            cont.Birthdate = Date.Today();
            contLst.add(cont);         
        }

        insert contLst;
        
        //create Lead record from TestDataBuilder.

        for(Integer i=0;i<100;i++){
            Lead led = TestDataBuilder.buildTestLead(i,unkwncont);
            led.Email = 'abc@gmail.com';
            ledLst.add(led);         
        }
        
        insert ledLst;
        
        for(Lead led: ledLst){
            led.lead_follow_up_date__c  = Date.today();
        }
        massupdatelead objmassupdatelead = new massupdatelead();
        
        objmassupdatelead.objContactDatefield = contLst[0];
        
        test.startTest();
        PageReference pageRef = new PageReference('/apex/massupdatelead?Ids='+ledLst[0].id);
        update ledLst;
        Test.setCurrentPage(pageRef); 
        
        objmassupdatelead.getobjContactDatefield();
        objmassupdatelead.getlistLeadDisplayOnPage();
        objmassupdatelead.getstatusOptions();
        objmassupdatelead.getoutcomeOptions();
        objmassupdatelead.setobjContactDatefield();
       // objmassupdatelead.setOutcomeValues();
       // objmassupdatelead.setStatusValues();
        objmassupdatelead.methodUpdateValues();
        objmassupdatelead.cancel();
        test.stopTest();
           
        
       
    }

}