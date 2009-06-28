package org.bungeni.exist.query;

import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.httpclient.methods.GetMethod;
import org.junit.Test;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni Akoma Ntoso URI Handler XQuery REST API Error Codes
 * http://localhost:8088/db/bungeni/query/AkomaNtosoURIHandler.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class AkomaNtosoURIHandlerErrorTest extends AbstractErrorTest
{
    @Test
    public void invalidUriType()  throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "IVDUTY0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=unknown";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void workUri_missing_country() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MICOWO0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=work";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void workUri_missing_type() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MITYWO0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=work&country=ken";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void workUri_missing_date() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIDTWO0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=work&country=ken&type=act";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void expressionUri_missing_country() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MICOEX0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=expression";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void expressionUri_missing_type() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MITYEX0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=expression&country=ken";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void expressionUri_missing_date() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIDTEX0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=expression&country=ken&type=act";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void expressionUri_missing_lang() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MILAEX0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=expression&country=ken&type=act&date=2009-06-28";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void manifestationUri_missing_country() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MICOMA0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=manifestation";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void manifestationUri_missing_type() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MITYMA0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=manifestation&country=ken";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void manifestationUri_missing_date() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIDTMA0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=manifestation&country=ken&type=act";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void manifestationUri_missing_lang() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MILAMA0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=manifestation&country=ken&type=act&date=2009-06-28";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }

    @Test
    public void manifestationUri_missing_dataFormat() throws IOException, ParserConfigurationException, SAXException
    {
        final String expectedErrorCode = "MIDFMA0001";
        final String expectedErrorMessage = getErrorMessageForErrorCode(expectedErrorCode);

        final String uri = REST.AN_URIHANDLER_URL + "?uriType=manifestation&country=ken&type=act&date=2009-06-28&lang=eng";

        GetMethod get = new GetMethod(uri);

        testErrorResponse(get, expectedErrorCode, expectedErrorMessage);
    }
}
