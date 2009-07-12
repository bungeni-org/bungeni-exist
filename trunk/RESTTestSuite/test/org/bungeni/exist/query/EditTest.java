package org.bungeni.exist.query;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.ByteArrayRequestEntity;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.jxpath.JXPathContext;
import org.apache.commons.jxpath.JXPathNotFoundException;
import static org.custommonkey.xmlunit.XMLAssert.assertXMLEqual;
import org.custommonkey.xmlunit.XMLUnit;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni XQuery REST API
 * http://localhost:8088/db/bungeni/query/edit.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.1
 */
public class EditTest
{
    private final static DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();

    private final static String TEST_COLLECTION = "/db/bungeni/data/ke/act/9999";

    static {
        XMLUnit.setIgnoreWhitespace(true);
    }

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
    }
    /**
     * Attempts to store a NEW XML document
     * checks the returned document is the same as the posted document
     */
    @Test
    public void storeNewXMLDocument()
    {
        String testDocManifestationURI = "/ke/act/9999-07-04/1/eng.xml";
        String testDocExpressionURI = testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.'));
        String testDocWorkURI = testDocExpressionURI.substring(0, testDocExpressionURI.lastIndexOf('/'));

        storeTestDocument(AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.ORIGINAL_VERSION, testDocWorkURI, testDocExpressionURI, testDocManifestationURI, null), testDocManifestationURI);
    }

    /**
     * GETs a un-versioned XML document
     * and then POSTs it back to the server
     * it checks that the documents content
     * is the same between the GET response and POST response
     */
    @Test
    public void updateUnVersionedXMLDocument()
    {
        String testDocManifestationURI = "/ke/act/9999-07-05/1/eng.xml";
        String testDocExpressionURI = testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.'));
        String testDocWorkURI = testDocExpressionURI.substring(0, testDocExpressionURI.lastIndexOf('/'));

        //store a test document, we can then try updating it
        storeTestDocument(AkomaNtoso.generateTestBill(testDocWorkURI, testDocExpressionURI, testDocManifestationURI), testDocManifestationURI);

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //GET the binary document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
        };
        get.setQueryString(qsGetParams);

        byte getDocument[] = null;
        try
        {
                status = http.executeMethod(get);
                getDocument = REST.getResponseBody(get);

                assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);
        }
        catch(IOException ioe)
        {
                ioe.printStackTrace();
                fail(ioe.getMessage());
        }
        finally
        {
                //release the connection
                get.releaseConnection();
        }

        //POST the updated XML document
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);
        NameValuePair qsPostParams[] = {
                        new NameValuePair("action", "save"),
                        new NameValuePair("uri", testDocManifestationURI),
                };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(getDocument, get.getResponseHeader("Content-Type").getValue()));

        try
        {
            status = http.executeMethod(post);

            assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

            InputStream responseDocument = post.getResponseBodyAsStream();
            assertXMLEqual("Document should not have changed", new InputSource(new ByteArrayInputStream(getDocument)), new InputSource(responseDocument));
        }
        catch(IOException ioe)
        {
                ioe.printStackTrace();
                fail(ioe.getMessage());
        }
        catch(SAXException se)
        {
                se.printStackTrace();
                fail(se.getMessage());
        }
        finally
        {
                //release the connection
                post.releaseConnection();
        }
    }

    /**
     * GETs a versioned XML document for editing
     * and then POSTs the new version back to the server for store
     *
     * it checks that the documents content
     * is the same between the GET response and POST response
     */
    @Test
    public void createNewXMLDocumentVersion()
    {
        String testDocManifestationURI = "/ke/act/9999-07-01/1/eng.xml";
        String testDocExpressionURI = testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.'));
        String testDocWorkURI = testDocExpressionURI.substring(0, testDocExpressionURI.lastIndexOf('/'));

        //store a test document, we can then create a version of it
        storeTestDocument(AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, testDocWorkURI, testDocExpressionURI, testDocManifestationURI, null), testDocManifestationURI);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String newVersion = sdf.format(Calendar.getInstance().getTime());

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //GET the XML document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
                new NameValuePair("version", newVersion)
        };
        get.setQueryString(qsGetParams);

        byte getResponse[] = null;
        try
        {
                status = http.executeMethod(get);
                getResponse = REST.getResponseBody(get);

                assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);

                assertTrue("No Response document", getResponse != null && getResponse.length > 0);

                //check the document URI's have been updated for the new version
                DocumentBuilder builder = documentBuilderFactory.newDocumentBuilder();
                Document docVersioned = builder.parse(new ByteArrayInputStream(getResponse));
                JXPathContext jxp = JXPathContext.newContext(docVersioned);
                jxp.registerNamespace(AkomaNtoso.AN_NAMESPACE_PREFIX, AkomaNtoso.AN_NAMESPACE_URI);

                HashMap<String, String> namespaces = new HashMap<String, String>();
                namespaces.put("an", AkomaNtoso.AN_NAMESPACE_URI);
                String versionedExpressionURI = (String)jxp.getValue("/an:akomaNtoso/an:act/an:meta/an:identification/an:FRBRExpression/an:FRBRuri/@value", String.class);
                String versionedManifestationURI = (String)jxp.getValue("/an:akomaNtoso/an:act/an:meta/an:identification/an:FRBRManifestation/an:FRBRuri/@value", String.class);

                assertEquals(versionedExpressionURI, testDocExpressionURI + "@" + newVersion);
                assertEquals(versionedManifestationURI, testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.')) + "@" + newVersion + testDocManifestationURI.substring(testDocManifestationURI.indexOf('.')));
            }
            catch(JXPathNotFoundException jnfe)
            {
                jnfe.printStackTrace();
                fail(jnfe.getMessage());
            }
            catch(ParserConfigurationException pce)
            {
                pce.printStackTrace();
                fail(pce.getMessage());
            }
            catch(SAXException se)
            {
                se.printStackTrace();
                fail(se.getMessage());
            }
            catch(IOException ioe)
            {
                ioe.printStackTrace();
                fail(ioe.getMessage());
            }
            finally
            {
                //release the connection
                get.releaseConnection();
            }

            //add a reference to the Original version into the new version of the document
            String originalReference = "<an:references source=\"#ar1\"><an:original id=\"ro1\" href=\"" + testDocManifestationURI + "\" showAs=\"original\"/></an:references>";
            String newDocVersion = new String(getResponse);
            newDocVersion = newDocVersion.substring(0, newDocVersion.indexOf("</an:meta>")) + originalReference + newDocVersion.substring(newDocVersion.indexOf("</an:meta>"));

            //POST the new version XML document
            byte[] postDocument = null;
            PostMethod post = new PostMethod(REST.EDIT_URL);
            post.setDoAuthentication(true);
            NameValuePair qsPostParams[] = {
                            new NameValuePair("action", "save"),
                            new NameValuePair("uri", testDocManifestationURI),
                            new NameValuePair("version", newVersion)
                    };
            post.setQueryString(qsPostParams);
            post.setRequestEntity(new ByteArrayRequestEntity(newDocVersion.getBytes(), Database.XML_MIMETYPE));

            try
            {
                    status = http.executeMethod(post);

                    assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

                    InputStream responseDocument = post.getResponseBodyAsStream();
                    assertXMLEqual("Response document did not match uploaded document", new InputSource(new StringReader(newDocVersion)), new InputSource(responseDocument));
            }
            catch(IOException ioe)
            {
                    ioe.printStackTrace();
                    fail(ioe.getMessage());
            }
            catch(SAXException se)
            {
                    se.printStackTrace();
                    fail(se.getMessage());
            }
            finally
            {
                    //release the connection
                    post.releaseConnection();
            }
    }

    /**
     * GETs a binary un-versioned document
     * and then POSTs it back to the server
     * it checks that the documents content
     * is the same between the GET response and POST response
     */
    @Test
    public void updateUnVersionedBinaryDocument() throws IOException
    {
        String testDocManifestationURI = "/ke/act/9999-01-22/3/eng.doc";

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //PUT a test binary document
        PutMethod put = new PutMethod(REST.EXIST_REST_URI + "/db/bungeni/data/ke/act/9999/01-22_3_eng.doc");
        put.setRequestEntity(new ByteArrayRequestEntity("some_data".getBytes(), "application/msword"));
        status = http.executeMethod(put);
        assertEquals("Could not store test document", HttpStatus.SC_CREATED, status);

        //GET the binary document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
        };
        get.setQueryString(qsGetParams);

        byte getDocument[] = null;
        try
        {
            status = http.executeMethod(get);
            getDocument = REST.getResponseBody(get);

            assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);

            assertTrue("No Response document", getDocument != null && getDocument.length > 0);
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        finally
        {
            //release the connection
            get.releaseConnection();
        }

        //POST the updated binary document
        byte[] postDocument = null;
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "save"),
            new NameValuePair("uri", testDocManifestationURI),
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(getDocument, get.getResponseHeader("Content-Type").getValue()));

        try
        {
            status = http.executeMethod(post);
            postDocument = REST.getResponseBody(post);

            assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

            if(postDocument != null && getDocument != null && postDocument.length == getDocument.length)
            {
                    for(int i = 0; i < postDocument.length; i++)
                    {
                            assertEquals("Received document is not the same as the saved document", postDocument[i], getDocument[i]);
                    }
            }
            else
            {
                    fail("Received document is not the same as the saved document");
            }
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        finally
        {
            //release the connection
            post.releaseConnection();
        }
    }

    /**
     * GETs a binary versioned document
     * and then POSTs it back to the server
     * it checks that the new version of the document
     * has the same content as the original version
     */
    @Test
    public void createNewBinaryDocumentVersion() throws IOException
    {
        final String testDocManifestationURI = "/ke/act/9999-04-22/3/eng.doc";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String newVersion = sdf.format(Calendar.getInstance().getTime());

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //PUT a test binary document
        PutMethod put = new PutMethod(REST.EXIST_REST_URI + "/db/bungeni/data/ke/act/9999/04-22_3_eng.doc");
        put.setRequestEntity(new ByteArrayRequestEntity("some_data".getBytes(), "application/msword"));
        status = http.executeMethod(put);
        assertEquals("Could not store test document", HttpStatus.SC_CREATED, status);

        //GET the binary document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
                new NameValuePair("version", newVersion)
        };
        get.setQueryString(qsGetParams);

        byte getDocument[] = null;
        try
        {
            status = http.executeMethod(get);
            getDocument = REST.getResponseBody(get);

            assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);

            assertTrue("No Response document", getDocument != null && getDocument.length > 0);
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        finally
        {
            //release the connection
            get.releaseConnection();
        }

        //POST the updated binary document
        byte[] postDocument = null;
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "save"),
            new NameValuePair("uri", testDocManifestationURI),
            new NameValuePair("version", newVersion)
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(getDocument, get.getResponseHeader("Content-Type").getValue()));

        try
        {
            status = http.executeMethod(post);
            postDocument = REST.getResponseBody(post);

            assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

            if(postDocument != null && getDocument != null && postDocument.length == getDocument.length)
            {
                for(int i = 0; i < postDocument.length; i++)
                {
                    assertEquals("Received document is not the same as the saved document", postDocument[i], getDocument[i]);
                }
            }
            else
            {
                fail("Received document is not the same as the saved document");
            }
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        finally
        {
            post.releaseConnection();
        }
    }

    /**
     * Stores a XML Test document for testing against
     *
     * @param testDocument the XML test document
     * @param manifestationURI the URI of this Manifestation
     */
    private final static void storeTestDocument(String testDocument, String manifestationURI)
    {
        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //setup POST Request for storing new document
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", manifestationURI)
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(testDocument.getBytes(), Database.XML_MIMETYPE));

        try
        {
            //do POST Request
            status = http.executeMethod(post);
            assertEquals("POST Request did not return HTTP OK", HttpStatus.SC_OK, status);

            InputStream responseDocument = post.getResponseBodyAsStream();
            assertXMLEqual("Response document did not match uploaded document", new InputSource(new StringReader(testDocument)), new InputSource(responseDocument));
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        catch(SAXException se)
        {
            se.printStackTrace();
            fail(se.getMessage());
        }
        finally
        {
            //release the connection
            post.releaseConnection();
        }
    }
}
