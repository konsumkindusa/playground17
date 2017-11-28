/**
*author Original: Faina Gorelik
*date Original: 13 September 2017, Last Modified:
*description : Class to handle delegated operations for TrainingAgreementClassRelationship object AtTask 2238455
*/

public class TrainingAgreementClassDML {
 @future (callout=true)
    public static void callMAOTS ( set <id> Set_ETAClass_id){    
  
        Logger.push('CallMAOTS Integration','TrainingAgreementClassDML') ;
        
        string url;
        string bToken;
        string ETALicense;
        string StartDate;
        string EndDate;
        Training_Agreement_Settings__c settings;
        IntegrationUtilityHelper intHelper;
        intHelper=new IntegrationUtilityHelper();  
        // retrieved ETAs to be updated
        List<Enterprise_Training_Agreement__c> talist =[select id,License_ID__c,Term_Start_Date__c,Term_End_Date__c,Classes__c,Grace_Period_End_Date__c from Enterprise_Training_Agreement__c where id in :Set_ETAClass_id];        
        for (Enterprise_Training_Agreement__c agr :talist){
            if (agr.License_ID__c !=null && agr.Term_Start_Date__c!=null && agr.Term_End_Date__c !=null && agr.Classes__c >0){
               ETALicense = agr.License_ID__c;// to be concatinated to url
                // build list of courses to pass to Training Authorization system
               List<Training_Agreement_Class_Relationship__c> courseCodes = [select course_code__c from Training_Agreement_Class_Relationship__c where Enterprise_Training_Agreement__c =: agr.Id ];
               ETAUtilityClass ETAUtil = new ETAUtilityClass();//initilize json parse class
                if (courseCodes.size() >0){ // pass only ETA associated with the at least one class/course
                 //   System.debug('List Size**'+ courseCodes.size());
                  //  List <String> lstCode = new List <String>();// convert list to List string to be able to serialize it
                  //  for (Training_Agreement_Class_Relationship__c lst :courseCodes){
                      //  lstCode.add(lst.Course_Code__c);
                  //  }
                    
                      for (Training_Agreement_Class_Relationship__c lst :courseCodes){
                      // lstCode.add(lst.Course_Code__c);
                      // ETAUtil.courseCodes = new Set<String>();
                        //  System.debug('**Set Size' +ETAUtil.courseCodes.size() );
                     ETAUtil.courseCodes.add(lst.Course_Code__c);
                    }
                   // ETAUtil.courseCodes = lstCode; old code
                    // convert Date format fields to strings 
                    String dateFormatString = 'MM-dd-yyyy';
                    Date TermStartDate = agr.Term_Start_Date__c;             
                    Date TermEndDate = agr.Grace_Period_End_Date__c;
                    Datetime startDt = Datetime.newInstance(TermStartDate.year(),TermStartDate.month(),TermStartDate.day());     
                    Datetime endDt = Datetime.newInstance(TermEndDate.year(),TermEndDate.month(),TermEndDate.day());
                    ETAUtil.startDate = startDt.format(dateFormatString);
                    ETAUtil.endDate = endDt.format(dateFormatString);       
                    String jsonText = JSON.serialize(ETAUtil);
                    integer returnresponse = null;   // added   
                    settings = Training_Agreement_Settings__c.GetInstance();
                    url = settings.MAOTS_Integration__c;
                    Http httpProtocol = new Http();
                    // Create HTTP request 
                    HttpRequest request = new HttpRequest();
                    if(!Test.isRunningTest()){
                        request.setClientCertificateName(intHelper.getCACertIntegration());
                    }
                    request.setHeader('OrganizationID', UserInfo.getOrganizationId()); 
                    request.setHeader('x-mw-authentication', 'LEARN-MATLAB');
                    request.setMethod('PUT');
                    request.setHeader('Content-type', 'application/json');
                    request.setBody(jsonText); //remove comments after TA will add all courses 
                    System.debug('**Json string**'+ jsonText);
                   //  commented for testing only
                   //request.setBody('{"courseCodes": ["gettingstarted"],"startDate": "01-10-2017","endDate": "05-10-2019"}'); 
                   url = url + ETALicense; 
                  // commented use for testing only
                  // url = 'https://sf-ext-msg-dev.mathworks.com/course-manager/service/v1/license-enrollments/100101';

                    request.setEndpoint(url);
                    request.setTimeout(20000);
                    HttpResponse response = httpProtocol.send(request);
                    String jsonData = response.getBody();
                    returnresponse = response.getStatusCode();
                    System.debug('**Response code**' + returnresponse + '**For License Number**' + ETALicense);
                    // for test only
                   // returnresponse = 503;
                    if (returnresponse != 200){
                        Logger.debugException('Course Manager Integration Error.License Number '+ ETALicense +' Response Status Code '+  returnresponse + ' ' +jsonData);
                       // Logger.pop();            

                    }
                    
                }//end if course code size >0
            }// end if validation for eta fields not null before send to Train Authorization
        }// end for trainagreement list to be passed to Training Authorization system 
      
        
       
        
        Logger.pop(); 
    }// end callMAOTS
    
}