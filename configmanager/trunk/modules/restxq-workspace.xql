xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cmwfrest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
(: external dependency to be installed :)
import module namespace gv = "http://kitwallace.co.uk/ns/graphviz" at "xmldb:exist:///db/apps/graphviz/lib/graphviz.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:
declare variable $ce:data := $config:app-root || "/config_editor/bungeni_custom/workflows";
:)

(: List all workspaces and return them as XML. :)
declare
    %rest:GET
    %rest:path("/workspace")
    %rest:produces("application/xml", "text/xml")
function cmwfrest:workspace() {
    <workspaces>
    {
        for $workspace in collection($appconfig:WS-FOLDER)/workspace
        return
            $workspace
    }
    </workspaces>
};

(: Delete a workspace identified by its name. :)
declare
    %rest:DELETE
    %rest:path("/workspace/{$name}")
function cmwfrest:delete-workspace($name as xs:string) {
    xmldb:remove($appconfig:WS-FOLDER, $name || ".xml"),
    cmwfrest:workspace()
};

(: COMMIT a workspace to the filesystem. Every workpspace is committed in company of types.xml :)
declare 
    (: 
        !+NOTE (ao, 26th Mar 2013) Using GET instead of POST/PUT because both seem unstable on the
        current eXist-builds and unpredictable. Once tested and confirmed to be fixed, this should 
        be updated appropriately with the corresponding JScript files that makes this rest requests,
        currently in custom.js
    :)
    %rest:GET
    %rest:path("/workspace/commit/{$name}")
function cmwfrest:commit-workspace($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WS-FOLDER || "/" || $name || ".xml")/workspace
    let $types := doc($appconfig:TYPES-XML)/types
    (: workspace XSLT:)
    let $xslworkspace := appconfig:get-xslt("ws_merge_attrs.xsl")   
    
    let $null := file:serialize($types,$appconfig:FS-PATH || "/types.xml" ,
                                                "media-type=application/xml method=xml")
    let $status := file:serialize(transform:transform($doc, $xslworkspace, ()),
                                                $appconfig:FS-PATH || "/workspace/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};