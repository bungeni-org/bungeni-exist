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
from org.bungeni.translators.configurations import OAConfiguration
from org.bungeni.translators.translator import GenericXMLSource
from org.bungeni.translators.globalconfigurations import GlobalConfigurations 
from org.bungeni.translators.utility.files import FileUtility

#Get the configuration file
config = ConfigParser.RawConfigParser()
config.read('sorting.ini')

#getting runtime params
path = config.get('general','bungeni_docs_folder')                  #path to Bungeni Documents
resources_f = config.get('general','transformer_resources_folder')  #Resources folder with transfromation configs
output_folder = config.get('general','akomantoso_output_folder')    #AN output dumping folder
metalex_dump = config.get('general','allow_metalex_output')         #Dumps metalex files !+FIX_THIS (ao, 19th Oct 2011) only per group not individually
metalex = config.get('general','default_metalex')                   #Default dumping file

class Transformer:
    
    def __init__(self):
        GlobalConfigurations.setApplicationPathPrefix(resources_f)
        self.transformer = OATranslator.getInstance()
    
    def run(self,input_file,output,config_file):
        config_file="configfiles/configs/config_bungeni_group.xml"
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
        self.xmlfile = xml_path
        self.xmldoc = None
        
    def xpath_form_by_attr(self,get_name):
        return  self.__global_path__ + "field[@name='"+get_name+"']"
        
    def parse_me(self, file):
        sreader = SAXReader()
        an_xml = File(file)        
        self.xmldoc = sreader.read(an_xml)
        getType= self.xmldoc.selectSingleNode(self.xpath_form_by_attr("type"))
        named = getType.getStringValue()      
        return named  
      
    def sorting_hat(self, typename):
        if typename == "question":
            __conf_path__ =  config.get('parliament','question')
            
        elif typname == "group":
            __conf_path__ =  config.get('parliament','group')
                        
def main():
    # parse command line options
    try:
        trans = Transformer()
        count = 1
        listing = os.listdir(path)
        for infile in listing:
            print "[" + str(count) + "]current file is: " + infile
            bunparse = ParseBungeniXML(path+infile)
            print bunparse.parse_me(path+infile)
            trans.run(path+infile,output_folder+infile,"configfiles/configs/config_bungeni_group.xml")
            count = count + 1
            
    except getopt.error, msg:
        print msg
        print "BOMBED!"
        sys.exit(2)

if __name__ == "__main__":
    main()
