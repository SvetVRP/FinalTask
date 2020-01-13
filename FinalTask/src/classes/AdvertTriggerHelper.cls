/**
 * Created by sakrutnaya on 12/31/2019.
 */

public with sharing class AdvertTriggerHelper {

    public void preventDuplicates(List<Advert__c> adverts) {
        new ProcessDuplicates().preventDuplicates(adverts);
    }

    public void findDuplicatesInList(List<Advert__c> adverts) {
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueAdvertName'
                LIMIT 1
        ];
        if (duplRule.IsActive) {
            new ProcessDuplicates().findDuplicatesInList(adverts, 'Name');
        }
    }

}