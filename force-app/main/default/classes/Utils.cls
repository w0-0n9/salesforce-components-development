public with sharing class Utils {


    public static void sleep(Long milliSeconds) {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do{
            timeDiff = System.now().getTime() - firstTime.getTime();
        }while(timeDiff <= milliSeconds);
    }

    public static Boolean addCalendarViews(
        list<String> ownerIds, 
        String objectName, 
        String viewName, 
        String calendarName, 
        String colorCode, 
        String displayField, 
        String startDateField){

        String listviewId = getListViewId(objectName, viewName);
        if(listviewId != null){
            list<CalendarView> lcv = new list<CalendarView>();
            for(String ownerId : ownerIds){
                CalendarView cv = new CalendarView();
                cv.Name = calendarName;
                cv.SobjectType = objectName;
                cv.DisplayField = displayField;
                cv.StartField = startDateField;
                cv.Color = colorCode;
                cv.ListViewFilterId = listviewId;
                cv.OwnerId = ownerId;
                lcv.add(cv);
            }
            system.debug('lcv : '+lcv);
            insert lcv;
        } else {
            return false;
        }
        return true;
    }

    public static String roundUpAmount(Decimal amount, String local){
        if(local.equals('KRW')){
            return String.valueOf(amount.round(System.RoundingMode.DOWN));
        }
        else{
            return amount.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
        }
    }
    public static String getListViewId(String objectName, String viewName){
        String listviewId = '';
        String query = 'SELECT Id FROM ' + objectName + ' LIMIT 10';
        list<sObject> lso = Database.query(query);
        system.debug('lso : '+lso);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(lso);
        system.debug('ssc.getListViewOptions() : '+ssc.getListViewOptions());
        for(System.SelectOption so : ssc.getListViewOptions()){
            system.debug('so : '+so);
            String label = so.getLabel();
            if(label.startsWith(viewName)) listviewId = so.getValue();
        }
        return listviewId != '' ? listviewId : null;
    }

    // Name : mapToSObjectList
    // Description
    // List<Map> 에 담겨있는 필드데이터를 sObject로 매핑
    public static List<sObject> mapToSObjectList(String objectName, List<Object> listObjectParam){
        List<sObject> listObject = new List<sObject>();
        
        for(Object obj : listObjectParam){
            Map<String,Object> objMap = (Map<String,Object>)obj;
            listObject.add(mapToSObject(objectName, objMap));
        }
        
        return listObject;
    }

    // Name : mapToSObject
    // Description
    // Map 에 담겨있는 필드데이터를 sObject로 매핑
    // 사용법 : Account acc = (Account)DK_CommonController.mapToSObject('Account',mapField);
    public static sObject mapToSObject(String objectName, Map<String,Object> mapObject){
        SObject obj = schema.getGlobalDescribe().get(objectName).newSObject();
        
        Map<String, Schema.SObjectField> mapField = new Map<String, Schema.SObjectField>();
        List<Schema.SObjectField> listField = getFieldList(objectName);
        for(Schema.SObjectField f : listField){
            mapField.put(f.getDescribe().getName(), f);
        }
        
        obj.put('Id',null);
        for(String key : mapObject.keyset()){
            if(mapField.get(key) == null) continue;
            //if(!mapField.get(key).getDescribe().isUpdateable()) continue;
            //if(!mapField.get(key).getDescribe().isCreateable()) continue;
            
            if( mapField.get(key).getDescribe().isUpdateable()) {
                Schema.DisplayType fieldType = mapField.get(key).getDescribe().getType();
                Object value = mapObject.get(key);
                
                if(value == null){
                    obj.put(mapField.get(key),null);
                    continue;
                }
                
                if(fieldType == Schema.DisplayType.Date) value = conversionToDate((String)value);
                else if(fieldType == Schema.DisplayType.Datetime){
                    if(value != null && value != '' && !''.equals(value))
                        value = Datetime.parse((String)value);
                }
                else if(fieldType == Schema.DisplayType.Integer){
                    if(value instanceof String && value != null && value != '') value = Integer.valueOf(value);
                    else value = (Integer) value;
                }
                else if(fieldType == Schema.DisplayType.Double){
                    if(value instanceof String && value != null && value != '') value = Double.valueOf(value);
                    else value = (Double) value;
                }
                else if(fieldType == Schema.DisplayType.CURRENCY){
                    if(value instanceof String && value != null && value != '') value = Decimal.valueOf((String)value);
                    else value = (Decimal) value;
                }
                obj.put(mapField.get(key),value);
                
                if(key == 'Id' && (value == '' || ''.equals(value))) obj.put(key,null);
            }
            
        }
        return obj;
    }

    /*
    public static Employee__c getLoginEmployeeData(String userId){
        Employee__c employee = new Employee__c();
        List<User> userLst = [SELECT Id, FederationIdentifier FROM USER WHERE Id =: userId LIMIT 1];
        if(userLst.size() > 0){
            User u = userLst[0];
            
            List<Employee__c> employeeLst= [SELECT Id, Name, EvEName__c, EvSdeptNM__c, EvSdeptENM__c, EvUniqID__c, EvMailAddr__c, EvSapBukrs__c, EvEmpNO__c FROM Employee__c WHERE EvUniqID__c =: u.FederationIdentifier LIMIT 1];
            if(employeeLst.size() > 0){
                employee = employeeLst[0];
            }
        }
        return employee;
    }
    */
    
    // Name : getCelloParameters
    // Description
    // Get AES Encrypted data for parameters to get Cello jump Url
    // param sample -> F2=1607062434552&F3=INT&F6=호출하시는분EP_ID&F7=호출하시는분IP
    public static map<String, String> getCelloParameters(){
        map<String, String> params = new map<String, String>();
        try {
            String timestamp = String.valueOf(system.now().getTime()/1000);
            String epId = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()].FederationIdentifier;
            String loginIp = [SELECT SourceIp 
                              FROM LoginHistory 
                              WHERE UserId = :UserInfo.getUserId() 
                              //  AND Application = 'Browser'
                              ORDER BY LoginTime DESC LIMIT 1].SourceIp;
            if(epId == null || epId == '') return null;

            Blob secret = Blob.valueOf('EvWiKhECcxgVHQAX');
            Blob urlParams = Blob.valueOf('TEMP=TEMP&F2=' + timestamp + '&F3=INT&F6=' + epId + '&F7=' + loginIp);
            Blob p2enc = Crypto.encryptWithManagedIV('AES128', secret, urlParams);
            Blob p3enc = Crypto.encryptWithManagedIV('AES128', secret, Blob.valueOf('TEMP=TEMP&MC=' + EncodingUtil.base64Encode(Blob.valueOf('WKS_LBS_REG'))));
            params.put('p0', EncodingUtil.base64Encode(Blob.valueOf('SFDC')));
            params.put('p2', EncodingUtil.convertToHex(p2enc));
            params.put('p3', EncodingUtil.convertToHex(p3enc));

            system.debug(params);
        } catch(Exception e){
            return null;
        }
        return params;
    }

    // Name : retrieveFieldList
    // Description
    // 오브젝트의 필드목록을 SOQL에 사용할 수 있는 문자열로 리턴함
    public static String retrieveFieldList(String objectName){
        String fieldList = '';

        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if(objType == null){
            return null;
        }

        List<Schema.SObjectField> fields = objType.getDescribe().fields.getMap().values();
        for(Integer i = 0; i < fields.size(); i++) {
            fieldList += fields[i].getDescribe().LocalName + ', ';
        }
        fieldList = fieldList.substring(0, fieldList.length()-2);

        return fieldList;
    }


    // Name : getFieldList
    // Description
    // 오브젝트의 필드들을 리스트로 리턴함
    public static List<Schema.SObjectField> getFieldList(String sObjectName){
        List<Schema.SObjectField> listField = schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values();
        List<Schema.SObjectField> listResult = new List<Schema.SObjectField>();
        
        for(Schema.SObjectField f : listField){
            try{
                DescribeFieldResult dfr = f.getDescribe();
                if(dfr.isAccessible()) listResult.add(f);
            }
            catch(Exception e){}
        }
        
        return listResult;
    }

    /**
    * [RichText 필드 타입을 제외한] 모든 Object 필드를 반환하여 Query문을 반환
    * [Picklist 필드 타입인 경우] toLabel Field 추가
    * @param    String objectApiName, String searchSpec
    * @return   String 
    **/
    public static String getQueryWithoutRichText(String sObjectName, String searchSpec){
        List<Schema.SObjectField> listField = getFieldList(sObjectName);
        String query = 'SELECT ';
        Boolean isFirst = true;
        for(Schema.SObjectField f : listField){
            try {
                DescribeFieldResult dfr = f.getDescribe();
                
                if ((dfr.getType() == Schema.DisplayType.TEXTAREA) && dfr.isHtmlFormatted() ) {               
                    // Check RichText Type
                } else {
                     if(!isFirst){
                        query += ',';
                    }
                    isFirst = false;
                    query += f.getDescribe().getName();
                    // Picklist Type toLabel() query
                    // ex) toLabel(fieldName) toLabel_fieldName
                    if(dfr.getType() == Schema.DisplayType.PICKLIST || dfr.getType() == Schema.DisplayType.MultiPicklist) {
                        query += ',toLabel(' + f.getDescribe().getName() + ') toLabel_'+f.getDescribe().getName() ;
                    }
                }
            } catch(Exception e) {}
        }
        system.debug( query + ' FROM ' + sObjectName + ' ' + searchSpec );
        return query + ' FROM ' + sObjectName + ' ' + searchSpec;
    }
    
    /**
    * Object의 [RichText 필드 타입을 제외한] 모든 Object 필드를 반환하여 Query 실행하여 sObject List로 반환
    * 사용법 : queryObject('Account', '조건문');
    * @param    : String objectApiName, String searchSpec
    * @return   : List<sObject> 
    **/
    @RemoteAction
    public static List<sObject> queryObjectWithoutRichText(String sObjectName, String searchSpec){
        System.debug('searchSpec :' + searchSpec);
        return database.query(getQueryWithoutRichText(sObjectName,searchSpec));
    }

    /**
     * Object의 모든 필드를 반환 + 추가 Select 문 Query
     */
    public static String getQueryAddSelect(String sObjectName, String addSelectQuery, String searchSpec, Boolean isAddRichText){
        List<Schema.SObjectField> listField = getFieldList(sObjectName);
        String query = 'SELECT ';
        Boolean isFirst = true;
        for(Schema.SObjectField f : listField){
            try {
                DescribeFieldResult dfr = f.getDescribe();
                // Check RichText Type
                if(dfr.getType() == Schema.DisplayType.TEXTAREA && dfr.isHtmlFormatted()) {
                    if(!isAddRichText) continue;
                }

                if(!isFirst) query += ',';
                isFirst = false;
                query += f.getDescribe().getName();

                // Picklist Type toLabel() query
                // ex) toLabel(fieldName) toLabel_fieldName
                if(dfr.getType() == Schema.DisplayType.PICKLIST || dfr.getType() == Schema.DisplayType.MultiPicklist) {
                    query += ',toLabel(' + f.getDescribe().getName() + ') toLabel_'+f.getDescribe().getName() ;
                }
                
            } catch(Exception e) {}
        }

        if(!String.isBlank(addSelectQuery)) {
            query += ',' + addSelectQuery;
        }
        system.debug( query + ' FROM ' + sObjectName + ' ' + searchSpec );
        return query + ' FROM ' + sObjectName + ' ' + searchSpec;
    }

    /**
    * Object의 Label 반환
    * @param    String objectApiName
    * @return   String objectLabel
    **/
    @RemoteAction
    public static String getObjectLabel(String objectApiName) {
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectApiName}); 
        String objectLabel = describeSobjectsResult[0].getLabel();
        return objectLabel;
    }

    /**
     * 해당 Object의 필드 레이블 반환
     * @param   String objectApiName 
     * @return  Map<String,String> fieldLabelMap
     **/
    public static Map<String, String> getFieldLabel(String objectApiName){
        Map<String,String> fieldLabelMap = new Map<String,String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        
        system.debug('## fieldMap.size : ' +  fieldMap.size()); 
        for (String fieldName: fieldMap.keySet()) {
            // Put Map ( Key: FieldApiName, Value: FieldLable )
            fieldLabelMap.put( fieldName,  fieldMap.get(fieldName).getDescribe().getLabel() );
        }
        
        return fieldLabelMap;
    }

    /* Name : getPicklistOptionType(String ObjectApiName,String FieldName)
       Author : 
       Description : picklist를 list안에 label , value로 리턴한다.
    */
    @AuraEnabled
    public static List<Map<String, String>> getPicklistOptionType(String ObjectApiName,String FieldName) {
        List<Map<String, String>> pickList = new List<Map<String, String>>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApiName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(FieldName).getDescribe().getPickListValues();

        for(Schema.PicklistEntry plv : pick_list_values) {
            Map<String, String> pickMap = new Map<String, String>();
            pickMap.put('label', plv.getLabel());
            pickMap.put('value', plv.getValue());
            pickList.add(pickMap);
        }

        return pickList;
    }

    /**
     * Object의 모든 Picklist Field Label, Value 가져오기
     * @param       String                  objectApiName
     * @return      Map<String, Object>     Map<String fieldApiName, Map<key를 각각 'label', 'value'로 가짐>>
     */
    public static Map<String,Object> getAllPicklistOptionType(String objectApiName){
        Map<String,Object> rtnData = new Map<String,Object>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = schemaMap.get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();

        // Get Field Api Name of Picklist Type
        List<String> picklistFieldList = new List<String>();
        for (String fieldName: fieldMap.keySet()) {
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if(fielddataType == Schema.DisplayType.Picklist) {
                picklistFieldList.add(fieldName);
            }
        }
        
        // PickList API Name List Loop 
        for(String fieldApiName : picklistFieldList){
            Schema.DescribeFieldResult pickList = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();  //지정한 Object Api 및 Field Api 명을 넣어주어 요약
            List<Schema.PicklistEntry> values = pickList.getPicklistValues();              
            
            // Label Value 가져오기
            List<Object> pickMapList = new List<Object>();
            for(Schema.PicklistEntry pick : values){
                Map<String, String> pickMap = new Map<String, String>();
                pickMap.put('label', pick.getLabel());
                pickMap.put('value', pick.getValue());
                pickMapList.add(pickMap);
            }
            rtnData.put(fieldApiName, pickMapList);
        }
        
        return rtnData;
    }
    
    // Name : conversionToDate
    // Description
    // YYYY.MM.DD 또는 YYYY. MM. DD 또는 YYYY-MM-DD를 YYYYMMDD로 변경 MMDDYYYY
    public static Date conversionToDate(String value){        
        if(value == null || value == ''){
            return null;
        }
        System.debug('value : ' + value);
        value = value.replaceAll('. ','').replaceAll(' ','').replaceAll('-','');
        System.debug('value :' + value);
        
        Integer year = Integer.valueOf(value.substring(0,4));
        Integer month = Integer.valueOf(value.substring(4,6));
        Integer day = Integer.valueOf(value.substring(6,8));
        System.debug('year, month, day :' + year + ' ' + month + ' ' + day);
        
        return Date.newInstance(year,month,day);
    }

    public static Datetime forTestDateTime; // for Test
    public static Datetime getCurDatetime(){
        Datetime result = System.now();
        if(Test.isRunningTest() && forTestDateTime != null) {
            result = forTestDateTime;
        }
        return result;
    }

    /**
    * makeMisId Method
    * @description  결재 ID값 생성
    **/
    public static String makeMisId(Datetime dt) {
        String strDatetime = dt.format('YYYYMMddHHmmss');
        String result = 'SDSSFDC'+strDatetime+dt.getTime()+Utils.getRandomInteger();
        result = result.substring(0, 32);
        return result;
    }

    public static Integer forTestRandomInteger; // for Test
    /**
    * Random Integer 생성
    * @return Integer
    **/
    public static Integer getRandomInteger(){
        Integer result = Crypto.getRandomInteger();
        if(Test.isRunningTest()) {
            result = (forTestRandomInteger < 0 ? forTestRandomInteger * -1 : forTestRandomInteger);
        }
        return result;
    }


    /**
    * @description picklist의 Label 관련 value값을 Map 형식 변환
    * @author kilhwan.an@partner.samsung.com | 2020-11-16 
    * @param ObjectApiName 
    * @param FieldName 
    * @return Map<String, String>
    **/
    @AuraEnabled
    public static Map<String, String> getPicklistMap(String ObjectApiName,String fieldApiName) {

        DescribeSObjectResult objSchema  = Schema.getGlobalDescribe().get( ObjectApiName).getDescribe();
        DescribeFieldResult   fieldDesc  = objSchema.fields.getMap().get( fieldApiName).getDescribe();

        List<Schema.PicklistEntry> pickListVal  = fieldDesc.getPickListValues();
        Map<String, String>        pickMap      = new Map<String, String>();
        for( Schema.PicklistEntry plv : pickListVal) {

            pickMap.put( plv.getLabel(), plv.getValue());
        }

        return pickMap;
    }

    /**     
     * 종속된 Picklist 가져오기
     * @params      Schema.sObjectField dependToken : Dependent Field
     * Map<String,List<String>> dependentPicklistValuesMap = getDependentPicklistValues(Opportunity.LostReasonLogistics__c);
     */
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }


    
    //  --------------------------------------------------------------------------------------------------------------
    //  User Locale Foramt Date , Datetime to String
    //  --------------------------------------------------------------------------------------------------------------
    private static Map<String,String> localeToDateTimeFmtMap; // Singleton, remember when first referenced
    
    /**
    * @description  getUserDateFormat: e.g. yyyy-mm-dd
    * @return String 
    **/
    public static String getUserDateFormat() {
        String userLocale  = UserInfo.getLocale();
        String userDateformat = '';
        
        getLocaleToDateTimeFmtMap();
        if (!localeToDateTimeFmtMap.containsKey(userLocale)) {
            return 'yyyy-MM-dd'; // default format  
        } else {
            
            String userDatetimeFormat = localeToDateTimeFmtMap.get(userLocale);
            // 해당 키 이전 or 이후 반환
            String C3_returnBeforeKey = ' a h';
            String C1_returnBeforeKey = ' ah';
            String C2_returnBeforeKey = ' 0h';
            String C4_returnAfterKey = 'mm, ';
            String C5_returnBeforeKey = ' h';
            if(userDatetimeFormat.containsIgnoreCase(C1_returnBeforeKey)) {
                userDateformat = userDatetimeFormat.substringBefore(C1_returnBeforeKey);
            } else if (userDatetimeFormat.containsIgnoreCase(C2_returnBeforeKey)) {
                userDateformat = userDatetimeFormat.substringBefore(C2_returnBeforeKey);
            } else if (userDatetimeFormat.containsIgnoreCase(C3_returnBeforeKey)) {
                userDateformat = userDatetimeFormat.substringBefore(C3_returnBeforeKey);
            } else if (userDatetimeFormat.containsIgnoreCase(C4_returnAfterKey)) {
                userDateformat = userDatetimeFormat.substringAfter(C4_returnAfterKey);
            } else {
                userDateformat = userDatetimeFormat.substringBefore(C5_returnBeforeKey);
            }
        }
        return userDateformat.removeEnd(',');
    }
    
    /**
    * @description  get user Datetime Format String : e.g. yyyy-mm-dd hh.mm.ss
    * @return String 
    **/
    public static String getUserDateTimeFormat() {
        String userLocale  = UserInfo.getLocale();
        getLocaleToDateTimeFmtMap();
        if (!localeToDateTimeFmtMap.containsKey(userLocale)) return 'yyyy-MM-dd HH:mm'; // default format
        return localeToDateTimeFmtMap.get(userLocale);
    }

    /**
    * @description datetime format for that locale : https://help.salesforce.com/articleView?id=sf.admin_supported_date_time_format.htm&type=5
    * @return Map<String, String> 
    **/
    public static Map<String,String> getLocaleToDateTimeFmtMap () {
        if (localeToDateTimeFmtMap == null)
            localeToDateTimeFmtMap  = new Map<String,String> {
                'mi_NZ' => 'yyyy-MM-dd h:mm',
                'af_ZA' => 'yyyy-MM-dd HH:mm',
                'eu_ES' => 'yyyy-MM-dd HH:mm',
                'ja_JP' => 'yyyy-MM-dd HH:mm',
                'lt_LT' => 'yyyy-MM-dd HH:mm',
                'sv_SE' => 'yyyy-MM-dd HH:mm',
                'xh_ZA' => 'yyyy-MM-dd HH:mm',
                'es_PA' => 'MM/dd/yyyy h:mm a',
                'es_PR' => 'MM/dd/yyyy h:mm a',
                'zu_ZA' => 'M/d/yyyy HH:mm',
                'en_US' => 'M/d/yyyy, h:mm a',
                'tl_PH' => 'M/d/yyyy, h:mm a',
                'vi_VN' => 'HH:mm, dd/MM/yyyy',
                'hu_HU' => 'yyyy. MM. dd. HH:mm',
                'ko_KP' => 'yyyy. M. d. a h:mm',
                'ko_KR' => 'yyyy. M. d. a h:mm',
                'ko' => 'yyyy. M. d. a h:mm',
                'en_ZA' => 'yyyy/MM/dd, HH:mm',
                'zh_CN' => 'yyyy/M/d ah:mm',
                'zh_CN_PINYIN' => 'yyyy/M/d ah:mm',
                'zh_CN_STROKE' => 'yyyy/M/d ah:mm',
                'zh_TW' => 'yyyy/M/d ah:mm',
                'zh_TW_STROKE' => 'yyyy/M/d ah:mm',
                'fr_CA' => 'yyyy-MM-dd HH h mm',
                'en_CA' => 'yyyy-MM-dd, h:mm a',
                'sl_SI' => 'dd. MM. yyyy HH:mm',
                'hr_HR' => 'dd. MM. yyyy. HH:mm',
                'sk_SK' => 'd. M. yyyy HH:mm',
                'bs_BA' => 'd. M. yyyy. HH:mm',
                'da_DK' => 'dd.MM.yyyy HH.mm',
                'az_AZ' => 'dd.MM.yyyy HH:mm',
                'cs_CZ' => 'dd.MM.yyyy HH:mm',
                'et_EE' => 'dd.MM.yyyy HH:mm',
                'fr_CH' => 'dd.MM.yyyy HH:mm',
                'lb_LU' => 'dd.MM.yyyy HH:mm',
                'lv_LV' => 'dd.MM.yyyy HH:mm',
                'tr_TR' => 'dd.MM.yyyy HH:mm',
                'be_BY' => 'dd.MM.yyyy, HH:mm',
                'de_AT' => 'dd.MM.yyyy, HH:mm',
                'de_AT_EURO' => 'dd.MM.yyyy, HH:mm',
                'de_BE' => 'dd.MM.yyyy, HH:mm',
                'de_CH' => 'dd.MM.yyyy, HH:mm',
                'de_DE' => 'dd.MM.yyyy, HH:mm',
                'de_DE_EURO' => 'dd.MM.yyyy, HH:mm',
                'de_LU' => 'dd.MM.yyyy, HH:mm',
                'de_LU_EURO' => 'dd.MM.yyyy, HH:mm',
                'hy_AM' => 'dd.MM.yyyy, HH:mm',
                'it_CH' => 'dd.MM.yyyy, HH:mm',
                'ka_GE' => 'dd.MM.yyyy, HH:mm',
                'kk_KZ' => 'dd.MM.yyyy, HH:mm',
                'no_NO' => 'dd.MM.yyyy, HH:mm',
                'pl_PL' => 'dd.MM.yyyy, HH:mm',
                'ro_MD' => 'dd.MM.yyyy, HH:mm',
                'ro_RO' => 'dd.MM.yyyy, HH:mm',
                'ru_KZ' => 'dd.MM.yyyy, HH:mm',
                'ru_RU' => 'dd.MM.yyyy, HH:mm',
                'uk_UA' => 'dd.MM.yyyy, HH:mm',
                'fi_FI' => 'd.M.yyyy HH.mm',
                'fi_FI_EURO' => 'd.M.yyyy HH.mm',
                'mk_MK' => 'd.M.yyyy HH:mm',
                'is_IS' => 'd.M.yyyy, HH:mm',
                'iw_IL' => 'd.M.yyyy, HH:mm',
                'sq_AL' => 'd.M.yyyy, h:mm a',
                'sh_BA' => 'd.M.yyyy. HH:mm',
                'sh_CS' => 'd.M.yyyy. HH:mm',
                'sh_ME' => 'd.M.yyyy. HH:mm',
                'sh_ME_USD' => 'd.M.yyyy. HH:mm',
                'sr_BA' => 'd.M.yyyy. HH:mm',
                'sr_CS' => 'd.M.yyyy. HH:mm',
                'sr_RS' => 'd.M.yyyy. HH:mm',
                'in_ID' => 'dd/MM/yyyy HH.mm',
                'cy_GB' => 'dd/MM/yyyy HH:mm',
                'es_GT' => 'dd/MM/yyyy HH:mm',
                'es_MX' => 'dd/MM/yyyy HH:mm',
                'es_PE' => 'dd/MM/yyyy HH:mm',
                'fr_BE' => 'dd/MM/yyyy HH:mm',
                'fr_FR' => 'dd/MM/yyyy HH:mm',
                'fr_FR_EURO' => 'dd/MM/yyyy HH:mm',
                'fr_GN' => 'dd/MM/yyyy HH:mm',
                'fr_HT' => 'dd/MM/yyyy HH:mm',
                'fr_KM' => 'dd/MM/yyyy HH:mm',
                'fr_LU' => 'dd/MM/yyyy HH:mm',
                'fr_MC' => 'dd/MM/yyyy HH:mm',
                'fr_WF' => 'dd/MM/yyyy HH:mm',
                'ga_IE' => 'dd/MM/yyyy HH:mm',
                'mt_MT' => 'dd/MM/yyyy HH:mm',
                'nl_BE' => 'dd/MM/yyyy HH:mm',
                'pt_BR' => 'dd/MM/yyyy HH:mm',
                'tg_TJ' => 'dd/MM/yyyy HH:mm',
                'fr_MR' => 'dd/MM/yyyy h:mm a',
                'so_DJ' => 'dd/MM/yyyy h:mm a',
                'so_SO' => 'dd/MM/yyyy h:mm a',
                'ti_ET' => 'dd/MM/yyyy h:mm a',
                'am_ET' => 'dd/MM/yyyy h:mm a',
                'zh_SG' => 'dd/MM/yyyy ah:mm',
                'en_BW' => 'dd/MM/yyyy, HH:mm',
                'en_BZ' => 'dd/MM/yyyy, HH:mm',
                'en_CM' => 'dd/MM/yyyy, HH:mm',
                'en_FK' => 'dd/MM/yyyy, HH:mm',
                'en_GB' => 'dd/MM/yyyy, HH:mm',
                'en_GI' => 'dd/MM/yyyy, HH:mm',
                'en_ID' => 'dd/MM/yyyy, HH:mm',
                'en_IE' => 'dd/MM/yyyy, HH:mm',
                'en_IE_EURO' => 'dd/MM/yyyy, HH:mm',
                'en_KE' => 'dd/MM/yyyy, HH:mm',
                'en_MG' => 'dd/MM/yyyy, HH:mm',
                'en_MU' => 'dd/MM/yyyy, HH:mm',
                'en_NG' => 'dd/MM/yyyy, HH:mm',
                'en_RW' => 'dd/MM/yyyy, HH:mm',
                'en_SC' => 'dd/MM/yyyy, HH:mm',
                'en_SH' => 'dd/MM/yyyy, HH:mm',
                'en_SX' => 'dd/MM/yyyy, HH:mm',
                'en_TZ' => 'dd/MM/yyyy, HH:mm',
                'en_UG' => 'dd/MM/yyyy, HH:mm',
                'it_IT' => 'dd/MM/yyyy, HH:mm',
                'pt_AO' => 'dd/MM/yyyy, HH:mm',
                'pt_CV' => 'dd/MM/yyyy, HH:mm',
                'pt_MZ' => 'dd/MM/yyyy, HH:mm',
                'pt_PT' => 'dd/MM/yyyy, HH:mm',
                'pt_ST' => 'dd/MM/yyyy, HH:mm',
                'sw_KE' => 'dd/MM/yyyy, HH:mm',
                'uz_LATN_UZ' => 'dd/MM/yyyy, HH:mm',
                'es_CO' => 'dd/MM/yyyy, h:mm a',
                'en_AG' => 'dd/MM/yyyy, h:mm a',
                'en_BB' => 'dd/MM/yyyy, h:mm a',
                'en_BM' => 'dd/MM/yyyy, h:mm a',
                'en_BS' => 'dd/MM/yyyy, h:mm a',
                'en_ER' => 'dd/MM/yyyy, h:mm a',
                'en_FJ' => 'dd/MM/yyyy, h:mm a',
                'en_GH' => 'dd/MM/yyyy, h:mm a',
                'en_GM' => 'dd/MM/yyyy, h:mm a',
                'en_GY' => 'dd/MM/yyyy, h:mm a',
                'en_IN' => 'dd/MM/yyyy, h:mm a',
                'en_JM' => 'dd/MM/yyyy, h:mm a',
                'en_KY' => 'dd/MM/yyyy, h:mm a',
                'en_LR' => 'dd/MM/yyyy, h:mm a',
                'en_MW' => 'dd/MM/yyyy, h:mm a',
                'en_MY' => 'dd/MM/yyyy, h:mm a',
                'en_NA' => 'dd/MM/yyyy, h:mm a',
                'en_NZ' => 'dd/MM/yyyy, h:mm a',
                'en_PG' => 'dd/MM/yyyy, h:mm a',
                'en_PH' => 'dd/MM/yyyy, h:mm a',
                'en_PK' => 'dd/MM/yyyy, h:mm a',
                'en_SB' => 'dd/MM/yyyy, h:mm a',
                'en_SL' => 'dd/MM/yyyy, h:mm a',
                'en_SZ' => 'dd/MM/yyyy, h:mm a',
                'en_TO' => 'dd/MM/yyyy, h:mm a',
                'en_TT' => 'dd/MM/yyyy, h:mm a',
                'en_VU' => 'dd/MM/yyyy, h:mm a',
                'en_WS' => 'dd/MM/yyyy, h:mm a',
                'ms_BN' => 'dd/MM/yyyy, h:mm a',
                'ms_MY' => 'dd/MM/yyyy, h:mm a',
                'gu_IN' => 'd/M/yyyy 0h:mm a',
                'kn_IN' => 'd/M/yyyy 0h:mm a',
                'ar_MA' => 'd/M/yyyy HH:mm',
                'ca_ES' => 'd/M/yyyy HH:mm',
                'ca_ES_EURO' => 'd/M/yyyy HH:mm',
                'es_AR' => 'd/M/yyyy HH:mm',
                'es_BO' => 'd/M/yyyy HH:mm',
                'es_CR' => 'd/M/yyyy HH:mm',
                'es_CU' => 'd/M/yyyy HH:mm',
                'es_EC' => 'd/M/yyyy HH:mm',
                'es_ES' => 'd/M/yyyy HH:mm',
                'es_ES_EURO' => 'd/M/yyyy HH:mm',
                'es_HN' => 'd/M/yyyy HH:mm',
                'es_NI' => 'd/M/yyyy HH:mm',
                'es_PY' => 'd/M/yyyy HH:mm',
                'es_SV' => 'd/M/yyyy HH:mm',
                'es_UY' => 'd/M/yyyy HH:mm',
                'ky_KG' => 'd/M/yyyy HH:mm',
                'lu_CD' => 'd/M/yyyy HH:mm',
                'rn_BI' => 'd/M/yyyy HH:mm',
                'yo_BJ' => 'd/M/yyyy HH:mm',
                'es_DO' => 'd/M/yyyy h:mm a',
                'es_US' => 'd/M/yyyy h:mm a',
                'es_VE' => 'd/M/yyyy h:mm a',
                'ml_IN' => 'd/M/yyyy h:mm a',
                'ur_PK' => 'd/M/yyyy h:mm a',
                'ar_DZ' => 'd/M/yyyy h:mm a',
                'ar_LY' => 'd/M/yyyy h:mm a',
                'ar_TN' => 'd/M/yyyy h:mm a',
                'zh_HK' => 'd/M/yyyy ah:mm',
                'zh_HK_STROKE' => 'd/M/yyyy ah:mm',
                'zh_MO' => 'd/M/yyyy ah:mm',
                'lo_LA' => 'd/M/yyyy, HH:mm',
                'ta_LK' => 'd/M/yyyy, HH:mm',
                'en_AU' => 'd/M/yyyy, h:mm a',
                'en_HK' => 'd/M/yyyy, h:mm a',
                'en_SG' => 'd/M/yyyy, h:mm a',
                'hi_IN' => 'd/M/yyyy, h:mm a',
                'km_KH' => 'd/M/yyyy, h:mm a',
                'el_GR' => 'd/M/yyyy, h:mm a',
                'ta_IN' => 'd/M/yyyy, a h:mm',
                'th_TH' => 'd/M/yyyy HH:mm',
                'es_CL' => 'dd-MM-yyyy HH:mm',
                'nl_AW' => 'dd-MM-yyyy HH:mm',
                'nl_NL' => 'dd-MM-yyyy HH:mm',
                'nl_SR' => 'dd-MM-yyyy HH:mm',
                'rm_CH' => 'dd-MM-yyyy HH:mm',
                'te_IN' => 'dd-MM-yyyy h:mm a'
            };
        return localeToDateTimeFmtMap;
    }
    
    public static Boolean getIsSandbox(){
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandBox;
    }
}