({
	helperInit : function(component, event) {
        var action = component.get("c.getLoginUserInfo");
        action.setCallback(this,function(response) { 
            var state = response.getState();            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                window.console.log('result : ', result);
                component.set('v.userInfo', result);
                component.set('v.lastLogin', result.lastLoginDate);
            }
        });
        $A.enqueueAction(action);
    }
})