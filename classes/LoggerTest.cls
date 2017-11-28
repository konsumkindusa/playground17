/*******************************************************************************
* @author         Andre Calimlim
* @date           5.19.2014
* @return         
* @description    Test class for testing the class named 
*                 Logger
*******************************************************************************/
@isTest
public class LoggerTest {

/*******************************************************************************
* @author         Andre Calimlim
* @date           5.19.2014
* @return         
* @description    This test methods creates log exceptions intentionally to check
                  the logger methods of Logger class
* @Revision(s) 
*******************************************************************************/

    static testMethod void testLogger() {
        
        User usr = TestDataBuilder.buildTestUser(1); 
        insert usr;
        System.runAs(usr){
            
           	insert new LogConfig__c(Debug_Record_Type__c='Debug', Exception_Record_Type__c='Exception', Exceptions_Enabled__c=true, Logging_Enabled__c=true);
            
            Test.startTest(); 
            
            //test push method
            Logger.push('createAccount','AccountDML');     
       		Logger.debug('Test debug message');
            //generate exception
            try {
            	insert new Account();
            
            }   
            catch (System.DmlException ex) {
                
            	Logger.debugException(ex); 
                
          
            }
            
            //test pop method
            Logger.pop();
            
			List<Log__c> testLog = [Select ExceptionType__c, Message__c from Log__c];
			System.assertEquals('Test debug message', testLog[0].Message__c);
			System.assert(testLog[1].Message__c.indexOf('fail') > -1);
			
						
			
            Test.stopTest();
            
        }
     
   }
   
}