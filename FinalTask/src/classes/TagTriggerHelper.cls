/**
 * Created by sakrutnaya on 12/31/2019.
 */

public with sharing class TagTriggerHelper {

    public void preventDuplicates(List<Tag__c> tags) {
        new ProcessDuplicates().preventDuplicates(tags);
    }

    public void findDuplicatesInList(List<Tag__c> tags) {
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueTagName'
                LIMIT 1
        ];
        if (duplRule.IsActive) {
            new ProcessDuplicates().findDuplicatesInList(tags, 'Name');
        }
    }

}