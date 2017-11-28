/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:   06 Aug 2015, Last Modified:
 *@description:     This is a Handler class for Enrollment Object.
 */

public class EnrollmentTriggerHandler{
    
    /**
    *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
    *@date Original:06 Aug 2015, Last Modified:Sagar Talele
    *@description:Method that handles Before Insert trigger event on the Enrollment__c object.
    */
    
    public void onBeforeInsert(List<Enrollment__c> enrolLst){
        Logger.push('onBeforeInsert','EnrollmentTriggerHandler');
        Logger.debug('onBeforeInsertLog##');
        //List to store the enrollment record.
        List<Enrollment__c> seatBasedEnrolLst = new List<Enrollment__c>();
        //List to store the Enterprise_Training_Agreement__c record having is associated with Triggered Record.
        List<Enterprise_Training_Agreement__c> etaLst = new List<Enterprise_Training_Agreement__c>();
        //Map of Enterprise Training Agreement with Seat-Based Record Type. 
        Map<Id, Id> etaRecTypeMap = new Map<Id, Id>();
        //Set of Enterprise Training Agreement.
        Set<Id> etaIdSet = new Set<Id>();
        //Store the  Enterprise Training Agreement RecordTypeId(Seat-Based). 
        Id etarecType;
        //Create Instance of Enrollment DML class
        EnrollmentDML enrolDmlObj = new EnrollmentDML();
        //Set of courseId
        Set<Id> courseIdSet = new Set<Id>();
        //List of classes
        List<Class__c> classList = new List<Class__c>();
        //List of enrollment.
        List<Enrollment__c> enrollmentList= new List<Enrollment__c>();
        List<Enrollment__c> enrollmentListForDupCheck= new List<Enrollment__c>();
        List<Course__c> courseList = new List<Course__c>();
        String enrollError= System.Label.EnrollmentPreriquisiteError;
        Set<Id> coursePrerequisiteIdSet = new Set<Id>();
        //set of Contact Id
        Set<Id> enrolleeSet = new Set<Id>();
        //List of enrollment
        List<Enrollment__c>EnrollPreReqList = new List<Enrollment__c>();
        //Map of corse Id as a key and Pre-Requisite CourseId as a value 
        Map<Id,Id> courseToPreRequisiteMap = new Map<Id,Id>();
        //Map 
        Map<Id,List<Enrollment__c>> preRequisiteToEnrollmetMap = new Map<Id,List<Enrollment__c>>();
        //Set of classformats for skipping the check for dups
        Set<string> classFormatsToSkipCheckingEnrolDups = new Set<String>();
        //Get the Enterprise Training Agreement RecordTypeId(Seat-Based). 
        etarecType = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
        Id enrollRectypeId = Schema.SObjectType.Enrollment__C.getRecordTypeInfosByName().get('Exam').getRecordTypeId();
        System.debug('**enrollRectypeId **'+enrollRectypeId );
        //Filling set of Enterprise training Agreement Id associated with Enrollment.
        for(Enrollment__c enrolObj : enrolLst){
            etaIdSet.add(enrolObj.Enterprise_Training_Agreement__c);
        }
        
        //Querying the Enterprise Training Agreement.
        etaLst = [SELECT Id, RecordTypeId FROM Enterprise_Training_Agreement__c WHERE id =: etaIdSet];
        //Filling the Map of Enterprise Training Agreement with Seat-Based RecordTypeId.
        for(Enterprise_Training_Agreement__c enrolmntObj : etaLst){
            etaRecTypeMap.put(enrolmntObj.Id, enrolmntObj.RecordTypeId);
        }
        
        classFormatsToSkipCheckingEnrolDups = enrolDmlObj.getClassFormatsToSkipCheckingEnrolDups();
        //Check if the Triggered Enrollment List is empty or not.
        if(!(enrolLst.isEmpty())){
            //Iterating over the List.
            for(Enrollment__c enrlObj : enrolLst){
                System.debug('**enrlObj.Class__r.Course__r.Prerequisite__c**'+enrlObj.Class__r.Course__r.Prerequisite__c);
                
                    System.debug('***enrlObj.CourseId__c*'+enrlObj.CourseId__c);
                    //Build a set of courseId
                    courseIdSet.add(enrlObj.CourseId__c);
                    //build a set of enrollee names
                    enrolleeSet.add(enrlObj.Enrollee_Name__c);
               
                 //Check if the Enrollment has status of Registered, Registered - Awaiting Payment, completed and and Enterprise Training Agreement has Seat-Based RecordType or not.
                if(((enrlObj.Enrollment_Status__c == 'Registered') || (enrlObj.Enrollment_Status__c == 'Registered - Awaiting Payment') || (enrlObj.Enrollment_Status__c == 'Completed')) && (etaRecTypeMap.get(enrlObj.Enterprise_Training_Agreement__c) == etarecType)){
                //add the filtered Record to EnrolLst List.
                seatBasedEnrolLst.add(enrlObj);
                }
                
                if(enrlObj.Enrollment_Status__c!=Label.Enrollment_Status_Cancelled && !classFormatsToSkipCheckingEnrolDups.contains(enrlObj.Format_Of_Class__c)){
                   enrollmentListForDupCheck.add(enrlObj);  
                }
                
            }
            if(!seatBasedEnrolLst.isEmpty()){
                enrolDmlObj.checkMaxEnrollmentOnClass(seatBasedEnrolLst,false);
            }
            if(!enrollmentListForDupCheck.isEmpty()){
                enrolDmlObj.checkDuplicateEnrollments(enrollmentListForDupCheck);
            }
        }
        //query course list for which Prerequisite is not equal to null
        courseList = [Select Id,Prerequisite__c From Course__c where Id IN: courseIdSet And Prerequisite__c!=null];
        if(!courseList.isEmpty()){
            for(Course__c courseObj: courseList){
                if(!courseToPreRequisiteMap.containsKey(courseObj.Id)){
                        //fill map for course id as a kaey and Pre-Requisite as a value
                        courseToPreRequisiteMap.put(courseObj.Id,courseObj.Prerequisite__c);
                }
            }
            System.debug('***courseToPreRequisiteMap*'+courseToPreRequisiteMap);
            //iterate over a list of course for getting the pre-reqisite course
            for(Course__c  courseObj: courseList ){
                if(courseObj.Prerequisite__c != null){
                    //build set of course Pre-Requisite
                    coursePrerequisiteIdSet.add(courseObj.Prerequisite__c);
                }
            }
            System.debug('**enrolleeSet**'+enrolleeSet);
            System.debug('*coursePrerequisiteIdSet**'+coursePrerequisiteIdSet);
            //query for Class and  related enrollment for classes        
             if(!coursePrerequisiteIdSet.isEmpty() && !enrolleeSet.isEmpty()){
                   //query for enrollments for pre-requisite course and enrolle set we created 
                   EnrollPreReqList = [Select Enrollee_Name__c,Id, Passed_Test_Flag__c,Class__c,CourseId__c  from Enrollment__c where CourseId__c in :courseToPreRequisiteMap.values() And  Enrollee_Name__c In:enrolleeSet]; 
                   System.debug('**EnrollPreReqList **'+EnrollPreReqList);
                   //Iterate over the enrollment List
                   for(Enrollment__c enrollmentObj : EnrollPreReqList){
                      if(!preRequisiteToEnrollmetMap.containsKey(enrollmentObj.CourseId__c) ){
                          //check for Passed_Test_Flag__c is Y then add into map
                          if(enrollmentObj.Passed_Test_Flag__c =='Y'){
                            preRequisiteToEnrollmetMap.put(enrollmentObj.CourseId__c,new List<Enrollment__c>{enrollmentObj});
                          }
                      }
                      else{
                          if(enrollmentObj.Passed_Test_Flag__c =='Y'){
                            preRequisiteToEnrollmetMap.get(enrollmentObj.CourseId__c).add(enrollmentObj);
                          }
                     }
                   }
                   System.debug('**preRequisiteToEnrollmetMap**'+preRequisiteToEnrollmetMap);
             }
            for(Enrollment__c enrollObj: enrolLst){
                if(!courseToPreRequisiteMap.isEmpty() ){
                    if(courseToPreRequisiteMap.containsKey(enrollObj.CourseId__c)){
                        if(preRequisiteToEnrollmetMap == null || preRequisiteToEnrollmetMap.isEmpty() || preRequisiteToEnrollmetMap.get(courseToPreRequisiteMap.get(enrollObj.CourseId__c)).size()<0){
                            enrollObj.addError(enrollError);
                        }
                    }
                }
            }
        }
        
        Logger.pop();
    }
    
    /**
    *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
    *@date Original:   2 Sep 2015, Last Modified: 
    *@description:     Method that handles Before Insert trigger event on the Enrollment__c object.
    */
    
    public void onBeforeUpdate(Map<Id, Enrollment__c> enrolMap, Map<Id, Enrollment__c> oldEnrolMap){
        Logger.push('onBeforeUpdate','EnrollmentTriggerHandler');
        
        //List to store enrollment record.
        List<Enrollment__c> updateEnrolLst = new List<Enrollment__c>();
        //List to store Enterprise Training Agreement Record.
        List<Enterprise_Training_Agreement__c> etaLst = new List<Enterprise_Training_Agreement__c>();
        //Set to store enterprise training agreement Id.
        Set<Id> etaIdSet = new Set<Id>();
        List<Enrollment__c> enrollmentListForDupCheck= new List<Enrollment__c>();
        //Store the  Enterprise Training Agreement RecordTypeId(Seat-Based). 
        Id etarecType;
        //Map of Enterprise Training Agreement with Seat-Based Record Type. 
        Map<Id, Id> etaRecTypeMap = new Map<Id, Id>();
        //Create Instance of Enrollment DML class
        EnrollmentDML enrolDmlObj = new EnrollmentDML();
        
        //Set of classformats for skipping the check for dups
        Set<string> classFormatsToSkipCheckingEnrolDups = new Set<String>();
        
        //Get the Enterprise Training Agreement RecordTypeId(Seat-Based). 
        etarecType = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
        
        //Filling set of Enterprise training Agreement Id associated with Enrollment.
        for(Enrollment__c enrolObj : enrolMap.Values()){
            etaIdSet.add(enrolObj.Enterprise_Training_Agreement__c);
        }
        //Querying the Enterprise Training Agreement.
        etaLst = [SELECT Id, RecordTypeId FROM Enterprise_Training_Agreement__c WHERE id =: etaIdSet];
        
        //Filling the Map of Enterprise Training Agreement with Seat-Based RecordTypeId.
        for(Enterprise_Training_Agreement__c enrolmntObj : etaLst){
            etaRecTypeMap.put(enrolmntObj.Id, enrolmntObj.RecordTypeId);
        }
        
        classFormatsToSkipCheckingEnrolDups = enrolDmlObj.getClassFormatsToSkipCheckingEnrolDups();
        
        if(!(enrolMap.isEmpty())){
            for(Enrollment__c enrolObj : enrolMap.values()){       
                //Get the old value of the enrollment.
                Enrollment__c oldenrlObj = oldEnrolMap.get(enrolObj.Id);
                //check if the enrollment status is changed or not.
                if((oldenrlObj.Enrollment_Status__c !=  enrolObj.Enrollment_Status__c ) && (etaRecTypeMap.get(enrolObj.Enterprise_Training_Agreement__c) == etarecType)){
                    System.debug('oldenrlObj.Enrollment_Status__c ' +oldenrlObj.Enrollment_Status__c );
                    updateEnrolLst.add(enrolObj);    
                }
                
                if(oldenrlObj.Enrollment_Status__c ==  'Cancelled' && enrolObj.Enrollment_Status__c!=Label.Enrollment_Status_Cancelled && !classFormatsToSkipCheckingEnrolDups.contains(enrolObj.Format_Of_Class__c)){
                   enrollmentListForDupCheck.add(enrolObj);      
                }
            }
            System.debug('@@##updateEnrolLst## '+updateEnrolLst);
            if(!updateEnrolLst.isEmpty()){
                enrolDmlObj.checkMaxEnrollmentOnClass(updateEnrolLst,true);
            }
            if(!enrollmentListForDupCheck.isEmpty()){
                enrolDmlObj.checkDuplicateEnrollments(enrollmentListForDupCheck);
            }
        }
        Logger.pop();
    }
    
    /**
    *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Kishore AN
    *@date Original:   08 Aug 2015, Last Modified: 31 Aug 2015
    *@description:     Method that handles after Insert trigger event on the Enrollment__c object.
    *                  Added the check to evaluate if the enrollment need to be processed to send notifications
    */
    
    public void onAfterUpdate(map<Id, Enrollment__c> oldmap, map<Id, Enrollment__c> newmap){
        Logger.push('onAfterUpdate','EnrollmentTriggerHandler');
        
        Set<Id> EnrollmentIdsSet = new Set<Id>();
        //check to see if the enrollemnt has the send email flag set so that the notifications can be sent for the enrollment based on the events
        for(Enrollment__c enroll: newmap.values()){
            if(enroll.Send_Email__c == true){
                EnrollmentIdsSet.add(enroll.Id);
            }
        }
        if(EnrollmentIdsSet.size() > 0){
          //instantiating EnrollmentDML class 
          EnrollmentDML enrolDmlObj = new EnrollmentDML();          
          enrolDmlObj.CheckAndSendEmailNotification(EnrollmentIdsSet);
        }
        Logger.pop();
    }
   
}