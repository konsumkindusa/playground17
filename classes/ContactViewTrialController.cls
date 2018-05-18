/**
 *@author Original: Archana Lohar - Cloud Sherpas/Mathworks,
 *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
 *@date Original: 29 Sep 2014, Last Modified:   29 Sep  2014
 *@description This is controller for ContactViewTrials Page
 */
public with sharing class ContactViewTrialController {
    
    //Initialize variables
    public String mathworkAccountId;
    TrialsIntegrationSetting__c settings ;
    String url;
    public String pageSize;
    public SerializedTrials trials{get;set;}
    public TrialPeopleBean trialPeoples{get;set;}
    public TrialProductBean trialProducts{get;set;}
    public list<SerializedTrials.EntitlementBean> trialList{get;set;}
    public list<SerializedTrials.EntitlementBean> selectedTrialList{get;set;}
    public list<TrialProductBean.entitlementReleaseBean> relatedProductList{get;set;}
    public list<TrialPeopleBean.entitlementPersonBean> relatedPeopleList{get;set;}
    public Map<String,Contact> mapContact{get; set;}
    public Contact con {get;set;}
    public list<Contact> conList;
    public String selTrialid {get;set;}
    public String pageNumberToSet{get;set;} 
    public String pageNumberToSetforContact{get;set;}
    public boolean displayPopup {get; set;} 
    public Integer mod {get; set;} 
    public Integer noOfPagesForContactToShow{get; set;} 
    public  string pageSizeForContact {get; set;}
    public String trialsNotFound=System.Label.ViewTrialNotrialsFoundMessage; 
    public String mathworkAccIdNotFound=System.Label.ViewTrialsMathWorkAccountIdNotFound;
    public String ViewTrialServerError=System.Label.ViewTrialServerError;
    public String STerrorMessage=System.Label.SecurityTokenNotFoundMessage;
    
    public IntegrationUtilityHelper intHelper;
    public  string bToken;
    //For Pagination purpose
    public integer totalRecs{get; set;}  
    private integer LimitSize;
    public boolean flag{get;set;}
    public integer listSize{get;set;}
    


    //For Contact Pagination purpose
    public integer contactTotalRecs{get; set;}  
    private integer contactLimitSize;
    public integer contactlistSize{get;set;}
    public Integer noOfPagesForContact {get; set;} 

    public ContactViewTrialController(ApexPages.StandardController controller)
    { 

        //fetch Trials Integration Setting  instance
        settings = TrialsIntegrationSetting__c.getInstance();

        //Getting url from General setting
        url = settings.TrialBaseUrl__c ;

        //getting Page size from General setting
        pageSize=settings.PageSizeForPaginationToShowTrials__c ;
        
        //getting contact related list Page size from General setting
        pageSizeForContact=settings.PaginationPageSizeContactRelatedList__c ;

        LimitSize=Integer.valueOf(pageSize);

        this.con = (Contact)controller.getRecord();
        
        conList=new List<contact>();
        
        conList=[select MathWorks_Account_ID__c  from Contact where id=:con.id limit 1];

        trialList=new list<SerializedTrials.EntitlementBean>();

        relatedPeopleList=new list<TrialPeopleBean.entitlementPersonBean>();

        relatedProductList=new list<TrialProductBean.entitlementReleaseBean>();

        selectedTrialList=new list<SerializedTrials.EntitlementBean>();

        pageNumberToSet='1';
        
        pageNumberToSetforContact='1';

        totalRecs = 0;
        
        
        intHelper=new IntegrationUtilityHelper ();
        
        bToken=intHelper.getBusinessServiceToken();

    }

    /*
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks,
     *@Date Original: 29 Sep 2014
     *@Last Modified: 29 Sep 2014
     *@Description:It will show all the trials related to the Opportunity record.
     */ 
    public PageReference showTrialsRelatedToOpportunity(string pageNumber){

        Logger.push('showTrialsRelatedToOpportunity','ViewTrialController');

        try{

               if(con != null){

                pageNumberToSet=pageNumber;
                
                String queryTagInputToSend;
                
                String payloadString;
                
                if(conList[0].MathWorks_Account_ID__c!=null){

                 queryTagInputToSend= 'person.mathworksAccountId="'+conList[0].MathWorks_Account_ID__c+'" &amp; entitlementtypeid=288';

                }
                else
                {
                    UtilityHelper.addErrorMessage(mathworkAccIdNotFound);
                    return null;
                }
                if(bToken!='SecurityTokenNotFound'){
                
                 //Getting payload to send in ws request
                 payloadString=TrialsUtilityClass.getPayLoadToSendForTrials(pageNumber,queryTagInputToSend,bToken);
                 
               }else{
                 
                 UtilityHelper.addErrorMessage(STerrorMessage);
                 return null;
              }
                
                //Getting response jason string from response XML string from WS
                String trialJsonString=TrialsUtilityClass.sendWSRequest(payloadString,'getEntitlements');
                
                system.debug('trialJsonStringtrialJsonString'+trialJsonString); 

                //Check For String value
                if(trialJsonString != null && trialJsonString!='NotFound'){

                    //Map Jason String into SerializedTrials class
                    trials=SerializedTrials.parse(trialJsonString);

                    //Set number of records 
                    totalRecs=trials.summaryCount;

                    //Calculate number of pages
                    mod = (Integer)Math.ceil((Double)totalRecs/ (Double)Integer.valueOf(pageSize));

                    //Getting EntitlementBean list from SerializedTrials class
                    trialList=trials.EntitlementBean;

                    if(trialList.size()==0){
                        UtilityHelper.addErrorMessage(trialsNotFound);
                        return null;
                    }

                }  

                else{

                    UtilityHelper.addErrorMessage(trialsNotFound);
                    return null;
                }//else

            }//if
        }
        catch(Exception ex){

            UtilityHelper.addErrorMessage(ViewTrialServerError);
            //Logger.debugException(ex);
            Logger.debugException(ex.getMessage()+'ContactId'+con.id);
            Logger.pop();
            return null;

        }
        return null;

    }


    /**
     *
     *@Author Original: Archana Lohar - Cloud Sherpas/Mathworks 
     *@Last Modified: Archana Lohar - Cloud Sherpas/Mathworks
     *@Date Original: 17 July 2014 
     *@Last Modified: 17 July 2014
     *@Description: It will get  the selected Contact from list 
     */ 
    public void selectTrial()
    {

        Logger.push('selectTrial','QuoteController');

        ApexPages.getMessages().clear();
        if(!Test.isRunningtest())
        selTrialid = System.currentPagereference().getParameters().get('trialId');

        mapContact = new Map<String,contact>();
        Set<String> mathworkAccountIdSet= new Set<String>();

        String pageNo='1';


        try{

            pageNumberToSetforContact='1';

            relatedPeopleList=TrialsUtilityClass.showEntitlementPeopleRelatedToTrial(selTrialid,'1',bToken);
            relatedProductList=TrialsUtilityClass.showEntitlementProductRelatedToTrial(selTrialid,bToken);
            
            noOfPagesForContactToShow=TrialsUtilityClass.noOfPagesForContact;

            selectedTrialList.clear();

            //Get selected trial on Page
            for(SerializedTrials.EntitlementBean trails:trialList){

                if(trails.id==selTrialid){

                    selectedTrialList.add(trails);

                }

            }

            //For contact Drill down
            for(TrialPeopleBean.entitlementPersonBean contacts: relatedPeopleList ) {

                mathworkAccountIdSet.add(contacts.webprofileid);

            }

            if(!mathworkAccountIdSet.isEmpty()) {

                mapContact = new Map<String,Contact>();
                for(Contact con : [SELECT id,lastName,Has_Licenses__c, Name, First_Name_Latin__c, Last_Name_Latin__c,MathWorks_Account_ID__c
                                   FROM Contact 
                                   WHERE MathWorks_Account_ID__c in : mathworkAccountIdSet]) {

                    mapContact.put(con.MathWorks_Account_ID__c,con);

                }
            }
            
             //Fill map With mathworkAccountIdSet Keys with Null Values so we can not get Map Key Not Found 
                    For(String mathWorkAccId: mathworkAccountIdSet){
                        if(!mapContact.containskey(mathWorkAccId)){
                         mapContact.put(mathWorkAccId,new Contact(lastName='DummyContact'));
                         
                         }
                    }

            listSize=mapContact.values().size();

        }
        Catch(Exception ex){

            UtilityHelper.addErrorMessage(ex.getMessage());
            //Logger.debugException(ex);
            Logger.debugException(ex.getMessage()+'ContactId'+con.id);
            Logger.pop();


        }

    }

    public void FirstPage()
    {
        pageNumberToSet='1';
        showTrialsRelatedToOpportunity(pageNumberToSet);
    }
    public void previous()
    {
        pageNumberToSet=String.valueOf((Integer.valueOf(pageNumberToSet) -1));
        showTrialsRelatedToOpportunity(pageNumberToSet);
    }

    public void next()
    {
        pageNumberToSet = String.valueOf((Integer.valueOf(pageNumberToSet) + 1));
        showTrialsRelatedToOpportunity(pageNumberToSet);
    }

    public void LastPage()
    {

        pageNumberToSet = String.valueOf(totalRecs - (math.mod(totalRecs,LimitSize)+1));


        showTrialsRelatedToOpportunity(String.valueOf(mod));
    }
    public boolean getprev()
    {
         return pageNumberToSet == '1';

    }
    public boolean getnxt()
    {
          return Integer.valueOf(pageNumberToSet)== mod;
   }
    //Pagination for Contact related list
        public void FirstConPage()
        {
            pageNumberToSetforContact='1';
            relatedPeopleList=TrialsUtilityClass.showEntitlementPeopleRelatedToTrial(selTrialid,pageNumberToSetforContact,bToken);
            
        }
        public void previousCon()
        {
            pageNumberToSetforContact=String.valueOf((Integer.valueOf(pageNumberToSetforContact) -1));
            relatedPeopleList=TrialsUtilityClass.showEntitlementPeopleRelatedToTrial(selTrialid,pageNumberToSetforContact,bToken);
            pageNumberToSetforContact=TrialsUtilityClass.currentPageNumberForContact;
        }

        public void nextCon()
        {
            pageNumberToSetforContact= String.valueOf((Integer.valueOf(pageNumberToSetforContact) + 1));
            relatedPeopleList=TrialsUtilityClass.showEntitlementPeopleRelatedToTrial(selTrialid,pageNumberToSetforContact,bToken);
            pageNumberToSetforContact=TrialsUtilityClass.currentPageNumberForContact;
        }

        public void LastConPage()
        {

             relatedPeopleList=TrialsUtilityClass.showEntitlementPeopleRelatedToTrial(selTrialid,String.valueOf(noOfPagesForContactToShow),bToken);
             pageNumberToSetforContact=TrialsUtilityClass.currentPageNumberForContact;
        }
        public boolean getConprev()
        {

                return pageNumberToSetforContact == '1';

        }
        public boolean getConnxt()
        {
               return Integer.valueOf(pageNumberToSetforContact)==TrialsUtilityClass.noOfPagesForContact;
        }
        public void getshowTrialsRelatedToOpportunityTest(){showTrialsRelatedToOpportunity('1');}

   
}