/**
* @author Original: Krishna Bhaskarla
* @date Original: 10 Feb 2014 
* @Desc: Securing customer artifacts webservice. Webservice is called by Sharepoint to get all the Case and email attachment details to be secured.
*/

global class SecureArtifactsWS {
		
	//webservice operation
	webService static list<Artifacts> getSecureArtifacts(Integer Hour, Integer Days){
		list<Artifacts> secureArtifacts = new list<Artifacts>();
		
		list<Case> caseList = new list<Case>();
		Set<Id> caseIdSet = new Set<Id>();
		Map<id,Case> caseMap;
		Map<id,Contact> contactMap;
		Map<id,Account> accountMap;
		list<Id> contactIdList = new list<Id>();
		Map<Id,EmailMessage> emailMap;
		 
		/* Get cases metadata and attachments on cases not sent to Sharepoint 
		   Get cases and attachments modified in last 'n' hours */
		if (Hour > 0){
			Datetime ct = system.now();
			DateTime dt = ct.addHours(-Hour);
			system.debug('@@@###CurrentTime:'+ct);
			system.debug('@@@###DateTime:'+dt);
			//caseList = [Select Sub_Area__c, Id, ContactId, CaseNumber, Area__c From Case where (lastmodifieddate > :dt and issecured__c != true) and (area__c like '%Advanced%' or area__c like '%Technical%' or area__C like '%Premier%' ) and sub_area__c != null];
			caseMap = new Map<id,Case>([
				Select 
					Sub_Area__c, Id, ContactId, CaseNumber, Area__c, AccountId, 
					(Select Id, Name, ContentType From Attachments where NOT Description like '%http%'),
					(select Id from EmailMessages where hasattachment = true) 
				From 
					Case 
				where 
					(lastmodifieddate > :dt and issecured__c != true) 
				and 
					(area__c like '%Advanced%' or area__c like '%Technical%' or area__C like '%Premier%' ) 
				and
					sub_area__c != null
				and
					(Contact.Country_Code__c != null or (Status = 'Closed' and issecured__c != true) ) 
			]);
			caseIdSet = caseMap.keySet();
			caseList = caseMap.values();	
		}
		/* Get cases and attachments modified in last 'n' days */
		if(Days > 0){
			system.debug('@@@### No.Of Days: '+Days);
			Date startDate = Date.today().addDays(-Days);
			system.debug('@@@### startdate: '+startDate);
			caseMap = new Map<id,Case>([
				Select 
					Sub_Area__c, Id, ContactId, CaseNumber, Area__c, AccountId, 
					(Select Id, Name, ContentType From Attachments where NOT Description like '%http%'),
					(select Id from EmailMessages where hasattachment = true) 
				From 
					Case 
				where 
					(lastmodifieddate >= :startDate and issecured__c != true) 
				and 
					(area__c like '%Advanced%' or area__c like '%Technical%' or area__C like '%Premier%' ) 
				and 
					sub_area__c != null
				and
					(Contact.Country_Code__c != null or (Status = 'Closed' and issecured__c != true) ) 
			]);
			caseIdSet = caseMap.keySet();
			caseList = caseMap.values();			
		}
		
		if(caseMap.size()==0){
			return secureArtifacts;
		}
		
		/*Get Contact Id and countrycode for all case id in the set. */
		contactMap = new Map<Id,Contact>([Select Id, Country_Code__c From Contact where Id IN (select contactid from case where Id IN :caseIdSet)]);
		system.debug('@@@### Contact length:'+contactMap.size());
		system.debug('@@@### Cases Map length:'+caseMap.size());
		/*Get account details */
		accountMap = new Map<Id,Account>([Select Id, Name From Account where id IN (select accountId from case where Id IN :caseIdSet)]);	
		system.debug('@@@### Account length:'+accountMap.size());
		
		/* Get inbound and outbound emails with attachments */
		emailMap = new Map<Id, EmailMessage>([select e.Id, e.incoming,(Select Id, Name, ContentType From Attachments where NOT Description like '%http%') from EmailMessage e where e.parentId IN :caseIdSet and e.hasattachment = true and e.status != '5']);
		system.debug('@@@### Email Map length:'+emailMap.size());
		
		/*Construct SOAP response payload */
		for(Case caseObj : caseList){
			list<Attachment> CaseAttList = new list<Attachment>();
			list<EmailMessage> EmailAttList = new list<EmailMessage>();
			Artifacts bean = null;
			Boolean flag = true;
			/*For each case get case attachment list*/
			CaseAttList = caseObj.Attachments;
			/*For each case get Email List*/
			EmailAttList = caseObj.EmailMessages;
			system.debug('@@@### Case Att List:'+CaseAttList.size());
			system.debug('@@@### Email Att List:'+EmailAttList.size());
								
			if(CaseAttList.size() > 0){
			    /*Get Response object with case metadata and country code*/
				bean = getCaseDetails(caseObj,contactMap, accountMap);
				flag = false;
				if(CaseAttList.size()> 0){
					/*Set case attachments to the response object*/
					bean.CaseArtifact.addAll(CaseAttList);
				}
			}
			if(EmailAttList.size()>0){
				for(EmailMessage em: EmailAttList){
					if(emailMap.containsKey(em.Id)){
					    EmailMessage email = emailMap.get(em.Id);
					    if(email.Attachments.size() > 0){
					    	system.debug('@@@###In email list');
					    	if(flag){
					    		system.debug('@@@###In email flag');
					    		flag = false;
					    		bean = getCaseDetails(caseObj,contactMap, accountMap);
					    	}
					       /*Set email attachments to the response object*/
					       bean.EmailArtifact.add(email);	
					    }
					}
				}
			}
			    if (bean != null){
			    	secureArtifacts.add(bean);
			    }
				
		}
			
		
		
		
	
		/* Return response object as a SOAP response payload */
		return secureArtifacts;
		
	}
	/* Get Attachments By Parent Type. i.e;;, Case, email or Activity */
	public static list<Attachment> getAttachments(Id id){
		list<Attachment> att = [SELECT Id,Name,ContentType FROM Attachment where parentId  =: id];
		system.debug('@@@### att length' +att.size());
		return att;
	} 
	
	
	/*Method to get case metadata and has login to determine country code.*/
	private static Artifacts getCaseDetails(Case c, Map<Id,Contact> contactMap, Map<Id,Account> accountMap){
		Artifacts art = new Artifacts();
		art.CaseId = c.Id;
		art.CaseNumber = c.CaseNumber;
		art.Area = c.Area__c;
		art.Subarea = c.Sub_Area__c;
		system.debug('@@@### contactId' +c.ContactId);
		if(c.AccountId !=null ){
			Account acc = accountMap.get(c.AccountId);
			if(acc !=null){
				art.AccountId = c.AccountId;
				art.AccountName = acc.Name;
			}
		}
		if(c.ContactId == null){
			art.CountryCode = 'US';
		}
		else{
			Contact contact = contactMap.get(c.ContactId);
			if(contact != null){
				if(contact.Country_Code__c !=null ){
					art.CountryCode = contact.Country_Code__c;
				}
				else {
					art.CountryCode = 'US';
				}
			}
			
			
		}
		return art;
						
	}

    //HW 1207062
	webService static list<DeleteArtifactsResponse> deleteArtifacts(Integer Days){
		list<DeleteArtifactsResponse> delArtifactsList = new list<DeleteArtifactsResponse>();
		list<Case> caseList = new list<Case>();
		 
		/* Get cases and attachments modified in last 'n' days */
		if(Days > 0){
			system.debug('@@@### No.Of Days: '+Days);
			Date startDate = Date.today().addDays(-Days);
			system.debug('@@@### startdate: '+startDate);
			caseList = [
				Select 
					Id, CaseNumber 
				From 
					Case 
				where 
					Status = 'Closed'
				and
					ClosedDate <= :startDate 
				and 
					isSecured__c = true
					//Attachments_Folder__c like '%http%'
				limit 10000
			];
		}
		
		if(caseList.size()==0)
			return delArtifactsList;
		
		/*Construct SOAP response payload */
		for(Case caseObj : caseList) {
			DeleteArtifactsResponse delArtifactsObj = new DeleteArtifactsResponse();
			delArtifactsObj.CaseId = caseObj.Id;
			delArtifactsObj.CaseNumber = caseObj.CaseNumber;
			delArtifactsList.add(delArtifactsObj);
		}
		return delArtifactsList;
	}

	global class DeleteArtifactsResponse {
	 
	 webservice	String CaseId;
	 webservice String CaseNumber;
	 //webservice list<String> urlList = new list<String>();
	 //webservice list<String> idList = new list<String>();
	 
     public DeleteArtifactsResponse() {}
	}



	/*Response Object*/
	global class Artifacts {
	 
	 webservice	String CaseId;
	 webservice String CaseNumber;
	 webservice	String CountryCode;
	 webservice	String Area;
	 webservice	String Subarea;
	 webservice	String AccountId;
	 webservice	String AccountName;
	 webservice list<Attachment> CaseArtifact = new list<Attachment>();
	 webservice list<EmailMessage> EmailArtifact = new list<EmailMessage>();
	 
	 /**
     * An empty constructor
     */
     public Artifacts() {}
 
    
	}
  
    //HW 1207062
    /*
	webService static list<DeleteArtifactsResponse> deleteArtifacts(Integer Days){
		list<DeleteArtifactsResponse> delArtifactsList = new list<DeleteArtifactsResponse>();
		list<Case> caseList = new list<Case>();
		Set<Id> caseIdSet = new Set<Id>();
		Map<id,Case> caseMap;
		Map<Id,EmailMessage> emailMap;
		 
		// Get cases and attachments modified in last 'n' days
		if(Days > 0){
			system.debug('@@@### No.Of Days: '+Days);
			Date startDate = Date.today().addDays(-Days);
			system.debug('@@@### startdate: '+startDate);
			caseMap = new Map<id,Case>([
				Select 
					Id, CaseNumber, 
					(Select Id, Description From Attachments where Description like '%http%'),
					(select Id from EmailMessages where hasattachment = true) 
				From 
					Case 
				where 
					Status = 'Closed'
				and
					ClosedDate <= :startDate 
				and 
					Attachments_Folder__c like '%http%'
				limit 10000
			]);
			caseIdSet = caseMap.keySet();
			caseList = caseMap.values();			
		}
		
		if(caseMap.size()==0){
			return delArtifactsList;
		}
		
		// Get inbound and outbound emails with attachments
		emailMap = new Map<Id, EmailMessage>([
			select 
				e.Id,
				(Select Id, Description From Attachments where Description like '%http%') 
			from 
				EmailMessage e 
			where 
				e.parentId IN :caseIdSet 
			and 
				e.hasattachment = true 
		]);
		system.debug('@@@### Email Map length:'+emailMap.size());
		
		//Construct SOAP response payload
		for(Case caseObj : caseList) {
			DeleteArtifactsResponse delArtifactsObj = new DeleteArtifactsResponse();
			delArtifactsObj.CaseId = caseObj.Id;
			delArtifactsObj.CaseNumber = caseObj.CaseNumber;
			
			for (Attachment att : caseObj.Attachments) {
				delArtifactsObj.urlList.add(att.Description);
				delArtifactsObj.idList.add(att.Id);
			}
			
			for (EmailMessage em : caseObj.EmailMessages) {
				for (Attachment att : emailMap.get(em.Id).Attachments) {
					delArtifactsObj.urlList.add(att.Description);
					delArtifactsObj.idList.add(att.Id);
				}
			}
			
			delArtifactsList.add(delArtifactsObj);
		}
	
		// Return response object as a SOAP response payload
		return delArtifactsList;
		
	}

  */
		
}
// OLD Code 
		
		
		/*for(Case caseObj : caseList){
			
			// Get case Attachments.
			list<Attachment> att = getAttachments(caseObj.Id);
			system.debug('@@@### length of case Attachments:' +att.size());
		    
			// Get email attachments.
			list<EmailMessage> emailList = [select e.Id, e.incoming,(Select Id, Name, ContentType From Attachments) from EmailMessage e where e.parentId = : caseObj.Id and e.hasattachment = true ];
			system.debug('@@@###emailList'+emailList.size());
			
			if(att.size()>0 || emailList.size()>0){
				// Get case and Contact Info.
				bean = getCaseDetails(caseObj);
				if( att.size() > 0){
					bean.CaseArtifact.addAll(att);
				}
				if(emailList.size() > 0){
					bean.EmailArtifact.addAll(emailList);
				}
				secureArtifacts.add(bean);
			}
		}*/
		
		
		/*// Get Case Attachments.
			attachments = SecureArtifactsWS.getAttachments(CASEINFO);
			artifactsMap = SecureArtifactsWS.buildSecureArtifacts(CASEINFO,artifactsMap,attachments);
			secureArtifacts = artifactsMap.values();
			
	    // Get Case inbound email Attachments
						
	
		/*bean.CaseNumber = '12345';
		Attachment[] artifact;
		artifact = [SELECT ParentId,Id FROM Attachment where ParentId='500e0000001dPJRAA2'];
		bean.artifacts = artifact;
		secureArtifacts.add(bean); */
		
		
		/*	private static map<String, Artifacts> buildSecureArtifacts(String obj, map <String, Artifacts> artifactsMap,list<Attachment> attList){
		//Build Case Attachments
		list<Artifacts> artList = new list<Artifacts>();
		if (obj == CASEINFO){			
			for(Attachment att : attList){
				String pId = att.ParentId;
				system.debug('@@@### parentId:' +pId);
				if(artifactsMap.containskey(pId)){
					system.debug('@@@### Case contains multiple attachments');
					system.debug('@@@###'+artifactsMap);
					Artifacts art = artifactsMap.get(pId);
					system.debug('@@@###'+art);
					art.ArtifactMetadata.add(att);
					artifactsMap.put(pId,art);
										
				} else{
					list<Case> caseObj = [Select Sub_Area__c, Id, ContactId, CaseNumber, Area__c From Case WHERE Id = :pId limit 1];
					system.debug('@@@### caseObj length' +caseObj);
					Artifacts art = getCaseDetails(caseObj[0], att);
					artifactsMap.put(pId,art);
					
				}
			}
			
		}
		if (obj == EMAIL){
			list<EmailMessage> emailList = [Select ParentId From EmailMessage where Incoming=true and Id IN :attList];
					}
		return artifactsMap;
	} */
	
	/*list<Contact> contact = [Select Id, Country_Code__c From Contact where Id = :c.ContactId limit 1 ];
			if(contact[0].Country_Code__c != null){
				art.CountryCode = contact[0].Country_Code__c;
			} else {
				art.CountryCode = 'US';
			} */