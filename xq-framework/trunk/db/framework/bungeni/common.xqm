module namespace cmn = "http://exist.bungeni.org/cmn";

declare namespace xh = "http://www.w3.org/1999/xhtml";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";


(:
Library for common functions used in the Application.

Some of the APIs here should eventually be factored int a framework level library 
rather than an Application level library

:)


(:~
Get the path to the lex collection
:)
declare function cmn:get-lex-db() as xs:string {
    $config:XML-COLLECTION
 };
 

(:~
Get the UI configuraiton document
:)
declare function cmn:get-ui-config() as document-node() {
  local:__get_app_doc__($config:UI-CONFIG)
  (: fn:doc(fn:concat($config:fw-app-root, $config:UI-CONFIG)) :)
};


(:~
Get a menu by name from the UI configuration document 
:)
declare function cmn:get-menu($menu-name as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/menugroups/menu[@name=$menu-name]
      return $doc
}; 

(:~
Get a route configuration from the exist path.
The exist-path is passed from the appcontroller
:)
declare function cmn:get-route($exist-path as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/routes/route[@href eq $exist-path]
       return $doc
};


(:~
Get the applicable menu for a route
:)
declare function cmn:get-menu-from-route($exist-path as xs:string) as node() {
    let $doc := cmn:get-route($exist-path)
      return cmn:get-ui-config()//menu[@for eq $doc/navigation/text()]
};

(:~
Build navigation template nodes for a request path 
The mainnav is provided by default.
The subnavigation is rendered based on the incoming request path
The app-tmpl parameter is the final page template to be processed.
:)
declare function cmn:build-nav-tmpl($exist-path as xs:string, $app-tmpl as xs:string) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $tmpl := fw:app-tmpl($app-tmpl)
     let $out := ($main-nav, $sub-nav, $tmpl)
     return $out
};

(:~
Build navigation template nodes for a request path 
The mainnav is provided by default.
The subnavigation is rendered based on the incoming request path
The node parameter is the "cooked" page as a node
:)
declare function cmn:build-nav-node($exist-path as xs:string, $node as node()) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $out := ($main-nav, $sub-nav, $node)
     return $out
};


(:~
Loads an XSLT file 
:)
declare function cmn:get-xslt($value as xs:string) as document-node() {
    (: doc(fn:concat($config:fw-app-root, $value)) :)
    local:__get_app_doc__($value)
};

(:~
Generic api to load a document from the application folder
:)
declare function local:__get_app_doc__($value as xs:string) as document-node() {
    doc(fn:concat($config:fw-app-root, $value))
};


(:~
Parses request parameters and returns them as a XML structure
:)
declare function cmn:get-parameters($value as xs:string, $delimiter as xs:string) as node() {
         let $parsed-tokens := tokenize($value ,$delimiter)
         return 
         <tokens>
         {for $parsed-token in $parsed-tokens 
               where string-length($parsed-token) > 0
               return <token name="{$parsed-token}" />
               }
         </tokens>          
};

(:
Returns the server running the current scripts
:)
declare function cmn:get-server() as xs:string {
    let $url := concat("http://" , request:get-server-name(),":" ,request:get-server-port())
    return $url

};