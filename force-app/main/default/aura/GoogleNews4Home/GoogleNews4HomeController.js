({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },

    callSetup : function(component, event, helper) {
        helper.callSetup(component, event);
    },

    submitFromChild : function(component, event){
        console.log('submit from footer');
        var childBody = component.get("v.modalbody");
        childBody.clickSave();
    },

    callShareSetup : function(component, event, helper) {
        helper.getUrl(component, event);
        helper.callShareSetup(component, event);
    },

    
    submitFromShareChild : function(component, event){
        console.log('*** submit from share footer ***');
        var childBody = component.get("v.shareModalBody");
        childBody.clickShare();
    }
    
})