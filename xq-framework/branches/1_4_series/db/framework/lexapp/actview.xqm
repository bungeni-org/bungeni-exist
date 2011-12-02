module namespace actview = "http://exist.bungeni.org/actview";

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
declare function actview:get-head($title as xs:string) as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
       <head>
       <!-- BeginRenderedBy(actview:get-head()) -->
            <title>{$title}</title>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            {yui:get-includes()/child::*} 
            {lexcustom:get-root-js()}
            {jquery:get-generic-js()}
            {jquery:get-custom-js()} 
            {lexcustom:get-custom-css()}            
          <!-- EndRenderedBy(actview:get-head()) -->
      </head>
 };
 
 
 
 (:
 returns the page header 
 :)
 declare function actview:get-page-header($title as xs:string, $actnum as xs:string, $actid as xs:string) as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
        <div id="header">
        <!-- BeginRenderedBy(actview:get-page-header()) -->
            <h1>{$actnum} - {$title} </h1>
	    <a href="actviewxml.xql?actid={$actid}&amp;acttitle={$title}&amp;actno={$actnum}" 
               border="0" target="_blank">
                <img src="images/xml.png" width="35" height="14" />
            </a>
        
        <!-- EndRenderedBy(actview:get-page-header()) -->
         </div>
    };
    
 (:
 Returns the content div
 :)
 declare function actview:get-page-content($doc , $actxsl as xs:string, $prefid as xs:string) as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
     <div id="content">
      <!-- BeginRenderedBy(actview:get-page-content()) -->
      {transform:transform($doc, $actxsl, <parameters><param name="pref" value="{$prefid}" /></parameters>)}
      <!-- EndRenderedBy(actview:get-page-content()) -->
    </div>
    };   
declare function actview:get-page-js($prefid as xs:string)  as element() {
        util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
        <script>
        if (YAHOO.util.Dom.get("{$prefid}-preamble")) {{
            YAHOO.kenyalex.bungeni.TOC = new YAHOO.widget.TreeView("{$prefid}-preamble");
            YAHOO.kenyalex.bungeni.TOC.render();
        }}
        </script>
};

(:
Displays the page 
:)
declare function actview:display-page($doc, $actid as xs:string , $actnum as xs:string, $title as xs:string, $actxsl as xs:string, $prefid as xs:string) as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
 <html xmlns="http://www.w3.org/1999/xhtml">
    {actview:get-head($title)}
    <body class="yui-skin-sam">
        {actview:get-page-header($title, $actnum, $actid)}
        {actview:get-page-content($doc, $actxsl, $prefid )}
        {actview:get-page-js($prefid)}
      </body>
    </html>
};
