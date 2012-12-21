xquery version "3.0";

(:
    Storing bungeni_custom from file-system
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace cfg = "http://bungeni.org/xquery/config" at "../config.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

let $root-coll := "/db"
let $fs-bu-custom := xs:string(request:get-parameter("fs_path",""))
let $ex-bu-custom := "bungeni_custom"
let $bu-custom-coll := $root-coll || "/" || $ex-bu-custom
let $ex-editor-coll := $root-coll || "/" || "config_editor"
let $ex-working-copy :=$ex-editor-coll || "/" || $ex-bu-custom

let $login := xmldb:login($root-coll, "admin", "")
let $created_bu_wc := if (xmldb:collection-available($ex-working-copy)) then () else xmldb:create-collection($ex-editor-coll,$ex-bu-custom)
let $storing := xmldb:store-files-from-pattern($ex-working-copy, $fs-bu-custom, "**/*.xml",'application/xml',true())
(: types.xml is the arch document. Its important to find it as guaranttee that the correct folder path was given :)
let $uploadstate := if (contains($storing,"types.xml")) then true() else false()
(: copying the original copy before we tranform the working copy :)
let $store-new-original := xmldb:copy($ex-working-copy,$root-coll)
let $transform-working-copy := cfg:transform-configs($storing)
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
                    {
                        switch($uploadstate)
                
                        case true() return
                            <div>
                                <h2>Upload was successful: <a href="javascript:location.reload();">reload page</a></h2>
                                <br/>
                                <div style="float:left">
                                    <h1>uploaded</h1>
                                    <ol>{
                                    for $one in $storing    
                                        return <li>{$one}</li>
                                     }</ol>   
                                </div>
                                <div style="float:right">
                                    <h1>transformed</h1>
                                    <ol>{for $entry in $transform-working-copy
                                    return <li>{$entry}</li> }</ol>
                                </div>                               
                            </div>
                        case false() return
                            <div>
                                <h2>Upload was unsuccessful</h2>
                                <span>
                                    Ensure you put the correct absolute-path to the <i>bungeni_custom</i> folder of your Bungeni application
                                </span>                            
                            </div>
                        default return
                            ()
                    }
            </div>                    
        </div>
    </body>
</html>