xquery version "3.0";

module namespace rou = "http://exist.bungeni.org/rou";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace request = "http://exist-db.org/xquery/request";

(:~
Framework Imports
:)
import module namespace config = "http://bungeni.org/xquery/config" at "../config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "../template.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "../fw.xqm";

(:~
Application imports
:)
import module namespace akn = "http://exist.bungeni.org/akn" at "anapp.xqm";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm"; 


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
                    $sortby := xs:string(request:get-parameter("s",$akn:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$akn:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$akn:LIMIT)),
                    $acl := "public-view",
                    $act-entries-tmpl := akn:get-documentitems($acl, $doc-type, $page-route, $stylesheet, $offset, $limit, $qry, $sortby),
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
    									    (cmn:build-nav-node($EXIST-PATH, $act-entries-repl))
    								    )                             
};

declare function rou:get-acts(
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
                             "listings.xml",
                             "act",
                             "act/text",
                             "listings.xsl")
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
                             "listings.xml",
                             "bill",
                             "bill/text",
                             "listings.xsl")
};

declare function rou:get-debates(
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
                             "listings.xml",
                             "debate",
                             "debate/text",
                             "listings.xsl")
};

declare function rou:get-amendments(
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
                             "listings.xml",
                             "amendment",
                             "amendment/text",
                             "listings.xsl")
};

declare function rou:get-reports(
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
                             "listings.xml",
                             "debateReport",
                             "report/text",
                             "listings.xsl"
                             )
};

declare function rou:get-judgements(
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
                             "listings.xml",
                             "judgement",
                             "judgement/text",
                             "listings.xsl"
                             )
};

declare function rou:get-gazettes(
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
                             "listings.xml",
                             "officialGazette",
                             "gazette/text",
                             "listings.xsl"
                             )
};

declare function rou:get-misc-docs(
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
                             "listings.xml",
                             "doc",
                             "misc/text",
                             "listings.xsl"
                             )                             
};

declare function rou:get-xml($EXIST-PATH as xs:string, 
                             $EXIST-ROOT as xs:string, 
                             $EXIST-CONTROLLER as xs:string, 
                             $EXIST-RESOURCE as xs:string, 
                             $REL-PATH as xs:string) {
    let $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
        $act-entries-tmpl :=  akn:get-raw-xml($docnumber)
    return $act-entries-tmpl   
};