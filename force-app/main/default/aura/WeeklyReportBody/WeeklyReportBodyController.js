({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },

    onRender : function(component, event, helper) {
        if(component.find("contentBody") != undefined && component.get("v.firstRender")){
            component.set("v.firstRender", false)
            helper.setWindowSize(component);
        }
    },

    selectDate : function(component, event, helper){
        var reportDate = event.getSource().get("v.value");
        component.set("v.reportDate", reportDate);
        component.set("v.pDate", reportDate);
        component.set("v.tab", "part");

        var evt = component.getEvent('WeeklyReportEvent');
        evt.setParam('WeeklyReportDate',reportDate);
        evt.setParam('Tab','part');
        evt.fire();

        helper.getContents(component);
    },

    clickReport : function(component, event, helper) {
        var recordId = event.currentTarget.id;
        console.log('click!', recordId);
        helper.callEditModal(component, recordId);
    },

    clickPreview : function(component, event, helper) {
        helper.callPreviewModal(component);
    },

    clickSendEmail : function(component, event, helper) {
        console.log('send from footer');
        var previewBody = component.get("v.previewBody");
        previewBody.clickSend();
    },

    saveFromChild : function(component, event){
        console.log('save from footer');
        var editBody = component.get("v.editBody");
        editBody.clickSave();
    },

    clickFullScreen : function(component, event, helper){
        var msg = $A.get('$Label.c.WEEKLY_ISSUE_REPORT_FULLSCREEN');
        helper.showMyToast('warning', msg);
    },
    getContent1: function(component, event, helper){
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){component.set('v.isMobile',true);}
        helper.doInit(component, event);
    },
})