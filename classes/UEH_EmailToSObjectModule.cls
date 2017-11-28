/*
 *@author Original:kishore AN - Cloud Sherpas/Mathworks, Last Modified: Haigang Wu
 *@date Original: 30 July 2015, Last Modified:29 Sep 2016
 *@description:This is an interface that any module that want to use emailtoSObject has to implement
 *@revision:30 July 2015|Archana Lohar|Added new method saveMessage 
 *@revision:29 Sep 2016|Haigang Wu|1693609, Changed from interface to abstract class
 */

global abstract class UEH_EmailToSObjectModule{
    public Messaging.InboundEmail email { get; set;}
    public Messaging.InboundEnvelope envelope { get; set;}
	
	public UEH_EmailToSObjectModule () {}
    
    global abstract void execute(QueueableContext qContext);
    
}