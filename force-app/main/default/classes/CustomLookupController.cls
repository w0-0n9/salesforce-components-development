public class CustomLookupController {

    @AuraEnabled
    public static String initComponent(String objectName) {
        String label = '';
        if(objectName != null){
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectName});
            label = describeSobjectsResult[0].getLabel();    
        }
        
        system.debug('label' + label);
        return label;
    }

    @AuraEnabled
    public static List<sObject> queryRecords(
		String searchKeyword,       // Search Text
		String objectName,          // Target Object API Name
        String searchFields,        // Search Target Fields (comma seperated)
        String additionalDisplay,   // Additional display fields (comma seperated)
        String additionalSelect,    // Additional select fields (comma seperated)
        String filterFields,        // Filter Fields (comma seperated)
		String filterValues,        // Filter Values (comma seperated)
        String filterConditions,    // Filter Conditions (comma seperated)
        String filterExpression,    // Complex filter condition (full statement)
		String recordTypeNames,     // Filter by Record Type Name (comma seperated)
        Boolean onlyOwned,          // Query only user owned records
        String orderBy,             // Order By specific field (comma seperated)
		String numLimit) {          // Number of query records
        
        List<sObject> returnList = new List<sObject> ();  
        
        String sQuery = '';
        sQuery += 'SELECT Id, Name';
        sQuery += (additionalDisplay != null && additionalDisplay != '') ? makeQueryString(additionalDisplay) : '';
        sQuery += (additionalSelect != null && additionalSelect != '') ? makeQueryString(additionalSelect) : '';
        sQuery += ' FROM ' + objectName;

        sQuery += makeSearchString(searchFields, searchKeyword);

        // Add filters
        System.debug(filterFields);
        sQuery += ((filterFields != null && filterFields != '') || filterExpression != '') ? makeFilterString(objectName, filterFields, filterValues, filterConditions, filterExpression) : '';

        // Add RecordType filter
        sQuery += (recordTypeNames != null && recordTypeNames != '') ? makeRecordTypeFilter(recordTypeNames) : '';

        // Query only owned records
        if(onlyOwned){
            sQuery += ' AND OwnerId =' + '\'' + userInfo.getUserId() +'\' ';
        }
        // Set order by string
        sQuery += (orderBy != null && orderBy != '') ? makeOrderBy(orderBy) : '';
        // Set number of records to query
        sQuery += ' LIMIT ' + numLimit;

        system.debug(sQuery);
        List<sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    /*
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, 
                                                   String ObjectName, 
                                                   String FilterField, 
                                                   String filterValue, 
                                                   String filterCondition, 
                                                   String searchType, 
                                                   String myRecord) {
        system.debug('ObjectName : ' + ObjectName);
        system.debug('searchType : ' + searchType);
        //String searchKey = searchKeyWord + '%';
        String searchKey = searchKeyWord;
        
        List <sObject> returnList = new List <sObject> ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery = 'SELECT Id, Name';
        if(ObjectName == 'Employee__c') sQuery += ', EvSdeptENM__c, EvEName__c, EvUniqID__c';
        if(searchType == 'Base'){
            sQuery += ' FROM ' + ObjectName;
            if(ObjectName == 'Employee__c'){                                
                sQuery += ' WHERE (Name LIKE \'%' + searchKey + '%\' ';
                sQuery += ' or EvEName__c LIKE \'%' + searchKey + '%\') ';
            }else{
                sQuery += ' WHERE Name LIKE \'%' + searchKey + '%\' ';
            }
            
        }else if(searchType == 'EvSdeptNM__c' || searchType == 'Email__c'){
            sQuery += ', EvSdeptNM__c, Email__c FROM ' + ObjectName;
            sQuery += ' WHERE (Name LIKE \'%' + searchKey + '%\' ';
            if(ObjectName == 'Employee__c'){                                
                sQuery += ' or Email__c LIKE \'%' + searchKey + '%\'';
                sQuery += ' or EvEName__c LIKE \'%' + searchKey + '%\'';
            }
            sQuery += ' or '+ searchType +' LIKE \'%' + searchKey + '%\') ';
        }else{
            sQuery += ','+ searchType +' FROM ' + ObjectName;
            sQuery += ' WHERE (Name LIKE \'%' + searchKey + '%\' ';
            if(ObjectName == 'Employee__c'){                                
                sQuery += ' or EvEName__c LIKE \'%' + searchKey + '%\'';
                sQuery += ' or '+ searchType +' LIKE \'' + searchKey + '%\') ';
            }else{
                sQuery += ' or '+ searchType +' LIKE \'%' + searchKey + '%\') ';
            }
        }

        if(FilterField != '' && filterValue != ''){
            String condition = ' = ';
            if(filterCondition != null){
                if(filterCondition == 'Y')
                    condition = ' = ';
                else
                    condition = ' != ';
            }
            sQuery += ' AND ' + FilterField + condition + '\'' + filterValue + '\' ';           
        }

        if(myRecord != '' && myRecord == 'Y'){
            sQuery += ' AND ownerId =' + '\'' + userInfo.getUserId() +'\' ';
        }

        sQuery += 'ORDER BY';
        if(ObjectName == 'Employee__c'){
             sQuery += ' Name ASC';
        }else{
             sQuery += ' Name ASC';
        }
        sQuery += ' , CreatedDate DESC LIMIT 50';


        system.debug('sQuery : ' + sQuery);
        List <sObject> lstOfRecords = new List <sObject>();
        if(searchKeyWord.length() > 1){
            lstOfRecords = Database.query(sQuery);
        }
        
        system.debug('lstOfRecords : ' + lstOfRecords);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    */

    @AuraEnabled
    public static sObject getCreatedRecord(String objectName) {
        DateTime dt = system.now().addSeconds(-5);
        String createdById = UserInfo.getUserId();
        String query = 'SELECT Id, Name FROM ' + objectName;
        query += ' WHERE CreatedById = :createdById ';
        query += ' AND CreatedDate > :dt ';
        query += ' ORDER BY CreatedDate DESC LIMIT 1';
        list<sObject> lobj = Database.query(query);
        if(lobj != null && lobj.size() > 0)
            return lobj[0];
        return null;
    }

    @TestVisible
    private static String makeQueryString(String s){
        String query = '';
        list<String> stringList = s.replaceAll(' ', '').split(',');
        if(stringList.size() > 0){
            for(String field : stringList){
                query += ', ' + field;
            }
        }
        return query;
    }

    @TestVisible
    private static String makeSearchString(String searchFields, String searchKeyword){
        String query = '';
        searchKeyword = String.escapeSingleQuotes(searchKeyword);
        if(searchFields != null && searchFields != ''){
            list<String> searchList = new list<String>();
            searchList = searchFields.replaceAll(' ', '').split(',');
            if(searchList.size() > 0){
                query += ' WHERE (Name LIKE \'%' + searchKeyword + '%\'';
                for(String field : searchList){
                    query += ' OR ' + field + ' LIKE \'%' + searchKeyword + '%\'';
                }
                query += ')';
            }
        } else {
            query += ' WHERE Name LIKE \'%' + searchKeyword + '%\'';
        }
        return query;
    }

    @TestVisible
    private static String makeFilterString(String objectName, String filterFields, String filterValues, String filterConditions, String filterExpression){
        String query = '';

        if(filterFields != null && filterFields != ''){
	        list<String> fields = filterFields.replaceAll(' ', '').split(',');
	        list<String> values = filterValues.replaceAll(' ', '').split(',');
	        list<String> ops = filterConditions.replaceAll(' ', '').split(',');
	        Integer cnt = fields.size();

	        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
	        map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

	        for(Integer i = 0; i < cnt; i++){
	            Schema.SObjectField field = fieldMap.get(fields[i]);
	            Schema.DescribeFieldResult fld = field.getDescribe();
	            String fieldType = fld.getType().name();
	            Boolean useNative = false;
	            //if(values[i] == 'null' || values[i] == 'empty' || values[i] == 'true' || values[i] == 'false' /* || values[i].isNumeric() */ )
	            if(values[i] == 'null' || values[i] == 'empty' || values[i] == 'true' || values[i] == 'false' 
	                || fieldType == 'INTEGER' || fieldType == 'CURRENCY' || fieldType == 'DOUBLE' 
	                || fieldType == 'DATE' || fieldType == 'DATETIME' || fieldType == 'BOOLEAN')
	                useNative = true;
	            if(values[i] == 'empty') values[i] = '\'\'';
	            query += ' AND ' + fields[i] + convertOperator(ops[i]) + (useNative ? values[i] : '\'' + values[i] + '\'');
	        }
	    }

        if(filterExpression != ''){
            query += ' AND (' + filterExpression + ') ';
        }

        return query;
    }

    @TestVisible
    private static String makeRecordTypeFilter(String recordTypeNames){
        String query = ' AND (';

        list<String> typeList = new list<String>();
        typeList = recordTypeNames.replaceAll(' ', '').split(',');
        if(typeList.size() > 0){
            Integer cnt = 0;
            for(String value : typeList){
                if(cnt > 0) query += ' OR ';
                query += ' RecordType.Name = \'' + value + '\' ';
                cnt++;
            }
        }

        query += ') ';

        return query;
    }

    @TestVisible
    private static String makeOrderBy(String orderBy){
        String query = ' ORDER BY Name ASC';

        list<String> orderList = new list<String>();
        orderList = orderBy.replaceAll(' ', '').split(',');
        if(orderList.size() > 0){
            for(String value : orderList){
                query += ', ' + value + ' ASC';
            }
        }

        return query;
    }

    @TestVisible
    private static String convertOperator(String op){
        String operator = '';

        switch on op {
            when 'eq' {
                operator = ' = ';
            }
            when 'ne' {
                operator = ' != ';
            }
            when 'gt' {
                operator = ' > ';
            }
            when 'lt' {
                operator = ' < ';
            }
            when 'gte' {
                operator = ' >= ';
            }
            when 'lte' {
                operator = ' <= ';
            }
            when else {
                throw new CustomLookupException('specified filter confition is invalid!');
            }
        }

        return operator;
    }

    public class CustomLookupException extends Exception {}
}