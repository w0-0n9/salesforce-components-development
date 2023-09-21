@isTest
public class HomeURLController_Test {
    
    @TestSetup
    static void setup(){
        List<Home_URL__c> urlList = new List<Home_URL__c>();

        Home_URL__c url1 = new Home_URL__c(
            Name = 'Google',
            SystemName_EN__c = 'Google',
            Role__c = 'CEO',
            URL__c = 'https://google.com',
            Order__c = 1
        );
        urlList.add(url1);

        Home_URL__c url2 = new Home_URL__c(
            Name = 'Naver',
            SystemName_EN__c = 'Naver',
            Role__c = 'Default',
            URL__c = 'https://naver.com',
            Order__c = 2
        );
        urlList.add(url2);

        Home_URL__c url3 = new Home_URL__c(
            Name = 'Google',
            SystemName_EN__c = 'Google',
            Role__c = 'CEO',
            URL__c = 'https://google.com',
            Order__c = 1
        );
        urlList.add(url3);

        if(urlList.size() > 0) insert urlList;
    }

    @isTest
    static void testCase() {
        
        Test.startTest();
        
        HomeURLController.urlSetting();
        
        Test.stopTest();
    }
}