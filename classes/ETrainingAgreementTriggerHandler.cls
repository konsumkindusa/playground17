/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks, Faina Gorelik MathWorks AtTask 2238455 /
 *@date Original:   29 July 2015, Last Modified: 29 July 2015, August 2017
 *@description:     This is a handler class for Enterprise Training Agreement 
 */
public class ETrainingAgreementTriggerHandler{
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 29 July 2015
     *@description: Method that handles After insert trigger event on the Enterprise_Training_Agreement__cobject.
     */
    public void onAfterInsert(List<Enterprise_Training_Agreement__c>ETAgreementLst){
        
        Logger.push('onAfterInsert','ETrainingAgreementTriggerHandler');
        ETAgreementDml ETAgreemetDmlObj = new ETAgreementDml ();
        //instantiating the Set of course id 
        Set<Id> ETAgreementId= new Set<Id>();
        //instantiating the List which contains list of course records
        List<Enterprise_Training_Agreement__c> ETAgreementList = new List<Enterprise_Training_Agreement__c>();
        
        //TODO: Do we need a SOQL for this? Can't we use schema methods for this?
        Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Enterprise_Training_Agreement__c']);
        
        //iterate over the  Enterprise Training Agreement List 
        for(Enterprise_Training_Agreement__c EtAgreementObj : ETAgreementLst){
           
              if(rt_map.get(EtAgreementObj.recordTypeID).name.containsIgnoreCase('Unlimited')){
                  ETAgreementId.add(EtAgreementObj.Id);
              }
           // we might need to create a different list to pass to MAOTS to combine with seat based ETAs
       }
       
        //check set is not empty
       if(!ETAgreementId.isEmpty()){
             //query the Enterprise Training Agreement records which involved in trigger event 
            ETAgreementList = [Select Id,Name From Enterprise_Training_Agreement__c Where Id In :ETAgreementId];
        }
        
        //check list is not empty
        if(!ETAgreementList.isEmpty()){
            //send Enterprise Training Agreement list  to EEnterprise Training Agreement  Dml Class       
            ETAgreemetDmlObj.insertTAgreementClassRelationship(ETAgreementList);
      
        }
        
        Logger.pop();
    
    }
    
    public void onAfterUpdate(map<Id, Enterprise_Training_Agreement__c> oldmap, map<Id, Enterprise_Training_Agreement__c> newmap){
 
    /**
     *@author Original: Faina Gorelik - Mathworks
     *@date Original: 16 September 2017, Last Modified: 
     *@description: Method that handles After update  trigger event on the Enterprise_Training_Agreement__cobject.
     */
        Set <Id> Set_ETAId = new Set<id>(); // pass to future call to send to Training Authorization;
        for (Enterprise_Training_Agreement__c eta : newmap.values()){
            // filter only ETAs with the updated fields we pass to Training Authorization or if we need to trigger the existing record by setting Submit Batch flag to true
            if((oldmap.get(eta.id).Submit_Batch__c != eta.Submit_Batch__c && eta.Submit_Batch__c==true ) || (oldmap.get(eta.id).Classes__c  != eta.Classes__c) || (oldmap.get(eta.id).License_ID__c != eta.License_ID__c) || (oldmap.get(eta.id).Term_End_Date__c  != eta.Term_End_Date__c) ||(oldmap.get(eta.id).Term_Start_Date__c  != eta.Term_Start_Date__c)  ){
                Set_ETAId.add(eta.Id);                
            }
        }
        
        if (Set_ETAId.size()>0){
                TrainingAgreementClassDML.callMAOTS(Set_ETAId);
        }
    }
    

}