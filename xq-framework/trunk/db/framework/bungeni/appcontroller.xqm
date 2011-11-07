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
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni.xqm";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm"; 



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
        		template:process-tmpl(
        		   $REL-PATH, 
        		   $EXIST-PATH, 
        		   $config:DEFAULT-TEMPLATE,
        		   cmn:get-route($EXIST-PATH),
        		   cmn:build-nav-tmpl($EXIST-PATH, "index.xml")
        		)
        		
    	(: Now we process application requests :)
    	else if ($EXIST-PATH eq "/business")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-PATH, 
                $config:DEFAULT-TEMPLATE, 
                cmn:get-route($EXIST-PATH),
                cmn:build-nav-tmpl($EXIST-PATH, "business.xml")
               )
               
        (:~ Handlers for business submenu :)
        else if ($EXIST-PATH eq "/committees")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-PATH, 
                $config:DEFAULT-TEMPLATE, 
                cmn:get-route($EXIST-PATH),
                cmn:build-nav-tmpl($EXIST-PATH, "committees.xml")
               )
                
    	else if ($EXIST-PATH eq "/bills")
    		 then 
                let 
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $act-entries-tmpl :=  bun:get-bills($offset,$limit),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("bills.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    								    template:process-tmpl(
    								        $REL-PATH, 
    								        $EXIST-PATH, 
    								        $config:DEFAULT-TEMPLATE,
    								        cmn:get-route($EXIST-PATH),
    								        cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    								    )
    								    
    	else if ($EXIST-PATH eq "/questions")
    		 then 
                let 
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $act-entries-tmpl :=  bun:get-questions($offset,$limit),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("questions.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    								    template:process-tmpl(
    								        $REL-PATH, 
    								        $EXIST-PATH, 
    								        $config:DEFAULT-TEMPLATE,
    								        cmn:get-route($EXIST-PATH),
    								        cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    								    )
    								    
    	else if ($EXIST-PATH eq "/motions")
    		 then 
                let 
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $act-entries-tmpl :=  bun:get-motions($offset,$limit),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("motions.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    								    template:process-tmpl(
    								        $REL-PATH, 
    								        $EXIST-PATH, 
    								        $config:DEFAULT-TEMPLATE,
    								        cmn:get-route($EXIST-PATH),
    								        cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    								    )
    								    
    	else if ($EXIST-PATH eq "/tableddocuments")
    		 then 
                let 
                    $offset := xs:integer(request:get-parameter("offset",$bun:OFF-SET)),
                    $limit := xs:integer(request:get-parameter("limit",$bun:LIMIT)),
                    $act-entries-tmpl :=  bun:get-tableddocs($offset,$limit),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("tableddocuments.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    								    template:process-tmpl(
    								        $REL-PATH, 
    								        $EXIST-PATH, 
    								        $config:DEFAULT-TEMPLATE,
    								        cmn:get-route($EXIST-PATH),
    								        cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    								    )
    								    
    	else if ($EXIST-PATH eq "/question/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"question.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("question.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/question/timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"changes.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("changes.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/question/related" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"related.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("related.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/question/attachments" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"attachments.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("attachments.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/bill/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"bill.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("bill.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )
    									 
    	else if ($EXIST-PATH eq "/bill/timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"changes.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("changes.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )
    									 
    	else if ($EXIST-PATH eq "/bill/related" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"related.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("related.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/bill/attachments" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"attachments.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("attachments.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/motion/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"motion.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("motion.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/motion/timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"changes.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("changes.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/motion/related" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"related.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("related.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/motion/assigned-groups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"assigned-groups.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("assigned-groups.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE, 
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/motion/attachments" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"attachments.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("attachments.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/tableddocument/text" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"tableddocument.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("tableddocument.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/tableddocument/timeline" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"changes.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("changes.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/tableddocument/related" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"related.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("related.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/tableddocument/assigned-groups" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"assigned-groups.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("assigned-groups.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    									
    	else if ($EXIST-PATH eq "/tableddocument/attachments" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("doc",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-parl-doc($docnumber,"attachments.xsl"),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("attachments.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									 )

    	else if ($EXIST-PATH eq "/member" )
    		 then 
                let 
                    $docnumber := xs:string(request:get-parameter("uri",$bun:DOCNO)),                
                    $act-entries-tmpl :=  bun:get-member($docnumber),
    		        $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("member.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-tmpl(
    									   $REL-PATH, 
    									   $EXIST-PATH, 
    									   $config:DEFAULT-TEMPLATE,
    									   cmn:get-route($EXIST-PATH),
    									   cmn:build-nav-node($EXIST-PATH, $act-entries-repl)
    									)
    			    			    
    	else if ($EXIST-PATH eq "/politicalgroups")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-PATH, 
                $config:DEFAULT-TEMPLATE, 
                cmn:get-route($EXIST-PATH),
                cmn:build-nav-tmpl($EXIST-PATH, "politicalgroups.xml")
               )
               
        else if ($EXIST-PATH eq "/members")
    		 then 
               template:process-tmpl(
                $REL-PATH, 
                $EXIST-PATH, 
                $config:DEFAULT-TEMPLATE,
                cmn:get-route($EXIST-PATH),
                cmn:build-nav-tmpl($EXIST-PATH, "members.xml")
               )               
    	(:else if ($EXIST-PATH eq "/by-capno")
    		 then 
               let $act-entries-tmpl := bun:get-bills(0,0),
    		       $act-entries-repl:= document {
    									template:copy-and-replace($EXIST-PATH, fw:app-tmpl("acts-list.xml")/xh:div, $act-entries-tmpl)
    								 } 
    								 return 
    									template:process-template($REL-PATH, $EXIST-PATH, $config:DEFAULT-TEMPLATE, (
    										fw:app-tmpl("menu.xml"), 
    										template:merge($EXIST-PATH, fw:app-tmpl("act-list-page.xml"), $act-entries-repl)
    										)
    									) :)                
    	else
            fw:ignore()
};
