/**
* @author Original: Jaspreet Monga
* @date Original: 7/21/2014 Modified: 2/25/15 Shweta Shanbhag - removed harcoded messages and used custom label
* @description: - controller of page viewterritoryteams
                - retrieves territoryid from query string parameter of page 
                - calls method fetchterritoryteamdetails of class territoryteam to get list of users related to territory
                - defines error messages to be displayed on page
*/

public class viewterritoryteam {
public List<UserTerritory2Association> ViewUserDetails {get;set;}
public String strTerritoryname {get;set;}
public viewterritoryteam(){
    ViewUserDetails = new List<UserTerritory2Association>();
    String strTerritoryId;
    strTerritoryId = ApexPages.currentPage().getParameters().get('territoryId');
    territoryteam objterritoryteam  = new territoryteam();
    if(strTerritoryId== null || strTerritoryId=='')
    {
      
      apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,Label.Territory_not_available);
      apexpages.addmessage(msg);
      return;
    }
    else if((strTerritoryID.length() == 15 || strTerritoryId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', strTerritoryId))
    {
     Id TerritoryID = id.valueOf(strTerritoryId);
     ViewUserDetails = objterritoryteam.fetchterritoryteamdetails(territoryId);
    }
   
    if(ViewUserDetails.size() < 1)
    {
       
        apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,Label.Territory_No_Team_Role);
        apexpages.addmessage(msg);
        return;
    }else if(ViewUserDetails[0].Territory2.Territory2Model.State != 'Active')
    {
        
        apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,Label.Territory_Model_not_active);
        apexpages.addmessage(msg);
        return;
    }
    }
}