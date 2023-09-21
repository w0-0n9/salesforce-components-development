({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },

    handleSend : function(component, event, helper) {
        var submit = component.get("v.onsubmit");
        $A.enqueueAction(submit);
    }
})