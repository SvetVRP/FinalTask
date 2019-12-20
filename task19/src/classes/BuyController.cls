/**
 * Created by sakrutnaya on 12/18/2019.
 */

public with sharing class BuyController {
    private ApexPages.StandardController ctrl { get; set; }
    private Product_Table__c prod;
    public Integer unitCount { get; set; }
    public Decimal totalVal { get; set; }
    private String ref;
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }

    public BuyController(ApexPages.StandardController stdController) {
        if (this.ctrl == null) {
            this.ctrl = stdController;
        }
        this.prod = (Product_Table__c) stdController.getRecord();
        Map<String, String>headers = ApexPages.currentPage().getHeaders();
        if (headers.keySet().contains('Referer') && headers.get('Referer').contains('visualforce.com')) {
            this.ref = headers.get('Referer').substringAfterLast('apex/').substringBefore('/').substringBefore('?');
        } else {
            this.ref = 'ProductsInWarehouse';
        }
    }

    public void calculateTotal() {
        if (this.unitCount == null) {
            this.unitCount = 0;
        }
        this.unitCount = Math.abs(this.unitCount);
        this.totalVal = this.prod.Unit_Price__c * this.unitCount;
    }

    public PageReference back() {
        String page = '/apex/' + this.ref;
        if (this.prod.Id != null) {
            page += '?id=' + this.prod.Id;
        }
        return new PageReference(page).setRedirect(true);
    }

    public void order() {
        prod = [SELECT Units_Available__c,Name,Unit_Price__c FROM Product_Table__c WHERE Id = :prod.Id];
        if (prod.Units_Available__c < Math.abs(this.unitCount)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Requested quantity is not available now'));
            return;
        }
        Contact cont = findContact();
        if (cont == null) {
            cont = new Contact(Email = this.email);
        }
        try {
            cont = updCont(cont);
            createOrder(cont, this.prod);
            updProd();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Something goes wrong. Please, try again.'));
            return;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The order has been successfully made'));
        this.unitCount = 0;
    }

    private Contact findContact() {
        List<Contact>conts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = :this.email];
        if (conts.isEmpty()) {
            return null;
        }
        if (conts.size() > 1) {
            for (Contact iCont : conts) {
                if (iCont.LastName.equalsIgnoreCase(this.lastName)) {
                    return iCont;
                }
            }
        }
        return conts[0];
    }

    private Contact updCont(Contact cont) {
        if (!String.isBlank(this.FirstName)) {
            cont.FirstName = this.firstName;
        }
        cont.LastName = this.lastName;
        upsert cont;
        return cont;
    }

    private Order_Table__c createOrder(Contact cont, Product_Table__c prod) {
        Order_Table__c ord = new Order_Table__c(
                Product__c = prod.Id,
                Units__c = Math.abs(this.unitCount),
                Order_Amount__c = Math.abs(this.unitCount) * prod.Unit_Price__c,
                Contact__c = cont.Id
        );
        insert ord;
        return ord;
    }

    private void updProd() {
        this.prod.Units_Available__c -= Math.abs(this.unitCount);
        update prod;
    }

}