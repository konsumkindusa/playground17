/**
 *author Original: Faina Gorelik - MathWorks
 *date Original: 17 September 2017
* description : Utilitiy class to parse ETA with course information to Training Authorization system
 */

public with sharing class ETAUtilityClass {
        public String startDate{get;set;}  
        public String endDate{get;set;}
       //public list<String> courseCodes{get;set;}// original 
    	public set<String> courseCodes;// initilize as a set to make it unique within HTTP json request
    public ETAUtilityClass(){
       
      courseCodes = new Set<String>();
   }
}