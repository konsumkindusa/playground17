/**
 *@author Original: Andre Calimlim
 *@Last Modified: kishore AN
 *@date Original: 1 Sept 2014, Last Modified: 13 March 2015
 *@description This is controller for ProjectTimecard Page
 *@revision Archana Lohar|13 March 2015|Made changes to allow for time to be captured by day
 */

public with sharing class TimecardController {
    //public Integer counter {get;set;}
    public List<TimecardWrapper> timecardWrapperList {get;set;}
    // public List<TimecardWrapper> timecardWrapperOldList {get;set;}
    public String saveStatus {get;set;}
    public Project_Time_Card__c projectTimecard{get;set;}
    private Date currentWeek;
    public String selectedProjectId{get; set;}
    public Map<string,List<String>> purposeToActivityMap;
    public Map<String, String> projectToPurposeMap;
    public string activityTypeToInclude{get; set;}
	public String defProjId;		//DMA 10-26-2017 default project id, passed in from URL
    public boolean defProjValid;	// ==true if defProjID is not null and is a valid project for this user
    public string defProjPurpose;	//Purpose of default project selected (used to get list of Activities)

    /*
     * @description: This is the Wrapper class that will hold the record
     *               that is displayed in the pageBlockTable
     */
    public class TimecardWrapper{
        public String selectedProj {get;set;}
        public Project_Time_Card__c timecard{get;set;}
        public Date weekending{get;set;}
        public Date weekDate{get;set;}
        public List<SelectOption> projectList{get;set;}
        public List<SelectOption> activityList{get;set;}
        public Integer counterWrap{get;set;}
        public boolean savedTC{get;set;}
        public boolean isModified {get;set;}
        public TimecardWrapper(Project_Time_Card__c tc){
            this.timecard = tc;
        }
    }

    //Default Consructor
    public TimecardController(){
    }

    //Constructor that will set the projectTimecard and currentWeek on page load
    public TimecardController(ApexPages.StandardController controller){

        Project_Validation_Rule_Settings__c projSet = Project_Validation_Rule_Settings__c.getInstance();

        this.projectTimecard = (Project_Time_Card__c)controller.getRecord();
        projectTimecard.Week_Ending__c = dayOfWeek(Date.today(), 6);
        projectTimecard.Week_Date__c=Date.today();
        projectTimecard.AE_PE__c = UserInfo.getUserId();
        currentWeek = projectTimecard.Week_Ending__c;

        purposeToActivityMap=new Map<string,List<String>>();

        list<TimeCardController__c> custSetList =new list<TimeCardController__c>();
        activityTypeToInclude = projSet.ProjectActivityType__c;

        custSetList=[select Project_Purpose__c, Dependent_Activity_Type_Values__c 
                     from TimeCardController__c 
                     order by name limit 15000];

        if(!custSetList.isEmpty() && custSetList!= NULL){

            for(TimeCardController__c tcc: custSetList){

                if(tcc.Project_Purpose__c!= '' && tcc.Project_Purpose__c!= NULL){


                    if(!purposeToActivityMap.containsKey(tcc.Project_Purpose__c)){

                        purposeToActivityMap.put(tcc.Project_Purpose__c,new List<String>{tcc.Dependent_Activity_Type_Values__c});
                    }
                    else{

                        purposeToActivityMap.get(tcc.Project_Purpose__c).add(tcc.Dependent_Activity_Type_Values__c);
                    }
                }
            }
        }

    }

    /**
     *@Author Original: Andre Calimlim - Cloud Sherpas/Mathworks 
     *@Last Modified: Kishore AN - Cloud Sherpas/Mathworks
     *@Date Original: 01 Sept 2014 
     *@Last Modified: 24 Sept 2014 Modified the code to add only one new timecard
     * @description: This is the method that will populate the pageblockTable
     *               to refresh the records in timecardWrapperList
     */
    public void initialise(){

        Logger.push('initialise', 'TimecardController');
		
        //DMA 10-26-2017 Adding logic for default project based on url param
        defProjId = ApexPages.currentPage().getParameters().get('projectID');
        defProjValid = false;
        
        this.timecardWrapperList = new List<TimecardWrapper>();
        projectToPurposeMap = new Map<String, String>();
        //call retrieveProjectTeamList method to get the List of projectTeam
        List<Project_Team_Member__c> projectTeamList = retrieveProjectTeamList();			//get projects for this user for select list options
        Integer counter = 0;       
        for(Project_Team_Member__c proj : projectTeamList){
            projectToPurposeMap.put(proj.project__c,  proj.Project__r.Purpose__c);
            if(defProjId != null && defProjId == proj.Project__r.Id){						//DMA 10-26-2017 if defProjId matches any of the valid select list options
            	defProjValid = true; 														//then we know it's valid (defProjValid == true)
                defProjPurpose = proj.Project__r.Purpose__c;								//also record this project's Purpose__c to later get Activities options
            }																				
        }
        for(Project_Time_Card__c tc : [SELECT Project__c, lastmodifieddate, Project__r.Project_Name__c,Project__r.Purpose__c, project__r.Project_Status__c, Product_Group__c, Activity_Type__c, Hours__c,Notes__c, Status__c, Week_Ending__c, Name,Week_Date__c  FROM Project_Time_Card__c WHERE Week_Date__c = :projectTimecard.Week_Date__c and AE_PE__c = :UserInfo.getUserId() ORDER BY CreatedDate]){
            TimecardWrapper projWrap = new TimecardWrapper(tc);
            projWrap.counterWrap = counter;
            projWrap.selectedProj = tc.Project__c;            
            projWrap.projectList = new List<SelectOption>();
            projWrap.activityList= new List<SelectOption>();
            projWrap.activityList.add(new SelectOption('None','--None--'));
            projWrap.timecard.Status__c='Submitted';

            for (String s: purposeToActivityMap.get(tc.Project__r.Purpose__c)) { projWrap.activityList.add(new SelectOption(s, s));}


            for(Project_Team_Member__c proj : projectTeamList){
                projWrap.projectList.add(new SelectOption(proj.Project__c, proj.Project__r.Name + ':' +proj.Project__r.Project_Name__c));                       
            }
            projWrap.timecard = tc;
            projWrap.weekending = tc.Week_Ending__c;
            projWrap.weekDate= tc.Week_Date__c;
            projWrap.savedTC = true;
            projWrap.isModified = false;
            timecardWrapperList.add(projWrap);
            counter++;

        }

        Logger.debug('counter:' + counter + ' projectTeamList size:' + projectTeamList.size());

        //Add one new time card along with the saved timecards if any.
        if(!projectTeamList.isEmpty()){

            TimecardWrapper projWrap = new TimecardWrapper(new Project_Time_Card__c()); 
            projWrap.counterWrap = counter+1;
            projWrap.projectList = new List<SelectOption>();
            projWrap.timecard.Hours__c = 0.00;
            projWrap.timecard.Notes__c = null;
            projWrap.activityList= new List<SelectOption>();
            projWrap.activityList.add(new SelectOption('None','--None--'));
            projWrap.projectList.add(new SelectOption('None','--None--'));
            for(Project_Team_Member__c proj : projectTeamList){
                projWrap.projectList.add(new SelectOption(proj.Project__c, proj.Project__r.Name + ':'+proj.Project__r.Project_Name__c));                
            }
            projWrap.weekending = projectTimecard.Week_Ending__c;
            projWrap.weekDate= projectTimecard.Week_Date__c;
            projWrap.savedTC = false;
            projWrap.isModified = false;
            if(defProjValid){	//DMA 10-26-2017 If our defProjID is valid, set selectedProj to this as default, populate activity list
                projWrap.selectedProj = defProjId;  
                for (String s: purposeToActivityMap.get(defProjPurpose)) { projWrap.activityList.add(new SelectOption(s, s));}
            }
            timecardWrapperList.add(projWrap);

            ApexPages.getMessages().clear();
        } else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.No_Project_Assignment_Msg));

        }

        Logger.pop();
    }

    /*
     * @description: This is the method for the Right arrow button to navigate to next date
     *              
     */
    public void GotoNext(){
        Logger.push('GotoNext', 'TimecardController');

        projectTimecard.Week_Date__c= projectTimecard.Week_Date__c.addDays(1);
        projectTimecard.Week_Ending__c = dayOfWeek(projectTimecard.Week_Date__c, 6);

        initialise();
        Logger.pop();
    }
    /*
     * @description: This is the method for the Left arrow button to navigate to Previous date
     *               
     */
    public void GotoPrev(){
        Logger.push('GotoPrev', 'TimecardController');
        projectTimecard.Week_Date__c= projectTimecard.Week_Date__c.addDays(-1);
        projectTimecard.Week_Ending__c = dayOfWeek(projectTimecard.Week_Date__c, 6);       
        initialise();
        Logger.pop();
    }
    /*
     * @description: This is the method to navigate to the Week Ending of a date.
     *               
     */
    public void changeWeekEnding(){
        Logger.push('changeWeekEnding', 'TimecardController');
        projectTimecard.Week_Ending__c = dayOfWeek(projectTimecard.Week_Date__c, 6);

        initialise();
        Logger.pop();
    }
    /*
     * @description: This is the method to add a new Entry and have it on the bottom of the pageblocktable
     *               
     */
    public void addRow(){
        Logger.push('addRow', 'TimecardController');
         //call retrieveProjectTeamList method  to get the List of projectTeam
        List<Project_Team_Member__c> projectTeamList = retrieveProjectTeamList();
        if(!projectTeamList.isEmpty()){
            TimecardWrapper tw = new TimecardWrapper(new Project_Time_Card__c());
            tw.activityList= new List<SelectOption>();

            tw.activityList.add(new SelectOption('None','--None--'));

            tw.counterWrap = timecardWrapperList.size();
            tw.timecard.Hours__c = 0.00;
            tw.timecard.Notes__c = null;
            tw.weekending = projectTimecard.Week_Ending__c;
            tw.weekdate = projectTimecard.Week_Date__c;
            tw.projectList = new List<SelectOption>();
            tw.projectList.add(new SelectOption('None','--None--'));

            for(Project_Team_Member__c proj : projectTeamList){
                tw.projectList.add(new SelectOption(proj.Project__c, proj.Project__r.Name + ':' + proj.Project__r.Project_Name__c));
            }
            tw.savedTC = false;
            if(defProjValid){	//DMA 10-26-2017 If our defProjID is valid, set selectedProj to this as default, populate activity list
                tw.selectedProj = defProjId;  
                for (String s: purposeToActivityMap.get(defProjPurpose)) { tw.activityList.add(new SelectOption(s, s));}
            }
            timecardWrapperList.add(tw);
        }

        for(Integer i=0;i<timecardWrapperList.size();i++){

            timecardWrapperList[i].counterWrap = i;
        }


        Logger.pop();

    }
    /*
     * @description: This is the method to clone a row
     *               
     */
    public void cloneRow(){
        Logger.push('cloneRow', 'TimecardController');

        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('CloneRow'));
         //call retrieveProjectTeamList method to get the List of projectTeam
        List<Project_Team_Member__c> projectTeamList = retrieveProjectTeamList();

        System.debug('TestCloneRow_2'+timecardWrapperList.size());  
        for(Integer i=0;i<timecardWrapperList.size();i++){

            if(timecardWrapperList[i].counterWrap == param ){


                TimecardWrapper tw = new TimecardWrapper(new Project_Time_Card__c());

                tw.counterWrap = timecardWrapperList.size();
                tw.timecard.Hours__c = 0.00;
                tw.timecard.Notes__c = null;
                tw.activityList=new List<SelectOption>();
                tw.isModified = true;

                tw.activityList.add(new SelectOption('None','--None--'));
                if(projectToPurposeMap.ContainsKey(timecardWrapperList[i].selectedProj)){
                    for (String s: purposeToActivityMap.get(projectToPurposeMap.get(timecardWrapperList[i].selectedProj))){ 
                        tw.activityList.add(new SelectOption(s, s));
                    }
                }                            


                tw.weekending = projectTimecard.Week_Ending__c;
                tw.weekDate= projectTimecard.Week_Date__c;
                tw.projectList = new List<SelectOption>();
                tw.timecard.Activity_Type__c=timecardWrapperList[i].timecard.Activity_Type__c;
                tw.timecard.Product_Group__c=timecardWrapperList[i].timecard.Product_Group__c;
                tw.projectList = new List<SelectOption>();
                tw.projectList.add(new SelectOption('None','--None--'));
                for(Project_Team_Member__c proj : projectTeamList){
                    tw.projectList.add(new SelectOption(proj.Project__c, proj.Project__r.Name + ':' + proj.Project__r.Project_Name__c));
                }
                tw.selectedProj=timecardWrapperList[i].selectedProj;
                tw.savedTC=false;
                
                system.debug(tw);

                timecardWrapperList.add(tw);

                break;
            } 
        }  

        for(Integer i=0;i<timecardWrapperList.size();i++){

            timecardWrapperList[i].counterWrap = i;
        }


        Logger.pop();


    }


    /*
     * @description: This is the method that will save the Timecard entries added/updated
     *               
     */
    public void saveEntries(){
        Logger.push('saveEntries', 'TimecardController');
        List<Project_Time_Card__c> timecardToUpsert = new List<Project_Time_Card__c>();
        
        if(!timecardWrapperList.isEmpty()){


            for(TimecardWrapper tw: timecardWrapperList){
            
              system.debug(tw+'twtwtwtwtwtwtwtw');
            
                if( tw.timecard.project__r.Project_Status__c != 'Closed' && tw.isModified == true && tw.timecard.Hours__c!=0 
                        && tw.selectedProj!='None' && tw.timecard.activity_type__c != 'None' && tw.timecard.product_group__c!= 'None'){

                    if(tw.selectedProj != null && tw.timecard.Hours__c > 0){
                        Project_Time_Card__c pt = new Project_Time_Card__c();
                        pt = tw.timecard;
                        pt.Week_Ending__c = tw.weekending;
                        pt.Week_Date__c= tw.weekDate;
                        pt.AE_PE__c = UserInfo.getUserId();
                        pt.Project__c = tw.selectedProj;
                        pt.status__c='Submitted';
                        pt.Notes__c = tw.timecard.Notes__c;
                         
                        //pt.Status__c = 'Draft';

                        timecardToUpsert.add(pt);
                    } else {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,System.Label.Warning_CannotEdit_Msg);
                        ApexPages.addMessage(myMsg);
                    }


                } else if( tw.timecard.project__r.Project_Status__c != 'Closed' && tw.isModified == true && tw.timecard.Hours__c!=0 
                        && tw.selectedProj!='None' && activityTypeToInclude.contains(tw.timecard.activity_type__c)){
                    if(tw.timecard.Hours__c > 0){
                        Project_Time_Card__c pt = new Project_Time_Card__c();
                        pt = tw.timecard;
                        pt.Week_Ending__c = tw.weekending;
                        pt.Week_Date__c= tw.weekDate;
                        pt.AE_PE__c = UserInfo.getUserId();
                        pt.Project__c = tw.selectedProj;
                        pt.status__c='Submitted';
                        pt.Notes__c = tw.timecard.Notes__c;

                        timecardToUpsert.add(pt);
                    } else {

                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,System.Label.Warning_CannotEdit_Msg);
                        ApexPages.addMessage(myMsg);
                    } 
                }

            }
            
            system.debug(timecardToUpsert+'timecardToUpserttimecardToUpserttimecardToUpserttimecardToUpsert');
            try{
                if(!timecardToUpsert.isEmpty()){
                    upsert timecardToUpsert;

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,System.Label.Confirm_Save_Msg);
                    ApexPages.addMessage(myMsg);
                } 
            } catch(Exception ex){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                ApexPages.addMessage(myMsg);
                Logger.debugException(ex);
            }


            initialise();
        }       
        Logger.pop();

    }
    /*
     * @description: This is the method that will remove a row from the pageblockTable
     *               
     */
    public void removingRow(){

        Logger.push('removingRow', 'TimecardController');
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));

        List<Project_Time_Card__c> timecardList = new List<Project_Time_Card__c>();

        for(Integer i=0;i<timecardWrapperList.size();i++){
            //check if status of the project related to the timecard is not closed
            if(timecardWrapperList[i].counterWrap == param && timecardWrapperList[i].timecard.project__r.Project_Status__c != 'Closed'){


                if(timecardWrapperList[i].timecard.Id != null){

                    timecardList.add(timecardWrapperList[i].timecard);
                }
                timecardWrapperList.remove(i);     
            } else {
                if(timecardWrapperList[i].timecard.project__r.Project_Status__c == 'Closed' && timecardWrapperList[i].counterWrap == param) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,System.Label.Warning_CannotRemove_Msg);
                    ApexPages.addMessage(myMsg);

                }
            }
        }
        try{
            if(!timecardList.isEmpty()){
                delete timecardList;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,System.Label.Confirm_Delete_Msg);

                ApexPages.addMessage(myMsg);
            }

        } catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(myMsg);
            Logger.debugException(ex);
        }

        for(Integer i=0;i<timecardWrapperList.size();i++){
            timecardWrapperList[i].counterWrap = i;
        }

        Logger.pop();

    }
    /*
     * @description: This is the method that will return a Date of for the week ending
     * @param: Date - the date to be checked, dd - the integer for the week e.g. 1 = Mon, 2 = Tue, ... 6 = Sat.
     * @return: return the Week Ending Date          
     */
    private Date dayOfWeek(Date dt, Integer dd){
        Date dtToCompare = Date.newInstance(1900, 1, dd);
        integer Days = Integer.valueOf(dt.daysBetween(dtToCompare.addDays(1)));

        return dt.addDays(6 - Math.abs(Math.mod(Days, 7)));
    }

    public void  getDependentActivityPicklist(){

        system.debug('iside dependent');

        Logger.push('getDependentActivityPicklist', 'TimecardController');
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('rowCounter'));
        String activityTypeNotFound=system.label.Activity_not_found_for_Project_Purpose;


        for(Integer i=0;i<timecardWrapperList.size();i++){

            if(timecardWrapperList[i].counterWrap == param ){

                timecardWrapperList[i].activityList.clear();
                timecardWrapperList[i].activityList.add(new SelectOption('None','--None--'));


                if(projectToPurposeMap.ContainsKey(timecardWrapperList[i].selectedProj) && purposeToActivityMap.get(projectToPurposeMap.get(timecardWrapperList[i].selectedProj))!=null){

                    if(purposeToActivityMap.get(projectToPurposeMap.get(timecardWrapperList[i].selectedProj))!=null){

                        for (String s: purposeToActivityMap.get(projectToPurposeMap.get(timecardWrapperList[i].selectedProj))){ 
                            timecardWrapperList[i].activityList.add(new SelectOption(s, s));


                        }
                    }else{

                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,activityTypeNotFound);
                        ApexPages.addMessage(myMsg);

                    }

                }

                break;
            } 
        }  

        Logger.pop();


    }

    /**
     *@Author Original: kishore AN - Cloud Sherpas/Mathworks 
     *@Last Modified: 
     *@Date Original: 20 Nov2014 
     *@Last Modified: 
     * @description: This is the method used to redirect to the timecard custom page instead of the standard page
     *               on the tab and the button overrides
     */
    public PageReference PageRedirect(){
        return new PageReference('/apex/ProjectTimecard');

    }
    /**@author Original: Sagar Talele
     * @date Original: 9 April 2015
     * @Last Modified: 9 April 2015
     * @description Method will give the list of Project team member
     **/
    public List<Project_Team_Member__c> retrieveProjectTeamList(){
        //retrieve the Project Team Members sorted by Project Name.
        List<Project_Team_Member__c> projectTeamList = [SELECT Project__c, Project__r.Project_Name__c, Project__r.Name, Project__r.Purpose__c  FROM Project_Team_Member__c WHERE Resource__c = :UserInfo.getUserId() and Project__r.Is_Open__c = True ORDER BY Project__r.Project_Name__c];
        return projectTeamList;
    }
}