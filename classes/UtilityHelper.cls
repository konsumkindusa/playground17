/**
 * @author Original: Kishore AN - Cloud Sherpas/Mathworks
 * @date Original: 26 July, 2013
 * @description: Class for utility methods
 * @revision: 9 June 2014 | Archana Lohar | Added method getLeadRecordTypeId
              13 June 2014 | Archana Lohar | Added method isProperIdFormat
              13 June 2014 | Archana Lohar | Added method LocaleToTimeFormatMap
 */ 

public with sharing class UtilityHelper {
    
   public Static Map<String, Schema.SObjectType> globalDescribe;   
    
    private UtilityHelper(){
    }
     public static List<String> getFieldPickListValues(String sObjectAPIName, String sObjectFiledName){         

        List<String> lstPickvals=new List<String>();
        ////Get the SObject from the Object Api name
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectAPIName);

        Sobject Object_name = targetType.newSObject();
        //grab the sobject that was passed 
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 

        //describe the sobject
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 

        //get a map of fields for the passed sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 

        //grab the list of picklist values for the passed field on the sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(sObjectFiledName).getDescribe().getPickListValues(); 

        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.add(a.getValue());
        }

        return lstPickvals;
    }
    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:9 June 2014, Last Modified: 9 June 2014
     * @description :Method that will use the schema method to get the recordtypeid by name
     * @param :record type name
     **/
    public static Id getLeadRecordTypeId(String recordTypeName){     
        Logger.push('getLeadRecordTypeId','UtilityHelper');
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Logger.pop(); 
        return leadRecordTypeId;

    }
 

    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:13 June 2014, Last Modified: 13 June 2014
     * @description :Method that will add the error to visualforce page
     * @param :Error message String
     **/
    public static void  addErrorMessage(String errorMessage){    

        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
        ApexPages.addMessage( myMsg ); 

    }

    
    /**
     * @Author Original:Sagar Talele
     * @Date Original: 22 September 2014
     * @Description: check the id is of type Opportunity
     */
    public static Schema.SObjectType ObjectTypeOf(ID oppId){
        Id myId;
        myId = oppId;
        Schema.SObjectType sObj=myId.getSObjectType();
        return sObj;

    }
   
    /**
     * @Author Original:Sagar Talele
     * @Date Original: 20 November 2014
     * @Description: check the Ownerid is  Queue Id or User Id
     */
    public static boolean IsObjectTypeOfQueue(String queueId){
        String myId;
        myId=queueId.trim();
        if(myId.startsWithIgnoreCase('00g')){
            return true;
        }
        return false;
    }
    /**
     * @Author Original:Sagar Talele
     * @Date Original: 25 September 2014
     * @Description: check the id is of type Opportunity
     */
    public static Integration_Settings__c getIntegrationInfo(){
        // Query the Integration_Settings__c and get the Username,Password,Clientname,Endpoint ,Timeout details for name =  'On Support'.
        Integration_Settings__c integrationSetting = [Select Id, Name, Username__c, Password__c, Clientname__c, Endpoint__c, Timeout__c From Integration_Settings__c Where Name = 'On Support' limit 1];
        return integrationSetting;
    }
    
    /**
     * @Author Original:kishore An
     * @Date Original: 24 octoeber 2014
     * @Description: return the map of Lead queues
     */
    public static Map<String, QueueSobject> getLeadQueuesMap(){
        map<String, QueueSobject> leadQueuesMap = new Map<String, QueueSobject>();
        for(QueueSobject queue :[Select SobjectType, QueueId, Id From QueueSobject WHERE SobjectType = 'Lead']){
            leadQueuesMap.put(queue.QueueId, queue);          

        }
        return leadQueuesMap;

    }
    
   
    
    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:18 Nov 2014, Last Modified: 18 Nov 2014
     * @description :Method  to get Organization Object
     * @param :
     **/
    public static Organization getOrganizationObject (){     
        
       Organization myOrg = [Select Id, DefaultOpportunityAccess, DefaultCaseAccess from Organization];  
       return myOrg;
       
    }
    
    /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:18 Jan 2016, Last Modified: 18 Jan 2016
     * @description :Method to get eQuery From FieldSets
     * @param :
     **/
     public static String generateQueryFromFieldSets(String sObjectName,Set<String> fieldSets,Set<String> additionalFields,String whereClause){  
     
     globalDescribe=Schema.getGlobalDescribe();     
         
     Set<String> fields = new Set<String>{'Id'};  
     String query='SELECT Id';  //initial query  
     if(additionalFields!=null)  
     for( String fs : additionalFields ) {            
       //add only unique fields  
       if(!fields.contains(fs)){  
         //maintain a set of fields so that only unique fields are added in query  
         fields.add(fs);  
         query = query+','+fs;  
       }      
     }  
     //describe the provided sObject  
     Schema.DescribeSObjectResult res=globalDescribe.get(sObjectName).getDescribe();  
     //get the fields set map  
     Map<String, Schema.FieldSet> fieldSetMap= res.fieldSets.getMap();  
         
     system.debug('fieldSetMap'+fieldSetMap);
     system.debug('fieldSetMap'+fieldSets);
     //iterate through provided fieldsets and generate query  
     for(String fieldSetName : fieldSets){  
       Schema.FieldSet fs = fieldSetMap.get(fieldSetName);  
       for( Schema.FieldSetMember fsm : fs.getFields() ) {            
         //add only unique fields  
         if(!fields.contains(fsm.getFieldPath())){  
           //maintain a set of fields so that only unique fields are added in query  
           fields.add(fsm.getFieldPath());  
           query = query+','+fsm.getFieldPath();  
         }      
       }  
     }  
     query = (whereClause == '' || whereClause ==null)   
             ? (query + ' FROM '+sObjectName)   
             : (query + ' FROM '+sObjectName + ' WHERE ' + whereClause);  
     return query;  
   }
    
   public Static String generateQueryFromFieldSet(String sObjectName,String fieldSet,Set<String> additionalFields,String whereClause){  
     return generateQueryFromFieldSets(sObjectName,new Set<String>{fieldSet},additionalFields,whereClause);   
   }
     /**
     * @author Original: Archana Lohar - Cloud Sherpas/Mathworks
     * @date Original:13 April 2016, Last Modified: 13 April 2016
     * @description :This is a utility method to sort a SelectOption list (dropdown) by label alphabetically.
     * @param :List of SelectOptions
     **/ 
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort)
    {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }  
   
}