""" 
    Performs XSLT transformations on Bungeni documents and outputs ontological documents;
    synchronizes with eXist-db; translates .po files to .xml catalogues

    transformation process:
        -get parliament's information
        -look for documents with attachments and bind them
        -transform Bungeni documents and add the bu: namespace
        -synchronize with collection in eXist-db to create upload list
        -upload XML documents + attachments to eXist database
    other actions:
        -translate .po files to .xml catalogues
        !+NOTE: Use of polib requires one to install it to Jython as follows:
        /path/to/jython2.5.2/bin/easy_install polib
"""

import httplib, socket #used in sync check
import os.path, sys, errno, getopt, shutil, uuid
import time
import ConfigParser, jarray

__author__ = "Ashok Hariharan and Anthony Oduor"
__copyright__ = "Copyright 2011, Bungeni"
__license__ = "GNU GPL v3"
__version__ = "1.3.0"
__maintainer__ = "Anthony Oduor"
__created__ = "18th Oct 2011"
__status__ = "Development"

__parl_info__ = "parliament_info.xml"

__sax_parser_factory__ = "org.apache.xerces.jaxp.SAXParserFactoryImpl"

from org.dom4j import DocumentFactory
from org.dom4j import DocumentException
from org.dom4j.io import SAXReader
from org.dom4j.io import OutputFormat
from org.dom4j.io import XMLWriter
from java.io import File, FileWriter, FileNotFoundException, IOException
from java.io import FileInputStream
from java.io import StringReader
from java.util import HashMap
from net.lingala.zip4j.core import ZipFile
from net.lingala.zip4j.exception import ZipException
from com.googlecode.sardine.impl import SardineException
from org.apache.http.conn import HttpHostConnectException
from com.googlecode.sardine import SardineFactory

from net.sf.saxon.trans import *
from org.xml.sax import *
from org.bungeni.translators.translator import OATranslator
from org.bungeni.translators.globalconfigurations import GlobalConfigurations 
from org.bungeni.translators.utility.files import FileUtility

from org.apache.log4j import PropertyConfigurator,Logger
LOG = Logger.getLogger("glue")

class Config(object):
    """
    Provides access to the configuration file via ConfigParser
    """
    
    def __init__(self, config_file):
        self.cfg = ConfigParser.RawConfigParser()
        print "Reading config file : " , os.path.abspath(config_file)
        self.cfg.read(config_file)
    
    def get(self, section, key):
        return self.cfg.get(section, key)

    def items(self, section):
        return self.cfg.items(section)

class TransformerConfig(Config):
    """
    Configuration information for the Transformer
    """

    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}

    def using_queue(self):
        return self.get("general", "message_queue")

    def get_input_folder(self):
        return self.get("general", "bungeni_docs_folder")

    def get_transformer_resources_folder(self):
        return self.get("general", "transformer_resources_folder")

    def get_akomantoso_output_folder(self):
        return self.get("general", "akomantoso_output_folder")

    def get_ontoxml_output_folder(self):
        return self.get("general", "metalex_output_folder")

    def get_attachments_output_folder(self):
        return self.get("general","attachments_output_folder")

    def get_temp_files_folder(self):
        return self.get("general","temp_files_folder")

    def get_pipelines(self):
        # list of key,values pairs as tuples 
        if len(self.dict_pipes) == 0:
            l_pipes = self.cfg.items("pipelines")
            for l_pipe in l_pipes:
                self.dict_pipes[l_pipe[0]] = l_pipe[1]
        return self.dict_pipes


class Transformer(object):
    """
    Access the Transformer via this class
    """

    __global_path__ = "//"
    
    def __init__(self, cfg):
        # point the transformer to the correct configuration folder
        GlobalConfigurations.setApplicationPathPrefix(cfg.get_transformer_resources_folder())
        # initialize the transformer
        self.transformer = OATranslator.getInstance()
        # setup a hashmap to pass input parameters to the pipeline
        self._params = HashMap()
        
    def get_params(self):
        # returns the parliament info object
        return self._params
    
    def set_params(self, params):
        # sets the parliament info object
        self._params = params

    def xpath_get_doc_uri(self):
        #returns a documents URI
        return self.__global_path__ + "bu:ontology/child::*/@uri"

    def xpath_get_doc_internal_uri(self):
        #returns a documents internal-URI. This is a fallback for document URI
        return self.__global_path__ + "bu:ontology/child::*/@internal-uri"

    def xpath_get_status_date(self):
        #returns a documents URI
        return self.__global_path__ + "bu:ontology/child::*/bu:statusDate"

    def get_sync_status(self,input_file):
        sreader = SAXReader()
        self.xmldoc = sreader.read(StringReader(input_file))
        return self.xmldoc.selectSingleNode("/response/status").getText()

    def get_doc_params(self,input_file):
        sreader = SAXReader()
        self.xmldoc = sreader.read(input_file)
        on_sync_params = {}
        doc_uri = self.xmldoc.selectSingleNode(self.xpath_get_doc_uri())
        status_date = self.xmldoc.selectSingleNode(self.xpath_get_status_date())
        if doc_uri is None:
            on_sync_params['uri'] = self.xmldoc.selectSingleNode(self.xpath_get_doc_internal_uri()).getValue()
        else:
            on_sync_params['uri'] = doc_uri.getValue()
        if status_date is None:
            on_sync_params['status_date'] = ""
        else:
            on_sync_params['status_date'] = self.xmldoc.selectSingleNode(self.xpath_get_status_date()).getText()
        return on_sync_params

    def get_doc_uri(self,input_file):
        sreader = SAXReader()
        self.xmldoc = sreader.read(input_file)
        doc_uri = self.xmldoc.selectSingleNode(self.xpath_get_doc_uri())
        if doc_uri is None:
            return self.xmldoc.selectSingleNode(self.xpath_get_doc_internal_uri()).getValue()
        else:
            return doc_uri.getValue()

    def replace_all(self, uri, dic):
        #multiple replace characters
        for i, j in dic.iteritems():
            uri = uri.replace(i, j)
        return uri

    def run(self, input_file, output, config_file):
        """
        Run the transformer on the input file
        """
        print "[checkpoint] entering translation..."
        if os.path.isfile(input_file) == False:
            print _COLOR.FAIL, '\nFile disappeared. Will retry ', input_file, _COLOR.ENDC
            return [None, None]
        print "Executing Transformer with: ", input_file, output, config_file
        try:
            translatedFiles = self.transformer.translate(
                input_file, 
                config_file,  
                self.get_params()
                )
            # catch internal exceptions that return 'null'
            if translatedFiles is None:
                print "[checkpoint] internal failure in the transformer"
                return [None, None]
            else:
                #input stream
                fis  = FileInputStream(translatedFiles["final"])
                #get the document's URI
                uri = self.get_doc_uri(translatedFiles["final"])
                rep_dict = {'/':'_', ':':','}
                uri_name = self.replace_all(uri, rep_dict)
                
                outFile = File(output + uri_name + ".xml")
                #copy transformed file to disk
                FileUtility.getInstance().copyFile(fis, outFile)
                fis.close()
                return [outFile, None]
        except SAXParseException, saE:
            print _COLOR.FAIL, saE, '\nERROR: saE While processing xml ', input_file, _COLOR.ENDC
            return [None, None]
        except XPathException, xpE:
            print _COLOR.FAIL, xpE, '\nERROR: xpE While processing xml ', input_file, _COLOR.ENDC
            return [None, None]
        except IOException, ioE:
            print _COLOR.FAIL, ioE, '\nERROR: ioE While processing xml ', input_file, _COLOR.ENDC
            return [None, None]
        except Exception, E:
            print _COLOR.FAIL, E, '\nERROR: E While processing xml ', input_file, _COLOR.ENDC
            return [None, None]
        except RuntimeException, ruE:
            print _COLOR.FAIL, ruE, '\nERROR: ruE While processing xml ', input_file, _COLOR.ENDC
            return [None, None]


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
        Used by RepoSyncUploader to read a reposync.xml file generated 
        before uploading to eXist-db
        """
        return self.xmldoc

    def write_to_disk(self):
        format = OutputFormat.createPrettyPrint()
        writer = XMLWriter(FileWriter(self.xmlfile), format)
        writer.write(self.xmldoc)
        writer.flush()
        writer.close()

class ParseBungeniXML(ParseXML):
    """
    Parsing contenttype documents from Bungeni.
    """
    def xpath_parl_item(self,name):

        return self.__global_path__ + "contenttype[@name='parliament']/field[@name='"+name+"']"
        
    def xpath_get_attr_val(self,name):

        return self.__global_path__ + "field[@name]"  
        
    def get_parliament_info(self):
        parl_params = HashMap()
        
        parliament_doc = self.xmldoc.selectSingleNode(self.xpath_parl_item("type"))
       
        if parliament_doc is None:
            return None
        if parliament_doc.getText() == "parliament" :
            """
            Get the parliamentary information at this juncture.
            """
            #parl_params['country-code'] = self.xmldoc.selectSingleNode("contenttype/field[@name='language']").getText()
            parl_params['parliament-id'] = self.xmldoc.selectSingleNode(self.xpath_parl_item("parliament_id")).getText()
            parl_params['parliament-election-date'] = self.xmldoc.selectSingleNode(self.xpath_parl_item("election_date")).getText()
            parl_params['for-parliament'] = self.xmldoc.selectSingleNode(self.xpath_parl_item("type")).getText()
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
            
    def get_attached_files(self):
        """
        Gets the attached_files node for a document
        """
        return self.xmldoc.selectSingleNode(self.xpath_get_attachments())

    def get_image_file(self):
        """
        Gets the image node for a user document
        """
        return self.xmldoc.selectSingleNode(self.xpath_get_image())

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


class _COLOR(object):
    """
    Color definitions used for color-coding significant runtime events 
    or raised exceptions as applied on python print() function
    """
    
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

    def disable(self):
        self.HEADER = ''
        self.OKBLUE = ''
        self.OKGREEN = ''
        self.WARNING = ''
        self.FAIL = ''
        self.ENDC = ''


class GenericDirWalker(object):
    """
    Walks a directory tree and invokes a
    callback API for every file in the tree
    """
    
    def __init__(self, input_params = None):
        """
        input_params - the parameters for the callback function
        """
        self.counter = 0
        self.object_info = None
        self.input_params = input_params

    def walk(self, folder):
        """ 
        walk a folder and recursively walk through sub-folders
        for every file in the folder call the processing function
        """
        folder = os.path.abspath(folder)
        for a_file in [
          a_file for a_file in os.listdir(folder) if not a_file in [".",".."]
          ]:
            nfile = os.path.join(folder, a_file)
            if os.path.isdir(nfile):
                self.walk(nfile)
            else:
                # increment the counter in the callback
                info_object = self.fn_callback(nfile)
                if info_object[0] == True:
                    self.object_info = info_object[1]
                    break
                else:
                    continue

    def fn_callback(self, nfile):
        LOG.debug("in GenericDirWalker BASE callback" + nfile)
        return (False, None)


class GenericDirWalkerXML(GenericDirWalker):
    """
    Walks a directory tree, but the callback filters on for 
    XML documents
    """

    def fn_callback(self, nfile):
        import fnmatch
        LOG.debug("in GenericDirWalker XML callback" + nfile)
        if fnmatch.fnmatch(nfile, "*.xml"):
            self.counter = self.counter + 1
            LOG.debug("returning TRUE GenericDirWalker XML callback" + nfile )
            return (True, None)
        else:
            LOG.debug("returning FALSE GenericDirWalker XML callback" + nfile )
            return (False,None)


class GenericDirWalkerATTS(GenericDirWalker):
    """
    grabs anyfile in the attachments folder no discrimination by filetype
    """
    
    def fn_callback(self, nfile):
        LOG.debug("in GenericDirWalker ATTS callback" + nfile)
        if nfile:
            self.counter = self.counter + 1
            LOG.debug("returning TRUE GenericDirWalker XML callback" + nfile )
            return (True, None)
        else:
            LOG.debug("returning FALSE GenericDirWalker XML callback" + nfile )
            return (False,None)


class GenericDirWalkerUNZIP(GenericDirWalker):

    def extractor(self, zip_file, dest_path = None):
        """
        extracts any .zip files in folder matching original name file.
        http://www.lingala.net/zip4j/
        """
        try:
            #Initiate ZipFile object with the path/name of the zip file.
            unzipper = ZipFile(zip_file)
            if dest_path is not None:
                extract_to = dest_path
            else:
                extract_to = os.path.splitext(zip_file)[0]
            #Extracts all files to the path specified
            unzipper.extractAll(extract_to)
            print _COLOR.WARNING + "Extracted zip file... " + zip_file+_COLOR.ENDC
        except ZipException, e:
            LOG.error("Error while processing zip "+ zip_file + e)

    def fn_callback(self, nfile):
        import fnmatch
        #print "in GenericDirWalker ZIP callback" , nfile
        if fnmatch.fnmatch(nfile, "*.zip"):
            self.counter = self.counter + 1
            self.extractor(nfile)
            #print "returning TRUE GenericDirWalker ZIP callback" , nfile
            # There is no extended processing here - we just continue until 
            # we have run out of zip files to process, so we return False
            # so as to not break the loop
            return (False, None)
        else:
            #print "returning FALSE GenericDirWalker ZIP callback" , nfile
            return (False,None)


class ParliamentInfoWalker(GenericDirWalkerXML):
    """
    Walker that retrieves the info about the parliament
    """
    def get_from_cache(self, input_file_path):
        bunparse = ParseBungeniXML(input_file_path)
        bunparse.doc_parse()
        the_parl_doc = bunparse.get_parliament_info()
        return the_parl_doc

    def fn_callback(self, input_file_path):
        if GenericDirWalkerXML.fn_callback(self, input_file_path)[0] == True:
            bunparse = ParseBungeniXML(input_file_path)
            bunparse.doc_parse()
            the_parl_doc = bunparse.get_parliament_info()
            if the_parl_doc is not None:
                """
                Create a cached copy in tmp folder defined in config.ini for quick access 
                in the current parliament's future transformation processes
                """
                tmp_folder = self.input_params["main_config"].get_temp_files_folder()
                shutil.copyfile(input_file_path, tmp_folder + __parl_info__)
                return (True, the_parl_doc)
            else :
                return (False, None)
        else:
            return (False,None)


class SeekBindAttachmentsWalker(GenericDirWalkerXML):
    """
    Walker that finds files with attachments and adds uuids
    """
    
    def xpath_get_saved_file(self):
        return "field[@name='saved_file']"

    def xpath_get_img_file(self):
        return "field[@name='img_uuid']"

    def attachments_seek_rename(self, inputdoc):
        """
        Attachments arrive from bungeni in zip files and use a non-random filename,
        we randomize this file name by renaming it to a unique id, and then repoint
        the XML file to the new attachment name
        """
        # get the folder where the attachments are written to
        self.atts_folder = self.input_params["main_config"].get_attachments_output_folder()
        # get the attached_files node in the document
        attachments = inputdoc.get_attached_files()
        if (attachments is not None):
            LOG.debug("In attachments_seek_rename " + inputdoc.xmlfile + " HAS attachments ")
            # get the attached_file nodes within attached_files
            nodes = attachments.elements("attachment")
            document_updated = False
            for node in nodes:
                # for each attached_file
                saved_file_node = node.selectSingleNode(self.xpath_get_saved_file())
                if saved_file_node is not None:
                    # get the name of the saved file node
                    original_name = saved_file_node.getText()
                    # rename file with uuid
                    new_name = str(uuid.uuid4())
                    # first get the current directory name 
                    current_dir = os.path.dirname(inputdoc.xmlfile)
                    # move file to attachments folder and use derived uuid as new name for the file
                    shutil.move(current_dir + "/" + original_name, self.atts_folder + new_name)
                    # add new node on document with uuid
                    node.addElement("field").addText(new_name).addAttribute("name","att_uuid")
                    document_updated = True
            if document_updated:
                inputdoc.write_to_disk()
            
        else:
            LOG.debug("In attachments_seek_rename " + inputdoc.xmlfile + " NO attachments")

    def image_seek_rename(self, inputdoc, dir_name, abs_path = False):
        """
        User images arrive from bungeni in zip files and use a non-random filename,
        we randomize this file name by renaming it to a unique id, and then repoint
        the XML file to the new image name
        """
        # get the folder where the attachments are written to
        self.atts_folder = self.input_params["main_config"].get_attachments_output_folder()
        # get the attached_files node in the document
        image_node = inputdoc.get_image_file()
        if (image_node is not None):
            LOG.debug("In image_seek_rename " + inputdoc.xmlfile + " HAS an image ")
            # get the attached_file nodes within attached_files
            document_updated = False
            saved_file_node = image_node.selectSingleNode(self.xpath_get_saved_file())
            saved_img_node = image_node.selectSingleNode(self.xpath_get_img_file())
            if saved_img_node is not None:
                saved_img_node.detach()
            if saved_file_node is not None:
                # get the name of the saved file node
                original_name = saved_file_node.getText()
                # rename file with uuid
                new_name = str(uuid.uuid4())
                # first get the current directory name 
                if abs_path == False:
                    current_dir = os.path.dirname(inputdoc.xmlfile)
                    full_path = current_dir + "/"
                else:
                    full_path = dir_name
                # move file to attachments folder and use derived uuid as new name for the file
                shutil.move(full_path + original_name, self.atts_folder + new_name)
                # add new node on document with uuid
                image_node.addElement("field").addText(new_name).addAttribute("name","img_uuid")
                document_updated = True
            if document_updated:
                inputdoc.write_to_disk()
                return original_name
        else:
            LOG.debug("In attachments_seek_rename " + inputdoc.xmlfile + " NO attachments")
            return None

    def fn_callback(self, input_file_path):
        if GenericDirWalkerXML.fn_callback(self, input_file_path)[0] == True:
            # get the DOM of the input document
            bunparse = ParseBungeniXML(input_file_path)
            bunparse.doc_parse()
            # now we process the attachment
            LOG.debug("Calling image/attachment_seek_rename for " + input_file_path )
            self.attachments_seek_rename(bunparse)
            xml_basename = os.path.basename(input_file_path)
            xml_name = os.path.splitext(xml_basename)[0]
            self.image_seek_rename(bunparse, xml_name, False)
        return (False,None)


class ProcessXmlFilesWalker(GenericDirWalkerXML):
    """
    Walker that is used to transform XML Files
    """

    def process_file(self, input_file_path):
        """
        Used by main_queue for individual processing mode
        """
        bunparse = ParseBungeniXML(input_file_path)
        parse_ok = bunparse.doc_parse()
        if parse_ok == False:
            # probably file is corrupt or not completely written to filesystem
            # return back to queue
            return (True, False)
        print "[checkpoint] running", bunparse.get_contenttype_name()
        pipe_type = bunparse.get_contenttype_name()
        if pipe_type is not None:
            if pipe_type in self.input_params["main_config"].get_pipelines():
                pipe_path = self.input_params["main_config"].get_pipelines()[pipe_type]
                output_file_name_wo_prefix  =   pipe_type + "_"
                #truncate to first-3 characters only
                truncated_prefix = output_file_name_wo_prefix[:3]
                on_xml_file = "on_" + truncated_prefix
                out_files = self.input_params["transformer"].run(
                     input_file_path,
                     self.input_params["main_config"].get_ontoxml_output_folder() + on_xml_file ,
                     pipe_path
                     )
                # Any error in transfromer return a None object which we want to leave 
                # the doc in queue e.g. premature end of file encountered
                if out_files[0] == None:
                    print "NOT TRANSFORMED: Back to queue"
                    return (True, False)
                else:
                    return (out_files[0], True)
            elif pipe_type == "parliament":
                # Handle unique case parliament
                return (None, None)
            # !+FIX_THIS (ao, 22 Aug 2012) Currently these are not being processed so removing them 
            # from queue programmatically
            elif pipe_type == "attachment" or pipe_type == "signatory" or pipe_type == "report":
                # Handle un-pipelined docs
                return (None, None)
            else:
                return (True, False)
        else:
            print "Ignoring %s" % input_file_path
            return (False, False)

    def fn_callback(self, input_file_path):
        if GenericDirWalkerXML.fn_callback(self, input_file_path)[0] == True:
            bunparse = ParseBungeniXML(input_file_path)
            bunparse.doc_parse()
            pipe_type = bunparse.get_contenttype_name()
            if pipe_type is not None:
                if pipe_type in self.input_params["main_config"].get_pipelines():
                    pipe_path = self.input_params["main_config"].get_pipelines()[pipe_type]
                    output_file_name_wo_prefix  =   pipe_type + "_" + str(self.counter)
                    #truncate to first-3 characters only
                    truncated_prefix = output_file_name_wo_prefix[:3]
                    on_xml_file = "on_" + truncated_prefix
                    out_files = self.input_params["transformer"].run(
                         input_file_path,
                         self.input_params["main_config"].get_ontoxml_output_folder() + on_xml_file ,
                         pipe_path
                         )
                else:
                    print _COLOR.WARNING, "No pipeline defined for content type %s " % pipe_type, _COLOR.ENDC
                return (False, None)
            else:
                print "Ignoring %s" % input_file_path
                return (False, None)
        else:
            return (False,None)


class RepoSyncUploader(object):
    """
    
    Pushes XML files one-by-one into eXist server from reposync.xml list of items
    """
    def __init__(self, input_params):
        self.input_params = input_params
        self.main_cfg = input_params["main_config"]
        self.webdav_cfg = input_params["webdav_config"]
        self.bunparse = ParseXML(self.main_cfg.get_temp_files_folder()+"reposync.xml")
        self.bunparse.doc_parse()
        try:
            self.dom = self.bunparse.doc_dom()
        except DocumentException, e:
            print _COLOR.FAIL, e, '\nERROR: reposync.xml is not generated. Run with `-s` switch to sync with repository first.', _COLOR.ENDC
            sys.exit()

    def upload_file(self, on_file):
        self.username = self.webdav_cfg.get_username()
        self.password = self.webdav_cfg.get_password()
        self.xml_folder = self.webdav_cfg.get_http_server_port()+self.webdav_cfg.get_bungeni_xml_folder()
        webdaver = WebDavClient(self.username, self.password, self.xml_folder)
        up_stat = webdaver.pushFile(str(on_file))
        return up_stat

    def upload_files(self):
        coll = self.dom.selectSingleNode("//collection")
        paths = coll.elements("file")
        for path in paths:
            path_name = path.getText()
            self.username = self.webdav_cfg.get_username()
            self.password = self.webdav_cfg.get_password()
            self.xml_folder = self.webdav_cfg.get_http_server_port()+self.webdav_cfg.get_bungeni_xml_folder()
            webdaver = WebDavClient(self.username, self.password, self.xml_folder)
            webdaver.pushFile(path_name)


class ProcessedAttsFilesWalker(GenericDirWalkerATTS):
    """
    
    Pushes Attachment files one-by-one into eXist server
    """
    def __init__(self, input_params = None):
        """
        input_params - the parameters for the callback function
        """
        super(GenericDirWalkerATTS, self).__init__()
        self.webdav_cfg = input_params["webdav_config"]

    """
    
    For uploading Attachment files but able to break and return if upload error is detected,
    useful to flag the current uploading to be left in queue
    """
    def process_atts(self, folder_path):
        upload_stat = False
        atts_present = False
        listing = os.listdir(folder_path)
        for att in listing:
            atts_present = True
            att_path = os.path.join(folder_path, att)
            LOG.debug("uploading file : " + att_path)
            try:
                self.username = self.webdav_cfg.get_username()
                self.password = self.webdav_cfg.get_password()
                self.xml_folder = self.webdav_cfg.get_http_server_port()+self.webdav_cfg.get_bungeni_atts_folder()
                webdaver = WebDavClient(self.username, self.password, self.xml_folder)
                up_info_obj = webdaver.pushFile(att_path)
                if up_info_obj == True:
                    upload_stat = True
                else:
                    upload_stat = False
            except HttpHostConnectException, e:
                print _COLOR.FAIL, e.printStackTrace(), _COLOR.ENDC
                break
        if atts_present == False:
            return True
        print "[checkpoint] ATTS upload"
        if upload_stat == True:
            return upload_stat
        else:
            return False

    def fn_callback(self, input_file_path):
        if GenericDirWalkerATTS.fn_callback(self, input_file_path)[0] == True:
            try:
                self.username = self.webdav_cfg.get_username()
                self.password = self.webdav_cfg.get_password()
                self.xml_folder = self.webdav_cfg.get_http_server_port()+self.webdav_cfg.get_bungeni_atts_folder()
                webdaver = WebDavClient(self.username, self.password, self.xml_folder)
                webdaver.pushFile(input_file_path)
                return (False, None)
            except SardineException, e:
                print _COLOR.FAIL, e.printStackTrace(), _COLOR.ENDC
                return (False, None)
            except HttpHostConnectException, e:
                print _COLOR.FAIL, e.printStackTrace(), _COLOR.ENDC
                return (False, None)
        else:
            return (False,None)


class SyncXmlFilesWalker(GenericDirWalkerXML):
    """
    
    Synchronizes XML files one-by-one with the eXist XML repository
    """
    def __init__(self, input_params = None):
        """
        input_params - the parameters for the callback function
        """
        super(GenericDirWalkerXML, self).__init__()
        self.main_cfg = input_params["main_config"]
        self.webdav_cfg = input_params["webdav_config"]
        self.transformer = Transformer(self.main_cfg)

    def create_sync_file(self):
        OutputFormat.createPrettyPrint()
        self.format = OutputFormat.createCompactFormat()
        self.document = DocumentFactory.getInstance().createDocument()
        self.root = self.document.addElement("collection")
        self.root.addAttribute("name", "synclist")
        return self.root

    def add_item_to_repo(self,repo_bound_file):
        name = self.root.addElement("file")
        name.addText(repo_bound_file)

    def close_sync_file(self):
        self.format = OutputFormat.createPrettyPrint()
        self.writer = XMLWriter(FileWriter(self.main_cfg.get_temp_files_folder()+"reposync.xml"), self.format)
        self.writer.write(self.document)
        self.writer.flush()
        self.writer.close()

    def get_params(self, input_file):
        return self.transformer.get_doc_params(input_file)

    def get_sync(self, input_file):
        return self.transformer.get_sync_status(input_file)

    def sync_file(self, input_file_path):
        """
        Calls a service on the eXist repository requesting status of file with 
        the given URI + status_date. Depending on response, adds it to a list of 
        documents that need to be uploaded to repository.
        """
        file_uri = self.get_params(input_file_path)['uri']
        file_stat_date = self.get_params(input_file_path)['status_date']
        import urllib2
        try:
            socket.setdefaulttimeout(60)
            conn = httplib.HTTPConnection(self.webdav_cfg.get_server(),self.webdav_cfg.get_port(),60)
            conn.request("GET", "/exist/apps/framework/bungeni/check-update?uri=" + file_uri+"&t=" + file_stat_date)
            response = conn.getresponse()
            if(response.status == 200):
                data = response.read()
                if(self.get_sync(data) != 'ignore'):
                    # !+NOTE without adding str in str(input_file_path), the compiler just stopped execution and went silent!
                    print _COLOR.WARNING, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(str(input_file_path)), _COLOR.ENDC
                    # 'ignore' means that its in the repository so we add anything that that is not `ignore` to the reposync list
                    self.add_item_to_repo(str(input_file_path))
                    LOG.debug( data )
                    return (True, file_uri)
                else:
                    print _COLOR.OKGREEN, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(str(input_file_path)), _COLOR.ENDC
                    return (True, None)
            else:
                print _COLOR.FAIL, os.path.basename(input_file_path), response.status, response.reason, _COLOR.ENDC
                return (False, None)
            conn.close()
        except socket.timeout:
            print _COLOR.FAIL, '\nERROR: eXist socket.timedout at sync file... back to MQ', _COLOR.ENDC
            return (False, None)
        except urllib2.URLError, e:
            print _COLOR.FAIL, e, '\nERROR: eXist URLError.timedout at sync file... back to MQ', _COLOR.ENDC
            return (False, None)
        except socket.error, (code, message):
            print _COLOR.FAIL, code, message, '\nERROR: eXist is NOT runnning OR Wrong config info', _COLOR.ENDC
            return (False, None)


    def fn_callback(self, input_file_path):
        """
        Calls a service on the eXist repository requesting status of file with 
        the given URI + status_date. Depending on response, adds it to a list of 
        documents that need to be uploaded to repository.
        """
        if GenericDirWalkerXML.fn_callback(self, input_file_path)[0] == True:
            file_uri = self.get_params(input_file_path)['uri']
            file_stat_date = self.get_params(input_file_path)['status_date']
            #statinfo = os.stat(input_file_path)
            #headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "application/xml"}
            try:
                conn = httplib.HTTPConnection(self.webdav_cfg.get_server(),self.webdav_cfg.get_port(),50)
                conn.request("GET", "/exist/apps/framework/bungeni/check-update?uri=" + file_uri+"&t=" + file_stat_date)
                response = conn.getresponse()
                if(response.status == 200):
                    data = response.read()
                    if(self.get_sync(data) != 'ignore'):
                        print _COLOR.WARNING, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(input_file_path), _COLOR.ENDC
                        # 'ignore' means that its in the repository so we add anything that that is not `ignore` to the reposync list
                        self.add_item_to_repo(input_file_path)
                        LOG.debug( data )
                    else:
                        print _COLOR.OKGREEN, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(input_file_path), _COLOR.ENDC
                else:
                    print _COLOR.FAIL, os.path.basename(input_file_path), response.status, response.reason, _COLOR.ENDC
                conn.close()
            except socket.error, (code, message):
                print _COLOR.FAIL, code, message, '\nERROR: eXist is NOT runnning OR Wrong config info', _COLOR.ENDC
                sys.exit()

            return (False, None)
        else:
            return (False,None)


class WebDavConfig(Config):
    """
    Configuration information for eXist WebDav
    """

    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}
    
    def get_bungeni_xml_folder(self):
        return self.get("webdav", "bungeni_xml_folder")

    def get_bungeni_atts_folder(self):
        return self.get("webdav", "bungeni_atts_folder")

    def get_fw_i18n_folder(self):
        return self.get("webdav", "framework_i18n_folder")

    def get_username(self):
        return self.get("webdav", "username")
    
    def get_password(self):
        return self.get("webdav", "password")

    def get_server(self):
        return self.get("webdav", "server")

    def get_port(self):
        return int(self.get("webdav", "port"))

    def get_http_server_port(self):
        return "http://"+self.get_server()+":"+str(self.get_port())

class WebDavClient(object):
    """        
    Connects to eXist via WebDav and finally places the files to rest.
    """
    def __init__(self, username, password, put_folder = None):
        self.put_folder = put_folder
        self.sardine = SardineFactory.begin(username, password)

    def reset_remote_folder(self, put_folder):
        try:
            if self.sardine.exists(put_folder) is False:
                print _COLOR.WARNING + "INFO: " + put_folder + " folder wasn't there !" + _COLOR.ENDC            
                self.sardine.createDirectory(put_folder)
        except SardineException, e:
            print _COLOR.FAIL, e.printStackTrace(), "\nERROR: Resource / Collection fault." , _COLOR.ENDC
            sys.exit()
        except HttpHostConnectException, e:
            print _COLOR.FAIL, e.printStackTrace(), "\nERROR: Clues... eXist is NOT runnning OR Wrong config info" , _COLOR.ENDC
            sys.exit()

    def pushFile(self, onto_file):
        try:
            a_file = File(onto_file)
        except Exception, E:
            print _COLOR.FAIL, E, '\nERROR: E While processing xml ', onto_file, _COLOR.ENDC
        try:
            inputStream = FileInputStream(a_file)
            length = a_file.length()
            bytes = jarray.zeros(length,'b')
            #Read in the bytes
            #http://www.flexonjava.net/2009/08/jython-convert-file-into-byte-array.html
            offset = 0
            numRead = 0
            while offset<length:
                if numRead>= 0:
                    #print numRead #For debugging
                    numRead=inputStream.read(bytes, offset, length-offset)
                    offset = offset + numRead
                    
            try:
                self.sardine.put(self.put_folder+os.path.basename(onto_file), bytes)
                print "PUT: "+self.put_folder+os.path.basename(onto_file)
                return True
            except SardineException, e:
                print _COLOR.FAIL, e.printStackTrace(), "\nERROR: Check eXception thrown for more." , _COLOR.ENDC
                return False
            except HttpHostConnectException, e:
                print _COLOR.FAIL, e.printStackTrace(), "\nERROR: Clues... eXist is NOT runnning OR Wrong config info" , _COLOR.ENDC
                sys.exit()
            finally:
                inputStream.close()
        except FileNotFoundException, e:
            print _COLOR.FAIL, e.getMessage(), "\nERROR: File deleted since last synchronization. Do a re-sync before uploading" , _COLOR.ENDC
            return True

class PoTranslationsConfig(Config):
    """
    Configuration information for .po translation files
    """
    
    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}

    def get_po_files_folder(self):
        return self.get("translations", "po_files_folder")

    def get_po_listing(self):
        return self.items("messages")

    def get_i18n_catalogues_folder(self):
        return self.get("translations", "i18n_catalogues_folder")


class PostTransform(object):
    """
    
    Updates signatories, workflowEvents and groupsitting items in the eXist repository
    
    http://www.voidspace.org.uk/python/articles/authentication.shtml
    """
    def __init__(self, input_params = None):
        self.webdav_cfg = input_params["webdav_config"]

    def update(self, uri = None):
        #socket.setblocking(0) #set to non-blocking mode
        socket.setdefaulttimeout(60) #timeout of 30 seconds
        import urllib2
        try:
            xqyurl = self.webdav_cfg.get_http_server_port()+'/exist/apps/framework/postproc-exec.xql?uri='+str(uri)
            username = self.webdav_cfg.get_username()
            password = self.webdav_cfg.get_password()

            #conjure a password manager
            passmngr = urllib2.HTTPPasswordMgrWithDefaultRealm()
            passmngr.add_password(None, xqyurl, username, password)
            # create the AuthHandler
            authhandler = urllib2.HTTPBasicAuthHandler(passmngr)
            opener = urllib2.build_opener(authhandler)
            urllib2.install_opener(opener)

            response = urllib2.urlopen(xqyurl)
            print _COLOR.OKGREEN + response.read() + _COLOR.ENDC
            return True
        except urllib2.URLError, e:
            print _COLOR.FAIL, e, '\nERROR: eXist timedout URLError', _COLOR.ENDC
            return False
        except socket.timeout:
            print _COLOR.FAIL, '\nERROR: eXist timedout TIMEOUTError', _COLOR.ENDC
            return False
        except urllib2.HTTPError, err:
            print _COLOR.FAIL, err.code, err.msg, ': ERROR: While running PostTransform', _COLOR.ENDC
            return False

class POFilesTranslator(object):
    """
    
    Translates the PO files one-by-one into XML catalogue format 
    palatable for i18n module in eXist-db
    
    pescape_key() & pescape_value() are based on this nifty script
    https://raw.github.com/fileformat/lptools/master/po2prop.py
    """ 
    def __init__(self, input_params = None):
        self.main_cfg = input_params["main_config"]
        self.po_cfg = input_params["po_config"]
        self.webdav_cfg = input_params["webdav_config"]
        self.download_po_files()

    def download_po_files(self):
        """
        Retrieves the .po files from a remote location and stores them in a local folder
        for translation to xml i18n catalogue
        """
        socket.setdefaulttimeout(20)
        from urllib2 import Request, urlopen, URLError, HTTPError
        print _COLOR.OKGREEN + "Downloading .po files..." + _COLOR.ENDC
        #return list of po link in the messages configuration
        msgs_list = self.po_cfg.get_po_listing()
        for iso_name, uri in msgs_list:
            try:
                f = urlopen(uri)
                print iso_name + "-downloading from " + uri
                local_file = open(self.po_cfg.get_po_files_folder()+iso_name+".po", "wb")
                local_file.write(f.read())
                local_file.close()
            except HTTPError, e:
                print _COLOR.FAIL, "HTTP Error: ", e.code , uri, _COLOR.ENDC
            except URLError, e:
                print _COLOR.FAIL, "URL Error: ", e.reason, uri, _COLOR.ENDC
        print _COLOR.OKGREEN + "Downloads finished... Now translating" + _COLOR.ENDC

    def pescape_key(self, orig):
        import string
        result = ""
        if orig[0] == '#' or orig[0] == '!':
            result = result + "\\"
        
        for ch in orig:
            if ch == ':':
                result = result + "\\:"
            elif ch == '=':
                result = result + "\\="
            elif ch == '\r':
                result = result + "\\r"
            elif ch == '\n':
                result = result + "\\n"
            else:
                result = result + ch
            
        return result

    def pescape_value(self, orig):
        result = ""
        for ch in orig:
            if ch == ':':
                result = result + "\\:"
            elif ch == '=':
                result = result + "\\="
            elif ch == '\r':
                result = result + "\\r"
            elif ch == '\n':
                result = result + "\\n"
            else:
                result = result + ch
        return result

    def create_catalogue_file(self, iso):
        OutputFormat.createPrettyPrint()
        self.format = OutputFormat.createCompactFormat()
        self.document = DocumentFactory.getInstance().createDocument()
        self.root = self.document.addElement("catalogue")
        self.root.addAttribute("xml:lang", iso)
        return self.root

    def add_msgs_to_catalogue(self,po_file):
        import polib
        po = polib.pofile(po_file, autodetect_encoding=False, encoding="utf-8", wrapwidth=-1)
        for entry in po:
            if entry.obsolete or entry.msgstr == '' or entry.msgstr == entry.msgid:
                continue
            name = self.root.addElement("msg")
            name.addAttribute("key",self.pescape_key(entry.msgid))
            name.addText(self.pescape_value(entry.msgstr))

    def close_catalogue_file(self, lang):
        self.format = OutputFormat.createPrettyPrint()
        self.writer = XMLWriter(FileWriter(self.po_cfg.get_i18n_catalogues_folder()+"po_collection_"+lang+".xml"), self.format)
        self.writer.write(self.document)
        self.writer.flush()
        self.writer.close()

    def po_to_xml_catalogue(self):
        po_files = os.listdir(os.path.join(self.po_cfg.get_po_files_folder()))
        for po_file in po_files:
            file_x_ext = os.path.splitext(po_file)[0] #remove extension
            self.create_catalogue_file(file_x_ext)
            self.add_msgs_to_catalogue(self.po_cfg.get_po_files_folder()+po_file)
            self.close_catalogue_file(file_x_ext)
            print "translated " + po_file

    def upload_catalogues(self):
        catalogues = os.listdir(os.path.join(self.po_cfg.get_i18n_catalogues_folder()))
        for catalogue in catalogues:
            self.username = self.webdav_cfg.get_username()
            self.password = self.webdav_cfg.get_password()
            self.xml_folder = self.webdav_cfg.get_http_server_port()+self.webdav_cfg.get_fw_i18n_folder()
            webdaver = WebDavClient(self.username, self.password, self.xml_folder)
            webdaver.pushFile(self.po_cfg.get_i18n_catalogues_folder()+catalogue)

def __empty_output_dir__(folder):
    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            os.unlink(file_path)
        except Exception, e:
            print e

def mkdir_p(path):
    try:
        os.makedirs(path)
    except os.error : # Python >2.5
        if os.error.errno == errno.EEXIST:
            pass
        else: raise

def __setup_tmp_dirs__(cfg):

    if not os.path.isdir(cfg.get_po_files_folder()):
        mkdir_p(cfg.get_po_files_folder())

    if not os.path.isdir(cfg.get_i18n_catalogues_folder()):
        mkdir_p(cfg.get_i18n_catalogues_folder())

def __setup_output_dirs__(cfg):

    if not os.path.isdir(cfg.get_akomantoso_output_folder()):
        mkdir_p(cfg.get_akomantoso_output_folder())
    else:
        __empty_output_dir__(cfg.get_akomantoso_output_folder())        
    if not os.path.isdir(cfg.get_ontoxml_output_folder()):
        mkdir_p(cfg.get_ontoxml_output_folder())
    else:
        __empty_output_dir__(cfg.get_ontoxml_output_folder())
    if not os.path.isdir(cfg.get_attachments_output_folder()):
        mkdir_p(cfg.get_attachments_output_folder())
    else:
        __empty_output_dir__(cfg.get_attachments_output_folder())
    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())

def get_parl_info(cfg):
    piw = ParliamentInfoWalker({"main_config":cfg})
    """
    Check first if we have a cached copy
    """
    if os.path.isfile(cfg.get_temp_files_folder() + __parl_info__):
        return piw.get_from_cache(cfg.get_temp_files_folder() + __parl_info__)
    else:
        piw.walk(cfg.get_input_folder())
        if piw.object_info is None:
            return False
        else:
            return piw.object_info

def do_bind_attachments(cfg):
    # first we unzip the attachments using the GenericDirWalkerUNZIP 
    # so we get xml + attachments in a sub-folder
    unzipwalker = GenericDirWalkerUNZIP()
    unzipwalker.walk(cfg.get_input_folder())
    # Now the files are unzipped in sub-folders - so we process the XML 
    # for the attachments, the attachments are renamed to a unique id
    # and the reference reset in the source document
    sba = SeekBindAttachmentsWalker({"main_config":cfg})
    sba.walk(cfg.get_input_folder())
    if sba.object_info is not None:
        print _COLOR.OKBLUE,"ATT: Found attachment ", _COLOR.ENDC
    else:
        return sba.object_info

def do_po_translations(cfg, po_cfg, wd_cfg):
    """ translating .po files """
    print _COLOR.OKGREEN + "Translating .po files to i18n xml <catalogue/> format..." + _COLOR.ENDC
    pofw = POFilesTranslator({"main_config":cfg, "po_config" : po_cfg, "webdav_config" : wd_cfg})
    pofw.po_to_xml_catalogue()
    print _COLOR.OKGREEN + "Completed translations from po to xml !" + _COLOR.ENDC
    print _COLOR.OKGREEN + "Commencing i18n catalogues upload to eXist-db via WebDav..." + _COLOR.ENDC
    pofw.upload_catalogues()
    print _COLOR.OKGREEN + "Catalogues uploaded to eXist-db !" + _COLOR.ENDC

def do_transform(cfg, parl_info):
    transformer = Transformer(cfg)
    transformer.set_params(parl_info)
    print _COLOR.OKGREEN + "Commencing transformations..." + _COLOR.ENDC
    pxf = ProcessXmlFilesWalker({"main_config":cfg, "transformer":transformer})
    pxf.walk(cfg.get_input_folder())
    print _COLOR.OKGREEN + "Completed transformations !" + _COLOR.ENDC

def do_sync(cfg, wd_cfg):
    print _COLOR.OKGREEN + "Syncing with eXist repository..." + _COLOR.ENDC
    """ synchronizing xml documents """
    sxw = SyncXmlFilesWalker({"main_config":cfg, "webdav_config" : wd_cfg})

    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())

    sxw.create_sync_file()
    sxw.walk(cfg.get_ontoxml_output_folder())
    sxw.close_sync_file()
    print _COLOR.OKGREEN + "Completed synching to eXist !" + _COLOR.ENDC

def webdav_upload(cfg, wd_cfg):
    print _COLOR.OKGREEN + "Commencing XML files upload to eXist via WebDav..." + _COLOR.ENDC
    """ uploading xml documents """
    # first reset bungeni xmls folder
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_xml_folder())
    # upload xmls at this juncture
    rsu = RepoSyncUploader({"main_config":cfg, "webdav_config" : wd_cfg})
    rsu.upload_files()
    print _COLOR.OKGREEN + "Commencing ATTACHMENT files upload to eXist via WebDav..." + _COLOR.ENDC
    """ now uploading found attachments """
    # first reset attachments folder
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_atts_folder())
    # upload attachments at this juncture
    pafw = ProcessedAttsFilesWalker({"main_config":cfg, "webdav_config" : wd_cfg})
    pafw.walk(cfg.get_attachments_output_folder())
    print _COLOR.OKGREEN + "Completed uploads to eXist !" + _COLOR.ENDC

def main_po_translate(config_file):
    """
    accepts the --po2xml option to translate .po files to i18n catalogue scheme
    used in the eXist-db
    """
    po_cfg = PoTranslationsConfig(config_file)
    wd_cfg = WebDavConfig(config_file)
    #ensure the tmp folder and its children are there or create them
    __setup_tmp_dirs__(po_cfg)
    do_po_translations(TransformerConfig(config_file), po_cfg, wd_cfg)


def main_transform(config_file):
    """
    process the -transform option by running the transformation
    """
    cfg = TransformerConfig(config_file)
    # create the output folders
    __setup_output_dirs__(cfg)
    print _COLOR.HEADER + "Retrieving parliament information..." + _COLOR.ENDC
    # look for the parliament document - and get the info which is used in the
    # following transformations
    parl_info = get_parl_info(cfg)
    if parl_info == False:
        print _COLOR.FAIL,"ERROR: Could not find Parliament info :(", _COLOR.ENDC
        sys.exit()
    print _COLOR.OKGREEN,"Retrieved Parliament info...", parl_info, _COLOR.ENDC
    print _COLOR.OKGREEN + "Seeking attachments..." + _COLOR.ENDC
    do_bind_attachments(cfg)
    print _COLOR.OKGREEN + "Done with attachments..." + _COLOR.ENDC
    print _COLOR.HEADER + "Transforming ...." + _COLOR.ENDC      
    do_transform(cfg, parl_info)


def main_sync(config_file):
    wd_cfg = WebDavConfig(config_file)
    do_sync(TransformerConfig(config_file), wd_cfg)


def main_upload(config_file):
    """
    process the --upload option by calling the webdav upload
    """
    wd_cfg = WebDavConfig(config_file)
    webdav_upload(TransformerConfig(config_file), wd_cfg)

def update_refs(config_file):
    wd_cfg = WebDavConfig(config_file)
    print _COLOR.OKGREEN + "Commencing Repository updates..." + _COLOR.ENDC
    pt = PostTransform({"webdav_config": wd_cfg})
    pt.update()

def __md5_file(f, block_size=2**20):
    """
    Gets the md5sum for a file
    """
    import hashlib
    md5 = hashlib.md5()
    while True:
        data = f.read(block_size)
        if not data:
            break
        md5.update(data)
    return md5.digest()

def list_uniqifier(seq):
    #http://www.peterbe.com/plog/uniqifiers-benchmark
    # wary or RabbitMQ producer giving us duplicates in cases of overwriting a file 
    # pyinotify would register two events of the same thing. So uncool! :@
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if x not in seen and not seen_add(x)]

def main_queue(config_file, afile):
    """
    Serially processes XML/ZIP files from the message queue and 
    uploads to XML repository. Returns True/False to consumer
        True = Remove from queue
        False = Retain in queue for whatever reason
    
    @param config_file  configuration file
    @param afile        path to the serialized file
    
    @return Boolean 
    """
    print "[checkpoint] got file " + afile
    script_path = os.path.dirname(os.path.realpath(__file__))
    PropertyConfigurator.configure(script_path + File.separator + "log4j.properties")
    # comment above lines to run in emotional mode
    cfg = TransformerConfig(config_file)
    # create the output folders
    __setup_output_dirs__(cfg)
    wd_cfg = WebDavConfig(config_file)
    in_queue = False
    """
    Get parliament information
    """
    print "[checkpoint] getting parliament info"
    parl_info = get_parl_info(cfg)
    if parl_info == False:
        return in_queue
    transformer = Transformer(cfg)
    transformer.set_params(parl_info)
    cfgs = {"main_config":cfg, "transformer":transformer, "webdav_config" : wd_cfg}
    pxf = ProcessXmlFilesWalker(cfgs)
    """
    Do Unzipping and Transformations
    """
    import fnmatch
    if os.path.isfile(afile):
        """
        Copy afile to temp_files_folder as working-copy(wc_afile)
        """
        temp_dir = cfg.get_temp_files_folder()
        wc_afile = temp_dir + os.path.basename(afile)
        shutil.copyfile(afile, wc_afile)
        print "[checkpoint] copied working-copy to temp folder"
        
        if fnmatch.fnmatch(afile, "*.zip") and os.path.isfile(wc_afile):
            print "[checkpoint] unzipping archive files"
            unzip = GenericDirWalkerUNZIP()
            temp_dir = cfg.get_temp_files_folder()
            unzip.extractor(afile, temp_dir)
            xml_basename = os.path.basename(wc_afile)
            xml_name = os.path.splitext(xml_basename)[0]
            new_afile = temp_dir + xml_name + ".xml"
            if os.path.isfile(new_afile):
                print "[checkpoint] found the unzipped XML file"
                # if there is an XML file inside then we have process its atts
                # descending upon the extracted folder
                bunparse = ParseBungeniXML(new_afile)
                parse_ok = bunparse.doc_parse()
                if parse_ok == False:
                    # Parsing error return to queue
                    return False
                print "[checkpoint] unzipped file parsed"
                sba = SeekBindAttachmentsWalker(cfgs)
                image_node = bunparse.get_image_file()
                if (image_node is not None):
                    print "[checkpoint] entered user doc path"
                    local_dir = os.path.dirname(afile)
                    print "Has profile image. Will process image node"
                    origi_name = sba.image_seek_rename(bunparse, temp_dir, True)
                else:
                    print "[checkpoint] entered non-user doc path"
                    sba.attachments_seek_rename(bunparse)

                print "[checkpoint] transforming the xml with zipped files"
                info_object = pxf.process_file(new_afile)
                # remove unzipped new_afile & wc_afile from temp_files_folder
                os.remove(new_afile)
                os.remove(wc_afile)
                if info_object[1] == True:
                    in_queue = True
                elif info_object[1] == False:
                    in_queue = False
                    return in_queue
                elif info_object[1] == None:
                    # mark parl-information document for removal from message-queue
                    in_queue = True
                    return in_queue
                else:
                    print _COLOR.WARNING, "No pipeline defined here ", _COLOR.ENDC
                    in_queue = False
                    return in_queue
            else:
                print "[checkpoint] extracted " + new_afile + "] but not found :-J"
                in_queue = True
                return in_queue
        elif fnmatch.fnmatch(afile, "*.xml") and os.path.isfile(wc_afile):
            print "[checkpoint] transforming the xml"
            info_object = pxf.process_file(wc_afile)
            # remove wc_afile from temp_files_folder
            os.remove(wc_afile)
            if info_object[1] == True:
                print "[checkpoint] transformed the xml"
                in_queue = True
            elif info_object[1] == False:
                in_queue = False
                return in_queue
            elif info_object[1] == None:
                # mark parl-information document for removal from message-queue
                in_queue = True
                return in_queue
            else:
                print _COLOR.WARNING, "No pipeline defined here ", _COLOR.ENDC
                in_queue = False
                return in_queue
        else:
            # ignore any other file type, not interested with them currently...
            print "[" + afile + "] ignoring unprocessable filetype"
            in_queue = True
            return in_queue
    else:
        print "[" + afile + "] not found in filesystem"
        in_queue = True
        return in_queue

    """
    Do sync step
    """
    print "[checkpoint] entering sync"
    sxw = SyncXmlFilesWalker(cfgs)
    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())
    sxw.create_sync_file()
    # reaching here means there is a successfull file
    sync_stat_obj = sxw.sync_file(info_object[0])
    sxw.close_sync_file()
    print "[checkpoint] exiting sync"
    if sync_stat_obj[0] == True and sync_stat_obj[1] == None:
        # ignore upload -remove from queue
        in_queue = True
        return in_queue
    elif sync_stat_obj[0] == True:
        in_queue = True
    else:
        # eXist not responding?!
        # requeue and try later
        in_queue = False
        return in_queue

    """
    Do uploading to eXist
    """
    print _COLOR.OKGREEN + "Uploading XML file(s) to eXist via WebDav..." + _COLOR.ENDC
    print "[checkpoint] at", time.localtime(time.time())
    # first reset bungeni xmls folder
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_xml_folder())
    rsu = RepoSyncUploader({"main_config":cfg, "webdav_config" : wd_cfg})
    print "[checkpoint] uploading XML file"
    if in_queue == True:
        upload_stat = rsu.upload_file(info_object[0])
    else:
        in_queue = False
        return in_queue

    print _COLOR.OKGREEN + "Uploading ATTACHMENT file(s) to eXist via WebDav..." + _COLOR.ENDC
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_atts_folder())
    # upload attachments at this juncture
    pafw = ProcessedAttsFilesWalker({"main_config":cfg, "webdav_config" : wd_cfg})
    info_obj = pafw.process_atts(cfg.get_attachments_output_folder())
    if info_obj == True:
        in_queue = True
    else:
        return False
    print _COLOR.OKGREEN + "Completed upload to eXist!" + _COLOR.ENDC
    # do post-transform
    """
    !+FIX_THIS (ao,8th Aug 2012) PostTransform degenerates and becomes and expensive process 
    over-time temporarily disabled.
    """
    pt = PostTransform({"webdav_config": wd_cfg})
    print "Initiating PostTransform request on eXist-db for URI =>", sync_stat_obj[1]
    info_object = pt.update(str(sync_stat_obj[1]))
    
    if info_object == True:
        in_queue = True
    else:
        in_queue = False
    return in_queue

def main(options):
    # parse command line options if any
    try:
        # first get the configuration file from the command line
        config_file = __parse_options(options, ("-c", "--config"))
        # transform and upload are independent options and can be called individually
        if config_file is not None and len(str(config_file)) > 0 :

            translate = __parse_options(options, ("-p", "--po2xml"))
            if translate is not None:
                main_po_translate(config_file)

            transform = __parse_options(options, ("-t", "--transform"))
            if transform is not None:
                main_transform(config_file)

            sync = __parse_options(options, ("-s", "--synchronize"))
            if sync is not None:
                #perform sync at this juncture
                main_sync(config_file)

            upload = __parse_options(options, ("-u", "--upload"))
            if upload is not None:
                main_upload(config_file)
                # perform post-transform URI reference fixes if any
                update_refs(config_file)
            else:
                print "upload not specified"
        else:
            print _COLOR.FAIL," config.ini specified incorrectly !",_COLOR.ENDC
    except getopt.error, msg:
        print msg
        print _COLOR.FAIL + "There was an exception during startup !" + _COLOR.ENDC
        sys.exit(2)
        
        
def __parse_options(options, look_for=()):
    input_arg = None
    for opt,arg in options:
        if opt in look_for:
            input_arg = arg
    return input_arg

if __name__ == "__main__":
    """
    Five command line parameters are supported
    
      --config=config_file_name - specifies the config file name
      --po2xml - translates po files to xml for i18n in eXisd-db
      --transform - runs a transform
      --synchronize - synchronizes with a xml db
      --upload - uploades to a xml db
    """
    
    script_path = os.path.dirname(os.path.realpath(__file__))
    if (len(sys.argv) > 1):
        #from org.apache.log4j import PropertyConfigurator
        PropertyConfigurator.configure(script_path + File.separator + "log4j.properties")
        # process input command line options
        options, remainder = getopt.getopt(sys.argv[1:], 
          "c:ptsu",
          ["config=", "po2xml","transform","synchronize","upload"]
        )
        # call main
        main(options)
    else:
        print _COLOR.FAIL , " config.ini file must be an input parameter " , _COLOR.ENDC
