"""
-Read a folder with myriad of .xml files
-Process them files one by one and do an output
-

@author = Anthony
@created = 18 Oct, 2011
"""

import java
import os 
import sys 
import ConfigParser
import getopt

from org.dom4j.io import SAXReader
from org.dom4j.tree import DefaultAttribute
from java.io import File
from java.io import FileInputStream

from org.bungeni.translators.translator import OATranslator
from org.bungeni.translators.globalconfigurations import GlobalConfigurations 
from org.bungeni.translators.utility.files import FileUtility

'''
#Get the configuration file
config = ConfigParser.RawConfigParser()
config.read("config.ini")

#getting runtime params
path = config.get("general","bungeni_docs_folder")                  #path to Bungeni Documents
resources_f = config.get("general","transformer_resources_folder")  #Resources folder with transfromation configs
output_folder = config.get("general","akomantoso_output_folder")    #AN output dumping folder
metalex_dump = config.get("general","allow_metalex_output")         #Dumps metalex files !+FIX_THIS (ao, 19th Oct 2011) only per group not individually
metalex_folder = config.get("general","metalex_output_folder")                   #Default dumping folder
metalex_allow = config.get("general","allow_metalex_output")              

#Get Pipelines
pipe_question = config.get("pipelines","question")
pipe_group = config.get("pipelines","group")
'''

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
    
    def run(self, input_file, output, metalex, config_file):
	print "xxx ", input_file, output, metalex, config_file, "yyy  "      
	translatedFiles = {}
        translatedFiles = self.transformer.translate(input_file, config_file) 
        
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
 
    def xpath_form_by_attr(self,name):

        return  self.__global_path__ + "field[@name='" + name + "']"
        
    def xpath_get_attr_val(self,name):

        return  self.__global_path__ + "field[@name]"        
        
    def get_contenttype_name(self):

        root_element = self.xmldoc.getRootElement()
        if root_element.getName() == "contenttype":
            return root_element.attributeValue("name")   
        else:
            return None

      
                        
def main(config_file):
    # parse command line options if any
    try:
        cfg = TransformerConfig(config_file)
        trans = Transformer(cfg)
        count = 1
        listing = os.listdir(cfg.get_input_folder())
        for infile in listing:
            print "[" + str(count) + "]current file is: " + infile
            input_file_path = cfg.get_input_folder() + infile            
            bunparse = ParseBungeniXML(input_file_path)
            pipe_type = bunparse.get_contenttype_name()
            if pipe_type is not None:
               pipe_path = cfg.get_pipelines()[pipe_type]
               trans.run(input_file_path,
                    cfg.get_akomantoso_output_folder() + infile,
                    cfg.get_ontoxml_output_folder() + str(count) + ".mlx",
                    pipe_path)
               count = count + 1
            else:
               print "Ignoring %s" % input_file_path
               
            
    except getopt.error, msg:
        print msg
        print "BOMBED!"
        sys.exit(2)

if __name__ == "__main__":
    if (len(sys.argv) > 1):
        main(sys.argv[1])
    else:
        print "config.ini file must be an input parameter"


