/**
*author Original: Faina Gorelik
*date Original: 13 September 2017, Last Modified:
*description : This  is handler class for TrainingAgreementClassRelationship object AtTask 2238455
*/

public class TrainingAgreementClassTriggerHandler {
    public void onAfterInsert (List<Training_Agreement_Class_Relationship__c> List_TAClass){
        
        Logger.Push('TrainingAgreementClassTriggerHandler','onAfterInsert');
        set<Id> taIdset = new set<Id>(); // inserted ETA ids from inserted training agreement class list
        set <id> etaIdset = new set<id>(); // eta ids pass to maots 
        List<Training_Agreement_Class_Relationship__c> TAwithCourse = new List<Training_Agreement_Class_Relationship__c>();// list of the eta ids from the inserted  list with course id the class associated with 
        List<Enterprise_Training_Agreement__c> ETAList = new List<Enterprise_Training_Agreement__c>();// list of eta with license id, and courses rollup summary 
        
        for (Training_Agreement_Class_Relationship__c tac : List_TAClass ){             
            taIdset.add(tac.Enterprise_Training_Agreement__c);// add unique ETA Ids         
        }

            if (taIdset.size()>0){// send to DML to pass records to  MAOTS // replace with new list to be passed
          //  if (canIRun()){    
                TrainingAgreementClassDML.callMAOTS(taIdset); 
           // }  
        }
        
        Logger.Pop();        
    }
    
    public void onAfterUpdate(map<Id, Training_Agreement_Class_Relationship__c> oldmap, map<Id, Training_Agreement_Class_Relationship__c> newmap){
        
    }
    
    /** Helper methods for disabling or enabling a functionality**/
    /*public static boolean allowrun = true;
    public static boolean allowupdate = true;
    public void stopUpdateSubStatus(){
        allowupdate = false;
    }
    public void stopTrigger(){
        allowrun = false;
    }
    public void runTrigger(){
        allowrun = true;
    }
    public static boolean canIRun(){
        return allowrun;
    }
    public static boolean canIRunUpdateStatus(){
        return allowupdate;
    }*/
}