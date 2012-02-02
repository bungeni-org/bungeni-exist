"""
-Read a folder with myriad of .xml files
-Process them files one by one and do an output
-

@author = Anthony
@created = 18 Oct, 2011
"""

import os, os.path, sys, errno, getopt, array, uuid
import ConfigParser, jarray

from org.dom4j.io import SAXReader
from org.dom4j.io import OutputFormat
from org.dom4j.io import XMLWriter
from java.io import File
from java.io import FileInputStream
from java.io import FileOutputStream
from java.util import HashMap
from net.lingala.zip4j.core import ZipFile
from net.lingala.zip4j.exception import ZipException
from com.googlecode.sardine import Sardine
from com.googlecode.sardine.impl import SardineException
from com.googlecode.sardine import SardineFactory

from org.bungeni.translators.translator import OATranslator
from org.bungeni.translators.globalconfigurations import GlobalConfigurations 
from org.bungeni.translators.utility.files import FileUtility


class Config:
    """
    Provides access to the configuration file via ConfigParser
    """
    
    def __init__(self, config_file):
        self.cfg = ConfigParser.RawConfigParser()
        self.cfg.read(config_file)
    
    def get(self, section, key):
        return self.cfg.get(section, key)

class TransformerConfig(Config):
    """
    Configuration information for the Transformer
    """

    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}
    
    def get_input_folder(self):
        return self.get("general", "bungeni_docs_folder")

    def get_transformer_resources_folder(self):
        return self.get("general", "transformer_resources_folder")
    
    def get_akomantoso_output_folder(self):
        return self.get("general", "akomantoso_output_folder")

    def get_ontoxml_output_folder(self):
        return self.get("general", "metalex_output_folder")

    def get_pipelines(self):
        # list of key,values pairs as tuples 
        if len(self.dict_pipes) == 0:
            l_pipes = self.cfg.items("pipelines")
            for l_pipe in l_pipes:
                self.dict_pipes[l_pipe[0]] = l_pipe[1]
        return self.dict_pipes


class Transformer:
    """
    Access the Transformer via this class
    """
    
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
    
    def run(self, input_file, output, metalex, config_file):
        """
        Run the transformer on the input file
        """
        print "Executing Transformer with: ", input_file, output, metalex, config_file
        translatedFiles = self.transformer.translate(
            input_file, 
            config_file,  
            self.get_params()
            ) 
        
        #input stream
        fis  = FileInputStream(translatedFiles["anxml"])
        fisMlx  = FileInputStream(translatedFiles["metalex"])
        
        outFile = File(output)
        outMlx = File(metalex)
        
        FileUtility.getInstance().copyFile(fis, outFile)
        FileUtility.getInstance().copyFile(fisMlx, outMlx)

class ParseBungeniXML:
    """
    Parses XML output from Bungeni using Xerces
    """

    __sax_parser_factory__ = "org.apache.xerces.jaxp.SAXParserFactoryImpl"
    __global_path__ = "//"
    
    def __init__(self, xml_path):
        """
        Load the xml document from the path
        """

        self.xmlfile = xml_path
        sreader = SAXReader()
        an_xml = File(xml_path)        
        self.xmldoc = sreader.read(an_xml)
 
    def xpath_parl_item(self,name):

        return self.__global_path__ + "contenttype[@name='parliament']/field[@name='"+name+"']"
        
    def xpath_get_attachments(self):
        
        return self.__global_path__ + "attached_files"
        
    def xpath_get_att_nodes(self):
        
        return self.__global_path__ + "attached_files/attached_file"        

    def xpath_get_saved_file(self):
        
        return "field[@name='saved_file']"        
        
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
            parl_params['parliament-election-date'] = self.xmldoc.selectSingleNode(self.xpath_parl_item("election_date")).getText()
            parl_params['for-parliament'] = self.xmldoc.selectSingleNode(self.xpath_parl_item("type")).getText()+"/"+parl_params['parliament-election-date']
            return parl_params
        else:
            return None
            
    def attachments_seek_rename(self, current_file):
        #get a copy for writing
        self.buffer_dom = self.xmldoc
        self.buffer_doc = FileOutputStream(self.xmlfile)    
        attachments = self.buffer_dom.selectSingleNode(self.xpath_get_attachments())
        nodes = self.buffer_dom.selectNodes(self.xpath_get_att_nodes())
        
        if attachments is not None:
            if len(nodes) > 0:
                for node in nodes:
                    if node.selectSingleNode(self.xpath_get_saved_file()) is not None:
                        original_name = node.selectSingleNode(self.xpath_get_saved_file()).getText()
                        new_name = str(uuid.uuid4())
                        #rename files with uuid
                        os.rename(os.path.dirname(current_file) + "/" + original_name, os.path.dirname(current_file) + "/" + new_name)
                        att_name = node.addElement("field").addText(new_name).addAttribute("name","att_uuid")
                        print original_name, new_name
                self.format = OutputFormat.createPrettyPrint()
                self.writer = XMLWriter(self.buffer_doc, self.format)
                self.writer.write(self.buffer_dom)
                self.writer.flush()
                #os.remove(os.path.dirname(current_file) + "/" + original_name)                        
            else:            
                return None
        else:
            return None
        
    def get_contenttype_name(self):

        root_element = self.xmldoc.getRootElement()
        if root_element.getName() == "contenttype":
            return root_element.attributeValue("name")   
        else:
            return None

class bcolors:
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

    def __init__(self, input_params = None):
        """
        input_params - the parameters for the callback function
        """
        self.counter = 0
        self.object_info = None
        self.input_params = input_params

    def extractor(self, zip_file):
        """
        extracts any .zip files in folder matching original name file.
        http://www.lingala.net/zip4j/
        """
        try:
			#Initiate ZipFile object with the path/name of the zip file.
			unzipper = ZipFile(zip_file)
			#Extracts all files to the path specified
			unzipper.extractAll(os.path.splitext(zip_file)[0])
			print bcolors.WARNING + "Extracted zip file... " + zip_file+bcolors.ENDC
        except ZipException, e:
			e.printStackTrace()
			
    def walk(self, folder):
        """ 
        walk a folder and recursively walk through sub-folders
        for every file in the folder call the processing function
        """
        import fnmatch
        folder = os.path.abspath(folder)
        for a_file in [
          a_file for a_file in os.listdir(folder) if not a_file in [".",".."]
          ]:
            nfile = os.path.join(folder, a_file)
            if os.path.isdir(nfile):
                self.walk(nfile)
            elif fnmatch.fnmatch(nfile, "*.zip"): 
                self.extractor(nfile)                 
            else:
                if fnmatch.fnmatch(nfile, "*.xml"):
                    self.counter = self.counter + 1
                    info_object = self.fn_callback(nfile)
                    if info_object[0] == True:
                        self.object_info = info_object[1]
                        break
                    else:
                        continue

    def fn_callback(self, nfile):
        return (False, None)


class ParliamentInfoWalker(GenericDirWalker):
    """
    
    Does not have any input params
    """
    
    def fn_callback(self, input_file_path):
        bunparse = ParseBungeniXML(input_file_path)
        the_parl_doc = bunparse.get_parliament_info()
        if the_parl_doc is not None:
            return (True, the_parl_doc)
        else :
            return (False, None)

class SeekBindAttachmentsWalker(GenericDirWalker):
    """
    
    Does not have any input params. Looks for files with attachments
    and then the renames them appropriately
    """
    
    def fn_callback(self, input_file_path):
        bunparse = ParseBungeniXML(input_file_path)
        the_parl_doc = bunparse.attachments_seek_rename(input_file_path)
        if the_parl_doc is not None:
            return (True, the_parl_doc)
        else :
            return (False, None)            

class ProcessXmlFilesWalker(GenericDirWalker):
    """
    
    Has input params
    """
    
    def fn_callback(self, input_file_path):
        bunparse = ParseBungeniXML(input_file_path)
        pipe_type = bunparse.get_contenttype_name()
        if pipe_type is not None:
            if pipe_type in self.input_params[0].get_pipelines():
                pipe_path = self.input_params[0].get_pipelines()[pipe_type]
                output_file_name_wo_prefix  =   pipe_type + "_" + str(self.counter)
                an_xml_file = "an_" + output_file_name_wo_prefix + ".xml"
                on_xml_file = "on_" + output_file_name_wo_prefix + ".xml"
                self.input_params[1].run(
                     input_file_path,
                     self.input_params[0].get_akomantoso_output_folder() + an_xml_file ,
                     self.input_params[0].get_ontoxml_output_folder() + on_xml_file,
                     pipe_path
                     )
            else:
                print "No pipeline defined for content type %s " % pipe_type
            return (False, None)
        else:
            print "Ignoring %s" % input_file_path
            return (False, None)
            
class PostProcessWalker(GenericDirWalker):
    """
    
    Pushes files one-by-one into eXist server
    """
    
    def fn_callback(self, input_file_path):
        self.username = self.input_params["webdav_config"].get_username()
        self.password = self.input_params["webdav_config"].get_password()
        self.xml_folder = self.input_params["webdav_config"].get_bungeni_xml_folder()
        webdaver = WebDavClient(self.username, self.password, self.xml_folder)
        webdaver.pushFile(input_file_path)
        return (False, None)            

class WebDavConfig(Config):
    """
    Configuration information for eXist WebDav
    """

    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}
    
    def get_bungeni_xml_folder(self):
        return self.get("webdav", "bungeni_xml_folder")

    def get_username(self):
        return self.get("webdav", "username")
    
    def get_password(self):
        return self.get("webdav", "password")

class WebDavClient:
    """        
    Connects to eXist via WebDav and finally places the files to rest.
    """
    def __init__(self, username, password, put_folder = None):
        self.put_folder = put_folder
        self.sardine = SardineFactory.begin(username, password)

    def pushFile(self, onto_file):
        a_file = File(onto_file)
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
        except SardineException, e:
			print bcolors.FAIL, e.printStackTrace(), "\nERROR: Check eXception thrown for more." , bcolors.ENDC
			sys.exit()

def __setup_output_dirs__(cfg):
 
    def mkdir_p(path):
        try:
            os.makedirs(path)
        except os.error : # Python >2.5
            if os.error.errno == errno.EEXIST:
                pass
            else: raise

    if not os.path.isdir(cfg.get_akomantoso_output_folder()):
        mkdir_p(cfg.get_akomantoso_output_folder())
    if not os.path.isdir(cfg.get_ontoxml_output_folder()):
        mkdir_p(cfg.get_ontoxml_output_folder())


def get_parl_info(cfg):
    piw = ParliamentInfoWalker()
    piw.walk(cfg.get_input_folder())
    if piw.object_info is None:
        print bcolors.FAIL,"ERROR: Could not find Parliament info :(", bcolors.ENDC
        return sys.exit()
    else:
        return piw.object_info

def do_bind_attachments(cfg):
    sba = SeekBindAttachmentsWalker()
    sba.walk(cfg.get_input_folder())
    if sba.object_info is not None:
        print bcolors.OKBLUE,"ATT: Found attachment ", bcolors.ENDC
    else:
        return sba.object_info

def do_transform(cfg, parl_info):
    transformer = Transformer(cfg)
    transformer.set_params(parl_info)
    print bcolors.OKGREEN, "Commencing transformations...", bcolors.ENDC
    pxf = ProcessXmlFilesWalker([cfg,transformer])
    pxf.walk(cfg.get_input_folder())
    print bcolors.OKGREEN, "Completed transformations !", bcolors.ENDC
    
def webdav_upload(cfg, wd_cfg):
    print bcolors.OKGREEN, "Commencing uploads to eXist via WebDav...", bcolors.ENDC
    ppw = PostProcessWalker({"main_config":cfg, "webdav_config" : wd_cfg})
    ppw.walk(cfg.get_ontoxml_output_folder())
    print bcolors.OKGREEN + "Completed uploads to eXist !" + bcolors.ENDC  
       
                        
def main(config_file):
    # parse command line options if any
    try:
        cfg = TransformerConfig(config_file)
        wd_cfg = WebDavConfig(config_file)
        __setup_output_dirs__(cfg)
        print bcolors.HEADER + "Retrieving parliament information..." + bcolors.ENDC
        parl_info = get_parl_info(cfg)
        print bcolors.OKGREEN,"Retrieved Parliament info...", parl_info, bcolors.ENDC
        print bcolors.OKGREEN + "Seeking attachments..." + bcolors.ENDC
        do_bind_attachments(cfg)
        print bcolors.OKGREEN + "Done with attachments..." + bcolors.ENDC
        print bcolors.HEADER + "Transforming ...." + bcolors.ENDC      
        do_transform(cfg, parl_info)
        webdav_upload(cfg, wd_cfg)
    except getopt.error, msg:
        print msg
        print bcolors.FAIL + "There was an exception during startup !" + bcolors.ENDC
        sys.exit(2)

if __name__ == "__main__":
    if (len(sys.argv) > 1):
        from org.apache.log4j import PropertyConfigurator
        PropertyConfigurator.configure("./src/log4j.properties");
        main(sys.argv[1])
    else:
        print bcolors.FAIL + "config.ini file must be an input parameter" + bcolors.ENDC
