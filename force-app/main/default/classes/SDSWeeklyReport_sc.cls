/****************************************************************************************
  * ===============================================================
  * Ver  Date          Author         Modification
  * ===============================================================
    1.0  2021. 05. 21  masterK       Create
****************************************************************************************/
global without sharing class SDSWeeklyReport_sc implements Schedulable{
    global void execute(SchedulableContext SC) {
        /*
         * callout limit으로 인해 100을 기준으로 일괄 적용한다.
         */
        SDSWeeklyReport_ba batch = new SDSWeeklyReport_ba();
        Database.executeBatch(batch, 10);
    }
}