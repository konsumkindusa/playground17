/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:   07 Aug 2015, Last Modified:21 Oct 2015
 *@description:     Class to handle delegated DML operations for Enrollment object.
 */
 
 public with sharing class EnrollmentDML{
 
     /**
     *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: 
     *@date Original: 19 Oct 2015, Last Modified: 21 Oct 2015
     *@description: Method that avoid duplicate enrollments for the same contact in a class
     */
     public void checkDuplicateEnrollments(List<Enrollment__c> enrolLst){
         
         Logger.push('checkDuplicateEnrollments','EnrollmentDML');
         //a map collection with class as key and set of enrollees as values
         map<id,Set<id>> enrollmentObjMap = new map<id,Set<id>>();
         //set of contacts(enrollees)
         Set<id> enroleeContactIds = new Set<id>();
         Set<id> enrolIds = new Set<id>();
         List<Enrollment__c> enrollObjLst = new List<Enrollment__c>();
         String cancelledstatus = System.Label.Enrollment_Status_Cancelled;
         
         //Get Enrollee in Set enroleeIds
         for(Enrollment__c enrlObj : enrolLst){
            enroleeContactIds.add(enrlObj.Enrollee_Name__c);
            enrolIds.add(enrlObj.id);
         }  
         
         
         enrollObjLst = [select id,Enrollee_Name__c,Class__c,Enrollment_Status__c from Enrollment__c where Enrollee_Name__c in: enroleeContactIds and Enrollment_Status__c != 'Cancelled'  ];
       
         for(Enrollment__c enrlObj : enrollObjLst){
         
             if(!enrolIds.contains(enrlObj.id)) {
             
                 if(enrollmentObjMap.containsKey(enrlObj.Class__c)){
                    enrollmentObjMap.get(enrlObj.Class__c).add(enrlObj.Enrollee_Name__c);
                 }
                 else{
                     
                     enrollmentObjMap.put(enrlObj.Class__c,new Set<id>{enrlObj.Enrollee_Name__c}); 
                 }
             
             }
         }
         
         system.debug(enrollmentObjMap+'enrollmentObjMap');
         
         
         for(Enrollment__c enrlObj : enrolLst){
            
            //Check if there is already enrollments for the same contact
            if(enrollmentObjMap.containsKey(enrlObj.Class__c) 
                  && enrollmentObjMap.get(enrlObj.Class__c).contains(enrlObj.Enrollee_Name__c)){
                  
                enrlObj.addError(Label.Do_not_allow_duplicate_enrollments_for_the_same_contact);
              
            }
         }  
         
         Logger.pop();
     }
    
     /**
     *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
     *@date Original: 07 Aug 2015, Last Modified: 7 Sep 2015
     *@description: Method that handles Dml events for Enrollment object.
     */
     public void checkMaxEnrollmentOnClass(List<Enrollment__c> enrolLst,boolean isUpdate){         
         Logger.push('checkMaxEnrollmentOnClass','EnrollmentDML');
         //Map contain Id of Enterprise Training Agreement Object and Max Seat Size.
         Map<Id, Decimal> etaMaxSeatMap = new Map<Id, Decimal>();
         //Set of Class associated to triggered Records.
         Set<Id> clsRecIdSet = new Set<Id>();
         //Set of Enterprise Training Agreement associated to triggered record.
         Set<Id> etaRecIdSet = new Set<Id>();
         
         //Filling the Set of Class Id.
         for(Enrollment__c enrolObj : enrolLst){
             clsRecIdSet.add(enrolObj.class__c);
             etaRecIdSet.add(enrolObj.Enterprise_Training_Agreement__c);
         }

         // Abhay Verma - 5/3/2016 - START
         List<Enterprise_Training_Agreement__c> enrollmentMaxseatList = [SELECT Id, Max_Seats__c FROM Enterprise_Training_Agreement__c WHERE Id IN :etaRecIdSet];

         for(Enterprise_Training_Agreement__c eta : enrollmentMaxseatList) {
          etaMaxSeatMap.put(eta.Id, eta.Max_Seats__c);
         }
         
         Map<Id, Map<Id, Integer>> etaClassCountMap = TrainingUtil.getConsumedSeatCountForETA(etaRecIdSet, clsRecIdSet);
         for(Enrollment__c enrlObj : enrolLst) {
            Map<Id, Integer> classSeatCountMap = etaClassCountMap.get(enrlObj.Enterprise_Training_Agreement__c);

            Decimal etaMaxSeat = etaMaxSeatMap.get(enrlObj.Enterprise_Training_Agreement__c);

            if(classSeatCountMap != null) {
              Integer seatsTaken = classSeatCountMap.get(enrlObj.Class__c) == null ? 0 : classSeatCountMap.get(enrlObj.Class__c);
              if(isUpdate) {
                if(seatsTaken > etaMaxSeat) {
                  enrlObj.addError(System.Label.Max_Enrollment_Error_Message);
                }
              } else {
                if(seatsTaken >= etaMaxSeat) {
                  enrlObj.addError(System.Label.Max_Enrollment_Error_Message);
                }
              }
            } else if(etaMaxSeat == 0) {
              enrlObj.addError(System.Label.Max_Enrollment_Error_Message);
            }         
         }
         // Abhay Verma - 5/3/2016 - END
         Logger.pop();
     }
         /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: kishore AN - Cloud Sherpas/Mathworks
     *@date Original: 08 Aug 2015, Last Modified: 25 Aug 2015
     *@description: Method that handles Dml events for Enrollment object for sending Email notification.
     *@revision: Removed the code related to creation of task after the email notification is sent as the email appears in the activity history.
     */
     public void CheckAndSendEmailNotification(Set<Id> enrolSet){
           
           Logger.push('CheckAndSendEmailNotification','EnrollmentDML');
           //instantiating a map of string as akey
           Map<String,String> fieldNameToEmailTempNameMap = new Map<String,String>();
           //fill map with field name as a key
           Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Enrollment__c.fields.getMap();
           //instantiating Messaging.SingleEmailMesage List
           List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
           //instantiating Enrollment__c List
           List<Enrollment__c> enrollList = new List<Enrollment__c>();
           //instantiating map of string as key
           Map<String,EmailTemplate> emailTempNameToETempMap = new Map<String,EmailTemplate>();
           //instantiating EmailTemplate List
           List<EmailTemplate> emailtempList = new  List<EmailTemplate>();
           //instantiating Enrollment__c List
           List<Enrollment__c> enrollUpdatedList = new List<Enrollment__c>();
           //instantiating Task List
           List<Task> taskList = new List<Task>();
           //instantiating a list of org emails
           List<OrgWideEmailAddress> orgEmailList = new List<OrgWideEmailAddress>();
           //Map with sponsor email id as a key  and values as OrgWideEmailAddress 
           Map<String,OrgWideEmailAddress> sponsorEmailToOrgEmailAddressMap = new Map<String,OrgWideEmailAddress>();
           //Map with enrollment id as Key and Email template Names as a values
           Map<Id,Map<String,String>>  enrollIdToEmailTemplateNameMap = new Map<Id,Map<String,String>> ();
           //complete set of all values of enrollIdToEmailTemplateNameMap
           Set<String> completeEmailtempSet = new Set<String>();
           //Map of email template name as a key
           Map<String,id> emailtemplateToEmailTempIdMap = new Map<String,id>();
           //Map of baseEmailTemplateName as a key
           Map<String,String> baseTemplateNameToCompleteTempNameMap = new Map<String,String>();
           //Map of enrollment Id as a key and enrollment fields as a value
           Map<Id,set<String>> enrollIdToFieldsMap = new Map<Id,set<String>>();
           //Map of Enrollment Id as a key and values as a enrollment Object
           Map<Id,Enrollment__c> enrollIdToEnrollmentMap = new Map<Id,Enrollment__c>();
           //Map of Enrollment Id as a key and values as a enrollment Object for task those has emailtempalte
           Map<Id,Enrollment__c> enrollIdToEnrollmentForTaskMap = new Map<Id,Enrollment__c>();
           //String for storing email template name
            String completeEmailtempName;
           //Get Email template name from custom setting
           list<Email_Template_Selection_Settings__c> emailTemplateSelectionList = Email_Template_Selection_Settings__c.getAll().Values();
          
           //Get Email Address from custom setting
           list<EmailAddressForSponsorOffice__c> emailAddressForSponsorOffice = EmailAddressForSponsorOffice__c.getAll().Values();
           
           //Check if there are any routing entries
           if(!emailTemplateSelectionList.isEmpty() && emailTemplateSelectionList != NULL){
                //iterate over Email_Template_Selection_Settings__c  custom setting to fill map
                for(Email_Template_Selection_Settings__c emailtempObj : emailTemplateSelectionList ){
                    //check map key and values not null 
                    if(emailtempObj.FieldName__c != '' && emailtempObj.FieldName__c!= NULL  
                            && emailtempObj.Email_Template_Name__c !='' &&  emailtempObj.Email_Template_Name__c != NULL){
                            if(!fieldNameToEmailTempNameMap.containsKey(emailtempObj.FieldName__c) && schemaFieldMap.containsKey(emailtempObj.FieldName__c)){
                                fieldNameToEmailTempNameMap.put(emailtempObj.FieldName__c,emailtempObj.Email_Template_Name__c);
                            }//if
                    }//if
                
                }//for
            
           }//if
            
           system.debug('**fieldNameToEmailTempNameMap**'+fieldNameToEmailTempNameMap);
           system.debug('**fieldNameToEmailTempNameMapValues**'+fieldNameToEmailTempNameMap.values());
            
           //query the field of Enrollment which is present in custom setting
           String query = 'Select ';
           for(String sObj : fieldNameToEmailTempNameMap.keyset()){
                 query +=  sObj + ', '; 
           }
           query += 'Id,Enrollee_Name__c,Class__r.Sponsor_Office__r.Email__c,Class__r.Sponsor_Office__r.Name,Class__r.Class_Format_Email_Template__c,Enrollee_Name__r.email,Recordtype.DeveloperName,Class__r.Language__r.Language_Code__c From Enrollment__c Where id In :enrolSet';
           enrollList = Database.query(query);
           System.debug('**enrollList**'+enrollList);
           
             
           //query for Org Email ids
           orgEmailList = [SELECT Id,Address,DisplayName  FROM OrgWideEmailAddress];
           System.debug('**orgEmailList **'+orgEmailList );
             
           if(!orgEmailList.IsEmpty()){
               //fill map which contains org id as value
               for(OrgWideEmailAddress  orgEmailObj : orgEmailList ){
                 
                     if(!sponsorEmailToOrgEmailAddressMap.containsKey(orgEmailObj.Address)){
                         sponsorEmailToOrgEmailAddressMap.put(orgEmailObj.Address,orgEmailObj);
                     }//if
               }//for
               system.debug('**sponsorEmailToOrgEmailAddressMap**'+sponsorEmailToOrgEmailAddressMap);
           }//if
            
           For(String baseEmialTemplate : fieldNameToEmailTempNameMap.values()){
               for(Enrollment__c enrollObj  : enrollList){
                   System.debug('****'+enrollObj.Class__r.Sponsor_Office__r.Name);
                   System.debug('**ponsor_Office_else**'+enrollObj.Class__r.Sponsor_Office__r.Name);
                   completeEmailtempName = baseEmialTemplate +'_'+enrollObj.Class__r.Class_Format_Email_Template__c+'_'+enrollObj.Class__r.Language__r.Language_Code__c+'_'+ enrollObj.Class__r.Sponsor_Office__r.Name.replace('-', '_') ;
                   if(!enrollIdToEmailTemplateNameMap.containskey(enrollObj.id)){
                         enrollIdToEmailTemplateNameMap.put(enrollObj.Id,new Map<String,String>{baseEmialTemplate => completeEmailtempName});
                   }//if
                   else{
                         enrollIdToEmailTemplateNameMap.get(enrollObj.Id).put(baseEmialTemplate,completeEmailtempName);
                   }//else
                   completeEmailtempSet.add(completeEmailtempName);
               }//for
           }//for
           system.debug('**enrollIdToEmailTemplateNameMap**'+enrollIdToEmailTemplateNameMap);
           System.debug('*completeEmailtempSet**'+completeEmailtempSet);
           /*for(set<String> setObj : enrollIdToEmailTemplateNameMap.values()){
                completeEmailtempSet.addAll(setObj);
           }*/
           System.debug('**completeEmailtempSet**'+completeEmailtempSet);
           emailtempList = [SELECT Id,Name,DeveloperName FROM EmailTemplate WHERE DeveloperName  In :completeEmailtempSet];
           System.debug('**emailtempList**'+emailtempList );
           //get emailtemplate Id for respective emailtemplate name
           for(EmailTemplate emailTempObj :emailtempList){
               if(!emailtemplateToEmailTempIdMap.containsKey(emailTempObj.DeveloperName)){
                      emailtemplateToEmailTempIdMap.put(emailTempObj.DeveloperName,emailTempObj.id);
               }
           }//for
           if(!enrollList.IsEmpty()){
               //logic for From Address
               for(Enrollment__c enrollObj : enrollList){
                   for(String fieldObj : fieldNameToEmailTempNameMap.keyset()){
                       System.debug('**enrollObjFieldsVal**'+enrollObj.get(fieldObj));
                       if(enrollObj.get(fieldObj) == true){
                           system.debug('**In If**');
                           String[] toAddresses = new String[] {enrollObj.Enrollee_Name__r.email};
                           System.debug('**toAddresses**'+toAddresses);
                           String emailTemp = fieldNameToEmailTempNameMap.get(fieldObj);
                           Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                               
                           String tempName = fieldNameToEmailTempNameMap.get(fieldObj);
                           baseTemplateNameToCompleteTempNameMap = enrollIdToEmailTemplateNameMap.get(enrollObj.Id);
                           Id emailtempId;
                           String emailTemplateName;
                           String emailTempName;
                           if(baseTemplateNameToCompleteTempNameMap.containsKey(tempName)){
                                    emailTempName = baseTemplateNameToCompleteTempNameMap.get(tempName);
                                    emailtempId = emailtemplateToEmailTempIdMap.get(emailTempName);
                                    emailTemplateName = emailTempName;
                                   
                               }
                           
                           system.debug('**emailtempId **'+emailtempId );
                           if(emailtempId !=null ){
                               //if the email template exists, build the email based on the template and sponsor office
                               email.setTemplateId(emailtempId);
                               System.debug('**emailtempId**'+emailtempId);
                               if(enrollObj.Class__r.Sponsor_Office__r.Email__c == null && enrollObj.Class__r.Sponsor_Office__r.Email__c == '' && !sponsorEmailToOrgEmailAddressMap.containsKey(enrollObj.Class__r.Sponsor_Office__r.Email__c)){
                                   email.setOrgWideEmailAddressId(sponsorEmailToOrgEmailAddressMap.get(emailAddressForSponsorOffice[0].Email__c).Id);
                               }
                               else{
                                   if(sponsorEmailToOrgEmailAddressMap.containsKey(enrollObj.Class__r.Sponsor_Office__r.Email__c)){
                                       email.setOrgWideEmailAddressId(sponsorEmailToOrgEmailAddressMap.get(enrollObj.Class__r.Sponsor_Office__r.Email__c).Id);
                                   }
                               }
                               system.debug('**OrgId**'+sponsorEmailToOrgEmailAddressMap.get(enrollObj.Class__r.Sponsor_Office__r.Email__c));
                               email.setWhatId(enrollObj.Id);
                               email.setToAddresses(toAddresses);
                               System.debug('**email**'+email);
                               email.setTargetObjectId(enrollObj.Enrollee_Name__c);
                                
                              
                               emailList.add(email);
                               if(!enrollIdToEnrollmentForTaskMap.containsKey(enrollObj.Id)){
                                   enrollIdToEnrollmentForTaskMap.put(enrollObj.Id,enrollObj);
                               }//if
                           }//If
                           else{
                               //log if the email template according to the naming convention does not exist
                               Logger.debugException('Customer Training Notification Error: Email Template does not exist : '+emailTemplateName + '. Error sending for Enrollment Id: '+enrollObj.Id+' on Event: '+fieldObj );
                           }
                           if(!enrollIdToFieldsMap.containsKey(enrollObj.Id)){
                               enrollIdToFieldsMap.put(enrollObj.Id,new set<String>{fieldObj});
                           }
                           else{
                                enrollIdToFieldsMap.get(enrollObj.Id).add(fieldObj);
                           }
                           if(!enrollIdToEnrollmentMap.containsKey(enrollObj.Id)){
                                enrollIdToEnrollmentMap.put(enrollObj.Id,enrollObj);
                           }//if
                       }//if
                   }//for
               }//for
           }//If
           try{
                //send all emails from the transaction
                Messaging.sendEmail(emailList,false);
            }
            catch(System.EmailException ex){
                Logger.debugException('THERE WAS AN ISSUE TO SEND MAIL TO THE DESTINATION : '+ex.getMessage());
            }
           
          
           for(Id enrollIdObj : enrollIdToFieldsMap.keyset()){
               Enrollment__c enroll = new Enrollment__c();
               enroll.Id = enrollIdObj ;
                
               set<String> fSet = enrollIdToFieldsMap.get(enrollIdObj);
               for(String fname : fSet){
                    //reset any of the event flags back to false
                     enroll.put(fname ,false);                     
               }//for
               enrollUpdatedList.add(enroll);
           }//for            
           
           try{
               if(!enrollUpdatedList.isEmpty()){
                   //update the event flags back to false
                   update enrollUpdatedList;
               }
           }
           catch(DMLException ex){
               for (Integer i = 0; i < ex.getNumDml(); i++) {
                   //Process exception here
                   Logger.debugException('Error in Updating Record for Enrollment Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
               }
           }
           Logger.pop(); 
     }
     
    /**
     *@author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@date Original: 21 Oct 2015, Last Modified: 21 Oct 2015
     *@description: get EnrollmentDupCheck_Setting__mdt cust meta data type
     */
     public Set<string> getClassFormatsToSkipCheckingEnrolDups(){
         Logger.push('getClassFormatsToSkipCheckingEnrolDups','EnrollmentDML');
         
         Set<string> FormatOfClassSet = new Set<string>();
         List<EnrollmentDupCheck_Setting__mdt> EnrollmentDupCheckLst = [select Id,Format_Of_Class__c from EnrollmentDupCheck_Setting__mdt];
         
         for(EnrollmentDupCheck_Setting__mdt enrlDupCheckObj:EnrollmentDupCheckLst){
             FormatOfClassSet.add(enrlDupCheckObj.Format_Of_Class__c);
         }
         
         Logger.pop(); 
         return FormatOfClassSet;        
     }
 }