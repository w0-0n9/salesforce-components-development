({
    /*
	init : function(component, event) {
        var action = component.get("c.getMarqueeContent");
        action.setCallback(this,function(response) { 
            var state = response.getState();            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                window.console.log('result : ', result);
                component.set('v.contents', result);
            }
        });
        $A.enqueueAction(action);
    }
    */

    init : function(component, event) {
        var action = component.get("c.getMarquee");
        action.setCallback(this,function(response) { 
            var state = response.getState();            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                window.console.log('result : ', result);
                component.set('v.contentList', result);
            }
        });
        $A.enqueueAction(action);
    }

})