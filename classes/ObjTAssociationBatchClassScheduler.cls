/***************************************************************************************
 * author Original: Sagar Talele - Cloud Sherpas/Mathworks, Last Modified:Sagar Talele
 * date Original: 26 Feb 2016, Last Modified: 26 Feb 2016
 * description This ScheduledBatchable class for batch class ObjT2AssociationScheduledBatchable 
 *
 ****************************************************************************************/
global class ObjTAssociationBatchClassScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      ObjectTerritory2AssociationBatchClass  batchObj = new ObjectTerritory2AssociationBatchClass(); 
      database.executebatch(batchObj,200);
   }
}