@IsTest
public with sharing class CustomLookupController_Test {
    static {

        Account ac = new Account(
            Name='Test Account'
            //,AccountCode__c ='00000'
        );
        insert ac;
    }

    @IsTest
	private static void testMethodOne() {
        Test.startTest();
        system.debug(CustomLookupController.initComponent('Account'));
        system.debug(CustomLookupController.queryRecords('Test', 'Account', '', '', '', '', '', '', '', '', false, '', '5'));
        try {
            system.debug(CustomLookupController.queryRecords('Test', 'Account', 'Email', '', '', '', '', '', '', '', false, '', '5'));
        } catch(Exception e){}
        system.debug(CustomLookupController.getCreatedRecord('Account'));
        system.debug(CustomLookupController.makeQueryString('Email, Phone'));
        system.debug(CustomLookupController.makeSearchString('Email, Phone', 'Test'));
        system.debug(CustomLookupController.makeFilterString('User', 'Email, Phone','empty, 0000','eq,eq',''));
        system.debug(CustomLookupController.makeRecordTypeFilter('Email, Phone'));
        system.debug(CustomLookupController.makeOrderBy('Email, Phone'));
        system.debug(CustomLookupController.convertOperator('eq'));
        system.debug(CustomLookupController.convertOperator('ne'));
        system.debug(CustomLookupController.convertOperator('gt'));
        system.debug(CustomLookupController.convertOperator('lt'));
        system.debug(CustomLookupController.convertOperator('gte'));
        system.debug(CustomLookupController.convertOperator('lte'));

    }

    /*
    @isTest static void fetchLookUpValues() {
        Test.startTest();
        String searchKeyWord = '';
        String ObjectName = '';
        String FilterField = '';
        String filterValue = ''; 
        String filterCondition = ''; 
        String searchType = ''; 
        String myRecord = '';

        searchKeyWord = 'Test';
        ObjectName = 'Employee__c';
        FilterField = '';
        filterValue = ''; 
        filterCondition = ''; 
        searchType = 'Base'; 
        myRecord = 'Y';
        customLookUpController.fetchLookUpValues(searchKeyWord,ObjectName,FilterField,filterValue,filterCondition,searchType,myRecord);
        Test.stopTest();
    }
    */
}