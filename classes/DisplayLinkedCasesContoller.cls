public with sharing class DisplayLinkedCasesContoller {

transient List<Case> ListCases; //DL: transient added for view state issue
List<KnowledgeArticle> ListArticle;
private integer totalRecords = 0;
private integer index = 0;
private integer blockSize = 10;
public string artNumber;


 public List<Case> getReq()
 {
	
  /// Get the data for the list

 	artNumber = ApexPages.currentPage().getParameters().get('ArticleNumber');
 	ListArticle = [Select Id,ArticleNumber from KnowledgeArticle where ArticleNumber =:artNumber limit 1];
 	String artId = ListArticle[0].Id;
 	ListCases = [Select c.Id,c.Subject, c.CaseNumber,c.Status,c.Description,c.CreatedDate From Case c where c.id in ( select caseid from casearticle ca where ca.KnowledgeArticleId= :artId) order by c.CreatedDate DESC limit 1000];
	totalRecords = [Select count() From Case c where c.id in ( select caseid from casearticle ca where ca.KnowledgeArticleId= :artId) limit 1000];

 return  ListCases;
 
 }


  public void beginning()
    {
        index = 0;
    }
    
    public void previous()
    {
        index = index - blockSize;
    }
    
    public void next()
    {
        index = index + blockSize;
    }

    public void end()
    {
        
        if(math.mod(totalRecords,blockSize)==0)
			index= totalRecords -blockSize; 
		else
		index = totalRecords - math.mod(totalRecords,blockSize);
    }        
    
    public boolean getprev()
    {
        if(index == 0)
        return true;
        else
        return false;
    }  
    
    public boolean getnxt()
    {
        if((index + blockSize) > totalRecords)
        return true;
        else
        return false;
    }         


	
}