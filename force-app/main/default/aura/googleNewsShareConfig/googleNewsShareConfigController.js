({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }
        helper.doInit(component, event);
    },
    
    clickShare : function(component, event, helper){
        helper.clickShare(component, event);
    }
})