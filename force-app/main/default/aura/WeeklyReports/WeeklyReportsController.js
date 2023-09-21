({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },


    onRender : function(component, event, helper) {
        console.log('onRender');
        if(component.find("main-box") != undefined && component.get("v.firstRender")){
            component.set("v.firstRender", false)
            helper.setWindowSize(component);
        }

        helper.refreshTab(component);
    },

    selectWeeklyReport : function(component,event,helper){
        console.log('selectWeeklyReport');
        var WeeklyReportBody = component.find('WeeklyReportBody');

    },

    selectWeeklyIssueReport : function(component,event,helper){
        console.log('#### selectWeeklyIssueReport #####');
        var WeeklyIssueReportBody = component.find('WeeklyIssueReportBody');
        //WeeklyIssueReportBody.getContent2(component,event,helper);
    },

    selectWeeklyTeamReport : function(component,event,helper){
        console.log('#### selectWeeklyTeamReport #####');
        var WeeklyTeamReportBody = component.find('WeeklyTeamReportBody');
    },

    selectWeeklyOfficeReport : function(component,event,helper){
        console.log('#### selectWeeklyOfficeReport #####');
        var WeeklyOfficeReportBody = component.find('WeeklyOfficeReportBody');
    },

    WeeklyReportEventHandle: function(component,event,helper){
        console.log('#######'+event.getParam('WeeklyReportDate'));
        console.log('###### Tab : '+event.getParam('Tab'));
        
        component.set('v.mDate',event.getParam('WeeklyReportDate'));
        component.set('v.cTab',event.getParam('Tab'));
    },

    WeeklyIssueReportEventHandle: function(component,event,helper){
        console.log('###### Date : '+event.getParam('WeeklyIssueReportDate'));
        console.log('###### Tab : '+event.getParam('Tab'));

        component.set('v.mDate',event.getParam('WeeklyIssueReportDate'));
        component.set('v.cTab',event.getParam('Tab'));
    },

    WeeklyTeamReportEventHandle: function(component,event,helper){
        console.log('###### Date : '+event.getParam('WeeklyTeamReportDate'));
        console.log('###### Tab : '+event.getParam('Tab'));

        component.set('v.mDate',event.getParam('WeeklyTeamReportDate'));
        component.set('v.cTab',event.getParam('Tab'));
    },

    WeeklyOfficeReportEventHandle: function(component,event,helper){
        console.log('###### Date : '+event.getParam('WeeklyOfficeReportDate'));
        console.log('###### Tab : '+event.getParam('Tab'));

        component.set('v.mDate',event.getParam('WeeklyOfficeReportDate'));
        component.set('v.cTab',event.getParam('Tab'));
    },

})