/**
 * @author Original: kishore AN - Cloud Sherpas/Mathworks
 * @date Original: 20 March 2015, Last Modified:
 * @description Class to handle delegated DML operations for Attachment object.
 * @Revision :
 */

public class AttachmentDML {

    /**
     * @author Original: Kishore AN - Cloud Sherpas/Mathworks
     * @date Original: 20 MArch 2015, Last Modified: 
     * @description: Method to update the Has email attachment flag on the Task
     *  @param: taskList - List of Tasks that needs to be updated
     */
    public void UpdateTaskHasAttachmentFlag(List<Task> taskList){
        Logger.push('updateTaskHasAttachment','AttachmentDML');
        List<Task> updateTaskList = new  List<Task>();
        //check if the has attachment flag is already true on the task. If it is false then only set the flag and update the task.
        for(Task tsk : taskList){
            if(tsk.Has_Attachment__c == false){
                tsk.Has_Attachment__c = true;
                updateTaskList.add(tsk);
            }
        }
        try{            
            if(!updateTaskList.isEmpty()){
                update updateTaskList;
            }
        }
         catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Capture Dml exception here
                Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }
        Logger.pop();
        
    }
}