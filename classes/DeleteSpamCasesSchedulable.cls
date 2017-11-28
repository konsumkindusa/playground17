/*
Author: Robbie Macatbag
*/
global class DeleteSpamCasesSchedulable implements Schedulable{
    global void execute(SchedulableContext SC){
        DeleteSpamCases delSpamCases = new DeleteSpamCases();
        database.executebatch(delSpamCases);
    }
}