xquery version "3.0";

module namespace config = "http://bungeni.org/xquery/config";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

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
declare variable $config:WORKFLOWS-COLLECTION := $config:doc/ce-config/config-workflows/text();

(: THis may be used internally to sudo to admin :)
declare variable $config:admin-username := "admin";
declare variable $config:admin-password := "";

(: 
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

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

declare function config:transform-configs($file-paths) {
    for $store in $file-paths
    let $login := xmldb:login("/db", "admin", "")
    let $resource := functx:substring-after-last($store, '/')
    let $collection := functx:substring-before-last($store, '/')
    return
        if (contains($store,"/forms/")) then (
            xmldb:store($collection, $resource, local:split-form($store), "application/xml")            
        ) 
        else if (contains($store,"/workflows/")) then (
            xmldb:store($collection, $resource, local:split-workflow($store), "application/xml")  
        )
        else
            ()
};

declare function local:split-form($form-path as xs:string) {
    let $fname := "custom"
    let $input_doc := doc($form-path)
    let $step1 := config:get-xslt("/xsl/forms_split_step1.xsl")
    let $step2 := config:get-xslt("/xsl/forms_split_step2.xsl")
    let $step1_doc := transform:transform($input_doc, $step1,   <parameters>
                                                                    <param name="fname" value="{$fname}" />
                                                                </parameters>)
    return 
        transform:transform($step1_doc, $step2,())
};

declare function local:split-workflow($wf-path as xs:string) {
    let $xsl := config:get-xslt("/xsl/wf_split_attrs.xsl")
    let $doc := doc($wf-path)
    return transform:transform($doc, $xsl, <parameters>
                                                <param name="docname" value="{util:document-name($doc)}" />
                                           </parameters>)        
};