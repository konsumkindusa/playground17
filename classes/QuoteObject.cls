global class QuoteObject implements Comparable{
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
            
            
            public QuoteObject (String expirationDate){
                this.expirationDate = expirationDate;
            }
            
            global Integer compareTo(Object compareTo) {
                // Cast argument to QuoteObject 
                QuoteObject  compareToQuote = (QuoteObject )compareTo;
                
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
            
       }