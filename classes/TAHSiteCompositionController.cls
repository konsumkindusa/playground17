/**
 * @author          Pranav Raulkar
 * @date            08-June-2016
 * @description     Composition template controller
 * @revision        1.0 - Initial version
 */
public without sharing class TAHSiteCompositionController {
    /**
    *    @author        Pranav Raulkar
    *    @date          08-June-2016
    *    @description   Checks if the org is Sandbox or Production
    *    @return        Boolean
    */ 
    public Boolean getIsSandbox() {
        Logger.push('TrainingUtil', 'isSandbox');
        Organization org = [SELECT IsSandbox FROM Organization];
        Logger.pop();
        return org.IsSandbox;
    }
}