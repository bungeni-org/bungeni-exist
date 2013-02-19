#export JYTHON_PATH=~/apps/jython2.5.2/jython.jar
# set JYTHON_PATH on the command line
export CLASSPATH=./lib/jaxen/jaxen.jar:./lib/xerces/xercesImpl.jar:./lib/saxon/saxon9he.jar:./lib/dom4j/dom4j-1.6.1.jar:./lib/log4j/log4j.jar:/lib/bungeni/editorplugininterface.jar:./lib/transformer/odttransformer.jar:./lib/commons-lang/commons-lang-2.3.jar:./lib/jsoup/jsoup-1.6.1.jar:./lib/zip4j/zip4j_1.2.8.jar:./lib/sardine/sardine.jar:./lib/sardine/httpclient-4.2.jar:./lib/sardine/httpcore-4.2.1.jar:./lib/sardine/slf4j-api-1.6.2.jar:./lib/sardine/commons-logging-1.1.1.jar:./lib/sardine/commons-codec-1.4.jar:./lib/rabbitmq/rabbitmq-client.jar:./lib/rabbitmq/mime-util-2.1.3.jar:./lib/jyson/jyson-1.0.2.jar
java -cp $JYTHON_PATH:$CLASSPATH org.python.util.jython ./src/glue.py $* 
