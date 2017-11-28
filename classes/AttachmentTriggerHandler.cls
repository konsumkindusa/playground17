/**
 * @author Original: kishore AN - Cloud Sherpas/Mathworks 
 * @author Modified: 
 * @date Original: 20 MArch 2015, Last Modified:
 * @description Trigger handler class for Attachment
 * @Revision :
 */

public class AttachmentTriggerHandler {
    
    /**
     * @author Original: Kishore AN - Cloud Shepras/Mathworks;Last Modified: kishore AN - Cloudsherpas/Mathworks
     * @date Original: 20 March 2015;last Modified Date: 07 March 2016
     * @description: Method that handles After insert trigger event on the Attachment object.
     * checks if the parent Id on the Attachment is a Task and see if the HAs attachment flag needs to be set on the task.
     * @param List_Attachments - A collection of Attachments that are inserted.
     */
    public void onAfterInsert(List<Attachment> List_Attachments,Map<Id,Attachment> newmap){
        Logger.push('onAfterInsert','AttachmentTriggerHandler');
        
        List<Task> taskList = new List<Task>();
        Set<Id> parentIds = new Set<Id>();

		//HW 2053012 
		Set<Id> setOwnerId = new Set<Id>();
		Set<Id> setId = new Set<Id>();
		//HW 2053012 
        
        //get the parent ids of all the attachments and
        //check if the parentId is of type Task and add it to the set
        for(Attachment att: List_Attachments){            
            if(att.parentId != null &&  UtilityHelper.ObjectTypeOf(att.ParentId) == Task.SObjectType )
                parentIds.add(att.parentId);

			//HW 2053012 
	   		setOwnerId.add(att.ParentId);
	   		setId.add(att.ParentId);
			//HW 2053012 
        }
        
        //query the task object with the parentId
        if(!parentIds.isEmpty()){
            for(Task tsk: [select Id, Has_attachment__c, whatId, Type, status from Task where Id in :parentIds]){
                //check if the task type is email, status  is completed                  
                if(parentIds.contains(tsk.Id) && tsk.Type=='Email' && tsk.Status == 'Completed' ){
                    taskList.add(tsk); 
                }
            }
        }
        
        if(!taskList.isEmpty()){
            AttachmentDML attachDML = new AttachmentDML();
            attachDML.UpdateTaskHasAttachmentFlag(taskList);
        }
        
		//HW 2053012 
		if (! setOwnerId.isEmpty()) {
			for (EmailMessage em : [Select Id, ParentId from EmailMessage where Id IN : setOwnerId limit 10000]) {
				if (em.ParentId != null)
		   	 		setId.add(em.ParentId);
			}
		}
		
		if (! setId.isEmpty()) {
			List<Case> listObjCase = [Select Id from Case where Id IN : setId and isSecured__c = true limit 10000];
		    for(Case objCase : listObjCase)
	          objCase.isSecured__c = false;
		    update(listObjCase);
		}
		//HW 2053012 

        Logger.Pop();
    }
}