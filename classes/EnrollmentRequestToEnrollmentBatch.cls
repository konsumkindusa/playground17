/**
* @author           Pranav Raulkar
* @date             5-May-2016
* @description      This batch processes all the enrollment request records that are fully populated with
*                   a valid contact, class and enterprise training agreement with no exceptions encountered
*                   and creates enrollments for each enrollment request.
* @revision         1.0 - Initial version
                    Archana Suryawanshi - Changed Implemented Interface from Batchable to Queueable and did related changes
                                          in other methods.
*/
global class EnrollmentRequestToEnrollmentBatch implements Queueable {
//global class EnrollmentRequestToEnrollmentBatch implements Queueable,Schedulable {
    // Query to run on start of the batch
    private String query;
    private Set<Id> enrolReqIds;

    /**
    * @author           Pranav Raulkar
    * @modified by      Archana Suryawanshi
    * @date             5-May-2016
    * @modified date    9-May-2016
    * @description      Constructor
    */
    public EnrollmentRequestToEnrollmentBatch(Set<Id> enrolReqIdSet) {
        Logger.push('EnrollmentRequestToEnrollmentBatch', 'EnrollmentRequestToEnrollmentBatch');
        
        enrolReqIds = enrolReqIdSet;
        
        Logger.pop();
    }
    
   

    /**
    * @author           Pranav Raulkar
    * @modified by      Archana Suryawanshi
    * @date             5-May-2016
    * @modified date    11-May-2016
    * @description      Execute method processes all the records from enrolReqIds and calls the utility method which creates  
    *                   enrollment for each enrollment request. The returned enrollments are inserted and any errors encountered
    *                   during the insert are logged against the enrollment request as well as in the debugs
    *                   (only for failed records, all the other requests continue processing).
    * @param            qContext - The Queueable Context
    */
    global void execute(QueueableContext qContext) {
        Logger.push('EnrollmentRequestToEnrollmentBatch', 'execute');
        
        List<Enrollment_Request__c> enrollmentLst = [SELECT Id, Batch_ID__c, Class__c, Contact__c, Enrollment_Code__c,
                                                     Enterprise_Training_Agreement__c, Enterprise_Training_Agreement__r.Term_Start_Date__c, 
                                                     Enterprise_Training_Agreement__r.Term_End_Date__c, Enterprise_Training_Agreement__r.CurrencyIsoCode,
                                                     Enterprise_Training_Agreement__r.Order_Number__c, Source__c, Status__c  
                                                     FROM Enrollment_Request__c WHERE Id IN :enrolReqIds];

        //Call the createEnrollmentFromEnrollmentRequest Method to create the Enrollment.
        List<Enrollment__c> enrollmentsToInsert = TrainingUtil.createEnrollmentFromEnrollmentRequest(enrollmentLst);

        // Partial insert the enrollments
        List<Database.SaveResult> srList = Database.insert(enrollmentsToInsert, false);

        // List to hold any enrollment requests to be updated with status and error messages
        List<Enrollment_Request__c> erToUpdate = new List<Enrollment_Request__c>();

        for(Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList[i];
            
           
            
            // Check if we have any failures. We need to update the status and error message
            // on the original enrollment request.
            if(!sr.isSuccess()) {
                Database.Error dbErr = sr.getErrors()[0];
                Enrollment_Request__c er = enrollmentLst[i];
                er.Status__c = 'Exception';
                er.Exception_Reason__c = dbErr.getMessage();
                erToUpdate.add(er);
            }
            else{
                Enrollment_Request__c er = enrollmentLst[i];
                er.Status__c = 'Pending Notification';
                er.Exception_Reason__c ='';
                er.Enrollment__c = sr.getId();
                erToUpdate.add(er);                
            }
        }

        // Update the enrollment requests with exception status and exeption message
        if(!erToUpdate.isEmpty()) {
            try {
                update erToUpdate;
            } catch(Exception ex) {
                Logger.debugException(ex);
            }       
        }
        //call batch
        if(!enrolReqIds.isEmpty() && !Test.isRunningTest()){
            System.enqueueJob(new EmailToEnrolleesBatch (enrolReqIds));
        }
         
        Logger.pop();
    }
    
   /* global void execute(SchedulableContext ctx) {
    }
*/
    
    
}