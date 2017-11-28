/**
 *author Original: Jaspreet Monga - Mathworks, 
 *date Original: 06 June 2014, 
 *description This trigger will delete chatter feed on article whenever a comment with text #deletethisThread is added to it
 */
trigger deleteFeedItem on FeedComment (after insert, after update) {

List<Id> listFeedItemId = new List<Id>();

for(FeedComment objFeedComment: trigger.new)
{
    if(objFeedComment.commentBody.equalsIgnoreCase(Label.DeleteFeedITem)) 
    {
       listFeedItemId.add(objFeedComment.FeedItemId);
    
    }
    
}
DeleteFeedItem.methodDeleteFeedItem(listFeedItemId);

}