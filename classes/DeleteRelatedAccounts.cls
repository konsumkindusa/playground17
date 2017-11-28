/**
*@author Original: Faina Gorelik - Mathworks
*@date Original:05/06/2017
*@description: Invocable class that will be called from process builder "Update Project Fields" on event when primary opportunity removed from the Project AtTask 1995293
*/

public class DeleteRelatedAccounts
{
    @InvocableMethod
    
    public static void ProjectAccountDelete(List<Id> ProjectIds)
    {
        List<Account_Project__c> Accounts =[select id from Account_Project__c where Project__c in :ProjectIds];
        if (Accounts.size() >0) {
            delete Accounts;
        }   
    }
}