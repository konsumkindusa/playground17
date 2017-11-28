/*
  *    @description:    tests the CDSContact
  */ 
@isTest
private class CDSContactTest{
     /*
      *    @description:    tests all the properties of CDSContact are working
      */ 
    private static testMethod void testGetParsedContactJson(){
        //setting value using getParsedContactJson() method
        String jsonToParse = '{"id":"C100023","selfIdentifiedCountryCode":"US", "source":"Webprofile","sourceId":"3288111","ebsSystemId":null,"recordStatus":"Active","sourceStatus":"368","status":"ACTIVE","salutation":"Mr.","greeting":null,"familyName":"Shi","givenName":"Congyin","latinFamilyName":null,"latinGivenName":null,"middleName":null,"department":"Electrical Engineering","department2":null,"mailStop":null,"latinDepartment":null,"latinDepartment2":null,"latinMailStop":null,"primaryAccountId":"C100021","primaryAccountSourceId":null,"primaryAddressId":"C100022","primaryAddressSourceId":null,"exportStatus":"D","exportProhibited":false,"warning":null,"primaryAccountWarning":null,"denied":false,"primaryAccountDenied":null,"exportReviewRequired":false,"licensed":null,"student":false,"contactRelatedSource":"Siebel","contactRelatedId":"1-GJUBJV","schoolName":null,"schoolCountry":null,"emails":[{"id":"100010","source":"Webprofile","sourceId":"3288111","primary":false,"address":"shicy.tulip@gmail.com","type":"MainEmail"}],"phones":[{"id":"100008","source":"Webprofile","sourceId":"3288111","type":"86","number1":"(979)209-4451","extension":null},{"id":"4908321","source":"WebProfile","sourceId":"3288111","type":"GENERAL","number1":"(979)209-4451","extension":null},{"id":"4908320","source":"WebProfile","sourceId":"3288111","type":"CELL","number1":"(979)209-4451","extension":null},{"id":"100007","source":"Webprofile","sourceId":"3288111","type":"86","number":"(979)209-4451","extension":null}],"userDefinedLogin":null,"keptId":null,"survivorId":null,"audit":{"createdDate":1327443953000,"createdBy":"MWUI","modifiedDate":1372305221000},"address":{"id":"C100022","recordStatus":"Active","sourceStatus":null,"status":null,"source":"Webprofile","sourceId":"4117694","ebsSystemId":null,"accountId":"C100021","line1":"Texas A&M University","line2":null,"line3":null,"line4":null,"mailStop":null,"city":"College Station","latinLine1":null,"latinLine2":null,"latinCity":null,"latinMailStop":null,"stateCode":"TX","stateName":null,"countryCode":"US","countryName":null,"postalCode":"77843-0001","county":null,"exportProhibited":false,"licensed":null,"type":null,"keptId":null,"survivorId":null,"taxExemptReason":null,"tax":null,"audit":{"createdDate":1327443953000,"createdBy":"MWUI","modifiedDate":1372305221000,"modifiedBy":"PRPL"}},"account":{"id":"C100021","recordStatus":"Active","sourceStatus":"368","status":"ACTIVE","source":"Webprofile","sourceId":"3288111","name":"Texas A&M University","latinName":null,"sector":"867","industry":null,"primaryAddressId":null,"sourceTerritoryId":null,"denied":null,"exportStatus":"D","warning":null,"exportReviewRequired":false,"activateDate":null,"licensed":null,"ebsSystemId":null,"operatingUnitId":null,"salesChannel":null,"keptId":null,"survivorId":null,"audit":{"createdDate":1327443953000,"createdBy":"MWUI","modifiedDate":1372305221000},"address":{"recordStatus":null,"sourceStatus":null,"status":null,"ebsSystemId":null,"line1":null,"line2":null,"line3":null,"line4":null,"mailStop":null,"city":null,"latinLine1":null,"latinLine2":null,"latinCity":null,"latinMailStop":null,"stateCode":null,"stateName":null,"countryCode":null,"countryName":null,"postalCode":null,"county":null,"exportProhibited":null,"licensed":null,"type":null,"keptId":null,"survivorId":null,"taxExemptReason":null,"tax":null}}}';
        CDSContact.Rootboolean CDSContactObj = CDSContact.getParsedContactJson(jsonToParse);
        
        //getting value
                
        //RootBoolean
        System.assertNotEquals(null, CDSContactObj);
        System.assertEquals('C100023', CDSContactObj.Id);
        System.assertEquals('Webprofile', CDSContactObj.source);
        System.assertEquals(null, CDSContactObj.ebsSystemId);
        System.AssertEquals('US',CDSContactObj.selfIdentifiedCountryCode);
            
        System.assertEquals('3288111', CDSContactObj.sourceId);
        System.assertEquals(null, CDSContactObj.name);
        System.assertEquals(null, CDSContactObj.activeStatus);
        System.assertEquals(null, CDSContactObj.emailAddress);
        System.assertEquals(null, CDSContactObj.siebelId);
        System.assertEquals(null, CDSContactObj.webprofileId);
        System.assertEquals(null, CDSContactObj.jobTitle);
        System.assertEquals(null, CDSContactObj.latinJobTitle);
        System.assertEquals(null, CDSContactObj.webprofileStatus);
        System.assertEquals(null, CDSContactObj.contactRole);
        System.assertEquals(null, CDSContactObj.disableMerge);
        System.assertEquals(null, CDSContactObj.employee);
        System.assertEquals(null, CDSContactObj.language);
        
        System.assertEquals('Active', CDSContactObj.recordStatus);
        System.assertEquals('368', CDSContactObj.sourceStatus);
        System.assertEquals('ACTIVE', CDSContactObj.status);
        System.assertEquals('Mr.', CDSContactObj.salutation);
        System.assertEquals(null, CDSContactObj.greeting);
        System.assertEquals('Shi', CDSContactObj.familyName);
        System.assertEquals('Congyin', CDSContactObj.givenName);
        System.assertEquals(null, CDSContactObj.latinFamilyName);
        System.assertEquals(null, CDSContactObj.latinGivenName);
        System.assertEquals(null, CDSContactObj.middleName);
        System.assertEquals('Electrical Engineering', CDSContactObj.department);
        System.assertEquals(null, CDSContactObj.department2);
        System.assertEquals(null, CDSContactObj.mailStop);
        System.assertEquals(null, CDSContactObj.latinDepartment);
        System.assertEquals(null, CDSContactObj.latinDepartment2);
        System.assertEquals(null, CDSContactObj.latinMailStop);
        System.assertEquals('C100021', CDSContactObj.primaryAccountId);
        System.assertEquals(null, CDSContactObj.primaryAccountSourceId);
        System.assertEquals('C100022', CDSContactObj.primaryAddressId);
        System.assertEquals(null, CDSContactObj.primaryAddressSourceId);
        System.assertEquals('D', CDSContactObj.exportStatus);
        System.assert(!CDSContactObj.exportProhibited);
        System.assertEquals(null, CDSContactObj.warning);
        System.assertEquals(null, CDSContactObj.primaryAccountWarning);
        System.assert(!CDSContactObj.denied);
        System.assertEquals(null, CDSContactObj.primaryAccountDenied);
        System.assert(!CDSContactObj.exportReviewRequired);
        System.assertEquals(null, CDSContactObj.licensed);
        System.assert(!CDSContactObj.student);
        System.assertEquals('Siebel', CDSContactObj.contactRelatedSource);
        System.assertEquals('1-GJUBJV', CDSContactObj.contactRelatedId);
        System.assertEquals(null, CDSContactObj.schoolName);
        System.assertEquals(null, CDSContactObj.schoolCountry);
        System.assertNotEquals(null, CDSContactObj.emails);
        System.assertNotEquals(null, CDSContactObj.account);
        System.assertEquals(null, CDSContactObj.userDefinedLogin);
        System.assertEquals(null, CDSContactObj.keptId);
        System.assertEquals(null, CDSContactObj.survivorId);
        System.assertNotEquals(null, CDSContactObj.audit);
        //Email        
            System.assertEquals('100010', CDSContactObj.emails[0].Id);
            System.assertEquals('Webprofile', CDSContactObj.emails[0].source);
            System.assertEquals('3288111', CDSContactObj.emails[0].sourceId);
            System.assert(!CDSContactObj.emails[0].primary);
            System.assertEquals('shicy.tulip@gmail.com', CDSContactObj.emails[0].address);
            System.assertEquals('MainEmail', CDSContactObj.emails[0].type);                    
        //Phone
            System.assertEquals('100008', CDSContactObj.phones[0].Id);
            System.assertEquals('Webprofile', CDSContactObj.phones[0].source);
            System.assertEquals('3288111', CDSContactObj.phones[0].sourceId);
            System.assertEquals('86', CDSContactObj.phones[0].type);
            System.assertEquals('(979)209-4451', CDSContactObj.phones[0].number1);
            System.assertEquals(null, CDSContactObj.phones[0].extension);
        //Audit
            System.assertEquals('1327443953000', string.valueOf(CDSContactObj.Audit.createdDate));
            System.assertEquals('MWUI', CDSContactObj.Audit.createdBy);
            System.assertEquals('1372305221000', string.valueOf(CDSContactObj.Audit.modifiedDate));
            System.assertEquals(null, string.valueOf(CDSContactObj.Audit.modifiedBy));
        //Address
            System.assertEquals('C100022', CDSContactObj.Address.Id);
            System.assertEquals('Active', CDSContactObj.Address.recordStatus);
            System.assertEquals(null, CDSContactObj.Address.sourceStatus);
            System.assertEquals(null, CDSContactObj.Address.status);
            System.assertEquals('Webprofile', CDSContactObj.Address.source);
            System.assertEquals('4117694', CDSContactObj.Address.sourceId);
            System.assertEquals(null, CDSContactObj.Address.ebsSystemId);
            System.assertEquals('C100021', CDSContactObj.Address.accountId);
            System.assertEquals('Texas A&M University', CDSContactObj.Address.line1);
            System.assertEquals(null, CDSContactObj.Address.line2);
            System.assertEquals(null, CDSContactObj.Address.line3);
            System.assertEquals(null, CDSContactObj.Address.line4);
            System.assertEquals(null, CDSContactObj.Address.mailStop);
            System.assertEquals('College Station', CDSContactObj.Address.city);
            System.assertEquals(null, CDSContactObj.Address.latinLine1);
            System.assertEquals(null, CDSContactObj.Address.latinLine2);
            System.assertEquals(null, CDSContactObj.Address.latinCity);
            System.assertEquals(null, CDSContactObj.Address.latinMailStop);
            System.assertEquals('TX', CDSContactObj.Address.stateCode);
            System.assertEquals(null, CDSContactObj.Address.stateName);
            System.assertEquals('US', CDSContactObj.Address.countryCode);
            System.assertEquals(null, CDSContactObj.Address.countryName);
            System.assertEquals('77843-0001', CDSContactObj.Address.postalCode);
            System.assertEquals(null, CDSContactObj.Address.county);
            System.assert(!CDSContactObj.Address.exportProhibited);
            System.assertEquals(null, CDSContactObj.Address.licensed);
            System.assertEquals(null, CDSContactObj.Address.type);
            System.assertEquals(null, CDSContactObj.Address.keptId);
            System.assertEquals(null, CDSContactObj.Address.survivorId);
            System.assertEquals(null, CDSContactObj.Address.taxExemptReason);
            
            System.assertNotEquals(null, CDSContactObj.Address.audit);
        //Audit2
            System.assertEquals('1327443953000', string.valueOf(CDSContactObj.Address.audit.createdDate));
            System.assertEquals('MWUI', CDSContactObj.Address.audit.createdBy);
            System.assertEquals('1372305221000', string.valueOf(CDSContactObj.Address.audit.modifiedDate));
            System.assertEquals('PRPL', CDSContactObj.Address.audit.modifiedBy);
       //Account
            System.assertEquals('C100021', CDSContactObj.account.Id);
            System.assertEquals('Active', CDSContactObj.account.recordStatus);
            System.assertEquals('368', CDSContactObj.account.sourceStatus);
            System.assertEquals('ACTIVE', CDSContactObj.account.status);
            System.assertEquals('Webprofile', CDSContactObj.account.source);
            System.assertEquals('3288111', CDSContactObj.account.sourceId);
            System.assertEquals('Texas A&M University', CDSContactObj.account.name);
            System.assertEquals(null, CDSContactObj.account.latinName);
            System.assertEquals('867', CDSContactObj.account.sector);
            System.assertEquals(null, CDSContactObj.account.industry);
            System.assertEquals(null, CDSContactObj.account.primaryAddressId);
            System.assertEquals(null, CDSContactObj.account.sourceTerritoryId);
            System.assertEquals(null, CDSContactObj.account.denied);
            System.assertEquals('D', CDSContactObj.account.exportStatus);
            System.assertEquals(null, CDSContactObj.account.warning);
            System.assert(!CDSContactObj.account.exportReviewRequired);
            System.assertEquals(null, CDSContactObj.account.activateDate);
            System.assertEquals(null, CDSContactObj.account.licensed);
            System.assertEquals(null, CDSContactObj.account.ebsSystemId);
            System.assertEquals(null, CDSContactObj.account.operatingUnitId);
            System.assertEquals(null, CDSContactObj.account.salesChannel);
            System.assertEquals(null, CDSContactObj.account.keptId);
            System.assertEquals(null, CDSContactObj.account.survivorId);
            System.assertNotEquals(null, CDSContactObj.account.audit);
           
        
        //Audit3
            System.assertEquals('1327443953000', string.valueOf(CDSContactObj.account.audit.createdDate));
            System.assertEquals('MWUI', CDSContactObj.account.audit.createdBy);
            System.assertEquals('1372305221000', string.valueOf(CDSContactObj.account.audit.modifiedDate));
            System.assertEquals(null, string.valueOf(CDSContactObj.account.audit.modifiedBy));
        //Address2          
            System.assertEquals(null, CDSContactObj.account.address.recordStatus);
            System.assertEquals(null, CDSContactObj.account.address.sourceStatus);
            System.assertEquals(null, CDSContactObj.account.address.status);                        
            System.assertEquals(null, CDSContactObj.account.address.ebsSystemId);            
            System.assertEquals(null, CDSContactObj.account.address.line1);
            System.assertEquals(null, CDSContactObj.account.address.line2);
            System.assertEquals(null, CDSContactObj.account.address.line3);
            System.assertEquals(null, CDSContactObj.account.address.line4);
            System.assertEquals(null, CDSContactObj.account.address.mailStop);
            System.assertEquals(null, CDSContactObj.account.address.city);
            System.assertEquals(null, CDSContactObj.account.address.latinLine1);
            System.assertEquals(null, CDSContactObj.account.address.latinLine2);
            System.assertEquals(null, CDSContactObj.account.address.latinCity);
            System.assertEquals(null, CDSContactObj.account.address.latinMailStop);
            System.assertEquals(null, CDSContactObj.account.address.stateCode);
            System.assertEquals(null, CDSContactObj.account.address.stateName);
            System.assertEquals(null, CDSContactObj.account.address.countryCode);
            System.assertEquals(null, CDSContactObj.account.address.countryName);
            System.assertEquals(null, CDSContactObj.account.address.postalCode);
            System.assertEquals(null, CDSContactObj.account.address.county);
            System.assertEquals(null, CDSContactObj.account.address.exportProhibited);
            System.assertEquals(null, CDSContactObj.account.address.licensed);
            System.assertEquals(null, CDSContactObj.account.address.type);
            System.assertEquals(null, CDSContactObj.account.address.keptId);
            System.assertEquals(null, CDSContactObj.account.address.survivorId);
            System.assertEquals(null, CDSContactObj.account.address.taxExemptReason);
            
    }
}