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
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni.xqm";
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

declare function rou:get-home($CONTROLLER-DOC as node()) {
        let 
            $parts := cmn:get-view-parts("/home"),
            $act-entries-tmpl :=  bun:get-government($parts,$CONTROLLER-DOC/parliament/identifier/text()),
            $act-entries-repl:= document {
    							template:copy-and-replace($CONTROLLER-DOC/exist-cont, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    						 } 
    						 return 
    							template:process-tmpl(
    							   $CONTROLLER-DOC/rel-path, 
    							   $CONTROLLER-DOC/exist-cont, 
    							   $config:DEFAULT-TEMPLATE, 
    							   cmn:get-route($CONTROLLER-DOC/exist-path),
                                    <route-override>
                                        <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                        {$CONTROLLER-DOC/parliament}
                                    </route-override>, 
    							   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
    							 )   
};

declare function rou:get-parliament($CONTROLLER-DOC as node()) {
        <null/>         
};


(:
Generic Listing API
:)
declare function rou:listing-documentitem($CONTROLLER-DOC as node(), 
                             $doc-type as xs:string) {
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    $tab := xs:string(request:get-parameter("tab",'uc')),
                    $sortby := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $parts := cmn:get-view-listing-parts($doc-type, 'text'),
                    $acl := "public-view",
                    $act-entries-tmpl := bun:get-documentitems($CONTROLLER-DOC/exist-res, $CONTROLLER-DOC/parliament,$acl, $doc-type, $parts, $offset, $limit, $qry, $sortby),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($CONTROLLER-DOC/exist-cont, fw:app-tmpl($parts/view/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    								    template:process-tmpl(
    								        $CONTROLLER-DOC/rel-path, 
    								        $CONTROLLER-DOC/exist-cont, 
    								        $config:DEFAULT-TEMPLATE,
    								        cmn:get-route($CONTROLLER-DOC/exist-path),
                                                <route-override>
                                                    {$CONTROLLER-DOC/parliament}
                                                </route-override>, 
    									    (cmn:build-nav-node(
    									       $CONTROLLER-DOC,
    									       (template:merge($CONTROLLER-DOC/exist-cont, $act-entries-repl, 
    									           bun:get-listing-search-context(
    									               concat("/",  $parts/current-view),
    									               "xml/listing-search-form.xml",
    									               $doc-type
    									               )
    									           )
    									       )
    									       )
    									     )
    								    )                             
};

declare function rou:get-bills($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "Bill")
};

declare function rou:get-questions($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "Question")
};

declare function rou:get-motions($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "Motion")
};

declare function rou:get-tableddocuments($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "TabledDocument")
};

declare function rou:get-agendaitems($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "AgendaItem")
};

declare function rou:get-reports($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "Report")
};

declare function rou:get-pdf($CONTROLLER-DOC as node(), $views as node()) {
      
    let $parliament := $CONTROLLER-DOC/parliament
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
        $act-entries-tmpl :=  bun:gen-pdf-output($parliament,$docnumber,$views)
    return $act-entries-tmpl                                  
};

declare function rou:get-xml($CONTROLLER-DOC as node()) {
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
        $act-entries-tmpl :=  bun:get-raw-xml($docnumber)
    return $act-entries-tmpl   
};

declare function rou:get-akn($CONTROLLER-DOC as node()) {
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
        $act-entries-tmpl :=  bun:get-akn-xml($docnumber)
    return $act-entries-tmpl   
};

declare function rou:get-xcard($CONTROLLER-DOC as node()) {
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
        $act-entries-tmpl :=  bun:get-xcard-xml($docnumber)
    return $act-entries-tmpl   
};