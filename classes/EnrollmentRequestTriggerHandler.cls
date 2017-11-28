/** 
 *@author Original: Archana Suryawanshi - Cloud Sherpas/Mathworks, Last Modified: Archana Suryawanshi  - Cloud Sherpas/Mathworks
 *@date Original: 4 April 2015, Last Modified:  27 April 2015
 *@description This  is handler class for 'EnrollmentRequestMasterTrigger' . 
 */ 
public class EnrollmentRequestTriggerHandler {
    
     /**
     * @author Original: 
     * @date Original:,Last Modified: 
     * @description Method that handles before insert trigger event on the Enrollment Request object
     * @param Account A collection of Enrollment Request to create new Enrollment Request
     */
    public void onBeforeInsert(List<Enrollment_Request__c> List_EnrollmentReq){ 
        
        Logger.push('onBeforeInsert', 'EnrollmentRequestTriggerHandler');
        
        //List to store Enrollment_Request__c having source 'Bulk Enrollment'
        List<Enrollment_Request__c> eReqBList = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqValidETALst = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqValidClassLst = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqValidContactLst = new List<Enrollment_Request__c>();
        
        EnrollmentRequestDml eReqDML = new EnrollmentRequestDml();
        
        //Validate ETA on Enrollment Request
        if(!List_EnrollmentReq.isEmpty()){
            eReqValidETALst = eReqDML.validateETAOnEnrollmentReq(List_EnrollmentReq);
        }
        
        //Validate Class on Enrollment Request
        if(!eReqValidETALst.isEmpty()){
            eReqValidClassLst = eReqDML.validateClassOnEnrollmentReq(eReqValidETAlst);
        }
        
        //Validate Contact Enrollment Request
        if(!eReqValidClassLst.isEmpty()){
            eReqValidContactLst = eReqDML.validateContactOnEnrollmentReq(eReqValidClassLst);
        }

        // Pranav Raulkar | 4-May-2016 | START
        // Set the Batch Id on enrollment request to a GUID for all enrollment requests created in a single context
        eReqDML.setGUIDOnEnrollmentRequests(List_EnrollmentReq);
        // Pranav Raulkar | 4-May-2016 | END

        //call batch for eReqValidContactLst to do enrollment processing for those that are not exceptions and not waiting for a CDS Lookup 
        
        Logger.pop();        
    }
    
     /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description Method that handles before update trigger event on the Enrollment Request object
     * @param oldmap Enrollment Request records with old values
     * @param newmap Enrollment Request records with new values
     */
    public void onBeforeUpdate(map<Id, Enrollment_Request__c> oldmap, map<Id, Enrollment_Request__c> newmap){
        Logger.push('onBeforeUpdate', 'EnrollmentRequestTriggerHandler');
        System.debug('**onBeforeUpdate**'+newmap);
        //List to store Enrollment_Request__c having source 'Bulk Enrollment'
        List<Enrollment_Request__c> eReqRList = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqValidETALst = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqValidClassLst = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqValidContactLst = new List<Enrollment_Request__c>();
        
        //Get all Enrollment_Request__c objects in list having Status changed to 'Reprocess'
        for(Enrollment_Request__c eReqObj : newmap.values()){
            System.debug('*OldMapStatus*'+oldmap.get(eReqObj.id).Status__c + '*newMapStatus*'+newmap.get(eReqObj.id).Status__c);
            if (oldmap.get(eReqObj.id).Status__c!= newmap.get(eReqObj.id).Status__c && (newmap.get(eReqObj.id).Status__c == 'Reprocess')){
                if(eReqObj.Enrollment__c == null){
                    
                    eReqRList.add(eReqObj); 
                }else{
                    eReqObj.Status__c = 'Pending Notification';
                }    
            }     
        }
        System.debug('**eReqRList**'+eReqRList);
        system.debug(eReqRList);
        
        EnrollmentRequestDml eReqDML = new EnrollmentRequestDml();
        
        //Validate ETA on Enrollment Request
        if(!eReqRList.isEmpty()){
            eReqValidETALst = eReqDML.validateETAOnEnrollmentReq(eReqRList);
        }
        System.debug('**eReqValidETALst**'+eReqValidETALst);
        //Validate Class on Enrollment Request
        if(!eReqValidETALst.isEmpty()){
            eReqValidClassLst = eReqDML.validateClassOnEnrollmentReq(eReqValidETAlst);
        }
        System.debug('**eReqValidClassLst**'+eReqValidClassLst);
        //Validate Contact Enrollment Request
        if(!eReqValidClassLst.isEmpty()){
            eReqValidContactLst = eReqDML.validateContactOnEnrollmentReq(eReqValidClassLst);
        }
        System.debug('**eReqValidContactLst**'+eReqValidContactLst);
        //call batch for eReqValidContactLst to do enrollment processing for those that are not exceptions and not waiting for a CDS Lookup 
        
        Logger.pop();
    }
    
     /**
     * @author Original: 
     * @date Original: , Last Modified: 
     * @description Method that handles after insert trigger event on the Enrollment Request object
     * @param List_EnrollmentReq A collection of Enrollment Requests to create new Enrollment Request
     */
    public void onAfterInsert(List<Enrollment_Request__c> List_EnrollmentReq){ 
        
        //Set to store the Id of the Enrollment Request Record Object.
        Set<Id> enrolReqIdSet = new Set<Id>();
        
        //Iterate over the Enrollment Request List and add the enrollment request Id in the set having the Completed status
        for(Enrollment_Request__c enrolReqObj : List_EnrollmentReq){
            if(enrolReqObj.Status__c == 'Processing'){
                enrolReqIdSet.add(enrolReqObj.Id);
                System.debug('In the after Insert');
            }
        }
        
        //Check if the list is empty or not and call the batch to create enrollment records.
        if(enrolReqIdSet.size() > 0 && enrolReqIdSet != null){
            System.debug('In the Call Batch insert ');
            System.enqueueJob(new EnrollmentRequestToEnrollmentBatch(enrolReqIdSet));

        }
    }
    
    /**
     * @author Original: 
     * @date Original: , Last Modified: Sagar Talele
     * @description Method that handles after update trigger event on the Enrollment Request object
     * @param oldmap Enrollment Request records with old values
     * @param newmap Enrollment Request records with new values
     */
    public void onAfterUpdate(map<Id, Enrollment_Request__c> oldmap, map<Id, Enrollment_Request__c> newmap){
        System.debug('**onAfterUpdate newmap**'+newmap);
        //Set to store the Id of the Enrollment Request Record Object.
        Set<Id> enrolReqIdSet = new Set<Id>();
        //set to store the Id of the Enrollment Request Record Object whcih has status equal to reprocess
        Set<Id> enrollReqReprocessIDSet = new Set<Id>();
        System.debug('**onAfterUpdate newmap.values()**'+newmap.values());
        //Iterate over the Enrollment Request List and add the enrollment request Id in the set having the Completed status
        for(Enrollment_Request__c enrolReqObj : newmap.values()){
            
            Enrollment_Request__c oldEnrolReq = oldmap.get(enrolReqObj.Id);
            System.debug(enrolReqObj.Status__c);
            System.debug(oldEnrolReq.Status__c);
            if(enrolReqObj.Status__c != oldEnrolReq.Status__c && enrolReqObj.Status__c == 'Processing'  && enrolReqObj.Enrollment__c == null){
                enrolReqIdSet.add(enrolReqObj.Id);
                System.debug('In the after Update');
            }//enrolReqObj.Status__c != oldEnrolReq.Status__c &&
            if( enrolReqObj.Status__c != oldEnrolReq.Status__c && enrolReqObj.Status__c == 'Pending Notification'  && enrolReqObj.Enrollment__c != null && oldEnrolReq.Status__c =='Exception'){
                //enrolReqObj.Status__c = 
               
                    //enrolReqObj.Status__c = 'Pending Notification';
                    enrollReqReprocessIDSet.add(enrolReqObj.Id);
            }
        }
        System.debug('**onAfterUpdate newmap.values()**'+newmap.values());
        System.debug('**onAfterUpdate enrolReqIdSet**'+enrolReqIdSet);
        
        //Check if the list is empty or not and call the batch to create enrollment records.
        if(enrolReqIdSet.size() > 0 && enrolReqIdSet != null){
            System.debug('In the after Update Batch');
            System.enqueueJob(new EnrollmentRequestToEnrollmentBatch(enrolReqIdSet));
        }
        System.debug('**onAfterUpdate enrollReqReprocessIDSet**'+enrollReqReprocessIDSet);
        //Check if the list is not empty for calling batch to send a email 
        if(!enrollReqReprocessIDSet.isEmpty()){
            System.enqueueJob(new EmailToEnrolleesBatch (enrollReqReprocessIDSet));
        }
    }


}