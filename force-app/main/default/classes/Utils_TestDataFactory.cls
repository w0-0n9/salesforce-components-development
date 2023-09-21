@isTest
public class Utils_TestDataFactory {
    static String DEFAULT_PROFILE_NAME = 'System Administrator';
    /**
        Profile 가져오기
    */
    public static Profile getProfile(String P_name) { 

        Profile pf = null;
        Integer pfCnt = [SELECT COUNT() FROM Profile WHERE Name = :P_name];
        if(pfCnt > 0) {
            pf = [select Id from Profile where Name = :P_name limit 1];
        } else {
            System.debug('not found this Profile : '+P_name+', set default profile : '+DEFAULT_PROFILE_NAME);
            pf = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' limit 1
];
        }
        
        return pf;
    }
    
    /**
        UserRole 생성
    */
    public static UserRole createUserRole(String roleName) {
        
        UserRole role = new UserRole(
            Name = roleName
        );
                                
        insert role;
        
        return role;
    }
        
    /**
    	UserRole 생성 (Parent UserRole 지정)
    */
    public static UserRole createUserRole(String roleName, String ParentRoleId) {
        
        UserRole role = new UserRole(
            Name = roleName
            , ParentRoleId = ParentRoleId
        );
                                
        insert role;
        
        return role;
    }
    
    
    
    /**
        User 생성
    */
    public static User createUser(Profile pf) {
        
        User user = new User(
            Alias = 'testUser'
            , Email='SysAdminTestuser@samsung.com'
            , EmailEncodingKey='UTF-8'
            , LastName='Testing'
            , LanguageLocaleKey='en_US'
            , LocaleSidKey='en_US'
            , EmployeeNumber='AC100000'
            , TimeZoneSidKey='Asia/Seoul'
            , UserName='SysAdminTestuser@samsung.com'
            , ProfileId = pf.Id
        );
                                
        insert user;
        
        return user;
    }
    
    
    /**
        User 생성 (UserName 지정)
    */
    public static User createUserByName(Profile pf, String u_name) {
        
        User user = new User(
            Alias = 'testUser'
            , Email = 'SysAdminTestuser@samsung.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = pf.Id
            , UserName = u_name
        );
                                
        insert user;
        
        return user;
    }

    /**
        User 생성 (UserName 지정)
    */
    public static User createUserFull(Profile pf, String u_name, String epId) {
        User user = new User(
            Alias = 'testUser'
            , Email = u_name
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = pf.Id
            , UserName = u_name
            , FederationIdentifier = epId
        );
                                
        insert user;
        
        return user;
    }
    
    /**
        User 생성 (UserName 지정)
    */
    public static User createUserFullWithRole(Profile pf, String u_name, String epId, UserRole ur) {
        User user = new User(
            Alias = 'testUser'
            , Email = u_name
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = pf.Id
            , UserName = u_name
            , FederationIdentifier = epId
            , UserRoleId = ur.Id
        );
                                
        insert user;
        
        return user;
    }

    /**
        Account 생성 (Name 지정,Account Code 지정)
    */
    public static Account createAccount(String a_name, String accCode) {
        Account acc = new Account(
            Name = a_name
            //Name = a_name,
            //AccountCode__c = accCode
        );
        
        insert acc;
        
        return acc;
    }    


    /**
        Contact 생성 (AccountId, Name, Email 지정)
    */
    public static Contact createContact(String accountId, String c_name, String email) {
        Contact cont = new Contact(
            AccountId = accountId
            , LastName = c_name
            , Email = email
        );
        
        insert cont;
        
        return cont;
    }

    /**
        Opportunity 생성 (Name 지정)
    */
    
    /*
    public static Opportunity createOpportunity(String a_name, String accId) {
        DescribeFieldResult describe = Opportunity.Product__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name='Component'].get(0);
        Opportunity opp = new Opportunity(
            Name = a_name,
            AccountId = accId,
            StageName = 'Qualification',
            CloseDate = Utils.getCurDatetime().date().addDays(1)
        );
        
        insert opp;
        
        return opp;
    }
	*/

    /**
    * @description Opportunity 생성
    * @author raeganja@partner.samsung.com | 2021-01-07 
    * @param String a_name 
    * @param String accId 
    * @param String oppCode 
    * @return Opportunity 
    **/
    // public static Opportunity createOpportunity(String a_name, String accId, String oppCode, String activityStatus) {
    //     Opportunity opp = new Opportunity(
    //         Name = a_name,
    //         AccountId = accId,
    //         OpportunityCode__c = oppCode,
    //         ActivityStatus__c = activityStatus,
    //         StageName = 'Qualification',
    //         CloseDate = Utils.getCurDatetime().date().addDays(1)
    //     );
        
    //     insert opp;
        
    //     return opp;
    // }

    /**
    * @description Opportunity 생성
    * @author raeganja@partner.samsung.com | 2021-01-07 
    * @param String oppId 
    * @param String activityStatus 
    * @return Opportunity_Activity__c 
    **/
    // public static Opportunity_Activity__c createOpportunityActivity(String oppId, String activityStatus) {
    //     Opportunity_Activity__c oppAct = new Opportunity_Activity__c(
    //         WhatId__c = oppId,
    //         ExtID__c = oppId+activityStatus,
    //         TransactionName__c = activityStatus
    //     );
        
    //     insert oppAct;
        
    //     return oppAct;
    // }
    
    /**
        ContentVersion 생성
    */
    public static ContentVersion createContentVersion() {
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'test',
            PathOnClient = '/test.JPG',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            origin = 'H'
        );
        insert contentVersion; 
        
        return contentVersion;
    }


    /**
        ContentDocumentLink 생성
    */
    public static ContentDocumentLink createContentDocumentLink (Id entityId, Id documentsId) {
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = entityId,
            ContentDocumentId = documentsId,
            shareType = 'V'
        );
        insert cdl;
        
        return cdl;
    }

    
    //    Employee__c 생성
    /*
    public static Employee__c createEmployee(String name, String epId){
        Employee__c emp = new Employee__c(
            Name = name,
            EvMailAddr__c = name + '@samsung.com',
            EvUniqID__c = epId
            // EvEmpNo__c = empNo
        );
        insert emp;

        return emp;
    }
	*/
    
    /*
    //    Product__c 생성
    public static Product__c createProdut(String productCode){
        Product__c prd = new Product__c(
            ProductCode__c = productCode
        );
        insert prd;
        return prd;
    }

    //    SoldtoParty__c 생성
    public static SoldtoParty__c createSoldtoParty(String s2pNumber){
        SoldtoParty__c s2p = new SoldtoParty__c(
            SoldtoPartyNumber__c = s2pNumber
        );
        insert s2p;
        return s2p;
    }
	*/
    
    /**
    * @description LBS__c 생성
    * @author raeganja@partner.samsung.com | 2021-01-04 
    * @param String name 
    * @param String oppId 
    * @return LBS__c 
    **/
    // public static LBS__c createLBS(String name, String oppId){
    //     LBS__c lbs = new LBS__c(
    //         Name = name,
    //         Opportunity__c = oppId            
    //     );
    //     insert lbs;

    //     return lbs;
    // }

        //    Employee__c 생성
    

}