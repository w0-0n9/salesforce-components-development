@isTest
private class HomeCalendarController_Test {
	static User u;
	static Account acc;
	//static AccountPlan__c accPlan;
	static Opportunity pastOpp;
    static Opportunity futureOpp;
	//static Opportunity_Activity__c pastOpptyAct;
    //static Opportunity_Activity__c futureOpptyAct;

	static {
		user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		system.runAs (admin) {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
			list<User> lu = new list<User>();
			u = new User(Alias = 'standt1', Email='user0001@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0001@samsung.com');
			insert u;
		}
		Event ev = new Event(Subject='Test', StartDateTime=system.now(), EndDateTime=system.now(), OwnerId=u.Id);
		insert ev;

		Task tsk = new Task(Subject='Test', ActivityDate=system.today(), OwnerId=u.Id);
		insert tsk;

		acc = new Account(Name = 'Test Account');
		insert acc;

        /*
		accPlan = new AccountPlan__c(
			AccountId__c = acc.Id,
			Name = 'Test Account Plan',
			StartDateTime__c = System.now(),
			OwnerId = u.Id
		);
		insert accPlan;
		*/
        
		pastOpp = new Opportunity(
			Name = 'Test Opportunity', 
			OwnerId = u.Id,
			StageName = 'Z01',
			CloseDate = System.today().addDays(-1)
		);
		insert pastOpp;
        
        futureOpp = new Opportunity(
			Name = 'Test Opportunity', 
			OwnerId = u.Id,
			StageName = 'Z01',
			CloseDate = System.today()
		);
		insert futureOpp;

        /*
		pastOpptyAct = new Opportunity_Activity__c(
			WhatId__c = pastOpp.Id,
			EndDate__c = System.today().addDays(-1),
            ExtID__c = pastOpp.Id + '_' + pastOpp.StageName
		);
		insert pastOpptyAct;
        */
        
        /*
        futureOpptyAct = new Opportunity_Activity__c(
			WhatId__c = futureOpp.Id,
			StartDate__c = System.today(),
            ExtID__c = futureOpp.Id + '_' + futureOpp.StageName
		);
		insert futureOpptyAct;
		*/
	}

	@isTest static void test_method_one() {
		Test.startTest();

		system.runAs (u) {
			String sYear = String.valueOf(system.today().year());
			String sMonth = String.valueOf(system.today().month());
			String sDate = system.now().format('yyyy-MM-dd');
			String jsonData = '{"Event":true,"Task":true,"AcctPlan":true,"OpptyAct":true}';
			system.debug(HomeCalendarController.getMyActivities(sYear, sMonth, jsonData, false));
			system.debug(HomeCalendarController.getTodayActivities(sDate,jsonData,false));
		}
		Test.stopTest();
	}
    
    @isTest static void test_method_two() {
		Test.startTest();

		system.runAs (u) {
			String sYear = String.valueOf(system.today().year());
			String sMonth = String.valueOf(system.today().month());
			String sDate = system.now().addDays(-1).format('yyyy-MM-dd');
			String jsonData = '{"Event":true,"Task":true,"AcctPlan":true,"OpptyAct":true}';
			system.debug(HomeCalendarController.getMyActivities(sYear, sMonth, jsonData, false));
			system.debug(HomeCalendarController.getTodayActivities(sDate,jsonData,false));
		}
		Test.stopTest();
	}
}