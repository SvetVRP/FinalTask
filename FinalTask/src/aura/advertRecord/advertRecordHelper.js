/**
 * Created by sakrutnaya on 1/3/2020.
 */
({
    showButton: function (component, event) {
        var dat = event.getParam("recordUi").record.fields["PublishDate__c"].value;
        component.set("v.showElevateButton", (Date.now() - new Date(dat)) > (7 * 24 * 60 * 60 * 1000));
    },
    elevate: function (component, event) {
        event.preventDefault();
        var fields = event.getParam("fields");
        fields["PublishDate__c"] = new Date().toISOString();
        component.find("form").submit(fields);
    },
    handleSuccessfulUpdate: function (component, event) {
        $A.get("e.force:showToast").setParams({message: "SUCCESS"}).fire();
        $A.get("e.force:refreshView").fire();
    },
    handleFail: function (component, event) {
        $A.get("e.force:showToast").setParams({message: "The operation fails"}).fire();
    },
    hideOptions:function(){
        $A.get("e.c:hideOptionsEvent").fire();
    }
})