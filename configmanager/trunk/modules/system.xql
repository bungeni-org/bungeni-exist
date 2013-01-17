xquery version "3.0";

module namespace sysmanager="http://exist.bungeni.org/systemfunctions";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $sysmanager:CXT := request:get-context-path();
declare variable $sysmanager:REST-CXT-APP :=  $sysmanager:CXT || "/rest" || $config:app-root;

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
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
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

(:
: write the CONFIGS-COLLECTION back to the file-system location they were retrieved from.
:)
declare function local:reverse-transform-configs() {

    for $doc in collection($appconfig:CONFIGS-FOLDER)
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
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
                                                $appconfig:FS-PATH || "/forms/" || $filename,
                                                "media-type=application/xml method=xml")         
            ) 
            else if (contains($path,"/workflows/")) then (
               $filename || " written? " || file:serialize(transform:transform(
                                                $doc, $xslworkflow, ()),
                                                $appconfig:FS-PATH || "/workflows/" || $filename,
                                                "media-type=application/xml method=xml")
            )
            else
                ()

};

declare function local:split-form($form-path as xs:string) {
    let $here := util:log('info', appconfig:get-xslt("forms_split_step1.xsl")) 
    let $input_doc := doc($form-path)    
    let $step1 := appconfig:get-xslt("forms_split_step1.xsl")
    let $step2 := appconfig:get-xslt("forms_split_step2.xsl")
    let $step1_doc := transform:transform($input_doc, $step1,())
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

declare
function sysmanager:upload-form($node as node(), $model as map(*)) {

    let $stamp := current-time()
    return 
        (: Element to pop up :)
        <div>
            <form id="store_config" method="get" action="store.html">
                <input type="hidden" name="t" value="{$stamp}" />
                <table>
                    <tr>
                        <td style="width: 90px;"><label for="name">Absolute Path: </label></td>
                        <td><input type="text" style="width:90%;" id="fs_path" name="fs_path" value="{$appconfig:FS-PATH}" /></td>
                    </tr>                    			
                    <tr>
                        <td colspan="2">
                            e.g. <i>/home/undesa/bungeni_apps/bungeni/src/bungeni_custom</i>
                            <br />
                            <br />
                            NOTE: This action will overwrite existing bungeni_custom. Unless the<br/>
                            structure of the configuration files has changed, this process is prefererably<br />
                            done once.<br/>
                        </td>
                    </tr>
                </table>
                <div>
                    <input id="submit-btn" type="submit" name="submit" value="Load"/>
                </div>
            </form> 
        </div>

};

(:
    Storing bungeni_custom from file-system
:)
declare 
function sysmanager:store($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    
    let $FS-BU-CUSTOM := xs:string(request:get-parameter("fs_path",""))
    let $EX-BU-CUSTOM := $appconfig:CONFIGS-FOLDER-NAME
    let $EX-WORKING-COPY := $appconfig:CONFIGS-FOLDER
    
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
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
        <div style="font-size:0.8em;">
             {
                switch($uploadstate)
        
                case true() return
                    <div>
                        <h2>Upload was successful: <a href="index.html">reload page</a></h2>
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
};

(:
    Saving back bungeni_custom to file-system
:)
declare 
function sysmanager:save($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $storing := local:reverse-transform-configs()
    (: check for something that definitely has to be there in the sequence :)
    let $uploadstate := if (contains($storing,"ui.xml")) then true() else false()
    
    return
        <div style="font-size:0.8em;">
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
};