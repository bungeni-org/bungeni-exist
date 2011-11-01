export JYTHON_PATH=~/apps/jython2.5.2/jython.jar
export CLASSPATH=./lib/jaxen/jaxen-1.1.1.jar:./lib/xerces/xercesImpl.jar:./lib/saxon/saxon9he.jar:./lib/dom4j/dom4j-1.6.1.jar:./lib/log4j/log4j.jar:/lib/bungeni/editorplugininterface.jar:./lib/transformer/odttransformer-generic.jar:./lib/commons-lang/commons-lang-2.3.jar:./lib/jsoup/jsoup-1.6.1.jar
java -cp $JYTHON_PATH:$CLASSPATH org.python.util.jython ./src/glue.py $1 
