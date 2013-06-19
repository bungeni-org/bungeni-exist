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


declare function sysmanager:transform-configs($file-paths) {
    for $store in $file-paths    
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $resource := functx:substring-after-last($store, '/')
    let $collection := functx:substring-before-last($store, '/')
    where not(contains($store,"/.auto/")) 
    return
        if (contains($store,"/forms/")) then (
            xmldb:store($collection, $resource, local:split-form($store), "application/xml")            
        ) 
        else if (contains($store,"/workflows/")) then (
            xmldb:store($collection, $resource, local:split-workflow($store), "application/xml")  
        )
        else if (contains($store,"types.xml")) then (
            xmldb:store($collection, $resource, local:import-typesxml($store), "application/xml")
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
    let $mkdirs := if(file:is-directory($appconfig:FS-PATH || "/forms")) then () else file:mkdirs($appconfig:FS-PATH || "/forms")    
    let $mkdirs := if(file:is-directory($appconfig:FS-PATH || "/workflows")) then () else file:mkdirs($appconfig:FS-PATH || "/workflows")
    let $log := util:log('debug',util:document-name($doc))
    return
            (: !+BUG (ao, June 6th 2013) we are singling-out the items below because they have other special global grants than
                the default .Add .Edit .View .Delete that we handle at the moment :)
            if (contains($path,"/sitting.xml") or contains($path,"/user.xml") or contains($path,"/signatory.xml")) then ()     
            else if (contains($path,"/forms/") and not(contains($path,"/.auto/"))) then (
                $filename || " written? " || file:serialize(transform:transform(
                                                transform:transform($doc, $step1forms,()), $step2forms,()), 
                                                $appconfig:FS-PATH || "/forms/" || $filename,
                                                "media-type=application/xml method=xml")         
            ) 
            else if (contains($path,"/workflows/") and not(contains($path,"/.auto/"))) then (
               $filename || " written? " || file:serialize(transform:transform(
                                                $doc, $xslworkflow, ()),
                                                $appconfig:FS-PATH || "/workflows/" || $filename,
                                                "media-type=application/xml method=xml")
            )
            else if (contains($path,"/types.xml")) then (
               $filename || " written? " || file:serialize($doc,
                                                $appconfig:FS-PATH || "/" || $filename,
                                                "media-type=application/xml method=xml")
            )            
            else
                ()

};

declare function local:split-form($form-path as xs:string) {
    let $input_doc := doc($form-path)    
    let $step1 := appconfig:get-xslt("forms_split_step1.xsl")
    let $step2 := appconfig:get-xslt("forms_split_step2.xsl")
    let $step1_doc := transform:transform($input_doc, $step1,())
    return 
        transform:transform($step1_doc, $step2,())
};

declare function local:split-workflow($wf-path as xs:string) {
    let $step1 := appconfig:get-xslt("wf_split_step1.xsl")
    let $step2 := appconfig:get-xslt("wf_split_step2.xsl")
    let $doc := doc($wf-path)
    let $step1_doc := transform:transform($doc, $step1, 
                            <parameters>
                               <param name="docname" value="{util:document-name($doc)}" />
                            </parameters>)      
    return transform:transform($step1_doc, $step2, ())        
};

declare function local:import-typesxml($typesxml-path as xs:string) {
    let $xslt := appconfig:get-xslt("types_import.xsl")
    let $doc := doc($typesxml-path)   
    return 
        transform:transform($doc, $xslt, ())        
};

declare
function sysmanager:upload-form($node as node(), $model as map(*)) {

    let $stamp := current-time()
    return 
        (: Element to pop up :)
        <div>
            <form id="store_config" method="get" action="store.html">
                <input type="hidden" name="t" value="{$stamp}" />
                <table style="width:100%;">
                    <tr>
                        <td style="width: 90px;"><label for="name">Absolute Path: </label></td>
                        <td><input type="text" style="width:40%;" id="fs_path" name="fs_path" value="{$appconfig:FS-PATH}" /></td>
                    </tr>                    			
                    <tr>
                        <td colspan="2"><p>e.g. <i>/home/user/bungeni_apps/bungeni/src/bungeni_custom</i></p></td>
                    </tr>
                </table>
                <div>
                    <input id="submit-btn" type="submit" name="submit" value="Load"/>
                </div>
            </form> 
        </div>

};

declare
function sysmanager:existing-imports($node as node(), $model as map(*)) {

    let $stamp := current-time()
    let $fs-live := $appconfig:doc/ce-config/configs/fs-live/text()
    return 
        (: Element to pop up :)
        <div style="width:57%">
            <h3>eXisting imports</h3>
            {
                if(not(xmldb:collection-available($appconfig:CONFIGS-COLLECTION || "/" || $fs-live))) then 
                    <p><span class="label label-important">No import has been activated for editing select one below</span></p>
                else
                    ()
            }
            
            {
                if(xmldb:collection-available($appconfig:CONFIGS-COLLECTION)) then 
                    <table class="table">{
                        let $fs-live := $appconfig:doc/ce-config/configs/fs-live/text()
                        for $coll at $pos in xmldb:get-child-collections($appconfig:CONFIGS-COLLECTION)
                        (:import_2013-06-14T17-42-53:)
                        let $pseudo-dateTime := substring-after($coll,"_")
                        (:2013-06-14T17-42-53:)
                        let $proper-date := substring-before($pseudo-dateTime,"T")
                        (:2013-06-14:)
                        let $pseudo-time := substring-after($pseudo-dateTime,"T")
                        (:17-42-53:)
                        let $proper-time := replace($pseudo-time,"-",":")
                        (:17:42:53:)
                        let $proper-dateTime := $proper-date || "T" || $proper-time
                        where starts-with($coll,"import")
                        order by $proper-dateTime descending
                        return 
                            <tr>
                                <td>
                                    <div class="btn-group">
                                        <button class="btn {if ($fs-live = $coll) then 'btn-success' else () }">{format-dateTime(xs:dateTime($proper-dateTime),"[D1o] [MNn,*-3], [Y] at [h]:[m]:[s] [P,2-2]")}</button>
                                        <button class="btn {if ($fs-live = $coll) then 'btn-success' else () } dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
                                        <ul class="dropdown-menu">
                                            <li><a class="activate-import" href="/exist/restxq/system/activate/{$coll}">set as active</a></li>
                                            <li><a class="delete-import" href="/exist/restxq/system/delete/{$coll}">delete</a></li>
                                        </ul>
                                    </div>
                                </td>
                                <td class="import-progress">
                                    <div class="hide progress progress-success progress-striped active">
                                      <div class="bar" style="width: 100%;">activating...</div>
                                    </div>  
                                </td>
                            </tr>
                    }</table>
                else
                    <p>None</p>
            }
            <p><span class="label label-info">NB</span> Click on the dropdown icon to activate a different set</p>
            <p><span class="label label-warning">NB</span> You cannot delete an active import (denoted by color green). You have to set another as active to that</p>
            <p><span class="label label-important">NB</span> Setting a configuration as active will overwrite current active and all changes made will be lost</p>
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
    /db/
        +--bungeni-configuration
                +--live
                    +-bungeni_custom
                +--import
                    +-bungeni_custom 
                    
    live - is the folder that editor edits
    import - is a backup of the folder imported from the file system as is. Its not even transformed.
            
    :)
    
    (: Creating the root collection for bungeni configurations :)
    let $created_configs_coll := if (xmldb:collection-available($appconfig:CONFIGS-COLLECTION)) then () else xmldb:create-collection($config:db-root-collection,$appconfig:CONFIGS-COLLECTION-NAME)
    
    (: every import have a timestamp :)
    let $timestamp := "_" || substring-before(replace(current-dateTime(),":","-"),".")
    let $import-timestamp := 'import' || $timestamp
    let $import-path := $appconfig:CONFIGS-COLLECTION || "/" || $import-timestamp
    (: Creating both import and live sub-collections within the the root bungeni-configuration created above :)
    let $created_import_subcoll := xmldb:create-collection($appconfig:CONFIGS-COLLECTION,$import-timestamp)
    let $created_live_subcoll := if (xmldb:collection-available($appconfig:CONFIGS-ROOT-LIVE)) then () else xmldb:create-collection($appconfig:CONFIGS-COLLECTION,'live')
    (: create it the new import_... collection :)
    let $created_bu_wc := xmldb:create-collection($import-path,$appconfig:CONFIGS-FOLDER-NAME)
    (: import the files from the file system into the live folder :)
    let $IMPORT-CONFIG-NAME := $import-path || "/" || $appconfig:CONFIGS-FOLDER-NAME
    let $storing-vdex := xmldb:store-files-from-pattern(
        $IMPORT-CONFIG-NAME, 
        $FS-BU-CUSTOM, 
        "**/*.vdex",
        'application/xml',
        true()
        )         
    let $storing-.zcml := xmldb:store-files-from-pattern(
        $IMPORT-CONFIG-NAME, 
        $FS-BU-CUSTOM, 
        "**/*.zcml",
        'application/xml',
        true()
        )      
    let $storing := xmldb:store-files-from-pattern(
        $IMPORT-CONFIG-NAME, 
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
    (:let $store-new-original := xmldb:copy(
        $appconfig:CONFIGS-FOLDER,
        $appconfig:CONFIGS-ROOT-IMPORT || $timestamp
        ):)
    (: transform the files in live folder :)
    (:let $transform-working-copy := sysmanager:transform-configs($storing):)

    return
        <div style="font-size:0.8em;">
             {
                switch($uploadstate)
        
                case true() return
                    <div>
                        <h2>Upload was successful!</h2>
                        <br/>
                        <!--div style="float:left">
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
                        </div-->                               
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
                        <h2>Save was successful</h2>
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