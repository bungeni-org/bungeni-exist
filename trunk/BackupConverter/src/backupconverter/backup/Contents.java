package backupconverter.backup;

import java.io.InputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.Locator;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.ContentHandler;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.XMLReader;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class Contents extends Item
{
    public final static String CONTENTS_FILE = "__contents__.xml";

    
    public Contents(String path, InputStream inputStream)
    {
        super(path);

        /*
        XMLReader reader = XMLReaderFactory.createXMLReader();
        ContentHandler contentsHandler = new ContentsContentHandler();
        reader.setContentHandler(contentsHandler);
        reader.parse(new InputSource(inputStream));
         */

    }

    public class ContentsContentHandler extends DefaultHandler
    {
        private final static String EXIST_NS = "http://exist.sourceforge.net/NS/exist";
        private final static String SUBCOLLECTION_ELEMENT_NAME = "subcollection";
        private final static String RESOURCE_ELEMENT_NAME = "resource";
        private final static String FILENAME_ATTR_NAME = "filename";

        private List<String> subCollections = new ArrayList<String>();
        private List<String> resources = new ArrayList<String>();


        @Override
        public void startElement(String uri, String localName, String qName, Attributes attrs) throws SAXException
        {
            String filename = null;
            if(attrs != null)
            {
                filename = attrs.getValue(FILENAME_ATTR_NAME);
            }

            if(localName.equals(SUBCOLLECTION_ELEMENT_NAME) && uri.equals(EXIST_NS))
            {
                if(filename != null)
                    subCollections.add(filename);
            }
            else if(localName.equals(RESOURCE_ELEMENT_NAME) && uri.equals(EXIST_NS))
            {
                if(filename != null)
                    resources.add(filename);
            }
        }
    }
}
