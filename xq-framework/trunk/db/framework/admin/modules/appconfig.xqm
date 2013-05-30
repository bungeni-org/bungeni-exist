xquery version "3.0";

module namespace appconfig = "http://exist-db.org/apps/frameworkadmin/appconfig";

import module namespace config="http://exist-db.org/apps/frameworkadmin/config" at "config.xqm";

(: Application files :)
declare variable $appconfig:doc := doc($config:app-root || "/config.xml");

(: gives you /db/apps/framework/admin  :)
declare variable $appconfig:ROOT := $config:app-root;

declare variable $appconfig:FRAMEWORK-ROOT := $config:db-root-collection || "/apps/framework";

declare variable $appconfig:BUNGENI-ROOT := $appconfig:FRAMEWORK-ROOT || "/bungeni";

declare variable $appconfig:I18N-ROOT := $appconfig:FRAMEWORK-ROOT || "/i18n";

declare variable $appconfig:BUNGENI-XML-ROOT := $config:db-root-collection || "/" || data($appconfig:doc/xmlui-config/bu-xml-collection);

declare variable $appconfig:i18n-catalogues := $appconfig:FRAMEWORK-ROOT || "/i18n";

declare variable $appconfig:CONFIG-FILE := $appconfig:FRAMEWORK-ROOT || "/bungeni/" || data($appconfig:doc/xmlui-config/configs/@config) ;

declare variable $appconfig:LEGISLATURE-FILE := $appconfig:BUNGENI-XML-ROOT || "/" || data($appconfig:doc/xmlui-config/configs/@legislature) ;

declare variable $appconfig:LANG-FILE := $appconfig:BUNGENI-XML-ROOT || "/" || data($appconfig:doc/xmlui-config/configs/@lang) ;

(: app/framework/bungeni :)
declare variable $appconfig:APPLICATION-COLLECTION := $appconfig:doc/xmlui-config/application/text() ;

declare variable $appconfig:TEMPLATES-FOLDER := $appconfig:APPLICATION-COLLECTION || "/" || data($appconfig:doc/ce-config/configs/@templates);

declare variable $appconfig:MODEL-TEMPLATES := $appconfig:ROOT || "/model_templates";

declare variable $appconfig:XML-RESOURCES := $appconfig:ROOT || "/resources/xml";

declare variable $appconfig:XSL := $appconfig:ROOT || "/xsl";

declare variable $appconfig:CSS := $appconfig:ROOT || "/resources/css";

declare variable $appconfig:IMAGES := $appconfig:ROOT || "/resources/images";

(: REST Paths :)
declare variable $appconfig:REST-FRAMEWORK-ROOT :=  "/rest" || $appconfig:FRAMEWORK-ROOT ;

declare variable $appconfig:REST-I18N :=  $appconfig:REST-FRAMEWORK-ROOT || "/i18n" ;

declare variable $appconfig:REST-UI-CONFIG :=  $appconfig:REST-FRAMEWORK-ROOT || "/bungeni/ui-config.xml" ;

declare variable $appconfig:REST-APP-ROOT := "/rest" || $config:app-root ;

declare variable $appconfig:REST-XML-RESOURCES := "/rest" || $appconfig:XML-RESOURCES ;

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

(:
    Creates a list of all the roles: Both system and custom roles
:)
declare function appconfig:roles() {

    <roles> {
        let $autoroles := doc($appconfig:CONFIGS-FOLDER || '/.auto/_roles.xml')/roles
        let $customroles := doc($appconfig:CONFIGS-FOLDER || '/roles.xml')/roles
        let $allroles := for $role in ($autoroles/role/@name, $customroles//@id) return data($role)
        
        for $role in distinct-values($allroles)
        order by $role ascending
        return
            <role name="{$role}"/>
    } </roles>
    
};
