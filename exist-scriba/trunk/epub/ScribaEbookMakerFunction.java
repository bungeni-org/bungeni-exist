package org.exist.xquery.modules.epub;

import it.senato.areatesti.ebook.ebookmaker.api.ScribaEbookMakerAPI;

import org.apache.log4j.Logger;
import org.exist.dom.QName;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceIterator;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.StringValue;
import org.exist.xquery.value.Type;
import org.exist.xquery.value.ValueSequence;
import org.exist.xquery.value.Base64BinaryValueType;
import org.exist.xquery.value.BinaryValueFromInputStream;

import org.exist.storage.DBBroker;
import org.exist.collections.Collection;
import org.exist.xmldb.EXistResource;
import org.exist.xmldb.EXistResource;
import org.exist.xmldb.XmldbURI;
import org.exist.dom.DocumentImpl;
import org.w3c.dom.Document;

import org.exist.security.PermissionDeniedException;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import javax.xml.xpath.XPathExpressionException;
import org.xml.sax.SAXException;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import org.exist.storage.serializers.Serializer;

import org.exist.xquery.value.NodeValue;
import javax.xml.transform.OutputKeys;
import java.util.Properties;

/**
 * Creates API(s) for accessing ScribaEbookMaker to make ePUB ebooks
 *
 * @author Sam
 */

public class ScribaEbookMakerFunction extends BasicFunction {

    @SuppressWarnings("unused")
	private final static Logger logger = Logger.getLogger(ScribaEbookMakerFunction.class);
	private final static Properties OUTPUT_PROPERTIES = new Properties();

	static {
		OUTPUT_PROPERTIES.setProperty(OutputKeys.INDENT, "yes");
		OUTPUT_PROPERTIES.setProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
	}

    public final static FunctionSignature signature =
		new FunctionSignature(
			new QName("scriba-ebook-maker", EpubModule.NAMESPACE_URI, EpubModule.PREFIX),
			"Returns an ePUB in base64 binary encoding",
			new SequenceType[] { new FunctionParameterSequenceType("document", Type.NODE, Cardinality.EXACTLY_ONE, 
			"The Scriba Configuration File (SCF), an XML input file")},
			new SequenceType(Type.BASE64_BINARY,Cardinality.ZERO_OR_MORE));

	public ScribaEbookMakerFunction(XQueryContext context) {
		super(context, signature);
	}
	
	private String serialize(NodeValue node) throws SAXException {
		
		Serializer serializer = context.getBroker().getSerializer();
        serializer.reset();
        serializer.setProperties(OUTPUT_PROPERTIES);
        return serializer.serialize(node);
    }

	public Sequence eval(Sequence[] args, Sequence contextSequence)
		throws XPathException{

		ValueSequence result = new ValueSequence();
		
		try{
		
			ScribaEbookMakerAPI semapi = new ScribaEbookMakerAPI();
			System.out.println(serialize((NodeValue) args[0].itemAt(0)));
			semapi.setAPIInput(serialize((NodeValue) args[0].itemAt(0)));
			
			return BinaryValueFromInputStream.getInstance(context, new Base64BinaryValueType(), new ByteArrayInputStream(semapi.makeEBookAsStream().toByteArray()));
		}
		catch(SAXException e){
				
			System.out.println(e);	
		}
		catch(Exception e){
		
			System.out.println(e);	
		}
		
		return result;
	}

}
