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
        return 
        
        if ($EXIST-PATH eq "" ) then
            fw:redirect(fn:concat(request:get-uri(), "/"))  
        else  if($EXIST-PATH eq "" or $EXIST-PATH eq "/" or $EXIST-PATH eq "/xml/index.xml") 
             then
        	   rou:get-home($CONTROLLER-DOC)

    	else if ($CHAMBER-REL-PATH eq "/home" )
    		 then 
                rou:get-home($CONTROLLER-DOC)                  
        	   
    	(: GLUE-SERVICE :)
    	else if ($EXIST-PATH eq "/check-update" )
    		 then 
                let $docuri := xs:string(request:get-parameter("uri","")), 
                    $statusdate := xs:string(request:get-parameter("t","")),
                    $check-up-results :=  bun:check-update($docuri,$statusdate)
                return $check-up-results        
                  
    	(: LANGUAGE-SETTER :)
    	else if ($EXIST-PATH eq "/switch")
    		 then (
                template:set-lang(),
                fw:redirect-rel($EXIST-PATH, request:get-header("Referer"))
            )
            
        (: for attachment downloads :)
    	else if ($EXIST-PATH eq "/download" )
    		 then 
                let $docuri := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $attid := xs:string(request:get-parameter("att",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:get-attachment("public-view",$docuri,$attid)
                return $act-entries-tmpl
                
        (: for images :)
    	else if ($EXIST-PATH eq "/image" )
    		 then 
                let $hash := xs:string(request:get-parameter("hash",'none')), 
                    $name := xs:string(request:get-parameter("name",'unnamed')), 
                    $act-entries-tmpl :=  bun:get-image($hash,$name)
                return $act-entries-tmpl                
                    
    	(: Now we process application requests :)
    	else if ($CHAMBER-REL-PATH eq "/business")
    		 then 
                  fw:redirect(fn:concat(request:get-uri(), "/","../whatson"))  
        else if ($CHAMBER-REL-PATH eq "/members")
    		 then 
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    $sty := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $parts := cmn:get-view-listing-parts('MemberOfParliament', 'member'),
                    $act-entries-tmpl :=  bun:get-members($CONTROLLER-DOC/exist-res,$PARLIAMENT,$offset,$limit,$parts,$qry,$sty),
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
    								        (cmn:build-nav-node($CONTROLLER-DOC,
    								                    (
    								                        template:merge(
    								                          $EXIST-CONTROLLER, 
    								                          $act-entries-repl, 
    								                          bun:get-listing-search-context(
    								                            $EXIST-PATH,
    								                            "xml/listing-search-form.xml",
    								                            'Membership'
    								                            )
    								                        )
    								                   )
    								            )
    								         )
    								    )              
               
        (:~ Handlers for business submenu :)
    	else if ($CHAMBER-REL-PATH eq "/committees")
    		 then 
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
    								        (cmn:build-nav-node($CONTROLLER-DOC,(template:merge($EXIST-PATH, $act-entries-repl, bun:get-listing-search-context($EXIST-PATH,"xml/listing-search-form.xml",'committee')))))
    								    )  
                  
        (:~ ITEM LISTINGS :)        
    	else if ($CHAMBER-REL-PATH eq "/bills")
    		 then 
    		 rou:get-bills($CONTROLLER-DOC)

    	else if ($CHAMBER-REL-PATH eq "/questions")
    		 then 
                 rou:get-questions($CONTROLLER-DOC)
                    
    	else if ($CHAMBER-REL-PATH eq "/motions")
    		 then 
                 rou:get-motions($CONTROLLER-DOC)
                    
    	else if ($CHAMBER-REL-PATH eq "/tableddocuments")
    		 then 
                 rou:get-tableddocuments($CONTROLLER-DOC) 
                    
    	else if ($CHAMBER-REL-PATH eq "/agendaitems")
    		 then 
                 rou:get-agendaitems($CONTROLLER-DOC)                     
        else if ($CHAMBER-REL-PATH eq "/publications")
            then
                rou:get-reports($CONTROLLER-DOC) 
	
        (:~ ITEMS SEARCH :)     
 	    else if ($EXIST-PATH eq "/search-all")
    		 then 
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
    	else if ($EXIST-PATH eq "/search-settings")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-PATH, 
                $config:DEFAULT-TEMPLATE, 
                cmn:get-route($EXIST-PATH),
                <null/>,
                cmn:build-nav-tmpl($EXIST-PATH, "xml/search-settings.xml")
               )     								    
    	else if ($EXIST-PATH eq "/advanced-search")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-CONTROLLER, 
                $config:DEFAULT-TEMPLATE, 
                cmn:get-route($EXIST-PATH),
                <null/>,
                cmn:rewrite-tmpl($EXIST-PATH, bun:get-advanced-search-context($EXIST-CONTROLLER,"xml/advanced-search.xml"))
               ) 
        else if ($EXIST-PATH eq "/search-adv")
    		 then 
                let 
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
                    $act-entries-tmpl :=  bun:advanced-search($qryall,
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
                                               cmn:build-nav-node($override_path,$act-entries-repl)
                                        )              
        else if ($CHAMBER-REL-PATH eq "/search")
    		 then 
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
                    $act-entries-tmpl :=  bun:search-criteria($PARLIAMENT,$acl,$offset,$limit,$qry,$sty,$type),
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
    									       (cmn:build-nav-node($override_path,
    									           (template:merge($EXIST-CONTROLLER, 
    									               $act-entries-repl, 
    									               bun:get-listing-search-context($override_path, 
    									                   "xml/listing-search-form.xml",
    									                   $type))))
    									     )
    								    )
               

        (:~
            Atom FEEDS
        :)    								 
    	else if ($CHAMBER-REL-PATH eq "/bills/rss")
    		 then 
                let
                    $act-entries-tmpl :=  bun:get-atom-feed($CONTROLLER-DOC,"public-view", "Bill","user")
                    return $act-entries-tmpl
    	else if ($CHAMBER-REL-PATH eq "/questions/rss")
    		 then 
                let
                    $act-entries-tmpl :=  bun:get-atom-feed($CONTROLLER-DOC,"public-view","Question","user")
                    return $act-entries-tmpl    
    	else if ($CHAMBER-REL-PATH eq "/motions/rss")
    		 then 
                let
                    $act-entries-tmpl :=  bun:get-atom-feed($CONTROLLER-DOC,"public-view", "Motion","user")
                    return $act-entries-tmpl                     
    	else if ($CHAMBER-REL-PATH eq "/tableddocuments/rss")
    		 then 
                let
                    $act-entries-tmpl :=  bun:get-atom-feed($CONTROLLER-DOC,"public-view", "TabledDocument","user")
                    return $act-entries-tmpl  
    	else if ($CHAMBER-REL-PATH eq "/agendaitems/rss")
    		 then 
                let
                    $act-entries-tmpl :=  bun:get-atom-feed($CONTROLLER-DOC,"public-view", "AgendaItem","user")
                    return $act-entries-tmpl                    
           
        (: ePUB GENERATORS :)
    	else if ($CHAMBER-REL-PATH eq "/bill/epub")   
    		 then 
                let $views := cmn:get-views-for-type("Bill"),
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:gen-epub-output($EXIST-CONTROLLER,$docnumber, $views)
                return $act-entries-tmpl 
    	else if ($CHAMBER-REL-PATH eq "/question/epub")   
    		 then 
                let $views := cmn:get-views-for-type("Question"),
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:gen-epub-output($EXIST-CONTROLLER,$docnumber, $views)
                return $act-entries-tmpl  
    	else if ($CHAMBER-REL-PATH eq "/motion/epub")   
    		 then 
                let $views := cmn:get-views-for-type("Motion"),
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:gen-epub-output($EXIST-CONTROLLER,$docnumber, $views)
                return $act-entries-tmpl 
    	else if ($CHAMBER-REL-PATH eq "/tableddocument/epub")   
    		 then 
                let $views := cmn:get-views-for-type("TabledDocument"),
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:gen-epub-output($EXIST-CONTROLLER,$docnumber, $views)
                return $act-entries-tmpl 
    	else if ($CHAMBER-REL-PATH eq "/agendaitem/epub")   
    		 then 
                let $views := cmn:get-views-for-type("AgendaItem"),
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:gen-epub-output($EXIST-CONTROLLER,$docnumber, $views)
                return $act-entries-tmpl    
    	else if ($CHAMBER-REL-PATH eq "/report/epub")   
    		 then 
                let $views := cmn:get-views-for-type("Report"),
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:gen-epub-output($EXIST-CONTROLLER,$docnumber, $views)
                return $act-entries-tmpl                 
           
        (: PDF FO GENERATORS :)
    	else if ($CHAMBER-REL-PATH eq "/bill/pdf")   
    		 then 
                rou:get-pdf($CONTROLLER-DOC,cmn:get-views-for-type("Bill") )
    	else if ($CHAMBER-REL-PATH eq "/question/pdf")   
    		 then 
                rou:get-pdf($CONTROLLER-DOC,cmn:get-views-for-type("Question") )    
    	else if ($CHAMBER-REL-PATH eq "/motion/pdf")   
    		 then 
                rou:get-pdf($CONTROLLER-DOC,cmn:get-views-for-type("Motion") )  
    	else if ($CHAMBER-REL-PATH eq "/tableddocument/pdf")   
    		 then 
                rou:get-pdf($CONTROLLER-DOC,cmn:get-views-for-type("TabledDocument") )  
    	else if ($CHAMBER-REL-PATH eq "/agendaitem/pdf")   
    		 then 
                rou:get-pdf($CONTROLLER-DOC,cmn:get-views-for-type("AgendaItem") )   
    	else if ($CHAMBER-REL-PATH eq "/report/pdf")   
    		 then 
                rou:get-pdf($CONTROLLER-DOC,cmn:get-views-for-type("Report") )                 
    	else if ($CHAMBER-REL-PATH eq "/member/pdf")   
    		 then 
    		    let $views := cmn:get-views-for-type("MemberOfParliament") 
                let $memid := xs:string(request:get-parameter("uri",$bun:DOCNO))
                let $act-entries-tmpl :=  bun:gen-member-pdf($CONTROLLER-DOC/parliament,$memid,$views)
                return $act-entries-tmpl                           
          
        (:Get Ontology XML:)
    	else if ($CHAMBER-REL-PATH eq "/bill/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC)    
    	else if ($CHAMBER-REL-PATH eq "/question/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC)
    	else if ($CHAMBER-REL-PATH eq "/motion/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC) 
    	else if ($CHAMBER-REL-PATH eq "/tableddocument/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC)
    	else if ($CHAMBER-REL-PATH eq "/agendaitem/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC)    
    	else if ($CHAMBER-REL-PATH eq "/report/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC)                 
    	else if ($CHAMBER-REL-PATH eq "/member/xml")   
    		 then 
                rou:get-xml($CONTROLLER-DOC)  
                
        (:Get AkomaNtoso XML:)
    	else if ($CHAMBER-REL-PATH eq "/bill/akn")   
    		 then 
                rou:get-akn($CONTROLLER-DOC)    
    	else if ($CHAMBER-REL-PATH eq "/question/akn")   
    		 then 
                rou:get-akn($CONTROLLER-DOC)
    	else if ($CHAMBER-REL-PATH eq "/motion/akn")   
    		 then 
                rou:get-akn($CONTROLLER-DOC) 
    	else if ($CHAMBER-REL-PATH eq "/tableddocument/akn")   
    		 then 
                rou:get-akn($CONTROLLER-DOC)
    	else if ($CHAMBER-REL-PATH eq "/agendaitem/akn")   
    		 then 
                rou:get-akn($CONTROLLER-DOC) 
    	else if ($CHAMBER-REL-PATH eq "/report/akn")   
    		 then 
                rou:get-akn($CONTROLLER-DOC)                 
                
        (:Get xCard XML:)
    	else if ($CHAMBER-REL-PATH eq "/membership/xcard")   
    		 then 
                rou:get-xcard($CONTROLLER-DOC)                
                
    	else if ($CHAMBER-REL-PATH eq "/politicalgroups")
    		 then 
                let 
                    $qry := xs:string(request:get-parameter("q",'')),
                    $sty := xs:string(request:get-parameter("s",$bun:SORT-BY)),
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $parts := cmn:get-view-listing-parts('PoliticalGroup','profile'),
                    $act-entries-tmpl :=  bun:get-politicalgroups($CONTROLLER-DOC/exist-res,$PARLIAMENT,$offset,$limit,$parts,$qry,$sty),
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
    								        (cmn:build-nav-node($CONTROLLER-DOC,(template:merge($EXIST-PATH, $act-entries-repl, bun:get-listing-search-context($EXIST-PATH, "xml/listing-search-form.xml",'politicalgroup')))))
    								    )
    	else if ($CHAMBER-REL-PATH eq "/politicalgroup-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-group("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/government-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-group("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/ministry-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-group("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/politicalgroup-members" )
    		 then 
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
    	else if ($CHAMBER-REL-PATH eq "/politicalgroup-contacts" )
    		 then 
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
    	else if ($CHAMBER-REL-PATH eq "/committee-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-group("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/committee-members" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $mem-status := xs:string(request:get-parameter("status","current")),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-committee("public-view",$docnumber,$mem-status,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/committee-sittings" )
    		 then 
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
    	else if ($CHAMBER-REL-PATH eq "/committee-staff" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $mem-status := xs:string(request:get-parameter("status","current")),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-committee("public-view",$docnumber,$mem-status,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/committee-contacts" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $mem-status := xs:string(request:get-parameter("status","current")),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-committee("public-view",$docnumber,$mem-status,$parts,$PARLIAMENT),
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
    								    
    	else if ($CHAMBER-REL-PATH eq "/bill-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/bill-version/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    									 
    	else if ($CHAMBER-REL-PATH eq "/bill-timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),      
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl := bun:get-parl-doc-timeline("public-view",$docnumber,$parts,$PARLIAMENT),
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
    									 
    	else if ($CHAMBER-REL-PATH eq "/bill-assignedgroups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),     
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
                                            </route-override>, 
    									   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
    									 )    									 								
    									
    	else if ($CHAMBER-REL-PATH eq "/bill-documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),      
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc-with-events("public-view", $docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/bill-version/documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),      
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/bill-event" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-event($docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/bill-attachment" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-attachment($docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/question-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/question-version/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),       
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
                                            </route-override>,    									   
    									   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
    									)    									
    									
    	else if ($CHAMBER-REL-PATH eq "/question-timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),     
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc-timeline("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/question-assignedgroups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),     
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/question-documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/question-version/documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),      
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
                                            </route-override>, 
    									   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
    									)    
    	else if ($CHAMBER-REL-PATH eq "/question-event" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-event($docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/question-attachment" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-attachment($docnumber,$parts),
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
                                            </route-override>,
                                            cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
                                        )     									
    									
    	else if ($CHAMBER-REL-PATH eq "/motion-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),   
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/motion-version/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),    
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/motion-timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),    
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc-timeline("public-view",$docnumber,$parts,$PARLIAMENT),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/motion-version" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
                                            </route-override>, 
    									   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
    									 ) 								
    	else if ($CHAMBER-REL-PATH eq "/motion-assignedgroups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),    
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/motion-documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/motion-version/documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view",$docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/motion-event" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),   
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-event($docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/motion-attachment" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-attachment($docnumber,$parts),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-version/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),     
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc-timeline("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-assignedgroups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),    
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view", $docnumber,$parts,$PARLIAMENT),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view", $docnumber,$parts,$PARLIAMENT),
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
    									 
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-version" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-event" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-event($docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/tableddocument-attachment" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-attachment($docnumber,$parts),
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
        (: AGENDA ITEMS :)
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),             
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-version/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),   
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc-timeline("public-view",$docnumber,$parts,$PARLIAMENT),
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
                                            </route-override>, 
    									   cmn:build-nav-node($CONTROLLER-DOC, $act-entries-repl)
    									)  									
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-assignedgroups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view", $docnumber,$parts,$PARLIAMENT),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-documents" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),       
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view", $docnumber,$parts,$PARLIAMENT),
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
    									 
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-version" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-ver("public-view", $docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-event" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),        
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-event($docnumber,$parts),
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
    	else if ($CHAMBER-REL-PATH eq "/agendaitem-attachment" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-doc-attachment($docnumber,$parts),
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
        (: REPORTS :)
    	else if ($CHAMBER-REL-PATH eq "/report-text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc("public-view",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/report-timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),     
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-doc-timeline("public-view",$docnumber,$parts,$PARLIAMENT),
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
        (: SITTINGS :)    									
    	else if ($CHAMBER-REL-PATH eq "/sitting" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:get-sitting("public-view",$docnumber,"xsl/sitting.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("xml/sitting.xml")/xh:div, $act-entries-tmpl)
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
        (: Utilities - Called from root path and meant to be generic calls :)
    	else if ($EXIST-PATH eq "/popout" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),  
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  bun:get-doc-event-popout($docnumber,$parts)
                    return
                        i18n:process($act-entries-tmpl, template:set-lang(), $config:I18N-MESSAGES, $config:DEFAULT-LANG)
                    
    	else if ($CHAMBER-REL-PATH eq "/get-sittings-xml" )
    		 then 
                let $act-entries-tmpl :=  bun:get-sittings-xml("public-view")
                    return $act-entries-tmpl
                    
        (:~ MEMBER INFORMATION :)
    
    	else if ($CHAMBER-REL-PATH eq "/member" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),     
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-member($docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/member-officesheld" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),   
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-member-officesheld($docnumber,$parts,$PARLIAMENT),
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

    	else if ($CHAMBER-REL-PATH eq "/member-parlactivities" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)), 
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-parl-activities("public-view",$docnumber,$parts,$PARLIAMENT),
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
    									
    	else if ($CHAMBER-REL-PATH eq "/member-contacts" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),           
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $act-entries-tmpl :=  bun:get-contacts-by-uri("public-view","MemberOfParliament",$docnumber,$parts,$PARLIAMENT),
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
    	else if ($CHAMBER-REL-PATH eq "/whatson")
    		 then 
                let
                    $parts := cmn:get-view-parts($CHAMBER-REL-PATH),
                    $woview := xs:string(request:get-parameter("showing",'twk')),   
                    $tab := xs:string(request:get-parameter("tab",'sittings')),  
                    $mtype := xs:string(request:get-parameter("mtype",'any')), 
                    $act-entries-tmpl :=  bun:get-whatson($woview,$tab,$mtype,$parts,$PARLIAMENT),
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
                                                {$PARLIAMENT}
                                            </route-override>, 
    								        (cmn:build-nav-node($CONTROLLER-DOC,
    								            (
    								                template:merge($EXIST-PATH, 
    								                        $act-entries-repl, 
    								                        bun:get-listing-search-context(
    								                            $EXIST-PATH,
    								                            "xml/listing-search-form.xml",'whatson'
    								                            )
    								                      )
    								             )
    								            )
    								        )
    								    )     									
    	else if ($CHAMBER-REL-PATH eq "/calendar")
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),
                    $act-entries-tmpl :=  bun:get-sitting("public-view",$docnumber,"xsl/calendar.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("xml/calendar.xml")/xh:div, $act-entries-tmpl)
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
    									 
        (:~ UNMAPPED :)			       
        else if ($CHAMBER-REL-PATH eq "/politicalgroups")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-CONTROLLER, 
                $config:DEFAULT-TEMPLATE, 
                cmn:get-route($EXIST-PATH),
                <null/>,
                cmn:build-nav-tmpl($EXIST-PATH, "xml/politicalgroups.xml")
               )  
       else if ($EXIST-PATH eq "/admin") 
            then
               template:process-tmpl(
                   $REL-PATH,
                   $EXIST-CONTROLLER,
                   $config:DEFAULT-TEMPLATE,
                   cmn:get-route($EXIST-PATH),
                   <null/>,
                   cmn:build-nav-tmpl($EXIST-PATH, "admin-ui.xml")
                   )
       else if ($EXIST-PATH eq "/preferences")
             then
               fw:redirect-rel($EXIST-PATH, "bungeni/user-config.xql")
       else if ($EXIST-PATH eq "/testing/blue/color") 
              then
    		 <doc>
                <req>{request:get-server-name()}</req>
                <ep> {$EXIST-PATH}</ep>
                <root>{$EXIST-ROOT}</root>
                <cont>{$EXIST-CONTROLLER}</cont>
                <res>{$EXIST-RESOURCE}</res>
                <relpath>{$REL-PATH}</relpath>
                <context-path>{request:get-context-path()}</context-path>
    		 </doc>
    	else
            fw:ignore()
};
