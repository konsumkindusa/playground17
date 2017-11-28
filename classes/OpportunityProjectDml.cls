/**
*author Original: Sagar Talele - Cloud Sherpas/Mathworks
*date Original: 1 April 2015, Last Modified:
*description : This  is class to handle the DML operations for 'OpportunityProjectTrigger'.. 
*revision:
*/
public class OpportunityProjectDml {
/**
*author Original: Sagar Talele - Cloud Sherpas/Mathworks
*date Original: 1 April 2015, Last Modified:
*description : This  is class to handle the DML operations for 'OpportunityProjectTrigger'.. 
*revision:
*/
    public void updateOpportunityOnProject(List<MW_Project__c> UpdateProjList ){
          Logger.push('updateOpportunityOnProject','OpportunityProjectDml');
           try{
                update UpdateProjList;
             }
            catch (System.DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        // Capture Dml exception here
                        Logger.debugException('DmlException:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
                    }
             } 
        
             Logger.Pop();
    }
    
}