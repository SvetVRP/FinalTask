/**
 * Created by sakrutnaya on 1/8/2020.
 */
@isTest
public with sharing class AdvertTagRestServiceTest {

    @isTest
    public static void testInsertAdvertsNotExist() {
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'POST';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;

        Test.startTest();
        AdvertTagRestService.insertAdverts();
        Test.stopTest();

        List<Advert__c>ads = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        List<Tag__c>tags = [SELECT Name FROM Tag__c];

        System.assertEquals(1, ads.size());
        System.assertEquals(4, tags.size());
        System.assertEquals(4, ads[0].AdvertTags__r.size());
        System.assertEquals('test0', ads[0].AdvertTags__r[0].Tag__r.Name);
        System.assertEquals('test1', ads[0].AdvertTags__r[1].Tag__r.Name);
        System.assertEquals('test2', ads[0].AdvertTags__r[2].Tag__r.Name);
        System.assertEquals('test3', ads[0].AdvertTags__r[3].Tag__r.Name);
    }

    @isTest
    public static void testInsertAdvertsAllExist() {
        List<Advert__c> adverts = TestDataFactory.createAdverts(1);
        List<Tag__c> tags = TestDataFactory.createTags(4);
        TestDataFactory.createAdvertTags(new Map<Advert__c, List<Tag__c>>{
                adverts[0] => tags
        });
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'POST';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;

        Test.startTest();
        String result = AdvertTagRestService.insertAdverts();
        Test.stopTest();

        adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        tags = [SELECT Name FROM Tag__c];
        List<Object>objects = (List<Object>) JSON.deserializeUntyped(result);

        System.assertEquals(1, adverts.size());
        System.assertEquals(4, tags.size());
        System.assertEquals(4, adverts[0].AdvertTags__r.size());
        System.assertEquals('test0', adverts[0].AdvertTags__r[0].Tag__r.Name);
        System.assertEquals('test1', adverts[0].AdvertTags__r[1].Tag__r.Name);
        System.assertEquals('test2', adverts[0].AdvertTags__r[2].Tag__r.Name);
        System.assertEquals('test3', adverts[0].AdvertTags__r[3].Tag__r.Name);
        System.assert(((List<Object>) objects[0]).isEmpty());
        System.assert(((List<Object>) objects[1]).isEmpty());
        System.assert(((List<Object>) objects[2]).isEmpty());
    }

    @isTest
    public static void testInsertAdvertsExistPartially() {
        List<Advert__c> adverts = TestDataFactory.createAdverts(1);
        List<Tag__c> tags = TestDataFactory.createTags(2);
        tags.remove(0);
        TestDataFactory.createAdvertTags(new Map<Advert__c, List<Tag__c>>{
                adverts[0] => tags
        });
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'POST';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;

        Test.startTest();
        String result = AdvertTagRestService.insertAdverts();
        Test.stopTest();

        adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        tags = [SELECT Name FROM Tag__c];
        List<Object>objects = (List<Object>) JSON.deserializeUntyped(result);

        System.assertEquals(1, adverts.size());
        System.assertEquals(4, tags.size());
        System.assertEquals(4, adverts[0].AdvertTags__r.size());
        System.assertEquals('test0', adverts[0].AdvertTags__r[0].Tag__r.Name);
        System.assertEquals('test1', adverts[0].AdvertTags__r[1].Tag__r.Name);
        System.assertEquals('test2', adverts[0].AdvertTags__r[2].Tag__r.Name);
        System.assertEquals('test3', adverts[0].AdvertTags__r[3].Tag__r.Name);
        System.assert(((List<Object>) objects[0]).isEmpty());
        System.assertEquals(2, ((List<Object>) objects[1]).size());
        System.assertEquals(3, ((List<Object>) objects[2]).size());
    }

    @isTest
    public static void testInsertAdvertsFail() {
        List<Advert__c> adverts = TestDataFactory.createAdverts(1);
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"AdvertName":"test0","Tags":[{"TagName":' +
                '"123456789123456789123456789123456789123456789123456789123456789123456789123456789"}]}]');
        RestContext.request = req;

        Test.startTest();
        String result = AdvertTagRestService.insertAdverts();
        Test.stopTest();

        adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        List<Tag__c>tags = [
                SELECT Name
                FROM Tag__c
        ];
        List<Object>objects = (List<Object>) JSON.deserializeUntyped(result);

        System.assertEquals(1, adverts.size());
        System.assertEquals(0, tags.size());
        System.assertEquals(0, adverts[0].AdvertTags__r.size());
        System.assert(((List<Object>) objects[0]).isEmpty());
        System.assertEquals(1, ((List<Object>) objects[1]).size());
        System.assert(((List<Object>) objects[1])[0].toString().containsIgnoreCase('error'));
        System.assertEquals(0, ((List<Object>) objects[2]).size());
    }

    @isTest
    public static void testInsertAdvertsCheckAccess() {
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'POST';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile currentProfile = [SELECT Id FROM Profile WHERE Name = 'Chatter External User'];
        User currentUser = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = currentProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = uniqueUserName);

        Test.startTest();
        String result = '[]';
        System.runAs(currentUser) {
            result = AdvertTagRestService.insertAdverts();
        }
        Test.stopTest();

        List<Advert__c>adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        List<Tag__c>tags = [
                SELECT Name
                FROM Tag__c
        ];

        System.assertEquals(0, adverts.size());
        System.assertEquals(0, tags.size());
        System.assert(result.containsIgnoreCase('insufficient privilege'));
    }

    @isTest
    public static void testDeleteAdvertTagsNotExist() {
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'DELETE';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;

        Test.startTest();
        String result = AdvertTagRestService.deleteAdvertTags();
        Test.stopTest();

        System.assert(((List<Object>) JSON.deserializeUntyped(result)).isEmpty());
    }

    @isTest
    public static void testDeleteAdvertTagsAllExist() {
        List<Advert__c> adverts = TestDataFactory.createAdverts(1);
        List<Tag__c> tags = TestDataFactory.createTags(4);
        TestDataFactory.createAdvertTags(new Map<Advert__c, List<Tag__c>>{
                adverts[0] => tags
        });
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'DELETE';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;

        Test.startTest();
        String result = AdvertTagRestService.deleteAdvertTags();
        Test.stopTest();

        adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        tags = [SELECT Name FROM Tag__c];

        System.assertEquals(1, adverts.size());
        System.assertEquals(4, tags.size());
        System.assertEquals(0, adverts[0].AdvertTags__r.size());
        System.assertEquals(4, ((List<Object>) JSON.deserializeUntyped(result)).size());
    }

    @isTest
    public static void testDeleteAdvertTagsExistPartially() {
        List<Advert__c> adverts = TestDataFactory.createAdverts(1);
        List<Tag__c> tags = TestDataFactory.createTags(8);
        TestDataFactory.createAdvertTags(new Map<Advert__c, List<Tag__c>>{
                adverts[0] => tags
        });
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'DELETE';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;

        Test.startTest();
        String result = AdvertTagRestService.deleteAdvertTags();
        Test.stopTest();

        adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        tags = [SELECT Name FROM Tag__c];
        List<Object>objects = (List<Object>) JSON.deserializeUntyped(result);

        System.assertEquals(1, adverts.size());
        System.assertEquals(8, tags.size());
        System.assertEquals(4, adverts[0].AdvertTags__r.size());
        System.assertEquals('test4', adverts[0].AdvertTags__r[0].Tag__r.Name);
        System.assertEquals('test5', adverts[0].AdvertTags__r[1].Tag__r.Name);
        System.assertEquals('test6', adverts[0].AdvertTags__r[2].Tag__r.Name);
        System.assertEquals('test7', adverts[0].AdvertTags__r[3].Tag__r.Name);
        System.assertEquals(4, ((List<Object>) JSON.deserializeUntyped(result)).size());
    }

    @isTest
    public static void testDeleteAdvertTagsCheckAccess() {
        List<Advert__c> adverts = TestDataFactory.createAdverts(1);
        List<Tag__c> tags = TestDataFactory.createTags(2);
        TestDataFactory.createAdvertTags(new Map<Advert__c, List<Tag__c>>{
                adverts[0] => tags
        });
        RestRequest req = new RestRequest();
        req.requestURI = 'https://taskfinal-dev-ed.my.salesforce.com/services/apexrest/Advert';
        req.httpMethod = 'DELETE';
        req.requestBody = [
                SELECT Id, Body
                FROM StaticResource
                WHERE Name = 'testJsonAdvertTag'
                LIMIT 1
        ].Body;
        RestContext.request = req;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile currentProfile = [SELECT Id FROM Profile WHERE Name = 'Chatter External User'];
        User currentUser = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = currentProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = uniqueUserName);

        Test.startTest();
        String result = '[]';
        System.runAs(currentUser) {
            result = AdvertTagRestService.deleteAdvertTags();
        }
        Test.stopTest();

        adverts = [
                SELECT Name, (
                        SELECT Tag__r.Name
                        FROM AdvertTags__r
                        ORDER BY Tag__r.Name ASC NULLS LAST
                )
                FROM Advert__c
        ];
        tags = [
                SELECT Name
                FROM Tag__c
        ];

        System.assertEquals(1, adverts.size());
        System.assertEquals(2, tags.size());
        System.assertEquals(2, adverts[0].AdvertTags__r.size());
        System.assert(result.containsIgnoreCase('insufficient privilege'));
    }

}