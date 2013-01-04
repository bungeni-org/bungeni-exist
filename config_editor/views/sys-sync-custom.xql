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
(:let file:serialize($node-set* as node(), $path as item(), $parameters* as xs:string):) 
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
                                <h2>Sync was successful: written back to file-system
                                <br/>
                                <div style="float:left">
                                    <h1>written</h1>
                                    <ol>{
                                    for $one in $storing    
                                        return <li>{$one}</li>
                                     }</ol>   
                                </div>
                                <div style="float:right">
                                    <h1>transformed back</h1>
                                    <ol>{for $entry in $transform-working-copy
                                    return <li>{$entry}</li> }</ol>
                                </div>                               
                            </div>
                        case false() return
                            <div>
                                <h2>Sync was unsuccessful</h2>
                                <span>
                                    Ensure the <i>bungeni_custom</i> folder of your Bungeni application on the file-system is writable. 
                                </span>                            
                            </div>
                        default return
                            ()
                    }
            </div>                    
        </div>
    </body>
</html>