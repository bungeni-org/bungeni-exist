"""
Created on Feb 14, 2013

All config related classes are placed here

@author: undesa
"""

import os
import ConfigParser

class Config(object):
    """
    Provides access to the configuration file via ConfigParser
    """
    
    def __init__(self, cfg_file):
        self.cfg = ConfigParser.RawConfigParser()
        print "Reading config file : " , cfg_file
        self.cfg.read(cfg_file)
        print "Finished reading config_file "

    
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

    def get_country_code(self):
        #return self.get("general", "country_code")
        return self.__legislature__()["country_code"]

    def get_bungeni_custom(self):
        return self.get("general", "bungeni_custom_folder")
    
    def get_types_xml_from_bungeni_custom(self):
        return os.path.join(self.get_bungeni_custom(), "types.xml")
 
    def get_legislature_start_date(self):
        return self.__legislature__()["start_date"]
 
    def get_legislature_election_date(self):
        return self.__legislature__()["election_date"]
 
    def __bungeni_custom__(self):
        import imp
        bc = imp.load_source(
                "bungeni_custom", 
                os.path.join(
                    self.get_bungeni_custom(), 
                    "__init__.py"
                )
            )
        return bc        
 
    def __legislature__(self):
        bc = self.__bungeni_custom__()
        return bc.legislature
    
    def get_languages_info(self):
        bc = self.__bungeni_custom__()
        lang_info = {
            "allowed_languages": bc.zope_i18n_allowed_languages,
            "default_language": bc.default_language,
            "right_to_left_languages": bc.right_to_left_languages
        }
        return lang_info
        
    def get_bicameral(self):
        #return self.get("general", "bicameral")
        return self.__legislature__()["bicameral"]    

    def get_legislature_identifier(self):
        return str(self.__legislature__()["identifier"])

    def get_input_folder(self):
        return self.get("general", "bungeni_docs_folder")

    def get_transformer_resources_folder(self):
        return self.get("general", "transformer_resources_folder")

    def get_xml_output_folder(self):
        return self.get("general", "xml_output_folder")

    def get_attachments_output_folder(self):
        return self.get("general","attachments_output_folder")

    def get_temp_files_folder(self):
        return self.get("general","temp_files_folder")

    def get_cache_file_folder(self):
        return self.get("general","cache_file_folder")

    def get_pipelines(self):
        # list of key,values pairs as tuples 
        if len(self.dict_pipes) == 0:
            l_pipes = self.cfg.items("pipelines")
            for l_pipe in l_pipes:
                self.dict_pipes[l_pipe[0]] = l_pipe[1]
        return self.dict_pipes


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

