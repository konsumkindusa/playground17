/**
 * @author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Jesfer Baculod - Cloud Sherpas/Mathworks
 * @date Original: 13 August 2015, Last Modified: 13 August 2015
 * @description Global utility class that contains different record builders for unit testing.
 */
public class UEH_TestDataBuilder {
	
    /**
       * @author Original: Archana Lohar
       * @date Original: 13 August 2015
       * @description: This method will be used  to create Partner Agreement record
       */
       public static Partner_Agreement__c  buildPartnerAgreement(){
           
           Partner_Agreement__c agreeObj = new  Partner_Agreement__c();
           return agreeObj;
           
       }
    
}