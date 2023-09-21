({

	init : function(component, event) {
		var self = this;
		var apexAction = 'initComponent';
        var apexParams = {
            'recordId' : component.get('v.recordId')
        };

        
        self.apex(component, apexAction, apexParams)
        .then((result) => {				
            var result = JSON.parse(result);                
            component.set('v.isLocked', result.isLocked);
            component.set('v.canModifyAll', result.canModifyAll);

            var toastTime = component.get('v.toastTime');
            var toastType = component.get('v.toastType');
            var toastMode = component.get('v.toastMode');
            if(result.isLocked){
                self.showToast(component, toastType, toastMode, 'Record Locked', $A.get('$Label.c.COMM_MSG_RECORD_LOCKED'), toastTime);
            }
            console.log("Here!!!!!!!!!");
        })
        .catch((errors) => {
        });
	},

	handleClick : function(component, event) {
		var self = this;
        var actionLabel = 'lock'; 
        var isLock = component.get('v.isLocked');

        if(isLock) {
            actionLabel = 'unlock'
        }
        
		var apexAction = actionLabel + 'Record';
        var apexParams = {
            'recordId' : component.get('v.recordId')
		};

		self.apex(component, apexAction, apexParams)
        .then((result) => {				
			self.init(component, event);
        })
        .catch((errors) => {
            
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

	/**
	 * 
	 * @param {*} component 
	 * @param {*} type 		'error', 'warning', 'success', 'info'
	 * @param {*} mode 		'pester', 'sticky', 'dismissible'
	 * @param {*} title 
	 * @param {*} message 
	 * @param {*} duration 
	 */
    showToast : function(component, type, mode, title, message, duration) {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			type : type,
			mode : mode,
			title: title,
			message : message,
			duration : duration
		});
		toastEvent.fire();
	}
})