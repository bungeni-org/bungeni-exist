xquery version "3.0";

(:
    Storing bungeni_custom from file-system
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

(:
: write the CONFIGS-COLLECTION back to the file-system location they were retrieved from.
:)
declare function local:reverse-transform-configs() {

    for $doc in collection($appconfig:CONFIGS-FOLDER)
    let $login := xmldb:login($appconfig:ROOT, "admin", "")
    let $path := document-uri($doc)
    (: form XSLTs:)
    let $step1forms := appconfig:get-xslt("forms_merge_step1.xsl")
    let $step2forms := appconfig:get-xslt("forms_merge_step2.xsl")
    (: workflow XSLTs:)
    let $xslworkflow := appconfig:get-xslt("wf_merge_attrs.xsl")
    
    let $filename := functx:substring-after-last($path, '/')
    return
            if (contains($path,"/forms/")) then (
                $filename || " written? " || file:serialize(transform:transform(
                                                transform:transform($doc, $step1forms,()), $step2forms,()), 
                                                $appconfig:CONFIGS-FOLDER || "/forms/" || $filename,
                                                "media-type=application/xml method=xml")         
            ) 
            else if (contains($path,"/workflows/")) then (
               $filename || " written? " || file:serialize(transform:transform(
                                                $doc, $xslworkflow, ()),
                                                $appconfig:CONFIGS-FOLDER || "/workflows/" || $filename,
                                                "media-type=application/xml method=xml")
            )
            else
                ()

};

let $login := xmldb:login($appconfig:ROOT, "admin", "")
let $storing := local:reverse-transform-configs()
(: check for something that definitely has to be there in the sequence :)
let $uploadstate := if (contains($storing,"ui.xml")) then true() else false()
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
                                <h2>Sync was successful: written back to file-system</h2>
                                <br/>
                                <div style="float:left">
                                    <h1>written</h1>
                                    <ol>{
                                    for $one in $storing    
                                        return <li>{$one}</li>
                                     }</ol>   
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