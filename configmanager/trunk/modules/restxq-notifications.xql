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

(: List all workflows and return them as XML. :)
declare
    %rest:GET
    %rest:path("/workflows")
    %rest:produces("application/xml", "text/xml")
function cmwfrest:workflows() {
    <workflows>
    {
        for $workflow in collection($appconfig:WF-FOLDER)/workflow
        return
            $workflow
    }
    </workflows>
};

(: COMMIT a notification to the filesystem. :)
declare 
    %rest:GET
    %rest:path("/notification/commit/{$name}")
function cmwfrest:commit-notification($name as xs:string) {

    let $login := xmldb:login($appconfig:ROOT, $appconfig:admin-username, $appconfig:admin-password)
    let $doc := doc($appconfig:NOTIF-FOLDER || "/" || $name || ".xml")/notifications
    (: notification XSLT:)
    let $xslnotif := appconfig:get-xslt("notif_merge.xsl")
    let $status := file:serialize(transform:transform($doc, $xslnotif, ()),
                                                $appconfig:FS-PATH || "/notifications/" || $name || ".xml",
                                                "media-type=application/xml method=xml")
    return 
        $status
};