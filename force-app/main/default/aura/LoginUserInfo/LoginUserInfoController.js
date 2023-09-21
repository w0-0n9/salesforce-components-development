({ 
    init : function(component, event, helper) {
        window.console.log('init Start');        
        helper.helperInit(component, event); 
    },
        
    userOverlayClick: function(component, event, helper) {
        var modalBody;
        $A.createComponent("c:UserRegistrationApplicationOverlay", {},
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "mymodal"
                    })
                }
            }
        );
    }
})