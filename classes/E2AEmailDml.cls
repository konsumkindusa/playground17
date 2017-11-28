/**
 *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *@date Original: 13 Nov 2015, Last Modified:13 Nov 2015
 *@description:    Class to handle delegated DML operations for E2a Email object. 
 */
public class E2AEmailDml{
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 13 Nov 2015, Last Modified: 13 Nov 2015
     *@description: Method that update the field on Accadamic Support Project
     */
    public void UpdateCountOfE2AEmailOnASP(Set<Id> AspIdSet){
        
        Logger.push('UpdateCountOfE2AEmailOnASP','E2AEmailDml');
        //List to add aggregate Results
        LIST<AggregateResult> e2aEmailList = new LIST<AggregateResult>();
        //Map Academic_Support_Project__c as a key and integer as count of e2a Email which has status as new
        Map<Id,integer> aspToE2aEmailCountMap = new Map<Id,integer> ();
        //List to add Academic_Support_Project__c records
        LIST<Academic_Support_Project__c> aspList = new LIST<Academic_Support_Project__c>();
        //List to add  Academic_Support_Project__c records which has to be updated 
        LIST<Academic_Support_Project__c> aspUpdateList = new LIST<Academic_Support_Project__c>();
        
        // Query the  List of e2a email reocrds which count for Academic_Support_Project__c 
        e2aEmailList = [Select count(Id),Academic_Support_Project__c,ortoo_e2a__Status__c From ortoo_e2a__EmailMessage__c where Academic_Support_Project__c In:AspIdSet and ortoo_e2a__Status__c = 'New' group by Academic_Support_Project__c,ortoo_e2a__Status__c];
        
        
        //iterate over the list of e2A email records
        for(AggregateResult e2aObj: e2aEmailList){
            if(!aspToE2aEmailCountMap.containskey((Id)e2aObj.get('Academic_Support_Project__c'))){
                system.debug('**e2aObjContainsKey**'+e2aObj);
                aspToE2aEmailCountMap.put((Id)e2aObj.get('Academic_Support_Project__c'),(integer)e2aObj.get('expr0'));
            }
        }
        
        
        //query the Academic_Support_Project__c records which has only records avaialble in trigger context
        aspList = [Select Id,Name,E2AEmailCount__c From Academic_Support_Project__c where Id In:AspIdSet];
        
        
        //ietrate over the list of Academic_Support_Project__c records to create a list of Academic_Support_Project__c that needs to be updated 
        for(Academic_Support_Project__c aspObj :aspList){
            //check Academic_Support_Project__c records present in map or not
            if(aspToE2aEmailCountMap.containsKey(aspObj.Id)){
                aspObj.E2AEmailCount__c = aspToE2aEmailCountMap.get(aspObj.Id);
                aspUpdateList.add(aspObj);
            }
            else{
                aspObj.E2AEmailCount__c = 0;
                aspUpdateList.add(aspObj);
            }
            
        }
        
        
        try{
            //update the Academic_Support_Project__c records list for count of e2a Emails
            update aspUpdateList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        Logger.pop();
    
    }
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 13 Nov 2015, Last Modified: 13 Nov 2015
     *@description: Method that update the field on Book Project
     */
    public void UpdateCountOfE2AEmailOnBP(Set<Id> BPIdSet){
        
        Logger.push('UpdateCountOfE2AEmailOnBP','E2AEmailDml');
        //List to add aggregate Results
        LIST<AggregateResult> e2aEmailList = new LIST<AggregateResult>();
        //Map Book_Project__c as a key and integer as count of e2a Email which has status as new
        Map<Id,integer> bpToE2aEmailCountMap = new Map<Id,integer> ();
        //List to add Book_Project__c records
        LIST<Book_Project__c> bpList = new LIST<Book_Project__c>();
        //List to add  Book_Project__c records which has to be updated 
        LIST<Book_Project__c> updatebpList = new LIST<Book_Project__c>();
        
        // Query the  List of e2a email reocrds which count for Book_Project__c 
        e2aEmailList = [Select count(Id),Book_Project__c,ortoo_e2a__Status__c From ortoo_e2a__EmailMessage__c where Book_Project__c In:BPIdSet and ortoo_e2a__Status__c = 'new' group by Book_Project__c,ortoo_e2a__Status__c];
        
        
        //iterate over the list of e2A email records
        for(AggregateResult e2aObj: e2aEmailList){
            if(!bpToE2aEmailCountMap.containskey((Id)e2aObj.get('Book_Project__c'))){
                system.debug('**e2aObjContainsKey**'+e2aObj);
                bpToE2aEmailCountMap.put((Id)e2aObj.get('Book_Project__c'),(integer)e2aObj.get('expr0'));
            }
        }
        
        
        //query the Book_Project__c records which has only records avaialble in trigger context
        bpList = [Select Id,Name,E2AEmailCount__c From Book_Project__c where Id In:BPIdSet];
        
        
        //ietrate over the list of Book_Project__c records to create a list of Book_Project__c that needs to be updated 
        for(Book_Project__c bpObj :bpList){
            //check Book_Project__c records present in map or not
            if(bpToE2aEmailCountMap.containsKey(bpObj.Id)){
                bpObj.E2AEmailCount__c = bpToE2aEmailCountMap.get(bpObj.Id);
                updatebpList.add(bpObj);
            }
            else{
                bpObj.E2AEmailCount__c = 0;
                updatebpList.add(bpObj);
            }
            
        }
        
        try{
            //update the Book_Project__c records list for count of e2a Emails
            update updatebpList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        Logger.pop();
    
    }
    
    /**
     *@author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *@date Original: 13 Nov 2015, Last Modified: 13 Nov 2015
     *@description: Method that update the field on Partner Agreement
     */
    public void UpdateCountOfE2AEmailOnPA(Set<Id> PAIdSet){
        
        Logger.push('UpdateCountOfE2AEmailOnPA','E2AEmailDml');
        //List to add aggregate Results
        LIST<AggregateResult> e2aEmailList = new LIST<AggregateResult>();
        //Map Partner_Agreement__c as a key and integer as count of e2a Email which has status as new
        Map<Id,integer> paToE2aEmailCountMap = new Map<Id,integer> ();
        //List to add Partner_Agreement__c records
        LIST<Partner_Agreement__c> paList = new LIST<Partner_Agreement__c>();
        //List to add  Partner_Agreement__c records which has to be updated 
        LIST<Partner_Agreement__c> updatePaList = new LIST<Partner_Agreement__c>();
        
        // Query the  List of e2a email reocrds which count for Partner_Agreement__c 
        e2aEmailList = [Select count(Id),Partner_Agreement__c,ortoo_e2a__Status__c From ortoo_e2a__EmailMessage__c where Partner_Agreement__c In :PAIdSet and ortoo_e2a__Status__c = 'new' group by Partner_Agreement__c,ortoo_e2a__Status__c];
        
        
        //iterate over the list of e2A email records
        for(AggregateResult e2aObj: e2aEmailList){
            if(!paToE2aEmailCountMap.containskey((Id)e2aObj.get('Partner_Agreement__c'))){
                
                paToE2aEmailCountMap.put((Id)e2aObj.get('Partner_Agreement__c'),(integer)e2aObj.get('expr0'));
            }
        }
        
        
        //query the Partner_Agreement__c records which has only records avaialble in trigger context
        paList = [Select Id,Name,E2AEmailCount__c From Partner_Agreement__c where Id In:PAIdSet];
        
        
        //ietrate over the list of Partner_Agreement__c records to create a list of Partner_Agreement__c that needs to be updated 
        for(Partner_Agreement__c paObj: paList){
            //check Partner_Agreement__c records present in map or not
            if(paToE2aEmailCountMap.containsKey(paObj.Id)){
                paObj.E2AEmailCount__c = paToE2aEmailCountMap.get(paObj.Id);
                updatePaList.add(paObj);
            }
            else{
                paObj.E2AEmailCount__c = 0;
                updatePaList.add(paObj);
            }
        }
        
        try{
            //update the Partner_Agreement__c records list for count of e2a Emails
            update updatePaList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        
        Logger.pop();
    
    }

    public void UpdateDateTimeOfE2AEmailOnASP(Set<Id> AspIdSet){
        
        Logger.push('UpdateDateTimeOfE2AEmailOnASP','E2AEmailDml');
        //List to add Academic_Support_Project__c records
        LIST<Academic_Support_Project__c> aspList = new LIST<Academic_Support_Project__c>();
        //query the Book_Project__c records which has only records avaialble in trigger context
        aspList = [Select Id, (Select createdDate from e2a_Emails__r where ortoo_e2a__Incoming__c = true order by createdDate desc limit 1) From Academic_Support_Project__c where Id In:AspIdSet];

        for(Academic_Support_Project__c bpObj :aspList){
            if (bpObj.e2a_Emails__r.IsEmpty()) {
                bpObj.Receive_Time_of_Last_Email__c = null;
            } else {
                bpObj.Receive_Time_of_Last_Email__c = bpObj.e2a_Emails__r[0].createdDate;
            }
        }
        
        try{
            update aspList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        Logger.pop();
    
    }

    public void UpdateDateTimeOfE2AEmailOnBP(Set<Id> BPIdSet){
        
        Logger.push('UpdateDateTimeOfE2AEmailOnBP','E2AEmailDml');
        //List to add Book_Project__c records
        LIST<Book_Project__c> bpList = new LIST<Book_Project__c>();
        //query the Book_Project__c records which has only records avaialble in trigger context
        bpList = [Select Id, (Select createdDate from e2a_Emails__r where ortoo_e2a__Incoming__c = true order by createdDate desc limit 1) From Book_Project__c where Id In:BPIdSet];

        for(Book_Project__c bpObj :bpList){
            if (bpObj.e2a_Emails__r.IsEmpty()) {
                bpObj.Receive_Time_of_Last_Email__c = null;
            } else {
                bpObj.Receive_Time_of_Last_Email__c = bpObj.e2a_Emails__r[0].createdDate;
            }
        }
        
        try{
            update bpList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        Logger.pop();
    
    }

    public void UpdateDateTimeOfE2AEmailOnPA(Set<Id> PAIdSet){
        
        Logger.push('UpdateDateTimeOfE2AEmailOnPA','E2AEmailDml');
        //List to add Partner_Agreement__c records
        LIST<Partner_Agreement__c> paList = new LIST<Partner_Agreement__c>();
        paList = [Select Id, (Select createdDate from e2a_Emails__r where ortoo_e2a__Incoming__c = true order by createdDate desc limit 1) From Partner_Agreement__c where Id In:PAIdSet];

        for(Partner_Agreement__c bpObj :paList){
            if (bpObj.e2a_Emails__r.IsEmpty()) {
                bpObj.Receive_Time_of_Last_Email__c = null;
            } else {
                bpObj.Receive_Time_of_Last_Email__c = bpObj.e2a_Emails__r[0].createdDate;
            }
        }
        
        try{
            update paList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        Logger.pop();
    
    }
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
     * date Original: 28 March 2016, Last Modified: 28 March 2016
     * description : Method that update the field on Social_Action__c
     ****************************************************************************************/
    public void UpdateCountOfE2AEmailOnSA(Set<Id> saIdSet){
        Logger.push('UpdateCountOfE2AEmailOnSA','E2AEmailDml');
        //List to add aggregate Results
        LIST<AggregateResult> e2aEmailList = new LIST<AggregateResult>();
        //Map Social_Action__c as a key and integer as count of e2a Email which has status as new
        Map<Id,integer> saToE2aEmailCountMap = new Map<Id,integer> ();
        //List to add Social_Action__c records
        LIST<Social_Action__c> saList = new LIST<Social_Action__c>();
        //List to add  Social_Action__c records which has to be updated 
        LIST<Social_Action__c> saUpdateList = new LIST<Social_Action__c>();
        
        // Query the  List of e2a email records which count for Social_Action__c 
        e2aEmailList = [Select count(Id),Social_Action__c,ortoo_e2a__Status__c From ortoo_e2a__EmailMessage__c where Social_Action__c In:saIdSet and ortoo_e2a__Status__c = 'New' group by Social_Action__c,ortoo_e2a__Status__c];
        
         //iterate over the list of e2A email records
        for(AggregateResult e2aObj: e2aEmailList){
            if(!saToE2aEmailCountMap.containskey((Id)e2aObj.get('Social_Action__c'))){
                system.debug('**e2aObjContainsKey**'+e2aObj);
                saToE2aEmailCountMap.put((Id)e2aObj.get('Social_Action__c'),(integer)e2aObj.get('expr0'));
            }
        }
        
        //query the Social_Action__c records which has only records avaialble in trigger context
        saList = [Select Id,Name,E2AEmailCount__c From Social_Action__c where Id In:saIdSet];
        
        //ietrate over the list of Social_Action__c  records to create a list of Social_Action__c that needs to be updated 
        for(Social_Action__c saObj :saList){
            //check Academic_Support_Project__c records present in map or not
            if(saToE2aEmailCountMap.containsKey(saObj.Id)){
                saObj.E2AEmailCount__c = saToE2aEmailCountMap.get(saObj.Id);
                saUpdateList.add(saObj);
            }
            else{
                saObj.E2AEmailCount__c = 0;
                saUpdateList.add(saObj);
            }
            
        }
        
        try{
            //update the Social_Action__c records list for count of e2a Emails
            update saUpdateList;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+ex.getDmlMessage(i)+ 'for ID:'+ex.getDmlId(i));
            }
            Logger.pop();
        }
        
        Logger.pop();
    }

}