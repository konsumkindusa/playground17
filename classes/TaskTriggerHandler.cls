/**
* @author Original: Jaspreet - Mathworks, Last Modified: Jaspreet , Faina, Dennis
* @date Original: 11 May 2015, Last Modified: 20 May 2015, 8 September 2015, 19 November 2015, 2 June 2017
* @description Performs actions on execution of task trigger, last update by Faina AtTask 958520, AtTask 1176560 
**/ 

public class TaskTriggerHandler {


TaskDML objTaskDMLClone = new TaskDML();

 
/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - Update Related To Object Name on Task - will updated parent object's name on task
               - Salesforce lead Id on task - if parent object is lead it will update salesforce lead id of parent lead on task
               - siebel contact Id-  if parent is contact, it update siebel contact id on task - this method is deleted
* @param List_Tasks A collection of Tasks
*/

public void onBeforeInsert(List<Task> listTasks)
{
    Logger.push('onBeforeInsert','TaskTriggerHandler');
    //List<Task> listTasks = newMapTask.values();
    List<Id> listContactIDs = new list<Id>();
    List<Id> listLeadId = new List<Id>();
    List<Id> listOppId = new List<Id>();
    
    for(Task objTask:listTasks)
    {
        
    /* DL: 4/1/2016: 868100 Update Task Closed Date/Time for task type Email, status completed, and closed date time null.
                            Configuration Workflow Rule exists to populate when Task is other than Email.
                            Workflow Rule did not evaluate when Task was created as result of outgoing email which is why
                            we have this logic in the Trigger.  
    */
        if(objTask.Type=='Email' 
           && (objTask.Status == 'Completed' || objTask.Status == 'Sent')
           && objTask.Close_Date_Time__c == null)  //DL:  Purposely do not check for SObjectType, as this same logic applies to Emails from Case, Opportunity, Lead, and Contact
            {
                objTask.Close_Date_Time__c = DateTime.now(); 
            }
   //DL:  End
        
      /* updatedRelatedToObjectName  -  If parent object is not lead or contact then update Related To Object Name field on task with parent object name */
        
        if(objTask.whatId!= null)
            objTask.Related_to_ObjectName__c =  objTask.WhatId.getSObjectType().getDescribe().getLabel();
        else
             objTask.Related_to_ObjectName__c =  '';
        
        /*updateRelatedToObjectWhoName - If Parent object is lead */
        
        if(objTask.whoId!= null)
            objTask.Object_Related_To_Who_Name__c =  objTask.WhoId.getSObjectType().getDescribe().getLabel();
        else
             objTask.Object_Related_To_Who_Name__c =  '';
        
      /* updateLeadIdOnTask - If parent object is Lead then update Salesforce Lead Id field on taks with parent Lead Id */
      if(objTask.whoId != null && objTask.WhoId.getSObjectType().getDescribe().getLabel() == 'Lead')
          objTask.Salesforce_Lead_Id__c= objTask.whoId;
      /* If Task is type of Escalation and parent object is Case then update Case Escalated To Value */
      if(objTask.Type == 'Escalation' && objTask.Escalate_To__c != null
           && objTask.WhatId != null && UtilityHelper.ObjectTypeOf(objTask.whatId)==Case.SObjectType)
        {
            system.debug(objTask.Escalate_To__c);
            objTask.Case_Escalated_To_Value__c = objTask.Escalate_To__c; 
        }
        
        
        //Added by Jaspreet Sept-17-2015 , in order to execute Existing Opportunity AtTask Story# 1061176
      
      if(objTask.WhoId != null && objTask.WhoId.getSObjectType().getDescribe().getLabel() == 'Lead')
      {
          listLeadId.add(objTask.WhoId);      
      }
      
      //Added by Haigang Wu Mar-23-2016 , in order to execute Story# 1403974
      if (objTask.WhatId != null && objTask.WhatId.getSObjectType().getDescribe().getLabel() == 'Opportunity') {
        listOppId.add(objTask.WhatId);
      }
    } 

    //Added by Haigang Wu Mar-23-2016 , in order to execute Story# 1403974
    if (listOppId.size() > 0) {
        Map<Id,Opportunity> mapOpp = new map<Id,Opportunity>([Select Id, Primary_Contact__c from Opportunity where Id In : listOppId limit 10000]);
        
        for(Task objTask:listTasks) {
            if (objTask.WhoId == null) {
                objTask.WhoId= mapOpp.get(objTask.whatId).Primary_Contact__c;
            }
        }
    }


    if(listLeadId.size() > 0)
    {
        Map<Id,Lead> mapLead = new map<Id,Lead>([Select Id, Existing_Opportunity__c from Lead where Id In : listLeadId limit 10000]);
        
        for(Task objTask:listTasks)
        {
         objTask.Existing_Opportunity_Id__c= mapLead.get(objTask.whoId).Existing_Opportunity__c;
        }
                
    }
        
   Logger.pop();
}

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - Update Related To Object Name on Task - will updated parent object's name on task
               - Salesforce lead Id on task - if parent object is lead it will update salesforce lead id of parent lead on task
               - Update Case_Escalated_To_Value__c field
* @param List_Tasks A collection of Tasks
*/    

public void onBeforeUpdate(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask) // add old map
{

    Logger.push('onBeforeUpdate','TaskTriggerHandler');

    List<Task> listTasks = newMapTask.values();
    List<Id> listLeadId = new List<Id>();

    for(Task objTask:listTasks)
    {

        /* updatedRelatedToObjectName  -  If parent object is not lead or contact then update Related To Object Name field on task with parent object name */
         
        if(objTask.whatId!= null)
            objTask.Related_to_ObjectName__c =  objTask.WhatId.getSObjectType().getDescribe().getLabel();
        else
             objTask.Related_to_ObjectName__c =  '';
        
        /*updateRelatedToObjectWhoName - If Parent object is lead */
        
        if(objTask.whoId!= null)
            objTask.Object_Related_To_Who_Name__c =  objTask.WhoId.getSObjectType().getDescribe().getLabel();
        else
             objTask.Object_Related_To_Who_Name__c =  '';
         
            
       /* updateLeadIdOnTask  - If parent object is Lead then update Salesforce Lead Id field on taks with parent Lead Id */
       
        if(objTask.whoId != null && objTask.WhoId.getSObjectType().getDescribe().getLabel() == 'Lead')
            objTask.Salesforce_Lead_Id__c= objTask.whoId;
            
       /* If Task is type of Escalation and parent object is Case then update Case Escalated To Value */
       
        if(objTask.Type == 'Escalation' && objTask.Escalate_To__c <> null
           && objTask.WhatId != null && UtilityHelper.ObjectTypeOf(objTask.whatId)==Case.SObjectType)
      //  objTask.Case_Escalated_To_Value__c = objTask.Escalate_To__c; //SS 12/20/13 G1030349 populating the task field  
        
      /* For mass update Tasks update Status of Tasks */
     
     system.debug(objTask.Updated_Status__c +' ---- '+ objTask.Updated_Priority__c ); 
      
      if(objTask.Updated_Status__c != '--None--' && objTask.Updated_Status__c != null)
      {
       system.debug(objTask.Updated_Status__c +' ---- '+ objTask.Updated_Priority__c );   
        if(oldMapTask != null && oldMapTask.get(objTask.Id).Status  !=  objTask.Updated_Status__c )
        {
             objTask.Status = objTask.Updated_Status__c; 
             //fg AtTask 1176560 
             objTask.Updated_Status__c = null;
        }
      }
          
    
      //Added by Jaspreet Sept-17-2015 , in order to execute Existing Opportunity AtTask Story# 1061176
      
      if(objTask.WhoId != null && objTask.WhoId.getSObjectType().getDescribe().getLabel() == 'Lead' && objTask.Existing_Opportunity_Id__c != null)
      {
          listLeadId.add(objTask.WhoId);      
      }
  
} 

    if(listLeadId.size() > 0)
    {
        Map<Id,Lead> mapLead = new map<Id,Lead>([Select Id, Existing_Opportunity__c from Lead where Id In : listLeadId limit 10000]);
        
        for(Task objTask:listTasks)
        {
         objTask.Existing_Opportunity_Id__c= mapLead.get(objTask.whoId).Existing_Opportunity__c;
        }
                
    }

Logger.pop();

}

/**
* @author Original: Jaspreet - Mathworks;Last Modified: Kishore AN
* @date Original: 11 May 2015;Last Modified Date: 07 March 2016
* @description - will do check for parent object on insert of task and create list object to be updated accordingly
* @param List_Tasks A collection of Tasks
*/


public void onAfterInsert(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask)
{
    Logger.push('onAfterInsert','TaskTriggerHandler');
    system.debug('task onAfterInsert firing');
    
    List<Task> listUpdateTasks = new List<Task>();  // Call task DML method to update Task
    
    Map<Id,Task> mapTaskWithCases = new Map<Id,Task>();
    Map<Id,Task> mapTaskWithOpp = new Map<Id,Task>();
    Map<Id,Task> mapTaskWithLead = new Map<Id,Task>();
    Map<Id,Task> mapTaskForAttatchmnt = new Map<Id,Task>();

 
 

 
    // Update Has Attachment flag only if task type is email and it's completed - for incoming emails.

    

    for(Task objTask:newMapTask.values())
    {
    
       //check if the task is of type email and has status completed and check for attachments to set the has attachments flag
       //DMA 2102029 - Removing this code as it was causing SOQL limit errors and we determined that it will not work correctly anyway
       //            because Attachments are inserted after Tasks, so this trigger will never see them
        // if(objTask.Type=='Email' && objTask.Status == 'Completed'){
       //         mapTaskForAttatchmnt.put(objTask.Id,objTask);
       //     }

        
        if(objTask.whatId != null && UtilityHelper.ObjectTypeOf(objTask.whatId)==Case.SObjectType)
        {       
           mapTaskWithCases.put(objTask.Id,objTask);
        } 
        
        if(objTask.whoId != null && UtilityHelper.ObjectTypeOf(objTask.whoId)==Lead.SObjectType)
        {
            mapTaskWithLead.put(objTask.Id,objTask);
        }  
        
        if(objTask.whatId != null && UtilityHelper.ObjectTypeOf(objTask.whatId)==Opportunity.SObjectType)
        {
         mapTaskWithOpp.put(objTask.Id,objTask);
        }
        
        // If parent object changes from opportunity to another parent object
        if(oldMapTask != null && oldMapTask.get(objTask.Id) != null && oldMapTask.get(objTask.Id).WhatID != null)
        {
            if(UtilityHelper.ObjectTypeOf(oldMapTask.get(objTask.Id).WhatID) == Opportunity.SObjectType) 
            {
                mapTaskWithOpp.put(objTask.Id,objTask);
            }
        } 
        
    }
    
    //DMA 2102029 - Removing this code as it was causing errors and is unnecessary (see first comment above)
    //if(mapTaskForAttatchmnt.size() > 0)
    //    createTaskList(mapTaskForAttatchmnt);
   
    if(mapTaskWithCases.size() > 0)
        createCaseList(mapTaskWithCases,oldMapTask,'Insert');
    if(mapTaskWithLead.size() > 0)
        createLeadList(mapTaskWithLead,oldMapTask,'Insert');
     if(mapTaskWithOpp.size() > 0)
        createOppList(mapTaskWithOpp,oldMapTask,'Insert');
    
    system.debug(newMapTask +  ' -- newMapTask --' + oldMapTask +' oldMapTask ---');
    Logger.Pop(); 
} 

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - will do check for parent object on update of task and create list object to be updated accordingly
* @param List_Tasks A collection of Tasks
*/

public void onAfterUpdate(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask)
{
    Logger.push('onAfterUpdate','TaskTriggerHandler');
    Map<Id,Task> mapTaskWithCases = new Map<Id,Task>();
    Map<Id,Task> mapTaskWithOpp = new Map<Id,Task>();
    Map<Id,Task> mapTaskWithLead = new Map<Id,Task>();

    
    for(Task objTask:newMapTask.values())
    {
        
        if(objTask.whatId != null && UtilityHelper.ObjectTypeOf(objTask.whatId)==Case.SObjectType)
        {       
           mapTaskWithCases.put(objTask.Id,objTask);
        } 
        
        if(objTask.whoId != null && UtilityHelper.ObjectTypeOf(objTask.whoId)==Lead.SObjectType)
        {
            mapTaskWithLead.put(objTask.Id,objTask);
        }  
        
        if(objTask.whatId != null && UtilityHelper.ObjectTypeOf(objTask.whatId)==Opportunity.SObjectType)
        {

         mapTaskWithOpp.put(objTask.Id,objTask);
        }
        
        // If parent object changes from opportunity to another parent object
        if(oldMapTask != null && oldMapTask.get(objTask.Id) != null && oldMapTask.get(objTask.Id).WhatID != null)
        {
            if(UtilityHelper.ObjectTypeOf(oldMapTask.get(objTask.Id).WhatID) == Opportunity.SObjectType) 
            {
                mapTaskWithOpp.put(objTask.Id,objTask);
            }
        } 
        
    }
    
    if(mapTaskWithCases.size() > 0)
        createCaseList(mapTaskWithCases,oldMapTask,'Update');
    if(mapTaskWithLead.size() > 0)
        createLeadList(mapTaskWithLead,oldMapTask,'Update');

     if(mapTaskWithOpp.size() > 0)

        createOppList(mapTaskWithOpp,oldMapTask,'Update');
    
    Logger.pop();
}
    
/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - will do check for parent object on delete of task and create list object to be updated accordingly
* @param List_Tasks A collection of Tasks
*/

public void onAfterDelete(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask)
{
    Logger.push('onAfterDelete','TaskTriggerHandler');
    Map<Id,Task> mapTaskWithOpp = new Map<Id,Task>();
    Map<Id,Task> mapTaskWithLead = new Map<Id,Task>();
    
    if(oldMapTask != null)
    {
        for(Task objTask:oldMapTask.values())
        {
            if(oldMapTask != null && oldMapTask.get(objTask.Id) != null && oldMapTask.get(objTask.Id).WhatID != null)
            {
                if(UtilityHelper.ObjectTypeOf(objTask.WhatID) == Opportunity.SObjectType) 
                {
                    mapTaskWithOpp.put(objTask.Id,objTask);
                }
            }    
        }
        
        for(Task objTask:oldMapTask.values())
        {
            if(oldMapTask != null && oldMapTask.get(objTask.Id) != null && oldMapTask.get(objTask.Id).WhoID != null)
            {
                if(UtilityHelper.ObjectTypeOf(objTask.WhoID) == Lead.SObjectType) 
                {
                    mapTaskWithLead.put(objTask.Id,objTask);
                }
            }    
        }
        
    } 
    
    if(mapTaskWithOpp.size() > 0)
        createOppList(mapTaskWithOpp,oldMapTask,'delete');
    if(mapTaskWithLead.size() > 0)
        createLeadList(mapTaskWithLead,oldMapTask,'delete');

    Logger.pop();
}


/**
    *** DMA 2102029 - Removing this code as it was causing errors and is unnecessary (see first comment above)


* @author Original: Jaspreet - Mathworks;Last Modified: Kishore AN
* @date Original: 11 May 2015;Last Modified Date: 07 March 2016
* @description - Creats list of tasks to be updated
* @param List_Tasks A collection of Tasks

    
    
public void createTaskList(Map<Id,Task> newMapTask)
{
    // task has attachment - task have attachments then mark Has Attachments fields true
    Logger.push('createTaskList','TaskTriggerHandler');
    List<Task> updateListTasks = new List<Task>();
    
    List<Task> tskList = newMapTask.values();
    
    Set<Id> taskSet = new Set<Id>();
       
    for(Task objTask:tskList)
    {
        if(objTask.Type=='Email' && objTask.Status == 'Completed')   
           {
                taskSet.add(objTask.Id);
           }
    
    }
    
    // Confirm- Requery tasks to confirm attachments are attached to task
        
    Map<Id,Task> mapTask = new Map<Id,Task>([Select Id,Has_Attachment__c from Task where ID in: taskSet limit 10000 ]);
    
    List<Attachment> listAttachments=[select id,ParentId from Attachment where ParentId in:taskSet limit 10000 ];
    
    Map<Id,Attachment> ParentIdAttachment = new Map<Id,Attachment>();
    
    for(Attachment attachObj: listAttachments){
     
       ParentIdAttachment.put(attachObj.ParentId,attachObj);

    }   
   
    for(Task tsk: mapTask.values()){
            
     if(ParentIdAttachment.get(tsk.Id) != null){
        tsk.Has_Attachment__c=true; 
        updateListTasks.add(tsk); 
    }
   }     
    objTaskDMLClone.updateTask(updateListTasks);
    Logger.pop();
}
*/
    

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - Creats list of Cases to be updated
               - Functionality to update Case Sub_Status to Waiting for internal has been moved to workflow rules
                 (Update Category for escalated emails and Update Case Sub Status for escalated emails)
* @param mapNewTask a mapped collection of Id and Task
*/
public void createCaseList(Map < Id, Task > mapNewTask, Map < Id, Task > oldmap, String dmlEvent) {

 Logger.push('createCaseList', 'TaskTriggerHandler');
     //Collection of Case ids which will be used for getting the Cases to be updated
     set < Id > setOfCaseID = new set < Id > ();
     set < Id > listIdCasesForEscalateTo = new set < Id > ();
     set < Id > listIdCasesForCallOutbound = new set < Id > ();
     set < id > listIdTaskForEscalateTo = new set < Id > ();
     set < Id > listIdTaskForCallOutbound = new set < Id > ();
     list < Task > listTask = new List < Task > ();

    //Get all Case Ids From Tasks
     for (Task objTask: mapNewTask.values()) { // Instead of querying add a condition here
       system.debug(objTask.Type + '' + objTask.Escalate_To__c + '' + oldmap);
      // UpdateEscalateTo - method update on Case
    if (objTask.Type == 'Escalation' && objTask.Escalate_To__c != null) {
        if (dmlEvent == 'update') // For update
        {
            if ((oldmap.get(objTask.Id).Type != objTask.Type) || (oldmap.get(objTask.Id).Escalate_To__c != objTask.Escalate_To__c)) {
                 listIdCasesForEscalateTo.add(objTask.WhatId);
                 listIdTaskForEscalateTo.add(objTask.Id);
                }
        } else // For insert
        {   
            listIdCasesForEscalateTo.add(objTask.WhatId);
            listIdTaskForEscalateTo.add(objTask.Id);
        }
    }

     // setActivityDates - 
     else if (objTask.Type == 'Call - Outbound' && objTask.status == 'Completed') {
       system.debug(listIdTaskForCallOutbound + ' ----listIdTaskForCallOutbound----');
        if (dmlEvent == 'update') // For update check if values have changed
       {
        if ((oldmap.get(objTask.Id).Type != objTask.Type) || (oldmap.get(objTask.Id).status != objTask.status)) {
         listIdCasesForCallOutbound.add(objTask.WhatId);
         listIdTaskForCallOutbound.add(objTask.Id);
        }
       } else {
            listIdCasesForCallOutbound.add(objTask.WhatId); // seprate set of values
            listIdTaskForCallOutbound.add(objTask.Id);
           }
          }
          listTask.add(objTask);
    } // if for object type verification ends

    setofCaseID.addAll(listIdCasesForEscalateTo);
    setofCaseID.addAll(listIdCasesForCallOutbound);
    system.debug(listIdTaskForCallOutbound + ' ----listIdTaskForCallOutbound----');
    //Identify Case records to be updated - 
    map < Id, Case > CaseMap = new map < Id, Case > ([Select Id, Escalation_to__c, IsEscalated, CaseNumber, First_Contact_Date__c, Last_Activity_Date__c, Status, SubStatus__c From Case Where id in : setofCaseID limit 10000]); // Query will be one
    List < Case > updateListCases = new List < Case > ();
    List < ID > listTaskIDs = new List < ID > ();
    // Set Case Escalate To field equal to Task's Escalate To field value

    for (Task task: listTask) {
    if (CaseMap.containskey(task.WhatId)) {
    //UpdateEscalateTo - method update on Case
      if (listIdTaskForEscalateTo.contains(task.Id)) {
        system.debug(CaseMap.get(task.WhatId).Escalation_To__c + ' ---- ' + task.Escalate_To__c);
        CaseMap.get(task.WhatId).Escalation_To__c = task.Escalate_To__c;
        //Changes for additional field updates
        CaseMap.get(task.WhatId).Status = 'Open';
        CaseMap.get(task.WhatId).SubStatus__c = 'Waiting for Internal';
        system.debug(CaseMap.get(task.WhatId).Escalation_To__c + ' ---- ' + task.Escalate_To__c);
         }
           
         // SetActivities - reverfy to avoid other recors to be updated with these fields                
         if (listIdTaskForCallOutbound.contains(task.Id)) {
            if (CaseMap.get(task.WhatId).First_Contact_Date__c != null) {
             CaseMap.get(task.WhatId).Last_Activity_Date__c = DateTime.now();
            } else {
             CaseMap.get(task.WhatId).First_Contact_Date__c = DateTime.now();
             CaseMap.get(task.WhatId).Last_Activity_Date__c = DateTime.now();
            }
           }
          }
         }
         //Update Case records

         if (CaseMap.size() > 0) {
          updateListCases.add(CaseMap.Values());
         }
         objTaskDMLClone.updateCase(updateListCases);
         Logger.pop();

        }
/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - Creats list of lead to be updated
* @param mapNewTask a mapped collection of Id and Task
*/

public void createLeadList(Map<Id,Task> mapNewTask,Map<Id,Task> mapOldTask, String dmlEvent)
{
    Logger.push('createLeadList', 'TaskTriggerHandler');
    List<Lead> updateListLead = new List<Lead>();
    //List<Task> listTask = new List<Task>();
    Map<Id, Integer> emailCountMap = new Map<Id, Integer>();
    Map<Id, Integer> callCountMap = new Map<Id, Integer>();
    
    Set<Id> listIdLead = new Set<Id>();
    
    for(Task objTask: mapNewTask.values())
    {
      if ((objTask.Type == 'Email' ||  objTask.Type == 'Call - Outbound') && (objTask.Status == 'Completed' || objTask.Status == 'Sent'))
      {
        if(dmlEvent == 'update') // on update
        {

         // If task or status have changed, comparision with old values
       
         if(mapOldTask.get(objTask.Id).Type != objTask.Type ||
            mapOldTask.get(objTask.Id).Status != objTask.Status || (mapOldTask.get(objTask.Id).Type == objTask.Type && mapOldTask.get(objTask.Id).Status == objTask.Status && mapOldTask.get(objTask.Id).WhatId == null)) 
            {    
              listIdLead.add(objTask.WhoId);  
            }    
        }  
       else if(dmlEvent == 'insert')
       {
         listIdLead.add(objTask.WhoId);  
       }
      }    
    }
    
    if(dmlEvent == 'delete'){ // on delete new map will be null
        for(Task objTask: mapOldTask.values()) // iterate through old map
        {
          if ((objTask.Type == 'Email' ||  objTask.Type == 'Call - Outbound') && (objTask.Status == 'Completed' || objTask.Status == 'Sent'))
          {
            listIdLead.add(objTask.WhoId);
          }    
        }
    }
 
    if(listIdLead.size() > 0)
    {
     List<aggregateResult> tskresultsEmail = [select count(id),type, whoid from Task where whoid in:listIdLead and (Status='Completed' or Status='Sent') group by whoid,type];   
     for (AggregateResult ar : tskresultsEmail )
     {
      if(ar.get('type') == 'Email')
      {
         emailCountMap.put((Id)ar.get('whoid'), (Integer)ar.get('expr0'));
      }
      else if (ar.get('type')  == 'Call - Outbound')
      {
         callCountMap.put((Id)ar.get('whoid'), (Integer)ar.get('expr0'));
      }        
         
     }
    }    
    
    List<Lead> leadList = [SELECT Id, Email_Attempts__c, Call_Attempts__c FROM Lead WHERE Id in: listIdLead];
    
    for(Lead objLead : leadList){
        if(!emailCountMap.isEmpty()){
            objLead.Email_Attempts__c = emailCountMap.get(objLead.Id);
        } else {
            objLead.Email_Attempts__c = 0;
        }
        
        if(!callCountMap.isEmpty()){
            objLead.Call_Attempts__c = callCountMap.get(objLead.Id);
        } else {
            objLead.Call_Attempts__c = 0;
        }   
     }
    
    objTaskDMLClone.updateLead(leadList);
    Logger.pop();
}        

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description - Creats list of opp to be updated
* @param mapNewTask a mapped collection of Id and Task
*/
    
public void createOppList(Map<Id,Task> mapNewTask,Map<Id,Task> mapOldTask, String dmlEvent)
{
    logger.push('createOppList', 'TaskTriggerHandler');
    List<Opportunity> updateListOpportunity = new List<Opportunity>();
    
    // For Update Email Attempts and Outbound  Attempts
    
    Map<Id, Integer> emailCountMap = new Map<Id, Integer>();
    Map<Id, Integer> callCountMap = new Map<Id, Integer>();
    
    // For NADD
    
    List<Id> listOwnerId = new List<Id>(); // will keep the list of owner IDs of tasks
    List<Id> listTaskId = new List<Id>();  // will keep ids of task getting updated or inserted 
    List<Id> listOpportunityId = new List<Id>(); // will keep the opportunity ids
    List<Task> listThisTask = new List<Task>(); // temp list of tasks to collect tasks related to opportunity
    Schema.SObjectType newParentSObj; // will have obj type of trigger.new values
    Schema.SObjectType oldParentSObj;  // will have obj type of trigger.old values 
    
    // For FACD 
    Boolean isRelatedtoLead = false; 
    List<Task> listCompletedTasks = new List<Task>();
    Map<Id,Datetime> mapOppIdTaskModifiedDate = new Map<Id,Datetime>();
    Map<Id,Id> mapTaskIDOwnerID = new Map<ID,Id>();
    
    List<Id> listIdOpp = new List<Id>();
    
    //Check if current record is meets the criteria to update NADD on opportunity if yes then add to list
    
    set<Task> setTaskIteration = new set<Task>();
    
    if(dmlEvent =='delete') // on delete add values from old map
    {
        setTaskIteration.addall(mapOldTask.values());        
    }
    else //on insert and update add values from new map
    {
        setTaskIteration.addall(mapNewTask.values());        
    }     
    
    for(Task objeTask : setTaskIteration) 
        {     
            Datetime oldActivityDueDate; 
            if(String.valueOf(objeTask.WhatId) != null){
                newParentSObj=UtilityHelper.ObjectTypeOf(objeTask.WhatId);
                
                // On Insert if activity date isn't null
                if(dmlEvent =='insert' && newParentSObj == Opportunity.sObjectType) 
                { 
                    if(objeTask.ActivityDate != null)
                    {
                        listThisTask.add(objeTask); // add task to list if parent object is or was opportunity 
                        listOpportunityId.add(objeTask.WhatId); // add opportunity to opportunity Id list this list will be used in Query
                    }
                    
                    // list of opportunities should be updated for call and email outbound attempts
                    if ((objeTask.Type == 'Email' ||  objeTask.Type == 'Call - Outbound') 
                        && (objeTask.Status == 'Completed' || objeTask.Status == 'Sent'))
                    {
                        listIdOpp.add(objeTask.WhatId);
                    }
                      
                } 
                // on update
                // If parent is or was opportunity and Activity due date is changed
                else if(dmlEvent =='update') 
                
                {   
                
                    if(mapOldTask.get(objeTask.Id) != null && mapOldTask.get(objeTask.Id).WhatId !=null) 
                   
                    {
                         // find object type of previous parent of task
                         oldParentSObj =  UtilityHelper.ObjectTypeOf(mapOldTask.get(objeTask.Id).WhatId); 
                         // if new object is not opp and old was opp doesn't matter Activity date have changed or not it should be recalculated
                         if(oldParentSObj  == Opportunity.sObjectType && newParentSObj != Opportunity.sObjectType) 
                            {
                             listThisTask.add(objeTask);
                             listOpportunityId.add(mapOldTask.get(objeTask.Id).WhatId);
                            }
                    }
                   
                    // if parent is opp then verify if Activity Date, Owner and Status values have changed or not
                    if(newParentSObj==Opportunity.sObjectType && dmlEvent =='update') 
                    {
                        if((mapOldTask.get(objeTask.Id).ActivityDate != objeTask.ActivityDate) ||
                           (mapOldTask.get(objeTask.Id).Status != objeTask.Status) ||
                           (mapOldTask.get(objeTask.Id).OwnerId != objeTask.OwnerId))
                           {
                            listThisTask.add(objeTask);
                            listOpportunityId.add(mapOldTask.get(objeTask.Id).WhatId);
                           }
                        
                        // list of opportunities should be updated for call and email outbound attempts
                      
                        if ((objeTask.Type == 'Email' && mapOldTask.get(objeTask.Id).Type != 'Email')
                            ||(objeTask.Type == 'Call - Outbound' && mapOldTask.get(objeTask.Id).Type !='Call - Outbound') 
                            ||(objeTask.Status == 'Completed' && mapOldTask.get(objeTask.Id).Status != 'Completed')
                            ||(objeTask.Status == 'Sent' && mapOldTask.get(objeTask.Id).Status != 'Sent')
                            ||(objeTask.Type == 'Email'  && objeTask.Status == 'Completed'&& (mapOldTask.get(objeTask.Id).Type =='Email' && mapOldTask.get(objeTask.Id).Status == 'Completed' && mapOldTask.get(objeTask.Id).WhatId == null)))
                            
                            {
                            
                                listIdOpp.add(objeTask.WhatId);
                                system.debug(listIdOpp + ' --listIdOpp');
                            } 
                        
                    }
                    
                    
                   
                }
                else if(dmlEvent =='delete')
                {
                    
                    listThisTask.add(objeTask);
                    listOpportunityId.add(mapOldTask.get(objeTask.Id).WhatId);
                }
                
               
          
                // Check old parent of task to update first activity completed date
                if(objeTask.status == 'Completed') //if task is completed and related to opportunity
                {
                    system.debug('mapOldTask' + mapOldTask);
                    // To avoid populating First Activity Date during lead conversion
                    if(!mapOldTask.isEmpty() &&  null != mapOldTask.get(objeTask.id).WhoId) // Check If task is related to contact or lead
                    {
                        Schema.SObjectType sObjLeadCont = UtilityHelper.ObjectTypeOf(mapOldTask.get(objeTask.id).WhoId);   
                        if(Lead.sObjectType == sObjLeadCont) //If task is not related to lead 
                        {
                            isRelatedtoLead = true; // make isRelatedtoLead true
                        }    
                    }
               // if - a new task is created with status = completed && is related to opportunity and contact   
          system.debug(mapOldTask +'--- '+ isRelatedtoLead);
                    
                   if(mapOldTask.isEmpty() || (!mapOldTask.isEmpty() && !isRelatedtoLead))
                   {  
                       listCompletedTasks.add(objeTask); 
                       mapTaskIDOwnerID.put(objeTask.WhatId,objeTask.OwnerId);
                       //If tasks related to same or different opps are getting completed in bulk 
                       if(mapOppIdTaskModifiedDate.size() > 0 &&  objeTask.LastModifiedDate < mapOppIdTaskModifiedDate.get(objeTask.WhatId))
                       {
                           mapOppIdTaskModifiedDate.put(objeTask.WhatId,objeTask.LastModifiedDate);
                       }   
                       else if(mapOppIdTaskModifiedDate.size() == 0)
                       {
                           mapOppIdTaskModifiedDate.put(objeTask.WhatId,objeTask.LastModifiedDate);
                       } 
                     }
                    }
                }
                // If task had opportunity as parent but now it does not have any parent
                else if(objeTask.WhatId == null) 
                {
                 if(dmlEvent =='update'
                    && !mapOldTask.isEmpty()
                    && mapOldTask.get(objeTask.id) != null 
                    && mapOldTask.get(objeTask.id).whatId != null 
                    && UtilityHelper.ObjectTypeOf(mapOldTask.get(objeTask.id).whatId) == Opportunity.sObjectType)
                    {
                        listOpportunityId.add(mapOldTask.get(objeTask.Id).WhatId);                        
                    }    
                        
                }  
              
      }    // For ends    
system.debug('mapOppIdTaskModifiedDate' + mapOppIdTaskModifiedDate);
// Calculations 
    
    // Create Map of Email and Call Outbound attempts
    if(listIdOpp.size() > 0)
    {
 
     List<aggregateResult> tskresultsEmail = [select count(id),type, whatid from Task where whatId in:listIdOpp and (Status='Completed' or Status='Sent') group by whatid,type];   
     for (AggregateResult ar : tskresultsEmail )
     {
      
      if(ar.get('type') == 'Email')
      {
         emailCountMap.put((Id)ar.get('whatid'), (Integer)ar.get('expr0'));
      }
      
      else if (ar.get('type')  == 'Call - Outbound')
      {
         callCountMap.put((Id)ar.get('whatid'), (Integer)ar.get('expr0'));
      }        
     }
    }    
   
    List<Id> listOppIDs = new List<Id>();
    listOppIDs.addAll(listIdOpp); // email or call attempts
    listOppIDs.addAll(listOpportunityId); // for NDD
    listOppIDs.addAll(mapOppIdTaskModifiedDate.keySet()); // for FACD

    
    Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, Email_Attempts__c, Call_Attempts__c,First_activity_completed_date__c,Primary_Purpose__c,OwnerId,Next_Activity_Due_Date__c FROM Opportunity WHERE Id in: listOppIDs limit 10000]);
    // Query tasks related to the opportunity but not the task just updated or inserted because if it is inserted it will not be queried because it is not commited yet 
    //and if it is updated it will not have new values 
    //Couldn't use aggregate function because ActivityDate doesn't support aggergate operator Min, Max
    List<Task> listTask = [Select WhoId, WhatId, ActivityDate,OwnerId,Status From Task where WhatiD IN:listOppIDs and Status != 'Completed' and Status != 'Sent'  and ID NOT IN:listTaskId limit 50000];
    //List<aggregateResult> tskresults = [select Max(ActivityDate),type, whoid from Task where WhatiD IN:listOpportunityId and Status != 'Completed' and ID NOT IN:listTaskId group by whoid,type];      
    
    if(dmlEvent =='insert' || dmlEvent =='update')
    {
        listTask.addAll(listThisTask); // this list have silbling tasks of updated/inserted task and task itself 
    }
    
    Map<Id,Date>  mapOppIDTask = new Map<Id,Date>(); // Map of Oppurtunity Id and next due date 

    // On insert compare Task Activity Date with NADD on opportunity 
            
    if(dmlEvent =='insert')
    {
        for(Task objecTask : mapNewTask.values()) // iterate through records which just got updated
        {
            
            if(objecTask.Status != 'Completed' && objecTask.Status != 'Sent'  && mapOpp.get(objecTask.WhatId) != null)
              {
                if(mapOpp.get(objecTask.WhatId).OwnerID == objecTask.OwnerID)
                {
                 
                 if(mapOpp.get(objecTask.WhatId).Next_Activity_Due_Date__c == null
                    || mapOpp.get(objecTask.WhatId).Next_Activity_Due_Date__c > objecTask.ActivityDate)
                 {
                    mapOppIdTask.put(objecTask.WhatId,objecTask.ActivityDate);  
                 }
                 else
                 {
                    mapOppIdTask.put(objecTask.WhatId,mapOpp.get(objecTask.WhatId).Next_Activity_Due_Date__c);    
                 }
                    
                } 
                else
                 {
                    mapOppIdTask.put(objecTask.WhatId,mapOpp.get(objecTask.WhatId).Next_Activity_Due_Date__c);    
                 }  
             }  
            // To retain old next activity due date when an email is send or completed activity is inserted
            else if(mapOpp.get(objecTask.WhatId) != null)
                 {
                     mapOppIdTask.put(objecTask.WhatId,mapOpp.get(objecTask.WhatId).Next_Activity_Due_Date__c);    
                 } 
      }      
   }    
  
   else if (dmlEvent =='update')
      { // On update and Delete NADD
      for(Task objectTask : listTask) // iterate through records which just got updated
      {
        // If task current status is not completed & Sent and task owner is same as opportunity owner
         if(objectTask.Status != 'Completed' && objectTask.Status != 'Sent'  && mapOpp.get(objectTask.WhatId) != null 
         && mapOpp.get(objectTask.WhatId).OwnerID == objectTask.OwnerID) // Checking if owner of task is same as owner of opportunity
         {
          // if map is null or map doesn't have values related to the opportunity then put first value
          if(mapOppIdTask.get(objectTask.WhatId) == null)
          {
              mapOppIdTask.put(objectTask.WhatId,objectTask.ActivityDate);  
          }
          // if map have any values the do comparision of new values and old values
          else  
          {
            if(mapOppIdTask.get(objectTask.WhatId) > objectTask.ActivityDate)
            {
                mapOppIdTask.put(objectTask.WhatId,objectTask.ActivityDate); 
 system.debug('Debug - Jaspreet' + objectTask);           }
          }
         }
          
        // if current status is completed
        // if owner is changed or mapOppIdTask does not have value related to opp then pass null value to clear NADD on opp

          if(((objectTask.Status == 'Completed')
              || ((objectTask.WhatId != null && UtilityHelper.ObjectTypeOf(objectTask.WhatId) == Opportunity.sObjectType)
                  && mapOpp.get(objectTask.WhatId) != null    
                  && mapOpp.get(objectTask.WhatId).OwnerID != objectTask.OwnerID))
             && (mapOppIdTask.size()==0 || (mapOppIdTask.size()>0 
                                            && mapOppIdTask.containsKey(objectTask.WhatId) == False)))
              {
                  mapOppIdTask.put(objectTask.WhatId,null);
              }
          
      
       // if parent object is changed on task then pass null value for the particular task
          if((mapOldTask != null 
              && mapOldTask.get(objectTask.Id) != null 
              && mapOldTask.get(objectTask.Id).WhatId !=null 
              && UtilityHelper.ObjectTypeOf(mapOldTask.get(objectTask.Id).WhatId) == Opportunity.sObjectType
              && UtilityHelper.ObjectTypeOf(objectTask.WhatId) != Opportunity.sObjectType ) 
              && (mapOppIdTask.size()==0 || (mapOppIdTask.size()>0 
              && mapOppIdTask.containsKey(mapOldTask.get(objectTask.Id).WhatId) == False)))
              {
                mapOppIdTask.put(mapOldTask.get(objectTask.Id).WhatId,null);
              }   
        } // For ends
   }
   else if(dmlEvent =='delete') 
   {
       if(listTask.size() >0)
       {
           for(Task objectTask : listTask) // iterate through records which just got updated
            {
            // If task current status is not completed and task owner is same as opportunity owner
             if(objectTask.Status != 'Completed' && objectTask.Status != 'Sent'  && mapOpp.get(objectTask.WhatId) != null 
             && mapOpp.get(objectTask.WhatId).OwnerID == objectTask.OwnerID) // Checking if owner of task is same as owner of opportunity
             {
              // if map is null or map doesn't have values related to the opportunity then put first value
              if(mapOppIdTask.get(objectTask.WhatId) == null)
              {
                  mapOppIdTask.put(objectTask.WhatId,objectTask.ActivityDate);  
              }
              // if map have any values the do comparision of new values and old values
              else  
              {
                if(mapOppIdTask.get(objectTask.WhatId) > objectTask.ActivityDate)
                {
                    mapOppIdTask.put(objectTask.WhatId,objectTask.ActivityDate); 
                }
              }
             }
            }
      }
      else if(listTask.size() == 0)
      {
          for(Task objectTask : listThisTask) 
          {
             mapOppIdTask.put(objectTask.WhatId,null);
          }
          
      }
   }  
    
    
       Map<Id,Opportunity> newMapOpp = new Map<Id,Opportunity>();
       
       set<opportunity>  setUpdateOpport = new set<Opportunity>();
       system.debug(mapOpp.values() + '--mapOpp--' + mapOppIdTaskModifiedDate);
       for(Opportunity tempOpportunity : mapOpp.values()) 
       {
           // Assignment for first activity completed date
           if((mapOppIdTaskModifiedDate.get(tempOpportunity.Id) != null && tempOpportunity.First_activity_completed_date__c == null)
           && (tempOpportunity.OwnerId ==mapTaskIDOwnerID.get(tempOpportunity.ID))           )
           {
              tempOpportunity.First_activity_completed_date__c = mapOppIdTaskModifiedDate.get(tempOpportunity.Id);
           }
            
          // Assignment for Next Activity Due date
          // Can't add null check for this because map may contain null values for completed tasks or whose parents have changed
           system.debug('mapOppIdTask' + mapOppIdTask.get(tempOpportunity.id));
           tempOpportunity.Next_Activity_Due_Date__c = mapOppIdTask.get(tempOpportunity.id); 
          
          // Assignment for Email Attempts 
         if(listIdOpp.size()>0)
         {
             
             if(!emailCountMap.isEmpty() && emailCountMap.get(tempOpportunity.Id) != null){
             system.debug('tempOpportunity.Email_Attempts__c' + tempOpportunity.Email_Attempts__c + ' emailCountMap.get(tempOpportunity.Id)' + emailCountMap.get(tempOpportunity.Id));
                tempOpportunity.Email_Attempts__c = emailCountMap.get(tempOpportunity.Id);
              } else {
                tempOpportunity.Email_Attempts__c = 0; 
              }
            
            
             // Assignment for call Attempts
             if(!callCountMap.isEmpty() && callCountMap.get(tempOpportunity.Id) != null){
                tempOpportunity.Call_Attempts__c = callCountMap.get(tempOpportunity.Id);
             } else {
                tempOpportunity.Call_Attempts__c = 0; 
             }
         }    
        system.debug('tempOpportunity.Email_Attempts__c' + tempOpportunity.Email_Attempts__c + ' emailCountMap.get(tempOpportunity.Id)' + emailCountMap.get(tempOpportunity.Id));
        setUpdateOpport.add(tempOpportunity);  
        }
        updateListOpportunity.addall(setUpdateOpport);
        objTaskDMLClone.updateOpportunity(updateListOpportunity);
        logger.pop(); 
}
}