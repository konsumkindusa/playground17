/*
 *@author Original:kishore AN - Cloud Sherpas/Mathworks, Last Modified:Haigang Wu
 *@date Original: 30 July 2015, Last Modified:29 Sep 2016
 *@description:This is a sample module handler class that extends the abstract class EmailToSObjectModule
 */
//HW 1693609
//public class SampleEmailToSObjectModuleHandler implements UEH_EmailToSObjectModule{
public class SampleEmailToSObjectModuleHandler extends UEH_EmailToSObjectModule implements Queueable, Database.AllowsCallouts {

    public SampleEmailToSObjectModuleHandler(){
    
    	system.debug('In Constructor');
    
    }
    
    //HW 1693609
    //public void processMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
    public override void execute(QueueableContext qContext){

        system.debug('In execute Method');  

    }
    
    public void saveMessage(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope ,id sObjectId){

        system.debug('In save Method');

    }

}