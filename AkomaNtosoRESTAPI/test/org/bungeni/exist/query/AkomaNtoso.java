package org.bungeni.exist.query;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 */
public class AkomaNtoso
{
    public final static String AN_NAMESPACE_URI = "http://www.akomantoso.org/1.0";
    public final static String AN_NAMESPACE_PREFIX = "an";



    public enum ActContentTypes
    {
        ORIGINAL_VERSION,
        SINGLE_VERSION,
    };

    /**
     * Generates a very Simple Act document
     *
     * @param actContentType The content type of this act
     * @param workURI the URI of this Work
     * @param expressionURI the URI of this Expression
     * @param manifestationURI the URI of this Manifestation
     * @param originalURI the URI of the Original version or null if this is non-versioned or the Original
     */
    public final static String generateTestAct(AkomaNtoso.ActContentTypes actContentType, String workURI, String expressionURI, String manifestationURI, String originalURI)
    {
        String act =
                "<an:akomaNtoso xmlns:an=\"" + AkomaNtoso.AN_NAMESPACE_URI + "\">"
                +   "<an:act contains=\"" + (actContentType == AkomaNtoso.ActContentTypes.ORIGINAL_VERSION ? "originalVersion" : "singleVersion") + "\">"
                + generateANMeta(workURI, expressionURI, manifestationURI, originalURI)
                +       "<an:body>"
                +           "<an:article id=\"art1\">"
                +               "<an:num>1.</an:num>"
                +               "<an:heading>Short article title.</an:heading>"
                +               "<an:clause id=\"art1-cla1\">"
                +                   "<an:content>"
                +                       "<an:p>Some article text</an:p>"
                +                   "</an:content>"
                +               "</an:clause>"
                +           "</an:article>"
                +       "</an:body>"
                +    "</an:act>"
                + "</an:akomaNtoso>";

        return act;
    }

    /**
     * Generates a very Simple Bill document
     *
     * @param workURI the URI of this Workan:akomantoso
     * @param expressionURI the URI of this Expression
     * @param manifestationURI the URI of this Manifestation
     */
    public final static String generateTestBill(String workURI, String expressionURI, String manifestationURI)
    {
            return
                    "<an:akomaNtoso xmlns:an=\"" + AkomaNtoso.AN_NAMESPACE_URI + "\">"
                    +    "<an:bill>"
                    +       generateANMeta(workURI, expressionURI, manifestationURI, null)
                    +       "<an:body>"
                    +           "<an:article id=\"art1\">"
                    +               "<an:num>1.</an:num>"
                    +               "<an:heading>Short article title.</an:heading>"
                    +               "<an:clause id=\"art1-cla1\">"
                    +                   "<an:content>"
                    +                       "<an:p>Some article text</an:p>"
                    +                   "</an:content>"
                    +               "</an:clause>"
                    +           "</an:article>"
                    +       "</an:body>"
                    +    "</an:bill>"
                    + "</an:akomaNtoso>";
    }

    private static String generateANMeta(String workURI, String expressionURI, String manifestationURI, String originalURI)
    {
        String workURISegs[] = workURI.split("/");
        String workDate = workURISegs[workURISegs.length - 2];
        
        String meta =       "<an:meta>"
                +           "<an:identification source=\"#ar1\">"
                +               "<an:FRBRWork>"
                +                   "<an:FRBRthis value=\"" + workURI + "/main" + "\"/>"
                +                   "<an:FRBRuri value=\"" + workURI + "\"/>"
                +                   "<an:FRBRdate date=\"" + workDate + "\" name=\"some-name\"/>"
                +                   "<an:FRBRauthor href=\"http://www.adamretter.org.uk/\"/>"
                +		"</an:FRBRWork>"
                +               "<an:FRBRExpression>"
                +                   "<an:FRBRthis value=\"" + expressionURI + "/main" + "\"/>"
                +                   "<an:FRBRuri value=\"" + expressionURI + "\"/>"
                +                   "<an:FRBRdate date=\"" + workDate + "\" name=\"some-name\"/>"
                +                   "<an:FRBRauthor href=\"http://www.adamretter.org.uk/\"/>"
                +               "</an:FRBRExpression>"
                +               "<an:FRBRManifestation>"
                +                   "<an:FRBRthis value=\"" + manifestationURI + "\"/>"
                +                   "<an:FRBRuri value=\"" + manifestationURI + "\"/>"
                +                   "<an:FRBRdate date=\"" + workDate + "\" name=\"some-name\"/>"
                +                   "<an:FRBRauthor href=\"http://www.adamretter.org.uk/\"/>"
                +               "</an:FRBRManifestation>"
                +           "</an:identification>"
                +           "<an:publication name=\"internal\" date=\"" + workDate + "\" showAs=\"\"/>";

        if(originalURI != null)
        {
                meta +=
                                         "<an:references source=\"#ar1\">"
                +				 "<an:original id=\"ro1\" href=\"" + originalURI + "\" showAs=\"original\"/>"
                +			 "</an:references>";
        }

        meta +=
                                "</an:meta>";

        return meta;
    }
}
