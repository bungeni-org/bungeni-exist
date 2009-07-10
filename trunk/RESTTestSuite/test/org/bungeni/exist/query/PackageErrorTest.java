package org.bungeni.exist.query;

import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.ByteArrayRequestEntity;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.junit.Test;
import org.xml.sax.SAXException;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 */
public class PackageErrorTest extends AbstractErrorTest
{
    @Test
    public void no_action() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "UNKNAC0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void store_missing_data() throws IOException, ParserConfigurationException, SAXException
    {
        //final String expectedErrorCode = "MIPKST0001";
        final String expectedErrorCode = "IVPKST0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "store")
        };
        post.setQueryString(qsPostParams);

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void store_empty_string_data() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVPKST0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "store")
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new StringRequestEntity("", Database.TEXT_MIMETYPE, "UTF-8"));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void store_string_data() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVPKST0002";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "store")
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new StringRequestEntity("Hello World", Database.TEXT_MIMETYPE, "UTF-8"));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void store_xml_data() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVPKST0002";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "store")
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity("<hello-world/>".getBytes(), Database.XML_MIMETYPE));

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }
}
