({
    doInit : function(component, event) {
        //console.log('Get My Domain');
        var self = this,
            reportDate = component.get("v.reportDate");

        component.set("v.showSpinner", true);
        self.apex(component, 'getMyDomain', { })
            .then(function(result){
                //console.log('getMyDomain -> ', result);
                var instanceUrl = 'https://' + result + '.lightning.force.com';
                component.set("v.instanceUrl", instanceUrl);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    callEmailModal : function(component, ids) {
        var self = this,
            modalBody,
            modalFooter;

        $A.createComponents([
            ["c:weeklyOfficeReportSendEmailBody", { reportIds : ids }],
            ["c:weeklyOfficeReportSendEmailFooter", { onsubmit : component.getReference("c.clickSendEmail") }]
        ],
        function(components, status){
            if(status === "SUCCESS"){
                modalBody = components[0];
                modalFooter = components[1];
                component.set("v.emailBody", modalBody);
                component.find('overlayLib').showCustomModal({
                    header : 'Send Email',
                    body : modalBody,
                    footer : modalFooter,
                    showCloseButton : true,
                    cssClass : "my-modal",
                    closeCallback : function(){
                        component.find("overlayLib").notifyClose();
                    }
                });
            }
        });
    },

    /**
     * Common Functions
     */
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    errorHandler : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            var msg = $A.get("$Label.c.COMM_MSG_0020");
            self.showMyToast('error', msg);
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},

})