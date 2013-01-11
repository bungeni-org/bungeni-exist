xquery version "3.0";
module namespace appconfig = "http://exist-db.org/apps/configmanager/config";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";


(: Application files :)
declare variable $appconfig:doc := fn:doc(fn:concat($config:app-root, "/config.xml"));

declare variable $appconfig:ROOT := $config:app-root;

declare variable $appconfig:CONFIGS-FOLDER-NAME := $appconfig:doc/ce-config/configs/@collection/text() ;

(: app/working :)
declare variable $appconfig:CONFIGS-ROOT := $appconfig:ROOT || "/working" ; 

declare variable $appconfig:CONFIGS-ROOT-IMPORT := $appconfig:CONFIGS-ROOT || "/import" ; 

declare variable $appconfig:CONFIGS-ROOT-LIVE := $appconfig:CONFIGS-ROOT || "/live" ; 

(: app/working/import/bungeni_custom :)
declare variable $appconfig:CONFIGS-IMPORT := $appconfig:CONFIGS-ROOT-IMPORT || "/" || $appconfig:CONFIGS-FOLDER-NAME ;

(: app/working/live/bungeni_custom :)
declare variable $appconfig:CONFIGS-FOLDER := fn:concat(
    $appconfig:CONFIGS-ROOT-LIVE, "/", 
    $appconfig:CONFIGS-FOLDER-NAME
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

declare variable $appconfig:XSL := fn:concat(
    $appconfig:ROOT, "/",
    "xsl"
);

declare variable $appconfig:CSS := fn:concat(
    $appconfig:ROOT, "/",
    "resources/css"
);

declare variable $appconfig:IMAGES := fn:concat(
    $appconfig:ROOT, "/",
    "resources/images"
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
    local:__get_app_doc__($appconfig:XSL || "/" || $value)
};

declare function appconfig:rest-css($cxt-path as xs:string, $value as xs:string) {
    $cxt-path || "/rest" || $appconfig:CSS || "/" || $value
};

declare function appconfig:rest-images($cxt-path as xs:string, $value as xs:string) {
    $cxt-path || "/rest" || $appconfig:IMAGES || "/" || $value
};

