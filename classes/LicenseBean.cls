/**
     *Author Original: Sagar Talele - Cloud Sherpas/Mathworks 
     *Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *Date Original: 9 October 2014 
     *Last Modified: 9 October 2014
     *Description: Method to parse json to licenseJsonString
    */
public class LicenseBean
{
    public integer totalNumber { get; set; }
    public List<License> licenses { get; set; }
    
    public class LicensedProduct
{
    public integer productId { get; set; }
    public string productName { get; set; }
    public integer quantity { get; set; }
    public string allocationStatus { get; set; }
    public string maintenanceEndDate { get; set; }
}

public class License
{
    public string id { get; set; }
    public string licenseAccountId { get; set; }
    public string overrideAccountId { get; set; }
    public string administratorId { get; set; }
    public string option { get; set; }
    public string use { get; set; }
    public string term { get; set; }
    public string status { get; set; }
    public string coreProductEndDate { get; set; }
    public string prorateDate { get; set; }
    public integer maintenanceGroupId { get; set; }
    public List<LicensedProduct> licensedProducts { get; set; }
}
 /**
     *Author Original: Sagar Talele - Cloud Sherpas/Mathworks 
     *Last Modified: Sagar Talele - Cloud Sherpas/Mathworks
     *Date Original: 9 October 2014 
     *Last Modified: 9 October 2014
     *Description: Method to parse json to licenseJsonString
    */
    public static LicenseBean getParsedLicenseJson(String jsonToParse){
        try{
            //List<String> contactSiebelId;
           // Map<String,Contact> mapContact;
          //  List<String> accountSiebelId;
            //Map<String,Account> mapAccount;
            System.debug('In getParsedLicenseJson'+jsonToParse);
            LicenseBean jsonToObjs = (LicenseBean )JSON.deserialize(jsonToParse, LicenseBean.class);
            System.debug('!!!!!!!!!In LicenseBean parsed'+jsonToObjs);
            return jsonToObjs;
        }
        catch(JSONException ex){
            System.debug('%%%'+ex);
            UtilityHelper.addErrorMessage(ex.getMessage());
            Logger.debugException(ex);
            Logger.pop();
            return null;
        }
    }
}