({
    doInit : function(component, event) {
        var self = this;
    },

    clickShare22 : function(component, event){
        console.log('start save');
        var self = this,
            shareItem = new Array(),
            sharetitle = component.find("title").get("v.value"),
            sharebody = component.find("body").get("v.value"),
            sharelinkurl = component.find("linkurl").get("v.value");

        if(sharetitle != "") shareItem.push(sharetitle);
        if(sharebody != "") shareItem.push(sharebody);
        if(sharelinkurl != "") shareItem.push(sharelinkurl);

        component.set("v.showSpinner", true);
        self.apex(component, 'saveKeywords', { shareItem : shareItem })
            .then(function(result){
                component.set("v.showSpinner", false);
                component.find("overlayLib").notifyClose();
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.find("overlayLib").notifyClose();
            });

    },

    clickShare : function(component, event){
        console.log('start share');
        var self = this,
            shareRichText = component.get("v.myVal"),
            shareUrl = component.get("v.url"),
            shareUrlTitle = component.get("v.urlTitle");

            if (shareRichText != null) {
                shareRichText = shareRichText.replaceAll('<br>',' ');
                shareRichText = shareRichText.replaceAll('<strike>','<s>');
                shareRichText = shareRichText.replaceAll('</strike>','</s>');
            }
            
        component.set("v.showSpinner", true);
        self.apex(component, 'shareNews', { shareRichText : shareRichText, shareUrl : shareUrl, shareUrlTitle : shareUrlTitle})
            .then(function(result){
                component.set("v.showSpinner", false);
                component.find('notifLib').showToast({
                    "variant" : "success",
                    "message" : $A.get("$Label.c.GOOGLENEWS_SHARENEWS_MSG"),
                    "mode" : "dismissable",
                    "duration" : 2000
                });
                component.find("overlayLib").notifyClose();
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.find("overlayLib").notifyClose();
            });

    },

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
})