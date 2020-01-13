@isTest
public with sharing class AdvertTableControllerTest {
    
    @isTest
    private static void testGetIdsAll(){
        TestDataFactory.createAdverts(200);
        
        Test.startTest();
        String result=AdvertTableController.getIds('');
        Test.stopTest();
        
        List<String>idsList=(List<String>)JSON.deserialize(result, List<String>.class);
        
        System.assertEquals(200, idsList.size());
    }
    
    @isTest
    private static void testGetIdsNone(){
        
        Test.startTest();
        String result=AdvertTableController.getIds('');
        Test.stopTest();
        
        List<String>idsList=(List<String>)JSON.deserialize(result, List<String>.class);
        
        System.assertEquals(0, idsList.size());
    }
    
    @isTest
    private static void testGetIdsSearch(){
        List<Advert__c>ads=TestDataFactory.createAdverts(2);
        List<Tag__c>tags=TestDataFactory.createTags(3);
        TestDataFactory.createAdvertTags(new Map<Advert__c, List<Tag__c>>{ads[0]=>tags,ads[1]=>tags});
        
        Test.startTest();
        String result=AdvertTableController.getIds('test1');
        Test.stopTest();
        
        List<String>idsList=(List<String>)JSON.deserialize(result, List<String>.class);
        
        System.assertEquals(2, idsList.size());
    }
    
    @isTest
    private static void testGetIdsSort(){
        List<Advert__c>ads=TestDataFactory.createAdverts(2);
        
        Test.startTest();
        String result=AdvertTableController.getIds('');
        Test.stopTest();
        
        List<String>idsList=(List<String>)JSON.deserialize(result, List<String>.class);
        
        System.assertEquals('test0', [SELECT Name FROM Advert__c WHERE Id =:idsList[0]].Name);
        System.assertEquals('test1', [SELECT Name FROM Advert__c WHERE Id =:idsList[1]].Name);
    }
    
    @isTest
    private static void testGetAllTagsPositive(){
        TestDataFactory.createTags(200);
        
        Test.startTest();
        String result=AdvertTableController.getAllTags();
        Test.stopTest();
        
        List<String>namesList=(List<String>)JSON.deserialize(result, List<String>.class);
        
        System.assertEquals(200, namesList.size());
    }
    
    @isTest
    private static void testGetAllTagsNegative(){
        
        Test.startTest();
        String result=AdvertTableController.getAllTags();
        Test.stopTest();
        
        List<String>namesList=(List<String>)JSON.deserialize(result, List<String>.class);
        
        System.assertEquals(0, namesList.size());
    }
    

}