@isTest
private class GQOQuoteTest {

    private static testMethod void testGetParsedQuoteJson() {
       //setting value using getParsedContactJson() method
        String jsonToParse ='[{"id":2019965,"opportunityId":"1-5P8UHT","contactId":"1-ACMSJ","quoteStatus":"Active","expirationDate":"2008-06-03 00:00:00.0","createdBy":"beals","dateCreated":"2008-04-04 00:00:00.0","productTotal":232159.4,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":21105.4,"orderDate":null,"currencyCode":"AUD","webViewable":true,"modifiedBy":"jwang","dateUpdated":"2008-04-06 21:25:11.0","accountId":"1-ODPT"},{"id":2036799,"opportunityId":"1-5P8UHT","contactId":"1-ACMSJ","quoteStatus":"Working","expirationDate":"2008-06-04 00:00:00.0","createdBy":"wvolwerk","dateCreated":"2008-05-05 00:00:00.0","productTotal":304263.3,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":27660.3,"orderDate":null,"currencyCode":"AUD","webViewable":true,"modifiedBy":"wvolwerk","dateUpdated":"2008-05-05 21:40:49.0","accountId":"1-ODPT"},{"id":2036803,"opportunityId":"1-5P8UHT","contactId":"1-ACMSJ","quoteStatus":"Working","expirationDate":"2008-06-04 00:00:00.0","createdBy":"wvolwerk","dateCreated":"2008-05-05 00:00:00.0","productTotal":299076.8,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":27188.8,"orderDate":null,"currencyCode":"AUD","webViewable":true,"modifiedBy":"wvolwerk","dateUpdated":"2008-05-05 23:09:51.0","accountId":"1-ODPT"},{"id":2036812,"opportunityId":"1-5P8UHT","contactId":"1-ACMSJ","quoteStatus":"Active","expirationDate":"2008-06-04 00:00:00.0","createdBy":"wvolwerk","dateCreated":"2008-05-05 00:00:00.0","productTotal":363460.9,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":33041.9,"orderDate":null,"currencyCode":"AUD","webViewable":true,"modifiedBy":"wvolwerk","dateUpdated":"2008-05-05 23:14:33.0","accountId":"1-ODPT"},{"id":2036813,"opportunityId":"1-5P8UHT","contactId":"1-ACMSJ","quoteStatus":"Active","expirationDate":"2008-06-04 00:00:00.0","createdBy":"wvolwerk","dateCreated":"2008-05-05 00:00:00.0","productTotal":299076.8,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":27188.8,"orderDate":null,"currencyCode":"AUD","webViewable":true,"modifiedBy":"wvolwerk","dateUpdated":"2008-05-05 23:39:27.0","accountId":"1-ODPT"},{"id":2898563,"opportunityId":"1-5P8UHT","contactId":"1-1043BR","quoteStatus":"Order","expirationDate":"2011-03-05 00:00:00.0","createdBy":"dmagner","dateCreated":"2011-01-04 00:00:00.0","productTotal":55629.0,"discountTotal":0.0,"handlingTotal":0.0,"taxTotal":2649.0,"orderDate":"2011-02-07 00:00:00.0","currencyCode":"JPY","webViewable":false,"modifiedBy":"legacyquotesws","dateUpdated":"2014-08-04 16:25:04.0","accountId":"1-CZ3B"}]'; 
        List<QuoteObject> GQOQuoteObj = GQOQuote.getParsedQuoteJson(jsonToParse);
        //getting value
                
        //RootBoolean
        System.assertNotEquals(null, GQOQuoteObj);
        System.assertEquals(2898563, GQOQuoteObj[0].id);
        System.assertEquals('1-5P8UHT', GQOQuoteObj[0].opportunityId);
        System.assertEquals('1-1043BR', GQOQuoteObj[0].contactId);
        System.assertEquals('Order', GQOQuoteObj[0].quoteStatus);
        System.assertEquals('2011-03-05 00:00:00.0', GQOQuoteObj[0].expirationDate);
        System.assertEquals('dmagner', GQOQuoteObj[0].createdBy);
        System.assertEquals('2011-01-04 00:00:00.0', GQOQuoteObj[0].dateCreated);
        System.assertEquals(55629.0, GQOQuoteObj[0].productTotal); 
        System.assertEquals(0.0, GQOQuoteObj[0].discountTotal);
        System.assertEquals(0.0, GQOQuoteObj[0].handlingTotal);
        System.assertEquals(2649.0, GQOQuoteObj[0].taxTotal);
        System.assertEquals('2011-02-07 00:00:00.0', GQOQuoteObj[0].orderDate);
        System.assertEquals('JPY', GQOQuoteObj[0].currencyCode);
        System.assertEquals(false, GQOQuoteObj[0].webViewable);
        System.assertEquals('legacyquotesws', GQOQuoteObj[0].modifiedBy);
        System.assertEquals('2014-08-04 16:25:04.0', GQOQuoteObj[0].dateUpdated);
        System.assertEquals('1-CZ3B', GQOQuoteObj[0].accountId);
           }
}