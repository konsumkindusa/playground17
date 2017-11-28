/*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Date Original: 9 July 2015
     *@Last Modified: 9 July 2015
     *@Description:Wrapper class 
     */ 
 //TODO: EmailEnvelopeWrapper - Needs comments and should be it's own class file
     public class UEH_EmailEnvelopeWrapper{
            
            public string emailFromAddress{get; set;}
            public string emailToAddresses{get; set;}
            public string envelopeToAddress{get; set;}
            public string envelopeFromAddress{get; set;}
            public string emailSubject{get; set;}
            public string emailPlainTextBody{get; set;}
            public string emailHtmlBody{get; set;}
            public String emailCCAddresses{get; set;}
            public String emailFromName{get; set;}
            public String emailInReplyTo{get; set;}
            public String emailMessageId{get; set;}
            public String emailReferences{get; set;}
            public String emailReplyTo{get; set;}
            public List<Attachment> emailAttachment{get; set;}           
            public List<String> emailHeaderList{get; set;}  
            
        }