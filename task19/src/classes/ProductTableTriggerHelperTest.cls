/**
 * Created by sakrutnaya on 12/17/2019.
 */
@isTest
public with sharing class ProductTableTriggerHelperTest {

    @testSetup
    static void testCreateData(){
        Warehouse__c newWarehouse=new Warehouse__c(Name='test', Period_Start__c=System.today(),Period_End__c=(System.today()+5));
        insert newWarehouse;
    }

    @isTest
    static void testLinkProductsToWarehousePositive(){
        List<Product_Table__c>prodWithoutWarehouse = new List<Product_Table__c>();
        Test.startTest();
        for(Integer i=0;i<5;i++){
            Product_Table__c prod=new Product_Table__c(Name='test',Unit_Price__c=1,Added_Date__c=(System.today()+6+i*6));
            prodWithoutWarehouse.add(prod);
        }
        insert prodWithoutWarehouse;
        Test.stopTest();
        System.assertEquals(6,[SELECT Id FROM Warehouse__c].size());
        for(Product_Table__c prod:[SELECT Warehouse__c FROM Product_Table__c]){
            System.assert(prod.Warehouse__c!=null);
        }
    }

    @isTest
    static void testLinkProductsToWarehouseNegative(){
        List<Product_Table__c>prodWithoutWarehouse = new List<Product_Table__c>();
        Test.startTest();
        for(Integer i=0;i<5;i++){
            Product_Table__c prod=new Product_Table__c(Name='test',Unit_Price__c=1);
            prodWithoutWarehouse.add(prod);
        }
        insert prodWithoutWarehouse;
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM Warehouse__c].size());
        for(Product_Table__c prod:[SELECT Warehouse__c FROM Product_Table__c]){
            System.assert(prod.Warehouse__c!=null);
        }
    }

    @isTest
    static void testLinkProductsToWarehousePartial(){
        List<Product_Table__c>prodWithoutWarehouse = new List<Product_Table__c>();
        Test.startTest();
        for(Integer i=0;i<5;i++){
            Product_Table__c prod=new Product_Table__c(Name='test',Unit_Price__c=1,Added_Date__c=(System.today()+i*5));
            prodWithoutWarehouse.add(prod);
        }
        insert prodWithoutWarehouse;
        Test.stopTest();
        System.assertEquals(4,[SELECT Id FROM Warehouse__c].size());
        for(Product_Table__c prod:[SELECT Warehouse__c FROM Product_Table__c]){
            System.assert(prod.Warehouse__c!=null);
        }
    }

}