/**
 * @author Original: Faina Gorelik - Mathworks 
 * @author Modified: 
 * @date Original: 26 September 2016, Last Modified:
 * @description Trigger handler class for File
 * @Revision :
 */

public class ContentDocumentLinkTriggerHandler {
    
    public void onAfterInsert(List<ContentDocumentLink> List_ContentDocumentLink,Map<Id,ContentDocumentLink> newmap){
        Logger.push('onAfterInsert','ContentDocumentLinkTriggerHandler');
        List<Task> taskList = new List<Task>();
       Set<Id> LinkedEntityIds = new Set<Id>();
        //get the parent - LinkedEntityId of all the files and
        //check if the LinkedEntityId is of type Task and add it to the set
        for(ContentDocumentLink contdoclink: List_ContentDocumentLink){            
            if (contdoclink.LinkedEntityId != null && UtilityHelper.ObjectTypeOf(contdoclink.LinkedEntityId) == Task.SobjectType){
               LinkedEntityIds.add(contdoclink.LinkedEntityId);
            }
        }
        
         if(!LinkedEntityIds.isEmpty()){
            for(Task tsk: [select Id, Has_attachment__c, whatId, Type, status from Task where Id in :LinkedEntityIds]){
                //check if the task type is email, status  is completed                  
                if(LinkedEntityIds.contains(tsk.Id) && tsk.Type=='Email' && tsk.Status == 'Completed' ){
                    taskList.add(tsk); 
                }
            }
        }

        if(!taskList.isEmpty()){
            // ContentDocumentLinkDML contdoclinkDML = new ContentDocumentLinkDML();
            // contdoclinkDML.UpdateTaskHasAttachmentFlag(taskList);
            AttachmentDML attachDML = new AttachmentDML();
            attachDML.UpdateTaskHasAttachmentFlag(taskList);
        }
        Logger.Pop();        
    }
 
}