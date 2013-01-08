xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";


if ($exist:path eq '') then
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<redirect url="admin/index.xql"/>
	</dispatch>
else if ($exist:path eq '/') then
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<redirect url="index.xql"/>
	</dispatch>		
else
    (: everything else is passed through :)
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>