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
                "<an:akomantoso xmlns:an=\"" + AkomaNtoso.AN_NAMESPACE_URI + "\">"
                +    "<an:act contains=\"" + (actContentType == AkomaNtoso.ActContentTypes.ORIGINAL_VERSION ? "OriginalVersion" : "SingleVersion") + "\">"
                +        "<an:meta>"
                +            "<an:identification source=\"#ar1\">"
                +  	 			 "<an:Work>"
                +				 	"<an:uri href=\"" + workURI + "\"/>"
                +				 "</an:Work>"
                +                "<an:Expression>"
                +                    "<an:uri href=\"" + expressionURI + "\"/>"
                +                "</an:Expression>"
                +				 "<an:Manifestation>"
                +				 	 "<an:uri href=\"" + manifestationURI + "\"/>"
                +				 "</an:Manifestation>"
                +            "</an:identification>";

        if(originalURI != null)
        {
                act +=
                                         "<an:references source=\"#ar1\">"
                +				 "<an:Original id=\"ro1\" href=\"" + originalURI + "\" showAs=\"Original\"/>"
                +			 "</an:references>";
        }

        act +=
                                "</an:meta>"
                +    "</an:act>"
                + "</an:akomantoso>";

        return act;
    }

    /**
     * Generates a very Simple Bill document
     *
     * @param workURI the URI of this Work
     * @param expressionURI the URI of this Expression
     * @param manifestationURI the URI of this Manifestation
     */
    public final static String generateTestBill(String workURI, String expressionURI, String manifestationURI)
    {
            return
                    "<an:akomantoso xmlns:an=\"" + AkomaNtoso.AN_NAMESPACE_URI + "\">"
                    +    "<an:bill>"
                    +        "<an:meta>"
                    +            "<an:identification source=\"FV\">"
                    +  	 			 "<an:Work>"
                    +				 	"<an:uri href=\"" + workURI + "\"/>"
                    +				 "</an:Work>"
                    +                "<an:Expression>"
                    +                    "<an:uri href=\"" + expressionURI + "\"/>"
                    +                "</an:Expression>"
                    +				 "<an:Manifestation>"
                    +				 	 "<an:uri href=\"" + manifestationURI + "\"/>"
                    +				 "</an:Manifestation>"
                    +            "</an:identification>"
                    +		"</an:meta>"
                    +    "</an:bill>"
                    + "</an:akomantoso>";
    }
}
