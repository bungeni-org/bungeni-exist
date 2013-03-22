xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cmrest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";

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
