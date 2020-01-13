/**
 * Created by sakrutnaya on 12/27/2019.
 */

public with sharing class ConvertAdvertTagWrapper {

    public String AdvertName;
    public String Description;
    public List<Tags> Tags;

    public class Tags {
        public String TagName;
    }


    public static List<ConvertAdvertTagWrapper> parse(String json) {
        return (List<ConvertAdvertTagWrapper>) System.JSON.deserialize(json, List<ConvertAdvertTagWrapper>.class);
    }

}