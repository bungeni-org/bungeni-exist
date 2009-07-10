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
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.InputStreamRequestEntity;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.jxpath.JXPathContext;
import org.apache.commons.jxpath.Pointer;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.w3c.dom.Document;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni XQuery REST API
 * http://localhost:8088/db/bungeni/query/package.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class PackageTest
{
    private final static DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();

    /*
    private final static String TEST_COLLECTION = "/db/bungeni/data/ke/act/9999";


    @BeforeClass
    public static void setupTestCollection() throws IOException
    {
        //create the test collection (if required)
        REST.createCollectionFromPath(TEST_COLLECTION);
    }

    @AfterClass
    public static void removeTestCollection() throws IOException
    {
        DeleteMethod delete = new DeleteMethod(REST.EXIST_REST_URI + TEST_COLLECTION);

        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int result = client.executeMethod(delete);
        assertEquals(HttpStatus.SC_OK, result);
    }
    */

    @Test
    public void store_package_ke_act_1980_01_01_1() throws IOException, ParserConfigurationException, SAXException
    {
        InputStream pkg = this.getClass().getClassLoader().getResourceAsStream("ke_act_1980-01-01_1.akn");

        assertNotNull(pkg);

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "store")
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new InputStreamRequestEntity(pkg, Database.ZIP_MIMETYPE));

        int status = http.executeMethod(post);

        System.out.println("RESPONSE=" + post.getResponseBodyAsString());
        
        assertEquals(HttpStatus.SC_OK, status);

        

        //List<String> extractedEntryPaths = getExtractedEntryPaths(post.getResponseBodyAsStream());

        //for(String path : extractedEntryPaths)
        //{
         //   System.out.println(path);
        //}
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
