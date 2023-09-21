@isTest
private class RecordLockController_Test {
    static RecordType RT_OPPTY_DirectSales;
    static RecordType RT_OPPTY_PartnerSales;
    
    static {
        RT_OPPTY_DirectSales  = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DirectSales' Limit 1];
        RT_OPPTY_PartnerSales  = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'PartnerSales' Limit 1];
        
        Account accAct = new Account(Name = 'accTest');
        insert accAct;

        Opportunity opptyData = new Opportunity(Name ='Test', RecordTypeId = RT_OPPTY_DirectSales.Id, AccountId = accAct.Id, CloseDate = System.today(), StageName = '기회 전환');
        insert opptyData;
        
        Opportunity opptyData2 = new Opportunity(Name ='Test2', RecordTypeId = RT_OPPTY_PartnerSales.Id, AccountId = accAct.Id, CloseDate = System.today(), StageName = '기회 전환');
        insert opptyData2;
    }
    
    @isTest static void testCase() {
		Test.startTest();

        Opportunity oppty = [Select Id From Opportunity Order by CreatedDate desc LIMIT 1];

        RecordLockController.initComponent(oppty.Id);
        RecordLockController.lockRecord(oppty.Id);
        RecordLockController.unlockRecord(oppty.Id);

		Test.stopTest();
	}
	
}