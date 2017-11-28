/**
 *author Original: Faina Gorelik - MathWorks
 *date Original: 16 June 2016
* description : Utilitiy class to parse OnSupport  REST API response
 */
public with sharing class OnSupportUtilityClass {

    public class Rootboolean{
    
        public string licenseid { get; set;}
        public boolean licenseSupportEligible {get;set;}
        public string licenseReason {get;set;}
        public string licenseeAccountId {get;set;}
        public string productCode {get;set;}
        public boolean productSupportEligible {get;set;}
        public string productReason {get;set;}
        public ControllingProductDetail controllingProductDetail {get;set;}
        public RequestedProductDetail requestedProductDetail {get;set;}
        public string detail {get;set;}
        
    }
    public class ControllingProductDetail{
        public string geographicScope {get;set;}
        public string latestServiceEndDate {get;set;}
        public integer offeringGracePeriod {get;set;}
        public string option {get;set;}
        public string term {get;set;}
        public string use {get;set;}
        public string lifecycleStage {get;set;}

    }
    
    public class RequestedProductDetail{
        public string geographicScope {get;set;}
        public string latestServiceEndDate {get;set;}
        public integer offeringGracePeriod {get;set;}
        public string option {get;set;}
        public string term {get;set;}
        public string use {get;set;}
        public string lifecycleStage {get;set;}
        
    }
    private OnSupportUtilityClass(){}
    
    /**
     *Author Original: Faina Gorelik - MathWorks
     *Date Original: 16 June 2016
     *Last Modified: 
     *Description: Method to parse OnSupport json string
     */
   public static OnSupportUtilityClass.Rootboolean getParsedOnSupportJson(String jsonToParse){
        
         return (OnSupportUtilityClass.Rootboolean)JSON.deserialize(jsonToParse, OnSupportUtilityClass.Rootboolean.class);
       
        
    }
    
}