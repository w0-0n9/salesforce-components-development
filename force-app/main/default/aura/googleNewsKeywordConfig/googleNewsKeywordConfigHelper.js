({
    doInit : function(component, event) {
        var self = this;
        
        self.apex(component, 'getKeywords', { })
            .then(function(result){
                console.log('getKeywords : ', result);
                if(result[0] != undefined) component.set("v.keyword01", result[0]);
                if(result[1] != undefined) component.set("v.keyword02", result[1]);
                if(result[2] != undefined) component.set("v.keyword03", result[2]);
                if(result[3] != undefined) component.set("v.keyword04", result[3]);
                if(result[4] != undefined) component.set("v.keyword05", result[4]);
                if(result[5] != undefined) component.set("v.keyword06", result[5]);
                if(result[6] != undefined) component.set("v.keyword07", result[6]);
                if(result[7] != undefined) component.set("v.keyword08", result[7]);
                if(result[8] != undefined) component.set("v.keyword09", result[8]);
                if(result[9] != undefined) component.set("v.keyword10", result[9]);
                component.set("v.showSpinner", false);
                //console.log('end of init');
            })
            .catch(function(errors){
                self.errorHandler(errors);
            });

    },

    clickSave : function(component, event){
        console.log('start save');
        var self = this,
            keywords = new Array(),
            keyword01 = component.find("keyword01").get("v.value"),
            keyword02 = component.find("keyword02").get("v.value"),
            keyword03 = component.find("keyword03").get("v.value"),
            keyword04 = component.find("keyword04").get("v.value"),
            keyword05 = component.find("keyword05").get("v.value"),
            keyword06 = component.find("keyword06").get("v.value"),
            keyword07 = component.find("keyword07").get("v.value"),
            keyword08 = component.find("keyword08").get("v.value"),
            keyword09 = component.find("keyword09").get("v.value"),
            keyword10 = component.find("keyword10").get("v.value");

        if(keyword01 != "") keywords.push(keyword01);
        if(keyword02 != "") keywords.push(keyword02);
        if(keyword03 != "") keywords.push(keyword03);
        if(keyword04 != "") keywords.push(keyword04);
        if(keyword05 != "") keywords.push(keyword05);
        if(keyword06 != "") keywords.push(keyword06);
        if(keyword07 != "") keywords.push(keyword07);
        if(keyword08 != "") keywords.push(keyword08);
        if(keyword09 != "") keywords.push(keyword09);
        if(keyword10 != "") keywords.push(keyword10);

        component.set("v.showSpinner", true);
        self.apex(component, 'saveKeywords', { keywords : keywords })
            .then(function(result){
                component.set("v.showSpinner", false);
                component.find("overlayLib").notifyClose();
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.find("overlayLib").notifyClose();
            });

    },

    apex : function(component, apexAction, params){
        /**
         * calling rule
        self.apex(component, 'method1', {})
            .then(function(result1){
                console.log('handlw with result1');
                return self.apex(component, 'method2', {});
            })
            .then(function(result2){
                console.log('handlw with result2');
            });
         */
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
})