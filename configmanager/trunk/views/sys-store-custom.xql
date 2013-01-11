xquery version "3.0";

(:
    Storing bungeni_custom from file-system
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace functx = "http://www.functx.com" at "../modules/functx.xqm";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "../modules/appconfig.xqm";

declare option exist:serialize "method=xhtml media-type=text/xml";

(:
: Stores the path that successfully loads bungeni_custom files into eXist-db
:)
declare function local:update-fs-path($fs-bu-custom-path as xs:string) {
    
    let $config-doc := doc($appconfig:ROOT || "/config.xml")
    return 
        update replace $config-doc//configs/fs-path/text() with $fs-bu-custom-path
};


declare function local:transform-configs($file-paths) {
    for $store in $file-paths
    let $login := xmldb:login($appconfig:ROOT, "admin", "")
    let $resource := functx:substring-after-last($store, '/')
    let $collection := functx:substring-before-last($store, '/')
    return
        if (contains($store,"/forms/")) then (
            xmldb:store($collection, $resource, local:split-form($store), "application/xml")            
        ) 
        else if (contains($store,"/workflows/")) then (
            xmldb:store($collection, $resource, local:split-workflow($store), "application/xml")  
        )
        else
            ()
};

declare function local:split-form($form-path as xs:string) {
    let $fname := "custom"
    let $input_doc := doc($form-path)
    let $step1 := appconfig:get-xslt("forms_split_step1.xsl")
    let $step2 := appconfig:get-xslt("forms_split_step2.xsl")
    let $step1_doc := transform:transform($input_doc, $step1,   
        <parameters>
            <param name="fname" value="{$fname}" />
        </parameters>)
    return 
        transform:transform($step1_doc, $step2,())
};

declare function local:split-workflow($wf-path as xs:string) {
    let $xsl := appconfig:get-xslt("wf_split_attrs.xsl")
    let $doc := doc($wf-path)
    return transform:transform($doc, $xsl, 
            <parameters>
               <param name="docname" value="{util:document-name($doc)}" />
            </parameters>)        
};


let $FS-BU-CUSTOM := xs:string(request:get-parameter("fs_path",""))
let $EX-BU-CUSTOM := $appconfig:CONFIGS-FOLDER-NAME
let $EX-WORKING-COPY := $appconfig:CONFIGS-FOLDER

let $login := xmldb:login($appconfig:ROOT, "admin", "")
(: 
The custom folder is imported into a structure that looks like this :
app-root
    +--working
            +--live
                +-bungeni_custom
            +--import
                +-bungeni_custom 
                
live - is the folder that editor edits
import - is a backup of the folder imported from the file system
:)

(: check if the live working folder exists, if not, create it :)
let $created_bu_wc := if (xmldb:collection-available($appconfig:CONFIGS-FOLDER)) then () else xmldb:create-collection($appconfig:CONFIGS-ROOT-LIVE,$appconfig:CONFIGS-FOLDER-NAME)
(: import the files from the file system into the live folder :)
let $storing := xmldb:store-files-from-pattern(
    $appconfig:CONFIGS-FOLDER, 
    $FS-BU-CUSTOM, 
    "**/*.xml",
    'application/xml',
    true()
    )
(: check if upload was successful :)
(: types.xml is the arch document. Its important to find it as guaranttee that the correct folder path was given :)
let $uploadstate := if (contains($storing,"types.xml")) then true() else false()
(: update the selected fs path in the configuration :)
let $update-fs-path-in-config := if ($uploadstate eq true()) then local:update-fs-path($FS-BU-CUSTOM) else ()
(: make a copy of the live folder into import :)
let $store-new-original := xmldb:copy(
    $appconfig:CONFIGS-FOLDER,
    $appconfig:CONFIGS-ROOT-IMPORT
    )
(: transform the files in live folder :)
let $transform-working-copy := local:transform-configs($storing)
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