/**
 * @description       : 
 * @author            : masterK
 * @group             : 
 * @last modified on  : 09-27-2022
 * @last modified by  : masterK
**/
@isTest(seeAllData=true)
private class SDSWeeklyReport_ba_Test {
	
    static testMethod void testCase1() {
        	
        Test.startTest();

        SDSWeeklyReport_ba  batch = new SDSWeeklyReport_ba();
        Database.executeBatch(batch, 5);

        Test.stopTest();
    }  


}