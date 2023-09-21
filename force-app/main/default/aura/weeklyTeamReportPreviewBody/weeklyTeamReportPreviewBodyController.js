({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
    },

    clickSend : function(component, event, helper) {
        console.log('send from child in preview');
        var reports = component.get("v.reports"),
            ids = new Array();
        console.log(reports);
        reports.forEach((rpt) => {
            ids.push(rpt.Id);
        });
        console.log(ids);
        helper.callEmailModal(component, ids);
    },

    clickSendEmail : function(component, event, helper) {
        console.log('send from child in sendmailbody');
        var mailBody = component.get("v.emailBody");
        mailBody.clickSend();
    },

})