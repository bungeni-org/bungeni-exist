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

from gen_utils import (
    COLOR,
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
            print COLOR.FAIL, ioE, '\nERROR: IOErrorFound reading xml ', xml_path, COLOR.ENDC

    def doc_parse(self):
        """
        !+NOTE Previously, this was done in __init__ but it was tough returning that failure as a boolean.
        To be called after initializing ParseXML this is to catch any parsing errors and a return boolean. 
        """
        try:
            self.xmldoc = self.sreader.read(self.an_xml)
            return True
        except DocumentException, fNE:
            print COLOR.FAIL, fNE, '\nERROR: when trying to parse ', self.xmlfile, COLOR.ENDC
            return False
        except IOException, fE:
            print COLOR.FAIL, fE, '\nERROR: IOErrorFound parsing xml ', self.xmlfile, COLOR.ENDC
            return False
        except Exception, E:
            print COLOR.FAIL, E, '\nERROR: Saxon parsing xml ', self.xmlfile, COLOR.ENDC
            return False
        except RuntimeException, ruE:
            print COLOR.FAIL, ruE, '\nERROR: ruE Saxon parsing xml ', self.xmlfile, COLOR.ENDC
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
        """
        Gets fields in a parliament object
        """
        return self.__global_path__ + "contenttype[@name='parliament']/field[@name='"+name+"']"
        
    def xpath_get_attr_val(self,name):

        return self.__global_path__ + "field[@name]"  
   
    
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



class ParliamentInfoParams:

    def __init__(self):    
        self.CACHED_TYPES = "cachedTypes"
        self.CONTENT_TYPE = "contenttype"
        self.FIELD_NAME = "field[@name='%s']"
    
    def _xpath_cached_types(self):
        return "/" + self.CACHED_TYPES

    def _xpath_content_types(self):
        return self._xpath_cached_types() + self._xpath_content_type()
    
    def _xpath_content_type(self):
        return "/" + self.CONTENT_TYPE
    
    def _xpath_parliament_info_field(self, name):
        return  self._xpath_content_type() + "[@name='parliament']/" + self._xpath_info_field(name)
    
    def _xpath_info_field(self, name):
        return (self.FIELD_NAME % name)
    
    def _get_parl_params(self, cc, parliament_doc):
        parl_map = HashMap()
        parl_map["country-code"] = cc
        print "XXXXX self._xpath_info_field", self._xpath_info_field("parliament_id")
        #print "XXXXX  ROOT ELEMENT", parliament_doc.getRootElement()
        parl_map["parliament-id"] = parliament_doc.selectSingleNode(
            "//" + self._xpath_info_field("parliament_id")
            ).getText()
        parl_map["parliament-election-date"] = parliament_doc.selectSingleNode(
            "//" + self._xpath_info_field("election_date")
            ).getText()
        parl_map["for-parliament"] = parliament_doc.selectSingleNode(
            "//" + self._xpath_info_field("type")
            ).getText()
        # !+BICAMERAL(ah,14-02-2013) added a type information for parliament to support
        # bicameral legislatures 
        parl_map["type"] = parliament_doc.selectSingleNode(
            "//" + self._xpath_info_field("parliament_type")
            ).getText()
            
        print "XXXXXX PARL_MAP ", parl_map
        return parl_map


class ParseParliamentInfoXML(ParseXML):
    """
    Parse parliament information from an incoming document
    """

    def get_parliament_info(self, cc):
        pinfo = ParliamentInfoParams()
        parl_params = []
        #print "XXXXXX parliament info ", pinfo._xpath_parliament_info_field("type")
        parliament_doc = self.xmldoc.selectSingleNode(pinfo._xpath_parliament_info_field("type"))
        if parliament_doc is None:
            #print "XXXX FOUND DOC NULL XXXX"
            return None
        print parliament_doc.getText(), "XXX FOUND TYPE "
        if parliament_doc.getText() == "parliament" :
            print "XXX FOUND PARLIAMENT TYPE !!! "
            parl_params.append(
                pinfo._get_parl_params(cc, self.xmldoc)
            )
            return parl_params
        else:
            return None
    

# !+FIX_THIS implement an overload ParseBungeniXML that supports input node processing
class ParseCachedParliamentInfoXML(ParseXML):
    """
    Parse parliament info from the cached document
    
    """

    def get_parliament_info(self, bicameral, cc):
        """
        Returns Cached Parliament information in a List
        """
        # !+BICAMERAL
        parl_params = []
        pinfo = ParliamentInfoParams()        
        parliament_docs = self.xmldoc.selectNodes(
            pinfo._xpath_content_types()
            )
        print "XXXXX parliament_docs ", parliament_docs
        if parliament_docs is None:
            return None
        
        if bicameral:
            if len(parliament_docs) == 2:
                print "XXXXX bicameral !!"
                pinfo = ParliamentInfoParams()
                for parliament_doc in parliament_docs:
                    print "XXXXX parliament_doc ", parliament_doc
                    parl_map = pinfo._get_parl_params(cc, parliament_doc)
                    parl_params.append(parl_map)
                return parl_params
            else:
                LOG.info(
                    "WARNING_INFO : bicameral legislature, number of parliaments found" % parliament_docs.size()
                )
                return None
        else:
            if parliament_docs.size() == 1:
                pinfo = ParliamentInfoParams()
                parl_params.append(
                    pinfo._get_parl_params(cc, parliament_doc)
                )
            else:
                LOG.info(
                "WARNING_INFO: unicameral legislature , number of parliaments found = %d" % parliament_docs.size()
                )
                return None

            