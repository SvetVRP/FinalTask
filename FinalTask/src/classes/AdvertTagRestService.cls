/**
 * Created by sakrutnaya on 12/26/2019.
 */

@RestResource(urlMapping='/Advert/*')
global with sharing class AdvertTagRestService {

    @HttpPost
    global static String insertAdverts() {
        String advertJson = RestContext.request.requestBody.toString();
        List<ConvertAdvertTagWrapper> adTagWraps = ConvertAdvertTagWrapper.parse(advertJson);
        String results = '';
        Boolean hasAccess = Schema.SObjectType.Tag__c.fields.getMap().get('Name').getDescribe().isCreateable();
        hasAccess = hasAccess && Schema.SObjectType.Advert__c.fields.getMap().get('Name').getDescribe().isCreateable();
        Map<String, Schema.SObjectField> fieldDescribeTokens = Schema.SObjectType.AdvertTags__c.fields.getMap();
        hasAccess = hasAccess && fieldDescribeTokens.get('Advert__c').getDescribe().isCreateable();
        hasAccess = hasAccess && fieldDescribeTokens.get('Tag__c').getDescribe().isCreateable();
        if (hasAccess) {
            if (!adTagWraps.isEmpty()) {
                Map<String, Set<String>> adNamesWithTagNames = getAdvertNamesWithCorrespondingTagNames(adTagWraps);
                Set<String>tagNames = getTagNames(adNamesWithTagNames.values());
                List<Tag__c>existedTags = [
                        SELECT Name
                        FROM Tag__c
                        WHERE Name IN :tagNames
                ];
                getTagNamesWithoutDuplicates(tagNames, existedTags);
                List<Tag__c>creatingTags = getTagsToInsert(tagNames);
                List<String>tagsSrList = ProcessDml.processInsert(creatingTags);
                List<Advert__c>existedAdverts = [
                        SELECT Id,Name
                        FROM Advert__c
                        WHERE Name IN :adNamesWithTagNames.keySet()
                ];
                List<String> adsSrList = ProcessDml.processInsert(getAdvertsToInsertWithoutDuplicates(getMapAdvertsToInsert(adTagWraps), existedAdverts));
                existedTags.addAll(creatingTags);
                List<AdvertTags__c> advertTagsToCreate = getAdvertTagsToCreate(adNamesWithTagNames, existedTags);
                List<String>adTagsSrList = ProcessDml.processInsert(advertTagsToCreate);
                List<List<String>> saveResults = new List<List<String>>{
                        adsSrList, tagsSrList, adTagsSrList
                };
                results = JSON.serialize(saveResults);
            }
        } else {
            results = 'The following errors have occurred: no access-insufficient privilege';
        }
        return results;
    }

    @HttpDelete
    global static String deleteAdvertTags() {
        String advertJson = RestContext.request.requestBody.toString();
        List<ConvertAdvertTagWrapper> adTagWraps = ConvertAdvertTagWrapper.parse(advertJson);
        String results = '';
        if (Schema.SObjectType.AdvertTags__c.isDeletable()) {
            if (!adTagWraps.isEmpty()) {
                Map<String, Set<String>> adNamesWithTagNames = getAdvertNamesWithCorrespondingTagNames(adTagWraps);
                Set<String>tags = getTagNames(adNamesWithTagNames.values());
                List<AdvertTags__c> advertTagsToDelete = getAdvertTagsToDelete(adNamesWithTagNames, tags);
                List<String>adTagsDelList = ProcessDml.processDelete(advertTagsToDelete);
                results = JSON.serialize(adTagsDelList);
            }
        } else {
            results = 'The following errors have occurred: no access-insufficient privilege';
        }
        return results;
    }

    private static Map<String, Set<String>> getAdvertNamesWithCorrespondingTagNames(List<ConvertAdvertTagWrapper> adTagWraps) {
        Map<String, Set<String>> adNamesWithTagNames = new Map<String, Set<String>>();
        if (adTagWraps != null && !adTagWraps.isEmpty()) {
            for (ConvertAdvertTagWrapper adTag : adTagWraps) {
                if (String.isNotBlank(adTag.AdvertName) && !adNamesWithTagNames.containsKey(adTag.AdvertName)) {
                    adNamesWithTagNames.put(adTag.AdvertName.trim(), new Set<String>());
                }
                if (adTag.Tags != null && !adTag.Tags.isEmpty()) {
                    for (ConvertAdvertTagWrapper.Tags tg : adTag.Tags) {
                        if (String.isNotBlank(tg.TagName)) {
                            adNamesWithTagNames.get(adTag.AdvertName.trim()).add(tg.TagName.trim());
                        }
                    }
                }
            }
        }
        return adNamesWithTagNames;
    }

    private static Set<String> getTagNames(List<Set<String>> inputTagNames) {
        Set<String> names = new Set<String>();
        if (inputTagNames != null && !inputTagNames.isEmpty()) {
            for (Set<String> currentNames : inputTagNames) {
                names.addAll(currentNames);
            }
        }
        return names;
    }

    private static List<Tag__c> getTagsToInsert(Set<String> tagNames) {
        List<Tag__c> tags = new List<Tag__c>();
        if (tagNames != null && !tagNames.isEmpty()) {
            for (String tagName : tagNames) {
                if (String.isNotBlank(tagName)) {
                    tags.add(new Tag__c(Name = tagName.trim()));
                }
            }
        }
        return tags;
    }

    private static void getTagNamesWithoutDuplicates(Set<String> tagNames, List<Tag__c>existedTags) {
        for (Tag__c tg : existedTags) {
            tagNames.remove(tg.Name);
        }
    }

    private static Map<String, Advert__c> getMapAdvertsToInsert(List<ConvertAdvertTagWrapper> adTagWraps) {
        Map<String, Advert__c>ads = new Map<String, Advert__c>();
        for (ConvertAdvertTagWrapper adTag : adTagWraps) {
            if (!ads.containsKey(adTag.AdvertName)) {
                ads.put(adTag.AdvertName, new Advert__c(Name = adTag.AdvertName, Description__c = adTag.Description));
            }
        }
        return ads;
    }

    private static List<Advert__c> getAdvertsToInsertWithoutDuplicates(Map<String, Advert__c>ads, List<Advert__c>existedAdverts) {
        for (Advert__c ad : existedAdverts) {
            ads.remove(ad.Name);
        }
        return ads.values();
    }

    private static List<AdvertTags__c> getAdvertTagsToDelete(Map<String, Set<String>> adNamesWithTagNames, Set<String>tags) {
        List<AdvertTags__c> advertTagsToDelete = new List<AdvertTags__c>();
        for (Advert__c ad : [
                SELECT Id,Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        WHERE Tag__r.Name IN :tags
                )
                FROM Advert__c
                WHERE Name IN :adNamesWithTagNames.keySet()
        ]) {
            Set<String> tagsToCurrAd = adNamesWithTagNames.get(ad.Name);
            List<AdvertTags__c> existedTagsInCurrAd = ad.AdvertTags__r;
            for (AdvertTags__c adTag : existedTagsInCurrAd) {
                if (tagsToCurrAd.contains(adTag.Tag__r.Name)) {
                    advertTagsToDelete.add(adTag);
                }
            }
        }
        return advertTagsToDelete;
    }

    private static List<AdvertTags__c> getAdvertTagsToCreate(Map<String, Set<String>> adNamesWithTagNames, List<Tag__c>existedTags) {
        List<AdvertTags__c> advertTagsToCreate = new List<AdvertTags__c>();
        Set<String>tagNames = getTagNames(adNamesWithTagNames.values());
        for (Advert__c ad : [
                SELECT Id,Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        WHERE Tag__r.Name IN :tagNames
                )
                FROM Advert__c
                WHERE Name IN :adNamesWithTagNames.keySet()
        ]) {
            Set<String> tagsToCurrAd = adNamesWithTagNames.get(ad.Name);
            Set<String> existedTagNamesInCurrAd = new Set<String>();
            for (AdvertTags__c adTag : ad.AdvertTags__r) {
                existedTagNamesInCurrAd.add(adTag.Tag__r.Name);
            }
            tagsToCurrAd.removeAll(existedTagNamesInCurrAd);
            Map<String, Tag__c>existedTagsWithNames = new Map<String, Tag__c>();
            for (Tag__c tg : existedTags) {
                existedTagsWithNames.put(tg.Name, tg);
            }
            for (String tgName : tagsToCurrAd) {
                Id tgId = existedTagsWithNames.get(tgName).Id;
                if (tgId != null) {
                    advertTagsToCreate.add(new AdvertTags__c(Advert__c = ad.Id, Tag__c = tgId));
                }
            }
        }
        return advertTagsToCreate;
    }

}