"""
Created on Feb 15, 2013

Walker Processing Implementations

@author: undesa
"""

import os, sys, shutil
import httplib, socket #used in sync check

from org.dom4j import (
    DocumentFactory,
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
    )


from org.apache.http.conn import HttpHostConnectException

from com.googlecode.sardine.impl import SardineException


from org.apache.log4j import (
    Logger
    )

from net.lingala.zip4j.core import ZipFile
from net.lingala.zip4j.exception import ZipException


### APP Imports ####

from gen_utils import (
    COLOR,
    close_quietly
    )

from utils import (
    __md5_file,
    WebDavClient,
    Transformer
    )

from parsers import (
    ParseBungeniXML,
    ParseLegislatureInfoXML,
    ParseCachedParliamentInfoXML,
    ParseParliamentInfoXML,
    ParliamentInfoParams
    )

from walker import (
    GenericDirWalker,
    GenericDirWalkerXML,
    GenericDirWalkerATTS,
    )

LOG = Logger.getLogger("glue")

__parl_info__ = "parliament_info.xml"
__legislature_info__ = "legislature_info.xml"
 
 
 



class LegislatureInfoWalker(GenericDirWalker):
    """
    Walker that retrieves the info about the legislature
    This is called from both the queue processor and from the batch processor
    """
    def __init__(self, input_params = None):
        super(LegislatureInfoWalker, self).__init__(input_params)
        self.cache_file = "%s%s" % (
            self.input_params["main_config"].get_cache_file_folder(),
            __legislature_info__
            )
        self.tmp_files_folder = self.input_params["main_config"].get_temp_files_folder()
        self.legislature_info = {}
    
    def cache_file_exists(self):
        return os.path.isfile(self.cache_file)

    def process_xml_file(self, input_file_path):
        # TO_BE_DONE
        bunparse = ParseLegislatureInfoXML(input_file_path)
        if not bunparse.valid_file:
            ## error while opening file
            return (False, None)
        parse_success = bunparse.doc_parse()
        if not parse_success:
            ## error while parsing file 
            return (False, None)
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
                #print "XXXX CACHE FILE EXISTS"
                if self.is_cache_full() == False:
                    #print "XXXX CACHE IS NOT FULL"
                    # inject into file after contenttypes node
                    # check if the parliament info is not already cached
                    #print "XXXX APPENDING TO CACHE"
                    self.append_to_cache(input_file_path)
                    #return (True, the_parl_doc)
            else:
                # new document
                self.new_cache(input_file_path)
            # Check if the cache is full
            # if the cache is full , stop processing and return the parl_doc
            if self.is_cache_full():
                return (True, the_parl_doc)
            else:
                # else continue
                return (False, None)    
        else :
            return (False, None)

   
    def fn_callback(self, input_file_path):
        """
        This is an incoming document 
        """
   
        if input_file_path.endswith(".zip"):
            # zip file processing
            zipfile = ZipFile(input_file_path)
            found_file = None
            if zipfile.isValidZipFile():
                files = zipfile.fileHeaders
                for file in files:
                    xml_file = file.fileName
                    if xml_file.endswith(".xml"):
                        found_file = file
                        break
                if found_file is not None:
                    try:
                        zipfile.extractFile(found_file, self.tmp_files_folder)
                        # return
                        return self.process_xml_file(
                                os.path.join(self.tmp_files_folder, found_file.fileName)
                        )
                    except ZipException, e:
                        print COLOR.FAIL, e.printStackTrace(), COLOR.ENDC
            return (False, None)
        elif input_file_path.endswith(".xml"):
            return self.process_xml_file(input_file_path)
        else :
            return (False, None)


class ParliamentInfoWalker(GenericDirWalker):
    """
    Walker that retrieves the info about the parliament
    This is called from both the queue processor and from the batch processor
    """
    def __init__(self, input_params = None):
        super(ParliamentInfoWalker, self).__init__(input_params)
        # check if the system is setup for unicameral or bicameral 
        self.bicameral = self.input_params["main_config"].get_bicameral()
        self.cache_file = "%s%s" % (
            self.input_params["main_config"].get_cache_file_folder(),
            __parl_info__
            )
        self.tmp_files_folder = self.input_params["main_config"].get_temp_files_folder()
        self.parliament_info = {}
    
    def cache_file_exists(self):
        return os.path.isfile(self.cache_file)
    
    """
    The system can have 2 parliaments, so the assumption is if bicameral is = True
    There can be 2 chambers.
    
    """

    def get_from_cache(self):
        """
        check if the dom is cached for the parliament information map
        Returns the parliament information of 1 parliament
        """
        # !+BICAMERAL !+FIX_THIS the cache file is not just the raw file, 
        # it has 2 parliaments !
        """
        reader = SAXReader()
        cache_doc = reader.read(
            File(self.cache_file)
            )
        list_of_cached_nodes = cache_doc.selectNodes(
            "//cachedTypes/contenttype"
            )
        """
        #!+FIX_THIS implement ParseBungeniXML to take a node as an input
        bunparse = ParseCachedParliamentInfoXML(self.cache_file)
        bunparse.doc_parse()
        # return the parliament information in a list containing a hashmap
        the_parl_doc = bunparse.get_parliament_info(
                self.input_params["main_config"].get_bicameral(),
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
            pinfo = ParliamentInfoParams()
            list_of_cached_nodes = cache_doc.selectNodes(
                pinfo._xpath_content_types()
            )
            if not self.bicameral:
                """
                If its unicameral
                """
                if len(list_of_cached_nodes) == 1:
                    return True
                else:
                    return False
            else:
                """
                If its bicameral
                """
                if len(list_of_cached_nodes) == 2:
                    return True
                else:
                    return False
        return False 
                
        

    def new_cache_document(self):
        """
        Creates a new empty cache document and saves it to disk
        """
        cache_doc = DocumentHelper.createDocument()
        pinfo = ParliamentInfoParams()
        # <cachedTypes />
        cache_doc.addElement(pinfo.CACHED_TYPES)
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
        #print "XXXX WRITE CACHE TO FILE ", cache_doc.getRootElement().getDocument().asXML()
        format = OutputFormat.createPrettyPrint()
        writer = XMLWriter(
            FileWriter(self.cache_file),
            format
            )
        try:
            writer.write(cache_doc)
            writer.flush()
        except Exception, e:
            print "Error WRITE_CACHE_DOC_TO_FILE ", e
        finally:
            close_quietly(writer)

    
    def does_parliament_exists_in_cache(self, parliament_id):
        cache_doc = self.__doc_cache_file()
        found_parl_node = cache_doc.selectSingleNode(
            "/cachedTypes/contenttype[@name='chamber']/field[@name='principal_id'][. = '%s']" % parliament_id
            )
        if found_parl_node is not None:
            # parliament already cached !
            return True
        else:
            return False

        
    def append_to_cache(self, input_file):
        reader = SAXReader()
        new_doc = reader.read(
            File(input_file)
        )
        parl_node = new_doc.selectSingleNode("/contenttype[@name='chamber']/field[@name='principal_id']")
        parliament_id = parl_node.getText()
        if not self.does_parliament_exists_in_cache(parliament_id):
            element_to_import = new_doc.getRootElement()
            self.append_element_into_cache_document(element_to_import)
        else:
            LOG.info(parliament_id + " already exists in cache")


    def __doc_cache_file(self):
        reader = SAXReader()
        cache_doc = reader.read(
            File(self.cache_file)
            )
        return cache_doc

    def append_element_into_cache_document(self, element_to_import):
        cache_doc = self.__doc_cache_file()
        # get the child elements
        list_of_elements = cache_doc.getRootElement().elements()
        #print "XXXX LIST OF ELEMENTS IN CACHE, ", list_of_elements 
        # get a deep copy of the element to be imported, this also detaches the node 
        # from the parent
        element_to_copy = element_to_import.createCopy()
        #print "XXXX LIST OF ELEMENTS TO COPY, ", element_to_copy 
        list_of_elements.add(element_to_copy)
        #cache_doc.importNode(element_to_import, True)
        #cache_doc.getRootElement().addElement(
        ##    element_to_import
        #    )
        #print "XXXX LIST OF ELEMENTS AFTER COPY, ", list_of_elements 
        self.write_cache_doc_to_file(cache_doc)    
   
   
    def process_xml_file(self, input_file_path):
        bunparse = ParseParliamentInfoXML(input_file_path)
        if not bunparse.valid_file:
            ## error while opening file
            return (False, None)
        parse_success = bunparse.doc_parse()
        if not parse_success:
            ## error while parsing file 
            return (False, None)
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
                #print "XXXX CACHE FILE EXISTS"
                if self.is_cache_full() == False:
                    #print "XXXX CACHE IS NOT FULL"
                    # inject into file after contenttypes node
                    # check if the parliament info is not already cached
                    #print "XXXX APPENDING TO CACHE"
                    self.append_to_cache(input_file_path)
                    #return (True, the_parl_doc)
            else:
                # new document
                self.new_cache(input_file_path)
            # Check if the cache is full
            # if the cache is full , stop processing and return the parl_doc
            if self.is_cache_full():
                return (True, the_parl_doc)
            else:
                # else continue
                return (False, None)    
        else :
            return (False, None)

   
    def fn_callback(self, input_file_path):
        """
        This is an incoming document 
        """
   
        if input_file_path.endswith(".zip"):
            # zip file processing
            zipfile = ZipFile(input_file_path)
            found_file = None
            if zipfile.isValidZipFile():
                files = zipfile.fileHeaders
                for file in files:
                    xml_file = file.fileName
                    if xml_file.endswith(".xml"):
                        found_file = file
                        break
                if found_file is not None:
                    try:
                        zipfile.extractFile(found_file, self.tmp_files_folder)
                        # return
                        return self.process_xml_file(
                                os.path.join(self.tmp_files_folder, found_file.fileName)
                        )
                    except ZipException, e:
                        print COLOR.FAIL, e.printStackTrace(), COLOR.ENDC
            return (False, None)
        elif input_file_path.endswith(".xml"):
            return self.process_xml_file(input_file_path)
        else :
            return (False, None)
         

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

    def votes_seek_rename(self, inputdoc, dir_name, abs_path = False):
        """
        Votes are zipped by Bungeni like any other attachment. We therefore link it to parent and 
        rename the votes document (XML) to be uploaded into bungeni-xml collection.
        """
        # get the folder where the attachments are written to
        self.atts_folder = self.input_params["main_config"].get_attachments_output_folder()
        # get the attached_files node in the document
        item_schedules = inputdoc.get_votes_file()
        if (item_schedules is not None):
            LOG.debug("In votes_seek_rename " + inputdoc.xmlfile + " HAS vote(s) ")
            # get the roll_call nodes within item_schedule
            nodes = item_schedules.selectNodes("//item_schedule/itemvotes/itemvote/roll_call")
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
                    new_name = "votes_" + __md5_file(current_dir + "/" + original_name) + ".xml"
                    # move file to attachments folder and use derived uuid as new name for the file
                    shutil.move(current_dir + "/" + original_name, self.atts_folder + new_name)
                    # add new node on document with uuid
                    node.addElement("field").addText(new_name).addAttribute("name","votes_hash")
                    document_updated = True
            if document_updated:
                inputdoc.write_to_disk()
            
        else:
            LOG.debug("In votes_seek_rename " + inputdoc.xmlfile + " NO votes")

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
                on_xml_file = "on_%s_" % truncated_prefix
                out_files = self.input_params["transformer"].run(
                     input_file_path,
                     self.input_params["main_config"].get_xml_output_folder() + on_xml_file ,
                     pipe_path
                     )
                # Any error in transfromer return a None object which we want to leave 
                # the doc in queue e.g. premature end of file encountered
                if out_files[0] == None:
                    print COLOR.OKBLUE, "[checkpoint] not transformed - requeued", COLOR.ENDC
                    return (True, False)
                else:
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
                    on_xml_file = truncated_prefix + "_"
                    #print "XXXXXX OUT_FILE_CALLBACK", on_xml_file
                    out_files = self.input_params["transformer"].run(
                         input_file_path,
                         self.input_params["main_config"].get_xml_output_folder() + on_xml_file ,
                         pipe_path
                         )
                else:
                    print COLOR.WARNING, "No pipeline defined for content type %s " % pipe_type, COLOR.ENDC
                return (False, None)
            else:
                print "Ignoring %s" % input_file_path
                return (False, None)
        else:
            return (False,None)


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
            webdaver = None
            try:
                self.username = self.webdav_cfg.get_username()
                self.password = self.webdav_cfg.get_password()
                self.xml_folder = "%s%s" % (
                        self.webdav_cfg.get_http_server_port(),
                        self.webdav_cfg.get_bungeni_atts_folder()
                        )
                webdaver = WebDavClient(self.username, self.password, self.xml_folder)
                up_info_obj = webdaver.pushFile(att_path)
                if up_info_obj == True:
                    upload_stat = True
                else:
                    upload_stat = False
            except HttpHostConnectException, e:
                print COLOR.FAIL, e.printStackTrace(), COLOR.ENDC
                break
            finally:
                if webdaver is not None:
                    webdaver.shutdown()
        if atts_present == False:
            return True
        print "[checkpoint] ATTS upload"
        if upload_stat == True:
            return upload_stat
        else:
            return False

    def fn_callback(self, input_file_path):
        if GenericDirWalkerATTS.fn_callback(self, input_file_path)[0] == True:
            webdaver = None
            try:
                self.username = self.webdav_cfg.get_username()
                self.password = self.webdav_cfg.get_password()
                self.xml_folder = self.webdav_cfg.get_http_server_port()+self.webdav_cfg.get_bungeni_atts_folder()
                webdaver = WebDavClient(self.username, self.password, self.xml_folder)
                webdaver.pushFile(input_file_path)
                return (False, None)
            except SardineException, e:
                print COLOR.FAIL, e.printStackTrace(), COLOR.ENDC
                return (False, None)
            except HttpHostConnectException, e:
                print COLOR.FAIL, e.printStackTrace(), COLOR.ENDC
                return (False, None)
            finally:
                if webdaver is not None:
                    webdaver.shutdown()
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
                    print COLOR.WARNING, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(str(input_file_path)), COLOR.ENDC
                    # 'ignore' means that its in the repository so we add anything that that is not `ignore` to the reposync list
                    self.add_item_to_repo(str(input_file_path))
                    LOG.debug( data )
                    return (True, file_uri)
                else:
                    print COLOR.OKGREEN, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(str(input_file_path)), COLOR.ENDC
                    return (True, None)
            else:
                print COLOR.FAIL, os.path.basename(input_file_path), response.status, response.reason, COLOR.ENDC
                return (False, None)
        except socket.timeout:
            print COLOR.FAIL, '\nERROR: eXist socket.timedout at sync file... back to MQ', COLOR.ENDC
            return (False, None)
        except urllib2.URLError, e:
            print COLOR.FAIL, e, '\nERROR: eXist URLError.timedout at sync file... back to MQ', COLOR.ENDC
            return (False, None)
        except socket.error, (code, message):
            print COLOR.FAIL, code, message, '\nERROR: eXist is NOT runnning OR Wrong config info', COLOR.ENDC
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
                        print COLOR.WARNING, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(input_file_path), COLOR.ENDC
                        # 'ignore' means that its in the repository so we add anything that that is not `ignore` to the reposync list
                        self.add_item_to_repo(input_file_path)
                        LOG.debug( data )
                    else:
                        print COLOR.OKGREEN, response.status, "[",self.get_sync(data),"]","- ", os.path.basename(input_file_path), COLOR.ENDC
                else:
                    print COLOR.FAIL, os.path.basename(input_file_path), response.status, response.reason, COLOR.ENDC
            except socket.error, (code, message):
                print COLOR.FAIL, code, message, '\nERROR: eXist is NOT runnning OR Wrong config info', COLOR.ENDC
                #sys.exit()
            finally:
                close_quietly(response)
                close_quietly(conn)

            return (False, None)
        else:
            return (False,None)



