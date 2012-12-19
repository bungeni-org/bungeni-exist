xquery version "3.0";

(:
    Storing bungeni_custom from file-system
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/xml";

let $root-coll := "/db"
let $fs-bu-custom := xs:string(request:get-parameter("fs_path",""))
let $ex-bu-custom := "bungeni_custom"
let $bu-custom-coll := $root-coll || "/" || $ex-bu-custom
let $ex-working-copy := $root-coll || "/" || "config_editor"

let $login := xmldb:login($root-coll, "admin", "")
let $created_bc := if (xmldb:collection-available($bu-custom-coll)) then () else xmldb:create-collection($root-coll,$ex-bu-custom)
let $storing := xmldb:store-files-from-pattern($bu-custom-coll, $fs-bu-custom, "**/*.xml",'application/xml',true())
let $make-working-copy := xmldb:copy($bu-custom-coll,$ex-working-copy)
return
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:exist="http://exist.sourceforge.net/NS/exist"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>Sys process</title>
    </head>
    <body class="nihilo InlineBordersAlert">
    	<div id="xforms">  	
            <div style="width: 100%; height: auto;">
                    <h1>Storing files from file-system </h1>
                    <span>
                        <a href="javascript:location.reload();">reload page</a>
                    </span>  
                    <br/>
                    <ul>{
                    for $one in $storing    
                        return <li>{$one}</li>
                     }</ul>
            </div>                    
        </div>
    </body>
</html>