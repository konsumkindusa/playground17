public class SerializedTrials {

 public class EntitlementPolicyBean
{
    public string id { get; set; }
    public string policyName { get; set; }
    public string allowedActivationCount { get; set; }
    public string allowedAnnualMachineTransferCount { get; set; }
    public string allowedAnnualUserTransferCount { get; set; }
    public string allowedAnnualProductTransferCount { get; set; }
    public string licensedEndUserRequired { get; set; }
    public Boolean validationDefault { get; set; }
    public Boolean validationDefaultOverridable { get; set; }
    public Boolean licenseFileExpirationOverrideAllowed { get; set; }
    public Boolean dcProcessCheckRequired { get; set; }
    public string maxLicensedEndUsers { get; set; } 
    public Integer validationIntegerervalDays { get; set; }
    public string disassociateSetting { get; set; }
    public Boolean associateByLicenseNumber { get; set; }
    public Boolean leuSynchronizationRequired { get; set; }
    public Integer allowedSimultaneousSessionCount { get; set; }
    public Boolean licenseManagementTypeUpdatable { get; set; }
    public Integer simultaneousMachineCountPerLeu { get; set; }
    public string profileAssociationType { get; set; }
    public Boolean userLoginNameRequired { get; set; }
    public Boolean displayStudentReminder { get; set; }
    public Boolean autoAssociateLeu { get; set; }
    public Boolean activateForOther { get; set; }
    public Boolean accessToDownloadOnly { get; set; }
    public string emailDomain { get; set; }
}

public class People
{
    public List<object> entitlementPersonBean { get; set; }
}

public class ActivationKeys
{
    public List<object> activationKeyBean { get; set; }
}

public class Products
{
    public List<object> entitlementProductBean { get; set; }
}

public class EntitlementReleaseBean
{
    public Integer passcodeVersionNumber { get; set; }
    public string shippedDate { get; set; }
    public string name { get; set; }
    public Products products { get; set; }
    public string fik { get; set; }
}

public class Releases
{
    public List<EntitlementReleaseBean> entitlementReleaseBean { get; set; }
}

public class TsurExtendTrialHistory
{
    public List<TsurExtendTrialHistoryBean> tsurExtendTrialHistoryBean { get; set; }
}

public class TsurExtendTrialHistoryBean
{
    public String extendDate { get; set; }
    
}

public class OnDemand
{
    public string status { get; set; }
    public Integer statusId { get; set; }
    public Boolean mwAllowed { get; set; }
    public Boolean customerOptIn { get; set; }
    public Boolean entitlementEligible { get; set; }
    public Boolean creditCardEligible { get; set; }
    public Boolean userAccessDefault { get; set; }
}

public class Name
{
}

public class Properties
{
    public List<string> property { get; set; }
}

public class LockingType
{
    public Name name { get; set; }
    public string displayLabel { get; set; }
    public Properties properties { get; set; }
}


public class LockingTypes
{
    public List<LockingType> lockingType { get; set; }
}

public class EntitlementBean
{
    public string id { get; set; }
    public string accessToActivationKeyDefault { get; set; }
    public string accessToDownloadsDefault { get; set; }
    public string accessToLoginNamedUserDefault { get; set; }
    public string accessToMatlabOnTheWebDefault { get; set; }
    public Boolean activatable { get; set; }
    public Integer activationsRemaining { get; set; }
    public string activationTypeId { get; set; }
    public string activationType { get; set; }
    public string displayLabel { get; set; }
    public Boolean allProductFIKApproval { get; set; }
    public Boolean multipleReleaseLicenseFile { get; set; }
    public Boolean allowActivationTypeUpdate { get; set; }
    public Integer computerRedesignationsRemaining { get; set; }
    public Integer computeLocationTypeId { get; set; }
    public string computeLocation { get; set; }
    public string controllingProduct { get; set; }
    public string controllingProductSmsEndDate { get; set; }
    public string countryCode { get; set; }
    public string createdById { get; set; }
    public string createdDateTime { get; set; }
    public string currentActivationKey { get; set; }
    //public object customerReleaseOverride { get; set; }
    public string distributorFirstName { get; set; }
    public string distributorLastName { get; set; }
    public EntitlementPolicyBean entitlementPolicyBean { get; set; }
    public string entitlementStatusTypeId { get; set; }
    public string entitlementStatus { get; set; }
    public string entitlementTypeId { get; set; }
    public string entitlementType { get; set; }
    public string expirationDateOverridable { get; set; }
    public string firstActivationDate { get; set; }
    public string groupLicenseId { get; set; }
    public string lastUpdatedById { get; set; }
    public string lastUpdatedDateTime { get; set; }
    public string licenseNumber { get; set; }
    public string licenseDongleRequired { get; set; }
    public string licenseFileDefinitionId { get; set; }
    public string licenseFileDefinitionName { get; set; }
    public string licenseFileExpirationOverrideDate { get; set; }
    public string licenseFileExpirationDate { get; set; }
    //public object licenseOption { get; set; }
    public string licenseOptionDescription { get; set; }
    //public object licenseTerm { get; set; }
    public string licenseTermDescription { get; set; }
    //public object licenseUse { get; set; }
    public string licenseUseDescription { get; set; }
    //public object loginNamedUserAvailable { get; set; }
    public string mutable { get; set; }
    public Integer officeId { get; set; }
    public string opportunityId { get; set; }
    public People people { get; set; }
    public ActivationKeys activationKeys { get; set; }
    public Releases releases { get; set; }
    public string sector { get; set; }
    public Integer trialExtensionCount { get; set; }
    public string trialReminder { get; set; }
    public string tsurType { get; set; }
    public Integer tsurTypeId { get; set; }
    public string tsurSubType { get; set; }
    public Integer tsurSubTypeId { get; set; }
    //public object tsurReleaseId { get; set; }
    public string tsurInitialExpirationDate { get; set; }
    public TsurExtendTrialHistory tsurExtendTrialHistory { get; set; }
    public string userDefinedLabel { get; set; }
    public Integer userRedesignationsRemaining { get; set; }
    public Boolean validationSetting { get; set; }
    public Boolean validating { get; set; }
    public Integer licensedEntitlementSubTypeId { get; set; }
    public string licensedEntitlementSubType { get; set; }
    //public object auditInformation { get; set; }
    public Boolean isNetwork { get; set; }
    public Integer personEntitlementId { get; set; }
    public Integer rollupEntitlementId { get; set; }
    public string licenseManagerType { get; set; }
    public Integer licenseManagerTypeId { get; set; }
    public OnDemand onDemand { get; set; }
    public LockingTypes lockingTypes { get; set; }
}

  public Integer summaryCount{get;set;}
  public List<EntitlementBean> entitlementBean {get;set;}
 
  public static SerializedTrials parse(String json) {
  return (SerializedTrials) System.JSON.deserialize(json, SerializedTrials.class);
 }
}