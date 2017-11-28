global with sharing class AltifyFivePillarController  {
    private static Map<String, List<String>> texts = null;
    private static Map<String, DMAPP__DM_Account_Plan__c> details = null;
    public DMAPP__DM_Account_Plan__c thePlan ;
    
    public AltifyFivePillarController() { 		  
  	}
  
  	public with sharing class Section {
    public String title {get;set;}
	public List<String> questions {get;set;}
         
   	public Section(String title, List<String> questions) {
      this.title = title;
      this.questions = questions;
    	}
  	}

    public List<Section> getSections() {
    return new List<Section>{
      new Section(Label.Five_Pillar_Section1, new List<String> {       
          'BA_CompPlatformProd__c', 
          'BA_Events__c',  
          'BA_Training__c',
          'BA_Instructions__c',
          'BA_InternalSupp__c' , 
          'BA_MLUsers__c', 
          'BA_SLUsers__c'      
      }),
      new Section(Label.Five_Pillar_Section2, new List<String> {
        'DA_IncreaseAttachRate__c', 
        'DA_OnsiteEvent__c',  
        'DA_EngProjects__c', 
        'DA_OnsiteDev__c', 
        'DA_NextSteps__c',
        'DA_AddOnTool__c', 
        'DA_InfluenceWF__c',   
        'DA_AdvancedTool__c',  
        'DA_AttendeesEvent__c'
    
      }),
      new Section(Label.Five_Pillar_Section3, new List<String>  {
          'ER_NoAttendeesMAB__c', 
           'ER_ReciprocalRel__c', 
           'ER_UserChampion__c', 
           'ER_PowerUsers__c', 
           'ER_UserGroup__c', 
           'ER_MarketingCommPlan__c',
           'ER_Advice__c'              
     
      }),     
       new Section(Label.Five_Pillar_Section4, new List<String>  {
         'MR_SeniorInfluencers__c', 
         'MR_ProcessChange__c',  
         'MR_ProjPlanning__c',   
         'MR_SeniorRel__c', 
         'MR_KeynoteSpeaker__c',
         'MR_CommitUsage__c',  
         'MR_CommitSMSTerm__c'
    
      }),
          
       new Section(Label.Five_Pillar_Section5, new List<String> {
      	'EXR_IdentifyExecutives__c',  
        'EXR_KeyVendor__c',
        'EXR_AccessibleResponsive__c',
        'EXR_ExecutiveReview__c',
        'EXR_RevenueInv__c',
        'EXR_ProtectMWStatus__c',
        'EXR_Introductions__c',
        'EXR_JointAccntStrategy__c',
        'EXR_MeetMWSeniorSalesMgmt__c',
        'EXR_MeetMWDevMgmt__c'
	})
                  
    };

  }

    public List<SelectOption> getItems() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));
        
        system.debug('****Options***'+ options);
        return Options;
    }
    
    public Map<String, List<String>> getQuestionTexts() {
        
        if (texts == null) {
            texts = new Map<String, List<String>>();
            
            texts.put('BA_MLUsers__c', new List<String> {DMAPP__DM_Account_Plan__c.BA_MLUsers__c.getDescribe().getInlineHelpText(), 'BA_MLUsers_Details__c'} );           
        	texts.put('BA_SLUsers__c' , new List<String> {DMAPP__DM_Account_Plan__c.BA_SLUsers__c.getDescribe().getInlineHelpText(), 'BA_SLUsers_Details__c'});
        	texts.put('BA_CompPlatformProd__c' , new List<String> {DMAPP__DM_Account_Plan__c.BA_CompPlatformProd__c.getDescribe().getInlineHelpText(), 'BA_CompPlatformProd_Details__c'});
         	texts.put('BA_Events__c' , new List<String> {DMAPP__DM_Account_Plan__c.BA_Events__c.getDescribe().getInlineHelpText(),'BA_Events_Details__c'});
        	texts.put('BA_Training__c' , new List<String> {DMAPP__DM_Account_Plan__c.BA_Training__c.getDescribe().getInlineHelpText(), 'BA_Training_Details__c'});
        	texts.put('BA_Instructions__c' , new List<String> {DMAPP__DM_Account_Plan__c.BA_Instructions__c.getDescribe().getInlineHelpText(),'BA_Instructions_Details__c' });
        	texts.put('BA_InternalSupp__c' , new List<String> {DMAPP__DM_Account_Plan__c.BA_InternalSupp__c.getDescribe().getInlineHelpText(), 'BA_InternalSupp_Details__c'});
        	texts.put('DA_IncreaseAttachRate__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_IncreaseAttachRate__c.getDescribe().getInlineHelpText(), 'DA_IncreaseAttachRate_Details__c'});
       		texts.put('DA_OnsiteEvent__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_OnsiteEvent__c.getDescribe().getInlineHelpText(), 'DA_OnsiteEvent_Details__c' });
            texts.put('DA_EngProjects__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_EngProjects__c.getDescribe().getInlineHelpText(), 'DA_EngProjects_Details__c'});
           	texts.put('DA_OnsiteDev__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_OnsiteDev__c.getDescribe().getInlineHelpText(), 'DA_OnsiteDev_Details__c'});
           	texts.put('DA_NextSteps__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_NextSteps__c.getDescribe().getInlineHelpText(), 'DA_NextSteps_Details__c' });
           	texts.put('DA_AddOnTool__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_AddOnTool__c.getDescribe().getInlineHelpText(), 'DA_AddOnTool_Details__c'});
            texts.put('DA_InfluenceWF__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_InfluenceWF__c.getDescribe().getInlineHelpText(), 'DA_InfluenceWF_Details__c'});
           	texts.put('DA_AdvancedTool__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_AdvancedTool__c.getDescribe().getInlineHelpText(), 'DA_AdvancedTool_Details__c'});
           	texts.put('DA_AttendeesEvent__c' , new List<String> {DMAPP__DM_Account_Plan__c.DA_AttendeesEvent__c.getDescribe().getInlineHelpText(), 'DA_AttendeesEvent_Details__c'});
            texts.put('ER_NoAttendeesMAB__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_NoAttendeesMAB__c.getDescribe().getInlineHelpText(), 'ER_NoAttendeesMAB_Details__c'});
           	texts.put('ER_ReciprocalRel__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_ReciprocalRel__c.getDescribe().getInlineHelpText(), 'ER_ReciprocalRel_Details__c'});
            texts.put('ER_UserChampion__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_UserChampion__c.getDescribe().getInlineHelpText(), 'ER_UserChampion_Details__c'});
            texts.put('ER_PowerUsers__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_PowerUsers__c.getDescribe().getInlineHelpText(), 'ER_PowerUsers_Details__c'});
           	texts.put('ER_UserGroup__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_UserGroup__c.getDescribe().getInlineHelpText(), 'ER_UserGroup_Details__c'});
          	texts.put('ER_MarketingCommPlan__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_MarketingCommPlan__c.getDescribe().getInlineHelpText(), 'ER_MarketingCommPlan_Details__c'});
           	texts.put('ER_Advice__c' , new List<String> {DMAPP__DM_Account_Plan__c.ER_Advice__c.getDescribe().getInlineHelpText(), 'ER_Advice_Details__c'});   
            texts.put('MR_SeniorInfluencers__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_SeniorInfluencers__c.getDescribe().getInlineHelpText(), 'MR_SeniorInfluencers_Details__c'});
            texts.put('MR_ProcessChange__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_ProcessChange__c.getDescribe().getInlineHelpText(), 'MR_ProcessChange_Details__c'});
            texts.put('MR_ProjPlanning__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_ProjPlanning__c.getDescribe().getInlineHelpText(), 'MR_ProjPlanning_Details__c'});
            texts.put('MR_SeniorRel__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_SeniorRel__c.getDescribe().getInlineHelpText(), 'MR_SeniorRel_Details__c'});
           	texts.put('MR_KeynoteSpeaker__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_KeynoteSpeaker__c.getDescribe().getInlineHelpText(), 'MR_KeynoteSpeaker_Details__c' });
           	texts.put('MR_CommitUsage__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_CommitUsage__c.getDescribe().getInlineHelpText(), 'MR_CommitUsage_Details__c'});
           	texts.put('MR_CommitSMSTerm__c' , new List<String> {DMAPP__DM_Account_Plan__c.MR_CommitSMSTerm__c.getDescribe().getInlineHelpText(), 'MR_CommitSMSTerm_Details__c' });
           	texts.put('EXR_IdentifyExecutives__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_IdentifyExecutives__c.getDescribe().getInlineHelpText(), 'EXR_IdentifyExecutives_Details__c'});
            texts.put('EXR_KeyVendor__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_KeyVendor__c.getDescribe().getInlineHelpText(), 'EXR_KeyVendor_Details__c' });
            texts.put('EXR_AccessibleResponsive__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_AccessibleResponsive__c.getDescribe().getInlineHelpText(), 'EXR_AccessibleResponsive_Details__c'});
            texts.put('EXR_ExecutiveReview__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_ExecutiveReview__c.getDescribe().getInlineHelpText(), 'EXR_ExecutiveReview_Details__c' });
            texts.put('EXR_RevenueInv__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_RevenueInv__c.getDescribe().getInlineHelpText(), 'EXR_RevenueInv_Details__c'});
            texts.put('EXR_ProtectMWStatus__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_ProtectMWStatus__c.getDescribe().getInlineHelpText(), 'EXR_ProtectMWStatus_Details__c'});
           	texts.put('EXR_Introductions__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_Introductions__c.getDescribe().getInlineHelpText(), 'EXR_Introductions_Details__c' });
           	texts.put('EXR_JointAccntStrategy__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_JointAccntStrategy__c.getDescribe().getInlineHelpText(), 'EXR_JointAccntStrategy_Details__c' });
            texts.put('EXR_MeetMWSeniorSalesMgmt__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_MeetMWSeniorSalesMgmt__c.getDescribe().getInlineHelpText(), 'EXR_MeetMWSeniorSalesMgmt_Details__c' });
           	texts.put('EXR_MeetMWDevMgmt__c' , new List<String> {DMAPP__DM_Account_Plan__c.EXR_MeetMWDevMgmt__c.getDescribe().getInlineHelpText(), 'EXR_MeetMWDevMgmt_Details__c' });
    
        }
     //   system.debug('*************Texts Map*************'+ texts);
        return texts;
    }
    
    public DMAPP__DM_Account_Plan__c getPlan() {
        
        Id planId = ApexPages.currentPage().getParameters().get('id');  
        return getPlan(planId);       
    }
    


    public DMAPP__DM_Account_Plan__c getPlan(Id planId) {
      
      //  system.debug('******This is the plan id:*****' + planId);      
        DMAPP__DM_Account_Plan__c thePlan 
            = [select 
              id, 
              name, 
              BA_MLUsers__c, 
              BA_SLUsers__c, 
              BA_CompPlatformProd__c,
              BA_Events__c,
              BA_Training__c,
              BA_InternalSupp__c,
              BA_Instructions__c,           
              DA_IncreaseAttachRate__c, 
              DA_OnsiteEvent__c,
              DA_EngProjects__c,             
              DA_OnsiteDev__c,
              DA_NextSteps__c,
              DA_AddOnTool__c,
              DA_AdvancedTool__c,
              DA_InfluenceWF__c,
              DA_AttendeesEvent__c,  
              ER_NoAttendeesMAB__c, 
              ER_ReciprocalRel__c,
              ER_UserChampion__c,
              ER_PowerUsers__c,
              ER_UserGroup__c,
              ER_MarketingCommPlan__c,
              ER_Advice__c,
              MR_SeniorInfluencers__c,
              MR_ProcessChange__c,
              MR_ProjPlanning__c,
              MR_SeniorRel__c,
              MR_KeynoteSpeaker__c,
              MR_CommitUsage__c,
              MR_CommitSMSTerm__c,
              EXR_IdentifyExecutives__c,
              EXR_KeyVendor__c,
              EXR_AccessibleResponsive__c,
              EXR_ExecutiveReview__c,
              EXR_RevenueInv__c,
              EXR_ProtectMWStatus__c,
              EXR_Introductions__c,
              EXR_JointAccntStrategy__c,
              EXR_MeetMWSeniorSalesMgmt__c,
              EXR_MeetMWDevMgmt__c,
              BA_MLUsers_Details__c, 
              BA_SLUsers_Details__c, 
              BA_CompPlatformProd_Details__c,
              BA_Events_Details__c,
              BA_Training_Details__c,
              BA_InternalSupp_Details__c,
              BA_Instructions_Details__c,           
              DA_IncreaseAttachRate_Details__c, 
              DA_OnsiteEvent_Details__c,
              DA_EngProjects_Details__c,             
              DA_OnsiteDev_Details__c,
              DA_NextSteps_Details__c,
              DA_AddOnTool_Details__c,
              DA_AdvancedTool_Details__c,
              DA_InfluenceWF_Details__c,
              DA_AttendeesEvent_Details__c,  
              ER_NoAttendeesMAB_Details__c, 
              ER_ReciprocalRel_Details__c,
              ER_UserChampion_Details__c,
              ER_PowerUsers_Details__c,
              ER_UserGroup_Details__c,
              ER_MarketingCommPlan_Details__c,
              ER_Advice_Details__c,
              MR_SeniorInfluencers_Details__c,
              MR_ProcessChange_Details__c,
              MR_ProjPlanning_Details__c,
              MR_SeniorRel_Details__c,
              MR_KeynoteSpeaker_Details__c,
              MR_CommitUsage_Details__c,
              MR_CommitSMSTerm_Details__c,
              EXR_IdentifyExecutives_Details__c,
              EXR_KeyVendor_Details__c,
              EXR_AccessibleResponsive_Details__c,
              EXR_ExecutiveReview_Details__c,
              EXR_RevenueInv_Details__c,
              EXR_ProtectMWStatus_Details__c,
              EXR_Introductions_Details__c,
              EXR_JointAccntStrategy_Details__c,
              EXR_MeetMWSeniorSalesMgmt_Details__c,
              EXR_MeetMWDevMgmt_Details__c,
              DMAPP__Plan_Type__r.BA_MLUsers__c, 
              DMAPP__Plan_Type__r.BA_SLUsers__c, 
			  DMAPP__Plan_Type__r.BA_CompPlatformProd__c, 
              DMAPP__Plan_Type__r.BA_Events__c, 
              DMAPP__Plan_Type__r.BA_Training__c, 
              DMAPP__Plan_Type__r.BA_InternalSupp__c, 
              DMAPP__Plan_Type__r.BA_Instructions__c, 
              DMAPP__Plan_Type__r.DA_IncreaseAttachRate__c,                
              DMAPP__Plan_Type__r.DA_OnsiteEvent__c, 
              DMAPP__Plan_Type__r.DA_EngProjects__c, 
              DMAPP__Plan_Type__r.DA_OnsiteDev__c,
              DMAPP__Plan_Type__r.DA_NextSteps__c,
              DMAPP__Plan_Type__r.DA_AddOnTool__c,
              DMAPP__Plan_Type__r.DA_InfluenceWF__c,
              DMAPP__Plan_Type__r.DA_AdvancedTool__c,
              DMAPP__Plan_Type__r.DA_AttendeesEvent__c,
              DMAPP__Plan_Type__r.ER_NoAttendeesMAB__c,
              DMAPP__Plan_Type__r.ER_ReciprocalRel__c,
              DMAPP__Plan_Type__r.ER_UserChampion__c,
              DMAPP__Plan_Type__r.ER_PowerUsers__c,
              DMAPP__Plan_Type__r.ER_UserGroup__c,
              DMAPP__Plan_Type__r.ER_MarketingCommPlan__c,
              DMAPP__Plan_Type__r.ER_Advice__c,
              DMAPP__Plan_Type__r.MR_SeniorInfluencers__c,
              DMAPP__Plan_Type__r.MR_ProcessChange__c,
              DMAPP__Plan_Type__r.MR_ProjPlanning__c,
              DMAPP__Plan_Type__r.MR_SeniorRel__c,
              DMAPP__Plan_Type__r.MR_KeynoteSpeaker__c,
              DMAPP__Plan_Type__r.MR_CommitUsage__c,
              DMAPP__Plan_Type__r.MR_CommitSMSTerm__c,
              DMAPP__Plan_Type__r.EXR_IdentifyExecutives__c,
              DMAPP__Plan_Type__r.EXR_KeyVendor__c,
              DMAPP__Plan_Type__r.EXR_AccessibleResponsive__c,
              DMAPP__Plan_Type__r.EXR_ExecutiveReview__c,
              DMAPP__Plan_Type__r.EXR_RevenueInv__c,
              DMAPP__Plan_Type__r.EXR_ProtectMWStatus__c,
              DMAPP__Plan_Type__r.EXR_Introductions__c,
              DMAPP__Plan_Type__r.EXR_JointAccntStrategy__c,
              DMAPP__Plan_Type__r.EXR_MeetMWSeniorSalesMgmt__c,
              DMAPP__Plan_Type__r.EXR_MeetMWDevMgmt__c         
              from DMAPP__DM_Account_Plan__c where id = :planId];
        
          system.debug('*****Plan******'+ thePlan); 
        return thePlan;
    }

  @RemoteAction
  global static String updateField(Id planId, String field, String value) {
    AltifyFivePillarController ctrl = new AltifyFivePillarController();
    DMAPP__DM_Account_Plan__c plan = ctrl.getPlan(planId);

    plan.put(field, value);
    update plan;
    return plan.id;
  }


}