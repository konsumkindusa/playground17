/**
 *author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
 *date Original: 18 Feb 2016, Last Modified: 18 Feb 2016
 *description This  is handler class for UserT2AMasterTrigger  
 */
public with sharing class UserT2ATriggerHandler {
    /**
     * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     * @date Original:18 Feb 2016 , Last Modified:18 Feb 2016
     * @description Method that handles before insert trigger event on the UserTerritory2Association object
     */
    public void onBeforeInsert(List<UserTerritory2Association> List_userT2A){   
        Logger.push('onBeforeInsert','UserT2ATriggerHandler ');
            //initialize the set for userId
            Set<Id> userIdSet = new Set<Id>();
            //iterate over the UserTerritory2Association for getting the user Id of trigger records
            for(UserTerritory2Association obj: List_userT2A ){
                if(obj.RoleInTerritory2 == null || obj.RoleInTerritory2 == ''){
                    userIdSet.add(obj.userId);
                }
            }
            if(userIdSet.size() > 0){
                //Map of key as a user Id and String as a functinal role
                Map<Id,User> userMap = new Map<Id,User>([Select Id,Functional_Role__c From User Where Id In:userIdSet]);
                //iterate over the UserTerritory2Association  List for setting the  RoleInTerritory2 
                for(UserTerritory2Association obj: List_userT2A ){
                    if(obj.RoleInTerritory2 == null || obj.RoleInTerritory2 == ''){
                         obj.RoleInTerritory2 = userMap.get(obj.UserId).Functional_Role__c;
                    }
                }
            }
        Logger.pop();
    }
}