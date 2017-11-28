/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 29 May 2013, Last Modified: 05 June 2013
* @description class that returns a mock of various response of the MW_OnSupport callouts
*/
public class MW_OnSupportTestMock implements WebServiceMock {
	
	public boolean isMockSuccess = false;
	
	public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
           String soapAction,String requestName,String responseNS,String responseName,String responseType){
           	
        	MW_OnSupportUtil.OnSupportResponseType res = new MW_OnSupportUtil.OnSupportResponseType();
       		res.OnSupportResponseBody = new MW_OnSupportUtil.OnSupportResponseBodyType();
       		res.OnSupportResponseHeader = new MW_OnSupportUtil.OnSupportResponseHeaderType();
		
	       	if (isMockSuccess){
	           	res.OnSupportResponseHeader.ErrorCode = 'SUCCESS';
	           	res.OnSupportResponseBody.AccountID = '1-1G82J';
	           	res.OnSupportResponseBody.SupportStatus = 'Yes';
	           	res.OnSupportResponseBody.SupportReason = 'SMS OK:01-Mar-2014';
	       	}
	       	else {
	       		res.OnSupportResponseHeader.ErrorCode = 'error';
	           	res.OnSupportResponseHeader.ErrorReason =  'error';
	       	}
	       	response.put('response_x', res);
			
   	}
   	
}