@isTest
public without sharing class WeeklyReportsController_Test {
    public static WeeklyReport__c wr;
    
    static {
        Account accAct = new Account(Name = 'accTest');
        insert accAct;

        wr = new WeeklyReport__c(
            Name = 'Weekly Report', 
            ReportingDate__c = system.today(), 
            Critical__c = true,
            CheckedforIssue__c = true,
            team__c = true,
            Office__c = true,
            //Contents__c = 'longtext contents',
            IssueDescription__c = '<div>test</div>',
            account_name__c = accAct.id
        );

        insert wr;
    }

    @isTest static void testCase1() {
		Test.startTest();
        system.debug(WeeklyReportsController.getMyDomain());
        system.debug(WeeklyReportsController.getWeeklyReports(system.today()));
        system.debug(WeeklyReportsController.getIssueReports(system.today()));
        system.debug(WeeklyReportsController.getTeamReports(system.today()));
        system.debug(WeeklyReportsController.getOfficeReports(system.today()));
        system.debug(WeeklyReportsController.getWeeklyReport(wr.Id));
        system.debug(WeeklyReportsController.getIssueReport(wr.Id));
        system.debug(WeeklyReportsController.saveWeeklyContent(wr.Id, '<div>update</div>', 1));
        system.debug(WeeklyReportsController.saveIssuesContent(wr.Id, '<div>update</div>', 1));
        list<String> lwr = new list<String>{wr.Id};
        system.debug(WeeklyReportsController.getEmailWeeklyContents(lwr));
        system.debug(WeeklyReportsController.getEmailIssuesContents(lwr));
        list<String> emails = new list<String>();
        emails.add('user@email.com');
        system.debug(WeeklyReportsController.sendReportKnoxEmail(emails, 'subject', '<div>update</div>'));
		Test.stopTest();
	}

    @isTest static void testCase2() {
        Test.startTest();
        try {
            system.debug(WeeklyReportsController.getWeeklyReports(null));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.getWeeklyReport('000000'));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.saveWeeklyContent(null, '<div>update</div>', 1));
        } catch(Exception e){
            //
        }
		Test.stopTest();
	}

    @isTest static void testCase3() {
        Test.startTest();
        try {
            system.debug(WeeklyReportsController.getIssueReports(null));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.getIssueReport('000000'));
        } catch(Exception e){
            //
        }
        try {
            system.debug(WeeklyReportsController.saveIssuesContent(null, '<div>update</div>', 1));
        } catch(Exception e){
            //
        }
		Test.stopTest();
	}

    @isTest static void testCase4() {
        Test.startTest();
        try {
            list<String> emails = new list<String>();
            emails.add('user@email.com');
            system.debug(WeeklyReportsController.sendReportKnoxEmail(emails, 'subject', '<div>update</div>'));
        } catch(Exception e){
            //
        }
        try {
            list<String> emails = new list<String>();
            emails.add('user@email.com');
            system.debug(WeeklyReportsController.sendReportKnoxEmail(emails, null, '<div>update</div>'));
        } catch(Exception e){
            //
        }
		Test.stopTest();
	}
}