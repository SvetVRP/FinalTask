/**
 * Created by sakrutnaya on 12/19/2019.
 */
@isTest
public with sharing class BuyControllerTest {

    @testSetup
    static void createData() {
        Contact cont = new Contact (LastName = 'fail', Email = 'test@test.com');
        insert cont;
        Product_Table__c prod = new Product_Table__c(Name = 'test', Unit_Price__c = 1, Units_Available__c = 100);
        insert prod;
    }

    static BuyController testHelper() {
        Product_Table__c currProd = [SELECT Name,Units_Available__c,Unit_Price__c FROM Product_Table__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(currProd);
        BuyController testCont = new BuyController(sc);
        PageReference pageRef = Page.Buy;
        Test.setCurrentPage(pageRef);
        return testCont;
    }

    @isTest
    static void testCalculateTotalPositive() {
        BuyController ctrl = testHelper();
        ctrl.unitCount = 10;
        Test.startTest();
        ctrl.calculateTotal();
        Test.stopTest();

        System.assertEquals(10, ctrl.totalVal);
    }

    @isTest
    static void testCalculateTotalNegative() {
        BuyController ctrl = testHelper();
        Test.startTest();
        ctrl.calculateTotal();
        Test.stopTest();

        System.assertEquals(0, ctrl.totalVal);
    }

    @isTest
    static void testBack() {
        BuyController ctrl = testHelper();
        Test.startTest();
        PageReference page = ctrl.back();
        Test.stopTest();

        System.assert(page.getUrl().containsIgnoreCase('ProductsInWarehouse'));
    }

    @isTest
    static void testOrderUnavailable() {
        BuyController ctrl = testHelper();
        ctrl.unitCount = 200;
        Test.startTest();
        ctrl.order();
        Test.stopTest();
        ApexPages.Message[] mess=ApexPages.getMessages();
        Boolean has=false;
        for (ApexPages.Message currMess:mess){
            if (currMess.getDetail().containsIgnoreCase('Requested quantity is not available now')){
                has=true;
            }
        }

        System.assert(has);
    }

    @isTest
    static void testOrderContactExist() {
        BuyController ctrl = testHelper();
        ctrl.unitCount = 10;
        Test.startTest();
        ctrl.email='test@test.com';
        ctrl.lastName='test';
        ctrl.firstName='test';
        ctrl.order();
        Test.stopTest();
        ApexPages.Message[] mess=ApexPages.getMessages();
        Boolean has=false;
        for (ApexPages.Message currMess:mess){
            if (currMess.getDetail().containsIgnoreCase('The order has been successfully made')){
                has=true;
            }
        }
        List<Contact>conts=[SELECT LastName,FirstName,Email FROM Contact];
        List<Order_Table__c>order=[SELECT Units__c,Order_Amount__c FROM Order_Table__c];
        Product_Table__c updProd=[SELECT Units_Available__c FROM Product_Table__c LIMIT 1];

        System.assert(has);
        System.assertEquals(1,conts.size());
        System.assertEquals('test',conts[0].FirstName);
        System.assertEquals('test',conts[0].LastName);
        System.assertEquals(1,order.size());
        System.assertEquals(10,order[0].Units__c);
        System.assertEquals(10,order[0].Order_Amount__c);
        System.assertEquals(90,updProd.Units_Available__c);
    }

    @isTest
    static void testOrderNewContact() {
        BuyController ctrl = testHelper();
        ctrl.unitCount = 10;
        Test.startTest();
        ctrl.email='new@test.com';
        ctrl.lastName='test';
        ctrl.firstName='test';
        ctrl.order();
        Test.stopTest();
        ApexPages.Message[] mess=ApexPages.getMessages();
        Boolean has=false;
        for (ApexPages.Message currMess:mess){
            if (currMess.getDetail().containsIgnoreCase('The order has been successfully made')){
                has=true;
            }
        }
        List<Contact>conts=[SELECT LastName,FirstName,Email FROM Contact WHERE Email='new@test.com'];
        List<Order_Table__c>order=[SELECT Units__c,Order_Amount__c FROM Order_Table__c];
        Product_Table__c updProd=[SELECT Units_Available__c FROM Product_Table__c LIMIT 1];

        System.assert(has);
        System.assertEquals(1,conts.size());
        System.assertEquals('test',conts[0].FirstName);
        System.assertEquals('test',conts[0].LastName);
        System.assertEquals(1,order.size());
        System.assertEquals(10,order[0].Units__c);
        System.assertEquals(10,order[0].Order_Amount__c);
        System.assertEquals(90,updProd.Units_Available__c);
    }

    @isTest
    static void testOrderSameEmail() {
        BuyController ctrl = testHelper();
        ctrl.unitCount = 10;
        insert new Contact(LastName='test',Email='test@test.com');
        Test.startTest();
        ctrl.email='test@test.com';
        ctrl.lastName='test';
        ctrl.firstName='test';
        ctrl.order();
        Test.stopTest();
        ApexPages.Message[] mess=ApexPages.getMessages();
        Boolean has=false;
        for (ApexPages.Message currMess:mess){
            if (currMess.getDetail().containsIgnoreCase('The order has been successfully made')){
                has=true;
            }
        }
        List<Contact>conts=[SELECT LastName,FirstName,Email FROM Contact WHERE Email='test@test.com'];
        List<Order_Table__c>order=[SELECT Units__c,Order_Amount__c FROM Order_Table__c];
        Product_Table__c updProd=[SELECT Units_Available__c FROM Product_Table__c LIMIT 1];

        System.assert(has);
        System.assertEquals(2,conts.size());
        System.assertNotEquals(conts[1].LastName,conts[0].LastName);
        System.assertEquals(1,order.size());
        System.assertEquals(10,order[0].Units__c);
        System.assertEquals(10,order[0].Order_Amount__c);
        System.assertEquals(90,updProd.Units_Available__c);
    }


}