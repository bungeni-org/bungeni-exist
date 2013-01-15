xquery version "3.0";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;

(:~
    : Modify document by renaming the file name 
    
    : @author Anthony Oduor <aowino@googlemail.com>
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

let $CXT := request:get-context-path()
let $DOCNAME := xs:string(request:get-parameter("doc","none"))
let $NEWNAME := xs:string(request:get-parameter("rename","none"))
let $login := xmldb:login('/db', $appconfig:admin-username, $appconfig:admin-password)
let $log := util:log('info',"AOLAA" || $appconfig:FORM-FOLDER || $DOCNAME || $NEWNAME)
let $form := xmldb:rename($appconfig:FORM-FOLDER, $DOCNAME, $NEWNAME)
let $workflow := xmldb:rename($appconfig:WF-FOLDER, $DOCNAME, $NEWNAME)
let $workspace := xmldb:rename($appconfig:WS-FOLDER, $DOCNAME, $NEWNAME)
return
    <ul class="secondary">
        <li><a href="#">{$DOCNAME}</a></li>
        <li><a href="#">form &#187;</a></li>
        <li><a href="#">worklow &#187;</a></li>
        <li><a href="#">workspace &#187;</a></li>
        <li><a href="#">notification &#187;</a></li>
    </ul>