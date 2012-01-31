"""
-Read a folder with myriad of .xml files
-Process them files one by one and do an output
-

@author = Anthony
@created = 18 Oct, 2011
"""

import os, os.path, sys, errno, getopt
import ConfigParser

from org.dom4j.io import SAXReader
from java.io import File
from java.io import FileInputStream
from java.util import HashMap
from net.lingala.zip4j.core import ZipFile
from net.lingala.zip4j.exception import ZipException

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
        
    def xpath_get_attr_val(self,name):

        return  self.__global_path__ + "field[@name]"  
        
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
    return piw.object_info

def do_transform(cfg, parl_info):
    transformer = Transformer(cfg)
    transformer.set_params(parl_info)
    print "Commencing transformations..."
    pxf = ProcessXmlFilesWalker([cfg,transformer])
    pxf.walk(cfg.get_input_folder())
    print "Completed transformations !"
       
                        
def main(config_file):
    # parse command line options if any
    try:
        cfg = TransformerConfig(config_file)
        __setup_output_dirs__(cfg)
        print bcolors.HEADER + "Retrieving parliament information..." + bcolors.ENDC
        parl_info = get_parl_info(cfg)
        print bcolors.OKGREEN,"Retrieved Parliament info ", parl_info, bcolors.ENDC
        print "Transforming ...."        
        do_transform(cfg, parl_info)    
    except getopt.error, msg:
        print msg
        print "There was an exception during startup !"
        sys.exit(2)

if __name__ == "__main__":
    if (len(sys.argv) > 1):
        main(sys.argv[1])
    else:
        print bcolors.FAIL + "config.ini file must be an input parameter" + bcolors.ENDC


