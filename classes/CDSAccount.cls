/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Kishore AN - Cloud Sherpas/Mathworks
 *date Original: 2 June 2014, Last Modified: 15 Oct 2014
 *description :This is Json parser class for Account
 *revision: Added sourcePrimaryPositionId field. 
 */

public class CDSAccount {
    
    private CDSAccount(){}

    public class RootString
    {
        public string id  { get; set;}
        public string recordStatus  { get; set;}
        public string sourceStatus  { get; set;}
        public string activeStatus  { get; set;}
        
        public string status  { get; set;}
        public string source  { get; set;}
        public string sourceId  { get; set;}
        public string name  { get; set;}
        public String latinName  { get; set;}
        public string sector  { get; set;}
        public String industry  { get; set;}
        public String primaryAddressId  { get; set;}
        public String sourceTerritoryId  { get; set;}
        public boolean denied  { get; set;}
        public string exportStatus { get; set;}
        public String warning { get; set;}
        public boolean exportReviewRequired  { get; set;}
        public String activateDate  { get; set;}
        public boolean licensed { get; set;}
        public String ebsSystemId  { get; set;}
        public String operatingUnitId  { get; set;}
        public String salesChannel  { get; set;}
        public String keptId  { get; set;}
        public String survivorId  { get; set;}
        public String controlledTechnologyAlert { get; set;}
        public String corporateParentId { get; set;}
        public boolean mathworksRelated { get; set;}
        public boolean competitor { get; set;}
        public String website { get; set;}
        public String siebelId { get; set;}
        public Audit audit  { get; set;}
        public Address address  { get; set;}
        public String exportprohibited  { get; set;}
        public string sourcePrimaryPositionId {get; set;}
        public boolean disableMerge { get; set;}
    }
    public class Audit
    {
        public long createdDate  { get; set;}
        public string createdBy  { get; set;}
        public long modifiedDate  { get; set;}
        public String modifiedBy { get; set;}
    }

    public class Address
    {
        public String recordStatus { get; set;}
        public String sourceStatus { get; set;}
        public String status { get; set;}
        public String ebsSystemId { get; set;}
        public String line1 { get; set;}
        public String line2 { get; set;}
        public String line3 { get; set;}
        public String line4 { get; set;}
        public String mailStop  { get; set;}
        public String city { get; set;}
        public String latinLine1 { get; set;}
        public String latinLine2 { get; set;}
        public String latinCity { get; set;}
        public String latinMailStop { get; set;}
        public String stateCode { get; set;}
        public String stateName { get; set;}
        public String countryCode { get; set;}
        public String countryName { get; set;}
        public String postalCode { get; set;}
        public String county { get; set;}
        public String exportProhibited { get; set;}
        public String licensed { get; set;}
        public String type { get; set;}
        public String keptId { get; set;}
        public String survivorId { get; set;}
        public String taxExemptReason { get; set;}
        public String id { get; set;}
    }
    
    public static CDSAccount.RootString  getParsedAccountJson(String jsonToParse){
        
       return (CDSAccount.RootString)JSON.deserialize(jsonToParse, CDSAccount.RootString.class);
       
    }

}