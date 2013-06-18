xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cmwfrest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace sysmanager = "http://exist.bungeni.org/systemfunctions" at "system.xql";
(: external dependency to be installed :)
import module namespace gv = "http://kitwallace.co.uk/ns/graphviz" at "xmldb:exist:///db/apps/graphviz/lib/graphviz.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:
declare variable $ce:data := $config:app-root || "/config_editor/bungeni_custom/workflows";
:)

(: COMMIT either types/roles.xml files which are at the root on the bungeni_custom folder to the filesystem :)
declare 
    (: 
        !+NOTE (ao, 26th Mar 2013) Using GET instead of POST/PUT because both seem unstable on the
        current eXist-builds and unpredictable. Once tested and confirmed to be fixed, this should 
        be updated appropriately with the corresponding JScript files that makes this rest requests,
        currently in custom.js
    :)
    %rest:GET
    %rest:path("/system/commit/{$name}")
function cmwfrest:commit-single-root($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $node := doc($appconfig:CONFIGS-FOLDER || "/" || $name || ".xml")/child::node()
    
    let $status := file:serialize($node,$appconfig:FS-PATH || "/" || $name || ".xml" ,
                                                "media-type=application/xml method=xml")
    return 
        $status
};

(: ACTIVATE a configuration in bungeni-configuration collections :)
declare 
    %rest:GET
    %rest:path("/system/activate/{$name}")
function cmwfrest:activate-single($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    (: copy import_... to live :)
    let $copy-to-live := xmldb:copy($appconfig:CONFIGS-COLLECTION || "/" || $name || "/" || $appconfig:CONFIGS-FOLDER-NAME, $appconfig:CONFIGS-ROOT-LIVE)
    (: transform the files in live folder :)
    let $storing := for $item in collection($copy-to-live) return fn:base-uri($item)
    let $transform-working-copy := sysmanager:transform-configs($storing)    
    (: update the config.xml with the new active import_... :)
    let $update-fs-live := update replace $appconfig:doc/ce-config/configs/fs-live/text() with $name

    return 
        <done>{$name}</done>
};

(: DELETE imported configuration in bungeni-configuration collections :)
declare 
    %rest:DELETE
    %rest:path("/system/delete/{$name}")
function cmwfrest:delete-single($name as xs:string) {

    let $active-name := $appconfig:doc/ce-config/configs/fs-live/text()
    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    return 
        if($active-name ne $name) then 
            xmldb:remove($appconfig:CONFIGS-COLLECTION || "/" || $name)
        else
            "could not delete"
};