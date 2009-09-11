package org.bungeni.exist.query;

import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.methods.PostMethod;
import org.junit.Test;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni Query XQuery REST API Error Codes
 * http://localhost:8088/db/bungeni/query/query.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class QueryErrorTest extends AbstractErrorTest
{
    @Test
    public void no_action() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "UNKNAC0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        PostMethod post = new PostMethod(REST.PACKAGE_URL);

        testErrorResponse(post, expectedErrorCode, expectedErrorMessage);
    }
}
