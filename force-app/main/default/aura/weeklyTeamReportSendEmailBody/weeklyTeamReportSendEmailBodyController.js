({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    
    clickSend : function(component, event, helper) {
        console.log('send from child in sendmailbody');
        helper.callKnoxSendEmail(component);
    },
})