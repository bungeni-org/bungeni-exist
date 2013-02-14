'''
Created on Feb 14, 2013

@author: undesa
'''

import os

from net.lingala.zip4j.core import ZipFile
from net.lingala.zip4j.exception import ZipException

from org.apache.log4j import Logger

from utils import _COLOR

LOG = Logger.getLogger("glue")



class GenericDirWalker(object):
    """
    Walks a directory tree and invokes a
    callback API for every file in the tree
    """
    
    def __init__(self, input_params = None):
        """
        input_params - the parameters for the callback function
        """
        self.counter = 0
        self.object_info = None
        self.input_params = input_params

    def walk(self, folder):
        """ 
        walk a folder and recursively walk through sub-folders
        for every file in the folder call the processing function
        """
        folder = os.path.abspath(folder)
        for a_file in [
          a_file for a_file in os.listdir(folder) if not a_file in [".",".."]
          ]:
            nfile = os.path.join(folder, a_file)
            if os.path.isdir(nfile):
                self.walk(nfile)
            else:
                # increment the counter in the callback
                # This is the tuple returned from the Implementing class
                # (False, anObject) or (True, anObject)
                info_object = self.fn_callback(nfile)
                if info_object[0] == True:
                    self.object_info = info_object[1]
                    break
                else:
                    continue

    def fn_callback(self, nfile):
        LOG.debug("in GenericDirWalker BASE callback" + nfile)
        return (False, None)


class GenericDirWalkerXML(GenericDirWalker):
    """
    Walks a directory tree, but the callback filters on for 
    XML documents
    """

    def fn_callback(self, nfile):
        import fnmatch
        LOG.debug("in GenericDirWalker XML callback" + nfile)
        if fnmatch.fnmatch(nfile, "*.xml"):
            self.counter = self.counter + 1
            LOG.debug("returning TRUE GenericDirWalker XML callback" + nfile )
            return (True, None)
        else:
            LOG.debug("returning FALSE GenericDirWalker XML callback" + nfile )
            return (False,None)


class GenericDirWalkerATTS(GenericDirWalker):
    """
    grabs anyfile in the attachments folder no discrimination by filetype
    """
    
    def fn_callback(self, nfile):
        LOG.debug("in GenericDirWalker ATTS callback" + nfile)
        if nfile:
            self.counter = self.counter + 1
            LOG.debug("returning TRUE GenericDirWalker XML callback" + nfile )
            return (True, None)
        else:
            LOG.debug("returning FALSE GenericDirWalker XML callback" + nfile )
            return (False,None)


class GenericDirWalkerUNZIP(GenericDirWalker):

    def extractor(self, zip_file, dest_path = None):
        """
        extracts any .zip files in folder matching original name file.
        http://www.lingala.net/zip4j/
        """
        try:
            #Initiate ZipFile object with the path/name of the zip file.
            unzipper = ZipFile(zip_file)
            if dest_path is not None:
                extract_to = dest_path
            else:
                extract_to = os.path.splitext(zip_file)[0]
            #Extracts all files to the path specified
            unzipper.extractAll(extract_to)
            print _COLOR.WARNING + "Extracted zip file... " + zip_file+_COLOR.ENDC
        except ZipException, e:
            LOG.error("Error while processing zip "+ zip_file + e)

    def fn_callback(self, nfile):
        import fnmatch
        #print "in GenericDirWalker ZIP callback" , nfile
        if fnmatch.fnmatch(nfile, "*.zip"):
            self.counter = self.counter + 1
            self.extractor(nfile)
            #print "returning TRUE GenericDirWalker ZIP callback" , nfile
            # There is no extended processing here - we just continue until 
            # we have run out of zip files to process, so we return False
            # so as to not break the loop
            return (False, None)
        else:
            #print "returning FALSE GenericDirWalker ZIP callback" , nfile
            return (False,None)
