xquery version "3.0";
 
if ($exist:path eq '/') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    	<redirect url="index.xql"/>
    </dispatch>            
else if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    	<redirect url="configeditor/index.xql"/>
    	<set-attribute name="q" value="home"/>
    </dispatch>
else
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="no"/>
    </ignore>