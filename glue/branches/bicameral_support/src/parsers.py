"""
Created on Feb 14, 2013

Parser and Parser implementation classes reside here

@author: undesa
"""

from java.io import (
    File, 
    FileWriter, 
    IOException,
    )

from java.lang import (
    RuntimeException
    )

from java.util import (
    HashMap
    )

from org.dom4j import (
    DocumentException,
    )

from org.dom4j.io import (
    SAXReader,
    OutputFormat,
    XMLWriter
    )


from org.apache.log4j import Logger

from utils import (
    _COLOR,
    close_quietly
    )

LOG = Logger.getLogger("glue")

class ParseXML(object):
    """
    Parses XML output from Bungeni using Xerces
    """

    __global_path__ = "//"

    def __init__(self, xml_path):
        """
        Load the xml document from the path
        """
        try:
            self.xmlfile = xml_path
            self.sreader = SAXReader()
            self.an_xml = File(xml_path)
        except IOException, ioE:
            print _COLOR.FAIL, ioE, '\nERROR: IOErrorFound reading xml ', xml_path, _COLOR.ENDC

    def doc_parse(self):
        """
        !+NOTE Previously, this was done in __init__ but it was tough returning that failure as a boolean.
        To be called after initializing ParseXML this is to catch any parsing errors and a return boolean. 
        """
        try:
            self.xmldoc = self.sreader.read(self.an_xml)
            return True
        except DocumentException, fNE:
            print _COLOR.FAIL, fNE, '\nERROR: when trying to parse ', self.xmlfile, _COLOR.ENDC
            return False
        except IOException, fE:
            print _COLOR.FAIL, fE, '\nERROR: IOErrorFound parsing xml ', self.xmlfile, _COLOR.ENDC
            return False
        except Exception, E:
            print _COLOR.FAIL, E, '\nERROR: Saxon parsing xml ', self.xmlfile, _COLOR.ENDC
            return False
        except RuntimeException, ruE:
            print _COLOR.FAIL, ruE, '\nERROR: ruE Saxon parsing xml ', self.xmlfile, _COLOR.ENDC
            return False

    def doc_dom(self):
        """
        Used by RepoSyncUploader to read a __repo_sync__ file generated 
        before uploading to eXist-db
        """
        return self.xmldoc

    def write_to_disk(self):
        format = OutputFormat.createPrettyPrint()
        writer = XMLWriter(FileWriter(self.xmlfile), format)
        try:
            writer.write(self.xmldoc)
            writer.flush()
        except Exception, ex:
            LOG.error("Error while writing %s to disk" % self.xmlfile, ex)
        finally:
            close_quietly(writer)
            


class ParseBungeniXML(ParseXML):
    """
    Parsing contenttype documents from Bungeni.
    """
    def xpath_parl_item(self,name):

        return self.__global_path__ + "contenttype[@name='parliament']/field[@name='"+name+"']"
        
    def xpath_get_attr_val(self,name):

        return self.__global_path__ + "field[@name]"  
        
    def get_parliament_info(self, cc):
        parl_params = HashMap()
        
        parliament_doc = self.xmldoc.selectSingleNode(self.xpath_parl_item("type"))
       
        if parliament_doc is None:
            return None
        if parliament_doc.getText() == "parliament" :
            """
            Get the parliamentary information at this juncture.
            """
            # !+NOTE (ao, 15th Nov 2012) country-code below is not available from Bungeni 
            # Will be enabled once added, currently the default is set in the pipeline configs as 'cc'
            # !+NOTE (ao, 8th Feb 2013) country-code added from glue.ini config file
            parl_params["country-code"] = cc
            parl_params["parliament-id"] = self.xmldoc.selectSingleNode(
                self.xpath_parl_item("parliament_id")
                ).getText()
            parl_params["parliament-election-date"] = self.xmldoc.selectSingleNode(
                self.xpath_parl_item("election_date")
                ).getText()
            parl_params["for-parliament"] = self.xmldoc.selectSingleNode(
                self.xpath_parl_item("type")
                ).getText()
            # !+BICAMERAL(ah,14-02-2013) added a type information for parliament to support
            # bicameral legislatures 
            parl_params["type"] = self.xmldoc.selectSingleNode(
                self.xpath_parl_item("parliament_type")
                ).getText()
            
            return parl_params
        else:
            return None

    def get_contenttype_name(self):
        root_element = self.xmldoc.getRootElement()
        if root_element.getName() == "contenttype":
            return root_element.attributeValue("name")   
        else:
            return None

    def xpath_get_attachments(self):
        
        return self.__global_path__ + "attachments"

    def xpath_get_image(self):

        return self.__global_path__ + "image"

    def xpath_get_log_data(self):

        return self.__global_path__ + "logo_data"

    def get_attached_files(self):
        """
        Gets the attached_files node for a document
        """
        return self.xmldoc.selectSingleNode(self.xpath_get_attachments())

    def get_image_file(self):
        """
        Gets the image node for a user/group document
        """
        # get from default <image/> node...
        image_node = self.xmldoc.selectSingleNode(self.xpath_get_image())
        if image_node is not None:
            return image_node
        else:
            # ...or from <log_data/>. Known to have an image.
            return self.xmldoc.selectSingleNode(self.xpath_get_log_data())


class ParseOntologyXML(ParseXML):
    """
    Parsing ontology documents from Transformation process.
    """
    def get_ontology_name(self):
        root_element = self.xmldoc.getRootElement()
        if root_element.attributeValue("for") == "document":
            return root_element
        else:
            return None

    def write_to_disk(self):
        super(ParseOntologyXML, self).write_to_disk()

            
            