xquery version "1.0";

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

(:~
Application imports
:)
import module namespace akn = "http://exist.bungeni.org/akn" at "anapp.xqm";
import module namespace rou = "http://exist.bungeni.org/rou" at "route.xqm";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";

(:~
All applications using the XQ framework must implement the appcontroller namespace module with the function 
called appcontroller:controller() in the same pattern as below
:)
declare function appcontroller:controller($EXIST-PATH as xs:string, 
                                $EXIST-ROOT as xs:string, 
                                $EXIST-CONTROLLER as xs:string, 
                                $EXIST-RESOURCE as xs:string, 
                                $REL-PATH as xs:string) {
        if ($EXIST-PATH eq "" ) then
        	fw:redirect(fn:concat(request:get-uri(), "/"))
        else if($EXIST-PATH eq "/" or $EXIST-PATH eq "/home" or $EXIST-PATH eq "/index.xml") 
             then
        	   rou:get-home(
        		  $EXIST-PATH , 
                  $EXIST-ROOT , 
                  $EXIST-CONTROLLER, 
                  $EXIST-RESOURCE, 
                  $REL-PATH
                  )     
                  
    	(: LANGUAGE-SETTER :)
    	else if ($EXIST-PATH eq "/switch")
    		 then (
                template:set-lang(),
                fw:redirect-rel($EXIST-PATH, request:get-header("Referer"))
            )
                    
    	(: Now we process application requests :)
    	else if ($EXIST-PATH eq "/business")
    		 then 
        		 rou:get-bills($EXIST-PATH, 
                        $EXIST-ROOT, 
                        $EXIST-CONTROLLER, 
                        $EXIST-RESOURCE, 
                        $REL-PATH)
                        
        (:~ ITEM LISTINGS :)        
    	else if ($EXIST-PATH eq "/acts")
    		 then 
    		 rou:get-acts($EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH)                        
                          
    	else if ($EXIST-PATH eq "/bills")
    		 then 
    		 rou:get-bills($EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH)
                    
    	else if ($EXIST-PATH eq "/debates")
    		 then 
    		 rou:get-debates($EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH)  
                    
    	else if ($EXIST-PATH eq "/reports")
    		 then 
    		 rou:get-reports($EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH)                     

    	else if ($EXIST-PATH eq "/amendments")
    		 then 
                 rou:get-amendments(
                    $EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH
                    )  
                    
    	else if ($EXIST-PATH eq "/judgements")
    		 then 
                 rou:get-judgements(
                    $EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH
                    )  
                    
    	else if ($EXIST-PATH eq "/gazettes")
    		 then 
                 rou:get-gazettes(
                    $EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH
                    )  
                    
    	else if ($EXIST-PATH eq "/misc")
    		 then 
                 rou:get-misc-docs(
                    $EXIST-PATH, 
                    $EXIST-ROOT, 
                    $EXIST-CONTROLLER, 
                    $EXIST-RESOURCE, 
                    $REL-PATH
                    )                    
                    
        (:Get AkomaNtoso XML:)
    	else if ($EXIST-PATH eq "/act/xml")   
    		 then 
                rou:get-xml($EXIST-PATH, 
                            $EXIST-ROOT, 
                            $EXIST-CONTROLLER, 
                            $EXIST-RESOURCE, 
                            $REL-PATH)    
    	else if ($EXIST-PATH eq "/bill/xml")   
    		 then 
                rou:get-xml($EXIST-PATH, 
                            $EXIST-ROOT, 
                            $EXIST-CONTROLLER, 
                            $EXIST-RESOURCE, 
                            $REL-PATH)   
                            
    	else if ($EXIST-PATH eq "/act/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )                             
    								    
    	else if ($EXIST-PATH eq "/bill/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )  									 
     	   
    	else if ($EXIST-PATH eq "/amendment/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),  
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>,
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)  		
    									
    	else if ($EXIST-PATH eq "/debate/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )     	
    									 
    	else if ($EXIST-PATH eq "/report/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )     
    									 
    	else if ($EXIST-PATH eq "/judgement/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )
    									 
    	else if ($EXIST-PATH eq "/gazette/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )  

    	else if ($EXIST-PATH eq "/misc/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$akn:DOCNO)),
                    $parts := cmn:get-view-parts($EXIST-PATH),
                    $act-entries-tmpl :=  akn:get-akn-doc("public-view",$docnumber,$parts),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl($parts/template)/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
                                            <route-override>
                                                <xh:title>{data($act-entries-tmpl//xh:div[@id='title-holder'])}</xh:title>
                                            </route-override>, 
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )
    									
       else if ($EXIST-PATH eq "/testing/blue/color") 
              then
                <xml>{request:get-effective-uri()}</xml>              
    	else
            fw:ignore()
};
