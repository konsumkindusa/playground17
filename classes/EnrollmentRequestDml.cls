/** 
 *@author Original: Archana Suryawanshi - Cloud Sherpas/Mathworks, Last Modified: Archana Suryawanshi  - Cloud Sherpas/Mathworks
 *@date Original: 4 April 2015, Last Modified:  25 April 2016
 *@description This  is Dml class for 'EnrollmentRequestMasterTrigger'. 
 */ 
public class EnrollmentRequestDml {
  
   /**
    * @author Original: Archana Suryawanshi - Cloud Sherpas/Mathworks
    * @date Original: 25 April 2016, Last Modified: 25 April 2016
    * @description: Method to validate Enterprise Training Agreement on Enrollment Request
    * @param : reqList collection of Enrollment Request records 
    **/
    public list<Enrollment_Request__c> validateETAOnEnrollmentReq(list<Enrollment_Request__c> reqList){
        Logger.push('validateETAOnEnrollmentReq', 'EnrollmentRequestDml');
        
        List<Enrollment_Request__c> eReqListwithETA = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqListwithoutETA = new List<Enrollment_Request__c>();
        List<String> etaCodesLst = new List<String>();
        Set<Enrollment_Code__c> enCodeObjSet = new Set<Enrollment_Code__c>();
        Map<String,Enrollment_Code__c> eCodeToECodeObjMap = new Map<String,Enrollment_Code__c>();
        Map<id,TrainingUtil.ValidationStatus> codeToStatusMap = new  Map<id,TrainingUtil.ValidationStatus>();
        
        //Get list of Enrollment_Request__c not having Enterprise_Training_Agreement__c 
        //and also when the status on the enrollment request is reprocess, so that validations can be run again          
        for(Enrollment_Request__c reqObj:reqList){
            if(reqObj.Enterprise_Training_Agreement__c!=null && reqObj.Status__c != 'Reprocess'){
                eReqListwithETA.add(reqObj);                
            }
            else{
                eReqListwithoutETA.add(reqObj); 
                etaCodesLst.add(reqObj.Enrollment_Code__c);
            }            
        }
        
        //Query Enrollment_Code__c
        enCodeObjSet = new Set<Enrollment_Code__c>([select id,Enterprise_Training_Agreement__c,Code__c,Enterprise_Training_Agreement__r.Is_Active__c,Status__c 
                                                    from Enrollment_Code__c where Code__c in:etaCodesLst]);
        
        //Get Map of Enrollment code to its Status
        codeToStatusMap = TrainingUtil.validateEnrollmentCodes(enCodeObjSet);
        
        //Get eCodeToECodeObjMap
        for(Enrollment_Code__c codeObj:enCodeObjSet){   
            eCodeToECodeObjMap.put(codeObj.Code__c,codeObj);        
        }
        
        //validate Enterprise_Training_Agreement__c
        for(Enrollment_Request__c reqObj:eReqListwithoutETA){
            if(eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c)!=null) {
                //Check if status is REVOKED
                if(codeToStatusMap.get(eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c).id)!=TrainingUtil.ValidationStatus.REVOKED){
                    //Check if status is INACTIVE_ETA_CODE
                    if(codeToStatusMap.get(eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c).id)!=TrainingUtil.ValidationStatus.INACTIVE_ETA_CODE){
                        //Check if status is VALID
                        if(codeToStatusMap.get(eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c).id)==TrainingUtil.ValidationStatus.VALID){
                            reqObj.Enterprise_Training_Agreement__c = eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c).Enterprise_Training_Agreement__c;    
                            eReqListwithETA.add(reqObj);
                        }
                    } 
                    else{
                        reqObj.Enterprise_Training_Agreement__c = eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c).Enterprise_Training_Agreement__c;
                        reqObj.Status__c = 'Exception'; 
                        reqObj.Exception_Reason__c = 'Inactive Agreement';       
                    }
                }
                else{
                    reqObj.Enterprise_Training_Agreement__c = eCodeToECodeObjMap.get(reqObj.Enrollment_Code__c).Enterprise_Training_Agreement__c;
                    reqObj.Status__c = 'Exception'; 
                    reqObj.Exception_Reason__c = 'Enrollment Code Revoked';   
                }
            }
            else{
                reqObj.Status__c = 'Exception'; 
                reqObj.Exception_Reason__c = 'Invalid Enrollment Code';   
            }
        }
        
        Logger.pop();
        return eReqListwithETA;            
    }
    
    /**
    * @author Original: Archana Suryawanshi - Cloud Sherpas/Mathworks
    * @date Original: 22 April 2016, Last Modified: 22 April 2016
    * @description: Method to validate Contact on Enrollment Request
    * @param : reqList collection of Enrollment Request records 
    **/
    public list<Enrollment_Request__c>  validateContactOnEnrollmentReq(list <Enrollment_Request__c> reqList){
        Logger.push('validateContactOnEnrollmentReq', 'EnrollmentRequestDml');
        
        List<Enrollment_Request__c> eReqListwithCon = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqListwithoutCon = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqListToDoCDSLookup = new List<Enrollment_Request__c>();
        Set<String> etaIdSet = new Set<String>();
        List<String> emailLst = new List<String>();
        Map<String,contact> emailToConMap = new Map<String,contact>();
        Map<id,Map<string,Boolean>> enrolleeBlacklistMap = new Map<id,Map<string,Boolean>>();
        Map<id,Map<string,Boolean>> enrolleeAllowedDomainMap = new Map<id,Map<string,Boolean>>();
        Map<Id,String> etaIdToEnrolleeEmailMap = new Map<Id,String>();
        
        //Check if Contact__c is already Populated
        for(Enrollment_Request__c reqObj:reqList){
        
            if(reqObj.Contact__c!=null && reqObj.Status__c != 'Reprocess'){
                reqObj.Exception_Reason__c = '';
                reqObj.Status__c = 'Processing';
                eReqListwithCon.add(reqObj);                
            }
            else{
                
                eReqListwithoutCon.add(reqObj); 
                emailLst.add(reqObj.Email__c);
                etaIdSet.add(reqObj.Enterprise_Training_Agreement__c);
                etaIdToEnrolleeEmailMap.put(reqObj.Enterprise_Training_Agreement__c,reqObj.Email__c);
            }            
        }
           
        //Query for contacts having email address in list emailLst
        for(Contact conObj:[select id,Email,MathWorks_Account_ID__c from Contact where email in:emailLst]){
            emailToConMap.put(conObj.Email,conObj);            
        }
        
        //Get Map of Blacklisted Enrollee from TrainingUtil
        enrolleeBlacklistMap = TrainingUtil.areEnrolleeBlacklisted(etaIdSet, emailToConMap.keyset());
        
        //Get Map of Allowed domain Enrollee from TrainingUtil
        enrolleeAllowedDomainMap = TrainingUtil.areEnrolleeFromAllowedDomain(etaIdToEnrolleeEmailMap);
       
        for(Enrollment_Request__c reqObj:eReqListWithoutCon){
            //Check if emailToConMap contains email address 
            if(emailToConMap.get(reqObj.Email__c)!=null){
                
                //Check if contact's MathWorks_Account_ID__c is not null
                if((emailToConMap.get(reqObj.Email__c).MathWorks_Account_ID__c)!=null){ 
                   
                    //Check for Enrollee Blacklist for the related Training Agreement
                    if(!enrolleeBlacklistMap.containsKey(reqObj.Enterprise_Training_Agreement__c) || !enrolleeBlacklistMap.get(reqObj.Enterprise_Training_Agreement__c).containsKey(reqObj.Email__c)){
                        
                        //Check Contact's email address domain does not exist in the Allowed Domains list for the related Training Agreement
                        if(enrolleeAllowedDomainMap.containsKey(reqObj.Enterprise_Training_Agreement__c) && enrolleeAllowedDomainMap.get(reqObj.Enterprise_Training_Agreement__c).containsKey(reqObj.Email__c)){
                            reqObj.Contact__c = emailToConMap.get(reqObj.Email__c).id;
                            reqObj.Exception_Reason__c = '';
                            reqObj.Status__c = 'Processing';                           
                            eReqListwithCon.add(reqObj);      
                        }
                        else{
                            reqObj.Contact__c = emailToConMap.get(reqObj.Email__c).id;
                            reqObj.Status__c = 'Exception'; 
                            reqObj.Exception_Reason__c = 'Invalid Email Domain';        
                        }
                    }
                    else{
                        reqObj.Contact__c = emailToConMap.get(reqObj.Email__c).id;
                        reqObj.Status__c = 'Exception'; 
                        reqObj.Exception_Reason__c = 'Contact Blacklisted';    
                    }
                } 
                else{
                    reqObj.Contact__c = emailToConMap.get(reqObj.Email__c).id;
                    reqObj.Status__c = 'Exception'; 
                    reqObj.Exception_Reason__c = 'No MW Profile';
                }
            }
            else{
                reqObj.Status__c = 'Exception'; 
                reqObj.Exception_Reason__c = 'Contact not found with the email';
                eReqListToDoCDSLookup.add(reqObj);
            }
        }       
        Logger.pop();
        return eReqListwithCon;
          
    }
    
    /**
    * @author Original: Archana Suryawanshi - Cloud Sherpas/Mathworks
    * @date Original: 22 April 2016, Last Modified: 22 April 2016
    * @description: Method to validate Class on Enrollment Request
    * @param : reqList collection of Enrollment Request records 
    **/
    public list<Enrollment_Request__c>  validateClassOnEnrollmentReq(list <Enrollment_Request__c> reqList){
        Logger.push('validateClassOnEnrollmentReq', 'EnrollmentRequestDml');
        
        List<Enrollment_Request__c> eReqListwithClass = new List<Enrollment_Request__c>();
        List<Enrollment_Request__c> eReqListwithoutClass = new List<Enrollment_Request__c>();
        List<Class__c> classLst= new List<Class__c>();
        Set<Id> classObjLst= new Set<Id>();
        List<Training_Agreement_Class_Relationship__c> tacrObjlst = new List<Training_Agreement_Class_Relationship__c>();
        Set<Id> etaIdSet = new Set<Id>();
        //Map to contain Id of Class Object with Enterprise Training Agreement Object with List of Enrollment.
        Map<Id,Map<Id, Integer>> clsEtaEnrolMap = new Map<Id,Map<Id, Integer>>();
        
        Map<String,Training_Agreement_Class_Relationship__c> tacrMap = new  Map<String,Training_Agreement_Class_Relationship__c>();
        Map<String,class__c> classMap = new  Map<String,class__c>();
        
        Set<String> criteriaToCompare = new Set<String>();
        Set<String> criteriaToCompareInEtar = new Set<String>();
        
        //Enrollment Seat-Based Record Type Id.
        Id eTARecTypeId;
         
        //Quering the RecordType Id of Seat-Based Enterprise Training Agreement Object
        eTARecTypeId = Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId();
         
        
        //Check if class__c is already Populated
        for(Enrollment_Request__c reqObj:reqList){
            if(reqObj.class__c!=null && reqObj.Status__c != 'Reprocess'){
                eReqListwithClass.add(reqObj);                
            }
            else{
                eReqListwithoutClass.add(reqObj);
                etaIdSet.add(reqObj.Enterprise_Training_Agreement__c);
                criteriaToCompare.add(reqObj.Course_Code__c+reqObj.Class_Format__c+reqObj.Language_Code__c);
                criteriaToCompareInEtar.add(reqObj.Course_Code__c+reqObj.Class_Format__c+reqObj.Language_Code__c+reqObj.Enterprise_Training_Agreement__c);
            }
        }
        
        system.debug(eReqListwithClass);
         system.debug(eReqListwithoutClass);
        
        //Find matching class by criteriaToCompare
        for(class__C classObj:[SELECT ClassCriteriaBE__c
                               FROM class__c
                               WHERE ClassCriteriaBE__c in :criteriaToCompare]){
            classMap.put((classObj.ClassCriteriaBE__c).tolowercase(),classObj);
        }
        
        //Find matching class by criteriaToCompareInEtar
        for(Training_Agreement_Class_Relationship__c tacrObj:[SELECT Class__r.Course__c,Class__c,Class__r.Course__r.Course_Code__c,class__r.Enrollee_Seats_Taken__c,
                                                              Class__r.Format_Of_Class__c,Class__r.Language__r.Language_Code__c,Class__r.status__c,
                                                              Enterprise_Training_Agreement__r.Max_Seats__c ,Enterprise_Training_Agreement__c,ClassCriteriaBE__c,
                                                              Enterprise_Training_Agreement__r.RecordType.Name
                                                              FROM Training_Agreement_Class_Relationship__c
                                                              WHERE ClassCriteriaBE__c in :criteriaToCompareInEtar]){
            tacrMap.put((tacrObj.ClassCriteriaBE__c).tolowercase(),tacrObj);
            classObjLst.add(tacrObj.Class__c);
        }
        
        system.debug('classObjLst'+classObjLst);
        system.debug('etaIdSet'+etaIdSet);
        clsEtaEnrolMap=TrainingUtil.getConsumedSeatCountForETA(etaIdSet,classObjLst);
        
        system.debug('clsEtaEnrolMap'+clsEtaEnrolMap);
        
        for(Enrollment_Request__c reqObj:eReqListwithoutClass){
        
           string keyCriteria = (reqObj.Course_Code__c+reqObj.Class_Format__c+reqObj.Language_Code__c).tolowercase();
           string keyEtaCriteria = (reqObj.Course_Code__c+reqObj.Class_Format__c+reqObj.Language_Code__c+reqObj.Enterprise_Training_Agreement__c).tolowercase();
          
           //Check if class Exist in org
           if(classMap.containsKey(keyCriteria)){
               
               //Check if Class is not listed in the Training Agreement Class Relationship object for the Agreement,
                if(tacrMap.containsKey(keyEtaCriteria)){
                    
                    //Check if the Class is inactive    
                    if(tacrMap.get(keyEtaCriteria).class__r.status__c == 'Active'){ 
                        
                           
                            //Check if the Class is found but the Enterprise Training Agreement is Seat-Based and the number of seats would be go beyond the threshold
                            if(!clsEtaEnrolMap.containsKey(tacrMap.get(keyEtaCriteria).Enterprise_Training_Agreement__c)){
                                reqObj.Class__c = tacrMap.get(keyEtaCriteria).class__c;
                                eReqListwithClass.add(reqObj);
                            }
                            else{
                            
                                if(((clsEtaEnrolMap.get(tacrMap.get(keyEtaCriteria).Enterprise_Training_Agreement__c).get(tacrMap.get(keyEtaCriteria).class__c))<(tacrMap.get(keyEtaCriteria).Enterprise_Training_Agreement__r.Max_Seats__c))){
                                    reqObj.Class__c = tacrMap.get(keyEtaCriteria).class__c;
                                    eReqListwithClass.add(reqObj);
                                }
                                else{
                                     reqObj.Status__c = 'Exception'; 
                                     reqObj.Exception_Reason__c = 'Seat-Based Class Is Full'; 
                                     reqObj.Class__c = tacrMap.get(keyEtaCriteria).class__c;
                                    
                                }
                            
                            }
                        }
                        else{
                            reqObj.Status__c = 'Exception'; 
                            reqObj.Exception_Reason__c = 'InActive Class';      
                        }
                    }
                else{
                        reqObj.Status__c = 'Exception'; 
                        reqObj.Exception_Reason__c = 'Class Not Part of Training Agreement';     
                }
            }      
            else{
                reqObj.Status__c = 'Exception'; 
                reqObj.Exception_Reason__c = 'InValid Class'; 
            }              
        }
        Logger.pop();   
        return eReqListwithClass;
    }
    
    /**
    * @author       Pranav Raulkar
    * @date         5-May-2016
    * @description  Sets the GUID on the enrollment requests created. 
    *               The same GUID is stamped on all the enrollment requests created in a context.   
    * @param        enrollmentRequestList - List of Enrollment_Request__c created
    */
    public void setGUIDOnEnrollmentRequests(List<Enrollment_Request__c> enrollmentRequestList) {
        Logger.push('EnrollmentRequestDml', 'setGUIDOnEnrollmentRequests');

        if(enrollmentRequestList != null && enrollmentRequestList.size() > 0) {
            String guid = TrainingUtil.generateGUID();
            for(Enrollment_Request__c er : enrollmentRequestList) {
                er.Batch_Id__c = guid;
            }
        }

        Logger.pop();
    }
}