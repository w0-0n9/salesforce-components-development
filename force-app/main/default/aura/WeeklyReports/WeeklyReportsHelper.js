({
    doInit : function(component, event) {
        var self = this;
        console.log('window ->', window);
        console.log('window screen ->', window.screen);

        window.addEventListener('resize', function(){
            self.setWindowSize(component);
        });
    },

    setWindowSize : function(component){
        var screenWidth = window.screen.width,
            screenHeight = window.screen.height,
            windowWidth = window.innerWidth,
            windowHeight = window.innerHeight,
            headerHeight = 234;

        var modal = component.find('main-box');
        if(window.innerWidth == window.outerWidth && window.innerHeight == window.outerHeight){
            $A.util.addClass(modal, "slds-modal");
            $A.util.addClass(modal, "slds-fade-in-open");
            component.set("v.bodyHeight", windowHeight - 100);
            component.set("v.gridHeight", windowHeight - (100 + 25));
        } else {
            $A.util.removeClass(modal, "slds-modal");
            $A.util.removeClass(modal, "slds-fade-in-open");
            component.set("v.bodyHeight", windowHeight - headerHeight);
            component.set("v.gridHeight", windowHeight - (headerHeight + 10));
        }
    },

    
    refreshTab : function(component){
        var bodyHeight = component.get("v.bodyHeight");
        var gridHeight = component.get("v.gridHeight");
        var mDate = component.get("v.mDate");

        var cTab = component.get("v.cTab");
        console.log("cTab : " + cTab);

        if(cTab != "" && cTab != "part") {
            var tab1 = component.find("partTab");
            $A.createComponent(
            "c:WeeklyReportBody", {"bodyHeight" : bodyHeight, "gridHeight" : gridHeight, "pDate" : mDate, "tab" : cTab},
                function(WeeklyReportBody, status, errorMessage){
                    if (status === "SUCCESS") {
                        tab1.set("v.body", [WeeklyReportBody]);
                    }                
                }
            );
        }

        if(cTab != "" && cTab != "group") {
            var tab2 = component.find("groupTab");
            $A.createComponent(
            "c:WeeklyIssueReportBody", {"bodyHeight" : bodyHeight, "gridHeight" : gridHeight, "gDate" : mDate, "tab" : cTab},
                function(WeeklyIssueReportBody, status, errorMessage){
                    if (status === "SUCCESS") {
                        tab2.set("v.body", [WeeklyIssueReportBody]);
                    }                
                }
            );
        }

        if(cTab != "" && cTab != "team") {
            var tab3 = component.find("teamTab");
            $A.createComponent(
            "c:WeeklyTeamReportBody", {"bodyHeight" : bodyHeight, "gridHeight" : gridHeight, "tDate" : mDate, "tab" : cTab},
                function(WeeklyTeamReportBody, status, errorMessage){
                    if (status === "SUCCESS") {
                        tab3.set("v.body", [WeeklyTeamReportBody]);
                    }                
                }
            );
        }
        
        if(cTab != "" && cTab != "office") {
            var tab3 = component.find("officeTab");
            $A.createComponent(
            "c:WeeklyOfficeReportBody", {"bodyHeight" : bodyHeight, "gridHeight" : gridHeight, "oDate" : mDate, "tab" : cTab},
                function(WeeklyOfficeReportBody, status, errorMessage){
                    if (status === "SUCCESS") {
                        tab3.set("v.body", [WeeklyOfficeReportBody]);
                    }                
                }
            );
        }
        
    },  

})