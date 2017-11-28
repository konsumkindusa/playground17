/**
 * @author      Pranav Raulkar
 * @date        23/03/2016
 * @description This class houses utility methods for the Mathworks TAH module
 * @revision    1.0 - Initial version
 */
public without sharing class TrainingUtil {
    /* The Enrollment Code Configuration custom setting org wide defaults */
    public static final Training_Agreement_Settings__c ENROLL_CODE_CONFIG = Training_Agreement_Settings__c.getOrgDefaults();
    
    /* Utility Constants Section */
    public static final String ECODE_URL_PARAM_KEY = 'code';
    public static final String LANGUAGE_URL_PARAM_KEY = 'ln';
    public static final String DEFAULT_LANGUAGE_CODE = 'en_US';
    public static final String DEFAULT_LANGUAGE_ISOCODE = 'en';
    
    public static final String STATUS_ACTIVE = 'Active';
        
    /* Constant use to test the Duplicate Code in test class */
    public static Boolean testDuplicateSwitch = False;

    /**
    *    @author         Pranav Raulkar
    *    @date           23/03/2016
    *    @description    Enum to store the enrollment code validation status.
    */
    public enum ValidationStatus {
        VALID,
        NON_EXISTENT,
        REVOKED,
        INACTIVE_ETA_CODE       
    }
    
    /* Custom exception to use for TrainingUtil */
    public class TrainingUtilException extends Exception { }

    /**
    *    @author         Pranav Raulkar
    *    @date           23/03/2016
    *    @description    This method generates an random enrollment code to be associated 
    *                    with an Enterprise Training Agreement. 
    *
    *                    The charset considered while generating the randome code is 
    *                    specified by Character_Set__c and the desired length of the code is 
    *                    specified by Code_Length__c from the Training_Agreement_Settings__c
    *                    Hierarchy Custom Setting.
    *
    *                    The method makes sure that the enrollment code retured is unique
    *                    by looking up on the existing enrollment codes for possible 
    *                    collisions.
    *    @return         String
    */
    public static String generateEnrollmentCode() {
        Logger.push('TrainingUtil', 'generateEnrollmentCode');

        String newEnrollmentCode = '';
        
        if(ENROLL_CODE_CONFIG != null) {
            // Get the charset
            List<String> eCodeCharset = ENROLL_CODE_CONFIG.Character_Set__c.split(';');
            
            // Get the charset size
            Integer upperLimit = eCodeCharset.size();
            
            // Generate random code from charset
            for(Integer i = 0; i < ENROLL_CODE_CONFIG.Code_Length__c; i++) {
                newEnrollmentCode += eCodeCharset[randomWithLimit(upperLimit)];
            }

            // Check for possible collisions and re-generate the enrollment code if required
            if(isDuplicate(newEnrollmentCode)) {
                generateEnrollmentCode();                
            }
        } else {
            Logger.debugException(System.Label.CP_ENROLL_Enrollment_Code_Configuration_Missing_Setup);
            
            // Missing custom setting setup
            throw new TrainingUtilException(System.Label.CP_ENROLL_Enrollment_Code_Configuration_Missing_Setup);
        }   
        
        Logger.pop();

        return newEnrollmentCode;
    }
    
    /**
    *    @author        Pranav Raulkar
    *    @date          23/03/2016
    *    @description   Returns a random number between Zero and Maximum number of of unique 
    *                   characters used in construction of enrollment code
    *    @param         upperLimit - The number of unique characters used in construction of 
    *                   enrollment code
    *    @return        Integer
    */
    private static Integer randomWithLimit(Integer upperLimit) {
        Logger.push('TrainingUtil', 'randomWithLimit');
        Integer rand = Math.round(Math.random() * 1000);
        Logger.pop();        
        return Math.mod(rand, upperLimit);
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          23/03/2016
    *    @description   Performs collision detection against existing 
    *                   Enterprise Training Agreement enrollment codes.
    *
    *                   The enrollment codes will not be generated in bulk? SOQL Limits?
    *    @param         enrollmentCode - The enrollment code to check for collision
    *    @return        Boolean
    */
    private static Boolean isDuplicate(String enrollmentCode) {
        Logger.push('TrainingUtil', 'isDuplicate');
        Integer matchCount = Database.countQuery('Select COUNT() FROM Enrollment_Code__c Where Code__c = :enrollmentCode');
        Logger.pop();
        
        return matchCount >= 1;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          26/03/2016
    *    @description   Returns true/false if the logged in enrollee is blacklisted for the ETA
    *    @param         etaId - The enterprise training agreement id
    *    @Return        Boolean
    */
    public static Boolean isEnrolleeBlacklisted(String etaId, String enrolleeEmail) {
        Logger.push('TrainingUtil', 'isEnrolleeBlacklisted');
        Integer matchCount = Database.countQuery('Select COUNT() FROM Enrollee_Blacklist__c Where Email__c = :enrolleeEmail AND Enterprise_Training_Agreement__c = :etaId');
        Logger.pop();
        
        return matchCount >= 1;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          26/03/2016
    *    @description   Returns true/false if the logged in enrollee email domain is in allowed domain for the ETA
    *    @param         etaId - The enterprise training agreement id
    *    @return        Boolean
    *    @version       Pranav Raulkar  : (Initial version)
    *                   Sagar talele    : Returns true if the logged in enrollee email domain is in allowed domain for the ETA
    *                                     and also if sub-domain is allowed.
    *                   Pranav Raulkar  : Cleaned up code. Removed all debug statements and fixed local variable naming and casing.
    *                                     Removed redundant UserInfo calls and return statements.
    *                                     Removed == checks on string. Added logger push pop.     
    *                   Archana suryawanshi  : Modified the code to validate the allowed domain if it is more than 1 
    *                                     levels deep if the allow sub domain flag is set to true.     
    */
     public static Boolean isEnrolleeFromAllowedDomain(String etaId) {
        Logger.push('TrainingUtil', 'isEnrolleeFromAllowedDomain');

        Boolean isEnrolleeFromAllowedDomain = false;

        List<Allowed_Domains__c> allowDomainList = new List<Allowed_Domains__c>();

        String userEmail = UserInfo.getUserEmail();
         
        system.debug('userEmail'+'userEmailuserEmailuserEmailuserEmail');
       
        String enrolleeEmailDomain = userEmail.split('@')[1];
        
        allowDomainList = [SELECT Id, Name, Allow_Sub_Domain__c
                            FROM Allowed_Domains__c 
                            WHERE  Enterprise_Training_Agreement__c = :etaId];
        
        for(Allowed_Domains__c ad : allowDomainList) {
            if(ad.Allow_Sub_Domain__c) {
                if(enrolleeEmailDomain.endsWith(ad.Name)) {
                    isEnrolleeFromAllowedDomain = true;
                }         
            } else {
                if(enrolleeEmailDomain.compareTo(ad.Name) == 0){
                    isEnrolleeFromAllowedDomain = true;
                }
            }
        }

        Logger.pop();

        return isEnrolleeFromAllowedDomain;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          26/03/2016
    *    @description   This method takes in the random code and returns the Enrollment Code instance.
    *    @param         eCode - The enrollment code
    *    @return        Enrollment_Code__c
    */
    public static Enrollment_Code__c getEnrollmentCode(String code) {
        Logger.push('TrainingUtil', 'getEnrollmentCode');

        List<Enrollment_Code__c> eCodeList = [SELECT Status__c, Code__c,
                                                Enterprise_Training_Agreement__r.Max_Seats__c,
                                                Enterprise_Training_Agreement__r.RecordTypeId,
                                                Enterprise_Training_Agreement__r.Is_Active__c,
                                                Enterprise_Training_Agreement__r.Language__r.SF_ISO_Code__c,
                                                Enterprise_Training_Agreement__r.Language__r.Show_Names_By__c,
                                                Enterprise_Training_Agreement__r.Self_Enrollment_Content__c,
                                                Enterprise_Training_Agreement__r.Account_Name__r.Name,
                                                Enterprise_Training_Agreement__r.Term_End_Date__c
                                                FROM Enrollment_Code__c
                                                WHERE Code__c = :code 
                                                Limit 1];

        Logger.pop();
        
        return eCodeList.isEmpty() ? null : eCodeList[0];
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          26/03/2016
    *    @description   The method performs the enrollment code validation as per following -
    *                   1.  Check if enrollment code is of proper length, if not display error.
    *                   2.  Check if the enrollment code exixts
    *                       2.1 If exists, check if it's active else display error
    *                       2.2 If active, check if the associated Enterprise Training Agreement is Active,
    *                           In which case we have a valid enrollment code. If not, display error
    *    @param         eCode - The enrollment code to perform validate
    *    @return        ValidationStatus
    */
    public static ValidationStatus validateEnrollmentCode(Enrollment_Code__c eCode) {
        Logger.push('TrainingUtil', 'validateEnrollmentCode');
        
        ValidationStatus status = ValidationStatus.NON_EXISTENT;
        
        if(eCode != null) {
            if('Active'.equalsIgnoreCase(eCode.Status__c)) {
                if(eCode.Enterprise_Training_Agreement__r.Is_Active__c) {
                    status = ValidationStatus.VALID;
                } else {
                    status = ValidationStatus.INACTIVE_ETA_CODE;
                }
            } else {
                status = ValidationStatus.REVOKED;
            }
        }

        Logger.pop();

        return status;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          14/04/2016
    *    @description   Get the logged in user contact id
    *    @return        Id
    */
    public static Id getLoggedInUserContactId() {
        Logger.push('TrainingUtil', 'getLoggedInUserContactId');
        User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Logger.pop();
        
        return loggedInUser.ContactId;
    }

    /*
        @author         Pranav Raulkar
        @date           14/04/2016
        @description    Get the logged in user contact id
        @returns        Id
    */
    public static Boolean doesLanguageExist(String urlIsoCode) {
        Logger.push('TrainingUtil', 'doesLanguageExist');
        Integer matchCount = Database.countQuery('Select COUNT() FROM Language__c Where SF_ISO_Code__c = :urlIsoCode');
        Logger.pop();

        return matchCount >= 1;
    }

    /**
    *    @author        Archana Suryawanshi
    *    @date          25/04/2016
    *    @description   The method performs the enrollment code validation as per following -
    *                   1.  Check if enrollment code is of proper length, if not display error.
    *                   2.  Check if the enrollment code exixts
    *                       2.1 If exists, check if it's active else display error
    *                       2.2 If active, check if the associated Enterprise Training Agreement is Active,
    *                           In which case we have a valid enrollment code. If not, display error
    *    @param         Set of Enrollment_Code__c - The enrollment codes to perform validate
    *    @return        Map of Enrollment_Code__c to ValidationStatus
    *    @version       Pranav Raulkar: Correct method name in logger push
    *                                   Moved initialization of status inside for loop
    *                                   Replaced 'Active' with TrainingUtil.STATUS_ACTIVE
    *                                   Changed the parameter type from List to Set
    *                                   Added comments
    */
    public static Map<Id, ValidationStatus> validateEnrollmentCodes(Set<Enrollment_Code__c> eCodeSet) {
        Logger.push('TrainingUtil', 'validateEnrollmentCodes');
        
        Map<Id,ValidationStatus> validatedEcodeMap = new Map<Id, ValidationStatus>();
        
        for(Enrollment_Code__c eCode : eCodeSet) { 
            // Validation status must be reset for each enrollment code being processed         
            ValidationStatus status = ValidationStatus.NON_EXISTENT;

            if(eCode != null) {
                if(TrainingUtil.STATUS_ACTIVE.equalsIgnoreCase(eCode.Status__c)) {
                    if(eCode.Enterprise_Training_Agreement__r.Is_Active__c) {
                        status = ValidationStatus.VALID;
                    } else {
                        status = ValidationStatus.INACTIVE_ETA_CODE;
                    }
                } else {
                    status = ValidationStatus.REVOKED;
                }
                
                validatedEcodeMap.put(eCode.id, status);
            }
        }

        Logger.pop();

        return validatedEcodeMap;
    }
    
    /**
    *    @author         Pranav Raulkar
    *    @date           26/04/2016
    *    @description    Returns a map of email & true/false if the logged in enrollee is blacklisted for the ETA
    *    @param          etaIdSet - Set of ETAs. 
    *                    enrolleeEmailSet - Set of email Ids to check for blacklist.
    *    @return         Map<String, Boolean>
    *    @version        Archana Suryawanshi :Changed return type from Map<String, Boolean> to Map<id,Map<string,Boolean>
    */
    public static  Map<id,Map<string,Boolean>> areEnrolleeBlacklisted(Set<String> etaIdSet, Set<String> enrolleeEmailSet) {
        Logger.push('TrainingUtil', 'areEnrolleeBlacklisted');

        Map<id,Map<string,Boolean>> blacklistResultMap = new  Map<id,Map<string,Boolean>>();

        for(Enrollee_Blacklist__c eb : [SELECT Id, Email__c,Enterprise_Training_Agreement__c FROM Enrollee_Blacklist__c 
                                        WHERE Enterprise_Training_Agreement__c IN :etaIdSet 
                                        OR Email__c IN :enrolleeEmailSet]) {
            if(!blacklistResultMap.containskey(eb.Enterprise_Training_Agreement__c)) {
                if(enrolleeEmailSet.contains(eb.Email__c)){
                    blacklistResultMap.put(eb.Enterprise_Training_Agreement__c,new Map<string,Boolean>{eb.Email__c=>true});
                }
            }
           
        }

        Logger.pop();
        
        return blacklistResultMap;
    }
    
  /**
    *    @author        Archana Suryawanshi
    *    @date          26/04/2016
    *    @description   Returns Map allowedDomainResultMap - true/false if the logged in enrollee email domain is in allowed domain for the ETA
    *    @param         etaIdToEnrolleeEmailMap - Map of The enterprise training agreement id to Enrollee email
    *    @return        Map<String,Boolean> - Map of Enrollee email to boolean(allowed domain)
    *    @version       Archana Suryawanshi  : (Initial version)
    * *                 Archana suryawanshi  : Modified the code to validate the allowed domain if it is more than 1 
    *                                          levels deep if the allow sub domain flag is set to true.     
    */
   
     public static Map<id,Map<string,Boolean>> areEnrolleeFromAllowedDomain(Map<Id,String> etaIdToEnrolleeEmailMap) {
        Logger.push('TrainingUtil', 'areEnrolleeFromAllowedDomain');

        Boolean isEnrolleeFromAllowedDomain = false;
        List<Allowed_Domains__c> allowDomainList = new List<Allowed_Domains__c>();
        Map<id,Map<string,Boolean>> allowedDomainResultMap = new Map<id,Map<string,Boolean>>();
      
         for(Allowed_Domains__c adObj:[SELECT Id, Name, Allow_Sub_Domain__c,Enterprise_Training_Agreement__c
                                       FROM Allowed_Domains__c 
                                       where Enterprise_Training_Agreement__c in :etaIdToEnrolleeEmailMap.keySet()]){   
          if(etaIdToEnrolleeEmailMap.get(adObj.Enterprise_Training_Agreement__c)!=null){
                                           
            String enrolleeEmail = etaIdToEnrolleeEmailMap.get(adObj.Enterprise_Training_Agreement__c);
            String enrolleeEmailDomain = etaIdToEnrolleeEmailMap.get(adObj.Enterprise_Training_Agreement__c).split('@')[1]; 

            if(adObj.Allow_Sub_Domain__c) {
                if(enrolleeEmailDomain.endsWith(adObj.Name)) {
                    allowedDomainResultMap.put(adObj.Enterprise_Training_Agreement__c,new Map<string,Boolean>{enrolleeEmail=>true});
                }                 
            } else {
                if(enrolleeEmailDomain.compareTo(adObj.Name) == 0){
                    allowedDomainResultMap.put(adObj.Enterprise_Training_Agreement__c,new Map<string,Boolean>{enrolleeEmail=>true});
                }
            }
            
        }

        Logger.pop();
    }
        return allowedDomainResultMap;
    }
    
    /**
    *    @author        Sagar Talele
    *    @date          26/04/2016
    *    @description   Get the logged in user's contact ids
    *    @return        Map of String,id
    */
    public static Map<String,Id> getLoggedInUserContactIds(Set<String> emailSet) {
        Logger.push('TrainingUtil', 'getLoggedInUserContactIds');
        List<User> loggedInUser = new List<User>();
        Map<String,Id> userEmailToConIdMap = new Map<String,Id>();
        loggedInUser = [SELECT ContactId,Email FROM User WHERE Email IN :emailSet];
        for(User userObj : loggedInUser){
            userEmailToConIdMap.put(userObj.Email,userObj.ContactId);
        }
        Logger.pop();
        
        return userEmailToConIdMap;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          26/04/2016
    *    @description   Returns all Training Agreement Class Relationship associated with an ETA
    *    @param         etaIdSet - Set of Enterprise Training Agreement Ids
    *    @return        List<Training_Agreement_Class_Relationship__c>
    */
    public static List<Training_Agreement_Class_Relationship__c> getTrainingAgreementClassRelationForETA(Set<Id> etaIdSet) {
        Logger.push('TrainingUtil', 'getTrainingAgreementClassRelationForETA');
        List<Training_Agreement_Class_Relationship__c> tacRelList = [SELECT Class__r.Course__c,Class__c,Class__r.Course_Code__c,class__r.Enrollee_Seats_Taken__c,
                                                                    Class__r.Format_Of_Class__c,Class__r.Language__r.Language_Code__c,Class__r.status__c,
                                                                    Enterprise_Training_Agreement__r.Max_Seats__c 
                                                                    FROM Training_Agreement_Class_Relationship__c
                                                                    WHERE Enterprise_Training_Agreement__c IN :etaIdSet];
        Logger.pop();
        return tacRelList;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          26/04/2016
    *    @description   Returns all Training Agreement Class Relationship associated with an ETA
    *    @param         etaIdSet - Set of Enterprise Training Agreement Ids
    *                   enrolleeEmailSet - Set of enrollee email ids to get the enrollments for
    *                   enrollmentStatus - The status for which to get the enrollments for
    *    @return        Map<Id, List<Enrollment__c>>
    */
    public static Map<Id, List<Enrollment__c>> getEnrollmentsForETA(Set<Id> etaIdSet, Set<String> enrolleeEmailSet, String enrollmentStatus) {
        Logger.push('TrainingUtil', 'getEnrollmentsForETA');
        
        Map<Id, List<Enrollment__c>> etaEnrollmentMap = new Map<Id, List<Enrollment__c>>();

        for(Enrollment__c enrollment : [SELECT Class__c, Class__r.Course__c, CreatedDate, Enterprise_Training_Agreement__c
                                        FROM Enrollment__c 
                                        WHERE Enterprise_Training_Agreement__c IN :etaIdSet
                                        AND Enrollment_Status__c = :enrollmentStatus
                                        AND Enrollee_Name__r.Email IN :enrolleeEmailSet]) {
            if(etaEnrollmentMap.containsKey(enrollment.Enterprise_Training_Agreement__c)) {
                etaEnrollmentMap.get(enrollment.Enterprise_Training_Agreement__c).add(enrollment);
            } else {
                etaEnrollmentMap.put(enrollment.Enterprise_Training_Agreement__c, new List<Enrollment__c> { enrollment });
            }
        }
        
        Logger.pop();
        
        return etaEnrollmentMap;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          02/05/2016
    *    @description   Returns count of seats taken for each class in an eta
    *    @param         etaIdSet - Set of Enterprise Training Agreement Ids
    *                   classIdSet - Set of class Ids
    *                   In case there are no enrollments for a class for an ETA, you should be checking if the inner map is null.
    *    @return        Map<Id, Map<Id, Integer>>
    */
    public static Map<Id, Map<Id, Integer>> getConsumedSeatCountForETA(Set<Id> etaIdSet, Set<Id> classIdSet) {
        Logger.push('TrainingUtil', 'getConsumedSeatCountForETA');

        Map<Id, Map<Id, Integer>> etaClassCountMap;

        if(etaIdSet != null && !etaIdSet.isEmpty()) {
            Set<Id> recTypeIdSet = new Set<Id> {
                Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Seat-Based').getRecordTypeId(),
                Schema.SObjectType.Enterprise_Training_Agreement__c.getRecordTypeInfosByName().get('Unlimited').getRecordTypeId()
            };

            Set<String> statusSet = new Set<String> {
                'Registered', 'Registered - Awaiting Payment', 'Completed'
            };

            List<Enrollment__c> enrollmentList = [SELECT Class__c, Enterprise_Training_Agreement__c FROM Enrollment__c 
                                                    WHERE Class__c = :classIdSet 
                                                    AND Enterprise_Training_Agreement__c IN :etaIdSet 
                                                    AND Enterprise_Training_Agreement__r.RecordTypeId IN :recTypeIdSet 
                                                    AND Enrollment_Status__c IN :statusSet];

            etaClassCountMap = new Map<Id, Map<Id, Integer>>();

            for(Enrollment__c enrollment : enrollmentList) {
                Id classId = enrollment.Class__c;
                Id etaId = enrollment.Enterprise_Training_Agreement__c;

                if(etaClassCountMap.containsKey(etaId)) {
                    Map<Id, Integer> classCountMap = etaClassCountMap.get(etaId);
                    if(classCountMap.containsKey(classId)) {
                        Integer count = classCountMap.get(classId);
                        classCountMap.put(classId, ++count);
                    } else {
                        classCountMap.put(classId, 1);
                    }  
                    etaClassCountMap.put(etaId, classCountMap);                  
                } else {
                    etaClassCountMap.put(etaId, new Map<Id, Integer> { classId => 1 });
                }
            }
        }

        Logger.pop();

        return etaClassCountMap;
    }

    /**
    *    @author        Pranav Raulkar
    *    @date          04-May-2016
    *    @description   Creates a version 3 GUID
    *    @return        String
    */
    public static String generateGUID() {
        Logger.push('TrainingUtil', 'generateGUID');

        Blob aesKey = Crypto.generateAesKey(128);
        String hexAesKey = EncodingUtil.convertToHex(aesKey);

        Logger.pop();

        return String.join(new List<String> {
            hexAesKey.substring(0, 8),
            hexAesKey.substring(8, 12),
            hexAesKey.substring(12, 16),
            hexAesKey.substring(16, 20),
            hexAesKey.substring(20)
        }, '-');
    }
    
    /**
    *    @author        Abhay Verma
    *    @date          05-May-2016
    *    @description   Creates Enrollment from a non exceptional enrollment request object.
    *    @return        List<Enrollment__c>
    */    
    public static List<Enrollment__c> createEnrollmentFromEnrollmentRequest(List<Enrollment_Request__c> enrolReqLst) {
        Logger.push('TrainingUtil', 'createEnrollmentFromEnrollmentRequest');

        List<Enrollment__c> enrolLst = new List<Enrollment__c>();

        if(enrolReqLst != null && enrolReqLst.size() >0) {        
            // Iterate over the enrollment request list and create enrollment with the respected values.
            for(Enrollment_Request__c enrolReqObj : enrolReqLst) {                
                Enrollment__c enrolObj = new Enrollment__c();
                enrolObj.Start_Date__c = enrolReqObj.Enterprise_Training_Agreement__r.Term_Start_Date__c > Date.Today() ? enrolReqObj.Enterprise_Training_Agreement__r.Term_Start_Date__c : Date.Today();
                enrolObj.End_Date__c = enrolReqObj.Enterprise_Training_Agreement__r.Term_End_Date__c;
                enrolObj.Send_Email__c = false;
                enrolObj.Enrollment_Status__c = 'Registered';
                enrolObj.Enrollee_Name__c = enrolReqObj.Contact__c;
                enrolObj.Enterprise_Training_Agreement__c = enrolReqObj.Enterprise_Training_Agreement__c;
                enrolObj.Class__c = enrolReqObj.Class__c;
                enrolObj.CurrencyIsoCode = enrolReqObj.Enterprise_Training_Agreement__r.CurrencyIsoCode;
                enrolObj.Order_Number__c = enrolReqObj.Enterprise_Training_Agreement__r.Order_Number__c;
                enrolObj.Enrollment_Code__c = enrolReqObj.Enrollment_Code__c;
                enrolObj.Seat_Price__c = 0.00; 
                enrolObj.Source__c = enrolReqObj.Source__c;
                enrolLst.add(enrolObj);
            }
        }

        Logger.pop();
        
        return enrolLst;
    }
}