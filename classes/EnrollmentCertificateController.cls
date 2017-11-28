/**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 14 Sep 2015, Last Modified: 14 Sep 2015
     *@description: Controller Class for EnrollmentTrainingCertProfessional component
      */
public Class EnrollmentCertificateController{
      
    public String enrollId{get;set;}
    boolean isLatin;
    LatinAddressUtilityHelper latinAddObj = new LatinAddressUtilityHelper();
    public String enrolleeName;
    public String enrolleeNameForCompletionCert;
    public String examDate{get;set;}
    Enrollment__c  enrollRec;
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 14 Sep 2015, Last Modified: 22 Sep 2015
     *@description: This method is for getting the value of Enrollment record
      */
    public Enrollment__c getEnrollmentRec() {
        if(enrollId !=null){
            enrollRec = [Select Id,
                                Name,
                                Enrollee_Name__r.name,
                                Class__r.Name,
                                Enrollee_Name__r.LastName,
                                Enrollee_Name__r.FirstName,
                                Class__c,
                                Class__r.Course__r.Name,
                                Class__r.Exam_Date_For_Template__c,
                                Certification_Training_Dates__c,
                                Class__r.Sponsor_Office__r.name
                        From Enrollment__c where Id =: enrollId];
            System.debug('**enrollRec **'+enrollRec );        
            examDate = enrollRec.Class__r.Exam_Date_For_Template__c;
        }
        return enrollRec;
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 14 Sep 2015, Last Modified: 14 Sep 2015
     *@description:  This method is for getting the value of Enrollee Name 
      */
    public String getEnrolleeName () {
          Enrollment__c  enrollRec = [Select Id, 
                                           Enrollee_Name__r.Name,
                                           Enrollee_Name__r.LastName,
                                           Enrollee_Name__r.FirstName,
                                           Class__c,
                                           Class__r.Exam_Date_For_Template__c,
                                           Class__r.Sponsor_Office__r.name
                                    From Enrollment__c
                                    Where Id =: enrollId];
        
        
        
        if(enrollRec !=null){
            if(!latinAddObj.isLatin(enrollRec.Enrollee_Name__r.name) || enrollRec.Class__r.Sponsor_Office__r.name == 'JP' ){
                enrolleeName = enrollRec.Enrollee_Name__r.LastName.toupperCase() + ' '+enrollRec.Enrollee_Name__r.FirstName.toupperCase();
                System.Debug('enrolee name:'+enrolleename);
            }
            else{
                enrolleeName = enrollRec.Enrollee_Name__r.Name.toupperCase();
            }
        }
        return enrolleeName;
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 14 Sep 2015, Last Modified: 22 Sep 2015
     *@description: This method is for getting the value of Enrollee Name for EnrollmentCompletionCert component
      */
    public String getEnrolleeNameForCompletionCert() {
          Enrollment__c  enrollRec = [Select Id, 
                                           Enrollee_Name__r.Name,
                                           Enrollee_Name__r.LastName,
                                           Enrollee_Name__r.FirstName,
                                           Class__c,
                                           Class__r.Exam_Date_For_Template__c,
                                           Class__r.Sponsor_Office__r.name
                                    From Enrollment__c
                                    Where Id =: enrollId];
        
        
        
        if(enrollRec !=null){
            if(!latinAddObj.isLatin(enrollRec.Enrollee_Name__r.name)){
                enrolleeNameForCompletionCert = enrollRec.Enrollee_Name__r.LastName + ' '+enrollRec.Enrollee_Name__r.FirstName;
                System.Debug('enrolee name:'+enrolleeNameForCompletionCert );
            }
            else{
                enrolleeNameForCompletionCert = enrollRec.Enrollee_Name__r.Name;
            }
        }
        return enrolleeNameForCompletionCert ;
    }
    public boolean getIsSponsorOfficeJp(){
        Enrollment__c  enrollRec = [Select Id, 
                                           Enrollee_Name__r.Name,
                                           Enrollee_Name__r.LastName,
                                           Enrollee_Name__r.FirstName,
                                           Class__c,
                                           Class__r.Exam_Date_For_Template__c,
                                           Class__r.Sponsor_Office__r.name
                                    From Enrollment__c
                                    Where Id =: enrollId];
    
        if(enrollRec.Class__r.Sponsor_Office__r.name == 'JP'){
        return true;
        }
        else{
        return false;
        }
    }
}