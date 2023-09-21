/**
 * @description       : 
 * @author            : masterK
 * @group             : 
 * @last modified on  : 07-25-2023
 * @last modified by  : masterK
**/
public class MarqueeController {

    @AuraEnabled(cacheable=true)
    public static List<Marquee__c> getMarquee() {
        return [SELECT Id, Name, Content__c, Order__c, Link__c, Owner.name, CreatedById, LastModifiedById FROM Marquee__c WHERE IsActive__c = true ORDER BY Order__c ASC];
    }

    @AuraEnabled(cacheable=true)
    public static String getMarqueeContent() {
        
        String rMarqeee = '';
        List<Marquee__c> marqueeList = [SELECT Id, Name, Content__c, Order__c, Link__c, Owner.name, CreatedById, LastModifiedById FROM Marquee__c WHERE IsActive__c = true ORDER BY Order__c ASC];

        if(marqueeList.size() > 0){
            for(Marquee__c marquee : marqueeList){

                /*
                if(marquee.Link__c != null) {
                    rMarqeee = rMarqeee + '<a href="'+ marquee.Link__c+'" target="_blank">'+ marquee.Content__c + '</a>    *****  ';

                } else {
                    rMarqeee = rMarqeee + marquee.Content__c + ' *****  ';
                }
                */

                rMarqeee = rMarqeee + marquee.Content__c + ' *****  ';

            }
        }

        system.debug(LoggingLevel.ERROR, '*** MarqueeController getMarqueeContent rMarqeee :  '+rMarqeee);

        Return rMarqeee;
    }

}