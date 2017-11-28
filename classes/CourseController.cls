/**
*   @author          Pranav Raulkar
*   @date            10-May-2016
*   @description     Course component controller
*   @revision        1.0 - Initial version
*/
public without sharing class CourseController {
    public String etAgreementID { get; set; }
    public String language { get; set; }
    public List<Course_Language__c> courseLanguageList { get {
            Logger.push('CourseController', 'courseLanguageList');

            Set<Id> courseIdSet = new Set<Id>(); 

            // Get all active class's course for the ETA 
            List<Training_Agreement_Class_Relationship__c > etaRelList = [SELECT Class__r.Course__c 
                                                                            FROM Training_Agreement_Class_Relationship__c 
                                                                            WHERE Enterprise_Training_Agreement__c = :etAgreementID 
                                                                            AND Class__r.Status__c = 'Active'];                                                         
            for(Training_Agreement_Class_Relationship__c tacRelObj : etaRelList){
                courseIdSet.add(tacRelObj.Class__r.Course__c);                                                     
            }
            
            // Get localized details for the course from course language
            List<Course_Language__c> courseLangList = [SELECT Localized_Course_Name__c, Localized_Short_Description__c 
                                                        FROM Course_Language__c 
                                                        WHERE Course__c IN :courseIdSet 
                                                        AND Course_Language__r.SF_ISO_Code__c = :language
                                                        ORDER BY Course__r.Display_Sort_Order__c ASC];
            Logger.pop();

            return courseLangList;
        } set;  
    }
    
 //   /**
    //*   @author         Abhay Verma/Pranav Raulkar
    //*   @date           10-May-2016
    //*   @description    Course component controller
    //*   @return           List<Course_Language__c>
    //*/
 //   private List<Course_Language__c> getCourseLanguage() {
 //     Logger.push('CourseController', 'getCourseLang');

 //       Set<Id> courseIdSet = new Set<Id>(); 

 //       // Get all active class's course for the ETA 
 //       List<Training_Agreement_Class_Relationship__c > etaRelList = [SELECT Class__r.Course__c 
 //                                                                     FROM Training_Agreement_Class_Relationship__c 
 //                                                                     WHERE Enterprise_Training_Agreement__c = :etAgreementID 
 //                                                                     AND Class__r.Status__c = 'Active'];                                                         
 //       for(Training_Agreement_Class_Relationship__c tacRelObj : etaRelList){
 //           courseIdSet.add(tacRelObj.Class__r.Course__c);                                                     
 //       }

 //       System.debug('## courseIdSet: ' + courseIdSet);
        
 //       // Get localized details for the course from course language
 //       List<Course_Language__c> courseLangList = [SELECT Localized_Course_Name__c, Localized_Short_Description__c 
 //                                                 FROM Course_Language__c 
 //                                                     WHERE Course__c IN :courseIdSet 
 //                                                     AND Course_Language__r.SF_ISO_Code__c = :language];
 //       Logger.pop();

 //       return courseLangList;
 //   }
}