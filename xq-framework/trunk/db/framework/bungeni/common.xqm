module namespace bungenicommon = "http://bungeni.org/pis/common";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";

(:

Library for common functions

:)


(:
Get the path to the lex collection
:)
declare function bungenicommon:get-lex-db() as xs:string {
    $config:XML-COLLECTION
 };
 
 
 
declare function bungenicommon:get-xslt($value as xs:string) as document-node() {
    doc(fn:concat($config:fw-app-root, $value))
};
 

 declare function bungenicommon:get-parameters($value as xs:string, $delimiter as xs:string) as node() {
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
declare function bungenicommon:get-server() as xs:string {
    let $url := concat("http://" , request:get-server-name(),":" ,request:get-server-port())
    return $url

};