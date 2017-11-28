public with sharing class TrialPeopleBean {
	
	public class EntitlementPersonBean
{
    public string role { get; set; }
    public string webProfileId { get; set; }
   // public Object webProfileUserId { get; set; }
    public string firstName { get; set; }
    public string lastName { get; set; }
    public string latinFirstName { get; set; }
    public string latinLastName { get; set; }
    public string emailAddress { get; set; }
    public string accountName { get; set; }
    public string latinAccountName { get; set; }
    public string department { get; set; }
    public string countryCode { get; set; }
    public string latinDepartment { get; set; }
    public string roleId { get; set; }
    public string accessToActivationKeyOverride { get; set; }
    public string accessToDownloadOverride { get; set; }
    public string accessToLoginNamedUserOverride { get; set; }
    public string accessToMatlabOnTheWebOverride { get; set; }
    public List<string> permissionList { get; set; }
    public string entitlementId { get; set; }
    public string accessToOnDemandOverride { get; set; }
}

public class People
{
    public List<EntitlementPersonBean> entitlementPersonBean { get; set; }
}


    public Integer summaryCount { get; set; }
    public People people { get; set; }
    
    public static TrialPeopleBean parse(String json) {
     return (TrialPeopleBean) System.JSON.deserialize(json, TrialPeopleBean.class);
 }


}