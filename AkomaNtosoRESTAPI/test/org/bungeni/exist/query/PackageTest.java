package org.bungeni.exist.query;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.HeadMethod;
import org.apache.commons.httpclient.methods.InputStreamRequestEntity;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.jxpath.JXPathContext;
import org.junit.AfterClass;
import org.junit.Test;
import org.w3c.dom.Document;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertNotNull;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni Package XQuery REST API
 * http://localhost:8088/db/bungeni/query/package.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class PackageTest
{
    private final static DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
    private static List<String> storedEntryPaths = new ArrayList<String>();

   
    @AfterClass
    public static void removeStoredEntries() throws IOException
    {
        for(String storedEntryPath : storedEntryPaths)
        {
            DeleteMethod delete = new DeleteMethod(REST.EXIST_REST_URI + storedEntryPath);
            HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
            int result = client.executeMethod(delete);
        }
    }


    @Test
    public void store_package_ke_act_1980_01_01_1() throws IOException, ParserConfigurationException, SAXException
    {
        final String packageFilename = "ke_act_1980-01-01_1.akn";

        final List<String> expectedExtractedEntryPaths = new ArrayList<String>();
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1980/01-01_1_eng_main.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1980/01-01_1_eng@1989-12-15_main.xml");

        doStorePackage(packageFilename, expectedExtractedEntryPaths);
    }

    @Test
    public void store_package_ke_act_1993_12_16_9() throws IOException, ParserConfigurationException, SAXException
    {
        final String packageFilename = "ke_act_1993-12-16_9.akn";

        final List<String> expectedExtractedEntryPaths = new ArrayList<String>();
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1993/12-16_9_eng_main.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1993/12-16_9_eng_annex1.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1993/12-16_9_eng_annex2.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1993/12-16_9_eng_annex3.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/act/1993/12-16_9_eng_image.jpg");
        
        doStorePackage(packageFilename, expectedExtractedEntryPaths);
    }

    @Test
    public void store_package_ke_debate_1995_10_31() throws IOException, ParserConfigurationException, SAXException
    {
        final String packageFilename = "ke_debate_1995-10-31.akn";

        final List<String> expectedExtractedEntryPaths = new ArrayList<String>();
        expectedExtractedEntryPaths.add("/db/bungeni/data/ke/debate/1995/10-31_eng_main.xml");

        doStorePackage(packageFilename, expectedExtractedEntryPaths);
    }

    @Test
    public void store_package_za_report_2007_03_22() throws IOException, ParserConfigurationException, SAXException
    {
        final String packageFilename = "za_report_2007-03-22.akn";

        final List<String> expectedExtractedEntryPaths = new ArrayList<String>();
        expectedExtractedEntryPaths.add("/db/bungeni/data/za/report/2007/03-22_eng_main.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/za/report/2007/03-22_eng_appendix1.xml");
        expectedExtractedEntryPaths.add("/db/bungeni/data/za/report/2007/03-22_eng_appendix2.xml");

        doStorePackage(packageFilename, expectedExtractedEntryPaths);
    }

    public void doStorePackage(String packageFilename, final List<String> expectedExtractedEntryPaths) throws HttpException, IOException, ParserConfigurationException, SAXException
    {
        InputStream pkg = this.getClass().getClassLoader().getResourceAsStream(packageFilename);

        assertNotNull(pkg);

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "store")
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new InputStreamRequestEntity(pkg, Database.ZIP_MIMETYPE));

        int status = http.executeMethod(post);

        if(status != HttpStatus.SC_OK)
            System.out.println(post.getResponseBodyAsString());

        assertEquals(HttpStatus.SC_OK, status);

        List<String> extractedEntryPaths = getExtractedEntryPaths(post.getResponseBodyAsStream());

        storedEntryPaths.addAll(extractedEntryPaths);

        assertEquals(expectedExtractedEntryPaths.size(), extractedEntryPaths.size());
        assertTrue(extractedEntryPaths.containsAll(expectedExtractedEntryPaths));

        for(String extractedEntryPath : extractedEntryPaths)
        {
            HeadMethod head = new HeadMethod(REST.EXIST_REST_URI + extractedEntryPath);
            assertEquals(HttpStatus.SC_OK, http.executeMethod(head));
        }
    }

    public static List<String> getStoredEntryPaths()
    {
        return storedEntryPaths;
    }

    private List<String> getExtractedEntryPaths(InputStream responseBody) throws ParserConfigurationException, SAXException, IOException
    {
        DocumentBuilder builder = documentBuilderFactory.newDocumentBuilder();
        Document docResult = builder.parse(responseBody);

        JXPathContext jxp = JXPathContext.newContext(docResult);
        Iterator<String> itEntry = (Iterator<String>)jxp.iterate("/extracted/entry");

        List<String> entryPaths = new ArrayList<String>();
        while(itEntry.hasNext())
        {
            entryPaths.add(itEntry.next());
        }

        return entryPaths;
    }

}
