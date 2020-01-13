/**
 * Created by sakrutnaya on 12/24/2019.
 */

public without sharing class ProcessDuplicates {

    public void preventDuplicates(List<SObject> sobjects) {
        if (sobjects.isEmpty()) {
            return;
        }
        try {
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(sobjects);
            for (Integer num = 0; num < results.size(); num++) {
                for (Datacloud.DuplicateResult dupeResult : results[num].getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        if (matchResult.getSize() > 0) {
                            sobjects[num].addError('Duplicated values are not allowed');
                        }
                    }
                }
            }
        } catch (System.HandledException e) {
            return;
        }
    }

    public void findDuplicatesInList(List<SObject> sobjects, String fieldNameWithDuplicates) {
        List<String>values = new List<String>();
        if (sobjects != null && !sobjects.isEmpty()) {
            for (SObject obj : sobjects) {
                if (obj.getPopulatedFieldsAsMap().containsKey(fieldNameWithDuplicates)) {
                    String currValue = String.valueOf(obj.getPopulatedFieldsAsMap().get(fieldNameWithDuplicates)).trim().toUpperCase();
                    if (values.contains(currValue)) {
                        obj.addError('The list contains duplicates.');
                    } else {
                        values.add(currValue);
                    }
                }
            }
        }
    }
}