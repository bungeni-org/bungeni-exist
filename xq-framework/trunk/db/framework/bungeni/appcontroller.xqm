xquery version "3.0";

module namespace appcontroller = "http://bungeni.org/xquery/appcontroller";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xh = "http://www.w3.org/1999/xhtml";

(:~
eXist Imports
:)
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace util = "http://exist-db.org/xquery/util";

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
import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";

(:~
All applications using the XQ framework must implement the appcontroller namespace module with the function 
called appcontroller:controller() in the same pattern as below
:)
declare function appcontroller:controller($EXIST-PATH as xs:string,
                                $PARLIAMENT as node()?,
                                $BICAMERAL as xs:boolean,
                                $CHAMBER-REL-PATH as xs:string,
                                $EXIST-ROOT as xs:string, 
                                $EXIST-CONTROLLER as xs:string, 
                                $EXIST-RESOURCE as xs:string, 
                                $REL-PATH as xs:string) {
                            
        let $CONTROLLER-DOC :=  <controller>
                                    <exist-path>{$EXIST-PATH}</exist-path>
                                    {$PARLIAMENT}
                                    <bicameral>{$BICAMERAL}</bicameral>
                                    <chamber-rel-path>{$CHAMBER-REL-PATH}</chamber-rel-path>
                                    <exist-root>{$EXIST-ROOT}</exist-root>
                                    <exist-cont>{$EXIST-CONTROLLER}</exist-cont>
                                    <exist-res>{$EXIST-RESOURCE}</exist-res>
                                    <rel-path>{$REL-PATH}</rel-path>
                                </controller>
        let $ROUTE-DOC := cmn:get-route($EXIST-PATH) 
        let $action := $ROUTE-DOC/action/text()
        return 
            if ($EXIST-PATH eq "/check-update" ) then
            (: GLUE-SERVICE :)            
                let $docuri := xs:string(request:get-parameter("uri","")), 
                    $statusdate := xs:string(request:get-parameter("t","")),
                    $check-up-results :=  bun:check-update($docuri,$statusdate)
                return $check-up-results
        	else if ($EXIST-PATH eq "/switch") then 
        	(: LANGUAGE-SETTER :)        	
        		(
                    template:set-lang(),
                    fw:redirect-rel($EXIST-PATH, request:get-header("Referer"))
                )
        	else if ($EXIST-PATH eq "/download" ) then 
            (: FOR ATTACHMENT DOWNLOADS :)
                let $docuri := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $attid := xs:string(request:get-parameter("att",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:get-attachment("public-view",$docuri,$attid)
                return $act-entries-tmpl
            else if ($EXIST-PATH eq "" ) then
                fw:redirect(fn:concat(request:get-uri(), "/")) 
            else  if($EXIST-PATH eq "/" or $EXIST-PATH eq "/xml/index.xml") then 
                rou:get-home($CONTROLLER-DOC)
        	else if ($EXIST-PATH eq "/image" ) then 
            (: FOR IMAGES :)
                let $hash := xs:string(request:get-parameter("hash",'')), 
                    $name := xs:string(request:get-parameter("name",'unnamed')), 
                    $act-entries-tmpl :=  bun:get-image($hash,$name)
                return $act-entries-tmpl
        	else if ($CHAMBER-REL-PATH eq "/committees") then 
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    $sty := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $parts := cmn:get-view-listing-parts('Committee','profile'),
                    $act-entries-tmpl :=  bun:get-committees($CONTROLLER-DOC/exist-res,$PARLIAMENT,$offset,$limit,$parts,$qry,$sty),
        	        $act-entries-repl:= document {
        								template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl($parts/view/template)/xh:div, $act-entries-tmpl)
        							 } 
                return 
                    template:process-tmpl(
                        $REL-PATH, 
                        $EXIST-CONTROLLER, 
                        $config:DEFAULT-TEMPLATE,
                        cmn:get-route($EXIST-PATH),
                        <route-override>
                            {$PARLIAMENT}
                        </route-override>,
                        (cmn:build-nav-node($CONTROLLER-DOC,(template:merge($EXIST-PATH, $act-entries-repl, bun:get-listing-search-context($CONTROLLER-DOC,"xml/listing-search-form.xml",'committee'))))))     
     	    else if ($EXIST-PATH eq "/search-all") then 
            (: ITEMS SEARCH :)     	    
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    $scope := xs:string(request:get-parameter("scope",'global')),
                    $sty := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $acl := "public-view",
                    $act-entries-tmpl :=  bun:search-global($acl,$offset,$limit,$qry,$scope,$sty),
        	        $act-entries-repl:= document {
        								template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl("xml/questions.xml")/xh:div, $act-entries-tmpl)
        							 } 
                return 
                    template:process-tmpl(
                           $REL-PATH, 
                           $EXIST-CONTROLLER, 
                           $config:DEFAULT-TEMPLATE,
                           cmn:get-route($EXIST-PATH),
                            <route-override>
                                {$PARLIAMENT}
                            </route-override>,
                           (cmn:build-nav-node($CONTROLLER-DOC,
                               (template:merge($EXIST-CONTROLLER, 
                                   $act-entries-repl, 
                                   bun:get-global-search-context($EXIST-PATH, 
                                       "xml/global-search-form.xml",
                                       $scope))))
                         )
                    )    
        	else if ($EXIST-PATH eq "/search-settings") then 
                template:process-tmpl(
                    $REL-PATH, 
                    $EXIST-PATH, 
                    $config:DEFAULT-TEMPLATE, 
                    cmn:get-route($EXIST-PATH),
                    <null/>,
                    cmn:build-nav-tmpl($EXIST-PATH, "xml/search-settings.xml")
                )     								    
        	else if ($EXIST-PATH eq "/advanced-search") then 
                template:process-tmpl(
                    $REL-PATH, 
                    $EXIST-CONTROLLER, 
                    $config:DEFAULT-TEMPLATE, 
                    cmn:get-route($EXIST-PATH),
                    <null/>,
                    cmn:rewrite-tmpl($EXIST-PATH, bun:get-advanced-search-context($CONTROLLER-DOC,"xml/advanced-search.xml"))
                ) 
            else if ($EXIST-PATH eq "/search-adv") then 
                let                
                    $chamber := xs:string(request:get-parameter("chamber",'')),                
                
                    $qryall := xs:string(request:get-parameter("qa",'')),
                    $qryexact := xs:string(request:get-parameter("qe",'')),
                    $qryhas := xs:string(request:get-parameter("qh",'')),
                    
                    (: accepts a sequence of parent types as request :)
                    $parenttypes := request:get-parameter("types",()),                    
                    (: accepts a sequence of document types as request :)
                    $doctypes := request:get-parameter("docs",()),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    
                    $override_path := xs:string(request:get-parameter("exist_path","/search-adv")),
                    $status := xs:string(request:get-parameter("std","")),
                    $startdate := xs:string(request:get-parameter("sd",())),  
                    $enddate := xs:string(request:get-parameter("ed",())),
                    $sortby := xs:string(request:get-parameter("sort",$bun:SORT-BY)),
                    
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    
                    $acl := "public-view",
                    $act-entries-tmpl :=  bun:advanced-search($chamber,
                                                            $qryall,
                                                            $qryexact,
                                                            $qryhas,
                                                            $parenttypes,                                                            
                                                            $doctypes,
                                                            $parts,
                                                            $offset,
                                                            $limit,
                                                            $status,
                                                            $startdate,
                                                            $enddate,
                                                            $sortby),
        	        $act-entries-repl := document {
        								   template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
                                        } 
                return 
                template:process-tmpl(
                       $REL-PATH, 
                       $EXIST-CONTROLLER, 
                       $config:DEFAULT-TEMPLATE,
                       cmn:get-route($override_path),
            	        <route-override>
                            {$PARLIAMENT}
                        </route-override>,
                       cmn:build-nav-node($CONTROLLER-DOC,$act-entries-repl)
                )              
            else if ($CHAMBER-REL-PATH eq "/search") then 
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    (: 
                        $scope is either global or listing - Let's us know which search form 
                        has been called to action.
                    :)
                    $scope := xs:string(request:get-parameter("scope",'listing')),
                    $type := xs:string(request:get-parameter("type",'bill')),
                    (:
                      override_path : For the search we want to override the automatic 
                      navigation rendering based on routes. So the search form, embeds 
                      a navigation context as a hidden input field. The hidden input 
                      field captures the origin search context e.g. if the search is being
                      done from a listing for a question. 
                      
                      So we use override_path instead of EXIST-PATH only in the context
                      of rendering the navigation correctly, and not in other cases e.g 
                      copy-and-replace or process-tmpl where the EXIST-PATH is used for 
                      rendering the correct template.
                      
                      Hence we use override_path only for build-nav-node() and get-route()
                      to re-route the navigation.
                    :)
                    $override_path := xs:string(request:get-parameter("exist_path","/search")),
                    $sty := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $acl := "public-view",
                    $log := util:log('debug',$CONTROLLER-DOC),
                    $log1 := util:log('debug',"++++++++++++++SEARCH RES++++++++++++++"),                  
                    $act-entries-tmpl :=  bun:search-criteria($CONTROLLER-DOC,$acl,$offset,$limit,$qry,$sty,$type),
        	        $act-entries-repl:= document {
        								template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl("xml/questions.xml")/xh:div, $act-entries-tmpl)
        							 } 
                return 
                    template:process-tmpl(
                           $REL-PATH, 
                           $EXIST-CONTROLLER,
                           $config:DEFAULT-TEMPLATE,
                           cmn:get-route($override_path),
                            <route-override>
                                {$PARLIAMENT}
                            </route-override>,
                           (cmn:build-nav-node($CONTROLLER-DOC,
                               (template:merge($EXIST-CONTROLLER, 
                                   $act-entries-repl, 
                                   bun:get-listing-search-context($CONTROLLER-DOC, 
                                       "xml/listing-search-form.xml",
                                       $type))))
                         )
                    )
        	else if ($EXIST-RESOURCE eq "epub") then
            (: ePUB RENDERER :)        	
                rou:epub($CONTROLLER-DOC)               
        	else if ($CHAMBER-REL-PATH eq "/member/pdf") then 
        	(: !+FIX-THIS (ao, 11th April 2013 this should be harmonized to use same get-pdf 
        	   method as the other documents, not its own separate one :)
        	    let $views := cmn:get-views-for-type("Member") 
                let $memid := xs:string(request:get-parameter("uri",$bun:DOCNO))
                let $act-entries-tmpl :=  bun:gen-member-pdf($CONTROLLER-DOC,$memid)
                return $act-entries-tmpl                
        	else if ($EXIST-RESOURCE eq "pdf") then
            (: PDF FO GENERATORS :)        	
                rou:get-pdf($CONTROLLER-DOC)
        	else if ($EXIST-RESOURCE eq "xml") then
            (: Raw Ontology XML :)        	
                rou:get-xml($CONTROLLER-DOC)  
        	else if ($EXIST-RESOURCE eq "akn") then
            (: AkomaNtoso XML :)        	
                rou:get-akn($CONTROLLER-DOC)
        	else if ($CHAMBER-REL-PATH eq "/member/xcard") then
            (: xCard XML :)        	
                rou:get-xcard($CONTROLLER-DOC)    									 
        	else if ($CHAMBER-REL-PATH eq "/politicalgroup-members" ) then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $mem-status := xs:string(request:get-parameter("status","current")),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-group-members("public-view",$docnumber,$mem-status,$parts,$PARLIAMENT),
        	        $act-entries-repl:= document {
        								template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
        							 } 
        		 return 
        			template:process-tmpl(
        			   $REL-PATH, 
        			   $EXIST-CONTROLLER, 
        			   $config:DEFAULT-TEMPLATE, 
        			   cmn:get-route($EXIST-PATH),
                        <route-override>
                            <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                            {$PARLIAMENT}
                        </route-override>, 
        			   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
        			 )
        	else if ($CHAMBER-REL-PATH eq "/politicalgroup-contacts" ) then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl := bun:get-contacts-by-uri("public-view","Group",$docnumber,$parts, $PARLIAMENT),
        	        $act-entries-repl:= document {
        								template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
        							 } 
                return 
                    template:process-tmpl(
                       $REL-PATH, 
                       $EXIST-CONTROLLER, 
                       $config:DEFAULT-TEMPLATE, 
                       cmn:get-route($EXIST-PATH),
                        <route-override>
                            <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                            {$PARLIAMENT}
                        </route-override>, 
                       cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
                     )    
        	else if ($CHAMBER-REL-PATH eq "/committee-sittings" ) then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-committee-sittings("public-view",$docnumber,$parts,$PARLIAMENT),
        	        $act-entries-repl:= document {
        								template:copy-and-replace($EXIST-CONTROLLER, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
        							 } 
        							 return 
        								template:process-tmpl(
        								   $REL-PATH, 
        								   $EXIST-CONTROLLER, 
        								   $config:DEFAULT-TEMPLATE, 
        								   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                                {$PARLIAMENT}
                                            </route-override>, 
        								   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
        								 )
        	else if ($CHAMBER-REL-PATH eq "/get-sittings-xml" ) then 
            (: Utilities - Called from root path and meant to be generic calls :)        	
                let $act-entries-tmpl :=  bun:get-sittings-xml("public-view",$PARLIAMENT)
                return $act-entries-tmpl       
            else if ($EXIST-PATH eq "/admin") then 
            (:~ UNMAPPED :)
               template:process-tmpl(
                   $REL-PATH,
                   $EXIST-CONTROLLER,
                   $config:DEFAULT-TEMPLATE,
                   cmn:get-route($EXIST-PATH),
                   <null/>,
                   cmn:build-nav-tmpl($EXIST-PATH, "admin-ui.xml")
                   )
            else if ($EXIST-PATH eq "/preferences") then
                   fw:redirect-rel($EXIST-PATH, "bungeni/user-config.xql")        								        
            else if ($PARLIAMENT) then 
            (: FOR ROUTED APPLICATION REQUESTS :)
                util:eval($action || '($CONTROLLER-DOC)')  
            else  if($CHAMBER-REL-PATH eq "/") then 
                rou:get-home($CONTROLLER-DOC)                  
            else
                fw:ignore()
};
