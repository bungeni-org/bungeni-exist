xquery version "1.0";

module namespace fw = "http://bungeni.org/xquery/fw";

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


(:~
Abbreviated API to get a request parameter
:)
declare function fw:get($param as xs:string) as xs:string {
    request:get-parameter($param, "")
};




declare function fw:app-tmpl($uri as xs:string) as document-node() {
   fn:doc(fn:concat($config:app-prefix, $uri))
};




(: do nothing ! :)
declare function fw:ignore() as element(exist:ignore) {
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>
};

(:~ 
do a local redirect, the web browser will send a second request and this will
again be filtered by XQueryURLRewrite.
:)
declare function fw:redirect($uri as xs:string) as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$uri}"/>
    </dispatch>
};

(:~
Chain and forward -- this is the typical query pattern for Ajax requests 
This specifically assumes all the scripts are in the application folder
:)
declare function fw:app-chain-forward($uri1 as xs:string, $uri2 as xs:string) as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <forward url="{$config:app-prefix}{$uri1}" />
      <view>
        <forward url="{$config:app-prefix}{$uri2}" />
	  </view>
    </dispatch>
};

(:
Dynamically rewrite all the urls in the page based on the url that you access 
it from. This ensures that URL's dont break even when you have a complex virtual
url hierarchy maintained via controller.xql.
:)
declare function fw:redirect-rel($EXIST-PATH as xs:string, $uri as xs:string) as element(exist:dispatch) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{template:make-relative-uri($EXIST-PATH, $uri)}"/>
    </dispatch>
};


declare function fw:apply-specific-menu($standard-menus as document-node()+, $specific-menu as document-node()) as document-node()+ {
    for $standard-menu in $standard-menus return
        template:merge($exist:path, $standard-menu, $specific-menu)
};
