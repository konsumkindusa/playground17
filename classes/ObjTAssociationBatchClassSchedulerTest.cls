/***************************************************************************************
 * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
 * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
 * description This batch claremaiss feth the dupilcate records and keeps one record and
 * delete the other duplicate records
 *
 ****************************************************************************************/
@isTest
public class ObjTAssociationBatchClassSchedulerTest{
    /***************************************************************************************
     * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele 
     * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
     * description This methods test for accounts that are associated with multiple territory records then it 
     * checks for account and get that territoryid and delete the other ObjectTerritory2Association records.
     ****************************************************************************************/
    static testMethod void scheduleClsTest() { 
        Test.startTest();
        ObjTAssociationBatchClassScheduler tstSchCls = new ObjTAssociationBatchClassScheduler();
        String chron = '0 0 0 * * ?';        
        system.schedule('oT2A Request Job', chron, tstSchCls);
        Test.stopTest();
    }
}