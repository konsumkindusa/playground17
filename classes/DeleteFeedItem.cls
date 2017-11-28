/**
 *author Original: Jaspreet Monga - Mathworks, 
 *date Original: 6 June 2015, 
 *description : This class will call a future method to delete feed post on article whenever a comment with text #DeleteThisThread is added to it
 */
global class DeleteFeedItem
{
    @future
    public static void methodDeleteFeedItem(List<ID> listFeedItemId)
    {   
         
        system.debug(listFeedItemId + ' -- listFeedItemId');
        List<FeedItem> listFeedItem = [Select id,parentId from FeedItem where Id IN: listFeedItemId limit 1000];
        List<FeedItem> deleteFeedItem = new List<FeedItem>();
        for(FeedItem objFeedItem: listFeedItem)
        {
          if(objFeedItem.ParentId.getSObjectType().getDescribe().getLabel() ==  'FAQ') 
          {
           deleteFeedItem.add(objFeedItem);
          }
       }
        delete deleteFeedItem;
    }
}