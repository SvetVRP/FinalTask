/**
 * Created by sakrutnaya on 12/31/2019.
 */
@isTest
public with sharing class TagTriggerHelperTest {

    @isTest
    private static void testPreventDuplicatesPositive() {
        List<Tag__c> tags = TestDataFactory.createTags(50);

        Test.startTest();
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueTagName'
                LIMIT 1
        ];
        Boolean hasExpectedError = false;
        delete tags;
        TestDataFactory.createTags(50);
        try {
            undelete tags;
        } catch (Exception e) {
            hasExpectedError = e.getMessage().containsIgnoreCase('Duplicated values are not allowed');
        }
        Test.stopTest();

        System.assert(!duplRule.IsActive || hasExpectedError);
    }

    @isTest
    private static void testPreventDuplicatesNegative() {
        List<Tag__c> tags = TestDataFactory.createTags(100);

        Test.startTest();
        delete tags;
        insert new Tag__c(Name = 'name');
        undelete tags;
        Test.stopTest();

        System.assertEquals(101, [SELECT Id FROM Tag__c].size());
    }

    @isTest
    private static void testFindDuplicatesInListInsert() {
        List<Tag__c> tags = new List<Tag__c>{
                new Tag__c(Name = 'test'), new Tag__c(Name = 'Test')
        };

        Test.startTest();
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueTagName'
                LIMIT 1
        ];
        Boolean hasExpectedError = false;
        try {
            insert tags;
        } catch (Exception e) {
            hasExpectedError = e.getMessage().containsIgnoreCase('The list contains duplicates');
        }
        Test.stopTest();

        System.assert(!duplRule.IsActive || hasExpectedError);
    }

    @isTest
    private static void testFindDuplicatesInListInsertNegative() {
        List<Tag__c> tags = TestDataFactory.createTags(100);

        Test.startTest();
        insert new List<Tag__c>{
                new Tag__c(Name = 'name'), new Tag__c(Name = 'name2')
        };
        Test.stopTest();

        System.assertEquals(102, [SELECT Id FROM Tag__c].size());
    }

    @isTest
    private static void testFindDuplicatesInListUpdate() {
        List<Tag__c> tags = TestDataFactory.createTags(5);

        Test.startTest();
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueTagName'
                LIMIT 1
        ];
        Boolean hasExpectedError = false;
        for (Tag__c ad : tags) {
            ad.Name = 'fail';
        }
        try {
            update tags;
        } catch (Exception e) {
            hasExpectedError = e.getMessage().containsIgnoreCase('The list contains duplicates');
        }
        Test.stopTest();

        System.assert(!duplRule.IsActive || hasExpectedError);
    }

    @isTest
    private static void testFindDuplicatesInListUpdateNegative() {
        List<Tag__c> tags = TestDataFactory.createTags(100);

        Test.startTest();
        tags[0].Name = 'name';
        tags[1].Name = 'name2';
        update new List<Tag__c>{
                tags[0], tags[1]
        };
        Test.stopTest();

        System.assertEquals('name', tags[0].Name);
        System.assertEquals('name2', tags[1].Name);
    }

}