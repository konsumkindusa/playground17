/** 
 *@author Original: Divya Gawade - Cloud Sherpas/Mathworks, Last Modified: Divya Gawade - Cloud Sherpas/Mathworks
 *@date Original: 23 July 2014, Last Modified: 24 Nov 2014
 *@description This  is handler class for 'OpportunityLineItemTriggerHandler' .                     
*/

public class OpportunityLineItemTriggerHandler {
    
     /**
     * @author Original:Divya Gawade 
     * @date Original: 23 July 2014, Last Modified: 23 July 2014
     * @description Method that handles after insert trigger event on the Opportunity Line Item object
     * @param Account A collection of Opportunity Line Item to create new Opportunity Line Item.
     */
    public void onAfterInsert(List<OpportunityLineItem> List_OpportunityLineItem){
     Logger.push('onBeforeInsert','OpportunityLineItemTriggerHandler');
     
     // Map of Product Topic and Opportunity ID
     Map<String, Set<Id>> oppTopicMap= new Map<String, Set<Id>>();
     
     // Set of Opportunity ID
     Set <ID> opptySet = new Set <ID> ();
     
     // List of Topic assignments
     List<TopicAssignment > topicassignLst= new List <TopicAssignment > ();
     
     // Set of Topic Names
     Set<string> topicNames = new Set<string> ();
     
     // Map of Topic anmes and Id
     Map<string,Id> topicNameIdMap = new Map<string,Id> ();
     
     //Checking if the product has a value in topic custom field and getting topics on product.
        for(OpportunityLineItem oppLn : List_OpportunityLineItem){
            if(oppLn.Product_Topic__c!= null){
                
                if(oppTopicMap.containsKey(oppLn.Product_Topic__c)){
                    
                    oppTopicMap.get(oppLn.Product_Topic__c).add(oppLn.OpportunityId);
                }
                else{
                    oppTopicMap.put(oppLn.Product_Topic__c, new Set<Id>{oppLn.OpportunityId});
                }

                topicNames.add(oppLn.Product_Topic__c);
                opptySet.add(oppLn.OpportunityId);
            }
             system.debug('****oppLn***'+oppLn);   
        }
      
      
      // Query to get Topic assignments 
      List<TopicAssignment> taList = [select TopicId,EntityId,Topic.Name
                                                from TopicAssignment 
                                                where Topicid in (select id from topic where name in: topicNames) and EntityId in :opptyset];
      system.debug('@@@: passed topicAssignment' + taList);
      for(TopicAssignment topicAssign : taList)
       {
           system.debug('@@@: passed topicAssignment');
           if(oppTopicMap.containskey(topicAssign.Topic.Name) && 
               oppTopicMap.get(topicAssign.Topic.Name).contains(topicAssign.EntityId))
           {
               oppTopicMap.get(topicAssign.Topic.Name).remove(topicAssign.EntityId);
               topicNameIdMap.put(topicAssign.Topic.Name,topicAssign.TopicId);
               if(topicNames.contains(topicAssign.Topic.Name))
                   topicNames.remove(topicAssign.Topic.Name);
               if(oppTopicMap.get(topicAssign.Topic.Name).isempty())
                  oppTopicMap.remove(topicAssign.Topic.Name);
           }
       }
     
       // Query Topic records name and ID which contains in Topic Set
       for(Topic topic : [select ID,Name from Topic where Name IN :topicNames ] ){
            topicNameIdMap.put(topic.Name,topic.Id);
            topicNames.remove(topic.Name);
        }

       // Create Topic Record if it does not exist
        if(!topicNames.isempty())
        {
            list<Topic> newTopics = new List<Topic>();
            for(string str : topicNames)
            {
                newTopics.add(new Topic(Name = str));
            }
            
            insert newTopics;
            for(Topic topic : newTopics)
               topicNameIdMap.put(topic.Name,topic.Id);
        
        }
        
       // Create Topic assignment record.                                 
       for( string str : oppTopicMap.keyset())
       {
            for(Id opptyId : oppTopicMap.get(str))
            {
                Id topicId = topicNameIdMap.get(str);
                topicassignLst.add(new TopicAssignment(TopicId = topicId,
                 EntityId = opptyId ));
            }
       }
       
       Database.SaveResult[] lsr = Database.insert(topicassignLst,false);
       
     Logger.pop(); 
    }
}