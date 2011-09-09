module namespace actviewhilite = "http://exist.bungeni.org/actviewhilite";

declare namespace util="http://exist-db.org/xquery/util";
import module namespace lexcustom = "http://exist.bungeni.org/lexcustom" at "custom.xqm";
import module namespace lex = "http://exist.bungeni.org/lex" at "lex.xqm";
import module namespace jquery = "http://exist.bungeni.org/jquery" at "jquery.xqm";
import module namespace yui = "http://exist.bungeni.org/yui" at "yui.xqm";


declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";

(:
: Page template module
: Builds the page out of different chunks of meta, header and body
:)


(:
Returns the <head /> element 
:)
declare function actviewhilite:get-head($page_info as element()) as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
       <head>
       <!-- BeginRenderedBy(actviewhilite:get-head()) -->
            <title>{$page_info/title/text()}</title>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            {yui:get-includes()/child::*} 
            {lexcustom:get-root-js()}
            {jquery:get-generic-js()}
            {jquery:get-custom-js()} 
            {lexcustom:get-custom-css()}            
          <!-- EndRenderedBy(actviewhilite:get-head()) -->
      </head>
 };
 
 
 
 (:
 returns the page header
 The heading and the link bar with the xml viewer
 :)
 declare function actviewhilite:get-page-header($page_info as element()) as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
        <div id="header">
         <!-- BeginRenderedBy(actviewhilite:get-page-header()) -->
            <h1>{$page_info/actno/text()} - {$page_info/heading/text()}</h1>
            <a href="actviewxml.xql?actid={$page_info/actid/string()}&amp;acttitle={$page_info/title/string()}&amp;actno={$page_info/actno/string()}" 
               border="0" target="_blank">
                <img src="images/xml.png" width="35" height="14" />
            </a>
         <!-- EndRenderedBy(actviewhilite:get-page-header()) -->
         </div>
    };
    
 (:
 Returns the content div
 :)
 declare function actviewhilite:get-page-content($doc, $page_info as element()) as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
     <div id="content">
      <!-- BeginRenderedBy(actviewhilite:get-page-content()) -->
      {transform:transform($doc, xs:string($page_info/xslt/text()), 
                                <parameters>
                                  <param name="pref" value="{$page_info/prefix/text()}" />
                                  <param name="searchfor" value="{$page_info/searchfor/text()}" />
                               </parameters>)}
      <!-- EndRenderedBy(actviewhilite:get-page-content()) -->
    </div>
    };   
declare function actviewhilite:get-page-js($page_info as element())  as element() {
        util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
        <script>
        if (YAHOO.util.Dom.get("{$page_info/prefix/text()}-preamble")) {{
            YAHOO.kenyalex.bungeni.TOC = new YAHOO.widget.TreeView("{$page_info/prefix/text()}-preamble");
            YAHOO.kenyalex.bungeni.TOC.render();
        }}
        </script>
};

(:
Displays the page 
:)
declare function actviewhilite:display-page($doc, $page_info as element()) as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
 <html xmlns="http://www.w3.org/1999/xhtml">
    {actviewhilite:get-head($page_info)}
    <body class="yui-skin-sam">
        {actviewhilite:get-page-header($page_info)}
        {actviewhilite:get-page-content($doc, $page_info )}
        {actviewhilite:get-page-js($page_info)}
      </body>
    </html>
};
