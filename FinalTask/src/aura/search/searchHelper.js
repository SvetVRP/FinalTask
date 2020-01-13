/**
 * Created by sakrutnaya on 1/6/2020.
 */
({
    seeOptions: function (component) {
        component.set("v.performSearch", !component.get("v.performSearch"));
    },
    performSelection: function (component, event) {
        this.hideOptions(component);
        component.find("enter-search").set("v.value", event.getParam("searchValue"));
    },
    hideOptions: function (component) {
        if (component.get("v.performSearch") === true) {
            this.seeOptions(component);
        }
    },
    filterOptions: function (component) {
        const options = component.get("v.options");
        const newOptions = options.filter(
            option => option.trim().toLowerCase().includes(
            component.find("enter-search").get("v.value").trim().toLowerCase()));
        newOptions.unshift($A.get("$Label.c.All"));
        component.set("v.filteredOptions", newOptions);
    },
})