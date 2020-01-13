/**
 * Created by sakrutnaya on 1/3/2020.
 */
({
    handleOnLoad: function (component, event, helper) {
        helper.showButton(component, event);
    },
    handleSubmit: function (component, event, helper) {
        helper.elevate(component, event);
    },
    handleOnSuccess : function(component, event, helper) {
        helper.handleSuccessfulUpdate(component, event);
    },
    handleOnError: function(component, event, helper) {
        helper.handleFail(component, event);
    },
    handleClick: function(component, event, helper) {
        helper.hideOptions();
    },
})