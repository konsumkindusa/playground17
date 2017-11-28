/*******************************************************************************
* @author       Andre Calimlim
* @date         5.19.2014
* @description  Class that is used to retrieve the LogConfig custom settings of 
*               the current user profile. 
*******************************************************************************/
public class LogConfigSettings{
    
    private static LogConfig__c theSetting = LogConfig__c.getInstance(UserInfo.getUserId());
    
    private static Map<string, schema.recordtypeinfo> recordTypeInfo = Schema.getGlobalDescribe().get('Log__c').getDescribe().getRecordTypeInfosByName();
    
    
    public static Id getDebugRecordType(){
    
        if(recordTypeInfo.get(theSetting.Debug_Record_Type__c)!=null){
        
          return recordTypeInfo.get(theSetting.Debug_Record_Type__c).getRecordTypeId();
        
        }
        else{
        
          return null; 
        
        }  
          
    }
    
    
    public static Id getExceptionRecordType(){
    
       if(recordTypeInfo.get(theSetting.Exception_Record_Type__c)!=null){
        
          return recordTypeInfo.get(theSetting.Exception_Record_Type__c).getRecordTypeId();
        
        }
        else{
        
          return null; 
        
        }    
    }
    
    public static  Boolean loggingEnabled(){

        return theSetting.Logging_Enabled__c;
    }
    public static  Boolean exceptionEnabled(){

        return theSetting.Exceptions_Enabled__c;
    }
}