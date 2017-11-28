/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Andy Ognenoff - Cloud Sherpas/Mathworks
 *@date Original:   3 June 2015, Last Modified: 30 June 2015
 *@description:     This is a handler class for Course 
 */
public class CourseTriggerHandler {
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Krishna Bhaskarla - Mathworks
     *@date Original: 13 May 2015, Last Modified: 30 Jun 2015
     *@description: Method that handles After insert trigger event on the Course__c object.
     */
    public void onAfterInsert(List<Course__c>courseLst){
        
        Logger.push('onAfterInsert','CoursetriggerHandler ');
        CourseDml courseDmlObj = new CourseDml();
        //instantiating the Set of course id 
        Set<Id> courseId = new Set<Id>();
        //instantiating the List which contains list of course records
        List<Course__c> courseList = new List<Course__c>();

        for(Course__c courseObj : courseLst){
            courseId.add(courseObj.Id);
        }
        //query the Course records which involved in trigger event 
        // Change for pre-requisite and shortDescription -- Neha Mahajan
        courseList = [Select Id,Name,Pre_Requisite__c,Short_Description__c From Course__c Where Id In :courseId];
        //chcek list is not empty
        if(!courseList.isEmpty()){
            //send course list and language list to course Dml Class       
            courseDmlObj.insertCourseLanguage(courseList);
            //call the insertCourseLanguage of CourseDml  class which perform dml operation 
            
            /**
            *@author Modified: Krishna Bhaskarla - Mathworks
             Last Modified: 23 Sep 2015
             *@description: No longer need to insert training domain for a course. Story Ref No: 1093975
            */
            
            //courseDmlObj.insertTrainDomainCon(courseList);
        }
        Logger.pop();
    
    }
}