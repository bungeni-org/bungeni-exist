xquery version "3.0";

module namespace config = "http://bungeni.org/xquery/config";
(: The db root :)

declare variable $config:db-root-collection := "/db";

(: holds path to the config_editor app :)
declare variable $config:ce-root := fn:concat($config:db-root-collection, "/config_editor");

(: Application files :)
declare variable $config:doc := fn:doc(fn:concat($config:ce-root, "/config.xml"));

(: Application name :)
declare variable $config:APP-NAME := data($config:doc/ce-config/@app-name);

declare variable $config:CONFIGS-COLLECTION := $config:doc/ce-config/configs-collection/text();
declare variable $config:FORMS-COLLECTION := $config:doc/ce-config/config-forms/text();

(: THis may be used internally to sudo to admin :)
declare variable $config:admin-username := "admin";
declare variable $config:admin-password := "";

(:~
Generic api to load a document from the application folder
:)
declare function local:__get_app_doc__($value as xs:string) as document-node() {
    doc(fn:concat($config:ce-root, $value))
};

(:~
Get the path to the bungeni configuration collection
:)
declare function config:get-configs-db() as xs:string {
    $config:CONFIGS-COLLECTION
 };
 
 declare function config:get-forms() as xs:string {
    $config:FORMS-COLLECTION
 };
 
(:~
Loads an XSLT file 
:)
declare function config:get-xslt($value as xs:string) as document-node() {
    local:__get_app_doc__($value)
};