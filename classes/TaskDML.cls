/**
* @author Original: Jaspreet - Mathworks, Last Modified: Jaspreet  
* @date Original: 11 May 2015, Last Modified: 20 May 2015
* @description DML operations related to Task Trigger will done in this class.
**/ 

public class TaskDML {

 
/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description Update the tasks on after insert of Task - for attachments
* @param List_Tasks A collection of Tasks
*/
    
public void updateTask(List<Task> listTasks)
{
	update listTasks;
}

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description Update the cases on after insert/update of Task
* @param List_Case A collection of Task and Map_Case map of Id and case
*/
    
public void updateCase(List<Case> updateListCases)
{
 //update updateListTask;
 update updateListCases;
}

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description Update the opportunities
* @param List_Opportunity A collection of opportunties
*/    

public void updateOpportunity(List<Opportunity> listOpportunities)
{
    update listOpportunities;
}

/**
* @author Original: Jaspreet - Mathworks
* @date Original: 11 May 2015
* @description Update the leads
* @param List_Opportunity A collection of lead
*/      

public void updateLead(List<Lead> listLead)
{
       update listLead;
}

}