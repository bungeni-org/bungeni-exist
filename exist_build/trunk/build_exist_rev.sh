
if [ -z "$1" ]; then
  echo "You need at least specify a revision number"
  exit 91
fi

EXIST_REPO="svn://svn.code.sf.net/p/exist/code/trunk/eXist"
# Exist Revision
EXIST_REV=$1

if [ -z "$2" ]; then
  # if source folder is not specified
  CURDIR=`pwd`
  EXIST_FOLDER=$CURDIR"/exist-code"
  if [ ! -d "$EXIST_FOLDER" ]; then
      svn co $EXIST_REPO $EXIST_FOLDER -r$EXIST_REV
  else
      svn up -r$EXIST_REV $EXIST_FOLDER
  fi
else
  EXIST_FOLDER=$2
  if [ ! -d "$EXIST_FOLDER" ]; then
      echo " Folder for exist source $EXIST_FOLDER does not exist ! "
      exit 98
  fi
fi

if [ -z "$JAVA_HOME" ]; then
   echo "JAVA_HOME is not set ! Please set JAVA_HOME before executing this script"
   exit 99
fi


echo "Attempting to rebuild exist " 
echo "Copying exist source for fresh build"

if [ $EXIST_REV == 'HEAD' ]; then
   echo "Resolving HEAD to a revision number..."
   EXIST_REV=`cd $EXIST_FOLDER && svn info -r 'HEAD' |grep Revision: |cut -c11-`
   echo " HEAD is at $EXIST_REV"
fi

EXIST_INST=exist_r$EXIST_REV
EXIST_INST_PATH=`pwd`/$EXIST_INST

rm -rf $EXIST_INST_PATH/*
cp -R $EXIST_FOLDER/* $EXIST_INST_PATH/
echo "Preparing eXist installation"
cd $EXIST_INST_PATH 
echo "Setting db-connection cache size to 96M"
sed -i 's/<db-connection cacheSize="48M"/<db-connection cacheSize="96M"/g' ./conf.xml.tmpl
echo "Enabling datetime module"
sed -i 's|</builtin-modules>|<module uri="http://exist-db.org/xquery/datetime" class="org.exist.xquery.modules.datetime.DateTimeModule" /></builtin-modules>|g' ./conf.xml.tmpl
echo "Enabling epub module in configuration"
sed -i 's|</builtin-modules>|<module uri="http://exist-db.org/xquery/epub" class="org.exist.xquery.modules.epub.EpubModule" /></builtin-modules>|g' ./conf.xml.tmpl
echo "Enabling xslfo module"
sed -i 's/include.module.xslfo = false/include.module.xslfo = true/g' ./extensions/build.properties

echo "Setting up Scriba epub plugin"

SCRIBA_DIR=../tmp_scriba
SCRIBA_MODULE_DIR=$EXIST_INST_PATH/extensions/modules/src/org/exist/xquery/modules/epub
SCRIBA_XQ_MODULE="http://bungeni-exist.googlecode.com/svn/exist-scriba/trunk/epub"
SCRIBA_DOWN_FILE=scriba-ebook-maker.tar.gz

mkdir -p $SCRIBA_DIR
if [ -f $SCRIBA_DIR/$SCRIBA_DOWN_FILE ];
then
    echo "Scriba module archive already exists, attempting to use existing one..."
else
    echo "Downloading Scriba module archive..."
    rm -rf  $SCRIBA_DIR/*
    wget http://bungeni-exist.googlecode.com/files/scriba-ebook-maker.tar.gz -P  $SCRIBA_DIR
fi

tar xvf $SCRIBA_DIR/scriba-ebook-maker.tar.gz -C $SCRIBA_DIR --strip-components=1
echo "Copying license information"
cp -R $SCRIBA_DIR/lib/License $EXIST_INST_PATH/lib/user/scriba_license

echo "Copying scriba specific libraries"
cp  $SCRIBA_DIR/scriba-ebook-maker.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/bcprov-jdk16-146.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/boilerpipe-1.2.0.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/dom4j-2.0.0-ALPHA-2.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/epubcheck-1.2.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/Filters.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/fontbox-1.6.0.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/jai_imageio-1.1.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/java-image-scaling-0.8.5.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/jempbox-1.6.0.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/jing.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/jsoup-1.5.2.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/jtidy-r918.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/juniversalchardet-1.0.3.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/pdfbox-1.6.0.jar $EXIST_INST_PATH/lib/user
cp  $SCRIBA_DIR/lib/commons-cli-1.2.jar $EXIST_INST_PATH/lib/user

echo "Scriba Jar Ignore List :"
echo commons-codec-1.5.jar
echo commons-io-2.0.1.jar
echo log4j.jar
echo nekohtml-1.9.13.jar
echo saxon.jar
echo xalan.jar
echo xerces-2.9.1.jar

echo "Updating libraries in eXist used by Scriba"
echo "Adding commons-lang3 to eXist side by side with commons-lang 2.x"
cp  $SCRIBA_DIR/lib/commons-lang3-3.1.jar $EXIST_INST_PATH/lib/user

echo "Installing Scriba XQuery module"
svn export $SCRIBA_XQ_MODULE $EXIST_INST_PATH/extensions/modules/src/org/exist/xquery/modules/epub --force
echo "Removing .svn files from the exist installation folder"
find . -name '.svn' -print0 | xargs -0 rm -rf 

echo "Building eXist installation in $EXIST_INST"
JAVA_HOME=$JAVA_HOME ./build.sh rebuild
cd ..
echo "Cleaning up build"
rm -rf ./$EXIST_INST/src
rm -rf ./$EXIST_INST/build
rm -rf ./$EXIST_INST/installer
rm -rf ./$EXIST_INST/test
find ./$EXIST_INST -name '*.java' | xargs rm -rf
echo "Building deployment archive"
tar cvzf ./$EXIST_INST.tar.gz ./$EXIST_INST
echo "Generated $EXIST_INST.tar.gz"

