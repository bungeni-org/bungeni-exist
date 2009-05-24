package org.bungeni.exist.tools.backupconverter.backup;

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
 * Represents a __contents__.xml Collection Descriptor in the Backup
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class Contents extends Item
{
    private final InputStream inputStream;
    private List<ContentsEntry> entries = null;

    /**
     * @param path The Path of the Contents
     * @param inputStream The input stream for reading the Contents
     */
    public Contents(String path, InputStream inputStream)
    {
        super(path);
        this.inputStream = inputStream;
    }

    /**
     * Gets the entries in the Contents
     *
     * @return List of Contents entries
     */
    public List<ContentsEntry> getEntries() throws IOException
    {
        if(entries == null)
            parseContentsDocument();

        return entries;
    }

    /**
     * SAX parses a __contents__.xml document
     * and extracts the entries
     */
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

    /**
     * Represents an entry in the __contents__.xml file
     */
    public class ContentsEntry extends Item
    {
        /**
         * @param contents The Contents from which this entry was extracted
         * @param filename The filename of the file represented by this Contents Entry
         */
        protected ContentsEntry(Contents contents, String filename)
        {
            super(new File(new File(contents.getPath()).getParentFile(), filename).getPath());
        }

        @Override
        public boolean equals(Object obj)
        {
            return obj instanceof ContentsEntry && getPath().equals(((ContentsEntry)obj).getPath());
        }
    }

    /**
     * Represents a <subcollection/> entry in the __contents__.xml file
     */
    public class ContentsSubCollectionEntry extends ContentsEntry
    {
        /**
         * @param contents The Contents from which this sub collection entry was extracted
         * @param filename The filename of the sub collection represented by this Contents Entry
         */
        public ContentsSubCollectionEntry(Contents contents, String filename)
        {
            super(contents, filename);
        }

        @Override
        public boolean equals(Object obj)
        {
            return obj instanceof ContentsSubCollectionEntry && super.equals(obj);
        }
    }

    /**
     * Represents a <resource/> entry in the __contents__.xml file
     */
    public class ContentsResourceEntry extends ContentsEntry
    {
        /**
         * @param contents The Contents from which this resource entry was extracted
         * @param filename The filename of the resource represented by this Contents Entry
         */
        public ContentsResourceEntry(Contents contents, String filename)
        {
            super(contents, filename);
        }

        @Override
        public boolean equals(Object obj)
        {
            return obj instanceof ContentsResourceEntry && super.equals(obj);
        }
    }

    /**
     * SAX Content Handler which extracts the SubCollection and Resource entries
     * from a Contents
     */
    private class ContentsContentHandler extends DefaultHandler
    {
        private final static String EXIST_NS = "http://exist.sourceforge.net/NS/exist";
        private final static String SUBCOLLECTION_ELEMENT_NAME = "subcollection";
        private final static String RESOURCE_ELEMENT_NAME = "resource";
        private final static String FILENAME_ATTR_NAME = "filename";

        private final Contents contents;
        private List<ContentsEntry> entries = new ArrayList<ContentsEntry>();
        

        /**
         * @param contents The Contents that we are parsing
         */
        public ContentsContentHandler(Contents contents)
        {
            this.contents = contents;
        }

        @Override
        public void startElement(String uri, String localName, String qName, Attributes attrs) throws SAXException
        {
            //get the filename for the entry
            String filename = null;
            if(attrs != null)
            {
                filename = attrs.getValue(FILENAME_ATTR_NAME);
            }

            //subcollection entry?
            if(localName.equals(SUBCOLLECTION_ELEMENT_NAME) && uri.equals(EXIST_NS))
            {
                if(filename != null)
                    entries.add(new ContentsSubCollectionEntry(contents, filename));
            }
            //resource entry
            else if(localName.equals(RESOURCE_ELEMENT_NAME) && uri.equals(EXIST_NS))
            {
                if(filename != null)
                    entries.add(new ContentsResourceEntry(contents, filename));
            }
        }

        /**
         * Gets the parsed entries
         *
         * @return entries from the Contents
         */
        public List<ContentsEntry> getEntries()
        {
            return entries;
        }
    }
}
