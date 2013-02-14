'''
Created on Feb 14, 2013

@author: undesa
'''

import sys, os

from java.util import (
    HashMap
    )

from java.lang import (
    RuntimeException
    )

from java.io import (
    File, 
    FileNotFoundException, 
    IOException,
    FileInputStream,
    StringReader,
    )


from org.dom4j.io import (
    SAXReader
    )

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

LOG = Logger.getLogger("glue")


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
            print _COLOR.FAIL, e, '\nERROR Closing sardine ', _COLOR.ENDC

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
                self.sardine.put(self.put_folder + os.path.basename(onto_file), bytes)
                print "PUT: "+self.put_folder + os.path.basename(onto_file)
                return True
            except SardineException, e:
                print _COLOR.FAIL, e.printStackTrace(), "\nERROR: Check eXception thrown for more." , _COLOR.ENDC
                return False
            except HttpHostConnectException, e:
                print _COLOR.FAIL, e.printStackTrace(), "\nERROR: Clues... eXist is NOT runnning OR Wrong config info" , _COLOR.ENDC
                sys.exit()
            finally:
                close_quietly(inputStream)
                self.shutdown()
                 
        except FileNotFoundException, e:
            print _COLOR.FAIL, e.getMessage(), "\nERROR: File deleted since last syn. Do a re-sync before uploading" , _COLOR.ENDC
            return True


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


def close_quietly(handle):
    """
    Always use this close to close any File, Stream or Response Handles
    This closes all handles in a exception safe manner
    """
    try:
        if (handle is not None):
            handle.close()
    except Exception, ex:
        LOG.error("Error while closing handle", ex)
        
        
        