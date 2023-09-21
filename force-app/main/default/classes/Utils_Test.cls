@isTest
public class Utils_Test {
	static Profile profile;
    static User user;
    static Account acc;
    @isTest static void utils() {
        User u = [SELECT ID FROM User where Name ='Admin']; 
        System.runas(u){
            profile =  Utils_TestDataFactory.getProfile('System Admin');
            user = Utils_TestDataFactory.createUserFull(profile, 'testUser'+System.now().millisecond()+'@samsung.com', 'test1');
            acc = Utils_TestDataFactory.createAccount('TestAcc','1234');
        }
        String mmId = String.valueof(acc.Id);
        Set<Id> mmIdLst = new Set<Id>();
        mmIdLst.add(acc.Id);
        // sObject obj = Utils.getObjectInfoFromRecordId(mmId);
        // sObject objS = Utils.getObjectAllFieldQuerySingle('Account',mmId);
        // List<sObject> objM = Utils.getObjectAllFieldQueryMulti('Account',mmIdLst);
        // Map<String,Object> objInfo = Utils.getObjectInfoFromRecordIdReturnMapType(mmId);
        // List<Object> allObj = Utils.getAllObjectInfo();
        Datetime curDatetime = Utils.getCurDatetime().date();
        Integer randomInteger = Utils.getRandomInteger();
        // List<Account> accList = (List<Account>)Utils.queryObject('Account', '');
        
        Map<String,Object> opptyMap = new Map<String,Object>();        
        opptyMap.put('Amount', 123);
        opptyMap.put('Probability', 20);
		Opportunity oppty = (Opportunity)Utils.mapToSObject('Opportunity', opptyMap);
        
        List<Map<String,Object>> mapList = new List<Map<String,Object>>();
        mapList.add(opptyMap);
        List<Opportunity> opptyList = Utils.mapToSObjectList('Opportunity', mapList);
        Utils.getCelloParameters();
        Utils.retrieveFieldList('Account');
        Utils.getQueryWithoutRichText('Account','');
        Utils.queryObjectWithoutRichText('Account','');
        Utils.getAllPicklistOptionType('Account');
        Utils.getObjectLabel('Account');
        Utils.makeMisId(Datetime.now());
        Utils.conversionToDate('2020-01-01');
        Utils.getFieldLabel('Account');
        Utils.getListViewId('Account','Name');

        //acc.cStatus__c = '00';
        update acc;
        // Utils.getPicklistMap('Account','cStatus__c');
        Utils.roundUpAmount(1.11,'KRW');
        Utils.roundUpAmount(1.11,'other');
        List<String> ownerIds = new List<String>();
        ownerIds.add(user.id);

        Utils.addCalendarViews(ownerIds,'Task','My','test','test','test','2021-01-02');        
        //Utils.getDependentPicklistValues(Opportunity.LostReasonLogistics__c);
        Utils.getQueryAddSelect('Opportunity', 'Account.AccountNumber', '', true);
        Utils.sleep(100);

        Utils.getUserDateFormat();
        Utils.getUserDateTimeFormat();
        /*
        Utils.isAdmin();
        Utils.calculationUsdprice('USD',  Util_String.convertStringDate( '9999-12-31') ,1000);
        Utils.calculationRate('USD',  Util_String.convertStringDate( '9999-12-31'));
		*/
        system.debug(Utils.getIsSandbox());
    }
}