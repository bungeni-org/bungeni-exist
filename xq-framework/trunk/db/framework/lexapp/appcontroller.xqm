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



import module namespace lex = "http://exist.bungeni.org/lex" at "lex.xqm";

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
        else if ($EXIST-RESOURCE eq 'searchbytitle') 
    		 then
    		   fw:app-chain-forward("titlesearch.xql", "translate-titlesearch.xql")
     	else if ($EXIST-RESOURCE eq 'viewacttoc')
             then 
              fw:app-chain-forward("viewacttoc.xql", "translate-toc.xql")
        else if ($EXIST-RESOURCE eq 'actview') 
    		 then 
    		  let $actcontent := lex:get-act(fw:get("actid"),fw:get("pref"),"actfull.xsl") return document {
                    template:copy-and-replace($EXIST-PATH,
                    fw:app-tmpl("actview.xml")/xh:div, 
                    $actcontent)
                 }
    	else
            fw:ignore()
};
