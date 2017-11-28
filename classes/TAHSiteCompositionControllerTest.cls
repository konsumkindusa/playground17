@isTest
public without sharing class TAHSiteCompositionControllerTest {
    public static testmethod void testOrganizationType() {
        TAHSiteCompositionController ctrl = new TAHSiteCompositionController();
        System.assert(ctrl.getIsSandbox() != null);
    }
}