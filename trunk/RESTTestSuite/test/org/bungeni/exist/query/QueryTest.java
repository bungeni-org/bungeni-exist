package org.bungeni.exist.query;

import java.io.IOException;
import java.util.List;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni Query XQuery REST API
 * http://localhost:8088/db/bungeni/query/query.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class QueryTest
{
    private static List<String> storedEntryPaths = null;

    @BeforeClass
    public static void setupTestPackage() throws IOException, ParserConfigurationException, SAXException
    {
        PackageTest packageTest = new PackageTest();
        packageTest.store_package_ke_act_1993_12_16_9();
        storedEntryPaths = packageTest.getStoredEntryPaths();
    }

    /*
    @AfterClass
    public static void removeTestPackage() throws IOException
    {
        for(String storedEntryPath : storedEntryPaths)
        {
            DeleteMethod delete = new DeleteMethod(REST.EXIST_REST_URI + storedEntryPath);
            HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
            int result = client.executeMethod(delete);
        }
    }
     */

    @Test
    public void listWorkComponents() throws IOException
    {
        GetMethod get = new GetMethod(REST.QUERY_URL);
        NameValuePair qsParams[] = {
            new NameValuePair("action", "list-components"),
            new NameValuePair("uri", "/ke/act/1993-12-31/9")
        };
        get.setQueryString(qsParams);

        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        int result = client.executeMethod(get);

        assertEquals(HttpStatus.SC_OK, result);

        System.out.println(get.getResponseBodyAsString());

        /*
        <query xmlns="http://exist.bungeni.org/query/query">
            <request>
                <action>list-components</action>
                <params>
                    <uri>/ke/act/1993-12-31/9</uri>
                </params>
            </request>
            <start time=""/>
            <results count="">
                
            </results>
            <end time=""/>
        </query>
         */
    }
}
