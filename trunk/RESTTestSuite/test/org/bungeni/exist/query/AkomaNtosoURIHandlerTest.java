package org.bungeni.exist.query;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
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
import static org.junit.Assert.assertTrue;
import org.xml.sax.SAXException;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 */
public class AkomaNtosoURIHandlerTest
{
    private static List<String> storedEntryPaths = null;

    @BeforeClass
    public static void setupTestPackage() throws IOException, ParserConfigurationException, SAXException
    {
        PackageTest packageTest = new PackageTest();
        packageTest.store_package_ke_act_1993_12_16_9();
        storedEntryPaths = packageTest.getStoredEntryPaths();
    }

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

    @Test
    public void retrievePackage() throws IOException
    {
        GetMethod get = new GetMethod(REST.AN_URIHANDLER_URL);

        get.setQueryString(new NameValuePair[]{
            new NameValuePair("uriType", "manifestation"),
            new NameValuePair("country", "ke"),
            new NameValuePair("type", "act"),
            new NameValuePair("date","1993-12-16"),
            new NameValuePair("number", "9"),
            new NameValuePair("lang", "eng"),
            new NameValuePair("dataformat", "akn")
        });

        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        int result = client.executeMethod(get);

        assertEquals(HttpStatus.SC_OK, result);

        assertEquals("application/zip", get.getResponseHeader("Content-Type").getValue());
        assertEquals("inline; filename=ke_act_1993-12-16_9_eng.akn", get.getResponseHeader("Content-Disposition").getValue());

        ZipInputStream zis = new ZipInputStream(get.getResponseBodyAsStream());
        ZipEntry entry = null;
        List<String> entryPaths = new ArrayList<String>();
        while((entry = zis.getNextEntry()) != null)
        {
            entryPaths.add(entry.getName());
        }

        final List<String> expectedEntryPaths = new ArrayList<String>();
        expectedEntryPaths.add("ke_act_1993-12-16_9_eng_annex1.xml");
        expectedEntryPaths.add("ke_act_1993-12-16_9_eng_annex2.xml");
        expectedEntryPaths.add("ke_act_1993-12-16_9_eng_annex3.xml");
        expectedEntryPaths.add("ke_act_1993-12-16_9_eng_image.jpg");
        expectedEntryPaths.add("ke_act_1993-12-16_9_eng_main.xml");

        assertEquals(expectedEntryPaths.size(), entryPaths.size());
        assertTrue(entryPaths.containsAll(expectedEntryPaths));
    }
}