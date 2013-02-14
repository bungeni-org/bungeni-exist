""" 

    REQUIRES : Jython , NOT Python

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
import os.path, sys, errno, getopt, shutil
import time
import jarray

__author__ = "Ashok Hariharan and Anthony Oduor"
__copyright__ = "Copyright 2011, Bungeni"
__license__ = "GNU GPL v3"
__version__ = "1.4.0"
__maintainer__ = "Anthony Oduor"
__created__ = "18th Oct 2011"
__status__ = "Development"

__parl_info__ = "parliament_info.xml"
__repo_sync__ = "reposync.xml"

__sax_parser_factory__ = "org.apache.xerces.jaxp.SAXParserFactoryImpl"

from org.dom4j import (
    DocumentFactory,
    DocumentException,
    DocumentHelper
    )

from org.dom4j.io import (
    SAXReader,
    OutputFormat,
    XMLWriter
    )

from java.io import (
    File, 
    FileWriter, 
    InputStreamReader
    )


from org.apache.http.conn import HttpHostConnectException
from org.apache.commons.codec.binary import Base64

from com.googlecode.sardine.impl import SardineException

from java.net import (
    MalformedURLException,
    URL
    )

from java.lang import (
    String,
    )


from org.apache.log4j import (
    PropertyConfigurator,
    Logger
    )
### APP Imports ####

from configs import (
    Config,
    TransformerConfig,
    WebDavConfig
    )

from utils import (
    _COLOR, 
    close_quietly,
    WebDavClient,
    Transformer
    )

from parsers import (
    ParseXML,
    ParseBungeniXML
    )

from walker import (
    GenericDirWalkerXML,
    GenericDirWalkerATTS,
    GenericDirWalkerUNZIP
    )


LOG = Logger.getLogger("glue")




class ParliamentInfoWalker(GenericDirWalkerXML):
    """
    Walker that retrieves the info about the parliament
    """
    
    def __init__(self, input_params = None):
        super(ParliamentInfoWalker, self).__init__(input_params)
        # check if the system is setup for unicameral or bicameral 
        self.bicameral = self.input_params["main_config"].get_bicameral()
        self.cache_file = self.input_params["main_config"].get_temp_files_folder() + __parl_info__
        self.camera_count = 0
        self.parliament_docs = {}
    
    """
    The system can have 2 parliaments, so the assumption is if bicameral is = True
    There can be 2 chambers.
    
    """

    def get_from_cache(self, input_file_path):
        bunparse = ParseBungeniXML(input_file_path)
        bunparse.doc_parse()
        the_parl_doc = bunparse.get_parliament_info(
                self.input_params["main_config"].get_country_code()
                )
        return the_parl_doc


    def is_cache_full(self):
        """
        Check if cache has more than one document
        """
        if os.path.exists(self.cache_file):
            reader = SAXReader()
            cache_doc = reader.read(
                File(self.cache_file)            
            )
            list_of_cached_nodes = cache_doc.selectNodes("//cachedTypes/contentType")
            if self.bicameral:
                if list_of_cached_nodes == 0:
                    return False
                if list_of_cached_nodes == 1:
                    return True
                return False
            else:
                if list_of_cached_nodes == 0:
                    return False
                if list_of_cached_nodes == 1:
                    return False
                if list_of_cached_nodes == 2:
                    return True
                return False
        return False 
                
        

    def new_cache_document(self):
        """
        Creates a new empty cache document and saves it to disk
        """
        cache_doc = DocumentHelper.createDocument()
        cache_doc.addElement("cachedtypes")
        self.write_cache_doc_to_file(cache_doc)

    def new_cache(self, input_file):
        """
        Takes the input file, creates a new empty cache document, 
        and adds the input file to the cache 
        """
        self.new_cache_document()
        reader = SAXReader()
        new_doc = reader.read(
            File(input_file)
        )
        element_to_import = new_doc.getRootElement()
        self.append_element_into_cache_document(element_to_import)

    def write_cache_doc_to_file(self, cache_doc):
        fw = FileWriter(self.cache_file)
        cache_doc.write(fw)
        
    def append_to_cache(self, input_file):
        reader = SAXReader()
        new_doc = reader.read(
            File(input_file)
        )
        
        element_to_import = new_doc.getRootElement()
        self.append_element_into_cache_document(element_to_import)

    def append_element_into_cache_document(self, element_to_import):
        reader = SAXReader()
        cache_doc = reader.read(
            File(self.cache_file)
            )
        cache_doc.importNode(element_to_import, True)
        cache_doc.getRootElement().addElement(
            element_to_import
            )
        self.write_cache_doc_to_file(cache_doc)    
   
    def fn_callback(self, input_file_path):
        if GenericDirWalkerXML.fn_callback(self, input_file_path)[0] == True:
            bunparse = ParseBungeniXML(input_file_path)
            bunparse.doc_parse()
            # check if its a parliament document
            the_parl_doc = bunparse.get_parliament_info(
                    self.input_params["main_config"].get_country_code()
                    )
            if the_parl_doc is not None:
                """
                Create a cached copy in tmp folder defined in config.ini for quick access 
                in the current parliament's future transformation processes
                """
                # check if file exists , if it exists there is already a parliament in the
                # cache 
                from os import path
                if path.exists(self.cache_file):
                    if self.is_cache_full() == False:
                        # inject into file after contenttypes node
                        self.append_to_cache(input_file_path)
                else:
                    # new document
                    self.new_cache(input_file_path)
                    
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
                    # first get the current directory name 
                    current_dir = os.path.dirname(inputdoc.xmlfile)
                    # rename file with md5sum
                    new_name = __md5_file(current_dir + "/" + original_name)
                    # move file to attachments folder and use derived uuid as new name for the file
                    shutil.move(current_dir + "/" + original_name, self.atts_folder + new_name)
                    # add new node on document with uuid
                    node.addElement("field").addText(new_name).addAttribute("name","att_hash")
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
                # first get the current directory name 
                if abs_path == False:
                    current_dir = os.path.dirname(inputdoc.xmlfile)
                    full_path = current_dir + "/"
                else:
                    full_path = dir_name
                # rename file with md5sum
                new_name = __md5_file(full_path + original_name)
                # move file to attachments folder and use derived uuid as new name for the file
                shutil.move(full_path + original_name, self.atts_folder + new_name)
                # add new node on document with uuid
                image_node.addElement("field").addText(new_name).addAttribute("name","img_hash")
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
                    print _COLOR.OKBLUE, "[checkpoint] not transformed - requeued", _COLOR.ENDC
                    return (True, False)
                else:
                    if pipe_type == "parliament":
                        # if it was a parliament info document update cached copy 
                        # to remain upto date.
                        tmp_folder = self.input_params["main_config"].get_temp_files_folder()
                        shutil.copyfile(input_file_path, tmp_folder + __parl_info__)
                        print _COLOR.WARNING, "[checkpoint] - Updated parliament info !", _COLOR.ENDC
                    return (out_files[0], True)
            # !+FIX_THIS (ao, 22 Aug 2012) Currently these are not being processed so removing them 
            # from queue programmatically
            elif pipe_type == "signatory":
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
    
    Pushes XML files one-by-one into eXist server from __repo_sync__ list of items
    """
    def __init__(self, input_params):
        self.input_params = input_params
        self.main_cfg = input_params["main_config"]
        self.webdav_cfg = input_params["webdav_config"]
        self.bunparse = ParseXML(self.main_cfg.get_temp_files_folder() + __repo_sync__)
        self.bunparse.doc_parse()
        try:
            self.dom = self.bunparse.doc_dom()
        except DocumentException, e:
            print _COLOR.FAIL, e, '\nERROR: __repo_sync__ file not found. Use `-s` switch to sync first.', _COLOR.ENDC
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
        try:
            self.writer.write(self.document)
            self.writer.flush()
        except Exception, ex:
            LOG.error("Error while writing sync file reposync.xml", ex)
        finally:
            close_quietly(self.writer)

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
        import urllib2, urllib
        conn = None
        response = None
        try:
            socket.setdefaulttimeout(60)
            conn = httplib.HTTPConnection(self.webdav_cfg.get_server(),self.webdav_cfg.get_port(),60)
            params = urllib.urlencode({'uri': ''+file_uri+'', 't': '' + file_stat_date +''})
            conn.request("GET", "/exist/apps/framework/bungeni/check-update?",params)
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
        except socket.timeout:
            print _COLOR.FAIL, '\nERROR: eXist socket.timedout at sync file... back to MQ', _COLOR.ENDC
            return (False, None)
        except urllib2.URLError, e:
            print _COLOR.FAIL, e, '\nERROR: eXist URLError.timedout at sync file... back to MQ', _COLOR.ENDC
            return (False, None)
        except socket.error, (code, message):
            print _COLOR.FAIL, code, message, '\nERROR: eXist is NOT runnning OR Wrong config info', _COLOR.ENDC
            return (False, None)
        finally:
            close_quietly(response)
            close_quietly(conn)


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
            conn = None
            response = None
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
            except socket.error, (code, message):
                print _COLOR.FAIL, code, message, '\nERROR: eXist is NOT runnning OR Wrong config info', _COLOR.ENDC
                sys.exit()
            finally:
                close_quietly(response)
                close_quietly(conn)

            return (False, None)
        else:
            return (False,None)


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
    """
    def __init__(self, input_params = None):
        self.webdav_cfg = input_params["webdav_config"]

    def update(self, uri = None):
        try:
            # http://www.avajava.com/tutorials/lessons/how-do-i-connect-to-a-url-using-basic-authentication.html
            scriptUrl = self.webdav_cfg.get_http_server_port()+'/exist/apps/framework/postproc-exec.xql?uri='+str(uri)
            name = self.webdav_cfg.get_username()
            password = self.webdav_cfg.get_password()

            authString = String(name + ":" + password)
            authEncBytes = Base64.encodeBase64(authString.getBytes())
            authStringEnc = String(authEncBytes)
            LOG.debug("Base64 encoded auth string: " + authStringEnc.toString())

            url = URL(scriptUrl)
            urlConnection = url.openConnection()
            urlConnection.setRequestProperty("Authorization", "Basic " + str(authStringEnc))
            iS = urlConnection.getInputStream()
            isr = InputStreamReader(iS)

            length = urlConnection.getContentLength()
            bytes = jarray.zeros(length,'c')
            #Read in the bytes
            offset = 0
            numRead = 0
            while offset<length:
                if numRead>= 0:
                    numRead=isr.read(bytes, offset, length-offset)
                    offset = offset + numRead
            print _COLOR.WARNING, String(bytes), _COLOR.ENDC
            return True
        except MalformedURLException, e:
            print _COLOR.FAIL, e, '\nERROR: MalformedURLException', _COLOR.ENDC
            return False
        except IOException, e:
            print _COLOR.FAIL, e, '\nERROR: IOException', _COLOR.ENDC
            return False
        finally:
            isr.close()

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
        from urllib2 import (
            urlopen, 
            URLError, 
            HTTPError
            )
        print _COLOR.OKGREEN + "Downloading .po files..." + _COLOR.ENDC
        #return list of po link in the messages configuration
        msgs_list = self.po_cfg.get_po_listing()
        for iso_name, uri in msgs_list:
            try:
                f = urlopen(uri)
                print iso_name + "-downloading from " + uri
                local_file = open(self.po_cfg.get_po_files_folder()+iso_name+".po", "wb")
                local_file.write(f.read())
                close_quietly(f)
                close_quietly(local_file)
            except HTTPError, e:
                print _COLOR.FAIL, "HTTP Error: ", e.code , uri, _COLOR.ENDC
            except URLError, e:
                print _COLOR.FAIL, "URL Error: ", e.reason, uri, _COLOR.ENDC
        print _COLOR.OKGREEN + "Downloads finished... Now translating" + _COLOR.ENDC

    def pescape_key(self, orig):
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
        try:
            self.writer.write(self.document)
            self.writer.flush()
        except Exception,ex:
            LOG.error("Error while writing catalog file", ex)
        finally:
            close_quietly(self.writer)

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
    webdaver.shutdown()
    # upload xmls at this juncture
    rsu = RepoSyncUploader({"main_config":cfg, "webdav_config" : wd_cfg})
    rsu.upload_files()
    print _COLOR.OKGREEN + "Commencing ATTACHMENT files upload to eXist via WebDav..." + _COLOR.ENDC
    """ now uploading found attachments """
    # first reset attachments folder
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_atts_folder())
    webdaver.shutdown()
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
    f = open(f)
    while True:
        data = f.read(block_size)
        if not data:
            break
        md5.update(data)
    return md5.hexdigest()

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
                    print "[checkpoint] entered user/group doc path"
                    local_dir = os.path.dirname(afile)
                    print "[checkpoint] processing image/log_data file"
                    origi_name = sba.image_seek_rename(bunparse, temp_dir, True)
                else:
                    print "[checkpoint] entered attachments doc path"
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
    webdaver.shutdown()
    rsu = RepoSyncUploader({"main_config":cfg, "webdav_config" : wd_cfg})
    print "[checkpoint] uploading XML file"
    if in_queue == True:
        upload_stat = rsu.upload_file(info_object[0])
    else:
        in_queue = False
        return in_queue

    print _COLOR.OKGREEN + "Uploading ATTACHMENT file(s) to eXist via WebDav..." + _COLOR.ENDC
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_atts_folder())
    webdaver.shutdown()
    
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
