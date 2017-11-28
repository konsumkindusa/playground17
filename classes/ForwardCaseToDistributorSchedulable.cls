/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *date Original: 13 May 2015, Last Modified:13 May 2015 
 *description : Batch class for forwarding case to distributor */

global with sharing class ForwardCaseToDistributorSchedulable implements Schedulable, Database.Batchable<sObject>{

    //String to hold query
    global  String query;
    global final String caseStatus='Cancelled';
    General_Settings__c settings ;

    List<case> caseListFR;
    List<case> caseListToUpdate;

    List <EmailTemplate> emailTempList;
    String tempEmailBody;

    SObjectType contactType;
    Map<String,Schema.SObjectField> ConfieldMap;

    //Map of Case Attchments
    Map<id,List<Attachment>> attchmentsMap;

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *date Original: 13 May 2015, Last Modified:13 May 2015 
     *description : Constructor which initialises the Query*/   
    global ForwardCaseToDistributorSchedulable(){
    
        attchmentsMap=new Map<id,List<Attachment>>();
        
        //Instantiate General Setting
        settings = General_Settings__c.getInstance();

        //Get all Contact fields
        contactType = Schema.getGlobalDescribe().get('Contact');
        ConfieldMap = contactType.getDescribe().fields.getMap();           

        //Query to get Cases
        query = 'SELECT ID,contactid,'+
                'Description,License__c,OS__c,Platform__c,Version__c,Release__c,Product_Lookup__c,Product_Lookup__r.Release__c,'+
                'Product_Lookup__r.Version__c,Product_Lookup__r.Name,';


        //Adding all contact fields in Query
        for(Schema.SObjectField feilds : ConfieldMap.values()) {

            query +='Contact.'+feilds+ ', ';

        }   

        query += 'contact.Account.Name FROM case where IsReadyForForwardingEmailToDistributor__c=true';
  
        //Query to get Template related to Distributor
        emailTempList = [SELECT Name, Body, Subject, Id FROM EmailTemplate WHERE Name LIKE '%Distributor Send Email%'];
        tempEmailBody = emailTempList[0].Body;
        


    }//ForwardCaseToDistributorSchedulable

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *date Original: 13 May 2015, Last Modified:113 May 2015 
     *description : Start method
     */
    global Database.QueryLocator start(Database.BatchableContext BC){


        return Database.getQueryLocator(query);

    }//start

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *date Original: 13 May 2015, Last Modified:113 May 2015 
     *description : BatchableContext Execute method
     */
    global void execute(Database.BatchableContext BC, List<Case> caseList){
     

        //Getting related list of attachments from cases
        List<Attachment> attchmentLst = [select Parentid,Name, Body, BodyLength from Attachment where parentid in:caseList];

        //fill out map
        for(Attachment attchObj:attchmentLst){

            if(!attchmentsMap.containsKey(attchObj.Parentid)){

                attchmentsMap.put(attchObj.Parentid,new List<Attachment>{attchObj});

            }
            else{

                attchmentsMap.get(attchObj.Parentid).add(attchObj);
            }

        }

        //List to store Messaging.SingleEmailMessage to send emails all at once
        List<Messaging.SingleEmailMessage> mailsToSendDistributor=new List<Messaging.SingleEmailMessage>();

        caseListFR=new List<case>();
        caseListToUpdate=new List<case>();

        for(case caseObj : caseList){

            //Check whether case contact is not null and contact's country code is not null
            if (caseObj.ContactId!=null && caseObj.contact.Country_Code__c!=null){

                system.debug(caseObj.contact.Country_Code__c+'caseObj.contact.Country_Code__c');

                //Getting respected record from forwarding rule custom setting 
                Forwarding_Rule__c fwdRule = Forwarding_Rule__c.getValues(caseObj.contact.Country_Code__c.toLowerCase());


                //Check forwarding rule is not null
                if (fwdRule != null){

                    //Check if it has MathWorks Office
                    if(!fwdRule.MathWorks_Office__c){

                        Messaging.Singleemailmessage mailToForward = new Messaging.Singleemailmessage();

                        //set Subject
                        String emailsubject = 'Web Service Request - '+fwdRule.Forwarding_Email_Address__c;

                        //set To Address
                        mailToForward.setToAddresses(new String[]{fwdRule.Forwarding_Email_Address__c}); 

                        //Set corresponding Forwarding_Email_Address__c from Forwarding_Rule__c as CC
                        mailToForward.setCcAddresses(new String[]{caseObj.contact.email});

                        mailToForward.setReplyTo(caseObj.contact.email);

                        //Set Email Subject
                        mailToForward.setSubject(emailsubject);

                        //Replace all Contact Merge Fields
                        while (tempEmailBody.contains('{!Contact.') == true){
                            if(tempEmailBody.contains('{!Contact.')){
                                for (Schema.Sobjectfield field : ConfieldMap.values()){
                                    system.debug('@@field:'+field);
                                    String mergefstring =  tempEmailBody.substring(tempEmailBody.indexOf('{'), tempEmailBody.indexOf('}') + 1);
                                    system.debug('@@mergefstring:'+mergefstring);
                                    if (mergefstring == '{!Contact.Account}'){
                                        string mergefvalue;
                                        if (caseObj.contact.AccountId != null){
                                            tempEmailBody = tempEmailBody.replace(mergefstring,caseObj.contact.Account.Name);   
                                        }
                                        else {
                                            tempEmailBody = tempEmailBody.replace(mergefstring,'');
                                        }
                                        break;
                                    }
                                    if (mergefstring == '{!Contact.MailingAddress}'){
                                        string mergefvalue;
                                        string mailingstreet = '';
                                        string mailingcity = ''; 
                                        string mailingstate = '';
                                        string mailingpostalcode = '';
                                        string mailingcountry = '';
                                        if (caseObj.contact.MailingStreet != null){ mailingStreet = caseObj.contact.MailingStreet; }
                                        if (caseObj.contact.MailingCity != null){ mailingCity = caseObj.contact.MailingCity; }
                                        if (caseObj.contact.MailingState != null){ mailingState = caseObj.contact.MailingState; }
                                        if (caseObj.contact.MailingPostalCode  != null){ mailingPostalCode = caseObj.contact.MailingPostalCode; }
                                        if (caseObj.contact.MailingCountry != null){ mailingCountry = caseObj.contact.mailingCountry; }
                                        string mailingaddress = mailingstreet + ' ' + mailingcity + ' ' + mailingstate + ' ' + mailingpostalcode + ' ' + mailingcountry;
                                        if (caseObj.contact.AccountId != null){
                                            tempEmailBody = tempEmailBody.replace(mergefstring,mailingaddress); 
                                        }
                                        else {
                                            tempEmailBody = tempEmailBody.replace(mergefstring,'');
                                        }
                                        break;
                                    }
                                    if ( mergefstring.contains( field.getDescribe().getName() ) ){
                                        string mergefvalue;
                                        if (caseObj.contact.get(field.getDescribe().getName()) == null){
                                            mergefvalue = '';
                                        }
                                        else {
                                            mergefvalue = String.valueof( caseObj.contact.get(field.getDescribe().getName() ) );
                                        }
                                        tempEmailBody = tempEmailBody.replace(mergefstring,mergefvalue);
                                        break;
                                    }
                                }
                            }
                        }

                        //Replace all identified Case merge fields
                        if(tempEmailBody.contains('{!Case.Subject}')){
                            tempEmailBody = tempEmailBody.replace('{!Case.Subject}', emailsubject);
                        }

                        if(tempEmailBody.contains('{!Case.Product_Lookup__c}')){

                            //list <Product2> prod = [Select Id,Name, Release__c, Version__c From Product2 Where Id = : caseObj.Product_Lookup__c limit 1];
                            if (caseObj.Product_Lookup__c != null){
                                tempEmailBody = tempEmailBody.replace('{!Case.Product_Lookup__c}', caseObj.Product_Lookup__r.Name);
                                if(tempEmailBody.contains('{!Case.Release__c}')){

                                    if (caseObj.Product_Lookup__r.Release__c != null){
                                        tempEmailBody = tempEmailBody.replace('{!Case.Release__c}', caseObj.Product_Lookup__r.Release__c);
                                    }

                                }
                                if(tempEmailBody.contains('{!Case.Version__c}')){

                                    if (caseObj.Product_Lookup__r.Version__c != null){
                                        tempEmailBody = tempEmailBody.replace('{!Case.Version__c}', caseObj.Product_Lookup__r.Version__c);
                                    }
                                }

                            }
                            else {
                                tempEmailBody = tempEmailBody.replace('{!Case.Product_Lookup__c}', '');
                                if(tempEmailBody.contains('{!Case.Release__c}')){
                                    tempEmailBody = tempEmailBody.replace('{!Case.Release__c}', '');
                                }
                                if(tempEmailBody.contains('{!Case.Version__c}')){
                                    tempEmailBody = tempEmailBody.replace('{!Case.Version__c}', '');
                                }
                            }
                        }
                        if(tempEmailBody.contains('{!Case.Platform__c}')){
                            if (caseObj.Platform__c != null){
                                tempEmailBody = tempEmailBody.replace('{!Case.Platform__c}', caseObj.Platform__c);
                            }
                            else{
                                tempEmailBody = tempEmailBody.replace('{!Case.Platform__c}', '');
                            }
                        }
                        if(tempEmailBody.contains('{!Case.OS__c}')){
                            if (caseObj.OS__c != null){
                                tempEmailBody = tempEmailBody.replace('{!Case.OS__c}', caseObj.OS__c);
                            }
                            else{
                                tempEmailBody = tempEmailBody.replace('{!Case.OS__c}', '');
                            }
                        }
                        if(tempEmailBody.contains('{!Case.License__c}')){
                            if (caseObj.License__c != null){
                                tempEmailBody = tempEmailBody.replace('{!Case.License__c}', caseObj.License__c);
                            }
                            else{
                                tempEmailBody = tempEmailBody.replace('{!Case.License__c}', '');
                            }
                        }
                        if(tempEmailBody.contains('{!Case.Description}')){
                            if (caseObj.Description != null){
                                tempEmailBody = tempEmailBody.replace('{!Case.Description}', caseObj.Description);
                            }
                            else {
                                tempEmailBody = tempEmailBody.replace('{!Case.Description}', '');
                            }
                        }


                        mailToForward.setPlainTextBody(tempEmailBody);

                        //set attchments
                        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

                        if(attchmentsMap.size()!=0 && attchmentsMap.get(caseObj.id)!=null){
                        
                            for (Attachment attchObj :attchmentsMap.get(caseObj.id))
                            { 
                                // Add to attachment file list
                                Messaging.Emailfileattachment emailFileObj = new Messaging.Emailfileattachment();
                                emailFileObj.setFileName(attchObj.Name);
                                emailFileObj.setBody(attchObj.Body);
                                fileAttachments.add(emailFileObj);
                            }
                        
                        }

                        //caseListToUpdate to set status to cancelled in finish method
                        caseListFR.add(caseObj);

                        if(!fileAttachments.isEmpty()){
                        //Set Attachments
                        mailToForward.setFileAttachments(fileAttachments);
                        }

                        //Adding Singleemailmessage object into mailsToSendDistributor List
                        mailsToSendDistributor.add(mailToForward);


                    }

                }

            }

        }//for

        //Sending emails to respective distributor
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailsToSendDistributor);


        //Set case status to Cancelled
        for(integer i=0;i<caseListFR.size();i++){

            if(results[i].isSuccess()){

                Case caseObjOBj=caseListFR[i];
                caseObjOBj.status=caseStatus;
                caseListToUpdate.add(caseObjOBj);

            }   

        }

        //Update Cases with Status Cancelled
        try{

            if(!caseListToUpdate.isempty())
                update caseListToUpdate;
        }
        catch(System.DmlException ex){

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
        }


    }//execute

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *date Original: 13 May 2015, Last Modified:113 May 2015 
     *description : SchedulableContext Execute method with the batch size as defined in the Territory Settings custom settings
     */
    global void execute(SchedulableContext ctx){

        //get the batch size from the custom settings and use it to execute the job
        Integer batchSize = Integer.ValueOf(settings.BatchSizeForForwardingCasesToDistributor__c);       
        ID batchprocessid = Database.executeBatch(this,batchSize);

    }//execute   

    /**
     *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *date Original: 13 May 2015, Last Modified:113 May 2015 
     *description : Finish method*/
    global void finish(Database.BatchableContext BC){




    }//finish

}//ForwardCaseToDistributorSchedulable