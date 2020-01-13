/**
 * Created by sakrutnaya on 12/26/2019.
 */

public with sharing class TestDataFactory {

    public static List<Advert__c> createAdverts(Integer num) {
        List<Advert__c> adverts = new List<Advert__c>();
        for (Integer i = 0; i < num; i++) {
            adverts.add(new Advert__c(Name = 'test' + i, PublishDate__c = System.today() - i, Description__c = 'test'));
        }
        insert adverts;
        return adverts;
    }

    public static List<Tag__c> createTags(Integer num) {
        List<Tag__c> tags = new List<Tag__c>();
        for (Integer i = 0; i < num; i++) {
            tags.add(new Tag__c(Name = 'test' + i));
        }
        insert tags;
        return tags;
    }

    public static List<AdvertTags__c> createAdvertTags(Map<Advert__c, List<Tag__c>> advertsWithTags) {
        List<AdvertTags__c> advertTags = new List<AdvertTags__c>();
        for (Advert__c ad : advertsWithTags.keySet()) {
            for (Tag__c tg : advertsWithTags.get(ad)) {
                advertTags.add(new AdvertTags__c(Advert__c = ad.Id, Tag__c = tg.Id));
            }
        }
        insert advertTags;
        return advertTags;
    }

}