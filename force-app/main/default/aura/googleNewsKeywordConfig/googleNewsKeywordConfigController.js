({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },
    
    clickSave : function(component, event, helper){
        helper.clickSave(component, event);
    },
})