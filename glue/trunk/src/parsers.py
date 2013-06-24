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
    QName,
    Namespace
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
            self.valid_file = False
            self.xmlfile = xml_path
            self.sreader = SAXReader()
            self.an_xml = File(xml_path)
            self.valid_file = True
        except IOException, ioE:
            self.valid_file = False
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
        #print "XXXX write_to_disk ", self.xmlfile
        #print "XXXX write_to_disk writing dom ", self.xmldoc.asXML()
        format = OutputFormat.createPrettyPrint()
        writer = XMLWriter(FileWriter(self.xmlfile), format)
        try:
            writer.write(self.xmldoc)
            writer.flush()
        except Exception, ex:
            LOG.error("Error while writing %s to disk" % self.xmlfile, ex)
        finally:
            close_quietly(writer)
            


class ParseBungeniTypesXML(ParseXML):
    
    def __init__(self, xml_path):
        super(ParseBungeniTypesXML, self).__init__(xml_path)
        #self.namespaces = {"ce": "http://bungeni.org/config_editor"}
   
    def xpath_nonbase_archetypes(self):
        return self.__global_path__ + "*[@archetype != 'doc' and @archetype != 'event']"
   
    """
    def qname(self, prefix, name):
        return QName(
            name, 
            Namespace(prefix, self.namespaces[prefix])
        )
    """
    """    
    def xpath_ce_types(self):
        return self.__global_path__ + "*[@type]"
    """
    def xpath_doc_archetypes(self):
        return self.__global_path__ + "doc"
    
    def xpath_group_archetypes(self):
        return self.__global_path__ + "group"

    def xpath_member_archetypes(self):
        return self.__global_path__ + "member"
    
    def xpath_event_archetypes(self):
        return self.__global_path__ + "event"
    
    def xpath_all_archetypes(self):
        return self.__global_path__ + "*[ name() = 'doc' or name() = 'group' or name() = 'member' or name() = 'event' ]"
    
    """
    def get_ce_types_map(self):
        xpath = self.doc_dom().createXPath(self.xpath_ce_types())
        xpath.setNamespaceURIs(self.namespaces)
        return xpath.selectNodes(self.doc_dom())
    """    
        
    def get_events(self):
        return self.doc_dom().selectNodes(self.xpath_event_archetypes())
    
    def get_docs(self):
        return self.doc_dom().selectNodes(self.xpath_doc_archetypes())
    
    def get_groups(self):
        return self.doc_dom().selectNodes(self.xpath_group_archetypes())
    
    def get_members(self):
        return self.doc_dom().selectNodes(self.xpath_member_archetypes())
    
    def get_nonbase_archetypes(self):
        return self.doc_dom().selectNodes(self.xpath_nonbase_archetypes())
        
    def get_all(self):
        return self.doc_dom().selectNodes(self.xpath_all_archetypes())

class ParsePipelineConfigsXML(ParseXML):
    
    def xpath_config_for(self, name):
        return self.__global_path__ + ("pipelineConfig[@for='%s']" % name)
    
    def xpath_config_internal(self):
        return self.__global_path__ + ("pipelineConfig[@type='internal']")

    def get_config_for(self, name):
        return self.doc_dom().selectSingleNode(self.xpath_config_for(name))
    
    def get_config_internal(self):
        return self.doc_dom().selectNodes(self.xpath_config_internal())

'''
class ParseLogicalTypesXML(ParseXML):
    
    def xpath_types(self):
        return self.__global_path__ + "types/type"
    
    def get_types(self):
        return self.doc_dom().selectNodes(self.xpath_types())
'''
    
class ParsePipelineXML(ParseXML): 
    
    def xpath_pipelines(self):
        return self.__global_path__ + "pipeline"
    
    def get_pipelines(self):
        return self.doc_dom().selectNodes(self.xpath_pipelines())

class ParseBungeniXML(ParseXML):
    
    """
    Parsing contenttype documents from Bungeni.
    """
    def xpath_parl_item(self,name):
        """
        Gets fields in a parliament object
        """
        return self.__global_path__ + "contenttype[@name='chamber']/field[@name='"+name+"']"
        
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

    def xpath_get_item_schedules(self):

        return self.__global_path__ + "item_schedule[child::item_schedule]"

    def xpath_get_image(self):

        return self.__global_path__ + "image"

    def xpath_get_log_data(self):

        return self.__global_path__ + "logo_data"

    def get_attached_files(self):
        """
        Gets the attached_files node for a document
        """
        return self.xmldoc.selectSingleNode(self.xpath_get_attachments())

    def get_votes_file(self):
        """
        Gets the roll_call node contained in sitting/document/MP
        """
        # get from default <roll_call/> node...
        item_schedules_node = self.xmldoc.selectSingleNode(self.xpath_get_item_schedules())
        if item_schedules_node is not None:
            return item_schedules_node
        else:
            print "[checkpoint] couldn't find item_schedules node"
            return None

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

    def __init__(self, is_cache_file = False):
        """
        is_cache_file indicates whether the file being parsed is a cached file or a content file,
        the XPath prefixes are adjusted according to which file is being processed 
        """
        self.CACHED_TYPES = "cachedTypes"
        self.CONTENT_TYPE = "contenttype"
        self.FIELD_NAME = "field[@name='%s']"
        self.cache_file = is_cache_file
    
    def _xpath_cached_types(self):
        return "/" + self.CACHED_TYPES

    def _xpath_content_types(self):
        return self._xpath_cached_types() + self._xpath_content_type()
    
    def _xpath_content_type(self):
        return "/" + self.CONTENT_TYPE
    
    def _xpath_parliament_info_field(self, name):
        return  self._xpath_content_type() + "[@name='chamber']/" + self._xpath_info_field(name)
    
    def _xpath_info_field(self, name):
        return (self.FIELD_NAME % name)
    
    def __cache_file_prefix__(self):
        if (self.cache_file):
            return ""
        else:
            return "//"
    
    def _get_parl_params(self, cc, parliament_doc):
        parl_map = HashMap()
        parl_map["country-code"] = cc
        #print "XXXXX  ROOT ELEMENT", parliament_doc.getRootElement()
        parl_map["parliament-id"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("principal_id")
            ).getText()
        parl_map["chamber-start-date"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("start_date")
            ).getText()
        parl_map["for-parliament"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("type")
            ).getText()
        # Since : http://code.google.com/p/bungeni-portal/source/detail?r=10757
        #    "identifier" field was renamed to "principal_name"
        parl_map["identifier"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("principal_name")
            ).getText()
        #    "status" field "
        parl_map["status"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("status")
            ).getText()
        # !+BICAMERAL(ah,14-02-2013) added a type information for parliament to support
        # bicameral legislatures 
        parl_map["type"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("sub_type")
            ).getText()
        # !+DEPRECATED r10981 in Bungeni displayAs attribute not present on sub_type
        parl_map["type_display"] = parliament_doc.selectSingleNode(
            self.__cache_file_prefix__() + self._xpath_info_field("full_name")
            ).getText()
            
        return parl_map


class ParseParliamentInfoXML(ParseXML):
    """
    Parse parliament information from an incoming document
    """

    def get_parliament_info(self, cc):
        pinfo = ParliamentInfoParams(is_cache_file=False)
        parl_params = []
        #print "XXXXXX parliament info ", pinfo._xpath_parliament_info_field("type")
        parliament_doc = self.xmldoc.selectSingleNode(pinfo._xpath_parliament_info_field("type"))
        if parliament_doc is None:
            #print "XXXX FOUND DOC NULL XXXX"
            return None
        if parliament_doc.getText() == "chamber" :
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
        pinfo = ParliamentInfoParams(is_cache_file=True)        
        parliament_docs = self.xmldoc.selectNodes(
            pinfo._xpath_content_types()
            )
        if parliament_docs is None:
            return None
        
        if bicameral:
            if len(parliament_docs) == 2:
                for parliament_doc in parliament_docs:
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

            
