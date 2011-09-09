module namespace capsearch = "http://exist.bungeni.org/lexpage/capsearch";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "common.xqm";

(:
This page renders the title search tab
:)

declare function capsearch:get-cap-search() as element(){
   util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
   <div id="cap-search"> 
   <!-- BeginRenderedBy(capsearch:get-cap-search()) -->
   <label for="icapsearch" id="for-icapsearch">Search by Cap Number, e.g. 4A</label>
   <input id="icapsearch" type="text" />
   <input id="icapsearchactid" type="hidden" />
   <div id="cap-search-container"> </div>
   <!-- EndRenderedBy(capsearch:get-cap-search()) -->
   </div>
};

declare function capsearch:get-cap-search-scripts() as element(){
 <script type="text/javascript">
    /** BeginRenderedBy(capsearch:get-cap-search-scripts()) ****/   
    YAHOO.kenyalex.bungeni.CapDS = new YAHOO.util.XHRDataSource('{lexcommon:get-actsbycapno-jsonds()}');
    YAHOO.kenyalex.bungeni.CapDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
    YAHOO.kenyalex.bungeni.CapDS.responseSchema = {{
        resultsList : "doc",
        fields: [
            {{key: "['docNumber'][0]['#text']" }},
            {{key: "['docNumber'][1]['#text']"}}
        ]
    }};
   YAHOO.kenyalex.bungeni.CapAC = new YAHOO.widget.AutoComplete("icapsearch","cap-search-container", YAHOO.kenyalex.bungeni.CapDS);
   YAHOO.kenyalex.bungeni.CapAC.allowBrowserAutocomplete = false;  
   YAHOO.kenyalex.bungeni.CapAC.forceSelection = true; 
   YAHOO.kenyalex.bungeni.CapAC.typeAhead = true;
   YAHOO.kenyalex.bungeni.CapAC.autoHighlight=true;
   YAHOO.kenyalex.bungeni.CapAC.applyLocalFilter = true;
   
   YAHOO.kenyalex.bungeni.CapAC.itemSelectEvent.subscribe(function(sType, sArgs) {{
        var capsearch = sArgs[2];
        var actTitle = capsearch[0]; 
        var actId = capsearch[1];
        YAHOO.util.Dom.get("icapsearchactid").value = actId;
        /** we have to make a request to retrive the act based on these parameters  **/
        /** use the eXist MVC rewrite proxy **/
        searchByCap(actId);
   }});
   
    function searchByCap(actId) {{
          var params = 'actid=' + escapeQuery(actId);
        var callback = {{
            success: searchByCapResponse,
            failure: requestFailed
        }};
        YAHOO.util.Connect.asyncRequest('POST', 'searchbycap', callback, params);
      }}

    
    function searchByCapResponse(request) {{
        var xml = request.responseXML;
        if (!xml) {{
            return;
        }}
        var txt = request.responseText;
        //show and hide the required module objects -- these are initialized in onDomReady -- see custom.xqm
        //show the preview
        YAHOO.kenyalex.bungeni.capnosearchresults.setBody(txt);
        YAHOO.kenyalex.bungeni.capnosearchresults.show();
        //hide the act viewer
        YAHOO.kenyalex.bungeni.csactviewer.hide();
        //show the button panel
        YAHOO.kenyalex.bungeni.csactbuttonpanel.show()
    }}
 
 /** EndRenderedBy(capsearch:get-title-search-scripts()) ****/      
</script>
};


declare function capsearch:get-viewer-panel() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
 <div id="cs-viewer-panel">
 <!-- BeginRenderedBy(capsearch:get-viewer-panel()) -->
             <script type="text/javascript">
                 function hideSearchForCap(){{
                      YAHOO.kenyalex.bungeni.csactviewer.hide();
                 }}
                 
                 function csOpenWin(){{
                     var actid  = new String(YAHOO.util.Dom.get("icapsearchactid").value);
                     var params = getLexQueryString({{'actid':actid, 'pref':'cs'}});
                     window.open('actview.xql?'+params, 'actwindow');
                 }}
                
                 function searchForCap() {{
                   //hide the act viewer
                   YAHOO.kenyalex.bungeni.csactviewer.hide();
                   var params = getLexQueryString({{'actid' : escapeQuery(YAHOO.util.Dom.get("icapsearchactid").value), 'pref' : 'cs'}});
                   var callback = {{
                        success: searchForCapResponse,
                        failure: requestFailed
                      }};
                    YAHOO.util.Connect.asyncRequest('POST', 'viewacttoc', callback, params);
                 }}
                
                function searchForCapResponse(request) {{
                    var xml = request.responseXML;
                    if (!xml) {{
                        alert('Failed to retrieve Act');
                        return;
                    }}
                    var txt = request.responseText;
                    YAHOO.kenyalex.bungeni.capnosearchresults.hide();
                    YAHOO.kenyalex.bungeni.csactviewer.setBody(txt);
                    YAHOO.kenyalex.bungeni.csactviewer.show();
                }}
                
                 function show_html(){{
                    /** make an async transfrom request on the xml document **/
                    YAHOO.kenyalex.bungeni.csactviewer.setBody("<strong>hello</strong>");
                    YAHOO.kenyalex.bungeni.csactviewer.show();
                 }}
                 
              </script>
             <div id="capno-search-results" class="yui-pe-content">
                <div class="bd"><!-- body for search results --></div>
               </div>
             <div id="cs-actbuttonpanel" class="yui-pe-content">
                <div class="bd">
                <button id="cs-showhtml">Expand</button> 
                <button id="cs-hidehtml">Collapse</button>
                 <button id="cs-openwin">Open in a new Window</button>
                </div>
            </div>
            
            <div id="cs-actviewer" class="yui-pe-content">
                <div class="hd"> --- Act --- </div>
                <div class="bd">This is a Module that was marked up in the document.</div>
                <div class="ft"> --- End Act --- </div>
            </div>
 <!-- EndRenderedBy(capsearch:get-viewer-panel()) -->
 </div>
};

declare function capsearch:get-tab() as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
    <div id="tab-cap-search">
    <!-- BeginRenderedBy(capsearch:get-tab()) -->
        {capsearch:get-cap-search()}
        {capsearch:get-cap-search-scripts()}
    <!-- EndRenderedBy(capsearch:get-tab()) -->
    </div>
};
