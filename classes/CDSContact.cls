/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Shweta Shanbhag - Mathworks
 *date Original: 2 June 2014, Last Modified: 30 March 2016
 *description : */

public with sharing class CDSContact {

    private CDSContact(){}

    public class Rootboolean
    {
        public string id { get; set;}
        public string source { get; set;}
        public string sourceId { get; set;}
        public string name { get; set;}
        public string ebsSystemId { get; set;}
        public string recordStatus { get; set;}
        public string sourceStatus { get; set;}
        public string status { get; set;}
        public string activeStatus { get; set;}
        public string salutation { get; set;}
        public string greeting { get; set;}
        public string familyName { get; set;}
        public string givenName { get; set;}
        public string latinFamilyName { get; set;}
        public String latinGivenName { get; set;}
        public string middleName { get; set;}
        public string department { get; set;}
        public String department2 { get; set;}
        public string mailStop { get; set;}
        public string latinDepartment { get; set;}
        public string latinDepartment2 { get; set;}
        public string latinMailStop { get; set;}
        public string primaryAccountId { get; set;}
        public string primaryAccountSourceId { get; set;}
        public string primaryAddressId { get; set;}
        public string primaryAddressSourceId { get; set;}
        public string exportStatus { get; set;}
        public boolean exportProhibited { get; set;}
        public string warning { get; set;}
        public string primaryAccountWarning { get; set;}
        public boolean denied { get; set;}
        public boolean primaryAccountDenied { get; set;}
        public boolean exportReviewRequired { get; set;}
        public boolean licensed { get; set;}
        public boolean student { get; set;}
        public string contactRelatedSource { get; set;}
        public string contactRelatedId { get; set;}
        public string schoolName { get; set;}
        public string schoolCountry { get; set;}
        public List<Email> emails { get; set;}
        public List<Phone> phones { get; set;}
        public string userDefinedLogin { get; set;}
        public string keptId { get; set;}
        public string survivorId { get; set;}
        public Audit audit { get; set;}
        public Address address { get; set;}
        public Account account { get; set;}
        public String emailAddress { get; set;}
        public String siebelId { get; set;}
        public String webprofileId { get; set;}
        public String jobTitle { get; set;}
        public String latinJobTitle { get; set;}
        public String webprofileStatus { get; set;}
        public String contactRole { get; set;}
        public boolean disableMerge { get; set;}
        public boolean employee { get; set;}
        public String language { get; set;}
        public String selfIdentifiedCountryCode {get; set;}
        public String derivedCountryCode {get; set;} //SS 3/29/16 Added for story 1427676
        public String webprofileEmailVerified {get; set;} //DL 4/8/16 Added for story 1427895
    }

    public class Email
    {
        public string id { get; set;}
        public string source { get; set;}
        public string sourceId { get; set;}
        public boolean primary { get; set;}//boolean
        public string address { get; set;}
        public string type { get; set;}
    }

    public class Phone
    {
        public string id { get; set;}
        public string source { get; set;}
        public string sourceId { get; set;}
        public string type { get; set;}//type
        public string number1 { get; set;}//number
        public string extension { get; set;}
    }

    public class Audit
    {
        public long createdDate { get; set;}
        public string createdBy { get; set;}
        public long modifiedDate { get; set;}
        public string modifiedBy { get; set;}
    }

    public class Audit2
    {
        public long createdDate { get; set;}
        public string createdBy { get; set;}
        public long modifiedDate { get; set;}
        public string modifiedBy { get; set;}
    }

    public class Address
    {
        public string id { get; set;}
        public string recordStatus { get; set;}
        public string sourceStatus { get; set;}
        public string status { get; set;}
        public string source { get; set;}
        public string sourceId { get; set;}
        public String ebsSystemId { get; set;}
        public string accountId { get; set;}
        public string line1 { get; set;}
        public string line2 { get; set;}
        public string line3 { get; set;}
        public string line4 { get; set;}
        public string mailStop { get; set;}
        public string city { get; set;}
        public string latinLine1 { get; set;}
        public string latinLine2 { get; set;}
        public string latinCity { get; set;}
        public string latinMailStop { get; set;}
        public string stateCode { get; set;}
        public string stateName { get; set;}
        public string countryCode { get; set;}
        public string countryName { get; set;}
        public string postalCode { get; set;}
        public string county { get; set;}
        public boolean exportProhibited { get; set;}
        public boolean licensed { get; set;}
        public string type { get; set;}
        public string keptId { get; set;}
        public string survivorId { get; set;}
        public string taxExemptReason { get; set;}        
        public Audit2 audit { get; set;}
    }

    public class Audit3
    {
        public long createdDate { get; set;}
        public string createdBy { get; set;}
        public long modifiedDate { get; set;}
        public string modifiedBy { get; set;}
    }

    public class Address2
    {
        public String recordStatus { get; set;}
        public String sourceStatus { get; set;}
        public String status { get; set;}
        public String ebsSystemId { get; set;}
        public String line1 { get; set;}
        public String line2 { get; set;}
        public String line3 { get; set;}
        public String line4 { get; set;}
        public String mailStop { get; set;}
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
        public boolean exportProhibited { get; set;}
        public boolean licensed { get; set;}
        public String type { get; set;}
        public String keptId { get; set;}
        public String survivorId { get; set;}
        public String taxExemptReason { get; set;}
        
    }

    public class Account
    {
        public string id { get; set;}
        public string recordStatus { get; set;}
        public string sourceStatus { get; set;}
        public string status { get; set;}
        public string source { get; set;}
        public string sourceId { get; set;}
        public string name { get; set;}
        public String latinName { get; set;}
        public string sector { get; set;}
        public string industry { get; set;}
        public string primaryAddressId { get; set;}
        public string sourceTerritoryId { get; set;}
        public boolean denied { get; set;}
        public string exportStatus { get; set;}
        public string warning { get; set;}
        public boolean exportReviewRequired { get; set;}
        public string activateDate { get; set;} 
        public boolean licensed { get; set;}
        public string ebsSystemId { get; set;}
        public string operatingUnitId { get; set;}
        public string salesChannel { get; set;}
        public string keptId { get; set;}
        public string survivorId { get; set;}
        public Audit3 audit { get; set;}
        public Address2 address { get; set;}
        public String corporateParentId { get; set;} //DL 4/8/16 Added for story 1427895
        
    }
    
    /**
     *Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *Date Original: 2 June 2014 
     *Last Modified: 2 June 2014
     *Description: Method to parse json to cdsContact
     */
    public static CDSContact.Rootboolean getParsedContactJson(String jsonToParse){
        
         return (CDSContact.Rootboolean)JSON.deserialize(jsonToParse, CDSContact.Rootboolean.class);
       
        
    }
}