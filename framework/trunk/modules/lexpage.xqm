module namespace lexpage = "http://exist.bungeni.org/lexpage";

declare namespace util="http://exist-db.org/xquery/util";

import module namespace yui = "http://exist.bungeni.org/yui" at "yui.xqm"; 

import module namespace lexcustom = "http://exist.bungeni.org/lexcustom" at "custom.xqm";
(: Tab module imports :)
import module namespace titlesearch = "http://exist.bungeni.org/lexpage/titlesearch" at "titlesearch.xqm";
import module namespace capsearch = "http://exist.bungeni.org/lexpage/capsearch" at "capsearch.xqm";
import module namespace adsearch = "http://exist.bungeni.org/lexpage/adsearch" at "adsearch.xqm";

declare namespace request="http://exist-db.org/xquery/request";

(:
: Page template module
: Builds the page out of different chunks of meta, header and body
:)


(:
Returns the <head /> element 
:)
declare function lexpage:get-head($pageinfo as element()) as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
       <head>
       <!-- BeginRenderedBy(lexpage:get-head()) -->
            <title>{$pageinfo/title/text()}</title>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            {yui:get-includes()/child::*} 
            {lexcustom:get-root-js()}
            {lexcustom:get-custom-css()}
            {lexpage:get-custom-js()}
            {lexcustom:get-file-js()}
       <!-- EndRenderedBy(lexpage:get-head()) -->
      </head>
 };
 
 
 
 (:
 returns the page header 
 :)
 declare function lexpage:get-page-header($pageinfo as element()) as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
        <div id="header">
        <!-- BeginRenderedBy(lexpage:get-page-header()) -->
            <h1>{$pageinfo/heading/text()}</h1>
        <!-- EndRenderedBy(lexpage:get-page-header()) -->
         </div>
    };
    
 (:
 Returns the content div
 :)
 declare function lexpage:get-page-content() as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
      <div id="content">
      <!-- BeginRenderedBy(lexpage:get-page-content()) -->
       <!-- load the YUI tabviews -->
       <div id="tabcontent" class="yui-navset">
          <!-- tab headings -->
          <ul class="yui-nav">
              <li class="selected"><a href="#tab1"><em>Act Title</em></a></li>
              <li><a href="#tab2"><em>Cap Number</em></a></li>
              <!-- <li><a href="#tab3"><em>Browse Table of Contents</em></a></li> -->
              <li><a href="#tab3"><em>Full Text Search</em></a></li>
          </ul>            
           <!-- tab body -->
           <div class="yui-content">
               {titlesearch:get-tab()}
               {capsearch:get-tab()}
               <!-- <div><p>TO DO</p></div> -->
               {adsearch:get-tab()}               
           </div>
        </div>
        <div id="label-search-results"></div>
        {titlesearch:get-viewer-panel()}
        {capsearch:get-viewer-panel()}
        {adsearch:get-viewer-panel()}
     <!-- EndRenderedBy(lexpage:get-page-content()) -->
    </div>
    };   


(:
Displays the page 
:)
declare function lexpage:display-page($pageinfo as element()) as element() {
 <html xmlns="http://www.w3.org/1999/xhtml">
    {lexpage:get-head($pageinfo)}
    <body class="yui-skin-sam">
        {lexpage:get-page-header($pageinfo)}
        {lexpage:get-page-content()}
        {lexpage:get-page-js()}
        {lexpage:get-dom-ready()}
      </body>
    </html>
};

(:
Custom JS in <head />
:)
declare function lexpage:get-custom-js() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
       <script type="text/javascript">
       /** BeginRenderedBy(lexcustom:get-custom-js()) **/
         /** render tab **/
        YAHOO.kenyalex.bungeni.Tabs = new YAHOO.widget.TabView("tabcontent");
 
        function escapeQuery(query) {{
        	return encodeURIComponent(query);
        }}
        
        
        /** put all the onload init stuff here **/
        function init() {{
        }}
        /** Event listeners **/
        YAHOO.util.Event.addListener(window, "load", init);
        /** EndRenderedBy(lexcustom:get-custom-js()) **/
       </script>
 };


(:
Custom JS in the body of this page
:)
declare function lexpage:get-page-js() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
 <script type="text/javascript">
          function tsModulesHide() {{
                YAHOO.kenyalex.bungeni.actbuttonpanel.hide();
                YAHOO.kenyalex.bungeni.titlesearchresults.hide();
                YAHOO.kenyalex.bungeni.actviewer.hide();
          }}
          
          function tsModulesShow() {{
                YAHOO.kenyalex.bungeni.actbuttonpanel.show();
                YAHOO.kenyalex.bungeni.titlesearchresults.show();
                YAHOO.kenyalex.bungeni.actviewer.show();
          }}
          
          function tsModulesPreview(){{
                YAHOO.kenyalex.bungeni.actbuttonpanel.show();
                YAHOO.kenyalex.bungeni.titlesearchresults.show();
                YAHOO.kenyalex.bungeni.actviewer.hide();
           }}
          
          function csModulesHide() {{
                YAHOO.kenyalex.bungeni.capnosearchresults.hide(); 
                YAHOO.kenyalex.bungeni.csactbuttonpanel.hide(); 
                YAHOO.kenyalex.bungeni.csactviewer.hide();           
          }}
          
          function csModulesPreview() {{
                YAHOO.kenyalex.bungeni.capnosearchresults.show(); 
                YAHOO.kenyalex.bungeni.csactbuttonpanel.show(); 
                YAHOO.kenyalex.bungeni.csactviewer.hide();           
          }}
 
 
          function csModulesShow() {{
                YAHOO.kenyalex.bungeni.capnosearchresults.show(); 
                YAHOO.kenyalex.bungeni.csactbuttonpanel.show(); 
                YAHOO.kenyalex.bungeni.csactviewer.show();                         
          }}
          
          function adModulesShow() {{
                 YAHOO.kenyalex.bungeni.adsearchresults.show();
          }}
          
          function adModulesHide() {{
                 YAHOO.kenyalex.bungeni.adsearchresults.hide();
          }}
          
          
            
          YAHOO.kenyalex.bungeni.Tabs.on('activeTabChange', 
                function(ev) {{
                    var TABS = YAHOO.kenyalex.bungeni.Tabs;
                    var oldTab = ev.prevValue;
                    var newTab = ev.newValue;
                    /** title search tab **/
                    var tabTS = TABS.getTab(0);
                    /** cap search tab **/
                    var tabCS = TABS.getTab(1);
                    /** adv search tab **/
                    var tabAS = TABS.getTab(2);
                    
                    if (oldTab === tabTS) {{
                        tsModulesHide();
                    }}
                    if (newTab === tabTS) {{
                       var currentCapId = new String(YAHOO.util.Dom.get("ititlesearchactid").value);
                       if (currentCapId.length == 0 ) {{
                          tsModulesHide();                       
                       }} else {{
                          tsModulesPreview();
                       }}
                    }}
                    if (oldTab === tabCS ) {{
                         csModulesHide();
                    }}
                    if (newTab === tabCS) {{
                        var currentCapId  = new String(YAHOO.util.Dom.get("icapsearchactid").value);
                        if (currentCapId.length == 0 )  {{
                            //there is no act to show - hide the viewer
                            csModulesHide();
                        }} else {{
                            csModulesPreview();
                        }}
           
                    }}
                    
                    if (oldTab == tabAS) {{
                        adModulesHide();
                    }}
                    if (newTab == tabAS) {{
                        adModulesShow();
                    }}
                   
                }});
 </script>
 };
 
 
 (:
 The YUI onDOMReady event is rendered by this function 
 :)
 declare function lexpage:get-dom-ready() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
      <script type="text/javascript">
        /** BeginRenderedBy(lexcustom:get-dom-ready()) **/
       YAHOO.util.Event.onDOMReady(function () {{
         /** initialize tab #1 **/
         YAHOO.util.Dom.removeClass("ts-actviewer", "yui-pe-content");
         YAHOO.util.Dom.removeClass("ts-actbuttonpanel", "yui-pe-content");
         YAHOO.util.Dom.removeClass("title-search-results", "yui-pe-content");
        
         YAHOO.kenyalex.bungeni.titlesearchresults = new YAHOO.widget.Module("title-search-results", {{visible: false}});
         YAHOO.kenyalex.bungeni.actbuttonpanel = new YAHOO.widget.Module("ts-actbuttonpanel", {{ visible: false }});
         YAHOO.kenyalex.bungeni.actviewer = new YAHOO.widget.Module("ts-actviewer", {{ visible: false }});
        
       
         YAHOO.kenyalex.bungeni.titlesearchresults.render();
         YAHOO.kenyalex.bungeni.actbuttonpanel.render();
         YAHOO.kenyalex.bungeni.actviewer.render();
         /** event listeners are defined in titlesearch.xqm **/
         YAHOO.util.Event.addListener("ts-showhtml", "click", searchForAct, YAHOO.kenyalex.bungeni.actviewer, true);
         YAHOO.util.Event.addListener("ts-hidehtml", "click", hideSearchForAct, YAHOO.kenyalex.bungeni.actviewer, true);
         YAHOO.util.Event.addListener("ts-openwin", "click", tsOpenWin, YAHOO.kenyalex.bungeni.actviewer, true);
          

         /** initialize tab #2 **/
         YAHOO.util.Dom.removeClass("cs-actviewer", "yui-pe-content");
         YAHOO.util.Dom.removeClass("cs-actbuttonpanel", "yui-pe-content");
        YAHOO.util.Dom.removeClass("capno-search-results", "yui-pe-content");
         YAHOO.kenyalex.bungeni.capnosearchresults = new YAHOO.widget.Module("capno-search-results", {{visible: false}});
         YAHOO.kenyalex.bungeni.csactbuttonpanel = new YAHOO.widget.Module("cs-actbuttonpanel", {{ visible: false }});
         YAHOO.kenyalex.bungeni.csactviewer = new YAHOO.widget.Module("cs-actviewer", {{ visible: false }});
        
         YAHOO.kenyalex.bungeni.csactviewer.render();
         YAHOO.kenyalex.bungeni.capnosearchresults.render();
         YAHOO.kenyalex.bungeni.csactbuttonpanel.render();
         /** event listeners are defined in capsearch.xqm **/
         YAHOO.util.Event.addListener("cs-showhtml", "click", searchForCap, YAHOO.kenyalex.bungeni.csactviewer, true);
         YAHOO.util.Event.addListener("cs-hidehtml", "click", hideSearchForCap, YAHOO.kenyalex.bungeni.csactviewer, true);
         YAHOO.util.Event.addListener("cs-openwin", "click", csOpenWin, YAHOO.kenyalex.bungeni.csactviewer, true);
         
         /** initialize advanced search tab **/
         YAHOO.util.Event.addListener("ads-search-bn", "click", adsSearch, null, false);
          YAHOO.util.Dom.removeClass("ad-search-results", "yui-pe-content");
          YAHOO.util.Dom.removeClass("ad-search-summary", "yui-pe-content");
          
         YAHOO.kenyalex.bungeni.adsearchresults = new YAHOO.widget.Module("ad-search-results", {{visible:false}} );
         YAHOO.kenyalex.bungeni.adsearchsummary = new YAHOO.widget.Module("ad-search-summary", {{visible:false}} );
         
         YAHOO.kenyalex.bungeni.adsearchresults.render();
         YAHOO.kenyalex.bungeni.adsearchsummary.render();
         
        
        /** EndRenderedBy(lexcustom:get-dom-ready()) **/
      }});
      </script>
 };
 