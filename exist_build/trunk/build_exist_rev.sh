EXIST_REPO="svn://svn.code.sf.net/p/exist/code/trunk/eXist"
if [ -z "$1" ]; then
  echo "You need at least specify a revision number"
  exit 91
fi

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
   EXIST_REV=`cd $EXIST_FOLDER && svn info -r 'HEAD' |grep Revision: |cut -c11-`
   echo " HEAD is at $EXIST_REV"
fi

EXIST_INST=exist_r$EXIST_REV
cp -R $EXIST_FOLDER $EXIST_INST
echo "Preparing eXist installation"
cd $EXIST_INST 
echo "Setting db-connection cache size to 96M"
sed -i 's/<db-connection cacheSize="48M"/<db-connection cacheSize="96M"/g' ./conf.xml.tmpl
echo "Enabling datetime module"
sed -i 's|</builtin-modules>|<module uri="http://exist-db.org/xquery/datetime" class="org.exist.xquery.modules.datetime.DateTimeModule" /></builtin-modules>|g' ./conf.xml.tmpl
echo "Enabling xslfo module"
sed -i 's/include.module.xslfo = false/include.module.xslfo = true/g' ./extensions/build.properties

echo "Setting up scriba plugin"
SCRIBA_DIR=../tmp_scriba
mkdir -p $SCRIBA_DIR
rm -rf  $SCRIBA_DIR/*.*
wget http://bungeni-exist.googlecode.com/files/scriba-ebook-maker.tar.gz -P  $SCRIBA_DIR
tar xvf  $SCRIBA_DIR/scriba-ebook-maker.tar.gz  $SCRIBA_DIR

echo "Copying license information"
cp -R $SCRIBA_DIR/License $EXIST_INST/lib/user/scriba_license

echo "Copying scriba specific libraries"
cp  $SCRIBA_DIR/bcprov-jdk16-146.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/boilerpipe-1.2.0.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/dom4j-2.0.0-ALPHA-2.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/epubcheck-1.2.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/Filters.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/fontbox-1.6.0.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/jai_imageio-1.1.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/java-image-scaling-0.8.5.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/jempbox-1.6.0.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/jing.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/jsoup-1.5.2.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/jtidy-r918.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/juniversalchardet-1.0.3.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/pdfbox-1.6.0.jar $EXIST_INST/lib/user
cp  $SCRIBA_DIR/commons-cli-1.2.jar $EXIST_INST/lib/user

echo "Jar Ignore List :"
echo commons-codec-1.5.jar
echo commons-io-2.0.1.jar
echo log4j.jar
echo nekohtml-1.9.13.jar
echo saxon.jar
echo xalan.jar
echo xerces-2.9.1.jar

echo "Updating libraries in eXist used by Scriba"
echo "Adding commons-lang3 to eXist side by side with commons-lang 2.x"
cp  $SCRIBA_DIR/commons-lang3-3.1.jar $EXIST_INST/lib/user



echo "Removing .svn files from the exist installation folder"
find . -name '.svn' -print0 | xargs -0 rm -rf 

#cd $EXIST_INST && JAVA_HOME=$JAVA_HOME ./build.s

echo "Exist folder = $EXIST_FOLDER"
