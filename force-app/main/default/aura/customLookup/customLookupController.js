/**
 * @description       : 
 * @author            : jinsub.eom@samsung.com
 * @group             : 
 * @last modified on  : 08-18-2021
 * @last modified by  : jinsub.eom@samsung.com
**/

({
    //init function
	doInit : function(component, event, helper) {
        // resultList Default Class setting
        component.set('v.searchClass', 'slds-is-close');
        helper.init(component, event);
	},	

    onFocus : function(component, event, helper){
        var searchcls = component.get('v.searchClass');

        // resultList open
        component.set('v.searchClass','slds-is-open');
    },

    // inputbox blur event
    onBlur : function(component, event, helper){
        helper.listToggleHelper(component, event);            
    },

    onKeyup : function(component, event, helper) {
        // get the search Input keyword   
        var minimum = component.get("v.minimum"),
            searchText = component.get("v.searchKeyword");
        // check if searchKeyword size id more then 2 then 
        // open the lookup result list and call the helper 
        // else close the lookup result List part.   
        if( searchText.length > minimum - 1 ){            
            // resultList open
            component.set('v.searchClass','slds-is-open');
            helper.queryRecords(component, event, searchText);
        } else {
            component.set("v.searchRecords", null ); 
            // resultList close
            component.set('v.searchClass','slds-is-close');
        }
    },
    /**
     * BY MinGyoon Woo at 2020-12-18
     * 스크롤 할때 검색 결과가 사라지지 않도록 처리하기 위한 핸들러.
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    doScroll : function(component, event, helper) {
        window.setTimeout(function(e){
            component.set('v.searchClass','slds-is-open');
            component.find("search-input").focus();
        }, 600);
    },

    // function for clear the Record Selaction 
    clear : function(component, event, heplper){
        var enableMultiRecord = component.get("v.enableMultiRecord");
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        var onchangeEvent = component.get("v.onchange");
        
        console.log('enableMultiRecord ====', enableMultiRecord);
        if(enableMultiRecord){
            var recordId = event.currentTarget.getAttribute("data-itemId"),
                records = component.get("v.selectedRecords"),
                removeIdx;

            for(var i=0;i<records.length;i++){
                if(recordId == records[i].Id) removeIdx = i;
            }
            records.splice(removeIdx, 1);
            component.set("v.selectedRecords", records);
            component.set("v.searchKeyword", "");

            if(records.length == 0){
                $A.util.removeClass(pillTarget, 'slds-show');
                $A.util.addClass(pillTarget, 'slds-hide');    
            }
        } else {
            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');
            
            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');
        
            component.set("v.searchKeyword", "");
            component.set("v.searchRecords", []);
            component.set("v.selectedRecord", {});
        }
        /* execute Aura.Action from parent component */
        if(onchangeEvent != null)
            $A.enqueueAction(onchangeEvent);
    },  

    // This function call when the end User Select any record from the result list.   
    recordSelectedEventHandler : function(component, event, helper) {
        console.log('recordSelectedEventHandler');
        // ====== [TEMP] 20201112 KnoxApproval 용 임시 helper method 호출 ======
        var lookupType = component.get('v.lookupType');
        console.log('lookupType', lookupType);
        if(lookupType == 'MultiHide'){
            helper.handleComponentEvent(component,event);
        // ====== [TEMP] 20201112 KnoxApproval 용 임시 helper method 호출 ======

        } else {
            // get the selected record from the COMPONETN event
            var recordFromEvent = event.getParam("recordByEvent");
            //console.log('recordFromEvent', JSON.stringify(recordFromEvent));	   
            helper.recordSelected(component, recordFromEvent);
        }
    },

    createNewRecord : function(component, event, helper){
        var objectName = component.get('v.objectName'),
            createEvent = $A.get("e.force:createRecord");
        
        createEvent.setParams({
            "entityApiName" : objectName,
            "navigationLocation" : "LOOKUP",
            "panelOnDestroyCallback": function(ev) {
                helper.getCreatedRecord(component, event);
            }
        });
        createEvent.fire();
    },

    objectSelect : function(component, event, helper){
        var dropdown = component.find("buttonMenu"),
            selectedObject = event.getParam("value"),
            multiObjectList = component.get("v.multiObjectList");
        
        multiObjectList.forEach(function(item){
            if(item.value == selectedObject){
                component.set("v.objectName", item.value);
                component.set("v.objectLabel", item.label);
                component.set("v.iconName", item.iconName);
            }
        });

        $A.util.removeClass(dropdown, "slds-is-open");
    },

    onrender : function(component, event, helper){
        var record= component.get("v.selectedRecord"),
            records = component.get("v.selectedRecords"),
            pillContainer = component.find("lookup-pill"),
            lookUpTarget = component.find("lookupField"),
            lookupType = component.get("v.lookupType");

        //console.log('onrender');
        /**
         * 2021-01-06 modified by MinGyoon Woo
         * change if condition, retain search input when multirecords mode
         */
        //if((record.Name != undefined || records.length > 0) && lookupType != 'MultiHide' ){
        if(record.Name != undefined && lookupType != 'MultiHide'){
            $A.util.removeClass(pillContainer, 'slds-hide');      
            $A.util.addClass(pillContainer, 'slds-show');
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        }
    },


})