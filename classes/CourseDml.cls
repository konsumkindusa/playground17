/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   3 June 2015, Last Modified: 3 June 2015
 *@description:     Class to handle delegated DML operations for Course object.
 */
public class CourseDml{
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 13 May 2015, Last Modified: 13 May 2015
     *@description: Method that handles insert records events for Course_Language__c object.
     */
    public void insertCourseLanguage(List<Course__c > courseList){
        Logger.push('insertCourseLanguage','CourseDml');
         //instantiating the List which contains list of Language__c records
        List<Language__c> langlist = new List<Language__c> ();
        //instantiating the List which contains list of Course_Language__c records
        List<Course_Language__c> clangList = new List<Course_Language__c>();
        //change for Localized_Pre_Requisite__c and Localized_Short_Description__c
        langlist = [Select Id,Name,ISO_Code__c From Language__c];
        for(Course__c cObj : courseList){
            //iterate over the langauge List 
            // addition of Localized_Pre_Requisite__c and Localized_Short_Description__c fields --- Neha Mahajan
            for(Language__c lObj : langlist){
                Course_Language__c cLangObj = new Course_Language__c ();
                cLangObj.Course__c = cObj.Id;
                cLangObj.Localized_Course_Name__c = cObj.Name;
                cLangObj.Course_Language__c = lObj.Id;
                cLangObj.Localized_Pre_Requisite__c=cObj.Pre_Requisite__c;
                cLangObj.Localized_Short_Description__c=cObj.Short_Description__c;
                clangList.add(cLangObj);
            }
    
        }
        try{            
            if(!clangList.isEmpty()){
                //insert list of Course language Object.
                 insert  clangList;
            }
        }
        catch (System.DmlException e) {
            // Capture Dml exception here
            Logger.debugException('DmlException:'+e);
        }
        Logger.pop();
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Krishna BhaskarlaMathworks
     *@date Original: 25 June 2015, Last Modified: 25 June 2015
     *@description: Method that handles insert records events for Training_Domain_Connections__c object.
                    No longer need this code. Story Ref No: 1093975
     */
    /*public void insertTrainDomainCon(List<Course__c > courseList){
         Logger.push('insertTrainDoaminCon','CourseDml');
         //instantiating the List which contains list of Training_Domain__c records
         List<Training_Domain__c> tDomainlist = new List<Training_Domain__c> ();
         //instantiating the List which contains list of Training_Domain__c records
         List<Training_Domain_Connections__c> tDomainConlist = new List<Training_Domain_Connections__c> ();
         //logic for insertion of Training Domain Connection
        tDomainlist = [Select Id,Status__c From Training_Domain__c where Status__c = 'Active'];
         //iterate over the course List
         for(Course__c cObj : courseList){
             //iterate over the Training Domain List
            for(Training_Domain__c tdomainObj : tDomainlist ){
                Training_Domain_Connections__c trainDConObj = new Training_Domain_Connections__c ();
                trainDConObj.Course__c = cObj.Id;
                trainDConObj.Training_Domain__c = tdomainObj.Id;
                tDomainConlist.add(trainDConObj);
            }
         }
         try{            
             if(!tDomainConlist.isEmpty()){
                 //insert list of Training Domain Connection Object.
                 insert  tDomainConlist;
             }
         }
         catch (System.DmlException e) {
             // Capture Dml exception here
             Logger.debugException('DmlException:'+e);
         }
         Logger.pop();
    } */

}