package org.bungeni.exist.query;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.jxpath.JXPathContext;
import org.apache.commons.jxpath.ri.QName;
import org.apache.commons.jxpath.ri.model.NodeIterator;
import org.apache.commons.jxpath.ri.model.dom.DOMNodePointer;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.w3c.dom.Document;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
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
    public final static String QUERY_NAMESPACE_URI = "http://exist.bungeni.org/query/query";
    public final static String QUERY_NAMESPACE_PREFIX = "query";

    private static List<String> storedEntryPaths = null;

    private final static DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();

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
    public void listWorkComponents() throws IOException, SAXException, ParserConfigurationException
    {
        final String queryAction = "list-components";
        final String queryUri = "/ke/act/1993-12-31/9";


        GetMethod get = new GetMethod(REST.QUERY_URL);
        NameValuePair qsParams[] = {
            new NameValuePair("action", queryAction),
            new NameValuePair("uri", queryUri)
        };
        get.setQueryString(qsParams);

        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        int result = client.executeMethod(get);

        assertEquals(HttpStatus.SC_OK, result);

        DocumentBuilder builder = documentBuilderFactory.newDocumentBuilder();
        Document docResult = builder.parse(get.getResponseBodyAsStream());

        JXPathContext jxp = JXPathContext.newContext(docResult);
        jxp.setLenient(true);
        jxp.registerNamespace(QUERY_NAMESPACE_PREFIX, QUERY_NAMESPACE_URI);
        jxp.registerNamespace(AkomaNtoso.AN_NAMESPACE_PREFIX, AkomaNtoso.AN_NAMESPACE_URI);

        //assertions
        String responseRequestAction = (String)jxp.getValue("/query:query/query:request/query:action");
        assertEquals(queryAction, responseRequestAction);

        String responseRequestUri = (String)jxp.getValue("/query:query/query:request/query:params/an:uri");
        assertEquals(queryUri, responseRequestUri);

        Iterator<DOMNodePointer> itPtrMatch = (Iterator<DOMNodePointer>)jxp.iteratePointers("/query:query/query:results/query:match");
        
        DOMNodePointer ptrMatch = itPtrMatch.next();
        assertEquals("/ke/act/1993-12-31/9/eng@/main.xml", getAttributeValue("an-manifestation-uri", ptrMatch));
        assertEquals("/db/bungeni/data/ke/act/1993/12-16_9_eng_main.xml", getAttributeValue("db-uri", ptrMatch));

        ptrMatch = itPtrMatch.next();
        assertEquals("/ke/act/1993-12-31/9/eng@/main/schedule03.xml", getAttributeValue("an-manifestation-uri", ptrMatch));
        assertEquals("/db/bungeni/data/ke/act/1993/12-16_9_eng_annex3.xml", getAttributeValue("db-uri", ptrMatch));

        ptrMatch = itPtrMatch.next();
        assertEquals("/ke/act/1993-12-31/9/eng@/main/schedule02.xml", getAttributeValue("an-manifestation-uri", ptrMatch));
        assertEquals("/db/bungeni/data/ke/act/1993/12-16_9_eng_annex2.xml", getAttributeValue("db-uri", ptrMatch));

        ptrMatch = itPtrMatch.next();
        assertEquals("/ke/act/1993-12-31/9/eng@/main/schedule01.xml", getAttributeValue("an-manifestation-uri", ptrMatch));
        assertEquals("/db/bungeni/data/ke/act/1993/12-16_9_eng_annex1.xml", getAttributeValue("db-uri", ptrMatch));

        try
        {
            itPtrMatch.next();
        }
        catch(Exception e)
        {
            assertEquals(NoSuchElementException.class, e.getClass());
        }

    }

    private final String getAttributeValue(String attrName, DOMNodePointer ptrNode)
    {
        return (String)ptrNode.attributeIterator(new QName(attrName)).getNodePointer().getValue();
    }
}
