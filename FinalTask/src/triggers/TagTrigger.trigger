trigger TagTrigger on Tag__c (after undelete, before insert, before update ) {

    if (Trigger.isAfter) {
        if (Trigger.isUndelete) {
            new TagTriggerHelper().preventDuplicates(Trigger.new);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            new TagTriggerHelper().findDuplicatesInList(Trigger.new);
        }
    }

}