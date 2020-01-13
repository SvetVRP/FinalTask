/**
 * Created by sakrutnaya on 12/31/2019.
 */

public inherited sharing class ProcessDml {

    public static List<String> processInsert(List<SObject> objects) {
        List <String> saveResults = new List<String>();
        if (objects == null || objects.isEmpty()) {
            return saveResults;
        }
        Database.SaveResult[] srList = Database.insert(objects, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                saveResults.add('Insert was performed successfully. ID: ' + sr.getId());
            } else {
                String message = 'The following errors have occurred: ';
                for (Database.Error err : sr.getErrors()) {
                    message += err.getStatusCode() + ': ' + err.getMessage() + err.getFields() + '.';
                }
                saveResults.add(message);
            }
        }
        return saveResults;
    }

    public static List<String> processDelete(List<SObject> objects) {
        List <String> deleteResults = new List<String>();
        if (objects == null || objects.isEmpty()) {
            return deleteResults;
        }
        Database.DeleteResult[] delList = Database.delete(objects, false);
        for (Database.DeleteResult dlr : delList) {
            if (dlr.isSuccess()) {
                deleteResults.add('Deletion was performed successfully. ID: ' + dlr.getId());
            } else {
                String message = 'The following errors have occurred: ';
                for (Database.Error err : dlr.getErrors()) {
                    message += err.getStatusCode() + ': ' + err.getMessage() + err.getFields() + '.';
                }
                deleteResults.add(message);
            }
        }
        return deleteResults;
    }

}