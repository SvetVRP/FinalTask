/**
 * Created by sakrutnaya on 12/31/2019.
 */
({
    getAdvertIds: function (component, searchTerm) {
        var action = component.get("c.getIds");
        action.setParams({
            searchTerm: searchTerm
        });
        var self = this;
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(actionResult.getReturnValue());
                component.set("v.advertIds", list);
            } else {
                $A.get("e.force:showToast").fire({message: "The operation has failed"});
            }
        });
        $A.enqueueAction(action);
    },
    getTags: function (component) {
        var action = component.get("c.getAllTags");
        var self = this;
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(actionResult.getReturnValue());
                component.set("v.tags", list);
            } else {
                $A.get("e.force:showToast").fire({message: "The operation has failed"});
            }
        });
        $A.enqueueAction(action);
    },
    handleFind: function (component, event) {
        let searchTerm = event.getParam("searchValue");
        event.stopPropagation();
        this.getAdvertIds(component, searchTerm);
    }
})