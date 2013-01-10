xquery version "3.0";

(: 
 : Defines all the RestXQ endpoints used by the XForms.
 :)
module namespace cerest = "http://exist-db.org/apps/configmanager/rest";

import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "./modules/appconfig.xqm";

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
function ce:workflows() {
    <workflows>
    {
        for $workflow in collection($appconfig:WF-FOLDER)/workflow
        return
            $workflow
    }
    </workflows>
};

(:~
 : Retrieve a workflow identified by a name.
 :)
declare 
    %rest:GET
    %rest:path("/workflow/{$name}")
function ce:get-workflow($name as xs:string) {
    collection($appconfig:WF-FOLDER)/workflow[@name = $name]
};

(:~
 : Update an existing workflow or store a new one. The workflow XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/workflow")
function ce:create-or-edit-address($content as node()) {
    let $id := ($content/workflow/@name, util:uuid())[1]
    let $data :=
        <workflow name="{$name}">
        { $content/workflow/* }
        </workflow>
    let $log := util:log("DEBUG", "Storing data into " || $appconfig:WF-FOLDER)
    let $stored := xmldb:store($appconfig:WF-FOLDER, $name || ".xml", $data)
    return
        ce:workflows()
};

(:~
 : Delete a workflow identified by its name.
 :)
declare
    %rest:DELETE
    %rest:path("/workflow/{$name}")
function ce:delete-workflow($name as xs:string) {
    xmldb:remove($appconfig:WF-FOLDER, $name || ".xml"),
    ce:workflows()
};