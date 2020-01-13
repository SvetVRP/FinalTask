/**
 * Created by sakrutnaya on 1/3/2020.
 */
({
    gotoRelatedList: function (component) {
        var navService = component.find("navService");
        var pageReference = {
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: component.get("v.recordId"),
                objectApiName: "Advert__c",
                actionName: "view",
                relationshipApiName: "AdvertTags__r"
            }
        };
        component.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function (url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function (error) {
                component.set("v.url", defaultUrl);
            }));
    },
})