xquery version "3.0";

module namespace appconfig = "http://exist-db.org/apps/configmanager/config";

import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";

(: Application files :)
declare variable $appconfig:doc := doc($config:app-root || "/config.xml");

declare variable $appconfig:ROOT := $config:app-root;

declare variable $appconfig:CONFIGS-FOLDER-NAME := data($appconfig:doc/ce-config/configs/@collection) ;

(: app/bungeni-custom :)
declare variable $appconfig:CONFIGS-COLLECTION-NAME := $appconfig:doc/ce-config/configs-collection/text() ;

declare variable $appconfig:CONFIGS-COLLECTION := $config:db-root-collection || "/" || $appconfig:CONFIGS-COLLECTION-NAME ;

declare variable $appconfig:CONFIGS-ROOT-IMPORT := $appconfig:CONFIGS-COLLECTION || "/import" ; 

declare variable $appconfig:CONFIGS-ROOT-LIVE := $appconfig:CONFIGS-COLLECTION || "/live" ; 

(: app/bungeni-configuration/import/bungeni_custom :)
declare variable $appconfig:CONFIGS-IMPORT := $appconfig:CONFIGS-ROOT-IMPORT || "/" || $appconfig:CONFIGS-FOLDER-NAME ;

(: app/bungeni-configuration/live/bungeni_custom :)
declare variable $appconfig:CONFIGS-FOLDER := $appconfig:CONFIGS-ROOT-LIVE || "/" || $appconfig:CONFIGS-FOLDER-NAME;

declare variable $appconfig:FORM-FOLDER := $appconfig:CONFIGS-FOLDER || "/" || data($appconfig:doc/ce-config/configs/@form);

declare variable $appconfig:SYS-FOLDER := $appconfig:CONFIGS-FOLDER || "/" || data($appconfig:doc/ce-config/configs/@sys);

declare variable $appconfig:WF-FOLDER := $appconfig:CONFIGS-FOLDER || "/" || data($appconfig:doc/ce-config/configs/@wf);

declare variable $appconfig:WS-FOLDER := $appconfig:CONFIGS-FOLDER || "/" || data($appconfig:doc/ce-config/configs/@ws);

declare variable $appconfig:VOCABS-FOLDER := $appconfig:CONFIGS-FOLDER || "/" || data($appconfig:doc/ce-config/configs/@vocab);

declare variable $appconfig:NOTIF-FOLDER := $appconfig:CONFIGS-FOLDER || "/" || data($appconfig:doc/ce-config/configs/@notif);

declare variable $appconfig:TYPES-XML := $appconfig:CONFIGS-FOLDER || "/" || "types.xml";

declare variable $appconfig:UI-XML := $appconfig:FORM-FOLDER || "/" || "ui.xml";

declare variable $appconfig:XSL := $appconfig:ROOT || "/" || "xsl";

declare variable $appconfig:CSS := $appconfig:ROOT || "/" || "resources/css";

declare variable $appconfig:IMAGES := $appconfig:ROOT || "/" || "resources/images";

declare variable $appconfig:FS-PATH := $appconfig:doc/ce-config/configs/fs-path/text();

(: REST Paths :)
declare variable $appconfig:REST-CONFIGS-COLLECTION-LIVE :=  "/rest/" ||$appconfig:CONFIGS-COLLECTION-NAME || "/live" ;

declare variable $appconfig:REST-BUNGENI-CUSTOM-LIVE :=  $appconfig:REST-CONFIGS-COLLECTION-LIVE || "/bungeni_custom" ;

declare variable $appconfig:REST-APP-ROOT := "/rest" || $config:app-root ;

(: THis may be used internally to sudo to admin :)
declare variable $appconfig:admin-username := "admin";
declare variable $appconfig:admin-password := "";

(:~
Generic api to load a document from the application folder
:)
declare function local:__get_app_doc__($value as xs:string) as document-node() {
    doc($config:app-root || $value)
};
 
(:~
Loads an XSLT file 
:)
declare function appconfig:get-xslt($value as xs:string) as document-node() {
    doc($appconfig:XSL || "/" || $value)
};

declare function appconfig:rest-css($cxt-path as xs:string, $value as xs:string) {
    $cxt-path || "/rest" || $appconfig:CSS || "/" || $value
};

declare function appconfig:rest-images($cxt-path as xs:string, $value as xs:string) {
    $cxt-path || "/rest" || $appconfig:IMAGES || "/" || $value
};

(:~
: "Flattens" the types.xml structure to get all the 3 archtypes somehow.
: @param e
: @param pID
: @return 
:   3 nodes representing the 3 archtypes of bungeni
:)
declare function appconfig:flatten($e as node()*) as element()*
{
  for $i at $p in $e/(child::*)
  return $i | appconfig:flatten($i)
};


(:
: Groups the 'flattened' types.xml ready for presentation
: @param flattend
: @return 
:   <types>
        <archetype key="doc"/>
        <archetype key="member"/>
        <archetype key="group"/>
:   </types>
:)
declare function appconfig:three-in-one($flattened as node()) {
    <types> 
    {
        for $doc in $flattened/child::*
        group by $key := node-name($doc)
        return 
            <archetype key="{$key}">
             {$doc}
            </archetype>
    }
    </types>
};
