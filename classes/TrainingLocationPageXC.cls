/**
 *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
 *@date Original: 1 July 2016, Last Modified: 
 *@description This  is Controller class for 'TrainingLocationPage' . 
 *@Revision:
 */

public class TrainingLocationPageXC {
    
    //List of FieldSetMember for different sections.
    public List<FieldSetMember> detailFieldSet{get; set;}
    public List<FieldSetMember> reqDetailFieldSet{get; set;}
    public List<FieldSetMember> addressFieldSet{get; set;}
    public List<FieldSetMember> contacInfoFieldSet{get; set;}
    public List<FieldSetMember> descandNotesFieldSet{get; set;}
    public ComponentData compDataObj{get; set;}
    public Boolean stateRequired{get; set;}
    public Id trainingLocationId {get; set;}
    public Training_Location__c trainingLocationObj {get; set;}
    
    public TrainingLocationPageXC(ApexPages.StandardController controller) {
        
        compDataObj = new ComponentData();
        stateRequired = False;
        //Getting the Id from the URL
        trainingLocationId = controller.getId();
        
        //if the record is edited.
        if(trainingLocationId != null){
            
            //SS 10/24/16 726234 Changed to get the fields from field set dynamically to form a query.
            Map<String, Schema.FieldSet> TrLocFSMap= Schema.SObjectType.Training_Location__c.fieldSets.getMap();
            Set <String> TrLocFSSet = new Set <String> ();
           	TrLocFSSet.addAll(TrLocFSMap.keySet());
 
            Set <String> additionalFields = new set <String> ();
            additionalFields.add('Country__c');
            additionalFields.add('State__c');
            additionalFields.add('Location_URL__c');
            additionalFields.add('Country_Code__c');
            additionalFields.add('State_Code__c');
            additionalFields.add('Country_Code_State_Code__c');
            
            
            String query = UtilityHelper.generateQueryFromFieldSets('Training_Location__c',TrLocFSSet ,additionalFields, 'Id=\'' + trainingLocationId +  '\'');
            
            trainingLocationObj = database.query(query);
             
             //Querying the Field of the Training Location Record for Edit View.
           /*  trainingLocationObj = [SELECT Id, Name, Location_Name_Latin__c, Region__c, Location_Type__c, 
                                    Status__c, Publish_To_Web__c, Account__c, Cancellation_Lead_Time__c,Address_Line_1__c,
                                    Address_Line_2__c,Address_Line_3__c,Address_Line_4__c, City__c, Country__c, Postal_Code__c, State__c, Admin_Contact__c, 
                                    Technical_Contact__c, Location_Email__c, Location_Fax__c, Location_Phone__c, Location_URL__c, Notes__c,
                                    Country_Code__c, State_Code__c, Country_Code_State_Code__c, Directions__c FROM Training_Location__c WHERE Id =: trainingLocationId];
			*/
            //Assign the State and Country value to the component
            compDataObj.stateCode = trainingLocationObj.Country_Code_State_Code__c;
            compDataObj.countryCode = trainingLocationObj.Country_Code__c;
            compDataObj.stateName = trainingLocationObj.State__c;
            compDataObj.countryName = trainingLocationObj.Country__c;
            System.debug('##compDataObj.stateCode'+compDataObj.stateCode);    
            System.debug('##compDataObj.stateName'+compDataObj.stateName);  
            System.debug('##trainingLocation__state__c'+trainingLocationObj.State__c);
        }
        else{
            trainingLocationObj = new Training_Location__c();
        }
        
        //Getting the field name from the field set and add to the List of Field Set Members
        reqDetailFieldSet = new List<FieldSetMember>();
        for(Schema.FieldSetMember fieldMemberObj :Schema.SObjectType.Training_Location__c.fieldSets.getMap().get('NameDetailReqFS').getFields()){
            reqDetailFieldSet.add(fieldMemberObj);
        }
        
        detailfieldSet = new List<FieldSetMember>();
        
        for(Schema.FieldSetMember fieldMemberObj :Schema.SObjectType.Training_Location__c.fieldSets.getMap().get('NameDetailFieldSet').getFields()){
            detailFieldSet.add(fieldMemberObj);
        }
        
        addressFieldSet = new List<FieldSetMember>();
        
        for(Schema.FieldSetMember fieldMemberObj : Schema.SObjectType.Training_Location__c.fieldSets.getMap().get('AddressFieldSet').getFields()){          
            addressFieldSet.add(fieldMemberObj);
        }
        
        contacInfoFieldSet = new List<FieldSetMember>();
        
        for(Schema.FieldSetMember fieldMemberObj : Schema.SObjectType.Training_Location__c.fieldSets.getMap().get('ContactInfoFieldSet').getFields()){
            contacInfoFieldSet.add(fieldMemberObj);
        }
        
        descandNotesFieldSet = new List<FieldSetMember>();
        
        for(Schema.FieldSetMember fieldMemberObj : Schema.SObjectType.Training_Location__c.fieldSets.getMap().get('DescriptionandNotesFS').getFields()){
            descandNotesFieldSet.add(fieldMemberObj);
        }
    }
    
    /**
     *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
     *@date Original: 1 July 2016, Last Modified: 
     *@description: To upsert the training location record on the click of Save Button. 
     *@param: 
     *@Revision:
    */
    
    public PageReference save(){
        
        Logger.push('TrainingLocationPageXC', 'save');
        System.debug('Testing ***' +compDataObj.countryCode);
        //Check if the country is None then set the other values as none.
        if(compDataObj.countryCode == null || compDataObj.countryCode == '--None--'){
            trainingLocationObj.State_Code__c = null;
            trainingLocationObj.Country_Code_State_Code__c = null;
            trainingLocationObj.State__c = null;
            trainingLocationObj.Country__c = null;
            trainingLocationObj.Country_Code__c = null;
        }
        //if we have no state then set None as the value.
        else{
            if(compDataObj.stateCode == null || compDataObj.stateName == null || compDataObj.stateName == '--None--'){
                trainingLocationObj.State_Code__c = null;
                trainingLocationObj.State__c = null;
                trainingLocationObj.Country_Code_State_Code__c = null;
            }
            else{
                trainingLocationObj.State_Code__c = compDataObj.stateCode.remove(compDataObj.countryCode+'-');
                trainingLocationObj.State__c = compDataObj.stateName;
                trainingLocationObj.Country_Code_State_Code__c = compDataObj.stateCode;
            }
            trainingLocationObj.Country__c = compDataObj.countryName;
            trainingLocationObj.Country_Code__c = compDataObj.countryCode;
        }
        /*  SS - 1951614 - 2/23/17 - State should not be required when creating or editing locations 
        if((compDataObj.stateCode == null || compDataObj.statecode == '--None--') || (compDataObj.countryCode != null && compDataObj.countryCode != '--None--')){
            System.debug('##'+compDataObj);
            checkStateRequired();
        }
        
        if((stateRequired && (compDataObj.statecode == null || compDataObj.statecode == '--None--'))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.State_Required));
            stateRequired = False;
            return null;
        }
		*/
        //HW 1734826
        if (trainingLocationObj.Status__c == 'Mark for Deletion') {
        	if (trainingLocationObj.publish_to_web__c) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Training_location_before_update_2));
	            return null;
        	}
	        List<Class__c> classList = [SELECT Id FROM Class__c WHERE Training_Location__c =: trainingLocationObj.id LIMIT 1];
        	if (classList.size() > 0) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Training_location_before_update_2));
	            return null;
        	}
        }
        //HW 1734826
        
        try{
            //Upsert Record.
            upsert trainingLocationObj;
            return new PageReference('/' + trainingLocationObj.Id);
        }
        //Catch the Exception
        catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            Logger.debugException(ex);
        }
        
         Logger.pop();
        
        return null;
    }
    
    
    /**
     *@author Original: Abhay Verma - Accenture/Mathworks, Last Modified: 
     *@date Original: 26 July 2016, Last Modified: 
     *@description: To check if the country selected having state or not. 
     *@param: 
     *@Revision:
    */
    /*  SS - 1951614 - 2/23/17 - State should not be required when creating or editing locations 
    private void checkStateRequired(){
        Logger.push('TrainingLocationPageXC', 'checkStateRequired');
        List<Country_Code_List__mdt> countryCodeRequiresStateLst = [SELECT Country_Code__c, Country_Long_Name_Latin__c FROM Country_Code_List__mdt where Require_States__c=true AND Country_Code__c =: compDataObj.countryCode order by Country_Code__c];
        if(countryCodeRequiresStateLst.size() > 0){    
            stateRequired = True;
        }
        System.debug('##'+stateRequired);
        Logger.pop();
    }
    */
}//End of Class