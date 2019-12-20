public class ProductTableTriggerHelper {

    public void linkProductsToWarehouse(List<Product_Table__c>prods) {
        List<Warehouse__c> warehouses = this.getWarehouses(prods);
        List<Warehouse__c>warehousesToCreate = new List<Warehouse__c>();
        List<Product_Table__c>prodWithoutWarehouse = new List<Product_Table__c>();
        try {
            for (Product_Table__c prod : prods) {
                Boolean found = this.populateWithId(prod, warehouses);
                if (found && prod.Warehouse__c == null) {
                    prodWithoutWarehouse.add(prod);
                }
                if (!found) {
                    Integer orgPeriod = (Integer) OrgConfiguration__c.getOrgDefaults().Period_Term__c;
                    if (orgPeriod == null) {
                        orgPeriod = 0;
                    }
                    Warehouse__c newWarehouse = new Warehouse__c(
                            Name = 'Warehouse' + prod.Added_Date__c + ' ' + (prod.Added_Date__c + orgPeriod),
                            Period_Start__c = prod.Added_Date__c,
                            Period_End__c = prod.Added_Date__c + orgPeriod);
                    warehousesToCreate.add(newWarehouse);
                    warehouses.add(newWarehouse);
                    prodWithoutWarehouse.add(prod);
                }
            }
            if (warehousesToCreate.size() > 0) {
                insert warehousesToCreate;
            }
            for (Product_Table__c prod : prodWithoutWarehouse) {
                this.populateWithId(prod, warehouses);
            }
        } catch (Exception e) {
            System.debug('Unable to create warehouses');
        }
    }

    private List<Warehouse__c> getWarehouses(List<Product_Table__c>prods) {
        String soql = 'SELECT Id, Period_Start__c, Period_End__c FROM Warehouse__c WHERE ';
        List<Date>datesInSoql = new List<Date>();
        Date todayDate = System.today();
        for (Product_Table__c prod : prods) {
            if (prod.Added_Date__c == null) {
                prod.Added_Date__c = todayDate;
                if (!datesInSoql.contains(todayDate)) {
                    datesInSoql.add(todayDate);
                    soql += '(Period_Start__c <= :todayDate AND Period_End__c >= :todayDate) ';
                }
            } else {
                Date prodDate = prod.Added_Date__c;
                if (!datesInSoql.contains(prodDate)) {
                    datesInSoql.add(prodDate);
                    if (soql.contains(')')) {
                        soql += ' OR ';
                    }
                    soql += ' (Period_Start__c <= ' + String.valueOf(prodDate) + ' AND Period_End__c >= ' + String.valueOf(prodDate) + ') ';
                }
            }
        }
        if (soql.endsWithIgnoreCase('WHERE ')) {
            soql.removeEndIgnoreCase('WHERE ');
        }
        return Database.query(soql);
    }

    private Boolean populateWithId(Product_Table__c prod, List<Warehouse__c> warehouses) {
        Boolean found = false;
        Integer count = 0;
        while (!found && count < warehouses.size()) {
            if (warehouses[count].Period_Start__c <= prod.Added_Date__c && warehouses[count].Period_End__c >= prod.Added_Date__c) {
                prod.Warehouse__c = warehouses[count].Id;
                found = true;
            }
            count += 1;
        }
        return found;
    }

}