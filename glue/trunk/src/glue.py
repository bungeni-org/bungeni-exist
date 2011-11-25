"""
-Read a folder with myriad of .xml files
-Process them files one by one and do an output
-

@author = Anthony
@created = 18 Oct, 2011
"""

import java
import os, sys, errno, getopt
import ConfigParser

from org.dom4j.io import SAXReader
from org.dom4j.tree import DefaultAttribute
from java.io import File
from java.io import FileInputStream
from java.util import HashMap


from org.bungeni.translators.translator import OATranslator
from org.bungeni.translators.globalconfigurations import GlobalConfigurations 
from org.bungeni.translators.utility.files import FileUtility


class Config:
    
    def __init__(self, config_file):
        self.cfg = ConfigParser.RawConfigParser()
        self.cfg.read(config_file)
    
    def get(self, section, key):
        return self.cfg.get(section, key)

class TransformerConfig(Config):

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
    
    
    def __init__(self, cfg):
        GlobalConfigurations.setApplicationPathPrefix(cfg.get_transformer_resources_folder())
        self.transformer = OATranslator.getInstance()
        self._parl_info = HashMap()
        
    def get_parl_info(self):
        return self._parl_info
    
    def set_parl_info(self, parl_info):
        self._parl_info = parl_info   
    
    def run(self, input_file, output, metalex, config_file):
        print "xxx ", input_file, output, metalex, config_file, "yyy  "
        translatedFiles = self.transformer.translate(input_file, config_file,  self.get_parl_info()) 
        
        #input stream
        fis  = FileInputStream(translatedFiles["anxml"])
        fisMlx  = FileInputStream(translatedFiles["metalex"])
        
        outFile = File(output)
        outMlx = File(metalex)
        
        FileUtility.getInstance().copyFile(fis, outFile)
        FileUtility.getInstance().copyFile(fisMlx, outMlx)

class ParseBungeniXML:

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

        return self.__global_path__ + "contenttype[@name='group']/field[@name='"+name+"']"
        
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

class GenericDirWalker(object):

    def __init__(self, input_params = []):
        """
        input_params - the parameters for the callback function
        """
        self.counter = 0
        self.object_info = None
        self.input_params = input_params
        
    def reset_counter(self):
        """
        This function resets the counter, e.g. after initial walk to retrieve parl_info & 
        starting the actual transformation since they user same DirWalker
        """
        self.counter = 0  

    def walk(self, dir, callback_function):
        """ 
        walk a folder and recursively walk through sub-folders
        for every file in the folder call the processing function
        """
        import fnmatch
        dir = os.path.abspath(dir)
        for file in [
          file for file in os.listdir(dir) if not file in [".",".."]
          ]:
            nfile = os.path.join(dir,file)
            if os.path.isdir(nfile):
                self.walk(nfile, callback_function)
            else:
                if fnmatch.fnmatch(nfile, "*.xml"):
                    self.counter = self.counter + 1
                    info_object = callback_function(nfile, self.counter, self.input_params)
                    if info_object[0] == True:
                        self.object_info = info_object[1]
                        break
                    else:
                        continue

def parliament_info(input_file_path, count, input_params):
    bunparse = ParseBungeniXML(input_file_path)
    the_parl_doc = bunparse.get_parliament_info()
    if the_parl_doc is not None:
        return (True, the_parl_doc)
    else :
        return (False, None)

def process_file(input_file_path, count, input_params):
    bunparse = ParseBungeniXML(input_file_path)
    pipe_type = bunparse.get_contenttype_name()
    if pipe_type is not None:
        if pipe_type in input_params[0].get_pipelines():
            pipe_path = input_params[0].get_pipelines()[pipe_type]
            output_file_name_wo_prefix  = pipe_type + "_" + str(count)
            an_xml_file = "an_" + output_file_name_wo_prefix + ".xml"
            on_xml_file = "on_" + output_file_name_wo_prefix + ".xml"
            input_params[1].run(input_file_path,
                 input_params[0].get_akomantoso_output_folder() + an_xml_file ,
                 input_params[0].get_ontoxml_output_folder() + on_xml_file,
                 pipe_path)
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

                        
def main(config_file):
    # parse command line options if any
    try:
        cfg = TransformerConfig(config_file)
        __setup_output_dirs__(cfg)
        transformer = Transformer(cfg)
        #Adding objects onto signature list that initializes the Direcory Walker
        input_params = []
        input_params.append(cfg)
        input_params.append(transformer)
        gdw = GenericDirWalker(input_params)
        #Check for parliamentary document and get parliament info        
        print "Retrieving parliament information..."
        gdw.walk(cfg.get_input_folder(), parliament_info)
        print gdw.object_info        
        transformer.set_parl_info(gdw.object_info)
        print "\nDONE! Commencing transformations..."
        gdw.reset_counter()
        gdw.walk(cfg.get_input_folder(), process_file)
            
    except getopt.error, msg:
        print msg
        print "There was an exception during startup !"
        sys.exit(2)

if __name__ == "__main__":
    if (len(sys.argv) > 1):
        main(sys.argv[1])
    else:
        print "config.ini file must be an input parameter"


