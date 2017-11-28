/**
 *author Original: Archana Lohar - Cloud Sherpas/Mathworks, Last Modified: Haigang Wu - Mathworks
 *date Original: 13 May 2014, Last Modified: 30 Aug 2016
 *description This  is handler class for 'AccountMasterTrigger' . 
 */
public with sharing class CheckRecursive {
    
    
    public static boolean run = true;
    public static boolean runTransferOnlyOldOwnersActivities = true;
    
    private CheckRecursive(){
    }
        public static boolean runOnce(){
	        system.debug('****************** run is ' + run);
	        if(run){
	           run=false;
	         return true;
	        }else{
	            return run;
	        }
        }

	    //HW, 1693606
        public static boolean runOnceTransferOnlyOldOwnersActivities(){
	        system.debug('****************** runTransferOnlyOldOwnersActivities is ' + runTransferOnlyOldOwnersActivities);
	        if(runTransferOnlyOldOwnersActivities){
	           runTransferOnlyOldOwnersActivities=false;
	         return true;
	        }else{
	            return runTransferOnlyOldOwnersActivities;
	        }
        }
    	//1693606
}