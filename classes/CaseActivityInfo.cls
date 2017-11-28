/**
* @author Original: kishore AN - Cloudsherpas
* @date Original: 12 August,2013
* @description: This class is a wrapper class for every activity like Email Messages, Tasks, Case comments for a case
*/

public class CaseActivityInfo{

    public String activityId{get;set;}
    public String activitySubject{get;set;}
    public String activityType{get;set;}
    public DateTime activityCreateddate{get;set;}
    
    public CaseActivityInfo(){
    }
    
    public CaseActivityInfo(String id, String subject,String type, DateTime createddate){
        activityId = id;
        activitySubject = subject;
        activityType = type;
        activityCreateddate = createddate;
    }
}