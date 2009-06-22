package org.bungeni.exist.query;

import java.io.IOException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.ByteArrayRequestEntity;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.jxpath.JXPathContext;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.w3c.dom.Document;
import static org.junit.Assert.fail;
import static org.junit.Assert.assertEquals;
import org.xml.sax.SAXException;


/**
 * Test harness for Bungeni XQuery REST API Error Codes
 * http://localhost:8088/db/bungeni/query/edit.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class EditErrorTest
{
    private final static DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();

    private final static String TEST_ACT_MANIFESTATION_URI = "/ken/act/2009-06-21/1/eng.xml";
    private final static String TEST_ACT_EXPRESSION_URI = TEST_ACT_MANIFESTATION_URI.substring(0, TEST_ACT_MANIFESTATION_URI.indexOf('.'));
    private final static String TEST_ACT_WORK_URI = TEST_ACT_EXPRESSION_URI.substring(0, TEST_ACT_EXPRESSION_URI.lastIndexOf('/'));

    private final static String TEST_ACT_MANIFESTATION_DB_URI = "/db/bungeni/data/ken/act/2009/06-21_1_eng.xml";

    @BeforeClass
    public static void storeTestDocuments() throws IOException
    {
        String testAct = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, TEST_ACT_WORK_URI, TEST_ACT_EXPRESSION_URI, TEST_ACT_MANIFESTATION_URI, null);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", TEST_ACT_MANIFESTATION_URI)
        };

        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(testAct.getBytes(), Database.XML_MIMETYPE));

        //store the document
        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int result = client.executeMethod(post);
        assertEquals(HttpStatus.SC_OK, result);
    }

    @AfterClass
    public static void removeTestDocuments() throws IOException
    {
        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        DeleteMethod delete = new DeleteMethod(REST.EXIST_REST_URI + TEST_ACT_MANIFESTATION_DB_URI);

        int result = client.executeMethod(delete);
        assertEquals(HttpStatus.SC_OK, result);
    }

    @Test
    public void calledWithNoParams() throws IOException, SAXException, ParserConfigurationException
    {
        final String expectedErrorCode = "MIDUED0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        GetMethod get = new GetMethod(REST.EDIT_URL);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void new_manifestationUriMismatchesDocumentExpressionUri() throws IOException, ParserConfigurationException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "EXUMAU0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);

        final String testAct = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, TEST_ACT_WORK_URI, TEST_ACT_EXPRESSION_URI, TEST_ACT_MANIFESTATION_URI, null);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", "/some/wrong/manifestation/uri.xml")
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(testAct.getBytes(), Database.XML_MIMETYPE));


        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void new_documentAlreadyExists() throws IOException, ParserConfigurationException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "EXDODB0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String testAct = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, TEST_ACT_WORK_URI, TEST_ACT_EXPRESSION_URI, TEST_ACT_MANIFESTATION_URI, null);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", TEST_ACT_MANIFESTATION_URI)
        };

        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(testAct.getBytes(), Database.XML_MIMETYPE));


        //try and store the test doument again

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void edit_versionedXMLDocumentButNoVersionSupplied() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIVEED0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);
        
        GetMethod get = new GetMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", TEST_ACT_MANIFESTATION_URI)
        };
        get.setQueryString(qsGetParams);
        
        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButNoDocumentSupplied() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIDOED0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "2009-06-22")
        };
        post.setQueryString(qsGetParams);

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButNoVersionSupplied() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIVEED0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", TEST_ACT_MANIFESTATION_URI)
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = "<an:akomantoso xmlns:an=\"" + AkomaNtoso.NAMESPACE_URI + "\"><an:act contains=\"SingleVersion\"/></an:akomantoso>";

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    private final static String getErrorMessageForErrorCode(String errorCode) throws IOException, ParserConfigurationException, SAXException
    {
        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        HttpMethod getErrorMessages = new GetMethod(REST.DEFAULT_ERROR_MESSAGES_URI);

        try
        {
            int result = client.executeMethod(getErrorMessages);
            if(result != HttpStatus.SC_OK)
                fail("Received Http Status: " + result);

            DocumentBuilder builder = documentBuilderFactory.newDocumentBuilder();

            Document docErrorMessages = builder.parse(getErrorMessages.getResponseBodyAsStream());

            JXPathContext jxp = JXPathContext.newContext(docErrorMessages);
            jxp.registerNamespace(REST.ERRORS_NAMESPACE_PREFIX, REST.ERRORS_NAMESPACE_URI);

            String errorMessage = (String)jxp.getValue("/" + REST.ERRORS_NAMESPACE_PREFIX + ":errors/" + REST.ERRORS_NAMESPACE_PREFIX + ":error[@code = '" + errorCode + "']", String.class);

            if(errorMessage == null)
                fail("Could not find error message for error code: " + errorCode + " whilst initialising test");

            return errorMessage;
        }
        finally
        {
            getErrorMessages.releaseConnection();
        }

    }

    public final static void testErrorResponse(HttpMethod method, String expectedErrorCode, String expectedErrorMessage) throws IOException, ParserConfigurationException, SAXException
    {
        try
        {
            HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

            int result = client.executeMethod(method);

            if(result != HttpStatus.SC_OK)
                fail("Received Http Status: " + result + "\r\n" + method.getResponseBodyAsString());

            DocumentBuilder builder = documentBuilderFactory.newDocumentBuilder();
            Document docResult = builder.parse(method.getResponseBodyAsStream());

            JXPathContext jxp = JXPathContext.newContext(docResult);
            jxp.registerNamespace(REST.ERROR_NAMESPACE_PREFIX, REST.ERROR_NAMESPACE_URI);

            String actualErrorCode = (String)jxp.getValue("/" + REST.ERROR_NAMESPACE_PREFIX + ":error/" + REST.ERROR_NAMESPACE_PREFIX + ":code", String.class);
            assertEquals(expectedErrorCode, actualErrorCode);

            String actualErrorMessage = (String)jxp.getValue("/" + REST.ERROR_NAMESPACE_PREFIX + ":error/" + REST.ERROR_NAMESPACE_PREFIX + ":message", String.class);
            assertEquals(expectedErrorMessage, actualErrorMessage);

            final String expectedErrorMethod = method instanceof GetMethod ? "GET" : "POST";
            String actualErrorMethod = (String)jxp.getValue("/" + REST.ERROR_NAMESPACE_PREFIX + ":error/" + REST.ERROR_NAMESPACE_PREFIX + ":http-context/"+ REST.ERROR_NAMESPACE_PREFIX + ":method", String.class);
            assertEquals(expectedErrorMethod, actualErrorMethod);

            final String expectedErrorURI = method.getURI().getPath();
            String actualErrorUri = (String)jxp.getValue("/" + REST.ERROR_NAMESPACE_PREFIX + ":error/" + REST.ERROR_NAMESPACE_PREFIX + ":http-context/"+ REST.ERROR_NAMESPACE_PREFIX + ":uri", String.class);
            assertEquals(expectedErrorURI, actualErrorUri);

            //TODO compare params
        }
        finally
        {
            method.releaseConnection();
        }
    }
}
