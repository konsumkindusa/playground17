/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 17 October 2013
* @description class that returns a mock response of the SendArticlesToMWImages callout
*/
public class SendArticlesToMWImagesTestMock implements WebServiceMock {
	
	//re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

	public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
           String soapAction,String requestName,String responseNS,String responseName,String responseType){
           	
        	csb.buildIntegrationSetting();
        	//Retrieve Integration setting
        	Integration_Settings__c integrationSetting = [Select Id, Name, Username__c, Password__c, Clientname__c, Endpoint__c, Timeout__c From Integration_Settings__c Where Name = 'Send Articles to MW Answers' limit 1];
        	
        	list <Attachment> attlist = new list <Attachment>();
        	for (Integer i=0;i<5;i++){
	        	Attachment att = new Attachment();
	        	att.Name = 'inlineimage'+i+'.txt';
	        	att.Body = Blob.valueof('inlinetext');
	        	att.ParentId = integrationsetting.Id;
	        	attlist.add(att);
        	}
        	insert attlist;
        	
        	SendArticlesToMWImages.getRichTextImagesResponse_element res = new SendArticlesToMWImages.getRichTextImagesResponse_element();
	       	response.put('response_x', res);
   	}
	
}