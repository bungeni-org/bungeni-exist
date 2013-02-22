"""
Created on Feb 14, 2013

All utility classes and APIs reside here

@author: undesa
"""

import sys, os, socket

from java.io import (
    FileWriter, 
    InputStreamReader,
    File, 
    FileNotFoundException, 
    IOException,
    FileInputStream,
    StringReader,
    )

from java.net import (
    MalformedURLException,
    URL
    )

from java.util import (
    HashMap,
    )

from java.lang import (
    String,
    StringBuilder,
    RuntimeException
    )

from org.dom4j import (
    DocumentFactory,
    DocumentException,
    )

from org.dom4j.io import (
    OutputFormat,
    XMLWriter,
    SAXReader
    )

from org.apache.commons.codec.binary import Base64

from net.sf.saxon.trans import XPathException
from org.xml.sax import SAXParseException

from org.bungeni.translators.translator import OATranslator
from org.bungeni.translators.globalconfigurations import GlobalConfigurations 
from org.bungeni.translators.utility.files import FileUtility

from com.googlecode.sardine.impl import SardineException
from com.googlecode.sardine import SardineFactory

import jarray

from org.apache.http.conn import HttpHostConnectException
from org.apache.log4j import Logger

### APP Imports ####
from gen_utils import (
    COLOR,
    close_quietly
    )

from parsers import (
    ParseXML,
    )


__repo_sync__ = "reposync.xml"

LOG = Logger.getLogger("glue")


class WebDavClient(object):
    """        
    Connects to eXist via WebDav and finally places the files to rest.
    """
    def __init__(self, username, password, put_folder = None):
        self.put_folder = put_folder
        self.sardine = SardineFactory.begin(username, password)

    def shutdown(self):
        try:
            self.sardine.shutdown()
        except Exception,e:
            print COLOR.FAIL, e, '\nERROR Closing sardine ', COLOR.ENDC

    def reset_remote_folder(self, put_folder):
        try:
            if self.sardine.exists(put_folder) is False:
                print COLOR.WARNING + "INFO: " + put_folder + " folder wasn't there !" + COLOR.ENDC            
                self.sardine.createDirectory(put_folder)
        except SardineException, e:
            print COLOR.FAIL, e.printStackTrace(), "\nERROR: Resource / Collection fault." , COLOR.ENDC
            sys.exit()
        except HttpHostConnectException, e:
            print COLOR.FAIL, e.printStackTrace(), "\nERROR: Clues... eXist is NOT runnning OR Wrong config info" , COLOR.ENDC
            sys.exit()

    def pushFile(self, onto_file):
        try:
            a_file = File(onto_file)
        except Exception, E:
            print COLOR.FAIL, E, '\nERROR: E While processing xml ', onto_file, COLOR.ENDC
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
                self.sardine.put(self.put_folder + os.path.basename(onto_file), bytes)
                print "PUT: "+self.put_folder + os.path.basename(onto_file)
                return True
            except SardineException, e:
                print COLOR.FAIL, e.printStackTrace(), "\nERROR: Check eXception thrown for more." , COLOR.ENDC
                return False
            except HttpHostConnectException, e:
                print COLOR.FAIL, e.printStackTrace(), "\nERROR: Clues... eXist is NOT runnning OR Wrong config info" , COLOR.ENDC
                sys.exit()
            finally:
                close_quietly(inputStream)
                self.shutdown()
                 
        except FileNotFoundException, e:
            print COLOR.FAIL, e.getMessage(), "\nERROR: File deleted since last syn. Do a re-sync before uploading" , COLOR.ENDC
            return True


class Transformer(object):
    """
    Access the Transformer via this class
    """

    __global_path__ = "//"
    
    def __init__(self, cfg):
        # point the transformer to the correct configuration folder
        GlobalConfigurations.setApplicationPathPrefix(
            cfg.get_transformer_resources_folder()
        )
        # initialize the transformer
        self.transformer = OATranslator.getInstance()
        # setup a hashmap to pass input parameters to the pipeline
        self.cfg = cfg
        self._params = HashMap()
        
    def get_params(self):
        # returns the parliament info object
        return self._params
    
    def set_params(self, input_params):
        """
        @params - a list containing hashmaps of parliamentary information
        This api converts it to an xml document
        !+BICAMERAL 
        """
        self._params = HashMap()
        # sets the parliament info object
        for key in input_params.keys():
            self._params.put(key, input_params[key])

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
            uri_raw = self.xmldoc.selectSingleNode(self.xpath_get_doc_internal_uri()).getValue()
            uri_encoded = uri_raw.encode('utf-8')
        else:
            uri_raw = doc_uri.getValue()
            uri_encoded = uri_raw.encode('utf-8')
        if status_date is None:
            on_sync_params['status_date'] = ""
        else:
            on_sync_params['status_date'] = self.xmldoc.selectSingleNode(self.xpath_get_status_date()).getText()
        
        on_sync_params['uri'] = uri_encoded
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
            print COLOR.FAIL, '\nFile disappeared. Will retry ', input_file, COLOR.ENDC
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
                uri_raw = self.get_doc_uri(translatedFiles["final"])
                # clean uri if it may have unicode characters
                uri = uri_raw.encode('utf-8') 
                rep_dict = {'/':'_', ':':','}
                uri_name = self.replace_all(uri, rep_dict)
                outFile = File(str(output) + uri_name.decode('iso-8859-1') + ".xml")
                #copy transformed file to disk
                FileUtility.getInstance().copyFile(fis, outFile)
                close_quietly(fis)
                return [outFile, None]
        except SAXParseException, saE:
            print COLOR.FAIL, saE, '\nERROR: saE While processing xml ', input_file, COLOR.ENDC
            return [None, None]
        except XPathException, xpE:
            print COLOR.FAIL, xpE, '\nERROR: xpE While processing xml ', input_file, COLOR.ENDC
            return [None, None]
        except IOException, ioE:
            print COLOR.FAIL, ioE, '\nERROR: ioE While processing xml ', input_file, COLOR.ENDC
            return [None, None]
        except Exception, E:
            print COLOR.FAIL, E, '\nERROR: E While processing xml ', input_file, COLOR.ENDC
            return [None, None]
        except RuntimeException, ruE:
            print COLOR.FAIL, ruE, '\nERROR: ruE While processing xml ', input_file, COLOR.ENDC
            return [None, None]


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
            print COLOR.FAIL, e, '\nERROR: __repo_sync__ file not found. Use `-s` switch to sync first.', COLOR.ENDC
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
            print COLOR.WARNING, String(bytes), COLOR.ENDC
            return True
        except MalformedURLException, e:
            print COLOR.FAIL, e, '\nERROR: MalformedURLException', COLOR.ENDC
            return False
        except IOException, e:
            print COLOR.FAIL, e, '\nERROR: IOException', COLOR.ENDC
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
        print COLOR.OKGREEN + "Downloading .po files..." + COLOR.ENDC
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
                print COLOR.FAIL, "HTTP Error: ", e.code , uri, COLOR.ENDC
            except URLError, e:
                print COLOR.FAIL, "URL Error: ", e.reason, uri, COLOR.ENDC
        print COLOR.OKGREEN + "Downloads finished... Now translating" + COLOR.ENDC

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


def get_legislature_information(cfg):
    
