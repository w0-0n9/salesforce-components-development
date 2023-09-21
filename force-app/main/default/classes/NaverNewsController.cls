/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class NaverNewsController {
    @AuraEnabled
    public static String callNaverNewsAPI(String searchQuery) {
        String apiKey = 'eAqcPnZdI0Pi77WOD2HZ';
        String apiUrl = 'https://openapi.naver.com/v1/search/news.json';
        String params = 'query=' + EncodingUtil.urlEncode(searchQuery, 'UTF-8');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl + '?' + params + '&display=30&start=1&sort=sim');
        request.setMethod('GET');
        request.setHeader('X-Naver-Client-Id', apiKey);
        request.setHeader('X-Naver-Client-Secret', '4kgULgrdnq');
        request.setHeader('Accept', 'application/xml');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        // Convert HttpResponse to a JSON string and return it
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            return 'Error';
        }
    }
}