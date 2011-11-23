xquery version "1.0";

module namespace rou = "http://exist.bungeni.org/rou";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xh = "http://www.w3.org/1999/xhtml";

(:~
eXist Imports
:)
import module namespace request = "http://exist-db.org/xquery/request";

(:~
Framework Imports
:)
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";

(:~
Application imports
:)
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni.xqm";
import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm"; 

declare function rou:get-pdf($EXIST-PATH as xs:string, 
                             $EXIST-ROOT as xs:string, 
                             $EXIST-CONTROLLER as xs:string, 
                             $EXIST-RESOURCE as xs:string, 
                             $REL-PATH as xs:string) {
                            
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
        $act-entries-tmpl :=  bun:gen-pdf-output($docnumber)
    return $act-entries-tmpl                                  
};

declare function rou:get-xml($EXIST-PATH as xs:string, 
                             $EXIST-ROOT as xs:string, 
                             $EXIST-CONTROLLER as xs:string, 
                             $EXIST-RESOURCE as xs:string, 
                             $REL-PATH as xs:string) {
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
        $act-entries-tmpl :=  bun:get-raw-xml($docnumber)
    return $act-entries-tmpl   
};