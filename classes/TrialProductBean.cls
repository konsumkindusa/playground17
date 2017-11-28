public with sharing class TrialProductBean {

	public class EntitlementProductBean
	{
		public string productId { get; set; }
		public string productName { get; set; }
		public string productBaseCode { get; set; }
		public string bitNumber { get; set; }
		public string seatQty { get; set; }
		public string defaultLicenseFileExpirationDate { get; set; }
		public string productSmsEndDate { get; set; }
	}

	public class Products
	{
		public List<EntitlementProductBean> entitlementProductBean { get; set; }
	}

	public class EntitlementReleaseBean
	{
		public string passcodeVersionNumber { get; set; }
		public string shippedDate { get; set; }
		public string name { get; set; }
		public Products products { get; set; }
		public string fik { get; set; }
	}


	public List<EntitlementReleaseBean> entitlementReleaseBean { get; set; }

	public static TrialProductBean parse(String json) {
		return (TrialProductBean) System.JSON.deserialize(json, TrialProductBean.class);
	}

}