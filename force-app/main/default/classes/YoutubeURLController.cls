/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-21-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class YoutubeURLController {

    @AuraEnabled(cacheable=true)
    public static String getYoutubeURL() {
        
        String url = 'https://www.youtube.com/embed/UNWduQ3VH4M?autoplay=1&mute=1&controls=0&loop=1&playlist=';
        List<Youtube__c> YoutubeList = [SELECT Id, OwnerId, Name, youtubeID__c, URL__c, Order__c, CreatedById, LastModifiedById FROM Youtube__c WHERE IsActive__c = true ORDER BY Order__c ASC];

        if(YoutubeList.size() > 0){
            for(Youtube__c youtubevideo : YoutubeList){
                url = url + youtubevideo.youtubeID__c + ',';
            }
        }

        system.debug(LoggingLevel.ERROR, '*** YoutubeURLController getYoutubeURL url :  '+url);

        Return url;
    }
}