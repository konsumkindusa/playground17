/**
    * @author Original: Abhay Verma - Cloud Sherpas/Mathworks, 
    * @Last Modified by:
    * @date Original: 16 July 2015, 
    * @LastModified Date : 
    * @description    Test Class to check the functionality of Class "UEH_MessageCheckingUtils".
                      It filter out the Black Listed and White Listed Email Address Listed in custom Setting 
                      "UEH_Sender_Blacklist" and "UEH_Sender_Whitelist" .
    */
    
@isTest
public class UEH_MessageCheckingUtilsTest{

    //re-create custom setting test records when running the test class
    static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
    
    //re-create custom setting test records when running the test class
    static CustomSettingsBuilder csb = new CustomSettingsBuilder();

   /*
      @name         isPresentInSenderBlackListTest
      @date         16.July.2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_EmailMessageUtils Class's Method - isPresentInBlackList is processing the Email Address 
                    as according to Custom Setting - UEH_CustomSettingsBuilder inorder to prevent unwanted Email Address to process 
                    further.
     */
     public static testMethod void isPresentInSenderBlackListTest(){ 
     
     //Inserting BlackList_Custom_Setting__c 
     custsettbuild.builtUEH_Sender_BlacklistForUniversalEmailHandler();
     
     custsettbuild.builtUEHGeneralSetting();
     
     test.startTest();
     
     //Creating Test Data.
     String emailAddress1 = 'verma.abhay092@gmail.com';
     UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress1);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress1), True);
     
     String emailAddress2 = 'archana@matchtime.com';
     UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress2);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress2), True); 
          
     String emailAddress3 = 'atulitsupport@workgroup.com';
     UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress3);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress3), True);
     
     String emailAddress4 = 'sales@workgroup.com';
     UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress4);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress4), False);
     
     String emailAddress5 = 'archana@gmail.com';
     UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress5);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress5), False); 
          
     String emailAddress6 = 'marker@workgroup.com';
     UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress6);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderBlackList(emailAddress6), False);
     test.stopTest();
     }
     
      /*
      @name         isPresentInSenderWhiteListTest
      @date         16.July.2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_EmailMessageUtils Class's Method - isPresentInWhiteList is processing  
                    the Email Address as according to Custom Setting - UEH_CustomSettingsBuilder to proceeed the white List Members.
     */
   
     public static testMethod void isPresentInSenderWhiteListTest(){ 
     
     //Inserting BlackList_Custom_Setting__c 
     custsettbuild.builtUEH_Sender_WhitelistForUniversalEmailHandler();
     
     test.startTest();
     
     //Creating Test Data.
     String emailAddress1 = 'whiteListuser@servicemail.com';
     UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress1);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress1), True);
     
     String emailAddress2 = 'abhay@matchtime.com';
     UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress2);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress2), True); 
          
     String emailAddress3 = 'atulitsupport@gmail.com';
     UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress3);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress3), True);
     
     String emailAddress4 = 'sales@workgroup.com';
     UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress4);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress4), False);
     
     String emailAddress5 = 'archana@outlook.com';
     UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress5);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress5), False); 
          
     String emailAddress6 = 'usernotexist@workgroup.com';
     UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress6);
     System.assertEquals(UEH_MessageCheckingUtils.isPresentInSenderWhiteList(emailAddress6), False);
     test.stopTest();
     } 
    
     /*
      @name         isInboundEmailSpamIfTrueTest
      @date         30.July.2015
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_EmailMessageUtils Class's Method - isInboundEmailSpam 
     */
     public static testMethod void isInboundEmailSpamIfTrueTest(){ 
     
        //Inserting UEHMessageCheckingSettings__c 
        custsettbuild.builtUEHMessageCheckingSettings(); 
         
        test.startTest();
         
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
		//Fetching data from UEH General setting
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        //Creating Messaging.InboundEmail and Messaging.InboundEnvelope test data.
        Messaging.InboundEmail inboundEmailMessage = new Messaging.InboundEmail();
        inboundEmailMessage.FromAddress = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.plainTextBody = 'Email plain Text Body Test for less than ' + uehGeneralSettings.Max_Email_Body_Length__c + ' Char ' + refId;
        inboundEmailMessage.htmlBody = '<html><title>This s A test mail</title><body>Hi i am ' + refId + ' here.</body></html>';
        inboundEmailMessage.ToAddresses = new String[] {'person@gmail.com'};
        inboundEmailMessage.CCAddresses = new String[] {'user@gmail.com'};
        inboundEmailMessage.fromName = 'User Name';
        inboundEmailMessage.htmlBodyIsTruncated = False;
        inboundEmailMessage.replyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.inReplyTo = 'personemailfromaddress@gmail.com';
        inboundEmailMessage.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        inboundEmailMessage.plainTextBodyIsTruncated = False;
        inboundEmailMessage.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
            
        // Creating Envelope Data    
        Messaging.InboundEnvelope envelopeObj = new Messaging.InboundEnvelope();
        envelopeObj.toAddress = 'personenvelope1toaddress@gmail.com';
        envelopeObj.FromAddress = 'personenvelopefromaddress@gmail.com';
            
        Id emailLogId = UEH_MessageLoggingUtils.CreateInBoundEmailLog(inboundEmailMessage, envelopeObj, 'Accepted','');
        UEH_Inbound_Email_Log__c eLogObj = [SELECT Id FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId];
        System.assertEquals(emailLogId, eLogObj.Id);
         
        Id emailLogId2 = UEH_MessageLoggingUtils.CreateInBoundEmailLog(inboundEmailMessage, envelopeObj, 'Accepted','');
        UEH_Inbound_Email_Log__c eLogObj2 = [SELECT Id FROM UEH_Inbound_Email_Log__c WHERE Id =:emailLogId2];
        System.assertEquals(emailLogId2, elogObj2.Id);
        
        System.assert(UEH_MessageCheckingUtils.isInboundEmailSpam(inboundEmailMessage));
        
        test.stopTest();
        
     }
    
     /*
      @name         isInboundEmailSpamIfFalseTest
      @date         30.July.2015
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_EmailMessageUtils Class's Method - isInboundEmailSpam 
     */
     public static testMethod void isInboundEmailSpamIfFalseTest(){ 
     
        //Inserting UEHMessageCheckingSettings__c 
        custsettbuild.builtUEHMessageCheckingSettings(); 
         
        test.startTest();
         
        // Creating Email for Excessing Char Limit Body and Subject        
        Messaging.InboundEmail excessCharEmailObj= new Messaging.InboundEmail();
         
        String refOrgId = userInfo.getOrganizationId();
        String refId = UEH_MessageParsingUtils.getReferenceOrgID(refOrgId);
         
        Integer i=0;
        String maxCharSubject;
        
        //Loop to insert 256 Char in Subject.
        for(i=0; i<=255;i++){
            maxCharSubject = maxCharSubject + i;
        }
       //Loop to insert 32500 Char in Plain Text Body and HTML Body.
        String plaintextadd;
        for(i=0;i<=33000;i++){
            plaintextadd = plaintextadd + i;
        }
        excessCharEmailObj.Subject = maxCharSubject + refId;
        excessCharEmailObj.FromAddress = 'excesscharpersonemailfromaddress@gmail.com';
        excessCharEmailObj.plainTextBody = 'Email Message Body' + plaintextadd + refId;
        excessCharEmailObj.htmlBody = '<!DOCTYPE html><html><title><h1><p>This s A test mail</p></h1></title><body> ' + plaintextadd + refId +'</body></html>';
        excessCharEmailObj.ToAddresses = new String[] {'personexcess@gmail.com'};
        excessCharEmailObj.CCAddresses = new String[] {'userexcess@gmail.com'};
        excessCharEmailObj.fromName = 'User Name Excess';
        excessCharEmailObj.htmlBodyIsTruncated = True;
        excessCharEmailObj.replyTo = 'excesscharpersonemailfromaddress@gmail.com';
        excessCharEmailObj.inReplyTo = 'excesscharpersonemailfromaddress@gmail.com';
        excessCharEmailObj.messageId = 'CA+aKGioNtsLN_TJ5t9pdG8JyGMbuzVVCoOr2bjBPaSMc9j=OLw@mail.gmail.com';
        excessCharEmailObj.plainTextBodyIsTruncated = True;
        excessCharEmailObj.references = new String[] {'CA+aKGirmwQ=JueoBbZHER0RFaNSQALnNi9gqffw+VtJS0sy_aw@mail.gmail.com'};
        
        System.assert(!UEH_MessageCheckingUtils.isInboundEmailSpam(excessCharEmailObj));
        
        test.stopTest();
        
     }
    
    /*
      @name         isValidThreadIdTest
      @date         7.August.2015
      @author       Archana Lohar
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_EmailMessageUtils Class's Method - isValidThreadId 
     */
     public static testMethod void isValidThreadIdTest(){ 
     
        test.startTest();
         
        //re-create Bypass Trigger Custom Setting
        csb.buildBypassTriggerSettings();
        
        Case cseObj = TestDataBuilder.buildTestCase('Open');
        Insert cseObj;
        
        String recId = String.valueOf(cseObj.id);
        
        //Positive Test when Thread id is valid
        system.assert(UEH_MessageCheckingUtils.isValidThreadId('ref:_'+UEH_MessageParsingUtils.getReferenceOrgID(UserInfo.getOrganizationId())+'._'+recId.SubString(0,recId.length()-3)+':ref'));
        
        //Positive Test when Thread id is not valid
        system.assert(!UEH_MessageCheckingUtils.isValidThreadId('ref:_00De0VmMk._500e08PLSJ:ref'));
        
        test.stopTest();
        
     }
}