public without sharing class WeeklyReportsController {
    @AuraEnabled
    public static string getMyDomain(){
        String domain = '';
        try {
            String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
            domain = urlInstance.removeEndIgnoreCase('.my.salesforce.com');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return domain;
    }

    @AuraEnabled
    public static list<WeeklyReport__c> getWeeklyReports(Date reportDate){
        list<WeeklyReport__c> lstWR = new list<WeeklyReport__c>();
        try {
            Date startDate = reportDate.toStartOfWeek();
            Date endDate = startDate.addDays(7);
            list<User> owners = RoleUtil.getAllSubordinates(UserInfo.getUserRoleId());
            lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                     FROM WeeklyReport__c
                     WHERE Critical__c = true
                        AND ReportingDate__c >= :startDate
                        AND ReportingDate__c < :endDate
                        AND OwnerId IN :owners 
                     ORDER BY DisplayOrder__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWR;
    }

    @AuraEnabled
    public static WeeklyReport__c getWeeklyReport(String recordId){
        WeeklyReport__c record = new WeeklyReport__c();
        try {
             record = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                      FROM WeeklyReport__c
                      WHERE Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return record;
    }

    @AuraEnabled
    public static Boolean saveWeeklyContent(String recordId, String content, Integer order){
        try {
            WeeklyReport__c record = new WeeklyReport__c();
            record.Id = recordId;
            //record.Contents__c = content;
            record.IssueDescription__c = content;
            if(order != null) record.DisplayOrder__c = order;
            
            update record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return true;
    }

    @AuraEnabled
    public static String getEmailWeeklyContents(list<String> reportIds){
        list<WeeklyReport__c> records = new list<WeeklyReport__c>();
        String contents = '';
        try {
            records = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                       FROM WeeklyReport__c
                       WHERE Id IN :reportIds 
                       ORDER BY DisplayOrder__c ASC];
            String myDomain = 'https://' + getMyDomain() + '.lightning.force.com';
            String body = '';
            String divHeader   = '<div style="padding-bottom: 8px;">';
            String divFooter   = '</div>';
            String tableHeader = '<table border="0" cellpadding="0" cellspacing="0" style="background-color: #F3F2F2;font-family:tahoma;font-size:10pt;border-top:0.1px solid black;border-left:0.1px solid black;border-right:0.1px solid black;border-bottom:0.1px solid black;">';
            String tableFooter = '</table>';
            String trHeader    = '<tr>';
            String trFooter    = '</tr>';
            String th1Header   = '<td style="width:150px;line-height:32px;text-align:right;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th2Header   = '<td colspan="2" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th4Header   = '<td colspan="4" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String td1Header   = '<td width="50%" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td3Header   = '<td colspan="3" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td4Header   = '<td colspan="4" style="background-color:#ffffff;border: 0.1px solid black;padding:16px;">';
            String tdhFooter   = '</td>';

            if(!records.isEmpty()){
                for(WeeklyReport__c record : records){
                    body += divHeader;
                    body += tableHeader;

                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_NAME + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/WeeklyReport__c/' + record.Id + '/view" target="_blank">' +  + record.Name.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_DEPT_NAME + tdhFooter;
                    if(record.Department__c != null ) {
                        body += td1Header + record.Department__c + tdhFooter;
                    } else {
                        body += td1Header + '' + tdhFooter;
                    }
                    body += trFooter;

                    body += trHeader;
                    if(record.Opportunity__c != null){
                        String opptyName = record.Opportunity__r.Name;
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '<a href="' + myDomain + '/lightning/r/Opportunity/' + record.Opportunity__c + '/view" target="_blank">' + opptyName.escapeHtml4() + '</a>' + tdhFooter;
                    }
                    else {
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '' + tdhFooter;
                    }
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_OWNER_NAME + tdhFooter;
                    body += td1Header + record.Owner.Name + tdhFooter;
                    body += trFooter;

                    String accountName = '';
                    String reportDate = '';
                    if(record.Account_Name__c != null) accountName = record.Account_Name__r.Name;

                    if(record.ReportingDate__c != null){
                        Date rt = record.ReportingDate__c;
                        reportDate = String.valueOf(rt.year()) + '-' + String.valueOf(rt.month()).leftPad(2, '0') + '-' + String.valueOf(rt.day()).leftPad(2, '0');
                    }
                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ACCOUNT + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/Account/' + record.Account_Name__c + '/view" target="_blank">' + accountName.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_REPORTDATE + tdhFooter;
                    body += td1Header + reportDate.escapeHtml4() + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    body += th4Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th2Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ORDER + tdhFooter;
                    //body += td1Header + Integer.valueOf(record.DisplayOrder__c) + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    //body += td4Header + record.Contents__c + tdhFooter;
                    body += td4Header + record.IssueDescription__c + tdhFooter;
                    body += trFooter;

                    body += tableFooter;
                    body += divFooter;
                }

                contents = '<div id="content-body">' + body + '</div>';
            }
        } catch (StringException e) {
            throw new AuraHandledException(Label.WEEKLY_ISSUE_REPORT_STRING_EXCEPTION);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contents;
    }

    @AuraEnabled
    public static list<WeeklyReport__c> getIssueReports(Date reportDate){

        system.debug('########### WeeklyReportsController > getIssueReports start()');

        list<WeeklyReport__c> lstWR = new list<WeeklyReport__c>();
        try {
            Date startDate = reportDate.toStartOfWeek();
            Date endDate = startDate.addDays(7);

            list<User> owners = RoleUtil.getAllSubordinates(UserInfo.getUserRoleId());
            lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                     FROM WeeklyReport__c
                     WHERE CheckedforIssue__c = true
                        AND ReportingDate__c >= :startDate
                        AND ReportingDate__c < :endDate
                        AND OwnerId IN :owners 
                     ORDER BY DisplayOrder__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWR;
    }

    @AuraEnabled
    public static list<WeeklyReport__c> getTeamReports(Date reportDate){

        system.debug('########### WeeklyReportsController > getTeamReports start()');

        list<WeeklyReport__c> lstWR = new list<WeeklyReport__c>();
        try {
            Date startDate = reportDate.toStartOfWeek();
            Date endDate = startDate.addDays(7);

            list<User> owners = RoleUtil.getAllSubordinates(UserInfo.getUserRoleId());
            lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                     FROM WeeklyReport__c
                     WHERE 	Team__c = true
                        AND ReportingDate__c >= :startDate
                        AND ReportingDate__c < :endDate
                        AND OwnerId IN :owners 
                     ORDER BY DisplayOrder__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWR;
    }

    @AuraEnabled
    public static list<WeeklyReport__c> getOfficeReports(Date reportDate){

        system.debug('########### WeeklyReportsController > getOfficeReports start()');

        list<WeeklyReport__c> lstWR = new list<WeeklyReport__c>();
        try {
            Date startDate = reportDate.toStartOfWeek();
            Date endDate = startDate.addDays(7);

            list<User> owners = RoleUtil.getAllSubordinates(UserInfo.getUserRoleId());
            lstWR = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                     FROM WeeklyReport__c
                     WHERE 	Office__c = true
                        AND ReportingDate__c >= :startDate
                        AND ReportingDate__c < :endDate
                        AND OwnerId IN :owners 
                     ORDER BY DisplayOrder__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstWR;
    }

    @AuraEnabled
    public static WeeklyReport__c getIssueReport(String recordId){
        WeeklyReport__c record = new WeeklyReport__c();
        try {
            record = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                      FROM WeeklyReport__c
                      WHERE Id = :recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return record;
    }

    @AuraEnabled
    public static Boolean saveIssuesContent(String recordId, String content, Integer order){
        try {
            WeeklyReport__c record = new WeeklyReport__c();
            record.Id = recordId;
            record.IssueDescription__c = content;
            if(order != null) record.DisplayOrder__c = order;
            
            update record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return true;
    }

    @AuraEnabled
    public static String getEmailIssuesContents(list<String> reportIds){
        list<WeeklyReport__c> records = new list<WeeklyReport__c>();
        String contents = '';
        try {
            records = [SELECT Id, Name, OwnerId, Owner.Alias, Owner.Name, Department__c, Account_Name__c, Account_Name__r.Name,
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Account.Name,
                        DisplayOrder__c, IssueDescription__c, ReportingDate__c
                       FROM WeeklyReport__c
                       WHERE Id IN :reportIds 
                       ORDER BY DisplayOrder__c ASC];
            String myDomain = 'https://' + getMyDomain() + '.lightning.force.com';
            String body = '';
            String divHeader   = '<div style="padding-bottom: 8px;">';
            String divFooter   = '</div>';
            String tableHeader = '<table border="0" cellpadding="0" cellspacing="0" style="background-color: #F3F2F2;font-family:tahoma;font-size:10pt;border-top:0.1px solid black;border-left:0.1px solid black;border-right:0.1px solid black;border-bottom:0.1px solid black;">';
            String tableFooter = '</table>';
            String trHeader    = '<tr>';
            String trFooter    = '</tr>';
            String th1Header   = '<td style="width:150px;line-height:32px;text-align:right;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th2Header   = '<td colspan="2" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String th4Header   = '<td colspan="4" style="line-height:32px;text-align:left;vertical-align:middle;font-weight:bold;white-space:nowrap;border: 0.1px solid black;padding-right:16px;padding-left:16px;">';
            String td1Header   = '<td width="50%" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td3Header   = '<td colspan="3" style="background-color:#ffffff;border: 0.1px solid black;line-height:32px;padding-right:16px;padding-left:16px;">';
            String td4Header   = '<td colspan="4" style="background-color:#ffffff;border: 0.1px solid black;padding:16px;">';
            String tdhFooter   = '</td>';

            if(!records.isEmpty()){
                for(WeeklyReport__c record : records){
                    body += divHeader;
                    body += tableHeader;

                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_NAME + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/WeeklyReport__c/' + record.Id + '/view" target="_blank">' +  + record.Name.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_DEPT_NAME + tdhFooter;
                    body += td1Header + record.Department__c + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    if(record.Opportunity__c != null){
                        String opptyName = record.Opportunity__r.Name;
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '<a href="' + myDomain + '/lightning/r/Opportunity/' + record.Opportunity__c + '/view" target="_blank">' + opptyName.escapeHtml4() + '</a>' + tdhFooter;
                    } 
                    else {
                        body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_OPPORTUNITY + tdhFooter;
                        body += td1Header + '' + tdhFooter;
                    }
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_OWNER_NAME + tdhFooter;
                    body += td1Header + record.Owner.Name + tdhFooter;
                    body += trFooter;

                    String accountName = '';
                    String reportDate = '';
                    if(record.Account_Name__c != null) accountName = record.Account_Name__r.Name;
                    if(record.ReportingDate__c != null){
                        Date rt = record.ReportingDate__c;
                        reportDate = String.valueOf(rt.year()) + '-' + String.valueOf(rt.month()).leftPad(2, '0') + '-' + String.valueOf(rt.day()).leftPad(2, '0');
                    }
                    body += trHeader;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ACCOUNT + tdhFooter;
                    body += td1Header + '<a href="' + myDomain + '/lightning/r/Account/' + record.Account_Name__c + '/view" target="_blank">' + accountName.escapeHtml4() + '</a>' + tdhFooter;
                    body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_REPORTDATE + tdhFooter;
                    body += td1Header + reportDate.escapeHtml4() + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    body += th4Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th2Header + Label.WEEKLY_ISSUE_REPORT_COL_CONTENT + tdhFooter;
                    //body += th1Header + Label.WEEKLY_ISSUE_REPORT_COL_ORDER + tdhFooter;
                    //body += td1Header + Integer.valueOf(record.DisplayOrder__c) + tdhFooter;
                    body += trFooter;

                    body += trHeader;
                    body += td4Header + record.IssueDescription__c + tdhFooter;
                    body += trFooter;

                    body += tableFooter;
                    body += divFooter;
                }

                contents = '<div id="content-body">' + body + '</div>';
            }

        } catch (StringException e) {
            throw new AuraHandledException(Label.WEEKLY_ISSUE_REPORT_STRING_EXCEPTION);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contents;
    }

    @AuraEnabled
    public static Boolean sendReportKnoxEmail(list<String> usrList, String subject, String content){
        Boolean result = false;
        try {
            map<String, Object> resultMap = new map<String, Object>();
            list<String> emails = usrList;
            // list<String> emails = new list<String>();
            // list<User> luser = [SELECT Email FROM User WHERE Id IN :usrList];
            // if(!luser.isEmpty()){
            //     for(User u : luser){
            //         if(u.Email != null)
            //             emails.add(u.Email);
            //     }
            // }

            if(!emails.isEmpty()){
                if(!Test.isRunningTest()){
                    //KnoxEmailSendController mailCon = new KnoxEmailSendController();
                    //resultMap = mailCon.sendKnoxEmail(null, emails, new list<String>(), new list<String>(), subject, content, new list<map<String, Object>>(), new list<map<String, String>>());
                    // resultMap = mailCon.sendKnoxEmail(
                    //     null,                            // recordId
                    //     emails,                          // to list
                    //     new list<String>(),              // cc list
                    //     new list<String>(),              // bcc list
                    //     subject,                         // subject
                    //     content,                         // mail body
                    //     new list<map<String, Object>>(), // efileList
                    //     new list<map<String, String>>()  // nfileList
                    // );    
                } else {
                    if(subject != null)
                        resultMap.put('result', 'success');
                    else {
                        resultMap.put('result', 'error');
                        resultMap.put('Message', 'error');
                    }
                }
    
                String val = String.valueOf(resultMap.get('result'));
                if(val == 'success') {
                    result = true;
                } else {
                    String msg = 'Knox Email Error!';
                    if(resultMap.get('Message') != null) msg = String.valueOf(resultMap.get('Message'));
                    throw new AuraHandledException(msg);
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
}