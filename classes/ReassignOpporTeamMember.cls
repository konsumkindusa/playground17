/******************************************************************************
* @author         Jaspreet Monga 
* @date           8/4/2014 
* @description    will reassign the opportunity sales team members if owner of opportunity is changed.
*/

public class ReassignOpporTeamMember{

    Boolean ownerChanged = false; 
    static List<OpportunityTeamMember> listOpporTM = new List<OpportunityTeamMember>();
    static List<OpportunityShare> listOpporShares = new List<OpportunityShare>();
     Organization orgObj=new Organization();
   
  /******************************************************************************
  * @author         Jaspreet Monga
  * @date            8/4/2014 
  * @param          list of Opportunity sobject - list of new values of opportunity i.e trigger.new
  * @param          map of id and Opportunity sobject - map of old values of opportunity i.e. trigger.old
  * @return         null
  * @description    will verify if the owner of opportunity has changed or not.
  * If owner is changed then it will query related opportunity team members and add to a static list i.e. listOpporTM
  * will query opportunity sharing setting for opportunity if team member have read.write access and add to a static list of OpportunityShare i.e. listOpporShares 
  * If there is any exception it will call debugexception method of logger class

  ******************************************************************************/
   
   
    public void beforeUpdate(List<Opportunity> listOppTM, Map<Id,Opportunity> mapOppTM){
    
    logger.push('beforeUpdate','OpportunityTeamMember'); // Calling push method of logger class to log the exceptions
    List<String> listOpporID = new List<String>(); 
    for(Opportunity objOpportunity : listOppTM)
    {
        if(objOpportunity.ownerId != null && mapOppTM != null)
        {
            if(objOpportunity.ownerId != mapOppTM.get(objOpportunity.Id).OwnerId)
            {
                    ownerChanged = true;
                    String strOppID = string.valueof(objOpportunity.Id);
                    strOppId = strOppId.substring(0,15); // Converting length 18 digit to 15 digit, SOQL query doesn't return results if list of ids with length 18 digit is added to filter criteria
                    listOpporID.add(strOppId);     
            }
        }
    }
    if(ownerChanged)
    {
      try{
          listOpporTM =  [Select Id,userId,OpportunityId,OpportunityAccessLevel,TeamMemberRole from OpportunityTeamMember where OpportunityId IN :listOpporID  limit 50000];
          listOpporShares =  [select Id,UserOrGroupId,OpportunityId,OpportunityAccessLevel,RowCause from OpportunityShare where OpportunityId IN :listOpporID and OpportunityAccessLevel='Edit'];
      }
      catch(Exception ex)
      {
          logger.debugException(ex); // Calling debugException method of logger class to log the exceptions
      }
    }
     logger.pop(); // Calling pop method of logger class to log the exceptions
    }
    
    
  /******************************************************************************
  * @author         Jaspreet Monga
  * @date            8/4/2014 
  * @return         null
  * @description    will be called on after update execution of opportunity 
  * will insert the opportunities teams for the opportunities who owner has been changed
  * will update the sharing settings to read/write of new opportunity team members if they had read/write access before
  * If there is any exception it will call debugexception method of logger class
  * commenting code from line 92 as orgwide sharing settings have been changed for opportunities 
  ******************************************************************************/
    
    public void afterUpdate(){
    logger.push('afterUpdate','OpportunityTeamMember'); // Calling push method of logger class to log the exceptions
    List<OpportunityTeamMember> listNewOpporTM = new List<OpportunityTeamMember>();
    for(OpportunityTeamMember objOpportunityTeamMember:listOpporTM)
    {
        OpportunityTeamMember newOpportunityTeamMember = new OpportunityTeamMember();
        newOpportunityTeamMember.UserId = objOpportunityTeamMember.UserId;
        newOpportunityTeamMember.OpportunityId = objOpportunityTeamMember.OpportunityId;
        newOpportunityTeamMember.TeamMemberRole = objOpportunityTeamMember.TeamMemberRole;
        listNewOpporTM.add(newOpportunityTeamMember);
    }
    
    if(listNewOpporTM.size() > 0)
    {
        try{
            insert listNewOpporTM;
        } 
        catch(Exception ex)
        {
            logger.debugException(ex); // Calling debugException method of logger class to log the exceptions
        }

    }
    
 
  
    List<Id> listIdOppor = new List<Id>();
    List<Id> listIdUserGrp = new List<Id>();
    
    
    for(OpportunityShare objOpportunityShare : listOpporShares)
    {
      listIdOppor.add(objOpportunityShare.OpportunityId);
      listIdUserGrp.add(objOpportunityShare.UserOrGroupId);
    }
    
    try{
        listOpporShares =  [select Id,UserOrGroupId,OpportunityId,OpportunityAccessLevel,RowCause from OpportunityShare where OpportunityId IN :listIdOppor and UserOrGroupId IN: listIdUserGrp and RowCause = 'Team'];
    }
    catch(Exception ex)
    {
        logger.debugException(ex); // Calling debugException method of logger class to log the exceptions
    }
    
    orgObj=UtilityHelper.getOrganizationObject();
   
    if(orgObj.DefaultOpportunityAccess!='Edit'){
    
    for(OpportunityShare objOpportunityShare : listOpporShares)
    {
       objOpportunityShare.OpportunityAccessLevel = 'Edit';  
    }
    
    if(listOpporShares.size() > 0)
    {
       try{
            update listOpporShares;   
        }
        catch (System.DmlException e) {            
           
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                Logger.debugException('Error in replaceAccountAddress:'+e.getDmlMessage(i)+ 'for ID:'+e.getDmlId(i));
            }
        }
    }
    
    }
   
    
     logger.pop(); // Calling pop method of logger class to log the exceptions
    } 
    
}