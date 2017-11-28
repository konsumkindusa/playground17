/**
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
 *@date Original: 5 August 2014, Last Modified: 25 Nov 2014
 *@description : wrapper class for Json and to parse Json String.
*/

public with sharing class GQOQuote {
   private GQOQuote(){
   }
       
    /**
     *@Author Original: Divya Gawade - Cloud Sherpas/Mathworks 
     *@Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
     *@Date Original: 5 August 2014 
     *@Last Modified: 25 Nov 2014
     *@Description: Method to parse json to GQOQuote
    */
     public static List<QuoteObject> getParsedQuoteJson(String jsonToParse){
        try{
        /*
            List<String> contactSiebelId;
            Map<String,Contact> mapContact;
            List<String> accountSiebelId;
            Map<String,Account> mapAccount;
            */
            List<QuoteObject> jsonToObjs = (List<QuoteObject>)JSON.deserialize(jsonToParse, List<QuoteObject>.class);
            system.debug('***jsonToObjs***'+jsonToObjs);
            jsonToObjs.sort();
            return jsonToObjs;
        }
        catch(JSONException ex){
            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex);
            Logger.pop();
            return null;
        }
    }

}