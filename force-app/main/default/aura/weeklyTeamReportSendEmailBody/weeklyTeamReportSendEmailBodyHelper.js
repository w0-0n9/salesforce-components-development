({
    doInit : function(component) {
        var self = this,
            reportIds = component.get("v.reportIds"),
            contents = '';
        
        component.set("v.showSpinner", true);
        self.apex(component, 'getEmailWeeklyContents', { reportIds : reportIds })
            .then(function(result){
                //console.log('getEmailContents -> ', result);
                component.set("v.contents", result);
                component.set("v.showSpinner", false);
                //closes the modal or popover from the component
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
                //closes the modal or popover from the component
                component.find("overlayLib").notifyClose();
            });
    },

    callKnoxSendEmail : function(component) {
        var self = this,
            error = false,
            subject = component.get("v.subject"),
            contents = component.get("v.contents"),
            recipients = component.get("v.recipients"),
            comments = component.get("v.comments"),
            emails = new Array();

        if(recipients.length < 1){
            error = true;
            var msg = $A.get("$Label.c.WEEKLY_TEAM_REPORT_ERROR_RECIPIENTS");
            self.showMyToast("error", msg);
        } else {
            recipients.forEach((recipient) => {
                emails.push(recipient.EvMailAddr__c);
            });
        }
        if(subject == ""){
            error = true;
            var msg = $A.get("$Label.c.WEEKLY_TEAM_REPORT_ERROR_SUBJECT");
            self.showMyToast("error", msg);
        }
        if(comments == ""){
            error = true;
            var msg = $A.get("$Label.c.WEEKLY_TEAM_REPORT_ERROR_COMMENT");
            self.showMyToast("warning", msg);
        } else {
            comments =  '<p>' + comments.replaceAll('\n', '<br/>') +'</p><br/>';
        }

        if(!error){
            var mailBody = comments + contents;
            //console.log('email contents =>', mailBody)
            self.sendKnoxEmail(component, emails, subject, mailBody);    
        }
    },

    sendKnoxEmail : function(component, emails, subject, mailBody){
        var self = this;

        mailBody = mailBody.replace(/(\r\n|\n|\r)/g,"<br />");
        component.set("v.showSpinner", true);
        self.apex(component, 'sendReportKnoxEmail', {
            usrList : emails, 
            subject : subject,
            content : mailBody
            })
            .then(function(result){
                //console.log('sendIssueKnoxEmail -> ', result);
                if(result){
                    var msg = $A.get("$Label.c.WEEKLY_TEAM_REPORT_MSG_SUCCESS");
                    self.showMyToast("success",msg);
                } else {
                    var msg = $A.get("$Label.c.WEEKLY_TEAM_REPORT_ERROR_APEX_CONTROLLER");
                    self.showMyToast("error", msg);
                }
                component.set("v.showSpinner", false);
                //closes the modal or popover from the component
                component.find("overlayLib").notifyClose();
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
                //closes the modal or popover from the component
                component.find("overlayLib").notifyClose();
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