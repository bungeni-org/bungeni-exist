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