/**
 * Created by sakrutnaya on 12/27/2019.
 */
@isTest
public with sharing class ConvertAdvertTagWrapperTest {

    @isTest
    private static void testParse() {
        String json = '['+
                '{\"AdvertName\":\"ValueName\",'+
                '\"Description\":\"ValueName\",'+
                '\"Tags\":['+
                '{\"TagName\":\"ValueName1\"},'+
                '{\"TagName\":\"ValueName2\"}'+
                ']'+
                '}'+
                ']';
        List<ConvertAdvertTagWrapper> obj = ConvertAdvertTagWrapper.parse(json);
        System.assert(obj != null);
    }

}