

# Introduction #

The BungeniGlueScript is a Jython script that provides various options to synchronizes outputs from Bungeni Portal with the eXist-db XML repository, Mainly the raw xml output that is generated in workflow steps.

# Pre-requisites #

  * Jython (2.5 or greater) - Can be found on the Jython Project website (see http://www.jython.org/ )
  * Install polib in the jython:
    * Run ez\_setup.py using the Jython interpreter (from http://peak.telecommunity.com/dist/ez_setup.py ) to install setuptools on Jython
    * Run easy\_install polib from the Jython installation to setup polib in jython

The steps are described below :
```
JYTHON_HOME=~/apps/jython2.5.2
wget http://peak.telecommunity.com/dist/ez_setup.py
$JYTHON_HOME/bin/jython ez_setup.py
$JYTHON_HOME/bin/easy_install polib
```

# Setup #

Checkout the framework from svn :

```
svn co https://bungeni-exist.googlecode.com/svn/glue/trunk bungeni-glue
```

This will download the project to a folder name `bungeni-glue`

The structure of the project should resemble the tree below:

```
|-- lib
|-- outputs
|   |-- an-output
|   |-- atts-output
|   `-- on-output
|-- res
|   |-- resources
|-- src
|   |-- config.ini
|   |-- glue.py
|   `-- log4j.properties
|-- tmp
|   |-- i18n
|   |-- po-files
|   `-- reposync.xml
|-- xml_db
`-- exec.sh
```

The `tmp` and `output` folders are run-time folders that will be generated during execution depending on the task.

In order to execute your first command, you will have to edit the JYTHON\_PATH in the `exec.sh` executable to where you have installed Jython.

```
export JYTHON_PATH=~/apps/jython2.5.2/jython.jar
```

Once done. Proceed to usage below.

NB: To immediately run XML transformations, you need to set the path where the XML documents can be found in the **`[general]`** section of the configuration file.

# Usage #

The script depends on several Java libraries which are required to execute the various tasks provided as options. All the dependencies are part of the glue repository project and will be available when you checkout the project as shown above. [BungeniGlueScript#Setup](BungeniGlueScript#Setup.md).

The below snippet shows how to transform raw XML output from Bungeni portal to ontology xml format.

```
./exec.sh -c src/config.ini --transform
```

There are currently four options provided to execute xml transformation and sync tasks.

  * po2xml - translates .po files to i18n xml catalogues
  * transform - Transforms raw Bungeni XML documents to specific ontology xml
  * synchronize - Synchronizes the XML repository with newly transformed Bungeni XML output
  * upload - Uploads transformed ontology documents and attachments to the eXist-db XML repository

All the options have a short-hand, single-character option switch instead of the name.

## po2xml ##

The main Bungeni application uses .po files for storing internationalization messages. Meanwhile in eXist-db, the i18n module uses a XML catalogues with key-message structure. The `--po2xml` option performs this translation.

```
./exec.sh -c src/config.ini --po2xml
```

The short-hand for transform option is `-p`

## transform ##

The transform option takes raw XML output from Bungeni and converts them to a specific XML ontology format used in the XML-UI. It also extracts archive files, XML documents and attachments found will be transformed and linked accordingly.

```
./exec.sh -c src/config.ini --transform
```

The short-hand for transform option is `-t`

## synchronize ##

NB: This option requires prior execution of the `--transform` option has or is executed simultaneously.

Synchronize option compares the transformed ontology XMLs with the XML collection in eXist-db repository. It generates an XML file listing all the files that need to be uploaded to the repository.

```
./exec.sh -c src/config.ini --synchronize
```

The short-hand for synchronize option is `-s`

## upload ##

Upload option checks the output folders with transformed documents or any attachments and uploads them to the repository via WebDAV protocol. The resource folders for storing XML documents and their attachments are defined in the [BungeniGlueScript#Configuration\_file](BungeniGlueScript#Configuration_file.md). Parameters relating to uploading documents can be altered in the `[webdav]` section of configuration.

```
./exec.sh -c src/config.ini --upload
```

The short-hand for transform option is `-u`

To run all the above options simultaneously:

```
./exec.sh -c src/config.ini -tsu
```

The above command will first do a transformation out the raw XML output including extracting archived files. Thereafter, synchronize with eXist-db repository to find out which files need to be uploaded based on status-date of the document. Finally, upload the files based on the synchronization file that has been generated in the project's `tmp` folder.

# Configuration file #

There is a configuration option which provides all parameters necessary for smooth execution. The **config.ini** is a mandatory option in executing the BungeniGlueScript as it contains all the customizable parameters, temporary folder and output folder locations.


Generally, the default parameters in the configuration file suffice but can be altered.