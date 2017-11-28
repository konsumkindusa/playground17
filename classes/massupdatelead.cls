/**
 * @author Original: Jaspreet Monga - Mathworks,
 * @date Original: 4/6/2015
 * @description Class to handle mass lead update
 * @Revision :
 */

public class massupdatelead{

  
    public List<Lead> listLeadDisplayOnPage;  // will display list of leads which will be updated
    public Contact objContactDatefield;             // Contact obj to dispay Lead Follow Up Date in calander format 
    public List<SelectOption> statusOptions;  // Picklist values for status 
    public List<SelectOption> outcomeOptions; // Picklist values for outcome
    public String setStatusValues {get;set;}  // String for status values 
    public String setOutcomeValues {get;set;} // String for outcome values
    public String errorMsg {get;set;}
    

 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description getter for sObject Lead
 * @param 
 **/

    public Contact getobjContactDatefield ()
    {
     objContactDatefield= new Contact();
     return objContactDatefield;
    }
 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description setter for sObject Lead
 * @param 
 **/

    public void setobjContactDatefield(){
       // isUpdated =this.isUpdated ;
    } 

 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description getter for Status option
 * @param 
 **/   
    
    public List<SelectOption> getstatusOptions () {
    // Set status field options      
     statusOptions  = new List<SelectOption>(); 
     Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
     statusOptions.add(new SelectOption('--None--', '--None--'));       
       for( Schema.PicklistEntry f : ple)
       {
          statusOptions .add(new SelectOption(f.getLabel(), f.getValue()));
       }       
      return  statusOptions;     
    }
 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description getter for outcome options
 * @param 
 **/


    public List<SelectOption> getoutcomeOptions () {
    // Set outcome field options      
     outcomeOptions  = new List<SelectOption>(); 
     Schema.DescribeFieldResult fieldResultOutCome = Lead.Outcome__c.getDescribe();
     List<Schema.PicklistEntry> outcome = fieldResultOutCome.getPicklistValues();
     outcomeOptions.add(new SelectOption('--None--', '--None--'));       
       for( Schema.PicklistEntry f : outcome)
       {
          outcomeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       
     return outcomeOptions;
            
    }

 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description getter for list of lead objects
 * @param 
 **/
   
    public List<Lead> getlistLeadDisplayOnPage  () {
   
    String recordIDs  =  ApexPages.currentPage().getParameters().get('Ids');
    List<String> listofIDs = recordIds.split(',',0);
    listLeadDisplayOnPage =[Select Id,Status,Name,Outcome__c,Lead_Follow_Up_Date__c  from Lead where Id IN :listofIDs limit 50000];
    
    return listLeadDisplayOnPage;
    }
    
 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description method will mass update the lead records
 * @param 
 **/
  
public pageReference methodUpdateValues()
{
     Logger.push('methodUpdateValues','massupdatelead');
     PageReference pageRef;
     
    /* Put this message in next sprint 
     if(objContactDatefield.Birthdate == null && (setOutcomeValues =='' || setOutcomeValues =='--None--'))
      {
       errorMsg =  'Please enter a value to update fields';
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Please enter a value to the field to be updated'));
       pageRef  = null;
       return null;
      } */
      
    for(Lead objNewLeadValue:listLeadDisplayOnPage)
    {
     
     if(objContactDatefield.Birthdate != null)
     {
         objNewLeadValue.Lead_Follow_Up_Date__c = objContactDatefield.Birthdate;
     }
     
     /*if(setStatusValues != '' && setStatusValues !='--None--')
     {
         objNewLeadValue.Status = setStatusValues;
     }*/
     
     if(setOutcomeValues !='' && setOutcomeValues !='--None--')
     {
       objNewLeadValue.Outcome__c = setOutcomeValues;
     }
    }
    try{
        update listLeadDisplayOnPage;
        
        pageRef = new PageReference('/apex/Lead_mass_update_confirmation?action=completed');     
    }
    
    catch(DmlException ex){
    
    for (Integer i = 0; i < ex.getNumDml(); i++) {
      errorMsg = ex.getDmlMessage(i); 
    }
    errorMsg =  ex.getMessage();
   
    ApexPages.addMessages(ex);
    pageRef  = null;

    
    }

 Logger.pop(); 
 return pageRef ;
 
}

 
/**
 * @author Original: Jaspreet
 * @date Original: 4/6/2015
 * @description method will cancel the request
 * @param 
 **/
public pageReference cancel()
{
 
    PageReference pageRef = new PageReference('/apex/Lead_mass_update_confirmation?action=cancelled');     
    return pageRef ;
}
}