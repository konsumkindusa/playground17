global class UpdateCaseCustomFalseSchedulable implements Schedulable {
/*
 * @Author: Donna Latte
 * Modification History:
 * @date   4/11/2014 Created
*/
    global void execute(SchedulableContext SC){
        UpdateCaseCustomFieldsSetFalse updCaseCustomFieldsFalse = new UpdateCaseCustomFieldsSetFalse();
        database.executeBatch(updCaseCustomFieldsFalse);
    }
}