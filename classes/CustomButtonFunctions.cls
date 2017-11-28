/**
* @author Original: Robbie Dell Macatbag - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag 
* @date Original: 31 May 2013, Last Modified: 12/20/13 G1030349
* @description class that contains methods of different functionality for custom buttons
*/
global class CustomButtonFunctions{
    
    /**
    * @author Original: Robbie Dell Macatbag - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag
    * @date Original: 31 May 2013, Last Modified: 12/20/13 G1030349
    * @description method that updates Case's Escalate To field to null when Task's Assigned To field is changed
    */ 
    webService static void TakeOwnership(String taskId, String userId) { 
    
        //Identify Task to be updated
        list <Task> taskList = [SELECT id,WhatId,OwnerId,Type FROM Task WHERE id = : taskId];
        
        if (taskList.size() > 0){
            //Set Assigned to value with userId
            taskList[0].OwnerId = userId;
            //Update Task
            update taskList;
        }
        
        //Update Escalate To only when Task's type is Escalation
        if (taskList[0].Type == 'Escalation' && taskList[0].Case_Escalated_To_Value__c != ''){
            //Identify Case to be updated
            list <Case> caseList  = [SELECT id, Escalation_to__c,OwnerId,IsEscalated FROM Case WHERE id = :taskList[0].WhatId];
            
            if (caseList.size() > 0){
                //Set Escalate To value to null
                if (caseList[0].IsEscalated == true){
                    list <Task> taskList2 = [SELECT id,WhatId,OwnerId,Type,Case_Escalated_To_Value__c FROM 
                                                                                Task 
                                                                           WHERE 
                                                                                What.id = : caseList[0].id 
                                                                           And
                                                                                Case_Escalated_To_Value__c !='' 
                                                                           And 
                                                                                Id != :taskList[0].Id
                                                                           And 
                                                                                Type= 'Escalation'      
                                                                           Order By 
                                                                                 LastModifiedDate limit 100];  
                    if(taskList2.size() >0)
                    {
                        caseList[0].Escalation_to__c = taskList2[0].Case_Escalated_To_Value__c;
                    }
                    else
                    {
                        caseList[0].Escalation_to__c = null;
                    }    
                    taskList[0].Case_Escalated_To_Value__c = null; //SS 12/20/13 G1030349
                }
                //Update Case
                update caseList;
                update taskList;

            }
        }
        
    }

    /**
    * @author Original: Marc Ouimet - Mathworks, Last Modified: Marc Ouimet
    * @date Original: 5/6/2014, Last Modified: 5/7/2014 G1017724
    * @description method that updates Case's owner as well as the owner of the Case's unassigned Tasks
    */ 
    webService static void TakeOwnershipCase(String caseId, String userId) { 
    
        //Identify Case to be updated
        list <Case> caseList = [SELECT id,Escalation_to__c,OwnerId,IsEscalated FROM Case WHERE Id = :caseId limit 1];
     Id prevOwner = caseList[0].OwnerId;
        //Take ownership of the Case
        if (caseList.size() > 0){
            //Set Assigned to value with userId
            caseList[0].OwnerId = userId;
        }
    system.debug(caseId + '' + caseList[0].OwnerId );    
        //Identify Task(s) without owners to be updated.  Per Eric DaSilva, we want to avoid taking ownership of esclation tasks.
        // Modified: Jaspreet Added criteria OwnerId= :prevOwner and Status != 'Completed' for UserStory 749714
        list <Task> taskList = [SELECT id,OwnerId,Type FROM Task WHERE WhatId = :caseId and (OwnerId='' OR (OwnerId= :prevOwner and Status != 'Completed'))  and Type<>'Escalation'];
        
            if (taskList.size() > 0){
                for (Task objTask: taskList) {
                    //Set Assigned to value with userId
                    objTask.OwnerId = userId;
                }
            }

        //Update Case and Task
        update caseList;
        update taskList;

    }
}