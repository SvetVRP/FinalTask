/**
 * Created by sakrutnaya on 1/6/2020.
 */
({
    find: function (component) {
        let val = component.get("v.item");
        if(val==$A.get("$Label.c.All")){
            val="";
        }
        component.getEvent("performSearch").setParams({"searchValue": val}).fire();
    }
})