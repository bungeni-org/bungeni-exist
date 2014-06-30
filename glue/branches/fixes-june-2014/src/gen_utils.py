'''
Created on Feb 19, 2013

@author: undesa
'''


from org.apache.log4j import Logger
import os

LOG = Logger.getLogger("glue")



class COLOR(object):
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


class ParliamentCacheInfo:
    
    def __init__(self, no_of_parls = 1, p_info = []):
        self.no_of_parliaments = no_of_parls
        self.parl_info = p_info
    
    def is_cache_satisfied(self):
        #print "XXXX is_cache_satisfied ", self.parl_info
        if self.parl_info is None:
            return False
        else:
            return self.no_of_parliaments == len(self.parl_info)

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
        

def mkdir_p(path):
    '''
    equivalent to the shell mkdir -p command
    '''
    import os, errno
    try:
        os.makedirs(path)
    except os.error : # Python >2.5
        if os.error.errno == errno.EEXIST:
            pass
        else: raise

def get_module_dir():
    return os.path.dirname(os.path.realpath(__file__))

def get_module_file(file_name):
    return os.path.join(get_module_dir(),file_name)

def typename_to_camelcase(value):
    """
    Convert underscore names to Camel Case
    """
    def camelcase(): 
        yield type(value).lower
        while True:
            yield type(value).capitalize
    
    c = camelcase()
    return "".join(c.next()(x) if x else '_' for x in value.split("_"))

def typename_to_propercase(value):
    """
    Convert underscore names to Proper Case (underscores are collapsed) 
    """
    li_value = value.split("_")
    return "".join(x.title() for x in li_value)

def __empty_output_dir__(folder):
    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            os.unlink(file_path)
        except Exception, e:
            print e

def __setup_tmp_dir__(cfg):
    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())
    
def __setup_tmp_dirs__(cfg):

    if not os.path.isdir(cfg.get_po_files_folder()):
        mkdir_p(cfg.get_po_files_folder())

    if not os.path.isdir(cfg.get_i18n_catalogues_folder()):
        mkdir_p(cfg.get_i18n_catalogues_folder())

def __setup_cache_dirs__(cfg):

    if not os.path.isdir(cfg.get_cache_file_folder()):
        mkdir_p(cfg.get_cache_file_folder())
    else:
        ### clear the cache file during every run of the consumer
        # !!! DO NOT DO THIS 
        #__empty_output_dir__(cfg.get_cache_file_folder())
        pass
    

def __setup_output_dirs__(cfg):
        
    if not os.path.isdir(cfg.get_xml_output_folder()):
        mkdir_p(cfg.get_xml_output_folder())
    else:
        __empty_output_dir__(cfg.get_xml_output_folder())        
    if not os.path.isdir(cfg.get_attachments_output_folder()):
        mkdir_p(cfg.get_attachments_output_folder())
    else:
        __empty_output_dir__(cfg.get_attachments_output_folder())
    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())

    