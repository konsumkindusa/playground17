/**
* @author Modified: Faina Gorelik
* @date Modified: 25 June, 2015
* @description: Added additional fields to the soql statements. Fields will be used on  the search result
*/
    
    
    
    
    public without sharing class MassReassignOpportunitiesController {
    public ApexPages.StandardSetController optySetController;
    public String filterId {get;set;}
    public String ErrorMsg {get;set;}
    public String optyQueryString;
    public List<cOpty> optyList {get;set;} 
    public list<Opportunity> optyToUpdateList {get;set;}
    public Opportunity searchRecord {get;set;}
    public Account searchRecordByAccountFields {get;set;}
    

    public Reassign_Helper__c helperRecord{get;set;}
    public boolean isSuccess{get;set;}
    public boolean searchPerformed{get;set;}
    public boolean tooManyResults{get;set;}
    public static List<sobject> sobj = new List<Sobject>();

    public Integer optyListSize {get{return optylist.size();}}

    public MassReassignOpportunitiesController(){
        
        //Descrption:added more fields(Territory_Name__c,CreatedDate,Account.name,Account.site) to query 
        optyQueryString = 'SELECT name,StageName,CloseDate,Territory_Name__c,campaignId,ownerId,CreatedDate,Account.name,Account.site,Salesforce_Opportunity_ID__c,Account_Name_Latin__c,Primary_Purpose__C,Amount from Opportunity where isDeleted=false';
        optyList = new List<cOpty>();
       
        searchRecord = new Opportunity();
        helperRecord = new Reassign_Helper__c();        
        searchRecordByAccountFields=new Account();
        isSuccess=false;
        searchPerformed = false;
        tooManyResults= false;

    }

   
    public void refreshOptyListBySearch(){
        
         Logger.push('refreshOptyListBySearch', 'MassReassignOpportunitiesController');
        
        optyList.clear();
        isSuccess = false;

        //resultList = new List<cResult>();
        String userFilterQuery='';
        if (searchRecord.Name<>null)    userFilterQuery = ' and Name like \'%'+searchRecord.Name+'%\'';
        if (searchRecord.Type<>null)    userFilterQuery += ' and Type = \''+searchRecord.type+'\'';
        if (searchRecord.StageName<>null)   userFilterQuery += ' and StageName = \''+searchRecord.StageName+'\'';
     

        //Modified by:Archana Lohar-cloudsherpas
        //Descrption:added extra fields to search criteria
        if (searchRecordByAccountFields.Territory_name__c<>null)   userFilterQuery += ' and Territory_Name__c like \'%'+searchRecordByAccountFields.Territory_name__c+'%\'';
        if (searchRecord.ownerId<>null)   userFilterQuery += ' and ownerId = \''+searchRecord.ownerId+'\'';
        if (searchRecord.campaignId<>null)   userFilterQuery += ' and campaignId= \''+searchRecord.campaignId+'\'';

        if (searchRecordByAccountFields.name<>null)   userFilterQuery += ' and Account.name  like \'%'+searchRecordByAccountFields.name+'%\'';
        if (searchRecordByAccountFields.site<>null)   userFilterQuery += ' and Account.site  like \'%'+searchRecordByAccountFields.site+'%\'';
    


        if (helperRecord.From__c<>null){
            DateTime startDate = DateTime.newInstance(helperRecord.From__c, Time.newInstance(0, 0, 0, 0));
            userFilterQuery += ' and CreatedDate >= '+startDate.format('yyyy-MM-dd')+'T00:00:00Z';

        }
        if (helperRecord.To__c<>null){
            DateTime endDate = DateTime.newInstance(helperRecord.to__c, Time.newInstance(0, 0, 0, 0));
            //set the created date condition to check till the end of day of enddate
            userFilterQuery += ' and CreatedDate <= '+endDate.format('yyyy-MM-dd')+'T23:59:59Z';

        }
        if (helperRecord.closedDate_From__c<>null){
            DateTime startDate = DateTime.newInstance(helperRecord.closedDate_From__c, Time.newInstance(0, 0, 0, 0));
            userFilterQuery += ' and CloseDate >= '+startDate.format('yyyy-MM-dd');

        }
        if (helperRecord.closedDate_To__c<>null){
            DateTime endDate = DateTime.newInstance(helperRecord.closedDate_to__c, Time.newInstance(0, 0, 0, 0));
            userFilterQuery += ' and CloseDate <= '+endDate.format('yyyy-MM-dd');

        }

        String optyQueryString =optyQueryString +  userFilterQuery ;

        //Modified by:Archana Lohar-cloudsherpas
        //Descrption:added condition to fetch only open opportunities
        optyQueryString += ' and isClosed=false  order by Name limit 1000';

        List<Sobject> sortedResults= new List<SObject>();
        try{
            sortedResults = Database.query(optyQueryString);
            searchPerformed = true;
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        System.debug('Requete => '+optyQueryString);

        for (SObject foundObject:sortedResults){
            Opportunity opty = (Opportunity)foundObject;
            optyList.add(new cOpty(opty));      
        }
        
        Logger.pop(); 
        
    }


    /*===============================================
    Assign the selected opportunities to a new owner
    =================================================*/
    public void Assign(){    
        
         Logger.push('Assign', 'MassReassignOpportunitiesController');
        
        list<Opportunity> optyToUpdateList=new list<Opportunity>();
        list<Task> taskToUpdateList=new list<Task>();
        list<Event> eventToUpdateList = new List<Event>();


        for (cOpty opty:optyList)
            if (opty.selected)
                optyToUpdateList.add(new Opportunity(id=opty.oOpty.id, OwnerId=helperRecord.Assign_to__c));


        //We also need to reassign the open activities to the new owner
        //To do so, we first loop on all the opportunities to retrieve their Open Activities
        //Then we loop through the Task or Events and reassign them

        //Modified by:Archana Lohar-cloudsherpas
        //Description:Added condition to reassign  only old users open actvities/task to new user
        for(Opportunity tempOpty:[select id,ownerId,(select id,ownerId,isTask from OpenActivities order by ActivityDate DESC, LastModifiedDate DESC limit 500) from Opportunity where id in :optyToUpdateList]){

            system.debug(tempOpty.OpenActivities+'tempOptytempOptytempOpty');
            for (OpenActivity tempActivity:tempOpty.OpenActivities){

                if(tempActivity.ownerId==tempOpty.ownerId){

                    if (tempActivity.IsTask) taskToUpdateList.add(new Task(id=tempActivity.id,ownerId=helperRecord.Assign_to__c));
                    else EventToUpdateList.add(new Event(id=tempActivity.id,ownerId=helperRecord.Assign_to__c));
                }
            }
        }

        if (optyToUpdateList.size()+taskToUpdateList.size()+eventToUpdateList.size()>=10000) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.TooManyRowsError));
        } else{

            try
            {
                update optyToUpdateList;
            }
             catch (System.DmlException e) {            
               
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    //Logger.DebugException('Error in replaceAccountAddress:'+e.getMessage());
                    Logger.debugException('Error in replaceAccountAddress:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
            
            try
            {
                if (taskToUpdateList.size()>0) update taskToUpdateList;
                if (eventToUpdateList.size()>0) update eventToUpdateList;
            }
            catch (System.DmlException e) {            
               
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
              for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    //Logger.DebugException('Error in replaceAccountAddress:'+e.getMessage());
                    Logger.debugException('Error in replaceAccountAddress:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                }
            }
            

            // Update the search results
            integer n=optyList.size();
            for (integer i=n-1;i>=0;i--){
                if (optyList[i].selected) optyList.remove(i);
            }

            if (optyToUpdateList.size()>0) isSuccess = true;
            
            Logger.pop(); 
        }       
    }

    /*==================================================
    Inner class helping identify selected opportunities
    ====================================================*/
    public class cOpty{
        
        
        
        public Opportunity oOpty {get;set;}
        public Boolean selected {get;set;}

        public cOpty(Opportunity oOpty){
            this.oOpty = oOpty;
            selected=false;
        }

    }



}