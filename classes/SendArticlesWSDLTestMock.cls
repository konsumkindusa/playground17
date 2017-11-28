/**
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks
* @date Original: 08 October 2013, Last Modified: 17 October 2013
* @description class that returns a mock response of the SendArticlesWSDL callout
*/
public class SendArticlesWSDLTestMock implements WebServiceMock  {
    
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
           String soapAction,String requestName,String responseNS,String responseName,String responseType){
            
            //SFDCTestWebservice.sayHelloResponse_element res =new SFDCTestWebservice.sayHelloResponse_element();
            SendArticlesWSDL1.KAResponseType res = new SendArticlesWSDL1.KAResponseType();
            res.status = 'OK';
            res.url = 'http://www-external-dev3.mathworks.com/42'; 
            response.put('response_x', res);
    }
}