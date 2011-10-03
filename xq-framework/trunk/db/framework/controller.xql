xquery version "1.0";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace xh = "http://www.w3.org/1999/xhtml";


import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace util = "http://exist-db.org/xquery/util";

import module namespace config = "http://bungeni.org/xquery/config" at "config.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "template.xqm";

(:app modules:)
import module namespace lex = "http://exist.bungeni.org/lex" at "lexapp/lex.xqm";

(: xhtml 1.1 :)
(:
declare option exist:serialize "media-type=text/html method=xhtml doctype-public=-//W3C//DTD&#160;XHTML&#160;1.1//EN doctype-system=http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd";
:)
declare option exist:serialize "media-type=text/html method=xhtml";

(:~
The below are explained here :

http://www.exist-db.org/urlrewrite.html#d1830e343

:)
declare variable $exist:path external;
declare variable $exist:root external;
declare variable $exist:controller external;

(: The default template :)
declare variable $DEFAULT-TEMPLATE := "template.xhtml";
declare variable $REL-PATH := fn:concat($exist:root, '/', $exist:controller);
declare variable $APP-PREF := $config:app-prefix;

(: Helper Functions :)

(:~
Abbreviated API to get a request parameter
:)
declare function local:get($param as xs:string) as xs:string {
    request:get-parameter($param, "")
};


declare function local:app-tmpl($uri as xs:string) as document-node() {
   fn:doc(fn:concat($APP-PREF, $uri))
};

(: do nothing ! :)
declare function local:ignore() as element(exist:ignore) {
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>
};

(:~ 
do a local redirect, the web browser will send a second request and this will
again be filtered by XQueryURLRewrite.
:)
declare function local:redirect($uri as xs:string) as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$uri}"/>
    </dispatch>
};

(:~
Chain and forward -- this is the typical query pattern for Ajax requests 
This specifically assumes all the scripts are in the application folder
:)
declare function local:app-chain-forward($uri1 as xs:string, $uri2 as xs:string) as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <forward url="{$APP-PREF}{$uri1}" />
      <view>
        <forward url="{$APP-PREF}{$uri2}" />
	  </view>
    </dispatch>
};

(:
Dynamically rewrite all the urls in the page based on the url that you access 
it from. This ensures that URL's dont break even when you have a complex virtual
url hierarchy maintained via controller.xql.
:)
declare function local:redirect-rel($uri as xs:string) as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{template:make-relative-uri($exist:path, $uri)}"/>
    </dispatch>
};


declare function local:apply-specific-menu($standard-menus as document-node()+, $specific-menu as document-node()) as document-node()+ {
    for $standard-menu in $standard-menus return
        template:merge($exist:path, $standard-menu, $specific-menu)
};


(:~
Controller XQuery for the lexsearch application.
Intercepts incoming named resource requests and forwards appropriately.
This script allows separation of view from control logic.

- default redirector to the home page (index.xql)

- searchbytitle 
  * titlesarch.xql - searchs for an actid and retrieves an xml snapshot
  * translate-titlesearch.xql - accepts the xml snapshot, transforms to html and returns it back
     in a html response to the caller
     
- viewfullact - used to retrieve a full act document as html. accepts 2 parameters, the actidentifier and 
   the id prefix. THe id prefix is passed in and is prefixed on identifiers in the transformed html page. 
   This is because there are instances when 2 acts are retrieved on the same page - and they could have 
   clashing identifiers.
   * uses the same pattern as searchbytitle - the first script in the chain returns xml, the second script,
     transforms the xml to html.
     
:)

let $menus := local:app-tmpl("menu.xml")

(: Root path: redirect to index.xql :)
return (: First process all framework requests :)
    if ($exist:path eq "" ) then
    	local:redirect(fn:concat(request:get-uri(), "/"))
    else if($exist:path eq "/" or $exist:path eq "/home" or $exist:path eq "/index.xml") then
    		template:process-template($REL-PATH, $exist:path, $DEFAULT-TEMPLATE, ( $menus, local:app-tmpl("index.xml")))
	(: Now we process application requests :)
	else if ($exist:path eq "/by-title")
		 then 
           template:process-template($REL-PATH, $exist:path, $DEFAULT-TEMPLATE, ( $menus, local:app-tmpl("by-title.xml")))
	else if ($exist:path eq "/by-keyword")
		 then 
           template:process-template($REL-PATH, $exist:path, $DEFAULT-TEMPLATE, ( $menus, local:app-tmpl("by-keyword.xml")))
    else if ($exist:resource eq 'searchbytitle') 
		 then
		   local:app-chain-forward("titlesearch.xql", "translate-titlesearch.xql")
 	else if ($exist:resource eq 'viewacttoc')
         then 
          local:app-chain-forward("viewacttoc.xql", "translate-toc.xql")
    else if ($exist:resource eq 'actview') 
		 then 
		  let $actcontent := lex:get-act(local:get("actid"),local:get("pref"),"actfull.xsl") return document {
                template:copy-and-replace($exist:path,
                local:app-tmpl("actview.xml")/xh:div, 
                $actcontent)
             }
	else
        local:ignore()
