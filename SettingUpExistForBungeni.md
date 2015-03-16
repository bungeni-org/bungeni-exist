

# Introduction #

This page documents how to build [eXist XML db](http://www.exist-db.org) for Bungeni deployment.

# Pre-requisites #

  * Working JDK installation (1.6)


# Build using the shell script #

Check-out the eXist source from svn :
```
svn co https://svn.code.sf.net/p/exist/code/stable/eXist-2.0.x/ exist-2.0
```

We use the 2.0 stable branch for Bungeni deployment.

Now get the shell script to build eXist for Bungeni :
```
svn export http://bungeni-exist.googlecode.com/svn/exist_build/trunk/build_exist_rev.sh
```

To run it, it takes 3 parameters :
```
./build_exist_rev.sh HEAD ./exist-2.0 scriba
```

**parameter 1** - the revision number of eXist - this can be a number or HEAD
**parameter 2** - the path to the folder where the eXist source code has been checked out
**parameter 3** - this is optional - and takes only the value `scriba`, indicating it builds scriba and enables the scriba module

Once the script has finished running - it will create a tar archive with the built exist in the form `exist_r<rev no>.tar.gz`

# Building from Source Manually #

## Building eXist ##

First, read these instructions [http://exist-db.org/exist/building.xml](http://exist-db.org/exist/building.xml)


Checkout source of eXist into a separate folder

```
svn co http://svn.code.sf.net/p/exist/code/stable/eXist-2.0.x/ ~/eXist
```

Configure extensions, by enabling XSLFO module, edit ~/eXist/extensions/build.properties and enable the xslfo module :
```
# XSL FO transformations (Uses Apache FOP)
include.module.xslfo = true
```

## Adding ePUB module ##

### Installing Ebook Maker ###

The ePUB module is based on Scriba Ebook Maker Project (see [http://scribaebookmake.sourceforge.net). This was extended with an API to allow eXist-db access the library's functionality.

Download it from: http://bungeni-exist.googlecode.com/files/scriba-ebook-maker.tar.gz

See the folder structure once extracted:
```
scriba-ebook-maker/
├── lib/
└── scriba-ebook-maker.jar
```
Copy the contents (`lib` directory and the `.jar` file) into `~/eXist/lib/user/`

### Setting up ePUB Module ###

Export source of ePUB Module into the extensions folder in eXist

```
svn export http://bungeni-exist.googlecode.com/svn/exist-scriba/trunk/epub ~/eXist/extensions/modules/src/org/exist/xquery/modules/epub
```

Now build eXist using ant

```
JAVA_HOME=/path/to/java/home ./build.sh all
```


## Configuring the Installation ##

  * Activate the compression, datetime, ePUB and XSLFOModule modules in conf.xml :
```
      <!-- Required modules -->
         <module uri="http://exist-db.org/xquery/xslfo" class="org.exist.xquery.modules.xslfo.XSLFOModule">
            <parameter name="processorAdapter" value="org.exist.xquery.modules.xslfo.ApacheFopProcessorAdapter"/>
         </module>
         <module uri="http://exist-db.org/xquery/epub" class="org.exist.xquery.modules.epub.EpubModule" />

      <!-- Optional Modules -->
         <module class="org.exist.backup.xquery.BackupModule"
                    uri="http://exist-db.org/xquery/backups"/>
         <module class="org.exist.xquery.modules.compression.CompressionModule"
                    uri="http://exist-db.org/xquery/compression" />
         <module class="org.exist.xquery.modules.datetime.DateTimeModule"
                    uri="http://exist-db.org/xquery/datetime" />
```
  * Change the default transformer to Saxon :
```
   <transformer class="net.sf.saxon.TransformerFactoryImpl"/>
```
  * Add a reference to the schema in ~/eXist/webapp/WEB-INF/catalog.xml :
```
     <catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
        <uri name="http://www.akomantoso.org/1.0" uri="xmldb:exist:///db/bungeni/grammar/akomantoso10.xsd" />
	..........
     </catalog>
```