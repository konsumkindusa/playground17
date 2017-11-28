/**
 *author Original: Faina Gorelik - MathWorks
 *date Original: 26 July 2017
* description : Utilitiy class to parse BodiService  REST API response
 */
public with sharing class BodiServiceUtilityClass {

    public class Rootboolean{
        public Integer pid {get;set;} 
        public Integer cid {get;set;} 
        public Integer rid {get;set;} 
        public String repoName {get;set;} 
        public String errorMessage {get;set;} 
    }     
    
    public static BodiServiceUtilityClass.Rootboolean getParsedBodiServiceJson(String jsonToParse){
        
        return (BodiServiceUtilityClass.Rootboolean)JSON.deserialize(jsonToParse, BodiServiceUtilityClass.Rootboolean.class);
        
        
    }
    
}