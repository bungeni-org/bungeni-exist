module namespace lexcommon = "http://exist.bungeni.org/lexcommon";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

(:

Library for common functions

:)


(:
Get the path to the lex collection
:)
declare function lexcommon:get-lex-db() as xs:string {
     xs:string("/db/kenyalex")
 };
 
 (:
 Used as a data source for the Title search auto-complete
 :)
 declare function lexcommon:get-acts-jsonds() as xs:string {
     xs:string(concat(lexcommon:get-server(), "/exist/kenyalex/actsbyidasjson.xql"))
 };
 
 
 (:
 Used as a data-source for the Cap-no search auto-complete
 :)
 declare function lexcommon:get-actsbycapno-jsonds() as xs:string {
     xs:string(concat(lexcommon:get-server(), "/exist/kenyalex/actsjsonbycapno.xql"))
 };
 
 
 

 declare function lexcommon:get-parameters($value as xs:string, $delimiter as xs:string) as node() {
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
declare function lexcommon:get-server() as xs:string {
    let $url := concat("http://" , request:get-server-name(),":" ,request:get-server-port())
    return $url

};