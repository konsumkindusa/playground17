/**
 *@author Original: Abhay Verma - Cloud Sherpas/Mathworks, Last Modified: Haigang Wu - Mathworks
 *@date Original: 3 July 2015, 
 *@Last Modified: 20 July 2016
 *@description : Global utility class that contains different record builders for Universal Email Handler(UEH) custom setting.
 */

public class UEH_CustomSettingsBuilder{

    /*
   *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
   *@Last Modified:   Abhay Verma - Cloud Sherpas/Mathworks 
   *@Date Original:   3 July 2015
   *@Last Modified:   
   *@Description:     Inserting the email address from Universal Email Handler and will check
                      inbound email messages against custom setting containing list of complete, 
                      Starts With, End With email addresses in order to prevent unwanted messages 
                      from being further processed.    
   */ 

    public void builtUEH_Sender_BlacklistForUniversalEmailHandler(){
    
    UEH_Sender_Blacklist__c senderBlacklistForUniversalEmailHandler = new UEH_Sender_Blacklist__c();
    senderBlacklistForUniversalEmailHandler.Name = 'BEA1';
    senderBlacklistForUniversalEmailHandler.Email_Address__c = 'verma.abhay092@gmail.com';
    senderBlacklistForUniversalEmailHandler.Match_Type__c = 'Exact';
    insert senderBlacklistForUniversalEmailHandler;
    
    UEH_Sender_Blacklist__c senderBlacklistForUniversalEmailHandler1 = new UEH_Sender_Blacklist__c();
    senderBlacklistForUniversalEmailHandler1.Name = 'BEA2';
    senderBlacklistForUniversalEmailHandler1.Email_Address__c = 'matchtime.com';
    senderBlacklistForUniversalEmailHandler1.Match_Type__c = 'Domain';
    insert senderBlacklistForUniversalEmailHandler1;
    
    UEH_Sender_Blacklist__c senderBlacklistForUniversalEmailHandler2 = new UEH_Sender_Blacklist__c();
    senderBlacklistForUniversalEmailHandler2.Name = 'BEA3';
    senderBlacklistForUniversalEmailHandler2.Email_Address__c = 'atulitsupport';
    senderBlacklistForUniversalEmailHandler2.Match_Type__c = 'Username';
    insert senderBlacklistForUniversalEmailHandler2;
      
    }
    
  /*
   *@Author Original: Abhay Verma - Cloud Sherpas/Mathworks 
   *@Last Modified:   11 August 2015 
   *@Date Original:   7 July 2015   
   *@Description:     Creating test data from Universal Email Handler and inbound email messages against 
                      custom setting containing list of complete, Starts With, End With email addresses 
                      in order to proceed them further.
   */ 
    
    public void builtUEH_Sender_WhitelistForUniversalEmailHandler(){
        
        UEH_Sender_Whitelist__c senderWhiteListForUniversalEmailHandler1 = new UEH_Sender_Whitelist__c();
        senderWhiteListForUniversalEmailHandler1.Name = 'WLEA1';
        senderWhiteListForUniversalEmailHandler1.Email_Address__c = 'whiteListuser@servicemail.com';
        senderWhiteListForUniversalEmailHandler1.Match_Type__c = 'Exact';
        insert senderWhiteListForUniversalEmailHandler1;
 
        
        UEH_Sender_Whitelist__c senderWhiteListForUniversalEmailHandler2 = new UEH_Sender_Whitelist__c();
        senderWhiteListForUniversalEmailHandler2.Name = 'WLEA2';
        senderWhiteListForUniversalEmailHandler2.Email_Address__c = 'abhay';
        senderWhiteListForUniversalEmailHandler2.Match_Type__c = 'Username';
        insert senderWhiteListForUniversalEmailHandler2;
        
        UEH_Sender_Whitelist__c senderWhiteListForUniversalEmailHandler3 = new UEH_Sender_Whitelist__c();
        senderWhiteListForUniversalEmailHandler3.Name = 'WLEA3';
        senderWhiteListForUniversalEmailHandler3.Email_Address__c = 'gmail.com';
        senderWhiteListForUniversalEmailHandler3.Match_Type__c = 'Domain';
        insert senderWhiteListForUniversalEmailHandler3;
        
                   
        UEH_Sender_Whitelist__c senderWhiteListForUniversalEmailHandler4 = new UEH_Sender_Whitelist__c();
        senderWhiteListForUniversalEmailHandler4.Name = 'WLEA4';
        senderWhiteListForUniversalEmailHandler4.Email_Address__c = 'supportTest@mathworks.com';
        senderWhiteListForUniversalEmailHandler4.Match_Type__c = 'Exact';
        insert senderWhiteListForUniversalEmailHandler4;
    
    }
    
    /*
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
   *@Date Original:   16 July 2015
   *@Last Modified:   Haigang Wu - Mathworks
   *@Last Modified:   20 July 2016 
   *@Description:     Creating test data from Universal Email Handler i.e
                      custom setting containing Mapping of recipient email addresses to the 
                      appropriate handler class for new messages in order to proceed them further.
   */ 
    
    public void builtUEH_Recipient_Module_Handler(){
        
        UEH_Recipient_Module_Handler__c handlerRecord1 = new UEH_Recipient_Module_Handler__c();
        handlerRecord1.Name = 'test';
        handlerRecord1.Module_Handler_Class__c = 'EmailHandler_Case';
        handlerRecord1.Module_Name__c = 'Cases';
        handlerRecord1.Recipient_Email_Address__c = 'support@mathworks.com';
        insert handlerRecord1;  
        
        UEH_Recipient_Module_Handler__c handlerRecord2 = new UEH_Recipient_Module_Handler__c();
        handlerRecord2.Name = 'test2';
        handlerRecord2.Module_Handler_Class__c = 'SampleEmailToSObjectModuleHandler';
        handlerRecord2.Module_Name__c = 'SampleClass';
        handlerRecord2.Recipient_Email_Address__c = 'supportTest@mathworks.com';
        insert handlerRecord2;  
        
        UEH_Recipient_Module_Handler__c handlerRecord3 = new UEH_Recipient_Module_Handler__c();
        handlerRecord3.Name = 'test3';
        handlerRecord3.Module_Handler_Class__c = 'UEH_EmailToPartnerAgreementModuleHandler';
        handlerRecord3.Module_Name__c = 'UEH_EmailToPartnerAgreementModuleHandler';
        handlerRecord3.Recipient_Email_Address__c = 'partnerAgree@mathworks.co.jp';
        insert handlerRecord3; 
        
        UEH_Recipient_Module_Handler__c handlerRecord4 = new UEH_Recipient_Module_Handler__c();
        handlerRecord4.Name = 'test4';
        handlerRecord4.Module_Handler_Class__c = 'UEH_EmailToBookProjectModuleHandler';
        handlerRecord4.Module_Name__c = 'UEH_EmailToBookProjectModuleHandler';
        handlerRecord4.Recipient_Email_Address__c = 'bookprogram@mathworks.co.jp';
        insert handlerRecord4; 
        
        UEH_Recipient_Module_Handler__c handlerRecord5 = new UEH_Recipient_Module_Handler__c();
        handlerRecord5.Name = 'test5';
        handlerRecord5.Module_Handler_Class__c = 'UEH_EmailToBookProjectModuleHandler';
        handlerRecord5.Module_Name__c = 'UEH_EmailToBookProjectModuleHandler';
        handlerRecord5.Recipient_Email_Address__c = 'bookprogram@mathworks.com';
        insert handlerRecord5;
        
        UEH_Recipient_Module_Handler__c handlerRecord6 = new UEH_Recipient_Module_Handler__c();
        handlerRecord6.Name = 'test6';
        handlerRecord6.Module_Handler_Class__c = 'UEH_EmailToAcademicSupportModuleHandler';
        handlerRecord6.Module_Name__c = 'UEH_EmailToAcademicSupportModuleHandler';
        handlerRecord6.Recipient_Email_Address__c = 'AcademicSupport@mathworks.co.jp';
        insert handlerRecord6; 
        
        UEH_Recipient_Module_Handler__c handlerRecord7 = new UEH_Recipient_Module_Handler__c();
        handlerRecord7.Name = 'test7';
        handlerRecord7.Module_Handler_Class__c = 'UEH_EmailToAcademicSupportModuleHandler';
        handlerRecord7.Module_Name__c = 'UEH_EmailToAcademicSupportModuleHandler';
        handlerRecord7.Recipient_Email_Address__c = 'AcademicSupport@mathworks.com';
        insert handlerRecord7;
        
        UEH_Recipient_Module_Handler__c handlerRecord8 = new UEH_Recipient_Module_Handler__c();
        handlerRecord8.Name = 'test8';
        handlerRecord8.Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord8.Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord8.Recipient_Email_Address__c = 'devconnections@2oai7diuwem4by36gqiecvcja5czedbli67er60swokxdxm8ch.e-5vmmkeak.cs15.apex.sandbox.salesforce.com';
        insert handlerRecord8;
        
        UEH_Recipient_Module_Handler__c handlerRecord9 = new UEH_Recipient_Module_Handler__c();
        handlerRecord9.Name = 'test9';
        handlerRecord9.Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord9.Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord9.Recipient_Email_Address__c = 'devconnections@2oai7diuwem4by36gqiecvcja5czedbli67er60swokxdxm8ch.e-5vmmkeak.cs15.apex.sandbox.salesforce.com';
        insert handlerRecord9 ;
        
        UEH_Recipient_Module_Handler__c handlerRecord10 = new UEH_Recipient_Module_Handler__c();
        handlerRecord10.Name = 'test10';
        handlerRecord10.Module_Handler_Class__c = 'UEH_fakehandler';
        handlerRecord10.Module_Name__c = 'UEH_fakehandler';
        handlerRecord10.Recipient_Email_Address__c = 'fakeadress@mathwork.com';
        insert handlerRecord10 ;
        
        UEH_Recipient_Module_Handler__c handlerRecord11 = new UEH_Recipient_Module_Handler__c();
        handlerRecord11 .Name = 'test11';
        handlerRecord11 .Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord11 .Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord11 .Recipient_Email_Address__c = 'emailhandler@36alpdiwf1kcv419ekqhc9bmprxuzkzvqsg8xlwuxjakeq4ypf.e-ntkseae.el.apex.sandbox.salesforce.com';
        insert handlerRecord11 ;
        
        
        UEH_Recipient_Module_Handler__c handlerRecord12 = new UEH_Recipient_Module_Handler__c();
        handlerRecord12 .Name = 'test12';
        handlerRecord12 .Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord12 .Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord12 .Recipient_Email_Address__c = 'emailhandler@7xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';
        insert handlerRecord12 ;
        
        UEH_Recipient_Module_Handler__c handlerRecord13 = new UEH_Recipient_Module_Handler__c();
        handlerRecord13 .Name = 'test13';
        handlerRecord13 .Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord13 .Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord13 .Recipient_Email_Address__c = 'emailhandler@0xgmlke5epfdooetc0r7kypwf48ke9k8g124x4awyvi4bu7kq.e-ntkseae.el.apex.sandbox.salesforce.com';
        insert handlerRecord13 ;
        
        UEH_Recipient_Module_Handler__c handlerRecord14 = new UEH_Recipient_Module_Handler__c();
        handlerRecord14 .Name = 'test14';
        handlerRecord14 .Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord14 .Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord14 .Recipient_Email_Address__c = 'EmailToCase@testServiceUnlisted.com';
        insert handlerRecord14 ;
        
        UEH_Recipient_Module_Handler__c handlerRecord15 = new UEH_Recipient_Module_Handler__c();
        handlerRecord15 .Name = 'test15';
        handlerRecord15 .Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord15 .Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord15 .Recipient_Email_Address__c = 'EmailToCase@NotGeneric.com';
        insert handlerRecord15 ;
    
        UEH_Recipient_Module_Handler__c handlerRecord16 = new UEH_Recipient_Module_Handler__c();
        handlerRecord16 .Name = 'test16';
        handlerRecord16 .Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord16 .Module_Name__c = 'UEH_EmailToCaseHandler';
        handlerRecord16 .Recipient_Email_Address__c = 'NotInRoutingRule@NotGeneric.com';
        insert handlerRecord16 ;
        
        UEH_Recipient_Module_Handler__c handlerRecord17 = new UEH_Recipient_Module_Handler__c();
        handlerRecord17.Name = 'test17';
        handlerRecord17.Module_Handler_Class__c = 'UEH_EmailToSocialActionModuleHandler';
        handlerRecord17.Module_Name__c = 'UEH_EmailToSocialActionModuleHandler';
        handlerRecord17.Recipient_Email_Address__c = 'dvsmprog@g-2mu5oo67bi466gwyra9uy4ejpv7dtbpcnw2jqwi0vclnfozz5d.18-8cmteaa.cs23.apex.sandbox.salesforce.com';
        insert handlerRecord17; 

        UEH_Recipient_Module_Handler__c handlerRecord18 = new UEH_Recipient_Module_Handler__c();
        handlerRecord18.Name = 'test18';
        handlerRecord18.Module_Handler_Class__c = 'UEH_EmailToProjectModuleHandler';
        handlerRecord18.Module_Name__c = 'UEH_EmailToProjectModuleHandler';
        handlerRecord18.Recipient_Email_Address__c = 'proect@mathworks.com';
        insert handlerRecord18; 
        
    }
   /*
   *@Author Original: Sagar Talele - Cloud Sherpas/Mathworks, 
   *@Date Original:   27 July 2015
   *@Last Modified:   Haigang Wu - Mathworks
   *@Last Modified:   20 July 2016 
   *@Description:     Creating test data from Universal Email Handler i.e
                      custom setting containing Mapping of keyPrfixes to the 
                      appropriate handler class for new messages in order to proceed them further.
  
    */
    public void builtUEH_KeyPrefix_Module_Handler(){
        
        UEH_KeyPrefix_Module_Handler__c handlerRecord1 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord1.Name = 'Z01';
        handlerRecord1.Key_Prefix__c = 'Z01';
        handlerRecord1.Module_Handler_Class__c = 'CaseHandler';
        handlerRecord1.Module_Name__c = 'Case';
        insert handlerRecord1;  
            
        UEH_KeyPrefix_Module_Handler__c handlerRecord2 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord2.Name = '500';
        handlerRecord2.Key_Prefix__c = '500';
        handlerRecord2.Module_Handler_Class__c = 'UEH_EmailToCaseHandler';
        handlerRecord2.Module_Name__c = 'Case1';
        insert handlerRecord2;
        
        SObjectType paTargetType = Schema.getGlobalDescribe().get('Partner_Agreement__c');
        String paKeyPrefix = paTargetType.getDescribe().getKeyPrefix();
        UEH_KeyPrefix_Module_Handler__c handlerRecord3 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord3.Name = paKeyPrefix;
        handlerRecord3.Key_Prefix__c = paKeyPrefix;
        handlerRecord3.Module_Handler_Class__c = 'UEH_EmailToPartnerAgreementModuleHandler';
        handlerRecord3.Module_Name__c = 'PartnerAgreement';
        insert handlerRecord3;
        
        SObjectType bpTargetType = Schema.getGlobalDescribe().get('Book_Project__c');
        String bpKeyPrefix = bpTargetType.getDescribe().getKeyPrefix();    
        UEH_KeyPrefix_Module_Handler__c handlerRecord4 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord4.Name = bpKeyPrefix;
        handlerRecord4.Key_Prefix__c = bpKeyPrefix;
        handlerRecord4.Module_Handler_Class__c = 'UEH_EmailToBookProjectModuleHandler';
        handlerRecord4.Module_Name__c = 'BookProject';
        insert handlerRecord4;
        
        SObjectType asTargetType = Schema.getGlobalDescribe().get('Academic_Support_Project__c');
        String asKeyPrefix = asTargetType.getDescribe().getKeyPrefix();
        UEH_KeyPrefix_Module_Handler__c handlerRecord5 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord5.Name = asKeyPrefix;
        handlerRecord5.Key_Prefix__c = asKeyPrefix;
        handlerRecord5.Module_Handler_Class__c = 'UEH_EmailToAcademicSupportModuleHandler';
        handlerRecord5.Module_Name__c = 'Academic support'; 
        insert handlerRecord5;
     
        SObjectType saTargetType = Schema.getGlobalDescribe().get('Social_Action__c');
        String saKeyPrefix = saTargetType.getDescribe().getKeyPrefix();
        UEH_KeyPrefix_Module_Handler__c handlerRecord6 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord6.Name = saKeyPrefix;
        handlerRecord6.Key_Prefix__c = saKeyPrefix;
        handlerRecord6.Module_Handler_Class__c = 'UEH_EmailToSocialActionModuleHandler';
        handlerRecord6.Module_Name__c = 'Social Action'; 
        insert handlerRecord6;
            
        SObjectType proTargetType = Schema.getGlobalDescribe().get('MW_Project__c');
        String proKeyPrefix = proTargetType.getDescribe().getKeyPrefix();
        UEH_KeyPrefix_Module_Handler__c handlerRecord7 = new UEH_KeyPrefix_Module_Handler__c();
        handlerRecord7.Name = proKeyPrefix;
        handlerRecord7.Key_Prefix__c = proKeyPrefix;
        handlerRecord7.Module_Handler_Class__c = 'UEH_EmailToProjectModuleHandler';
        handlerRecord7.Module_Name__c = 'Project';
        insert handlerRecord7;
        
    }
    
    /*
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
   *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks  
   *@Date Original:   30 July 2015
   *@Last Modified:   30 July 2015
   *@Description:     Creating test data for Universal Email Handler i.e
                      custom setting containing interval.
  
    */
    public void builtUEHMessageCheckingSettings(){
        
        UEHMessageCheckingSettings__c checkingSetting = new UEHMessageCheckingSettings__c();
        checkingSetting.Check_Interval__c = 90;
        checkingSetting.SpamCheckCount__c = 1;
        insert checkingSetting;  
    
    }
    
   /*
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
   *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks  
   *@Date Original:   30 July 2015
   *@Last Modified:   30 July 2015
   *@Description:     Creating test data for Universal Email Handler i.e
                      General Setting.
  
    */
    public void builtUEHGeneralSetting(){
        
        UEHGeneralSetting__c generalSetting = new UEHGeneralSetting__c();
        generalSetting.Enable_Blacklist_Logging__c = true;
        generalSetting.Partner_Program_User__c = 'TUser101';
        generalSetting.Max_Email_Body_Length__c = 128000;
        insert generalSetting;  
    
    }
    
    /*
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
   *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks  
   *@Date Original:   26 August 2015
   *@Last Modified:   26 August 2015
   *@Description:     Creating test data for Universal Email Handler i.e
                      UEH_BookProject_RecipientToQueueMapping__c.
  
    */
    public void builtUEHBookProjectRecipientToQueueMapping(){
        
        UEH_BookProject_RecipientToQueueMapping__c bookProjectAssignmentSetting = new UEH_BookProject_RecipientToQueueMapping__c();
        bookProjectAssignmentSetting.Name = 'Book Project - Japan';
        bookProjectAssignmentSetting.Queue_Name__c = 'Book Project - Japan';
        bookProjectAssignmentSetting.Recipient_Email_Address__c = 'bookprogram@mathworks.co.jp';
        insert bookProjectAssignmentSetting;
        
        UEH_BookProject_RecipientToQueueMapping__c bookProjectAssignmentSetting1 = new UEH_BookProject_RecipientToQueueMapping__c();
        bookProjectAssignmentSetting1.Name = 'Book Project - Natick';
        bookProjectAssignmentSetting1.Queue_Name__c = 'Book Project- Natick';
        bookProjectAssignmentSetting1.Recipient_Email_Address__c = 'bookprogram@mathworks.com';
        insert bookProjectAssignmentSetting1;
    
    }
    
    /*
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
   *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks  
   *@Date Original:   4 Sep 2015
   *@Last Modified:   4 Sep 2015
   *@Description:     Creating test data for Universal Email Handler i.e
                      PartnerAgreementRecipientToQueueMapping__c.
  
    */
    public void builtUEHPartnerAgreementRecipientToQueueMapping(){
        
        PartnerAgreementRecipientToQueueMapping__c partAgreeAssignmentSetting = new PartnerAgreementRecipientToQueueMapping__c();
        partAgreeAssignmentSetting.Name = 'Japan Partner Agreements';
        partAgreeAssignmentSetting.Queue_Name__c = 'Japan Partner Agreements';
        partAgreeAssignmentSetting.Recipient_Email_Address__c = 'partnerAgree@mathworks.co.jp';
        insert partAgreeAssignmentSetting;
        
        PartnerAgreementRecipientToQueueMapping__c partAgreeAssignmentSetting1 = new PartnerAgreementRecipientToQueueMapping__c();
        partAgreeAssignmentSetting1.Name = 'Natick Partner Agreements';
        partAgreeAssignmentSetting1.Queue_Name__c = 'Natick Partner Agreements';
        partAgreeAssignmentSetting1.Recipient_Email_Address__c = 'partnerAgree@mathworks.com';
        insert partAgreeAssignmentSetting1;
    
    }
    
    /*
   *@Author Original: Haigang Wu - Mathworks, 
   *@Last Modified:   Haigang Wu - Mathworks  
   *@Date Original:   20 July 2016
   *@Last Modified:   20 July 2016
   *@Description:     Creating test data for Universal Email Handler i.e
                      ProjectRecipientToQueueMapping__c.
  
    
    public void builtUEHProjectRecipientToQueueMapping(){
        
        ProjectRecipientToQueueMapping__c proAssignmentSetting = new ProjectRecipientToQueueMapping__c();
        proAssignmentSetting.Name = 'Project - Natick';
        proAssignmentSetting.Queue_Name__c = 'Project - Natick';
        proAssignmentSetting.Recipient_Email_Address__c = 'proect@mathworks.com';
        insert proAssignmentSetting;
        
    }
    */
    /*
   *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks, 
   *@Last Modified:   Archana Lohar - Cloud Sherpas/Mathworks  
   *@Date Original:   4 Sep 2015
   *@Last Modified:   4 Sep 2015
   *@Description:     Creating test data for Universal Email Handler i.e
                      UEH_AcademicSup_RecipientToQueueMapping__c.
  
    */
    public void builtUEHAcademicSupRecipientToQueueMapping(){
        
        UEH_AcademicSup_RecipientToQueueMapping__c academicSupAssignmentSetting = new UEH_AcademicSup_RecipientToQueueMapping__c();
        academicSupAssignmentSetting.Name = 'Japan Academic support';
        academicSupAssignmentSetting.Queue_Name__c = 'Japan Academic support';
        academicSupAssignmentSetting.Recipient_Email_Address__c = 'AcademicSupport@mathworks.co.jp';
        insert academicSupAssignmentSetting;
        
        PartnerAgreementRecipientToQueueMapping__c academicSupAssignmentSetting1 = new PartnerAgreementRecipientToQueueMapping__c();
        academicSupAssignmentSetting1.Name = 'Natick Academic support';
        academicSupAssignmentSetting1.Queue_Name__c = 'Natick Academic support';
        academicSupAssignmentSetting1.Recipient_Email_Address__c = 'AcademicSupport@mathworks.com';
        insert academicSupAssignmentSetting1;
    
    }
    
    
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
     * date Original: 17 March 2016, Last Modified: 17 March 2016
     * description: Creating test data for Universal Email Handler i.e
     *                     UEH_SocialAction_RecipientToQueueMapping__c.
     ****************************************************************************************/
    public void builtUEHSocialActionRecipientToQueueMapping(){
        UEH_SocialAction_RecipientToQueueMapping__c socialActionSetting = new UEH_SocialAction_RecipientToQueueMapping__c();
        socialActionSetting.Name = 'Unassigned - Social Mission';
        socialActionSetting.Queue_Name__c = 'Unassigned - Social Mission';
        socialActionSetting.Recipient_Email_Address__c = 'dvsmprog@g-2mu5oo67bi466gwyra9uy4ejpv7dtbpcnw2jqwi0vclnfozz5d.18-8cmteaa.cs23.apex.sandbox.salesforce.com';
        insert socialActionSetting;
        
    } 
}