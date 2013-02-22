""" 

    REQUIRES : Jython , NOT Python

    Performs XSLT transformations on Bungeni documents and outputs ontological documents;
    synchronizes with eXist-db; translates .po files to .xml catalogues

    transformation process:
        -get parliament's information
        -look for documents with attachments and bind them
        -transform Bungeni documents and add the bu: namespace
        -synchronize with collection in eXist-db to create upload list
        -upload XML documents + attachments to eXist database
    other actions:
        -translate .po files to .xml catalogues
        !+NOTE: Use of polib requires one to install it to Jython as follows:
        /path/to/jython2.5.2/bin/easy_install polib
"""

import os.path, sys, errno, getopt, shutil
import time

__author__ = "Ashok Hariharan and Anthony Oduor"
__copyright__ = "Copyright 2011, Bungeni"
__license__ = "GNU GPL v3"
__version__ = "1.4.0"
__maintainer__ = "Anthony Oduor"
__created__ = "18th Oct 2011"
__status__ = "Development"

#__parl_info__ = "parliament_info.xml"
#__repo_sync__ = "reposync.xml"

__sax_parser_factory__ = "org.apache.xerces.jaxp.SAXParserFactoryImpl"


from java.io import File

from java.lang import StringBuilder

from org.apache.log4j import (
    PropertyConfigurator,
    Logger
    )


### APP Imports ####

from configs import (
    TransformerConfig,
    WebDavConfig,
    PoTranslationsConfig
    )

from gen_utils import (
    COLOR,
    get_module_file
    )

from utils import (
    WebDavClient,
    Transformer,
    RepoSyncUploader,
    PostTransform,
    POFilesTranslator,
    )

from parsers import (
    ParseBungeniXML
    )

from walker import (
    GenericDirWalkerUNZIP
    )

from walker_ext import (
     ParliamentInfoWalker,
     SeekBindAttachmentsWalker,
     ProcessXmlFilesWalker,
     ProcessedAttsFilesWalker,
     SyncXmlFilesWalker
    )

LOG = Logger.getLogger("glue")

def __empty_output_dir__(folder):
    for the_file in os.listdir(folder):
        file_path = os.path.join(folder, the_file)
        try:
            os.unlink(file_path)
        except Exception, e:
            print e

def mkdir_p(path):
    try:
        os.makedirs(path)
    except os.error : # Python >2.5
        if os.error.errno == errno.EEXIST:
            pass
        else: raise

def __setup_tmp_dirs__(cfg):

    if not os.path.isdir(cfg.get_po_files_folder()):
        mkdir_p(cfg.get_po_files_folder())

    if not os.path.isdir(cfg.get_i18n_catalogues_folder()):
        mkdir_p(cfg.get_i18n_catalogues_folder())

def __setup_output_dirs__(cfg):

    if not os.path.isdir(cfg.get_xml_output_folder()):
        mkdir_p(cfg.get_xml_output_folder())
    else:
        __empty_output_dir__(cfg.get_xml_output_folder())        
    #if not os.path.isdir(cfg.get_ontoxml_output_folder()):
    #    mkdir_p(cfg.get_ontoxml_output_folder())
    #else:
    #    __empty_output_dir__(cfg.get_ontoxml_output_folder())
    if not os.path.isdir(cfg.get_attachments_output_folder()):
        mkdir_p(cfg.get_attachments_output_folder())
    else:
        __empty_output_dir__(cfg.get_attachments_output_folder())
    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())

def get_parl_info(cfg):
    """
    !+BICAMERAL
    Returns a list containing a map of active parliaments
    This list will have 2 maps in bicameral parliaments
    and 1 map when its unicameral 
    """
    piw = ParliamentInfoWalker({"main_config":cfg})
    """
    Check first if we have a cached copy
    """
    if piw.cache_file_exists():
        print "INFO: CACHED PARLIAMENT INFO  FILE EXISTS !"
        # if the cache file exists
        # get the parliament info from cache
        if piw.is_cache_full():
            print "INFO: GETTING PARLIAMENT INFO  FROM CACHE"
            return piw.get_from_cache()
        else:
            print "INFO: PARLIAMENT INFO CACHE IS NOT FULL"
            return _walk_get_parl_info(piw, cfg)
            # walk some more
    else:
        print "INFO: CACHED FILE DOES NOT EXIST, SEEKING INFO"
        return _walk_get_parl_info(piw, cfg)

def _walk_get_parl_info(piw, cfg):
    # !+BICAMERAL !+FIX_THIS returns a contenttype document, but should
    # instead return the extract from the cached parliament_info.xml document 
    # !+FIXED
    print "XXXXX WALKING INPUT FOLDER"
    piw.walk(cfg.get_input_folder())
    print "XXXX CHECKING IF CACHE FULL"
    if piw.is_cache_full():
        print "XXXX RETURNING FROM CACHE"
        return piw.get_from_cache()
    #if piw.object_info is None:
    #    return False
    #else:
    #    return piw.object_info
    else:
        print "XXXXX CACHE WAS NOT FULL WILL FAIL"
        return False



def param_parl_info(cfg, params):
    """
    Converts it to the transformers expected input form
    """
    li_parl_params = StringBuilder()
    li_parl_params.append(
        "<parliaments>"
        )
    li_parl_params.append(
           "<countryCode>%s</countryCode>"  % cfg.get_country_code()
        )
    for param in params:
        li_parl_params.append(
             ('<parliament id="%(parl_id)s">'
             " <electionDate>%(election_date)s</electionDate>"
             " <forParliament>%(for_parl)s</forParliament>"
             " <type>%(type)s</type>"
             "</parliament>") %  
             {
              "parl_id" : param["parliament_id"],
              "election_date": param["parliament-election-date"],
              "for_parl": param["for-parliament"],
              "type": param["type"]
              }
        )
    li_parl_params.append(
        "</parliaments>"
    )
    

def param_type_mappings():
    type_mappings_file = get_module_file("type_mappings.xml")
    type_mappings = open(type_mappings_file, "r").read()
    return type_mappings.encode("UTF-8")
    

def do_bind_attachments(cfg):
    # first we unzip the attachments using the GenericDirWalkerUNZIP 
    # so we get xml + attachments in a sub-folder
    unzipwalker = GenericDirWalkerUNZIP()
    unzipwalker.walk(cfg.get_input_folder())
    # Now the files are unzipped in sub-folders - so we process the XML 
    # for the attachments, the attachments are renamed to a unique id
    # and the reference reset in the source document
    sba = SeekBindAttachmentsWalker({"main_config":cfg})
    sba.walk(cfg.get_input_folder())
    if sba.object_info is not None:
        print COLOR.OKBLUE,"ATT: Found attachment ", COLOR.ENDC
    else:
        return sba.object_info

def do_po_translations(cfg, po_cfg, wd_cfg):
    """ translating .po files """
    print COLOR.OKGREEN + "Translating .po files to i18n xml <catalogue/> format..." + COLOR.ENDC
    pofw = POFilesTranslator({"main_config":cfg, "po_config" : po_cfg, "webdav_config" : wd_cfg})
    pofw.po_to_xml_catalogue()
    print COLOR.OKGREEN + "Completed translations from po to xml !" + COLOR.ENDC
    print COLOR.OKGREEN + "Commencing i18n catalogues upload to eXist-db via WebDav..." + COLOR.ENDC
    pofw.upload_catalogues()
    print COLOR.OKGREEN + "Catalogues uploaded to eXist-db !" + COLOR.ENDC

def do_transform(cfg, params):
    """
    Batch processor for XML documents
    """
    transformer = Transformer(cfg)
    transformer.set_params(params)
    print COLOR.OKGREEN + "Commencing transformations..." + COLOR.ENDC
    pxf = ProcessXmlFilesWalker({"main_config":cfg, "transformer":transformer})
    pxf.walk(cfg.get_input_folder())
    print COLOR.OKGREEN + "Completed transformations !" + COLOR.ENDC

def do_sync(cfg, wd_cfg):
    print COLOR.OKGREEN + "Syncing with eXist repository..." + COLOR.ENDC
    """ synchronizing xml documents """
    sxw = SyncXmlFilesWalker({"main_config":cfg, "webdav_config" : wd_cfg})

    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())

    sxw.create_sync_file()
    sxw.walk(cfg.get_xml_output_folder())
    sxw.close_sync_file()
    print COLOR.OKGREEN + "Completed synching to eXist !" + COLOR.ENDC

def webdav_upload(cfg, wd_cfg):
    print COLOR.OKGREEN + "Commencing XML files upload to eXist via WebDav..." + COLOR.ENDC
    """ uploading xml documents """
    # first reset bungeni xmls folder
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_xml_folder())
    webdaver.shutdown()
    # upload xmls at this juncture
    rsu = RepoSyncUploader({"main_config":cfg, "webdav_config" : wd_cfg})
    rsu.upload_files()
    print COLOR.OKGREEN + "Commencing ATTACHMENT files upload to eXist via WebDav..." + COLOR.ENDC
    """ now uploading found attachments """
    # first reset attachments folder
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_atts_folder())
    webdaver.shutdown()
    # upload attachments at this juncture
    pafw = ProcessedAttsFilesWalker({"main_config":cfg, "webdav_config" : wd_cfg})
    pafw.walk(cfg.get_attachments_output_folder())
    print COLOR.OKGREEN + "Completed uploads to eXist !" + COLOR.ENDC

def main_po_translate(config_file):
    """
    accepts the --po2xml option to translate .po files to i18n catalogue scheme
    used in the eXist-db
    """
    po_cfg = PoTranslationsConfig(config_file)
    wd_cfg = WebDavConfig(config_file)
    #ensure the tmp folder and its children are there or create them
    __setup_tmp_dirs__(po_cfg)
    do_po_translations(TransformerConfig(config_file), po_cfg, wd_cfg)


def main_transform(config_file):
    """
    process the -transform option by running the transformation
    """
    cfg = TransformerConfig(config_file)
    # create the output folders
    __setup_output_dirs__(cfg)
    print COLOR.HEADER + "Retrieving parliament information..." + COLOR.ENDC
    # look for the parliament document - and get the info which is used in the
    # following transformations
    parl_info = get_parl_info(cfg)
    if parl_info == False:
        print COLOR.FAIL,"ERROR: Could not find Parliament info :(", COLOR.ENDC
        sys.exit()
    print parl_info , "XXXX PARL_INFO XXX"
    if parl_info == None:
        print COLOR.FAIL, "PARLINFO is NULL"
        sys.exit()
    print COLOR.OKGREEN,"Retrieved Parliament info...", parl_info, COLOR.ENDC
    print COLOR.OKGREEN + "Seeking attachments..." + COLOR.ENDC
    do_bind_attachments(cfg)
    print COLOR.OKGREEN + "Done with attachments..." + COLOR.ENDC
    print COLOR.HEADER + "Transforming ...." + COLOR.ENDC      
    do_transform(
        cfg,
        {
         "parliament-info" : param_parl_info(cfg, parl_info),
         "type-mappings": param_type_mappings()
        } 
        )


def main_sync(config_file):
    wd_cfg = WebDavConfig(config_file)
    do_sync(TransformerConfig(config_file), wd_cfg)


def main_upload(config_file):
    """
    process the --upload option by calling the webdav upload
    """
    wd_cfg = WebDavConfig(config_file)
    webdav_upload(TransformerConfig(config_file), wd_cfg)

def update_refs(config_file):
    wd_cfg = WebDavConfig(config_file)
    print COLOR.OKGREEN + "Commencing Repository updates..." + COLOR.ENDC
    pt = PostTransform({"webdav_config": wd_cfg})
    pt.update()


def list_uniqifier(seq):
    #http://www.peterbe.com/plog/uniqifiers-benchmark
    # wary or RabbitMQ producer giving us duplicates in cases of overwriting a file 
    # pyinotify would register two events of the same thing. So uncool! :@
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if x not in seen and not seen_add(x)]

def main_queue(config_file, afile):
    """
    
    Entry Point for Queue invocation, processes one file at a time
    
    Serially processes XML/ZIP files from the message queue and 
    uploads to XML repository. Returns True/False to consumer
        True = Remove from queue
        False = Retain in queue for whatever reason
    
    @param config_file  configuration file
    @param afile        path to the serialized file
    
    @return Boolean 
    """
    print "[checkpoint] got file " + afile
    script_path = os.path.dirname(os.path.realpath(__file__))
    PropertyConfigurator.configure(script_path + File.separator + "log4j.properties")
    # comment above lines to run in emotional mode
    cfg = TransformerConfig(config_file)
    # create the output folders
    __setup_output_dirs__(cfg)
    wd_cfg = WebDavConfig(config_file)
    in_queue = False
    """
    Get parliament information
    """
    print "[checkpoint] getting parliament info"
    """
    !+BICAMERAL
    if its a bicameral legislature, then the parliament information must return 
    a list with 2 maps containing info about the 2 chambers
    otherwise a list with a map containing info about the chamber
    """
    parl_info = get_parl_info(cfg)
    if parl_info == False:
        return in_queue
    transformer = Transformer(cfg)
    input_map = {
        "parliament-info" : param_parl_info(cfg, parl_info),
        "type-mappings" : param_type_mappings()         
        }
    transformer.set_params(input_map)
    cfgs = {
        "main_config":cfg, 
        "transformer":transformer, 
        "webdav_config" : wd_cfg
    }
    pxf = ProcessXmlFilesWalker(cfgs)
    """
    Do Unzipping and Transformations
    """
    import fnmatch
    if os.path.isfile(afile):
        """
        Copy afile to temp_files_folder as working-copy(wc_afile)
        """
        temp_dir = cfg.get_temp_files_folder()
        wc_afile = temp_dir + os.path.basename(afile)
        shutil.copyfile(afile, wc_afile)
        print "[checkpoint] copied working-copy to temp folder"
        
        if fnmatch.fnmatch(afile, "*.zip") and os.path.isfile(wc_afile):
            print "[checkpoint] unzipping archive files"
            unzip = GenericDirWalkerUNZIP()
            temp_dir = cfg.get_temp_files_folder()
            unzip.extractor(afile, temp_dir)
            xml_basename = os.path.basename(wc_afile)
            xml_name = os.path.splitext(xml_basename)[0]
            new_afile = temp_dir + xml_name + ".xml"
            if os.path.isfile(new_afile):
                print "[checkpoint] found the unzipped XML file"
                # if there is an XML file inside then we have process its atts
                # descending upon the extracted folder
                bunparse = ParseBungeniXML(new_afile)
                parse_ok = bunparse.doc_parse()
                if parse_ok == False:
                    # Parsing error return to queue
                    return False
                print "[checkpoint] unzipped file parsed"
                sba = SeekBindAttachmentsWalker(cfgs)
                image_node = bunparse.get_image_file()
                if (image_node is not None):
                    print "[checkpoint] entered user/group doc path"
                    local_dir = os.path.dirname(afile)
                    print "[checkpoint] processing image/log_data file"
                    origi_name = sba.image_seek_rename(bunparse, temp_dir, True)
                else:
                    print "[checkpoint] entered attachments doc path"
                    sba.attachments_seek_rename(bunparse)

                print "[checkpoint] transforming the xml with zipped files"
                info_object = pxf.process_file(new_afile)
                # remove unzipped new_afile & wc_afile from temp_files_folder
                os.remove(new_afile)
                os.remove(wc_afile)
                if info_object[1] == True:
                    in_queue = True
                elif info_object[1] == False:
                    in_queue = False
                    return in_queue
                else:
                    print COLOR.WARNING, "No pipeline defined here ", COLOR.ENDC
                    in_queue = False
                    return in_queue
            else:
                print "[checkpoint] extracted " + new_afile + "] but not found :-J"
                in_queue = True
                return in_queue
        elif fnmatch.fnmatch(afile, "*.xml") and os.path.isfile(wc_afile):
            print "[checkpoint] transforming the xml"
            info_object = pxf.process_file(wc_afile)
            # remove wc_afile from temp_files_folder
            os.remove(wc_afile)
            if info_object[1] == True:
                print "[checkpoint] transformed the xml"
                in_queue = True
            elif info_object[1] == False:
                in_queue = False
                return in_queue
            elif info_object[1] == None:
                # mark parl-information document for removal from message-queue
                in_queue = True
                return in_queue
            else:
                print COLOR.WARNING, "No pipeline defined here ", COLOR.ENDC
                in_queue = False
                return in_queue
        else:
            # ignore any other file type, not interested with them currently...
            print "[" + afile + "] ignoring unprocessable filetype"
            in_queue = True
            return in_queue
    else:
        print "[" + afile + "] not found in filesystem"
        in_queue = True
        return in_queue

    """
    Do sync step
    """
    print "[checkpoint] entering sync"
    sxw = SyncXmlFilesWalker(cfgs)
    if not os.path.isdir(cfg.get_temp_files_folder()):
        mkdir_p(cfg.get_temp_files_folder())
    sxw.create_sync_file()
    # reaching here means there is a successfull file
    sync_stat_obj = sxw.sync_file(info_object[0])
    sxw.close_sync_file()
    print "[checkpoint] exiting sync"
    if sync_stat_obj[0] == True and sync_stat_obj[1] == None:
        # ignore upload -remove from queue
        in_queue = True
        return in_queue
    elif sync_stat_obj[0] == True:
        in_queue = True
    else:
        # eXist not responding?!
        # requeue and try later
        in_queue = False
        return in_queue

    """
    Do uploading to eXist
    """
    print COLOR.OKGREEN + "Uploading XML file(s) to eXist via WebDav..." + COLOR.ENDC
    print "[checkpoint] at", time.localtime(time.time())
    # first reset bungeni xmls folder
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_xml_folder())
    webdaver.shutdown()
    rsu = RepoSyncUploader({"main_config":cfg, "webdav_config" : wd_cfg})
    print "[checkpoint] uploading XML file"
    if in_queue == True:
        upload_stat = rsu.upload_file(info_object[0])
    else:
        in_queue = False
        return in_queue

    print COLOR.OKGREEN + "Uploading ATTACHMENT file(s) to eXist via WebDav..." + COLOR.ENDC
    webdaver = WebDavClient(wd_cfg.get_username(), wd_cfg.get_password())
    webdaver.reset_remote_folder(wd_cfg.get_http_server_port()+wd_cfg.get_bungeni_atts_folder())
    webdaver.shutdown()
    
    # upload attachments at this juncture
    pafw = ProcessedAttsFilesWalker({"main_config":cfg, "webdav_config" : wd_cfg})
    info_obj = pafw.process_atts(cfg.get_attachments_output_folder())
    if info_obj == True:
        in_queue = True
    else:
        return False
    print COLOR.OKGREEN + "Completed upload to eXist!" + COLOR.ENDC
    # do post-transform
    """
    !+FIX_THIS (ao,8th Aug 2012) PostTransform degenerates and becomes and expensive process 
    over-time temporarily disabled.
    """
    pt = PostTransform({"webdav_config": wd_cfg})
    print "Initiating PostTransform request on eXist-db for URI =>", sync_stat_obj[1]
    info_object = pt.update(str(sync_stat_obj[1]))
    
    if info_object == True:
        in_queue = True
    else:
        in_queue = False
    return in_queue


def main(options):
    """
    Entry point for command line invocation
    """
    # parse command line options if any
    try:
        # first get the configuration file from the command line
        config_file = __parse_options(options, ("-c", "--config"))
        # transform and upload are independent options and can be called individually
        if config_file is not None and len(str(config_file)) > 0 :

            translate = __parse_options(options, ("-p", "--po2xml"))
            if translate is not None:
                main_po_translate(config_file)

            transform = __parse_options(options, ("-t", "--transform"))
            if transform is not None:
                main_transform(config_file)

            sync = __parse_options(options, ("-s", "--synchronize"))
            if sync is not None:
                #perform sync at this juncture
                main_sync(config_file)

            upload = __parse_options(options, ("-u", "--upload"))
            if upload is not None:
                main_upload(config_file)
                # perform post-transform URI reference fixes if any
                update_refs(config_file)
            else:
                print "upload not specified"
        else:
            print COLOR.FAIL," config.ini specified incorrectly !",COLOR.ENDC
    except getopt.error, msg:
        print msg
        print COLOR.FAIL + "There was an exception during startup !" + COLOR.ENDC
        sys.exit(2)
        
        
def __parse_options(options, look_for=()):
    input_arg = None
    for opt,arg in options:
        if opt in look_for:
            input_arg = arg
    return input_arg

if __name__ == "__main__":
    """
    Five command line parameters are supported
    
      --config=config_file_name - specifies the config file name
      --po2xml - translates po files to xml for i18n in eXisd-db
      --transform - runs a transform
      --synchronize - synchronizes with a xml db
      --upload - uploades to a xml db
    """
    
    script_path = os.path.dirname(os.path.realpath(__file__))
    if (len(sys.argv) > 1):
        #from org.apache.log4j import PropertyConfigurator
        PropertyConfigurator.configure(script_path + File.separator + "log4j.properties")
        # process input command line options
        options, remainder = getopt.getopt(sys.argv[1:], 
          "c:ptsu",
          ["config=", "po2xml","transform","synchronize","upload"]
        )
        # call main
        main(options)
    else:
        print COLOR.FAIL , " config.ini file must be an input parameter " , COLOR.ENDC
