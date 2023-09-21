({
    doInit : function(component, event) {
        var self = this;
        self.getContents(component);
    },

    callSetup : function(component, event){
        var self = this,
            modalBody,
            modalFooter;
        $A.createComponents([
                ["c:googleNewsKeywordConfig",{}],
                ["c:googleNewsKeywordConfigFooter",{
                    onsubmit : component.getReference("c.submitFromChild")
                }]
            ],
            function(contents, status, errorMessage){
                if(status === "SUCCESS"){
                    var title = $A.get("$Label.c.GOOGLENEWS_KEYWORD_TITLE");
                    modalBody = contents[0];
                    modalFooter = contents[1];
                    component.set("v.modalbody", modalBody);
                    
                    component.find("overlayLib").showCustomModal({
                        header: title,
                        body : modalBody,
                        footer : modalFooter,
                        showCloseButton: true,
                        cssClass: 'childModal',
                        closeCallback: function(){
                            self.getContents(component);
                        }
                    });
                } else if(status === "INCOMPLETE"){
                    self.showMyToast("error", "Server issue or client is offline.");
                } else if(status === "ERROR"){
                    self.showMyToast("error", "Unknown error!");
                }
            }
        );
    },

    getUrl : function(component, event){
        var urlval =  event.getSource().get("v.value");

        component.set("v.url", urlval.Url);
        component.set("v.urlTitle", urlval.Title);
    },
    
    callShareSetup : function(component, event){
        var self = this,
            modalBody,
            modalFooter;
        $A.createComponents([
                ["c:googleNewsShareConfig",{
                    url : component.get("v.url"),
                    urlTitle : component.get("v.urlTitle")
                }],
                ["c:googleNewsShareConfigFooter",{
                    onsubmit : component.getReference("c.submitFromShareChild")
                }]
            ],
            function(contents, status, errorMessage){
                if(status === "SUCCESS"){
                    var title = $A.get("$Label.c.GOOGLENEWS_SHARENEWS_TITLE");
                    modalBody = contents[0];
                    modalFooter = contents[1];
                    component.set("v.shareModalBody", modalBody);
                    
                    component.find("overlayLib").showCustomModal({
                        header: title,
                        body : modalBody,
                        footer : modalFooter,
                        showCloseButton: true,
                        cssClass: 'childModal',
                        closeCallback: function(){
                            self.getContents(component);
                        }
                    });
                } else if(status === "INCOMPLETE"){
                    self.showMyToast("error", "Server issue or client is offline.");
                } else if(status === "ERROR"){
                    self.showMyToast("error", "Unknown error!");
                }
            }
        );
    },

    getContents : function(component){
        console.log('Query Google News Feed');
        var self = this;
        component.set("v.showSpinner", true);
        self.apex(component, 'getContents4Home', {})
            .then(function(result){
                console.log('getContents4Home -> ', result);
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

})