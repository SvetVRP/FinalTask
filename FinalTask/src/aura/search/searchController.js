/**
 * Created by sakrutnaya on 1/6/2020.
 */
({
    showOptions: function (component, event, helper) {
        helper.seeOptions(component);
        helper.filterOptions(component);
    },
    optionSelected: function (component, event, helper) {
        helper.performSelection(component, event);
    },
    getFilteredOptions: function (component, event, helper) {
        helper.filterOptions(component);
    },
    handleBlur: function (component, event, helper) {
        helper.hideOptions(component);
    }
})