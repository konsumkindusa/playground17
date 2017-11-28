/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original:   29 July 2015, Last Modified: 29 July 2015
 *@description:     This is a Dml class for Enterprise_Training_Agreement__c Object.
 */
public class ETAgreementDml {
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 29 July 2015
     *@description: Method that handles Dml events for Enterprise_Training_Agreement__c object.
     */
    public void insertTAgreementClassRelationship(List<Enterprise_Training_Agreement__c>ETAgreemetLst){
    
        Logger.push('insertTAgreementClassRelationship','ETAgreementDml ');
        
        //instantiating the List which contains list of Class__c records for status Active and record Type Self-paced
        List<Class__c> classlist = new List<Class__c> ();
        classlist = [Select Id,Name,Status__c,RecordType.Name From Class__c Where Status__c = 'Active' And RecordType.Name = 'Self-Paced'];
        //instantiating the List which contains list of Training_Agreement_Class_Relationship__c records
        List<Training_Agreement_Class_Relationship__c> TAgreementClassRelList = new List<Training_Agreement_Class_Relationship__c>();
        
        for(Enterprise_Training_Agreement__c ETAgreementObj : ETAgreemetLst){
            for(Class__c classObj : classlist){
                Training_Agreement_Class_Relationship__c TAgreementClassRelObj = new Training_Agreement_Class_Relationship__c();
                TAgreementClassRelObj.Class__c = classObj.Id;
                TAgreementClassRelObj.Enterprise_Training_Agreement__c = ETAgreementObj.Id;
                TAgreementClassRelList.add(TAgreementClassRelObj);
            }
        }
        
        //check list is not empty
        if(!TAgreementClassRelList.isEmpty()){
            try{
            insert TAgreementClassRelList;
            }
            catch(DMLException ex){
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                 //Process exception here
                Logger.debugException('Error in inserting Training Agreement Class Relationship Record Object:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
                }
            }
        }
        
        Logger.pop();
    }
}