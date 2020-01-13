/**
 * Created by sakrutnaya on 12/31/2019.
 */
@isTest
public with sharing class AdvertTriggerHelperTest {

    @isTest
    private static void testPreventDuplicatesPositive() {
        List<Advert__c> ads = TestDataFactory.createAdverts(50);

        Test.startTest();
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueAdvertName'
                LIMIT 1
        ];
        Boolean hasExpectedError = false;
        delete ads;
        TestDataFactory.createAdverts(50);
        try {
            undelete ads;
        } catch (Exception e) {
            hasExpectedError = e.getMessage().containsIgnoreCase('Duplicated values are not allowed');
        }
        Test.stopTest();

        System.assert(!duplRule.IsActive || hasExpectedError);
    }

    @isTest
    private static void testPreventDuplicatesNegative() {
        List<Advert__c> ads = TestDataFactory.createAdverts(100);

        Test.startTest();
        delete ads;
        insert new Advert__c(Name = 'name');
        undelete ads;
        Test.stopTest();

        System.assertEquals(101, [SELECT Id FROM Advert__c].size());
    }

    @isTest
    private static void testFindDuplicatesInListInsert() {
        List<Advert__c> ads = new List<Advert__c>{
                new Advert__c(Name = 'test'), new Advert__c(Name = 'Test')
        };

        Test.startTest();
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueAdvertName'
                LIMIT 1
        ];
        Boolean hasExpectedError = false;
        try {
            insert ads;
        } catch (Exception e) {
            hasExpectedError = e.getMessage().containsIgnoreCase('The list contains duplicates');
        }
        Test.stopTest();

        System.assert(!duplRule.IsActive || hasExpectedError);
    }

    @isTest
    private static void testFindDuplicatesInListInsertNegative() {
        List<Advert__c> ads = TestDataFactory.createAdverts(100);

        Test.startTest();
        insert new List<Advert__c>{
                new Advert__c(Name = 'name'), new Advert__c(Name = 'name2')
        };
        Test.stopTest();

        System.assertEquals(102, [SELECT Id FROM Advert__c].size());
    }

    @isTest
    private static void testFindDuplicatesInListUpdate() {
        List<Advert__c> ads = TestDataFactory.createAdverts(5);

        Test.startTest();
        DuplicateRule duplRule = [
                SELECT DeveloperName, IsActive
                FROM DuplicateRule
                WHERE DeveloperName = :'UniqueAdvertName'
                LIMIT 1
        ];
        Boolean hasExpectedError = false;
        for (Advert__c ad : ads) {
            ad.Name = 'fail';
        }
        try {
            update ads;
        } catch (Exception e) {
            hasExpectedError = e.getMessage().containsIgnoreCase('The list contains duplicates');
        }
        Test.stopTest();

        System.assert(!duplRule.IsActive || hasExpectedError);
    }

    @isTest
    private static void testFindDuplicatesInListUpdateNegative() {
        List<Advert__c> ads = TestDataFactory.createAdverts(100);

        Test.startTest();
        ads[0].Name = 'name';
        ads[1].Name = 'name2';
        update new List<Advert__c>{
                ads[0], ads[1]
        };
        Test.stopTest();

        System.assertEquals('name', ads[0].Name);
        System.assertEquals('name2', ads[1].Name);
    }

}