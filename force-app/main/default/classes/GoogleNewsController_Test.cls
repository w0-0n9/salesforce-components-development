@IsTest
public with sharing class GoogleNewsController_Test {
    @IsTest
    private static void testMethod1() {
        Account acc = new Account(
            Name = 'Test',
            BillingCountryCode = 'KR'
            //AccountCode__c = 'TEST1'
        );
        insert acc;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        system.debug(GoogleNewsController.getContents4Account(acc.Id));
        Test.stopTest();
    }

    @IsTest
    private static void testMethod2() {
        Account acc = new Account(
            Name = 'Test',
            NewsKeyword__c = 'Test',
            BillingCountryCode = 'KR'
            //AccountCode__c = 'TEST1'
        );
        insert acc;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        system.debug(GoogleNewsController.getContents4Account(acc.Id));
        Test.stopTest();
    }

    @IsTest
    private static void testMethod3() {
        Account acc = new Account(
            Name = 'Test',
            NewsKeyword__c = 'Test;Imsi',
            BillingCountryCode = 'KR'
            //AccountCode__c = 'TEST1'
        );
        insert acc;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        system.debug(GoogleNewsController.getContents4Account(acc.Id));
        Test.stopTest();
    }
    @IsTest
    private static void testMethod4() {
        list<GoogleNewsKeyword__c> lkey = new list<GoogleNewsKeyword__c>();
        GoogleNewsKeyword__c k1 = new GoogleNewsKeyword__c(Name='삼성전기');
        lkey.add(k1);
        GoogleNewsKeyword__c k2 = new GoogleNewsKeyword__c(Name='삼성 SDS');
        lkey.add(k2);
        insert lkey;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        system.debug(GoogleNewsController.getContents4Home());
        system.debug(GoogleNewsController.parseCommonKeyword('Test;Imsi'));
        Test.stopTest();
    }

    @IsTest
    private static void testMethod5() {
        list<String> lkey = new list<String>();
        lkey.add('삼성전기');
        lkey.add('삼성 SDS');

        Test.startTest();
        system.debug(GoogleNewsController.saveKeywords(lkey));
        system.debug(GoogleNewsController.getKeywords());
        Test.stopTest();
    }

    @IsTest
    private static void testMethod6() {
        Boolean result;
        String shareRichText = 'Google News Share Test';
        String shareUrl = 'https://help.salesforce.com/s/?language=en_US';
        String shareUrlTitle = 'Google News Share Test';

        Test.startTest();
        system.debug(GoogleNewsController.shareNews(shareRichText, shareUrl, shareUrlTitle));
        result = GoogleNewsController.shareNews(shareRichText, shareUrl, shareUrlTitle);
        system.assertEquals(true, result);
        Test.stopTest();
    }

    //@IsTest
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            system.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml; charset=utf-8');
            String body = '<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">';
            body += '<channel>';
            body += '<generator>NFE/5.0</generator>';
            body += '<title>Google News</title>';
            body += '<link>https://news.google.com/</link>';
            body += '<language>ko</language>';
            body += '<webMaster>news-webmaster@google.com</webMaster>';
            body += '<copyright>2020 Google Inc.</copyright>';
            body += '<description>Google 뉴스</description>';
            body += '<item>';
            body += '<title>News Item Title</title>';
            body += '<link>http://www.example.com</link>';
            body += '<pubDate>Mon, 1 Jan 2020 00:00:00 GMT</pubDate>';
            body += '<description>description <img src="http://www.example.com/image.png"></img> blah blah blah </description>';
            body += '<source url="http://www.example.com">Source</source>';
            body += '<content medium="image" url="http://www.example.com">Source</content>';
            body += '</item>';
            body += '</channel>';
            body += '</rss>';
            
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}