({
    doInit : function(component, event) {
        var self = this,
            recordId = component.get("v.recordId");

        console.log('Query Google News Feed');
        component.set("v.showSpinner", true);
        self.apex(component, 'getContents4Account', { accountId : recordId })
            .then(function(result){
                console.log('getContents4Account -> ', result);
                if(result != null && result.length > 0) component.set("v.hasNews", true);
                component.set("v.googleNews", result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
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
            self.showMyToast('error', 'Unknown error in javascript controller/helper.')
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
    clickRefresh : function(component, event){
        console.log('ttttttttttttt');
        $A.get('e.force:refreshView').fire();
    }   
})