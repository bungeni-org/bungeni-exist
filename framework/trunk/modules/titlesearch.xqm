module namespace titlesearch = "http://exist.bungeni.org/lexpage/titlesearch";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "common.xqm";

(:
This page renders the title search tab
:)

declare function titlesearch:get-title-search() as element(){
   util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
   <div id="title-search"> 
   <!-- BeginRenderedBy(titlesearch:get-title-search()) -->
   <label for="ititlesearch" id="for-ititlesearch" >Search by Act Title</label>
   <input id="ititlesearch" type="text" />
   <input id="ititlesearchactid" type="hidden" />
   <div id="title-search-container"> </div>
   <!-- EndRenderedBy(titlesearch:get-title-search()) -->
   </div>
};

declare function titlesearch:get-title-search-scripts() as element(){
 <script type="text/javascript">
    /** BeginRenderedBy(titlesearch:get-title-search-scripts()) ****/   

    YAHOO.kenyalex.bungeni.TitlesDS = new YAHOO.util.XHRDataSource('{lexcommon:get-acts-jsonds()}');
    YAHOO.kenyalex.bungeni.TitlesDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
    YAHOO.kenyalex.bungeni.TitlesDS.responseSchema = {{
        resultsList : "doc",
        fields: [
            {{key: "['docTitle']['#text']"}},
            {{key: "['docNumber']['#text']"}}
        ]
    }};
   YAHOO.kenyalex.bungeni.TitlesAC = new YAHOO.widget.AutoComplete("ititlesearch","title-search-container", YAHOO.kenyalex.bungeni.TitlesDS);
   YAHOO.kenyalex.bungeni.TitlesAC.allowBrowserAutocomplete = false;  
   YAHOO.kenyalex.bungeni.TitlesAC.forceSelection = true; 
   YAHOO.kenyalex.bungeni.TitlesAC.typeAhead = true;
   YAHOO.kenyalex.bungeni.TitlesAC.autoHighlight=true;
   YAHOO.kenyalex.bungeni.TitlesAC.applyLocalFilter = true;
   /** invoke autocomplete only after first 2 letters have been typed **/
   YAHOO.kenyalex.bungeni.TitlesAC.minQueryLength = 3;

   
   YAHOO.kenyalex.bungeni.TitlesAC.itemSelectEvent.subscribe(function(sType, sArgs) {{
        var titleSearch = sArgs[2];
        var actTitle = titleSearch[0]; 
        var actId = titleSearch[1];
        YAHOO.util.Dom.get("ititlesearchactid").value = actId;
        /** we have to make a request to retrive the act based on these parameters  **/
        /** use the eXist MVC rewrite proxy **/
        searchByTitle(actId);
   }});
   
    
   
    function searchByTitle(actId) {{
          var params = 'actid=' + escapeQuery(actId);
          //salert(params);
        var callback = {{
            success: searchByTitleResponse,
            failure: requestFailed
        }};
        YAHOO.util.Connect.asyncRequest('POST', 'searchbytitle', callback, params);
      }}

    function requestFailed(request) {{
        document.getElementById('title-search-results').innerHTML =
            "The request to the server failed.";
    }}
    
    
    function searchByTitleResponse(request) {{
        var xml = request.responseXML;
        if (!xml) {{
            return;
        }}
        var txt = request.responseText;
        //show and hide the required module objects -- these are initialized in onDomReady -- see custom.xqm
        //show the preview
        YAHOO.kenyalex.bungeni.titlesearchresults.setBody(txt);
        YAHOO.kenyalex.bungeni.titlesearchresults.show();
        //hide the act viewer
        YAHOO.kenyalex.bungeni.actviewer.hide();
        //show the button panel
        YAHOO.kenyalex.bungeni.actbuttonpanel.show()
    }}
 
 /** EndRenderedBy(titlesearch:get-title-search-scripts()) ****/      
</script>
};


declare function titlesearch:get-viewer-panel() as element() {
 util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
 <div id="ts-viewer-panel">
 <!-- BeginRenderedBy(titlesearch:get-viewer-panel()) -->
             <script type="text/javascript">
                /** THE YUI Modules used here are initialized in onDomReady, see custom.xqm **/
                 function hideSearchForAct(){{
                      YAHOO.kenyalex.bungeni.titlesearchresults.show();
                      YAHOO.kenyalex.bungeni.actviewer.hide();
                 }}
                 
                 function tsOpenWin(){{
                     var actid  = new String(YAHOO.util.Dom.get("ititlesearchactid").value);
                     var paramsArr = {{'actid' : actid , 'pref' : 'ts' }};
                     //getLexQueryString is defined in the file-js 
                     var params = getLexQueryString(paramsArr);
                     window.open('actview.xql?'+params, 'actwindow');
                 }}
                 
                 function searchForAct() {{
                   //hide the act preview
                   YAHOO.kenyalex.bungeni.actviewer.hide();
                   var paramsArr = {{'actid' : escapeQuery(YAHOO.util.Dom.get("ititlesearchactid").value) , 'pref' : 'ts' }};
                   var params = getLexQueryString(paramsArr);
                   var callback = {{
                        success: searchForActResponse,
                        failure: requestFailed
                      }};
                    YAHOO.util.Connect.asyncRequest('POST', 'viewacttoc', callback, params);
                 }}
                
                function searchForActResponse(request) {{
                    var xml = request.responseXML;
                    if (!xml) {{
                        alert('Failed to retrieve Act');
                        return;
                    }}
                    var txt = request.responseText;
                    //document.getElementById('capno-search-results').innerHTML = '';
                    //YAHOO.kenyalex.bungeni.titlesearchresults.hide();
                    YAHOO.kenyalex.bungeni.actviewer.setBody(txt);
                    YAHOO.kenyalex.bungeni.actviewer.show();
                }}
                
                 function show_html(){{
                    /** make an async transfrom request on the xml document **/
                    YAHOO.kenyalex.bungeni.actviewer.setBody("<strong>hello</strong>");
                    YAHOO.kenyalex.bungeni.actviewer.show();
                 }}
              </script>
               <div id="title-search-results">
                <div class="bd"><!-- body for search results --></div>
               </div>
             <div id="ts-actbuttonpanel" class="yui-pe-content">
                <div class="bd">
                <button id="ts-showhtml">Expand</button> 
                <button id="ts-hidehtml">Collapse</button>
                <button id="ts-openwin">Open in a new Window</button>
                </div>
            </div>
            
            <div id="ts-actviewer" class="yui-pe-content">
                <div class="hd"> --- Act --- </div>
                <div class="bd">This is a Module that was marked up in the document.</div>
                <div class="ft"> --- End Act --- </div>
            </div>
 <!-- EndRenderedBy(titlesearch:get-viewer-panel()) -->
 </div>
};

declare function titlesearch:get-tab() as element(){
  util:declare-option("exist:serialize", "media-type=text/html method=xhtml"),
    <div id="tab-title-search">
    <!-- BeginRenderedBy(titlesearch:get-tab()) -->
        {titlesearch:get-title-search()}
        {titlesearch:get-title-search-scripts()}
    <!-- EndRenderedBy(titlesearch:get-tab()) -->
    </div>
};
