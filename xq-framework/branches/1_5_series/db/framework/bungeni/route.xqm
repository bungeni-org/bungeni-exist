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

(:~
The functions here are called from the app-controller.

The functions here must follow the app-controller signature / pattern

declare function rou:func-name(
        $EXIST-PATH as xs:string, 
        $EXIST-ROOT as xs:string, 
        $EXIST-CONTROLLER as xs:string, 
        $EXIST-RESOURCE as xs:string, 
        $REL-PATH as xs:string
)

:)

declare function rou:get-home($EXIST-PATH as xs:string, 
                             $EXIST-ROOT as xs:string, 
                             $EXIST-CONTROLLER as xs:string, 
                             $EXIST-RESOURCE as xs:string, 
                             $REL-PATH as xs:string) {
        template:process-tmpl(
           $REL-PATH, 
           $EXIST-PATH, 
           $config:DEFAULT-TEMPLATE,
           cmn:get-route($EXIST-PATH),
            (),         		   
           cmn:build-nav-tmpl($EXIST-PATH, "index.xml")
        )
};


(:
Generic Listing API
:)
declare function rou:listing-documentitem($EXIST-PATH as xs:string, 
                             $EXIST-ROOT as xs:string, 
                             $EXIST-CONTROLLER as xs:string, 
                             $EXIST-RESOURCE as xs:string, 
                             $REL-PATH as xs:string, 
                             $use-tmpl as xs:string, 
                             $doc-type as xs:string, 
                             $page-route as xs:string,
                             $stylesheet as xs:string) {
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    $tab := xs:string(request:get-parameter("tab",'uc')),
                    $sortby := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $acl := "public-view",
                    $act-entries-tmpl := bun:get-documentitems($acl, $doc-type, $page-route, $stylesheet, $offset, $limit, $qry, $sortby),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($use-tmpl)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    								    template:process-tmpl(
    								        $REL-PATH, 
    								        $EXIST-PATH, 
    								        $config:DEFAULT-TEMPLATE,
    								        cmn:get-route($EXIST-PATH),
    								        (),
    									    (cmn:build-nav-node(
    									       $EXIST-PATH,
    									       (template:merge($EXIST-PATH, $act-entries-repl,bun:get-listing-search-context($EXIST-PATH,"listing-search-form.xml",
    									       $doc-type))
    									       )))
    								    )                             
};

declare function rou:get-bills(
                        $EXIST-PATH as xs:string, 
                        $EXIST-ROOT as xs:string, 
                        $EXIST-CONTROLLER as xs:string, 
                        $EXIST-RESOURCE as xs:string, 
                        $REL-PATH as xs:string
                        ) {
      rou:listing-documentitem($EXIST-PATH, 
                             $EXIST-ROOT, 
                             $EXIST-CONTROLLER, 
                             $EXIST-RESOURCE, 
                             $REL-PATH,
                             "bills.xml",
                             "bill",
                             "bill/text",
                             "legislativeitem-listing.xsl")
};

declare function rou:get-questions(
                        $EXIST-PATH as xs:string, 
                        $EXIST-ROOT as xs:string, 
                        $EXIST-CONTROLLER as xs:string, 
                        $EXIST-RESOURCE as xs:string, 
                        $REL-PATH as xs:string
                        ) {
     rou:listing-documentitem($EXIST-PATH, 
                             $EXIST-ROOT, 
                             $EXIST-CONTROLLER, 
                             $EXIST-RESOURCE, 
                             $REL-PATH,
                             "questions.xml",
                             "question",
                             "question/text",
                             "legislativeitem-listing.xsl")
};

declare function rou:get-motions(
                        $EXIST-PATH as xs:string, 
                        $EXIST-ROOT as xs:string, 
                        $EXIST-CONTROLLER as xs:string, 
                        $EXIST-RESOURCE as xs:string, 
                        $REL-PATH as xs:string
                        ) {
     rou:listing-documentitem($EXIST-PATH, 
                             $EXIST-ROOT, 
                             $EXIST-CONTROLLER, 
                             $EXIST-RESOURCE, 
                             $REL-PATH,
                             "motions.xml",
                             "motion",
                             "motion/text",
                             "legislativeitem-listing.xsl")
};

declare function rou:get-tableddocuments(
                        $EXIST-PATH as xs:string, 
                        $EXIST-ROOT as xs:string, 
                        $EXIST-CONTROLLER as xs:string, 
                        $EXIST-RESOURCE as xs:string, 
                        $REL-PATH as xs:string
                        ) {
                    rou:listing-documentitem(
                             $EXIST-PATH, 
                             $EXIST-ROOT, 
                             $EXIST-CONTROLLER, 
                             $EXIST-RESOURCE, 
                             $REL-PATH,
                             "tableddocuments.xml",
                             "tableddocument",
                             "tableddocument/text",
                             "legislativeitem-listing.xsl"
                             )
};

declare function rou:get-agendaitems(
                        $EXIST-PATH as xs:string, 
                        $EXIST-ROOT as xs:string, 
                        $EXIST-CONTROLLER as xs:string, 
                        $EXIST-RESOURCE as xs:string, 
                        $REL-PATH as xs:string
                        ) {
                    rou:listing-documentitem(
                             $EXIST-PATH, 
                             $EXIST-ROOT, 
                             $EXIST-CONTROLLER, 
                             $EXIST-RESOURCE, 
                             $REL-PATH,
                             "agendaitems.xml",
                             "agendaitem",
                             "agendaitem/text",
                             "legislativeitem-listing.xsl"
                             )
};

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