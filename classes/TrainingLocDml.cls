/**
 *@author Original: Krishna Bhaskarla, Mathworks
 *@date Original:   Aug 19, 2015
 *@description:     This is a DML class for Training loc Object.
 */
public class TrainingLocDml {
    /**
     *@author Original: Krishna Bhaskarla, Mathworks
     *@date Original: 29 June 2015, Last Modified: 07 July 2015
     *@description: This function prevents deletion of a location when the publish to web status is true
     */
    public void preventDelTrainingLoc(List<Training_Location__c>trainLocLst){
        Logger.push('preventDelTrainingLoc','TrainingLocDml');
        //iterate over the list to check training location has publish to web flag set to true 
        for(Training_Location__c locObj: trainLocLst){
            if(locObj.Publish_To_Web__c){
                	
                   Training_Location__c actualRecord =(Training_Location__c ) Trigger.oldMap.get(locObj.Id);
                   actualRecord.addError(system.label.Training_location_before_delete);
                System.debug('########'+actualRecord.Id);
            }
        }
        Logger.pop();
    }
    /**
     *@author Original: Krishna Bhaskarla, Mathworks
     *@date Original: 9 Sep 2015
     *@description: This function returns error if user attempts to unpublish a training location with one or more associated classes
     */
    public void restrictLocUnpublish(List<Training_Location__c>trainLocList){
         Logger.push('restrictLocUnpublish','TrainingLocDml');
         //iterate over the list and display error
         for(Training_Location__c locObj: trainLocList){
             Training_Location__c actualRecord =(Training_Location__c ) Trigger.newMap.get(locObj.Id);
              actualRecord.Publish_To_Web__c.addError(system.label.Training_location_before_update);
            
         }
         
         Logger.pop();
    }

}