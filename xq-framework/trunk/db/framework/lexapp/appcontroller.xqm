xquery version "1.0";
(:~

Application controller implementation of the lexapp sample application

:)

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
Application specific module imports
:)
import module namespace lex = "http://exist.bungeni.org/lex" at "lex.xqm";

(:~
: All applications using the XQ-framework must implement application controllers on the below pattern.
: The controller must always be in the http://bungeni.org/exist/appcontroller namespace, and implement
: a controller function with the parameters specified.
:
: @param EXIST-PATH
:   The last part of the request URI after the section leading to the controller. If the resource example.xml 
:   resides within the same directory as the controller query, $EXIST-PATH will be /example.xml.
: @param EXIST-ROOT
:   The root of the current controller hierarchy. This may either point to the file system or to a collection 
:   in the database. Use this variable to locate resources relative to the root of the application.
: @param EXIST-CONTROLLER
:   The part of the URI leading to the current controller script. For example, if the request path is 
:   /xquery/test.xql and the controller is in the xquery directory, $exist:controller would contain /xquery.
: @param EXIST-RESOURCE
:   The section of the URI after the last /, usually pointing to a resource, e.g. example.xml.
: @param REL-PATH
:   This EXIST-ROOT & EXIST-CONTROLLER concatenated by a /
:
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
        		template:process-template(
        		   $REL-PATH, $EXIST-PATH, $config:DEFAULT-TEMPLATE, 
        		   ( fw:app-tmpl("menu.xml"), fw:app-tmpl("index.xml"))
        		)
    	(: Now we process application requests :)
    	else if ($EXIST-PATH eq "/by-title")
    		 then 
               template:process-template(
                    $REL-PATH, $EXIST-PATH, $config:DEFAULT-TEMPLATE, 
                    ( fw:app-tmpl("menu.xml"), fw:app-tmpl("by-title.xml"))
               )
    	else if ($EXIST-PATH eq "/by-keyword")
    		 then 
               template:process-template(
                    $REL-PATH, $EXIST-PATH, $config:DEFAULT-TEMPLATE, 
                    ( fw:app-tmpl("menu.xml"), fw:app-tmpl("by-keyword.xml"))
               )
        else if ($EXIST-PATH eq "/by-capno")
		     then 
               let $act-entries-tmpl := lex:get-acts(),
		           $act-entries-repl:= document {
						 template:copy-and-replace(
						   $EXIST-PATH, 
						   fw:app-tmpl("acts-list.xml")/xh:div, 
						   $act-entries-tmpl
						  )
					   } return template:process-template(
					       $REL-PATH, 
					       $EXIST-PATH, 
					       $config:DEFAULT-TEMPLATE,(
					           fw:app-tmpl("menu.xml"),	
					           template:merge(
					               $EXIST-PATH, 
					               fw:app-tmpl("act-list-page.xml"), 
					               $act-entries-repl
					           )
					       )
					     )			               
        else if ($EXIST-RESOURCE eq 'searchbytitle') 
    		 then
    		   fw:app-chain-forward("titlesearch.xql", "translate-titlesearch.xql")
     	else if ($EXIST-RESOURCE eq 'viewacttoc')
             then 
              fw:app-chain-forward("viewacttoc.xql", "translate-toc.xql")
        else if ($EXIST-RESOURCE eq 'actview') 
    		 then 
		        let $actcontent := lex:get-act(fw:get("actid"),fw:get("pref"),"actfull.xsl"),
                    $actdoc := document {
                        template:copy-and-replace($EXIST-PATH,
                        fw:app-tmpl("actview.xml")/xh:div, 
                        $actcontent)
                       } return 
                          template:process-template(
                            $REL-PATH, 
                            $EXIST-PATH, 
                            $config:DEFAULT-TEMPLATE, 
                            (fw:app-tmpl("menu.xml"), $actdoc)
                          ) 
        else
            fw:ignore()
};
