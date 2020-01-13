/**
 * Created by sakrutnaya on 12/31/2019.
 */

public with sharing class AdvertTableController {

    @AuraEnabled
    public static String getIds(String searchTerm) {
        String returnIds = '';
        String toSearch = String.escapeSingleQuotes(String.valueOf(searchTerm));
        if (Schema.SObjectType.Advert__c.isAccessible()) {
            if (String.isBlank(toSearch)) {
                Map<Id, Advert__c> ids = new Map<Id, Advert__c>([
                        SELECT Id
                        FROM Advert__c
                        ORDER BY PublishDate__c DESC NULLS LAST
                        LIMIT 50000
                ]);
                returnIds = JSON.serialize(new List<Id>(ids.keySet()));
            } else {
                Map<Id, Advert__c> ids = new Map<Id, Advert__c>([
                        SELECT Id
                        FROM Advert__c
                        WHERE Id IN (SELECT Advert__c FROM AdvertTags__c WHERE Tag__r.Name = :toSearch)
                        ORDER BY PublishDate__c DESC NULLS LAST
                        LIMIT 50000
                ]);
                returnIds = JSON.serialize(new List<Id>(ids.keySet()));
            }
        }
        return returnIds;
    }

    @AuraEnabled
    public static String getAllTags() {
        List<String>tagNames = new List<String>();
        if (Schema.SObjectType.Tag__c.isAccessible()) {
            List<Tag__c> tags = [
                    SELECT Name
                    FROM Tag__c
                    LIMIT 50000
            ];
            if (tags != null && !tags.isEmpty()) {
                for (Tag__c tg : tags) {
                    tagNames.add(tg.Name);
                }
            }
        }
        return JSON.serialize(tagNames);
    }

}