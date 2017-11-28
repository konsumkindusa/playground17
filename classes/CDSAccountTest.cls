/*
  *    @description:    tests the CDSAccount
  */ 
@isTest

private class CDSAccountTest {
    
     /*
      *    @description:    tests all the properties of CDSContact are working
      */ 
    private static testMethod void testGetParsedContactJson(){
        //setting value using getParsedContactJson() method
        
       
        String jsonToParse='{"id":"C100316","recordStatus":"Active","sourceStatus":"373","status":"UNCONFIRMED","activeStatus":"Y","source":"Webprofile","sourceId":"4398097","name":"Univ of Manchester","latinName":null,"sector":"867","industry":null,"primaryAddressId":null,"sourceTerritoryId":null,"denied":null,"exportStatus":"D","exportProhibited":"N","warning":null,"exportReviewRequired":false,"activateDate":null,"licensed":null,"ebsSystemId":null,"operatingUnitId":null,"salesChannel":null,"keptId":null,"survivorId":null,"audit":{"createdDate":1372299734000,"createdBy":"MWUI","modifiedDate":1372305292000},"address":{"recordStatus":null,"sourceStatus":null,"status":null,"ebsSystemId":null,"line1":null,"line2":null,"line3":null,"line4":null,"mailStop":null,"city":null,"latinLine1":null,"latinLine2":null,"latinCity":null,"latinMailStop":null,"stateCode":null,"stateName":null,"countryCode":null,"countryName":null,"postalCode":null,"county":null,"exportProhibited":null,"licensed":null,"type":null,"keptId":null,"survivorId":null,"taxExemptReason":null,"tax":null }}';
       
        CDSAccount.RootString CDSaccountObj = CDSAccount.getParsedAccountJson(jsonToParse);
        
        //getting value 
                
            //RootBoolean
            System.assertEquals ('C100316',CDSaccountObj.id);
            System.assertEquals ('Active',CDSaccountObj.recordStatus );
            System.assertEquals ('373',CDSaccountObj.sourceStatus );
        
            System.assertEquals (null,CDSaccountObj.corporateParentId);
            System.assertEquals (null,CDSaccountObj.mathworksRelated );
            System.assertEquals (null,CDSaccountObj.competitor);
            System.assertEquals (null,CDSaccountObj.controlledTechnologyAlert);
            System.assertEquals (null,CDSaccountObj.website);
            System.assertEquals (null,CDSaccountObj.siebelId);
            System.assertEquals (null,CDSaccountObj.sourcePrimaryPositionId);
            System.assertEquals (null,CDSaccountObj.disableMerge);
            
        
            System.assertEquals ('UNCONFIRMED',CDSaccountObj.status );
            System.assertEquals ('Y',CDSaccountObj.activeStatus ); 
            
            System.assertEquals ('Webprofile',CDSaccountObj.source );
            System.assertEquals ('4398097',CDSaccountObj.sourceId );
            System.assertEquals ('Univ of Manchester',CDSaccountObj.name );
            System.assertEquals (null,CDSaccountObj.latinName );
            System.assertEquals ('867',CDSaccountObj.sector );
            System.assertEquals (null,CDSaccountObj.industry );
            System.assertEquals (null,CDSaccountObj.primaryAddressId );
            System.assertEquals (null,CDSaccountObj.sourceTerritoryId );
            System.assertEquals (null,CDSaccountObj.denied );
            System.assertEquals ('D',CDSaccountObj.exportStatus );
            System.assertEquals ('N',CDSaccountObj.exportprohibited );
           
            System.assertEquals (null,CDSaccountObj.warning );
            System.assert(!CDSaccountObj.exportReviewRequired );
            System.assertEquals (null,CDSaccountObj.activateDate );
            System.assertEquals (null,CDSaccountObj.licensed );
            System.assertEquals (null,CDSaccountObj.ebsSystemId );
            System.assertEquals (null,CDSaccountObj.operatingUnitId );
            System.assertEquals (null,CDSaccountObj.salesChannel );
            System.assertEquals (null,CDSaccountObj.keptId );
            System.assertEquals (null,CDSaccountObj.survivorId );
            
            //Audit
            System.assertEquals('1372299734000',String.valueOf(CDSaccountObj.Audit.createdDate));
            System.assertEquals('MWUI',CDSaccountObj.Audit.createdBy);
            System.assertEquals('1372305292000',String.valueOf(CDSaccountObj.Audit.modifiedDate));
            System.assertEquals(null,String.valueOf(CDSaccountObj.Audit.modifiedBy));
        
            //Address
        
            System.assertEquals(null, CDSaccountObj.Address.recordStatus);
            System.assertEquals(null, CDSaccountObj.Address.sourceStatus);
            System.assertEquals(null, CDSaccountObj.Address.status);
            System.assertEquals(null, CDSaccountObj.Address.id);
           
            
            System.assertEquals(null, CDSaccountObj.Address.ebsSystemId);
          
            System.assertEquals(null, CDSaccountObj.Address.line1);
            System.assertEquals(null, CDSaccountObj.Address.line2);
            System.assertEquals(null, CDSaccountObj.Address.line3);
            System.assertEquals(null, CDSaccountObj.Address.line4);
            System.assertEquals(null, CDSaccountObj.Address.mailStop);
            System.assertEquals(null,CDSaccountObj.Address.city);
            System.assertEquals(null, CDSaccountObj.Address.latinLine1);
            System.assertEquals(null, CDSaccountObj.Address.latinLine2);
            System.assertEquals(null, CDSaccountObj.Address.latinCity);
            System.assertEquals(null, CDSaccountObj.Address.latinMailStop);
            System.assertEquals(null, CDSaccountObj.Address.stateCode);
            System.assertEquals(null, CDSaccountObj.Address.stateName);
            System.assertEquals(null, CDSaccountObj.Address.countryCode);
            System.assertEquals(null, CDSaccountObj.Address.countryName);
            System.assertEquals(null, CDSaccountObj.Address.postalCode);
            System.assertEquals(null, CDSaccountObj.Address.county);
            System.assertEquals(null, CDSaccountObj.Address.exportProhibited);
            System.assertEquals(null, CDSaccountObj.Address.licensed);
            System.assertEquals(null, CDSaccountObj.Address.type);
            System.assertEquals(null, CDSaccountObj.Address.keptId);
            System.assertEquals(null, CDSaccountObj.Address.survivorId);
            System.assertEquals(null, CDSaccountObj.Address.taxExemptReason);
            
           
    }
}