/**
 * @description       : 
 * @author            : masterK
 * @group             : 
 * @last modified on  : 07-20-2023
 * @last modified by  : masterK
**/
public class HomeVideoController {

    @AuraEnabled(cacheable=true)
    public static List<HomeVideo__c> getHomeVideo() {
        return [SELECT Id, OwnerId, Name, videoID__c, URL__c, Order__c, CreatedById, LastModifiedById FROM HomeVideo__c WHERE IsActive__c = true ORDER BY Order__c ASC];
    }

    @AuraEnabled(cacheable=true)
    public static String getHomeVideoURL() {
        
        String url = 'https://www.youtube.com/embed/UNWduQ3VH4M?autoplay=1&mute=1&loop=1&playlist=';
        List<HomeVideo__c> homeVideoList = [SELECT Id, OwnerId, Name, videoID__c, URL__c, Order__c, CreatedById, LastModifiedById FROM HomeVideo__c WHERE IsActive__c = true ORDER BY Order__c ASC];

        if(homeVideoList.size() > 0){
            for(HomeVideo__c homevideo : homeVideoList){
                url = url + homevideo.videoID__c + ',';
            }
        }

        system.debug(LoggingLevel.ERROR, '*** HomeVideoController getHomeVideoURL url :  '+url);

        Return url;
    }

}