/**
 * Created by sakrutnaya on 12/31/2019.
 */
({
    initialize: function (component, event, helper) {
        helper.getAdvertIds(component,"");
        helper.getTags(component);
    },
    doFind: function (component, event, helper) {
        helper.handleFind(component, event);
    },
})