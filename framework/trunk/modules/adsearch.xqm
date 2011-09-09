module namespace adsearch = "http://exist.bungeni.org/lexpage/adsearch";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "common.xqm";

(:
This page renders the advanced search tab
:)

(:
Renders the advanced search form
:)
declare function adsearch:get-ad-search() as element(){
   util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
   <div id="ads-search"> 
   <!-- BeginRenderedBy(adsearch:get-title-search()) -->
   <label for="ads-searchfor" id="lbl-ads-searchfor">Search for Text</label>
   <input type="text" id="ads-searchfor" />
   <button id="ads-search-bn" >Search</button>
   <span class="ads-desc">Search Within:</span>
   <input type="checkbox" id="ads-title" checked="checked" /><label for="ads-title">Act Title</label>
   <input type="checkbox" id="ads-desc" checked="checked" /><label for="ads-desc">Description</label>
    <!-- EndRenderedBy(adsearch:get-title-search()) -->
   </div>
};


(:
Renders the javascript required by the advanced search
:)
declare function adsearch:get-ad-search-scripts() as element(){
 <script type="text/javascript">
    function adsSearch() {{
        var ftquery = adsSearchBuild();
        var ftsearchIn = adsSearchIn();
        var searchString = escapeQuery(YAHOO.util.Dom.get("ads-searchfor").value) ;
        var paramsArr = {{ 
                            'searchfor' : searchString,
                            'searchin' : ftsearchIn.join(","), 
                            'q' : escapeQuery(ftquery)
                        }};
        var params = getLexQueryString(paramsArr);
        var callback = {{
                        success: adsSearchResponse,
                        failure: adsRequestFailed
                      }};
         YAHOO.kenyalex.bungeni.adsearchresults.setBody("<strong>Searching...</strong>");
         YAHOO.kenyalex.bungeni.adsearchresults.show();
         YAHOO.util.Connect.asyncRequest('POST', 'adsearch', callback, params);
    }}
    
    function adsRequestFailed(request) {{
        alert("The request to the server failed.");
    }}
    
     function adsSearchResponse(request) {{
                    var xml = request.responseXML;
                    if (!xml) {{
                        return;
                    }}
                  
                    var txt = request.responseText;
                    YAHOO.kenyalex.bungeni.adsearchresults.setBody(txt);
                    YAHOO.kenyalex.bungeni.adsearchresults.show();
                }}
                
      function filterYear(varYear) {{
        alert("To be implemented");
        /*
            var ftquery = adsSearchBuild();
            var ftsearchIn = adsSearchIn();
            var searchString = escapeQuery(YAHOO.util.Dom.get("ads-searchfor").value);
            var restrictyy = varYear.toString();
            var paramsArr = {{ 
                            'searchfor' : searchString,
                            'searchin' : ftsearchIn.join(","), 
                            'q' : escapeQuery(ftquery),
                            'restrictyy' : restrictyy,
                            'restrictmm' : ''
                        }};
            var params = getLexQueryString(paramsArr);
            alert(params);
            var callback = {{
                        success: adsSearchResponse,
                        failure: adsRequestFailed
                      }};
         YAHOO.kenyalex.bungeni.adsearchresults.setBody("<strong>Searching...</strong>");
         YAHOO.kenyalex.bungeni.adsearchresults.show();
         YAHOO.util.Connect.asyncRequest('POST', 'ftsearch', callback, params);
         */
            
      }}
      
      function filterMonth(varYear, varMonth) {{
            alert("To be implemented");
            /**
            var ftquery = adsSearchBuild();
            var ftsearchIn = adsSearchIn();
            var searchString = escapeQuery(YAHOO.util.Dom.get("ads-searchfor").value);
            var restrictyy = varYear.toString();
            var restrictmm = varMonth.toString();
            var paramsArr = {{ 
                            'searchfor' : searchString,
                            'searchin' : ftsearchIn.join(","), 
                            'q' : escapeQuery(ftquery),
                            'restrictyy' : restrictyy,
                            'restrictmm' : restrictmm
                        }};
            var params = getLexQueryString(paramsArr);
            alert(params);
            var callback = {{
                        success: adsSearchResponse,
                        failure: adsRequestFailed
                      }};
         YAHOO.kenyalex.bungeni.adsearchresults.setBody("<strong>Searching...</strong>");
         YAHOO.kenyalex.bungeni.adsearchresults.show();
         YAHOO.util.Connect.asyncRequest('POST', 'ftsearch', callback, params);
         **/
      }}
      
    /** BeginRenderedBy(adsearch:get-search-scripts()) ****/   
 /** EndRenderedBy(adsearch:get-search-scripts()) ****/      
</script>
};

(:
Renders the search results viewer
:)
declare function adsearch:get-viewer-panel() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
 <div id="ad-viewer-panel">
 <!-- BeginRenderedBy(adsearch:get-viewer-panel()) -->
             <script type="text/javascript">
                /** THE YUI Modules used here are initialized in onDomReady, see custom.xqm **/
                // -- page level scripts requird by advanced search --
              </script>
               <div id="ad-search-summary" class="yui-pe-content">
               <div class="bd"><!-- body for search summary --></div>
               </div>
               <div id="ad-search-results" class="yui-pe-content" >
                <div class="bd"><!-- body for search results --></div>
               </div>
 <!-- EndRenderedBy(adsearch:get-viewer-panel()) -->
 </div>
};


(:
Renders the advanced search tab
:)
declare function adsearch:get-tab() as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
    <div id="tab-ad-search">
    <!-- BeginRenderedBy(adsearch:get-tab()) -->
        {adsearch:get-ad-search()}
        {adsearch:get-ad-search-scripts()}
    <!-- EndRenderedBy(adsearch:get-tab()) -->
    </div>
};
