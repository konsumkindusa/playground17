/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: 
 *@date Original:18 Nov 2015, Last Modified:
 *@description This is Utility class for Territory2 And Territory Shadow Object Mapping .
 */
 
 public class SobjectCloningUtility{
     
     
     
     /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:18 Nov 2015, Last Modified: 18 Nov 2015
     * @description :Method to copy source object fields to target object fields using mapping from metadata type.  
     * @param :fieldMappingMap - Map of field mapping
     * @param :sourceObjLst - List of SourceObject
     * @param :sourceObjApi - SourceObject API name
     * @param :targetObjApi - TargetObject API name
     **/
    
    public static list<sObject> cloneSobject(Map<String,String> fieldMappingMap,List<sObject> sourceObjLst,String sourceObjApi,String targetObjApi){     
     
       Logger.push('SobjectCloningUtility','cloneSobject');
       
       //Instantiate target object list
       List<sObject> targetObjectLst = new List<sObject>();
       
       for(sObject obj:sourceObjLst){
         
          //Dynamically instantiate target object by using api name
          sObject sObj = Schema.getGlobalDescribe().get(targetObjApi).newSObject();
           
          for(String strObj:fieldMappingMap.keySet()){
              //Assigning source object field values to target objcet field values
              sObj.put(fieldMappingMap.get(strObj),obj.get(strObj));
          } 
          
          //Add sObj into target object field
          targetObjectLst.add(sObj);
       }
   
       Logger.pop();
       return targetObjectLst; 
    }
     
     
     
}//End of Class