/**
    * @author Original: Sagar Talele - Cloud Sherpas/Mathworks, 
    * @Last Modified by:Abhay Verma
    * @date Original: 16 July 2015, 
    * @LastModified Date : 26 AUG 2015
    * @description    Test Class to check the functionality of Class "UEH_MessageParsingUtils".
    */
    
@isTest
public class UEH_MessageParsingUtilsTest{
     //re-create custom setting test records when running the test class
    static UEH_CustomSettingsBuilder custsettbuild = new UEH_CustomSettingsBuilder();
    
    /*
      @name                  truncateSubjectTest
      @date                  16 July 2015
      @author                Sagar Talele
      @Last Modified by:     Abhay Verma
      @Last Modified Date:   26 AUG 2015
      @param                 none.
      @return                Void. 
      @description           Check the functionality of UEH_MessageParsingUtils Class's Method - truncateSubject 
     */
    
     public static testMethod void truncateSubjectTest(){ 
        String OrganizationId = UserInfo.getOrganizationId();
        //Getting the Reference Id.
         String refId  = 'ref:_'+ UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId) + '._500e08PLSJ:ref';
        
        String maxCharSubject;
         String Subject;
         
        //Loop to insert 256 Char in Subject.
        for(integer i=0; i<=255;i++){
            maxCharSubject = maxCharSubject + i;
        }
        //Loop to insert 32500 Char in Plain Text Body and HTML Body.
        String plaintextadd;
        for(integer i=0;i<=32500;i++){
            plaintextadd = plaintextadd + i;
        }
        Subject =  maxCharSubject + refId;
       
        String testTrunctSub = UEH_MessageParsingUtils.truncateSubject(Subject);
        System.assertEquals(testTrunctSub.length() < 255,true );
        System.assertEquals(testTrunctSub.contains(refId),true);
        
        //Creating Test data for the new Format Thread Id 
        //Getting the Reference Id.
         String newFormatRefId  = 'ref:'+ UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId) + '.500e08PLSJ:ref';
        
        String maxCharSubject1;
        String Subject1;
         
        //Loop to insert 256 Char in Subject.
        for(integer i=0; i<=255;i++){
            maxCharSubject1 = maxCharSubject1 + i;
        }
        
        Subject1 =  maxCharSubject1 + newFormatRefId;
       
        String testTrunctSub1 = UEH_MessageParsingUtils.truncateSubject(Subject1);
        System.assertEquals(testTrunctSub1.length() < 255,true );
        System.assertEquals(testTrunctSub1.contains(newFormatRefId),true);
       
     }
     /*
      @name                 truncateBodyTest
      @date                 20 July 2015
      @author               Sagar Talele
      @Last Modified by:    Abhay Verma
      @Last Modified Date:  26 AUG 2015
      @param                none.
      @return               Void. 
      @description          Check the functionality of UEH_MessageParsingUtils Class's Method - truncateBody 
     */
     public static testMethod void truncateBodyTest(){
         String OrganizationId = UserInfo.getOrganizationId(); 
         //Getting the Reference Id.
         String refId = 'ref:_'+ UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId) + '._500e08PLSJ:ref';
         String plainTextBody;
       
        //Loop to insert 32500 Char in Plain Text Body and HTML Body.
        String plaintextadd;
        //Inserting UEH GeneralSetting 
        custsettbuild.builtUEHGeneralSetting();
		UEHGeneralSetting__c uehGeneralSettings = UEHGeneralSetting__c.getInstance();
        for(long i=0;i<=uehGeneralSettings.Max_Email_Body_Length__c/100;i++){
            plaintextadd = plaintextadd + '0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        }
          
        plainTextBody =  plaintextadd + refId;
        String htmlBody = '<!DOCTYPE html><html><title><h1><p>This s A test mail</p></h1></title><body> ' + plaintextadd + refId +'</body></html>';
        String testTrunctBodyPlainText = UEH_MessageParsingUtils.truncateBody(plainTextBody);
        String testTrunctBodyHtml = UEH_MessageParsingUtils.truncateBody(plainTextBody);
        system.debug('testTrunctBodyPlainText.length()'+testTrunctBodyPlainText.length());
        System.assertEquals(testTrunctBodyPlainText.length() <= uehGeneralSettings.Max_Email_Body_Length__c,true);
        system.assertEquals(testTrunctBodyPlainText.contains(refId),true);
        System.assertEquals(testTrunctBodyHtml.length() <= uehGeneralSettings.Max_Email_Body_Length__c,true);
        system.assertEquals(testTrunctBodyHtml.contains(refId),true);
        
        
        //Creating Test data for the new Format Thread Id.
        String newFormatRefId = 'ref:'+ UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId) + '.500e08PLSJ:ref';
        String plainTextBody1;
       
        //Loop to insert 32500 Char in Plain Text Body and HTML Body.
        String plaintextadd1;
        for(long i=0;i<=uehGeneralSettings.Max_Email_Body_Length__c/100;i++){
            plaintextadd1 = plaintextadd1 + '0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        }
          
        plainTextBody1 =  plaintextadd1 + newFormatRefId;
        String htmlBody1 = '<!DOCTYPE html><html><title><h1><p>This s A test mail</p></h1></title><body> ' + plaintextadd1 + newFormatRefId +'</body></html>';
        String testTrunctBodyPlainText1 = UEH_MessageParsingUtils.truncateBody(plainTextBody1);
        String testTrunctBodyHtml1 = UEH_MessageParsingUtils.truncateBody(plainTextBody1);
        System.assertEquals(testTrunctBodyPlainText1.length() < uehGeneralSettings.Max_Email_Body_Length__c,true);
        system.assertEquals(testTrunctBodyPlainText1.contains(newFormatRefId),true);
        System.assertEquals(testTrunctBodyHtml1.length() < uehGeneralSettings.Max_Email_Body_Length__c,true);
        system.assertEquals(testTrunctBodyHtml1.contains(newFormatRefId),true);
        
        
     }
     /*
      @name              getThreadIDTest
      @date              20 July 2015
      @author            Sagar Talele
      @Last Modified by: Abhay Verma
      @Last Modified Date:26 AUG 2015
      @param             none.
      @return            Void. 
      @description  Check the functionality of UEH_MessageParsingUtils Class's Method - getThreadID
     */
    
     public static testMethod void getThreadIDTest(){
         String OrganizationId = UserInfo.getOrganizationId();
         //Getting the Reference Id.
         String refId = 'ref:_'+ UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId) + '._500e08PLSJ:ref';
         String truncatedThreadId;
       
        //Loop to insert 32500 Char in Plain Text Body and HTML Body.
        String plaintextadd;
        for(integer i=0;i<=32500;i++){
            plaintextadd = plaintextadd + i;
        }
          
        truncatedThreadId =  plaintextadd + refId + 'plaintextadd';
        String testTrunctThreadID = UEH_MessageParsingUtils.getThreadID(truncatedThreadId);
        System.assertEquals(testTrunctThreadID,refId);
        
         //Getting the Reference Id.
         String refIdNewFormat = 'ref:'+ UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId) + '.500e08PLSJ:ref';
         String truncatedNewThreadId;
       
        //Loop to insert 32500 Char in Plain Text Body and HTML Body.
        String plaintextadd1;
        for(integer i=0;i<=32500;i++){
            plaintextadd1 = plaintextadd1 + i;
        }
          
        truncatedNewThreadId =  plaintextadd1 + refIdNewFormat + 'plaintextadd';
        String testNewTrunctThreadID = UEH_MessageParsingUtils.getThreadID(truncatedNewThreadId);
        System.assertEquals(testNewTrunctThreadID,refIdNewFormat);
        
     }
      /*
      @name         getReferenceOrgIDTest
      @date         20 July 2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_MessageParsingUtils Class's Method - getReferenceOrgID
     */
    
    public static testMethod void getReferenceOrgIDTest(){
        //Creating Test Data.
        String OrganizationId1 = '00De00000001234ABC';
        String OrganizationId2 = '00De0000001234ABCD';
        String OrganizationId3 = '00De000001234ABCDE';
        String OrganizationId4 = '00De00001234ABCDEF';
        String OrganizationId5 = '00De0001234ABCDEFG';
        String OrganizationId6 = '00De001234ABCDEFGH';
        String OrganizationId7 = '00De01234ABCDEFGHI';
        String OrganizationId8 = '00De1234ABCDEFGHIJ';
        
        //Asserting if the Org Id will converted into the desire Reference Id.
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest1 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId1);
        System.assertEquals(RefOrgIdTest1,'00De1234');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest2 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId2);
        System.assertEquals(RefOrgIdTest2,'00De1234A');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest3 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId3);
        System.assertEquals(RefOrgIdTest3,'00De1234AB');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest4 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId4);
        System.assertEquals(RefOrgIdTest4,'00De1234ABC');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest5 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId5);
        System.assertEquals(RefOrgIdTest5,'00De1234ABCD');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest6 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId6);
        System.assertEquals(RefOrgIdTest6,'00De1234ABCDE');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest7 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId7);
        System.assertEquals(RefOrgIdTest7,'00De1234ABCDEF');
        UEH_MessageParsingUtils.refOrgId = null;
        String RefOrgIdTest8 = UEH_MessageParsingUtils.getReferenceOrgID(OrganizationId8);
        System.assertEquals(RefOrgIdTest8,'00De1234ABCDEFG');
        UEH_MessageParsingUtils.refOrgId = null;
    }

      /*
      @name                 getKeyPrefixFromThreadIdTest
      @date                 24 July 2015
      @Author Original:     Priyank Saxena - Mathworks
      @Last Modified By :   Abhay Verma
      @Last Modified Date:  26 AUG 2015 
      @param                none.
      @return               Void. 
      @description          Check the functionality of UEH_MessageParsingUtils Class's Method - getKeyPrefixFromThreadId 
     */
    
     public static testMethod void getKeyPrefixFromThreadIdTest(){ 
        
        //Set the valid and Invalid Thread Id.
         String ValidThreadId  = 'ref:_00De0VmMk._500e08PLSJ:ref';
         String InvalidThreadId  = 'ref:_00De0VmMk50e08PLSJ:ref';
         String validThreadId1 = 'ref:00De0VmMk.500e08PLSJ:ref';
         
         String testValidKeyPrefixID = UEH_MessageParsingUtils.getKeyPrefixFromThreadId(ValidThreadId); 
         String testInvalidKeyPrefixID = UEH_MessageParsingUtils.getKeyPrefixFromThreadId(InvalidThreadId); 
         String testValidKeyPrefixID1 = UEH_MessageParsingUtils.getKeyPrefixFromThreadId(validThreadId1);
         
         System.assertEquals(testValidKeyPrefixID.length(),3);
         System.assertEquals(testValidKeyPrefixID,'500');
         
         //Check for invalid ThreadId
         System.assertEquals(testInvalidKeyPrefixID,'');
         
         //Check for the new Pattern ThreadId
         System.assertEquals(testValidKeyPrefixID1,'500');
         System.assertEquals(testValidKeyPrefixID1.length(),3);
         
         
        
       
     }
     
     /*
      @name         getRecordIdFromThreadIdTest
      @date         20 July 2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_MessageParsingUtils Class's Method - getRecordIdFromThreadId
     */
     
     public static testMethod void getRecordIdFromThreadIdTest(){
     
     //Creating Test Data.
     String threadId1 = 'ref:_00De0VmMk._a1Ve0V8iA:ref';
     String threadId2 = 'ref:_00De0VmMk._a1Ve01V8iA:ref';
     String threadId3 = 'ref:_00De0VmMk._a1Ve012V8iA:ref';
     String threadId4 = 'ref:_00De0VmMk._a1Ve0123V8iA:ref';
     String threadId5 = 'ref:_00De0VmMk._a1Ve01234V8iA:ref';
     String threadId6 = 'ref:_00De0VmMk._a1Ve012345V8iA:ref';
     String threadId7 = 'ref:_00De0VmMk._a1Ve0123456V8iA:ref';
     String threadId8 = 'ref:_00De0VmMk._N+O+T_VALID:ref'; //negative case - not a valid thread id
     String threadId9 =  'ref:00De0VmMk.a1VeV8iA:ref';
     String threadId10 = 'ref:00De0VmMk.a1Ve1V8iA:ref';
     String threadId11 = 'ref:00De0VmMk.a1Ve12V8iA:ref';
     String threadId12 = 'ref:00De0VmMk.a1Ve123V8iA:ref';
     String threadId13 = 'ref:00De0VmMk.a1Ve1234V8iA:ref';
     String threadId14 = 'ref:00De0VmMk.a1Ve12345V8iA:ref';
     String threadId15 = 'ref:00De0VmMk.a1Ve123456V8iA:ref';
     String threadId16 = 'ref:00De0VmMk.N+O+T_VALID:ref'; //negative case - not a valid thread id
     String threadId17 = 'ref:00De0VmMk.a1Ve1234567V8iA:ref';
     
     Id RecId1;
     RecId1 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId1);
     //Check for valid Record Id.
     System.assertEquals(RecId1, 'a1Ve0000000V8iAEAS');
     
     Id RecId2;
     RecId2 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId2);
     //Check for valid Record Id.
     System.assertEquals(RecId2, 'a1Ve0000001V8iAEAS');
     
     Id RecId3;
     RecId3 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId3);
     //Check for valid Record Id.
     System.assertEquals(RecId3, 'a1Ve0000012V8iAEAS');
     
     Id RecId4;
     RecId4 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId4);
     //Check for valid Record Id.
     System.assertEquals(RecId4, 'a1Ve0000123V8iAEAS');
     
     Id RecId5;
     RecId5 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId5);
     //Check for valid Record Id.
     System.assertEquals(RecId5, 'a1Ve0001234V8iAEAS');
     
     Id RecId6;
     RecId6 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId6);
     //Check for valid Record Id.
     System.assertEquals(RecId6, 'a1Ve0012345V8iAEAS');
     
     Id RecId7;
     RecId7 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId7);
     //Check for valid Record Id.
     System.assertEquals(RecId7, 'a1Ve0123456V8iAEAS');
     
     Id RecId8;
     RecId8 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId8);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId8, null);
     
     Id RecId9;
     RecId9 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId9);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId9, 'a1Ve0000000V8iAEAS');
     
     Id RecId10;
     RecId10 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId10);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId10, 'a1Ve0000001V8iAEAS');
     
     Id RecId11;
     RecId11 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId11);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId11, 'a1Ve0000012V8iAEAS');
     
     Id RecId12;
     RecId12 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId12);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId12, 'a1Ve0000123V8iAEAS');
     
     Id RecId13;
     RecId13 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId13);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId13, 'a1Ve0001234V8iAEAS');
     
     Id RecId14;
     RecId14 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId14);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId14, 'a1Ve0012345V8iAEAS');
     
     Id RecId15;
     RecId15 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId15);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId15, 'a1Ve0123456V8iAEAS');
     
     Id RecId16;
     RecId16 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId16);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId16, null);
    
    Id RecId17;
     RecId17 = UEH_MessageParsingUtils.getRecordIdFromThreadId(threadId17);
     //Check for null value since input is not a valid thread id
     System.assertEquals(RecId17, null);
    }
    
    /*
      @name         getSFCDReferenceOrgIDTest
      @date         6 oct 2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_MessageParsingUtils Class's Method - getSFDCReferenceOrgID
     */
     
    public static testMethod void getSFDCReferenceOrgIDTest(){
        //Creating Test Data.
        String OrganizationId1 = '00De00000000123ABC';
        String OrganizationId2 = '00De0000000123ABCD';
        String OrganizationId3 = '00De000000123ABCDE';
        String OrganizationId4 = '00De00000123ABCDEF';
        String OrganizationId5 = '00De0000123ABCDEFG';
        String OrganizationId6 = '00De000123ABCDEFGH';
        String OrganizationId7 = '00De00123ABCDEFGHI';
         
        //Asserting if the Org Id will converted into the desire Reference Id.
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest1 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId1);
        System.assertEquals(RefOrgIdTest1,'00De0123');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest2 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId2);
        System.assertEquals(RefOrgIdTest2,'00De0123A');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest3 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId3);
        System.assertEquals(RefOrgIdTest3,'00De0123AB');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest4 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId4);
        System.assertEquals(RefOrgIdTest4,'00De0123ABC');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest5 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId5);
        System.assertEquals(RefOrgIdTest5,'00De0123ABCD');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest6 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId6);
        System.assertEquals(RefOrgIdTest6,'00De0123ABCDE');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        String RefOrgIdTest7 = UEH_MessageParsingUtils.getSFDCReferenceOrgID(OrganizationId7);
        System.assertEquals(RefOrgIdTest7,'00De0123ABCDEF');
        UEH_MessageParsingUtils.refSFDCOrgId = null;
        
    }
    
    /*
      @name         getRecordIdFromSFDCThreadIdTest
      @date         20 July 2015
      @author       Abhay Verma
      @param        none.
      @return       Void. 
      @description  Check the functionality of UEH_MessageParsingUtils Class's Method - getRecordIdFromSFDCThreadId
     */
     
     public static testMethod void getRecordIdFromSFDCThreadIdTest(){
     
         //Creating Test Data.
         String threadId1 = 'ref:_00De0VmMk._500e0V8iA:ref';
         String threadId2 = 'ref:_00De0VmMk._500e01V8iA:ref';
         String threadId3 = 'ref:_00De0VmMk._500e012V8iA:ref';
         String threadId4 = 'ref:_00De0VmMk._500e0123V8iA:ref';
         String threadId5 = 'ref:_00De0VmMk._500e01234V8iA:ref';
         String threadId6 = 'ref:_00De0VmMk._500e012345V8iA:ref';
         String threadId7 = 'ref:_00De0VmMk._500e0123456V8iA:ref';
         String threadId8 = 'ref:_00De0VmMk._N+O+T_VALID:ref'; //negative case - not a valid thread id
         
         
         Id RecId1;
         RecId1 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId1);
         //Check for valid Record Id.
         System.assertEquals(RecId1, '500e0000000V8iAAAS');
         
         Id RecId2;
         RecId2 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId2);
         //Check for valid Record Id.
         System.assertEquals(RecId2, '500e0000001V8iAAAS');
         
         Id RecId3;
         RecId3 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId3);
         //Check for valid Record Id.
         System.assertEquals(RecId3, '500e0000012V8iAAAS');
         
         Id RecId4;
         RecId4 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId4);
         //Check for valid Record Id.
         System.assertEquals(RecId4, '500e0000123V8iAAAS');
         
         Id RecId5;
         RecId5 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId5);
         //Check for valid Record Id.
         System.assertEquals(RecId5, '500e0001234V8iAAAS');
         
         Id RecId6;
         RecId6 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId6);
         //Check for valid Record Id.
         System.assertEquals(RecId6, '500e0012345V8iAAAS');
         
         Id RecId7;
         RecId7 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId7);
         //Check for valid Record Id.
         System.assertEquals(RecId7, '500e0123456V8iAAAS');
         
         Id RecId8;
         RecId8 = UEH_MessageParsingUtils.getRecordIdFromSFDCThreadId(threadId8);
         //Check for null value since input is not a valid thread id
         System.assertEquals(RecId8, null);
     }
     
}