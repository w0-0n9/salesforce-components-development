({
    clickSave : function(component, event, helper) {
        var submit = component.get("v.onsubmit");
        $A.enqueueAction(submit);
    },

    clickCancel : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    }

})