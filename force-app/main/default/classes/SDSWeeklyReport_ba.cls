/****************************************************************************************
  * ===============================================================
  * Ver  Date          Author         Modification
  * ===============================================================
    1.0  2021. 05. 21  masterK        Create
****************************************************************************************/
public class SDSWeeklyReport_ba implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public String whereCondition;
    private Id senderMailId;
 
    public SDSWeeklyReport_ba(){
        //senderMailId = [Select Id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName = 'No Reply'].Id;
    }

    // ### implemented Method ------------------------------------------------------------------------------------------
    // Start
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        String queryWhere = '';
        //String accountId = '0017X00000jm54BQAQ';
        String accountName = 'CRM 전략 그룹';

        query += 'Select Account.id, Account.name, Id, LastName, FirstName, Email';
        query += ' FROM Contact';	
        //queryWhere += ' WHERE Account.id = :accountId';
        queryWhere += ' WHERE Account.name = :accountName';

        system.debug('query : '+query + queryWhere);
        
        return Database.getQueryLocator(query + queryWhere);
    }

    // Execute
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        if(scope.size() > 0) sendEmail(scope);   
    }

    // Finish
    public void finish(Database.BatchableContext BC) {

     }

    // ### 별도 메소드 --------------------------------------------------------------------------------------------------
    // 메일링
    public void sendEmail(List<Contact> ContactList) {
        system.debug(LoggingLevel.ERROR, '*** [sendEmail] Start !!');
        system.debug(LoggingLevel.ERROR, '*** [ContactList] : '+ContactList);
        
        //Org Wide Email Sender
        Id oweId = [Select Id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='No Reply'].id;

        Messaging.SingleEmailMessage email;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        if(ContactList.size() > 0){
            
            for(Contact con : ContactList){
                if(con.email != null) {
                    email = new Messaging.SingleEmailMessage();
                    email.setSubject(Label.EMAIL_WeeklyReport_SUBJECT);
                    email.setOrgWideEmailAddressId(oweId);
                    email.setToAddresses(new List<String>{con.Email});
                    
                    String textBody = '';
                    //String url = 'https://efss.samsung.net/cc/#/workspaces/154463538467305889/stream';
                    String url = Label.EMAIL_WeeklyReport_URL;
                    
                    textBody += '<html>';
                    textBody += '<head>';
                    textBody += '<title></title>';
                    textBody += '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
                    textBody += '</head>';
        
                    textBody += '<div class="mail_wrap" style="width:850px;line-height:2em;border:1px solid #c2c2c2;font-family:Arial, tahoma;font-size:16px;color:#363636;display:inline-block;">';
                    textBody += '<div class="header" style="height:30px;background:#099ad6 no-repeat right;padding:25px 30px;">';
                    textBody += '<h1 style="font-size:30px;text-align:right;color:#fff;margin:0;padding-top:10px;no-repeat left 12px;">MSG SFDC</h1>';
                    textBody += '</div>';
                    textBody += '<div class="content_wrap" style="color:#222;font-size:14px;padding:30px;">';
                    textBody += '<p style="font-size:18px;line-height:1.5em;">'+Label.EMAIL_WeeklyReport_L1+'</p>';
                    textBody += '<p style="font-size:18px;line-height:1.5em;">'+Label.EMAIL_WeeklyReport_L2+'</p>';
                    textBody += '<p style="font-size:18px;line-height:1.5em;">'+Label.EMAIL_WeeklyReport_L3+'</p>';
                    
                    
                    textBody += '<div style="border:1px; text-align:center; padding-top:10px; font-family:Arial;" >';
                    textBody += '<a href="'+url+'" target="_blank" class="link" style="font-size:15pt;">'+Label.EMAIL_WeeklyReport_L4+'</a>';
                    textBody += '</div>';
        
                    textBody += '</div>';
                    textBody += '<div class="footer" style="line-height:1em;padding:15px 28px;background-color:#f6f6f6;border-top:1px solid #c2c2c2;">';
                    textBody += '<div class="policy" style="color:#444;font-size:14px;text-align:center;font-weight:bold;padding-bottom:15px;border-bottom:1px solid #e2e2e2;">';
                    textBody += '</div>';
                    textBody += '<div style="color:#666;font-size:12px;text-align:left;padding-top:15px;white-space:pre-wrap;">';
                    textBody += '</div>';
                    textBody += '</div>';
                    textBody += '</div>';
                    textBody += '</html>';
                    
                    email.setHtmlBody(textBody);
                    emailList.add(email); 
                }           
            }
            
            if(emailList.size() > 0) {
                //Messaging.sendEmail( emailList );    
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }            
            }
        }
        
        system.debug(LoggingLevel.ERROR, '*** [sendEmail] End !!');
    }

}