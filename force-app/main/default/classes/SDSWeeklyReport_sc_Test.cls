/**
 * @description       : 
 * @author            : masterK
 * @group             : 
 * @last modified on  : 09-27-2022
 * @last modified by  : masterK
**/
@IsTest
private class SDSWeeklyReport_sc_Test {

    static testMethod void testBehavior() {
        Test.startTest();

        String CRON_EXP = '0 0 8 * * ?';
        String jobId = System.schedule('SDSWeeklyReport_sc', CRON_EXP, new SDSWeeklyReport_sc());

        Test.stopTest();
    }
    
    
}