package org.bungeni.exist.query;

import java.io.IOException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.jxpath.JXPathContext;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public abstract class AbstractErrorTest
{
    private final static DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
    

    protected final static String getErrorMessageForErrorCode(String errorCode) throws IOException, ParserConfigurationException, SAXException
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

    protected final static void testErrorResponse(HttpMethod method, String expectedErrorCode, String expectedErrorMessage) throws IOException, ParserConfigurationException, SAXException
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
