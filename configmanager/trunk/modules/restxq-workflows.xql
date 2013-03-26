xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cmrest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:
declare variable $ce:data := $config:app-root || "/config_editor/bungeni_custom/workflows";
:)

(:~
 : List all workflows and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/workflows")
    %rest:produces("application/xml", "text/xml")
function cmrest:workflows() {
    <workflows>
    {
        for $workflow in collection($appconfig:WF-FOLDER)/workflow
        return
            $workflow
    }
    </workflows>
};

(:~
 : DELETE a state in a workflow
 :)
declare 
    %rest:DELETE
    %rest:path("/workflow/{$doc}/state/{$id}")
function cmrest:delete-state($doc as xs:string,$id as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $doc || ".xml")/workflow
    return (
        update delete $doc/state[@id eq $id],
        update delete $doc/facet[starts-with(@name,$id)],
        $doc
    )
};

(:~
 : DELETE a facet in a workflow
 :)
declare 
    %rest:DELETE
    %rest:path("/workflow/{$doc}/facet/{$pos}")
function cmrest:delete-facet($doc as xs:string,$pos as xs:integer) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $doc || ".xml")/workflow
    let $facet-name := data($doc/facet[$pos]/@name)
    return (
        update delete $doc/facet[$pos],
        update delete $doc/state/facet[@ref eq "." || $facet-name],
        $doc
    )
};

(:~
 : Retrieve a workflow identified by a name.
 :)
declare 
    %rest:GET
    %rest:path("/workflow/{$name}")
function cmrest:get-workflow($name as xs:string) {
    collection($appconfig:FORM-FOLDER)/descriptor[@name = $name]
};

(:~
 : Delete a workflow identified by its name.
 :)
declare
    %rest:DELETE
    %rest:path("/workflow/{$name}")
function cmrest:delete-workflow($name as xs:string) {
    xmldb:remove($appconfig:WF-FOLDER, $name || ".xml"),
    cmrest:workflows()
};

(:~
 : COMMIT a workflow to the filesystem. Every workflow is committed in company of types.xml
 :)
declare 
    (: 
        !+NOTE (ao, 26th Mar 2013) Using GET instead of POST/PUT because both seem unstable on the
        current eXist-builds and unpredictable. Once tested and confirmed to be fixed, this should 
        be updated appropriately with the corresponding JScript files that makes this rest requests,
        currently in custom.js
    :)
    %rest:GET
    %rest:path("/workflow/commit/{$name}")
function cmrest:commit-workflow($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:WF-FOLDER || "/" || $name || ".xml")/workflow
    let $types := doc($appconfig:TYPES-XML)/types
    (: workflow XSLT:)
    let $xslworkflow := appconfig:get-xslt("wf_merge_attrs.xsl")   
    
    let $null := file:serialize($types,$appconfig:FS-PATH || "/types.xml" ,
                                                "media-type=application/xml method=xml")
    let $status := file:serialize(transform:transform($doc, $xslworkflow, ()),
                                                $appconfig:FS-PATH || "/workflows/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};