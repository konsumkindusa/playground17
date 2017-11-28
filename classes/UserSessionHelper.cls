public class UserSessionHelper{

        
    @future(callout=true)
    public static void requestAccessToken(String username, String password, String clientId, String clientSecret, String tokenEndpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpoint);
        req.setMethod('POST');
        req.setBody(buildHttpQuery(new Map<String, String> {
            'grant_type' => 'password',
            'username' => username,
            'password' => password,
            'client_id' => clientId,
            'client_secret' => clientSecret
        }));

        Http http = new Http();
        HttpResponse resp = http.send(req);

        Map<String, Object> m =
            (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        
        SendArticlesSession__c sases = SendArticlesSession__c.getOrgDefaults();
        
        //HW 1816555. Adding safety check to prevent blank SessionId from overwriting the custom setting.
        string token = (String) m.get('access_token');
        System.Debug('requestAccessToken-SessionId: ' + token);
        
        if (token != null) {
        	sases.SessionId__c = token;
        	update sases;
        }
        //HW 1816555
    }

    static String buildHttpQuery(Map<String, String> queryParams) {        
        if (queryParams.isEmpty()) {
            return '';
        }

        String[] params = new String[] {};
        for (String k : queryParams.keySet()) {
            String v = EncodingUtil.urlEncode(queryParams.get(k), 'UTF-8');

            params.add(String.format('{0}={1}', new String[] { k, v }));
        }

        return String.join(params, '&');
        
    }
}