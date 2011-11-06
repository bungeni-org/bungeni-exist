module namespace cmn = "http://exist.bungeni.org/cmn";

declare namespace xh = "http://www.w3.org/1999/xhtml";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";


(:

Library for common functions

:)


(:
Get the path to the lex collection
:)
declare function cmn:get-lex-db() as xs:string {
    $config:XML-COLLECTION
 };
 

declare function cmn:get-ui-config() as document-node() {
  fn:doc("ui-config.xml")
};

declare function cmn:get-menu($menu-name as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/menugroups/menu[@name=$menu-name]
      return $doc
}; 

declare function cmn:get-route($exist-path as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/routes/route[@href eq $exist-path]
       return $doc
};

declare function cmn:get-menu-from-route($exist-path as xs:string) as node() {
    let $doc := cmn:get-route($exist-path)
      return cmn:get-ui-config()//menu[@for eq $doc/navigation/text()]
};

declare function cmn:build-nav-tmpl($exist-path as xs:string, $app-tmpl as xs:string) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $tmpl := fw:app-tmpl($app-tmpl)
     let $out := ($main-nav, $sub-nav, $tmpl)
     return $out
};

declare function cmn:build-nav-node($exist-path as xs:string, $node as node()) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $out := ($main-nav, $sub-nav, $node)
     return $out
};


declare function cmn:get-xslt($value as xs:string) as document-node() {
    doc(fn:concat($config:fw-app-root, $value))
};
 

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