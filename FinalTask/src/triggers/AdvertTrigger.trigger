/**
 * Created by sakrutnaya on 12/26/2019.
 */

trigger AdvertTrigger on Advert__c (after undelete, before insert, before update) {

    if (Trigger.isAfter) {
        if (Trigger.isUndelete) {
            new AdvertTriggerHelper().preventDuplicates(Trigger.new);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            new AdvertTriggerHelper().findDuplicatesInList(Trigger.new);
        }
    }
}