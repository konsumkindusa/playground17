/*
 *Name: ECodeTracker
 *Author: Neha Mahajan
 *Description: For the registered and available section of classes. 
*/

public class EcodeTracker{
	
    public static void main(){

        Set<id> ETAset= new Set<id>();
        Set<id> EnObj= new Set<id>(); 
        Set<id> ClObj=new Set<id>();
        
        // User record to get the contactid
        User userObj= new User();
        userObj=[Select Id, Contactid, username from User where Id = :UserInfo.getUserId()];
        // Enrollment code and its associated ETA 
        list<Enrollment_Code__c> CodeObj=new list<Enrollment_Code__c>();
        CodeObj=[Select id, Enterprise_Training_Agreement__c from Enrollment_Code__c];
    	System.debug('****'+CodeObj);
    
        for(Enrollment_Code__c ecodeObj:CodeObj){
            ETAset.add(ecodeObj.Enterprise_Training_Agreement__c);
        }
            
        Map<id,list<Enrollment__c>> ClassMap= new Map<id,list<Enrollment__c>>();
        // Enrollment record which stores the classes and enrollments with status registered.
        list<Enrollment__c> EnrollObj= new list<Enrollment__c>();
        
        
        EnrollObj=[select id,Enterprise_Training_Agreement__c, Class__c,Class__r.Course__c,Class__r.name from Enrollment__c where Enterprise_Training_Agreement__c in :ETAset And Enrollment_Status__c='Registered' and Enrollee_Name__c=:userObj.Contactid];
        System.debug('**Classes Registered**'+EnrollObj);
            for(Enrollment__c EnrolObj:EnrollObj){
                        
           if(ClassMap.containsKey(EnrolObj.id)){
                ClassMap.get(EnrolObj.id).add(EnrolObj);
            }
            else{
                ClassMap.put(EnrolObj.id,new List<Enrollment__c>{EnrolObj});
            }    
            }
            
    for(Enrollment__c EnrolObj:EnrollObj){
       EnObj.add(EnrolObj.Class__c);
       ClObj.add(EnrolObj.Class__r.Course__c);
       
    }
   
    list<Course_Language__c> Clang= new list<Course_Language__c>();
    Clang=[Select Course__c, Course_Language__c,id, name from Course_Language__c where Course__c in :ClObj];
    System.debug('****'+Clang);  
        
    // Map to store available classes for an ETA.    
    Map<id,list<Training_Agreement_Class_Relationship__c>> TACObjMap= new Map<id,list<Training_Agreement_Class_Relationship__c>>();
    list<Training_Agreement_Class_Relationship__c> etaObj=new list<Training_Agreement_Class_Relationship__c>();
    etaObj=[select id, Class__r.Name,Enterprise_Training_Agreement__c from Training_Agreement_Class_Relationship__c where Enterprise_Training_Agreement__c in :ETAset];
        if(!TACObjMap.keySet().isEmpty() && TACObjMap.keySet() != null){
        for(Training_Agreement_Class_Relationship__c TAClass:etaObj){
            if(TACObjMap.containsKey(TAClass.id)){
               TACObjMap.get(TAClass.id).add(TAClass);
               }
            else
            {
              TACObjMap.put(TAClass.id, new List<Training_Agreement_Class_Relationship__c>{TAClass});
            }
        } 
      }
	}
         
}