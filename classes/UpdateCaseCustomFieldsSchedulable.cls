/*
 * @Author: Donna Latte
 * Modification History:
 * @date   3/28/2014 Created
*/

global class UpdateCaseCustomFieldsSchedulable implements Schedulable {
	global void execute(SchedulableContext SC){
        UpdateCaseCustomFields updCaseCustomFields = new UpdateCaseCustomFields();
        database.executeBatch(updCaseCustomFields);
    }
}