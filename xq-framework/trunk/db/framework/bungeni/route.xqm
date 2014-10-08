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
import module namespace i18n = "http://exist-db.org/xquery/i18n" at "../i18n.xql";

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
        $parliament := cmn:get-parl-config()/parliaments/parliament[type/text() eq $CONTROLLER-DOC/exist-res][1],
        $act-entries-tmpl :=  bun:get-parliament($parts,$CONTROLLER-DOC,$parliament/identifier/text()),
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


declare function rou:get-whatson($CONTROLLER-DOC as node()) {

    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $woview := xs:string(request:get-parameter("showing",'twk'))   
    let $tab := xs:string(request:get-parameter("tab",'sittings')) 
    let $mtype := xs:string(request:get-parameter("mtype",'any')) 
    let $act-entries-tmpl :=  bun:get-whatson($woview,$tab,$mtype,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
    						template:copy-and-replace($CONTROLLER-DOC/exist-cont, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
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
            (cmn:build-nav-node($CONTROLLER-DOC,
                (
                    template:merge($CONTROLLER-DOC/exist-path, 
                            $act-entries-repl, 
                            bun:get-listing-search-context(
                                $CONTROLLER-DOC,
                                "xml/listing-search-form.xml",'whatson'
                                )
                          )
                 )
                )
            )
        )

};


declare function rou:group($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-parl-group("public-view",$docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
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

declare function rou:committee($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $mem-status := xs:string(request:get-parameter("status","current"))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-parl-committee("public-view",$docnumber,$mem-status,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl:= document {
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

declare function rou:get-members($CONTROLLER-DOC as node()) {

    let $qry := xs:string(request:get-parameter("q",''))
    (: 
    FIX+[27-08-2014, AH, default member list order]
    default sort order, last name desc
    Fixed bug: where it was refering to a non-existent sort-order
    :)
    let $sty := xs:string(request:get-parameter("s","ln_asc"))
    let $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET))
    let $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT))
    let $parts := cmn:get-view-listing-parts('Member', 'member')
    
    let $act-entries-tmpl :=  bun:get-members(
        $CONTROLLER-DOC/exist-res,$CONTROLLER-DOC/parliament,
        $offset,
        $limit,
        $parts,
        $qry,
        $sty
        )
    let $act-entries-repl:= document {
    						template:copy-and-replace(
    						  $CONTROLLER-DOC/exist-cont, 
    						  fw:app-tmpl($parts/view/template)/xh:div, 
    						  $act-entries-tmpl
    						  )
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
            (cmn:build-nav-node($CONTROLLER-DOC,
                        (
                            template:merge(
                              $CONTROLLER-DOC/exist-cont, 
                              $act-entries-repl, 
                              bun:get-listing-search-context(
                                $CONTROLLER-DOC,
                                "xml/listing-search-form.xml",
                                'Membership'
                                )
                            )
                       )
                )
             )
        )
       

};

declare function rou:member($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))     
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-member($docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
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

declare function rou:sitting($CONTROLLER-DOC as node()) {
    
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-sitting("public-view",$docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl:= document {
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

declare function rou:calendar($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $act-entries-tmpl :=  bun:get-calendar("public-view",$docnumber,"xsl/calendar.xsl",$CONTROLLER-DOC/parliament)
    let $act-entries-repl:= document {
        					template:copy-and-replace($CONTROLLER-DOC/exist-cont, fw:app-tmpl("xml/calendar.xml")/xh:div, $act-entries-tmpl)
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

declare function rou:member-officesheld($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))   
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-member-officesheld($docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl:= document {
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

declare function rou:member-biographical($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))   
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-member-biographical($docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl:= document {
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

declare function rou:member-parlactivities($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)) 
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-parl-activities("public-view",$docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
    					template:copy-and-replace(
    					   $CONTROLLER-DOC/exist-cont, 
    					   fw:app-tmpl($parts/template)/xh:div, 
    					   $act-entries-tmpl
    					)
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

declare function rou:member-communications($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)) 
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-communications("public-view",$docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
    					template:copy-and-replace(
    					   $CONTROLLER-DOC/exist-cont, 
    					   fw:app-tmpl($parts/template)/xh:div, 
    					   $act-entries-tmpl
    					)
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



declare function rou:member-contacts($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))           
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-contacts-by-uri("public-view","Member",$docnumber,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
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

declare function rou:document-text($CONTROLLER-DOC as node()) {

    let $uri := xs:string(request:get-parameter("uri",$bun:DOCNO))  
    let $internal-uri := xs:string(request:get-parameter("internal-uri",$bun:DOCNO)) 
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-parl-doc("public-view",$uri,$internal-uri,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
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

declare function rou:document-timeline($CONTROLLER-DOC as node()) {

    let $uri := xs:string(request:get-parameter("uri",$bun:DOCNO))   
    let $internal-uri := xs:string(request:get-parameter("internal-uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl := bun:get-parl-doc-timeline("public-view",$uri,$internal-uri,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
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

declare function rou:document-documents($CONTROLLER-DOC as node()) {

    let $uri := xs:string(request:get-parameter("uri",$bun:DOCNO)) 
    let $internal-uri := xs:string(request:get-parameter("internal-uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-parl-doc("public-view",$uri,$internal-uri,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl:= document {
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

declare function rou:document-events($CONTROLLER-DOC as node()) {

    let $uri := xs:string(request:get-parameter("uri",''))  
    let $internal-uri := xs:string(request:get-parameter("internal-uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-parl-doc(
        "public-view",
        $uri,
        $internal-uri,
        $parts,
        $CONTROLLER-DOC/parliament
        )
    let $act-entries-repl := document {
    						template:copy-and-replace(
    						  $CONTROLLER-DOC/exist-cont, 
    						  fw:app-tmpl($parts/template)/xh:div, 
    						  $act-entries-tmpl
    						  )
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

declare function rou:document-event($CONTROLLER-DOC as node()) {

    let $eventuri := xs:string(request:get-parameter("uri",''))
    let $sequence-id := xs:integer(request:get-parameter("id",0))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-doc-event($eventuri,$sequence-id,$parts)
    let $act-entries-repl := document {
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

declare function rou:document-response($CONTROLLER-DOC as node()) {

    let $eventuri := xs:string(request:get-parameter("uri",''))
    let $sequence-id := xs:integer(request:get-parameter("id",0))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-doc-event($eventuri,$sequence-id,$parts)
    let $act-entries-repl := document {
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

declare function rou:document-attachment($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))  
    let $attid := xs:integer(request:get-parameter("id",0))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-doc-attachment("public-view",$docnumber,$attid,$parts)
    let $act-entries-repl:= document {
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

declare function rou:document-scheduleItem($CONTROLLER-DOC as node()) {

    let $uri := xs:string(request:get-parameter("uri",$bun:DOCNO)) 
    let $internal-uri := xs:string(request:get-parameter("internal-uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl := bun:get-parl-doc-scheduleItem("public-view",$uri,$internal-uri,$parts,$CONTROLLER-DOC/parliament)
    let $act-entries-repl := document {
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

declare function rou:version-text($CONTROLLER-DOC as node()) {

    let $uri := xs:string(request:get-parameter("uri",$bun:DOCNO))    
    let $internal-uri := xs:string(request:get-parameter("internal-uri",$bun:DOCNO))
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-doc-version("public-view", $uri, $internal-uri,$parts)
    let $act-entries-repl:= document {
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

declare function rou:show-event-popout($CONTROLLER-DOC as node()) {
    
    let $log := util:log('debug',$CONTROLLER-DOC)
    let $log := util:log('debug','++++++++++++++++++++++++++++++++++')
    let $uri := xs:string(request:get-parameter("uri",$bun:DOCNO)) 
    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-doc-event-popout($uri,$parts)
    return
        i18n:process($act-entries-tmpl, template:set-lang(), $config:I18N-MESSAGES, $config:DEFAULT-LANG)    
};

declare function rou:get-politicalgroups($CONTROLLER-DOC as node()) {

    let $qry := xs:string(request:get-parameter("q",''))
    let $sty := xs:string(request:get-parameter("s",$bun:SORT-BY))
    let $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET))
    let $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT))
    let $parts := cmn:get-view-listing-parts('PoliticalGroup','profile')
    let $act-entries-tmpl :=  bun:get-politicalgroups($CONTROLLER-DOC/exist-res,$CONTROLLER-DOC/parliament,$offset,$limit,$parts,$qry,$sty)
    let $act-entries-repl:= document {
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
            (cmn:build-nav-node($CONTROLLER-DOC,
                                (template:merge($CONTROLLER-DOC/exist-path, 
                                                $act-entries-repl, 
                                                bun:get-listing-search-context($CONTROLLER-DOC, "xml/listing-search-form.xml",'politicalgroup'))
                                                )
                                 )
             )
        )
};

declare function rou:get-parliament($CONTROLLER-DOC as node()) {
        <null/>         
};

(:
Generic Listing API
:)
declare function rou:listing-documentitem($CONTROLLER-DOC as node(), $doc-type as xs:string) {
    let $qry := xs:string(request:get-parameter("q",'')),
        $tab := xs:string(request:get-parameter("tab",'uc')),
        $sortby := xs:string(request:get-parameter("s",$bun:SORT-BY)),
        $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
        $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
        $parts := cmn:get-view-listing-parts($doc-type, 'text'),
        $acl := "public-view",
        $act-entries-tmpl := bun:get-documentitems($CONTROLLER-DOC,$acl, $doc-type, $parts, $offset, $limit, $qry, $sortby),
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
    						               $CONTROLLER-DOC,
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


declare function rou:get-petitions($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "Petition")
};

declare function rou:get-other-documents($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "OtherDocument")
};


(:
declare function rou:get-questions($CONTROLLER-DOC as node()) {
    rou:listing-documentitem($CONTROLLER-DOC, "Question")
};
:)

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

declare function rou:atom-rss($CONTROLLER-DOC as node()) {

    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $doc-type := data($parts/parent::node()/@name)
    let $act-entries-tmpl :=  bun:get-documents-feed($CONTROLLER-DOC,"public-view", $doc-type,"user")
    return 
        $act-entries-tmpl        
};

declare function rou:sitting-rss($CONTROLLER-DOC as node()) {

    let $parts := cmn:get-view-parts($CONTROLLER-DOC/chamber-rel-path)
    let $act-entries-tmpl :=  bun:get-sittings-feed($CONTROLLER-DOC,"public-view","user")
    return 
        $act-entries-tmpl        
};

declare function rou:epub($CONTROLLER-DOC as node()) {

    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $act-entries-tmpl :=  bun:gen-epub-output($CONTROLLER-DOC/exist-cont,$docnumber)
    return 
        $act-entries-tmpl
};

declare function rou:get-pdf($CONTROLLER-DOC as node()) {
      
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $act-entries-tmpl :=  bun:gen-pdf-output($CONTROLLER-DOC,$docnumber)
    return 
        $act-entries-tmpl                                  
};

declare function rou:get-print($CONTROLLER-DOC as node()) {
      
    let $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO))
    let $act-entries-tmpl :=  bun:gen-print-output($CONTROLLER-DOC,$docnumber)
    return 
        $act-entries-tmpl                                  
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