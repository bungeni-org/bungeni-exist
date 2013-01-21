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
 : Move a field in a form descriptor
 :)
declare 
    %rest:GET
    %rest:path("/form/{$doc}/{$field}/{$dir}")
function cmrest:move-field($doc as xs:string,
    $field as xs:string,
    $dir as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    return
        switch ($dir)
        
            case 'up' return 
                let $doc := doc($appconfig:FORM-FOLDER || "/" || $doc || ".xml")/descriptor
                return (
                    update insert $doc/field[@name eq $field] preceding $doc/field[@name eq $field]/preceding-sibling::*[1],
                    update delete $doc/field[@name eq $field][2],
                    $doc
                )
                    
            case 'down' return 
                let $doc := doc($appconfig:FORM-FOLDER || "/" || $doc || ".xml")/descriptor
                return (
                    update insert $doc/field[@name eq $field] following $doc/field[@name eq $field]/following-sibling::*[1],
                    update delete $doc/field[@name eq $field][1],
                    $doc
                )           
                    
            default return           
                () 
};

(:~
 : DELETE a field in a form descriptor
 :)
declare 
    %rest:DELETE
    %rest:path("/form/{$doc}/{$field}")
function cmrest:delete-field($doc as xs:string,$field as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:FORM-FOLDER || "/" || $doc || ".xml")/descriptor
    return (
        update delete $doc/field[@name eq $field],
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