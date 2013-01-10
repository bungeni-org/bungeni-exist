xquery version "3.0";
module namespace appconfig = "http://exist-db.org/apps/configmanager/config";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";


(: Application files :)
declare variable $appconfig:doc := fn:doc(fn:concat($config:app-root, "/config.xml"));

declare variable $appconfig:ROOT := $config:app-root

declare variable $appconfig:CONFIGS-FOLDER := fn:concat(
    $config:app-root, "/" , 
    $appconfig:doc/ce-config/configs/@collection/text()
);

declare variable $appconfig:FORM-FOLDER := fn:concat(
    $appconfig:CONFIGS-FOLDER, "/",
    $appconfig:doc/ce-config/configs/@form/text()
);

declare variable $appconfig:WF-FOLDER := fn:concat(
    $appconfig:CONFIGS-FOLDER, "/", 
    $appconfig:doc/ce-config/configs/@wf/text()
);

declare variable $appconfig:WS-FOLDER := fn:concat(
    $appconfig:CONFIGS-FOLDER, "/",
    $appconfig:doc/ce-config/configs/@ws/text()
);

declare variable $appconfig:NOTIF-FOLDER := fn:concat(
    $appconfig:CONFIGS-FOLDER, "/",
    $appconfig:doc/ce-config/configs/@notif/text()
);

declare variable $appconfig:TYPES_XML := fn:concat(
    $appconfig:CONFIGS-FOLDER, "/",
    "types.xml"
);

(: THis may be used internally to sudo to admin :)
declare variable $appconfig:admin-username := "admin";
declare variable $appconfig:admin-password := "";

(:~
Generic api to load a document from the application folder
:)
declare function local:__get_app_doc__($value as xs:string) as document-node() {
    doc(fn:concat($config:app-root, $value))
};
 
(:~
Loads an XSLT file 
:)
declare function appconfig:get-xslt($value as xs:string) as document-node() {
    local:__get_app_doc__($value)
};