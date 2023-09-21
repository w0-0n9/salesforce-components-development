public class HomeURLController {
    @AuraEnabled
    public static List<UrlInfo> urlSetting(){

        system.debug(LoggingLevel.ERROR, '*** HomeURLController urlSetting Start !!! ');

        Map<String, List<UrlInfo>> urlMap = new Map<String, List<UrlInfo>>();
        
        User user = [SELECT Id, Name, ProfileId, Profile.Name, UserRoleId, UserRole.Name, LanguageLocaleKey, IsActive FROM User WHERE Id =: Userinfo.getUserId()];
        List<Home_URL__c> urlList = [SELECT Id, Name, SystemName_EN__c, Role__c, URL__c, Order__c FROM Home_URL__c ORDER BY Role__c, Order__c];
        
        if(urlList.size() > 0){
            for(Home_URL__c url : urlList){
                UrlInfo ui = new UrlInfo();
                ui.Name = user.LanguageLocaleKey == 'ko' ? url.Name : url.SystemName_EN__c;
                ui.Url = url.URL__c;

                system.debug(LoggingLevel.ERROR, '*** urlMap.get(url.Role__c) : ' + urlMap.get(url.Role__c));

                if(urlMap.get(url.Role__c) != null){
                    List<UrlInfo> old_urlList = urlMap.get(url.Role__c);
                    old_urlList.add(ui);

                    urlMap.put(url.Role__c, old_urlList);
                } else{
                    List<UrlInfo> new_urlList = new List<UrlInfo>();
                    new_urlList.add(ui);

                    urlMap.put(url.Role__c, new_urlList);
                }
            }
        }

        system.debug(LoggingLevel.ERROR, '*** HomeURLController urlSetting End !!! ');

        if(urlMap.get(user.UserRole.Name) != null){
            return urlMap.get(user.UserRole.Name);
        } else{
            return urlMap.get('Default');
        }

    }

    public class UrlInfo {
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Url {get; set;}
    }
    
}