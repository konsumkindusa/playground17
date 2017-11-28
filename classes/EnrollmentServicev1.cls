/**
 * @author Original: Haigang Wu - Mathworks
 * @date Original: Jan 24 2017
 * @description: Enrollment REST service.
 * @revision: 
 */ 


@RestResource(urlMapping='/training/v1/enrollments/*')
global with sharing class EnrollmentServicev1 {

	// Process ping request
	public static void processPing() {
        RestContext.response.statuscode= 200;
        RestContext.response.responseBody = Blob.valueOf('{ "message" : "Working" }');
	}   
	 
    @HttpGet
    global static void getEnrollmentbyId(){
        Logger.push('getEnrollmentbyId','EnrollmentServicev1');    
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestRequest request = RestContext.request;
        String EnrollmentId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        // If no id is passed in, consider it is a ping request
        if (String.isBlank(EnrollmentId)) {
        	processPing();
        	Logger.pop();
            return;
        }
        
        // Ping request, ignore cases
    	if (EnrollmentId.toLowerCase() == 'ping') {
        	processPing();
        	Logger.pop();
            return;
    	}
        
        // Query Enrollment
        list<Enrollment__c> enrollList = [
        	SELECT Email__c, Class__c, Enrollment_Status__c, Payment_Method__c, Order_Number__c, PO_Number__c, Seat_Price__c, Source__c, id, Enrollee_Name__r.CDS_Contact_Id__c
        	from Enrollment__c 
        	where Id =:EnrollmentId
    	]; 
    	
    	// If Enrollment not found
    	if (enrollList.isEmpty()) {
            RestContext.response.statuscode= 400;
            RestContext.response.responseBody = Blob.valueOf('{ "errorCode" : "400", "message" : "' + System.Label.Enrollment_not_found + '" }');
        	Logger.pop();
            return;
    	}      

        Enrollment__c enrollObj = enrollList[0];
        
        // Return json of the enrollment
        String strJson = '{ ';
        strJson += '"enrolleeEmail" : "'		+ enrollObj.Email__c + '", ';
        strJson += '"classId" : "' 				+ enrollObj.Class__c + '", ';
        strJson += '"enrollmentStatus" : "' 	+ enrollObj.Enrollment_Status__c + '", ';
        strJson += '"paymentMethod" : "' 		+ enrollObj.Payment_Method__c + '", ';
        strJson += '"orderNum" : "' 			+ enrollObj.Order_Number__c + '", ';
        strJson += '"poNum" : "' 				+ enrollObj.PO_Number__c + '", ';
        strJson += '"cdsContactId" : "' 		+ enrollObj.Enrollee_Name__r.CDS_Contact_Id__c + '", ';
        strJson += '"seatPrice" : "' 			+ enrollObj.Seat_Price__c + '", ';
        strJson += '"source" : "' 				+ enrollObj.Source__c + '", ';
        strJson += '"id" : "' 					+ enrollObj.id + '"';
        strJson += ' }';
        RestContext.response.statuscode= 200;
        RestContext.response.responseBody = Blob.valueOf(strJson);
        Logger.pop();
        return;

    }
    
    @HttpPost
    global static void newenrollments(
      String enrolleeEmail,
      String classId,
      String enrollmentStatus,
      String paymentMethod,
      String orderNum,
      String poNum,
      String cdsContactId,
      String seatPrice,
      String source){
         
        Logger.push('newenrollments','EnrollmentServicev1');    

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestRequest request = RestContext.request;
        String EnrollmentId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        // Ping request
        if (String.isNotBlank(EnrollmentId)) {
	    	if (EnrollmentId.toLowerCase() == 'ping') {
	        	processPing();
	        	Logger.pop();
	            return;
	    	}
        }

        // Validate enrolleeEmail / classId / enrollmentStatus
        if (String.isBlank(enrolleeEmail) || String.isBlank(classId) || String.isBlank(enrollmentStatus)){
            RestContext.response.statuscode= 400;
            RestContext.response.responseBody = Blob.valueOf('{ "errorCode" : "400", "message" : "' + System.Label.Enrollment_Required_Fields + '" }');
            Logger.pop();
            return;
        }

        // Search contactId using email
        GlobalContactSearchController.SearchContactResponse conRes;
          String contactId;
          String CDScontId;
        conRes = GlobalContactSearchController.searchContactByEmail(enrolleeEmail);
        if(conRes.ErrorCode != 'SUCCESS') {
            List<Contact>  contList=[select id, CDS_Contact_Id__c from contact where email=:enrolleeEmail ];
            if (contList!=null && !contList.isEmpty())
            {
                contactId = contList[0].Id;
                CDScontId = contList[0].CDS_Contact_Id__c;
            }
            else
            {
            RestContext.response.statuscode= 400;
            RestContext.response.responseBody = Blob.valueOf('{ "errorCode" : "400", "message" : "' + System.Label.Enrollment_Contact_not_found + '" }');
            Logger.pop();
            return;
        	}
        }
          else if (conRes.ErrorCode == 'SUCCESS')
          {
            contactId= conRes.contactId;
            CDScontId = [SELECT CDS_Contact_Id__c from Contact where Id =: conRes.contactId][0].CDS_Contact_Id__c;
              
          }
        
        // Create new Enrollment__c
        Enrollment__c enrollObj = new Enrollment__c();
        enrollObj.Enrollee_Name__c = contactId;
        enrollObj.Class__c = classid;
        enrollObj.Enrollment_Status__c = enrollmentStatus;
        enrollObj.Payment_Method__c = paymentMethod;
        enrollObj.Order_Number__c = orderNum;
        enrollObj.PO_Number__c = poNum;
        if (String.isNotBlank(seatPrice)) enrollObj.Seat_Price__c = decimal.valueOf(seatPrice);
        enrollObj.Source__c = source;

        String strJson = '';
        try {
            insert enrollObj;
	        // Return json of the enrollment
	        strJson = '{ ';
	        strJson += '"enrolleeEmail" : "'		+ enrolleeEmail + '", ';
	        strJson += '"classId" : "' 				+ classid + '", ';
	        strJson += '"enrollmentStatus" : "' 	+ enrollmentStatus + '", ';
	        strJson += '"paymentMethod" : "' 		+ paymentMethod + '", ';
	        strJson += '"orderNum" : "' 			+ orderNum + '", ';
	        strJson += '"poNum" : "' 				+ poNum + '", ';
	        strJson += '"cdsContactId" : "' 		+ CDScontId + '", ';
	        strJson += '"seatPrice" : "' 			+ seatPrice + '", ';
	        strJson += '"source" : "' 				+ source + '", ';
	        strJson += '"id" : "' 					+ enrollObj.id + '"';
	        strJson += ' }';
	        RestContext.response.statuscode= 201;
	        RestContext.response.responseBody = Blob.valueOf(strJson);

        } catch(DmlException dmlEx) {
            Logger.debugException(dmlEx.getMessage());
            system.debug('****Exception in Enrollment Creation:****'+ dmlEx.getMessage());
            strJson = 'Failure:' + (dmlEx.getMessage().replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,','')).replace(': []', '');
	        RestContext.response.statuscode= 400;
            RestContext.response.responseBody = Blob.valueOf('{ "errorCode" : "400", "message" : "' + strJson + '" }');
            
        } catch(Exception ex) {
            Logger.debugException(ex.getMessage());
            system.debug('****Exception in Enrollment Creation:****'+ ex.getMessage());
            strJson = 'Failure:' + ex.getMessage();
	        RestContext.response.statuscode= 400;
            RestContext.response.responseBody = Blob.valueOf('{ "errorCode" : "400", "message" : "' + strJson + '" }');
        }

        Logger.pop();
        return;
    }

}