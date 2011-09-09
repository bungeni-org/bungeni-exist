module namespace yui = "http://exist.bungeni.org/yui";
declare namespace util="http://exist-db.org/xquery/util";


(:-
: YUI Includes 
: Most of these includes are returend wrapped in <container /> elements as the element() type 
: needs to return a well formed element
: 
:)

(:
Get the css files 
:)
declare function yui:get-skins() as element(){
    <container>
    <!-- BeginRenderedBy(yui:get-skins()) -->
    <link rel="stylesheet" type="text/css" href="yui/skins/sam/skin.css"/>
    <link type="text/css" rel="stylesheet" href="yui/autocomplete/assets/skins/sam/autocomplete.css" />
    <link type="text/css" rel="stylesheet" href="yui/tabview/assets/skins/sam/tabview.css" />
    <link type="text/css" rel="stylesheet" href="yui/container/assets/skins/sam/container.css" />
    <link type="text/css" rel="stylesheet" href="yui/treeview/assets/skins/sam/treeview.css" />
    <link type="text/css" rel="stylesheet" href="yui/calendar/assets/skins/sam/calendar.css" />
    <!-- EndRenderedBy(yui:get-skins()) -->
    </container>
};


(:
get the generic js files 
:)
declare function yui:get-generic-js() as element(){
    <container>
    <!-- BeginRenderedBy(yui:get-generic-js()) -->
    <!-- Dependencies -->
    <script src="yui/yahoo-dom-event/yahoo-dom-event.js" />
    <script src="yui/element/element-min.js" />
    <script src="yui/datasource/datasource-min.js" />
    <!-- OPTIONAL: Get (required only if using ScriptNodeDataSource) -->
    <script src="yui/get/get-min.js" />
    <!-- OPTIONAL: Connection (required only if using XHRDataSource) -->
    <script src="yui/connection/connection-min.js" />
     <!-- OPTIONAL: Animation (required only if enabling animation) -->
     <script src="yui/animation/animation-min.js" />
     <script src="yui/calendar/calendar-min.js" />
     <!-- OPTIONAL: JSON (enables JSON validation) -->
     <script src="yui/json/json-min.js" />    
     <script src="yui/treeview/treeview-min.js" />    
    <!-- EndRenderedBy(yui:get-generic-js()) -->
   </container>
};


(:
get the widget specific js
:)
declare function yui:get-widget-js() as element() {
    <container>
    <!-- BeginRenderedBy(yui:get-widget-js()) -->
      <script src="yui/autocomplete/autocomplete-min.js" />
      <script src="yui/tabview/tabview-min.js" />
      <script src="yui/container/container-min.js" />           
    <!-- EndRenderedBy(yui:get-widget-js()) -->
    </container>
};

(:
get all includes
:)
declare function yui:get-includes() as element() {
    <container>
    <!-- BeginRenderedBy(yui:get-includes()) -->
    <!--CSS file (default YUI Sam Skin) -->
      {yui:get-skins()/child::*}
      {yui:get-generic-js()/child::*}
      <!-- Source file -->
      {yui:get-widget-js()/child::*}
    <!-- EndRenderedBy(yui:get-includes()) -->
   </container>
};

