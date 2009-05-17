package backupconverter.backup;

import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.helpers.XMLReaderFactory;
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
    private final InputStream inputStream;

    private List<ContentsEntry> entries = null;

    
    public Contents(String path, InputStream inputStream)
    {
        super(path);
        this.inputStream = inputStream;
    }

    public List<ContentsEntry> getEntries() throws IOException
    {
        if(entries == null)
            parseContentsDocument();

        return entries;
    }

    private void parseContentsDocument() throws IOException
    {
        try
        {
            XMLReader reader = XMLReaderFactory.createXMLReader();
            ContentsContentHandler contentsHandler = new ContentsContentHandler(this);
            reader.setContentHandler(contentsHandler);
        
            reader.parse(new InputSource(inputStream));

            this.entries = contentsHandler.getEntries();
        }
        catch(SAXException saxe)
        {
            throw new IOException(saxe);
        }
    }

    public class ContentsEntry extends Item
    {
        public ContentsEntry(Contents contents, String name)
        {
            super(new File(new File(contents.getPath()).getParentFile(), name).getPath());
        }

        @Override
        public boolean equals(Object obj)
        {
            return obj instanceof ContentsEntry && getPath().equals(((ContentsEntry)obj).getPath());
        }
    }

    public class ContentsSubCollectionEntry extends ContentsEntry
    {
        public ContentsSubCollectionEntry(Contents contents, String name)
        {
            super(contents, name);
        }

        @Override
        public boolean equals(Object obj)
        {
            return obj instanceof ContentsSubCollectionEntry && super.equals(obj);
        }
    }

    public class ContentsResourceEntry extends ContentsEntry
    {
        public ContentsResourceEntry(Contents contents, String name)
        {
            super(contents, name);
        }

        @Override
        public boolean equals(Object obj)
        {
            return obj instanceof ContentsResourceEntry && super.equals(obj);
        }
    }


    private class ContentsContentHandler extends DefaultHandler
    {
        private final static String EXIST_NS = "http://exist.sourceforge.net/NS/exist";
        private final static String SUBCOLLECTION_ELEMENT_NAME = "subcollection";
        private final static String RESOURCE_ELEMENT_NAME = "resource";
        private final static String FILENAME_ATTR_NAME = "filename";

        private final Contents contents;
        private List<ContentsEntry> entries = new ArrayList<ContentsEntry>();
        

        public ContentsContentHandler(Contents contents)
        {
            this.contents = contents;
        }

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
                    entries.add(new ContentsSubCollectionEntry(contents, filename));
            }
            else if(localName.equals(RESOURCE_ELEMENT_NAME) && uri.equals(EXIST_NS))
            {
                if(filename != null)
                    entries.add(new ContentsResourceEntry(contents, filename));
            }
        }

        public List<ContentsEntry> getEntries()
        {
            return entries;
        }
    }
}
