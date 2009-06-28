package org.bungeni.exist.query;

import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.ByteArrayRequestEntity;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import org.xml.sax.SAXException;


/**
 * Test harness for Bungeni Editor XQuery REST API Error Codes
 * http://localhost:8088/db/bungeni/query/edit.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class EditErrorTest extends AbstractErrorTest
{
    private final static String ORIGINAL_TEST_ACT_MANIFESTATION_URI = "/ke/act/9999-06-21/1/eng.xml";
    private final static String ORIGINAL_TEST_ACT_EXPRESSION_URI = ORIGINAL_TEST_ACT_MANIFESTATION_URI.substring(0, ORIGINAL_TEST_ACT_MANIFESTATION_URI.indexOf('.'));
    private final static String ORIGINAL_TEST_ACT_WORK_URI = ORIGINAL_TEST_ACT_EXPRESSION_URI.substring(0, ORIGINAL_TEST_ACT_EXPRESSION_URI.lastIndexOf('/'));

    private final static String ORIGINAL_TEST_ACT_MANIFESTATION_DB_URI = "/db/bungeni/data/ke/act/9999/06-21_1_eng.xml";

    private final static String NEW_TEST_ACT_MANIFESTATION_URI = "/ke/act/9999-06-21/1/eng@9999-06-25.xml";
    private final static String NEW_TEST_ACT_EXPRESSION_URI = NEW_TEST_ACT_MANIFESTATION_URI.substring(0, NEW_TEST_ACT_MANIFESTATION_URI.indexOf('.'));
    private final static String NEW_TEST_ACT_WORK_URI = NEW_TEST_ACT_EXPRESSION_URI.substring(0, NEW_TEST_ACT_EXPRESSION_URI.lastIndexOf('/'));

    private final static String NEW_TEST_ACT_MANIFESTATION_DB_URI = "/db/bungeni/data/ke/act/9999/06-21_1_eng@9999-06-25.xml";



    @BeforeClass
    public static void storeTestDocuments() throws IOException
    {
        //create the test collection (if required)
        REST.createCollectionFromPath(ORIGINAL_TEST_ACT_MANIFESTATION_DB_URI.substring(0, ORIGINAL_TEST_ACT_MANIFESTATION_DB_URI.lastIndexOf("/")));


        //generate the test original document
        String testAct = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, ORIGINAL_TEST_ACT_WORK_URI, ORIGINAL_TEST_ACT_EXPRESSION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI, null);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI)
        };

        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(testAct.getBytes(), Database.XML_MIMETYPE));

        //store the original document
        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int result = client.executeMethod(post);
        assertEquals(HttpStatus.SC_OK, result);
    }

    @AfterClass
    public static void removeTestDocuments() throws IOException
    {
        HttpClient client = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);

        DeleteMethod delete = new DeleteMethod(REST.EXIST_REST_URI + ORIGINAL_TEST_ACT_MANIFESTATION_DB_URI);

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

        final String testAct = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, ORIGINAL_TEST_ACT_WORK_URI, ORIGINAL_TEST_ACT_EXPRESSION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI, null);

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

        final String testAct = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, ORIGINAL_TEST_ACT_WORK_URI, ORIGINAL_TEST_ACT_EXPRESSION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI, null);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI)
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
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI)
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
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "9999-06-22")
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
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI)
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, NEW_TEST_ACT_WORK_URI, NEW_TEST_ACT_EXPRESSION_URI, NEW_TEST_ACT_MANIFESTATION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI);

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButNotSingleVersionDocument() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVVESV0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "9999-06-25")
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.ORIGINAL_VERSION, NEW_TEST_ACT_WORK_URI, NEW_TEST_ACT_EXPRESSION_URI, NEW_TEST_ACT_MANIFESTATION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI);

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButWorkUriChanged() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVVWOU0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "9999-06-25")
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, "/some/invalid/work/uri", NEW_TEST_ACT_EXPRESSION_URI, NEW_TEST_ACT_MANIFESTATION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI);

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButExpressionUriUnchanged() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVVEXU0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "9999-06-25")
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, NEW_TEST_ACT_WORK_URI, ORIGINAL_TEST_ACT_EXPRESSION_URI, NEW_TEST_ACT_MANIFESTATION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI);

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButManifestationUriUnchanged() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVVMAU0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "9999-06-25")
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, NEW_TEST_ACT_WORK_URI, NEW_TEST_ACT_EXPRESSION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI, ORIGINAL_TEST_ACT_MANIFESTATION_URI);

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void save_versionedXMLDocumentButNoReferenceToOriginal() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVDORE0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.EDIT_URL);
        NameValuePair qsGetParams[] = {
                new NameValuePair("action", "save"),
                new NameValuePair("uri", ORIGINAL_TEST_ACT_MANIFESTATION_URI),
                new NameValuePair("version", "9999-06-25")
        };
        post.setQueryString(qsGetParams);

        final String testNewDocumentVersion = AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, NEW_TEST_ACT_WORK_URI, NEW_TEST_ACT_EXPRESSION_URI, NEW_TEST_ACT_MANIFESTATION_URI, null);

        post.setRequestEntity(new ByteArrayRequestEntity(testNewDocumentVersion.getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    

    
}
