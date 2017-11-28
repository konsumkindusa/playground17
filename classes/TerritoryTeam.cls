/**
* @author Original: Jaspreet
* @date Original: 7/22/2014
* @description: this class does following functions:
        - queries territory_team field set from user 
        - returns list of UserTerritory Association table related to a territory
* Archana Suryawanshi | 23 May 2016| Attask:1211182 and 1362981 - Added RoleInTerritory2 in Query for Opportunity assignment based on user territory association role in territory (and not on the User Default Functional Role)
*/

public class TerritoryTeam{

    // this method is being called in class viewterritoryteam
    public List<UserTerritory2Association> fetchTerritoryTeamDetails(Id territoryID)
    {    
        System.debug('**territoryID**'+territoryID);
            List<UserTerritory2Association> listUserTerritoryAssoc = new List<UserTerritory2Association>();
    
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : SObjectType.User.FieldSets.territory_team.getFields()) {

                    query += 'User.'+f.getFieldPath() + ', ';

            }   
            query+= 'Territory2.Name,Territory2.Territory2Model.State,Territory2.Office__c,RoleInTerritory2 from UserTerritory2Association'; 
            query+= ' where Territory2Id= '+'\'' + territoryID + '\' limit 500000';

            query=query.replace(', FROM', ' FROM');
            listUserTerritoryAssoc = Database.query(query);
                                                           
        return listUserTerritoryAssoc ;
    }

}