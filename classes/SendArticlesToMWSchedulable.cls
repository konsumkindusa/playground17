/*
* @author Original: Jesfer Baculod - Cloud Sherpas/Mathworks 
* @date   Original: 03 July 2013, Last Modified: 16 September 2013
* @description: Schedulable class that will handle sending of Articles to MW
*/
global class SendArticlesToMWSchedulable  implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        //Resets the info of the Custom Setting
        Send_Article_Settings__c saset = Send_Article_Settings__c.getOrgDefaults();
        string sedName = saset.SchedulerName__c;
        System.Debug('Scheduler Name:'+sedName);
        saset.Number_of_Articles_Sent__c = 0;
        update saset;
        
        RemoteAppSettings__c remApp = RemoteAppSettings__c.getInstance('articlestoanswers');
        String userSessionId;
        if(remApp!= null){
            System.Debug('remote App settings:'+remApp); 
            UserSessionHelper.requestAccessToken(remApp.username__c, remApp.password__c, remApp.consumer_key__c, remApp.consumer_secret__c,remApp.endpoint_url__c);
            
            SendArticlesSession__c sases = SendArticlesSession__c.getOrgDefaults();
            userSessionId  = sases.sessionId__c;
            System.Debug('SessionId:'+userSessionId);
        }
       
        //execute sending of Articles to Mathworks
        SendArticlesToMW.sendArticles(userSessionId);
        
         
        //Abort previous scheduled run
        List<CronJobDetail> cronJob = [Select Id, Name From CronJobDetail Where Name =:sedName];        
        if(cronJob != null && cronJob.size() > 0){
            list <CronTrigger> runningJob = [Select Id, NextFireTime, PreviousFireTime From CronTrigger Where CronJobDetailId  = : cronJob[0].Id];
            if (runningJob.size() > 0){
                system.abortJob(runningJob[0].Id);
            }
        }
        
        //create and schedule another run for sending of articles (currently set interval is 15mins)
        SendArticlesToMWSchedulable satmwsc = new SendArticlesToMWSchedulable();
        String min = String.valueOf(Datetime.now().minute() + 15);
        String hour = '';
        //Add one hour to current hour
        if (Integer.valueof(min) > 59){
            Integer fixmin = Datetime.now().minute() + 15;
            fixmin = fixmin - 60;
            min = String.valueof(fixmin);
            if (Integer.valueof(Datetime.now().hour()) < 23){
                hour = String.valueOf(Datetime.now().hour() + 1);
            }
            //Reset hour to 00 - a new day has come
            else {
                hour = String.valueOf(Datetime.now().hour() - 23);
            }
        }
        //Set current hour
        else {
            hour = String.valueOf(Datetime.now().hour());   
        }
        //String ss = String.valueOf(Datetime.now().second()); 
        String nextFireTime = '0' + ' ' + min + ' ' + hour + ' * * ?';
        System.schedule(sedName, nextFireTime, satmwsc);
    }
}