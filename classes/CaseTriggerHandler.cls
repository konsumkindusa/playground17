/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks  
* @date Original: 03 June 2013, Last Modified: 27/11/2014
* @author modified: Archana Lohar;Date: 27/11/2014; Method: onBeforeUpdate
* @description Trigger handler class for Case
* @Revision Archana Lohar|27 Nov 2014|Added call to updateCaseAccount method of caseDml in onBeforeUpdate
                                      for updating the Account based on the Account.Opportunity relationship of an opportunity related to the case
       
*/
public class CaseTriggerHandler {
    
    /**
      * @author Original: Jesfer Baculod - Cloud Shepras/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
      * @date Original: 11 June 2013, Last Modified: 27 October 2013
      * @description Method that handles before insert trigger event on the Case object
      * @param List_Cases A collection of Cases to create new Case
    */
    public void onBeforeInsert(List<Case> List_Cases){
         
        CaseDML cseDML = new CaseDML();
        //calls the CaseDML EmailToCaseLoopKiller that prevents a Case to be inserted if Case has been created a couple of times by the Inbound Handler
        cseDML.EmailToCaseLoopKiller(List_Cases,'before'); //(Only applies to Inbound Email created Cases)
        //calls the CaseDML UpdateCaseProductFields that updates Case's Product lookup and Product Base Code fields
        cseDML.UpdateCaseProductFields(null,null,List_Cases);

        //calls the CaseDML updateCaseOwnerEmailTemplateInfo that updates Case's Email Template Signature and Disclosure fields;
        cseDML.updateCaseEmailTemplateInfo(List_Cases);
        //calls the CaseDML updateCaseOwnerEmailTemplateInfo that updates Case's Area field;
        cseDML.updateCaseArea(List_Cases);
        
        //call the CaseDML updateCaseAreaSubArea that updates the area, subarea based on the case origin         
         cseDML.updateCaseAreaSubArea(List_Cases);         
         
        
        //call the CaseDML updateCaseAccount that updates the Account based on the Account.Opportunity relationship of an opportunity related to the case
         cseDML.updateCaseAccount(List_Cases);  
        
    }

    /**
      * @author Original: Jesfer Baculod - Cloud Shepras/Mathworks
      * @date Original: 04 June 2013, Last Modified: 27 October 2013
      * @description Method that handles after insert trigger event on the Case object
      * @param List_Cases A collection of Cases to create new Case
    */
    public void onAfterInsert(List<Case> List_Cases){
         
         Set <Id> Set_OnSupport_CaseID = new Set <Id>();
         
         for (Case cse : List_Cases){
             
            //Case Ids for OnSupport
            if (cse.License__c != null){
                Set_OnSupport_CaseID.add(cse.Id);
            }            
            
         }
         // fg commented, webservice will be replaced by REST
         // fg added
    
         //calls the CaseDML checkOnSupport method that updates On Support fields by doing webservice callouts
        if (Set_OnSupport_CaseID.size() > 0){
             //Trigger check that allows or stops the trigger on running
             if (canIRun()){
                CaseDML.checkOnSupport(Set_OnSupport_CaseID);
             }
         }
         // fg end commented
         CaseDML cseDML = new CaseDML();
         cseDML.EmailToCaseLoopKiller(List_Cases,'after'); //(Only applies to Inbound Email created Cases)
         
         
         
    }
    
    /**
      * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
      * @date Original: 11 June 2013, Last Modified: 30 Sept 2013
      * @description Method that handles before update trigger event on the Case object
      * @param oldmap case records with old values
      * @param newmap case records with new values
      
    */
    public void onBeforeUpdate(map<Id, Case> oldmap, map<Id, Case> newmap){
        
        CaseDML cseDML = new CaseDML();
        CustomSettingsBuilder csb = new CustomSettingsBuilder();
        
        List<Case> cseList=new List<Case>();
        
        //calls the CaseDML UpdateCaseProductFields that updates Case's Product lookup and Product Base Code fields
        cseDML.UpdateCaseProductFields(oldmap,newmap,null);
        
        map <Id,Case> Map_CaseEmailTemplateInfo = new map <Id,Case>();
        for (Case cse : newmap.values()){
            //Filter only Case records which Case Owner is updated - for updateCaseOwnerEmailTemplateInfo
            if (oldmap.get(cse.Id).OwnerId != cse.OwnerId){
                Map_CaseEmailTemplateInfo.put(cse.Id,cse);
            }
            
            //Filter only Case records which opporutnity ID is updated .
            if (oldmap.get(cse.Id).Opportunity__c != cse.Opportunity__c){
                
                cseList.add(cse);
            }
        }
        
        
        //calls the CaseDML updateCaseOwnerEmailTemplateInfo that updates Owners' Email Template Signature and Disclosure fields;
        cseDML.updateCaseEmailTemplateInfo(Map_CaseEmailTemplateInfo.values());
        //calls the CaseDML updateSubStatusonChangeOwnership that updates SubStatus base on Case Owner and 'Unassigned' substatus;
        if (canIRunUpdateStatus()){
            cseDML.updateSubStatusOnChangeOwnership(oldmap,newmap);
        }
        //calls the CaseDML CaseArticleCheck that updates Case fields needed for easy reporting of KCS metrics
        User ThisUser = [Select Id, UserPermissionsKnowledgeUser From User Where Id = : UserInfo.getUserId()];
        if (UserInfo.getProfileId() != csb.getUtilOverageHighVolumCustomerPortalUserProfileId() && ThisUser.UserPermissionsKnowledgeUser == true){
            //do not execute CaseArticleCheck if the user is a customer portal user
            cseDMl.CaseArticleCheck(newmap.values());
        }
        
        //call update area changed method to update the fields
        cseDML.UpdateAreaChangedDates(oldmap,newmap);
        
        //call the CaseDML updateCaseAccount that updates the Account based on the Account.Opportunity relationship of an opportunity related to the case
         cseDML.updateCaseAccount(cseList);
    }
    
    /**
      * @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
      * @date Original: 04 June 2013, Last Modified: SS 8/25/16
      * @description Method that handles after update trigger event on the Case object
      * @param oldmap case records with old values
      * @param newmap case records with new values
    */
    public void onAfterUpdate(map<Id, Case> oldmap, map<Id, Case> newmap){
        
        CaseDML cseDML = new CaseDML();
        
        Set <Id> Set_OnSupport_CaseID = new Set <Id>();
        Set <Id> cseIds = new Set <Id>(); //SS 12/27/13 G1017545
        
        for (Case cse : newmap.values()){
        
            //Filter only Case records which have License or product updated - ( SS 8/25/16 Added product logic for #1589868)
            if ((oldmap.get(cse.Id).License__c != cse.License__c) || (oldmap.get(cse.Id).Product_Lookup__c != cse.Product_Lookup__c)){
                Set_OnSupport_CaseID.add(cse.Id);
                System.Debug('**Faina After Update**'+ Set_OnSupport_CaseID);
            }
            

           
            //SS 12/27/13 G1017545 - Close open tasks associated to case when a case is Closed
            //FG 4/22/14 G1063136 - Complete open tasks associated to the Cancelled case
            //DL 4/22/14 G1062257 - modification from G1017545 - to only close for specific areas.
            //SS 2/4/2015 Attask:749127 - removed specific area values from code and created a Custom Setting : Areas Case task Closure
     
            // Close all open tasks when case is closed based on the value in Area.
            Boolean areaMatch = false;
            String targetString = cse.Area__c;
            if (null != targetString) {
                
                for(Areas_Case_Task_Closure__c caseAreaRec : Areas_Case_Task_Closure__c.getAll().values()){
                    if(targetString.indexOf(caseAreaRec.Name) > -1)
                    {
                        System.debug('**targetString**'+targetString);
                        areaMatch = true;
                        break;
                    }
                }
            }
             
            //Gather list of Cases with Tasks to mark Complete
            if (oldmap.get(cse.Id).Status != cse.Status && ((cse.Status == 'Closed' && areaMatch)||cse.Status == 'Cancelled')   && cse.Escalation_to__c == null ){
                 System.debug('**targetString**'+targetString);
                cseIds.add(cse.Id);
            }     
        }
        
        
        if (cseIds.size() > 0){
        
        cseDML.closeTaskStatusForCloseCase(cseIds);
        }
        
        // fg added
       // CaseDML.checkOnSupport(Set_OnSupport_CaseID);
        //calls the CaseDML checkOnSupport method that updates On Support fields by doing webservice callouts
        // fg commented as webservice replaced by REST 
        if (Set_OnSupport_CaseID.size() > 0){
            //Trigger check that allows or stops the trigger on running
            if (canIRun()){
                CaseDML.checkOnSupport(Set_OnSupport_CaseID);
            }
        }
        // fg end
    }
    
    /** Helper methods for disabling or enabling a functionality**/
    public static boolean allowrun = true;
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
    }
        
}