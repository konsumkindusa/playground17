/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified:
 *@date Original: 19 Feb 2016, Last Modified: 
 *@description This  is Controller class for 'TerritorySalesTeamMemberComponent' . 
 *@Revision:
 */

public class TerritorySalesTeamMemberComponentCC {

    public String territoryRecId{get; set;}
    public List<UserTerritory2Association> userTerritoryList {get; set;}
    public Id teamUserAssociationId{get; set;}
    public Id territoryShadowId{get; set;}
    /*
      @name         getTerritoryTeamMembers
      @date         19.Feb.2016
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Method is use to get the Territory Team Member associated to the Territory 
        */    


    public List<UserTerritory2Association> getTerritoryTeamMembers(){
        Logger.push('getTerritoryTeamMembers','TerritorySalesTeamMemberComponentCC');
        
        userTerritoryList = new List<UserTerritory2Association>();
        if(territoryRecId != null){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : SObjectType.User.FieldSets.TerritorySalesTeamMemberFieldSet.getFields()) {
            
                query += 'User.'+f.getFieldPath() + ', ';
            
            }   
            query+= 'User.Name, RoleInTerritory2 from UserTerritory2Association'; 
            query+= ' where Territory2Id= '+'\'' + territoryRecId + '\' limit 500000';
            
            query=query.replace(', FROM', ' FROM');
            userTerritoryList = Database.query(query);
            System.debug('%%userTerritoryList%%'+userTerritoryList);
        }    
            
        if(userTerritoryList != null && !(userTerritoryList.isEmpty())){ 
            Logger.pop();
            System.debug('$$userTerritoryList$$'+userTerritoryList);
            return userTerritoryList ;
        }
        else{
            Logger.pop();
            System.debug('$$userTerritoryList$$'+userTerritoryList);
            return null;    
        }
    }
    
    /*
      @name         edit
      @date         9.March.2016
      @author       Abhay Verma
      @param        none.
      @return       pagereference. 
      @description  Method is use to redirect the page to the Territory Team User detail Page. 
    */
        
    public PageReference edit() {
  
        PageReference pg = new PageReference('/'+teamUserAssociationId+'/e');
        String returlstr='/apex/Territorysummary?id='+territoryShadowId;
        pg.getParameters().put('retURL', returlstr);
        pg.getParameters().put('isdtp','nv');
        return pg; 

    }
}