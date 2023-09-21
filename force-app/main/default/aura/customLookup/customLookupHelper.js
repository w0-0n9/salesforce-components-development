/**
 * @description       : 
 * @author            : jinsub.eom@samsung.com
 * @group             : 
 * @last modified on  : 08-18-2021
 * @last modified by  : jinsub.eom@samsung.com
**/

({
    init : function(component, event){
        if(this.checkMultiObject(component) && this.checkRequired(component) 
            && this.checkAdditionalFields(component) && this.checkSearchFields(component)
            && this.checkFilters(component) && this.checkOrderBy(component)){

            var objectName = component.get('v.objectName'),
                action = component.get("c.initComponent");
            
            action.setParams({
                'objectName': objectName
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set('v.objectLabel', returnValue);
                }
            });
            $A.enqueueAction(action);
        }
    },

    checkMultiObject: function(component){
        var enableMultiObject = component.get("v.enableMultiObject"),
            multiObjectList = component.get("v.multiObjectList");
    
        if(enableMultiObject){
            if(multiObjectList == null || multiObjectList.length < 1){
                this.showToast('error', 'CustomLookup Error', 'Need to set multiObjectList for using Multiple Object. Lookup disabled!!');
                component.set("v.disabled", true);
                return false;
            }
            var searchFields = component.get("v.searchFields");
            if(searchFields != ""){
                this.showToast('warning', 'CustomLookup Alert', 'Can not use searchFields with multiObject. searchFields cleared!!');
                component.set("v.searchFields", "");
            }
            var additionalDisplay = component.get("v.additionalDisplay");
            if(additionalDisplay != ""){
                this.showToast('warning', 'CustomLookup Alert', 'Can not use additionalDisplay with multiObject. additionalDisplay cleared!!');
                component.set("v.additionalDisplay", "");
            }
            var filterFields = component.get("v.filterFields");
            if(filterFields != ""){
                this.showToast('warning', 'CustomLookup Alert', 'Can not use Filter with multiObject. Filter cleared!!');
                component.set("v.filterFields", "");
                component.set("v.filterValues", "");
                component.set("v.filterConditions", "");
            }
            var recordTypeNames = component.get("v.recordTypeNames");
            if(recordTypeNames != ""){
                this.showToast('warning', 'CustomLookup Alert', 'Can not use recordTypeNames with multiObject. recordTypeNames cleared!!');
                component.set("v.recordTypeNames", "");
            }

            component.set("v.objectName", multiObjectList[0].value);
            component.set("v.objectLabel", multiObjectList[0].label);
            component.set("v.iconName", multiObjectList[0].iconName);
        }
        return true;
    },

    checkRequired: function(component){
        var objectName = component.get("v.objectName"),
            // label = component.get("v.label"),
            iconName = component.get("v.iconName");
        if(objectName == "" || iconName == ""){ // label == "" || 
            this.showToast('error', 'CustomLookup Error', 'objectName, iconName are required. Lookup disabled!!');
            component.set("v.disabled", true);
            return false;
        }
        return true;   
    },

    checkAdditionalFields: function(component){
        var additionalFields = component.get("v.additionalDisplay");

        if(additionalFields != ""){
            var listField = additionalFields.replace(" ","").split(",");
            if(listField.length > 2){
                this.showToast('error', 'CustomLookup Error', 'The additionalField only accept maximum 2. Lookup disabled!!');
                component.set("v.disabled", true);    
                return false;
            }

            component.set("v.hasMeta", true);
        }
        
        return true;
    },
    
    checkSearchFields: function(component){
        var searchFields = component.get("v.searchFields");

        if(searchFields != ""){
            var listField = searchFields.replace(" ","").split(",");
            if(listField.length > 2){
                this.showToast('error', 'CustomLookup Error', 'The searchField only accept maximum 3. Lookup disabled!!');
                component.set("v.disabled", true);    
                return false;
            }
        }
        return true;
    },
    
    checkFilters: function(component){
        var filterFields = component.get("v.filterFields"),
            filterValues = component.get("v.filterValues"),
            filterConditions = component.get("v.filterConditions");
        
        if(filterFields != ""){
            var listField = filterFields.replace(" ","").split(","),
                listValue = filterValues.replace(" ","").split(","),
                listCondition = filterConditions.replace(" ","").split(",");
            //console.log('listField', listField);
            //console.log('listValue', listValue)
            if(listField.length != listValue.length || listField.length != listCondition.length){
                this.showToast('error', 'CustomLookup Error', 'The number of filter fields, values and conditions must match. Lookup disabled!!');
                component.set("v.disabled", true);    
                return false;
            }
        }
        return true;
    },

    checkOrderBy: function(component){
        var orderBy = component.get("v.orderBy");

        if(orderBy != ""){
            var listField = orderBy.replace(" ","").split(",");
            if(listField.length > 2){
                this.showToast('error', 'CustomLookup Error', 'Additional order by fields accept maximum 3. Lookup disabled!!');
                component.set("v.disabled", true);    
                return false;
            }
        }
        return true;
    },
    
    queryRecords : function(component, event, getInputkeyword) { 
        // call the apex class method 
        var action = component.get("c.queryRecords");
        // set param to method
        action.setParams({
            'searchKeyword': getInputkeyword,
            'objectName' : component.get("v.objectName"),
            'searchFields' : component.get("v.searchFields"),
            'additionalDisplay' : component.get("v.additionalDisplay"),
            'additionalSelect' : component.get("v.additionalSelect"),
            'filterFields' : component.get("v.filterFields"),
            'filterValues' : component.get("v.filterValues"),
            'filterConditions' : component.get("v.filterConditions"),
            'filterExpression' : component.get("v.filterExpression"),
            'recordTypeNames' : component.get("v.recordTypeNames"),         
            'onlyOwned' : component.get('v.onlyOwned'),
            'orderBy' : component.get('v.orderBy'),
            'numLimit' : component.get("v.numOfQuery")
        });
        // set a callBack     
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if(state === "SUCCESS"){
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    var msg = 'No Result Found...';
                    component.set("v.message", msg);
                } else {
                    component.set("v.message", '');
                }
                component.set("v.searchRecords", storeResponse);      
            } else {
                var errors = response.getError();
                if(errors.length > 0)
                    this.showToast("error", errors[0].exceptionType, errors[0].message);
                else
                    this.showToast("error", "Controller Error" , "Unknown APEX Controller Error!");
            }
            this.spinnerToggle(component, event);
        });
        // enqueue the Action
        this.spinnerToggle(component, event);
        $A.enqueueAction(action);
    },

    getCreatedRecord : function(component, event){
        var objectName = component.get('v.objectName'),
            action = component.get("c.getCreatedRecord");
                
        action.setParams({
            'objectName': objectName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue != null)
                    this.recordSelected(component, returnValue);
            }
        });
        $A.enqueueAction(action);
    },

    recordSelected : function(component, record){
        var lookUpTarget = component.find("lookupField"),
            enableMultiRecord = component.get("v.enableMultiRecord"),
            onchangeEvent = component.get("v.onchange");
        //console.log('enableMultiRecord', JSON.stringify(enableMultiRecord));
        //console.log('onchange', onchangeEvent);

        if(enableMultiRecord){
            var records = component.get("v.selectedRecords");
            records.push(record);
            component.set("v.selectedRecords", records);
        } else {
            var pillContainer = component.find("lookup-pill");
                
            $A.util.removeClass(pillContainer, 'slds-hide');      
            $A.util.addClass(pillContainer, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-show');
            $A.util.addClass(lookUpTarget, 'slds-hide');

            component.set("v.selectedRecord" , record); 
        }

        component.set('v.searchClass','slds-is-close');
        component.set("v.searchKeyword", "");

        /* execute Aura.Action from parent component */
        if(onchangeEvent != null)
            $A.enqueueAction(onchangeEvent );
    },

    /*
    * handleComponentEvent Function
    * @description  User Select any record from the result list Function - Result Attribute control
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
    * @return       N/A 
    *               Result Attribute Data Set 
    */
    handleComponentEvent : function(component, event) {
        //console.log('handleComponentEvent');
        
        var selectedAccountGetFromEvent;
        var argument = event.getParam('arguments');
        var recordType = component.get("v.objectName");
        var lookupType = component.get('v.lookupType');
        var isIgnoredDuplicatedRule = component.get('v.isIgnoredDuplicatedRule');        
 
        if(argument){
            selectedAccountGetFromEvent = argument.recordByEvent;
        } else {
            selectedAccountGetFromEvent = event.getParam("recordByEvent");
        }   
         
        if(lookupType == 'Base' || lookupType == 'GroupBase'){//Base Type
            // Selected 1 Record
            component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
                 
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');      
 
            // ListBox close
            component.set('v.searchClass','slds-is-close');
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
 
            /*
            var compEvent = component.getEvent("oSelectedRecordsEvent");
            compEvent.setParams({"record" : selectedAccountGetFromEvent ,"recordType" : recordType , "lookupType" : lookupType });    
            compEvent.fire();
             */
            //console.log({"record" : selectedAccountGetFromEvent ,"recordType" : recordType , "lookupType" : lookupType });
 
        } else { //Multi Type
            //console.log('Multi Type --- ');
            var selectMultiRecords = component.get('v.selectedRecords');
                 
            if(selectMultiRecords){
                if(isIgnoredDuplicatedRule){
                    //console.log('Ignored Duplicated Rule');
                } else {
                    for(var i=0; i<selectMultiRecords.length; i++){
                        if(selectMultiRecords[i].Id == selectedAccountGetFromEvent.Id){
                            this.showToast('error', 'error', '이미 입력된 정보 입니다.');
                            return;
                        }
                                             
                    }
                    //console.log('end for loop --- ');
                }
 
                // Selected multi Record array push
                selectMultiRecords.push(selectedAccountGetFromEvent);
 
                //multiRecord.push(selectedAccountGetFromEvent);
                component.set("v.selectedRecords" , selectMultiRecords);
                component.set("v.searchKeyWord",null);
            }
            /*
            var compEvent = component.getEvent("oSelectedRecordsEvent");
            compEvent.setParams({"record" : selectedAccountGetFromEvent ,"recordType" : recordType , "lookupType" : lookupType });   
            compEvent.fire();
             */
        }
    },

    listToggleHelper : function(component, event){
        window.setTimeout(function(e){
            // resultList close
            component.set('v.searchClass','slds-is-close');
        }, 500);
    },

    showToast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    // Spinner toggle
    spinnerToggle : function(component, event){
        var spinner = component.find("result-spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

})