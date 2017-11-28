/**
 *@author Original:Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original:18 Feb 2015, Last Modified: 23 Feb 2015
 *@description : wrapper class for Json and to parse Json String.
**/
global class QuoteBean implements Comparable{
         public Integer id { get; set;}
            public String opportunityId { get; set;}
            public String contactId { get; set;}
            public String quoteStatus { get; set;}
            public String expirationDate { get; set;}
            public String createdBy { get; set;}
            public String dateCreated { get; set;}
            public Double productTotal { get; set;}
            public Double  discountTotal { get; set;}
            public Double  handlingTotal { get; set;}
            public Double taxTotal { get; set;}
            public String orderDate { get; set;}
            public String currencyCode { get; set;}
            public boolean webViewable { get; set;}
            public String modifiedBy { get; set;}
            public String dateUpdated { get; set;}
            public String accountId { get; set;}
            public Double prodSubTot { get; set;}
            
            
            public QuoteBean (String expirationDate){
                this.expirationDate = expirationDate;
            }
            
            global Integer compareTo(Object compareTo) {
                // Cast argument to QuoteBean 
                QuoteBean compareToQuote = (QuoteBean )compareTo;
                
                // The return value of 0 indicates that both elements are equal.
                Integer returnValue = 0;
                if (expirationDate > compareToQuote.expirationDate) {
                    // Set return value to a positive value.
                    returnValue = -1;
                } else if (expirationDate < compareToQuote.expirationDate) {
                    // Set return value to a negative value.
                    returnValue = 1;
                }
                
                return returnValue;       
        }
    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 23 Feb 2015 
     *@Last Modified: 23 Feb 2015
     *@Description: Method to parse json to single QuoteBean Class
    */
   
    public static QuoteBean parse(String json){
        return (QuoteBean) System.JSON.deserialize(json, QuoteBean.class);
    }
    
    /**
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 23 Feb 2015 
     *@Last Modified: 23 Feb 2015
     *@Description: Method to parse json to list of QuoteBean Class
    */
     public static List<QuoteBean> getParsedQuoteJson(String jsonToParse){
       
            List<QuoteBean> jsonToObjs = (List<QuoteBean>)JSON.deserialize(jsonToParse, List<QuoteBean>.class);
            jsonToObjs.sort();
            return jsonToObjs;
        
    }
 
}