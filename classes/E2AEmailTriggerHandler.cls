/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original: 12 Nov 2015, Last Modified:12 Nov 2015
 *@description:   This is a handler class for E2a Email 
 */
public class E2AEmailTriggerHandler{
    E2AEmailDml e2aEmailDml = new E2AEmailDml();
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 29 July 2015
     *@description: Method that handles After insert trigger event on the ortoo_e2a__EmailMessage__c object.
     */
    public void onAfterInsert(List<ortoo_e2a__EmailMessage__c>E2AEmailLst){
        Logger.push('onAfterInsert','ortoo_e2a__EmailMessage__c');

        Set<Id> AspIdSet = new Set<Id>();
        Set<Id> BpIdSet = new Set<Id>();
        Set<Id> PaIdSet = new Set<Id>();
        Set<Id> saIdSet = new Set<Id>();
        Set<Id> AspIdSet1 = new Set<Id>();
        Set<Id> BpIdSet1 = new Set<Id>();
        Set<Id> PaIdSet1 = new Set<Id>();
        
        //iterate over the list of e2a email 
        for(ortoo_e2a__EmailMessage__c e2aobj: E2AEmailLst){
            if(e2aobj.Academic_Support_Project__c != null && e2aobj.ortoo_e2a__Status__c == 'new'){
                 AspIdSet.add(e2aobj.Academic_Support_Project__c);
            }
            if(e2aobj.Book_Project__c != null && e2aobj.ortoo_e2a__Status__c == 'new'){
                BpIdSet.add(e2aobj.Book_Project__c);
            }
            if(e2aobj.Partner_Agreement__c != null && e2aobj.ortoo_e2a__Status__c == 'new'){
                PaIdSet.add(e2aobj.Partner_Agreement__c);
            }
            if(e2aobj.Social_Action__c != null && e2aobj.ortoo_e2a__Status__c == 'new'){
                saIdSet.add(e2aobj.Social_Action__c);
            }
            if (e2aobj.ortoo_e2a__Incoming__c) {
              if(e2aobj.Academic_Support_Project__c != null){
                   AspIdSet1.add(e2aobj.Academic_Support_Project__c);
              }
              if(e2aobj.Book_Project__c != null){
                  BpIdSet1.add(e2aobj.Book_Project__c);
              }
              if(e2aobj.Partner_Agreement__c != null){
                  PaIdSet1.add(e2aobj.Partner_Agreement__c);
              }
            }
        }
        
        //Check Set is not empty
        if(!AspIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnASP(AspIdSet);
        }
        //Check Set is not empty
        if(!BpIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnBP(BpIdSet);
        }
        //Check Set is not empty
        if(!PaIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnPA(PaIdSet);
        }
        //Check Set is not empty
        if(!saIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnSA(saIdSet);
        }
        if(!AspIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnASP(AspIdSet1);
        }
        //Check Set is not empty
        if(!BpIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnBP(BpIdSet1);
        }
        //Check Set is not empty
        if(!PaIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnPA(PaIdSet1);
        }
        Logger.pop();
    
    }
/**
    public void OnBeforeUpdate(Map<Id,ortoo_e2a__EmailMessage__c> idToE2aObjOld, Map<Id,ortoo_e2a__EmailMessage__c> idToE2aObjNew){
        Logger.push('OnBeforeUpdate','ortoo_e2a__EmailMessage__c');
        List<ortoo_e2a__EmailMessage__c> E2AEmailLst = new List<ortoo_e2a__EmailMessage__c>();
        E2AEmailLst = idToE2aObjNew.values();
        System.debug('**E2AEmailLst **'+E2AEmailLst );
        for(ortoo_e2a__EmailMessage__c e2aobj: E2AEmailLst){
            ortoo_e2a__EmailMessage__c e2aobjOld = idToE2aObjOld.get ( e2aobj.Id );
            
            if(e2aobj.Academic_Support_Project__c != null ){
                if (e2aobj.Academic_Support_Project__c != e2aobjOld.Academic_Support_Project__c) {
                  e2aobj.ortoo_e2a__Status__c = 'New';
                } 
            }
            if(e2aobj.Book_Project__c != null ){
                if (e2aobj.Book_Project__c != e2aobjOld.Book_Project__c) {
                  e2aobj.ortoo_e2a__Status__c = 'New';
                  system.debug ('>>>>> OnBeforeUpdate >>>>> e2aEmail Id: ' + e2aobj.Id + ', status: ' + e2aobj.ortoo_e2a__Status__c);
                } 
            }
            if(e2aobj.Partner_Agreement__c != null ){
                if (e2aobj.Partner_Agreement__c != e2aobjOld.Partner_Agreement__c) {
                  e2aobj.ortoo_e2a__Status__c = 'New';
                } 
            }
        }
        Logger.pop();
    }
*/
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 29 July 2015
     *@description: Method that handles After update trigger event on the ortoo_e2a__EmailMessage__c object.
     */
    public void OnAfterUpdate(Map<Id,ortoo_e2a__EmailMessage__c> idToE2aObj, Map<Id,ortoo_e2a__EmailMessage__c> idToE2aObjOld){
        
        Logger.push('onAfterInsert','ortoo_e2a__EmailMessage__c');
        
        Set<Id> AspIdSet = new Set<Id>();
        Set<Id> BpIdSet = new Set<Id>();
        Set<Id> PaIdSet = new Set<Id>();
        Set<Id> saIdSet = new Set<Id>();
        Set<Id> AspIdSet1 = new Set<Id>();
        Set<Id> BpIdSet1 = new Set<Id>();
        Set<Id> PaIdSet1 = new Set<Id>();

        List<ortoo_e2a__EmailMessage__c> E2AEmailLst = new List<ortoo_e2a__EmailMessage__c>();
        E2AEmailLst = idToE2aObj.values();
        System.debug('**E2AEmailLst **'+E2AEmailLst );
        //iterate over the list of e2a email 
        for(ortoo_e2a__EmailMessage__c e2aobj: E2AEmailLst){
            
            if(e2aobj.Academic_Support_Project__c != null ){
                
                AspIdSet.add(e2aobj.Academic_Support_Project__c);
            }
            if(e2aobj.Book_Project__c != null ){
                BpIdSet.add(e2aobj.Book_Project__c);
            }
            if(e2aobj.Partner_Agreement__c != null ){
                PaIdSet.add(e2aobj.Partner_Agreement__c);
            }
            if(e2aobj.Social_Action__c != null ){
                saIdSet.add(e2aobj.Social_Action__c);
            }
            if (e2aobj.ortoo_e2a__Incoming__c) {
              if( e2aobj.Academic_Support_Project__c != idToE2aObjOld.get(e2aobj.Id).Academic_Support_Project__c ){
                 if (e2aobj.Academic_Support_Project__c != null) {
                   AspIdSet1.add(e2aobj.Academic_Support_Project__c);
                 }
                 if (idToE2aObjOld.get(e2aobj.Id).Academic_Support_Project__c != null) {
                   AspIdSet1.add(idToE2aObjOld.get(e2aobj.Id).Academic_Support_Project__c);
                 }
              }
              if( e2aobj.Book_Project__c != idToE2aObjOld.get(e2aobj.Id).Book_Project__c ){
                  if (e2aobj.Book_Project__c != null) {
                    BpIdSet1.add(e2aobj.Book_Project__c);
                  }
                  if (idToE2aObjOld.get(e2aobj.Id).Book_Project__c != null) {
                    BpIdSet1.add(idToE2aObjOld.get(e2aobj.Id).Book_Project__c);
                  }
              }
              if( e2aobj.Partner_Agreement__c != idToE2aObjOld.get(e2aobj.Id).Partner_Agreement__c ){
                  if (e2aobj.Partner_Agreement__c != null) {
                    PaIdSet1.add(e2aobj.Partner_Agreement__c);
                  }
                  if (idToE2aObjOld.get(e2aobj.Id).Partner_Agreement__c != null) {
                    PaIdSet1.add(idToE2aObjOld.get(e2aobj.Id).Partner_Agreement__c);
                  }
              }
            }
        }
/**        
        E2AEmailLst = idToE2aObjOld.values();
        System.debug('**E2AEmailLst **'+E2AEmailLst );
        //iterate over the list of e2a email 
        for(ortoo_e2a__EmailMessage__c e2aobj: E2AEmailLst){
            
            if(e2aobj.Academic_Support_Project__c != null && e2aobj.ortoo_e2a__Incoming__c){
                 AspIdSet1.add(e2aobj.Academic_Support_Project__c);
            }
            if(e2aobj.Book_Project__c != null && e2aobj.ortoo_e2a__Incoming__c){
                BpIdSet1.add(e2aobj.Book_Project__c);
            }
            if(e2aobj.Partner_Agreement__c != null && e2aobj.ortoo_e2a__Incoming__c){
                PaIdSet1.add(e2aobj.Partner_Agreement__c);
            }
        }
*/        
        //Check Set is not empty
        if(!AspIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnASP(AspIdSet);
        }
        //Check Set is not empty
        if(!BpIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnBP(BpIdSet);
        }
        //Check Set is not empty
        if(!PaIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnPA(PaIdSet);
        }
        //Check Set is not empty
        if(!saIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnSA(saIdSet);
        }
        if(!AspIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnASP(AspIdSet1);
        }
        //Check Set is not empty
        if(!BpIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnBP(BpIdSet1);
        }
        //Check Set is not empty
        if(!PaIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnPA(PaIdSet1);
        }
        
        Logger.pop();
    
    }
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 29 July 2015, Last Modified: 29 July 2015
     *@description: Method that handles After delete trigger event on the ortoo_e2a__EmailMessage__c object.
     */
    public void onAfterDelete(Map<Id,ortoo_e2a__EmailMessage__c> idToE2aObj){
        
        Logger.push('onAfterInsert','ortoo_e2a__EmailMessage__c');
        
        Set<Id> AspIdSet = new Set<Id>();
        Set<Id> BpIdSet = new Set<Id>();
        Set<Id> PaIdSet = new Set<Id>();
        Set<Id> saIdSet = new Set<Id>();
        Set<Id> AspIdSet1 = new Set<Id>();
        Set<Id> BpIdSet1 = new Set<Id>();
        Set<Id> PaIdSet1 = new Set<Id>();

        List<ortoo_e2a__EmailMessage__c> E2AEmailLst = new List<ortoo_e2a__EmailMessage__c>();
        E2AEmailLst = idToE2aObj.values();
        
        //iterate over the list of e2a email 
        for(ortoo_e2a__EmailMessage__c e2aobj: E2AEmailLst){
            
            if(e2aobj.Academic_Support_Project__c != null ){
                
                AspIdSet.add(e2aobj.Academic_Support_Project__c);
            }
            if(e2aobj.Book_Project__c != null ){
                BpIdSet.add(e2aobj.Book_Project__c);
            }
            
            if(e2aobj.Partner_Agreement__c != null ){
                PaIdSet.add(e2aobj.Partner_Agreement__c);
            }
            if(e2aobj.Social_Action__c != null ){
                saIdSet.add(e2aobj.Social_Action__c);
            }
            if (e2aobj.ortoo_e2a__Incoming__c) {
              if(e2aobj.Academic_Support_Project__c != null){
                   AspIdSet1.add(e2aobj.Academic_Support_Project__c);
              }
              if(e2aobj.Book_Project__c != null){
                  BpIdSet1.add(e2aobj.Book_Project__c);
              }
              if(e2aobj.Partner_Agreement__c != null){
                  PaIdSet1.add(e2aobj.Partner_Agreement__c);
              }
            }
        }
        
        //Check Set is not empty
        if(!AspIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnASP(AspIdSet);
        }
        //Check Set is not empty
        if(!BpIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnBP(BpIdSet);
        }
        //Check Set is not empty
        if(!PaIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnPA(PaIdSet);
        }
        //Check Set is not empty
        if(!saIdSet.IsEmpty()){
            e2aEmailDml.UpdateCountOfE2AEmailOnSA(saIdSet);
        }
        if(!AspIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnASP(AspIdSet1);
        }
        //Check Set is not empty
        if(!BpIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnBP(BpIdSet1);
        }
        //Check Set is not empty
        if(!PaIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnPA(PaIdSet1);
        }
        Logger.pop();
    }
    
    public void onAfterUnDelete(Map<Id,ortoo_e2a__EmailMessage__c> idToE2aObj){
        
        Logger.push('onAfterUnDelete','ortoo_e2a__EmailMessage__c');
        
        Set<Id> AspIdSet1 = new Set<Id>();
        Set<Id> BpIdSet1 = new Set<Id>();
        Set<Id> PaIdSet1 = new Set<Id>();

        List<ortoo_e2a__EmailMessage__c> E2AEmailLst = new List<ortoo_e2a__EmailMessage__c>();
        E2AEmailLst = idToE2aObj.values();
        
        //iterate over the list of e2a email 
        for(ortoo_e2a__EmailMessage__c e2aobj: E2AEmailLst){
            if (e2aobj.ortoo_e2a__Incoming__c) {
              if(e2aobj.Academic_Support_Project__c != null){
                   AspIdSet1.add(e2aobj.Academic_Support_Project__c);
              }
              if(e2aobj.Book_Project__c != null){
                  BpIdSet1.add(e2aobj.Book_Project__c);
              }
              if(e2aobj.Partner_Agreement__c != null){
                  PaIdSet1.add(e2aobj.Partner_Agreement__c);
              }
            }
        }
        
        if(!AspIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnASP(AspIdSet1);
        }
        //Check Set is not empty
        if(!BpIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnBP(BpIdSet1);
        }
        //Check Set is not empty
        if(!PaIdSet1.IsEmpty()){
            e2aEmailDml.UpdateDateTimeOfE2AEmailOnPA(PaIdSet1);
        }
        Logger.pop();
    }
    
}