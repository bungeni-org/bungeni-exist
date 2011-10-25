export JYTHON_PATH=~/apps/jython2.5.2/jython.jar
export CLASSPATH=./lib/jaxen-1.1.1.jar:./lib/xercesImpl.jar:./lib/saxon9-dom.jar:./lib/saxon9.jar:./lib/saxon9-xpath.jar:./lib/saxon9-s9api.jar:./lib/dom4j-1.6.1.jar:./lib/log4j.jar:./lib/bungenirestlet.jar:./lib/editorextinterfaces.jar:./lib/editorplugininterface.jar:./lib/odttransformer.jar
java -cp $JYTHON_PATH:$CLASSPATH org.python.util.jython ./glue.py $1 
