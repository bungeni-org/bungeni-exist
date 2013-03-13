module namespace cmn = "http://exist.bungeni.org/cmn";

declare namespace xh = "http://www.w3.org/1999/xhtml";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
import module namespace config = "http://bungeni.org/xquery/config" at "config.xqm";
import module namespace fw = "http://bungeni.org/xquery/fw" at "fw.xqm";
declare namespace i18n = "http://exist-db.org/xquery/i18n";
declare namespace bu="http://portal.bungeni.org/1.0/";


(:
Library for common functions used in the Application.

Some of the APIs here should eventually be factored int a framework level library 
rather than an Application level library

:)


(:~
Get the path to the bungeni collection
:)
declare function cmn:get-lex-db() as xs:string {
    $config:XML-COLLECTION
 };
 
 (:~
Get the path to the attachments collection
:)
declare function cmn:get-att-db() as xs:string {
    $config:ATT-COLLECTION
 };

(:~
Get the path to the vocabularies collection
:)
declare function cmn:get-vdex-db() as xs:string {
    $config:VDEX
 };

(:~
Get the UI configuraton document
:)
declare function cmn:get-ui-config() as document-node() {
  local:__get_app_doc__($config:UI-CONFIG)
  (: fn:doc(fn:concat($config:fw-app-root, $config:UI-CONFIG)) :)
};

(:~
Get the PARLIAMENT configuraton document
:)
declare function cmn:get-parl-config() as document-node()? {
    doc($config:PARLIAMENT-CONFIG)
};

(:~
Get the LANGUAGES configuraton document
:)
declare function cmn:get-langs-config() as document-node()? {
    doc($config:LANGUAGES-CONFIG)
};

(:~
Get a menu by name from the UI configuration document 
:)
declare function cmn:get-menu($menu-name as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/menugroups/menu[@name=$menu-name]        
      return $doc
}; 

(:~
Get a route configuration from the exist path.
The exist-path is passed from the appcontroller
:)
declare function cmn:get-route($exist-path as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/routes/route[@href eq $exist-path]      
       return $doc
};

(:~
Get a viewgroups configuration from the --------.
:)
declare function cmn:get-tabgroups($exist-path as xs:string) as node() {
    let $doc := cmn:get-ui-config()/ui/viewgroups/views[@name eq $exist-path]     
        return $doc
};

(:~
Get a viewgroups listing parameters from the --------.
:)
declare function cmn:get-view-listing-parts($doctype as xs:string, $default-view as xs:string) as node() {
    let $views := cmn:get-ui-config()/ui/viewgroups/views[@name eq $doctype]
    let $listing-view := $views/view[@id eq 'listing']
    let $current-path := data($listing-view/@path)
    let $default-path := data($views/view[@id eq $default-view]/@path)
        return  <listing>
                    <doctype>{$doctype}</doctype>
                    {$listing-view}
                    <current-view>{$current-path}</current-view>
                    <default-view>{$default-path}</default-view>
                </listing>
};

(:~
    Get a views path configuration as per given context.
:)
declare function cmn:get-views-for-type($type as xs:string) as node()* {
        cmn:get-ui-config()/ui/viewgroups/views[@name eq $type]
};

(:~
    Get a tabs/view path configuration as per context. Currently 
    returns a template and stylesheet for document transformations
:)
declare function cmn:get-view-parts($exist-path as xs:string) as node()* {
    let $rel-path := substring-after($exist-path,'/'),
        $doc := cmn:get-ui-config()/ui/viewgroups/views/view[@path eq $rel-path]
        return $doc
};

(:~
:   Get the user ui-config file
:)
(:
declare function cmn:user-preferences() as document-node() {
    
    $config:UI-USER-CONFIG
    
};
:)

(:~
Get the applicable menu for a route
:)
declare function cmn:get-menu-from-route($exist-path as xs:string) as node()? {
    let $doc := cmn:get-route($exist-path)
      return cmn:get-ui-config()//menu[@for eq $doc/navigation/text()]
};

(:~
Build navigation template nodes for a request path 
The mainnav is provided by default.
The subnavigation is rendered based on the incoming request path
The app-tmpl parameter is the final page template to be processed.
:)
declare function cmn:build-nav-tmpl($exist-path as xs:string, $app-tmpl as xs:string) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $tmpl := fw:app-tmpl($app-tmpl)
     let $out := ($main-nav, $sub-nav, $tmpl)      
     return $out
};

(:~
 Builds a content template nodes
 The mainnav is provided by default.
 The subnavigation is rendered based on the incoming request path
 The app-tmpl parameter is a node that has been rewritten as final page template to be processed.
:)
declare function cmn:rewrite-tmpl($exist-path as xs:string, $app-tmpl as node()+) as node()+ {
     let $main-nav := cmn:get-menu("mainnav")
     let $sub-nav := cmn:get-menu-from-route($exist-path)
     let $out := ($main-nav, $sub-nav, $app-tmpl)
     return $out
};

(:~
Build navigation template nodes for a request path 
The mainnav is provided by default.
The subnavigation is rendered based on the incoming request path
The node parameter is the "cooked" page as a node
:)
declare function cmn:build-nav-node($controller-data as node(), $node as node()) as node()+ {
    let $main-nav := cmn:get-menu("mainnav")
    let $val := util:log('debug',$main-nav)
    let $log := util:log('debug', "++++++++++++++++++++++++++++++++++")     
    let $sub-nav := cmn:get-menu-from-route($controller-data/exist-path/text())      
    let $crumb := <crumb>
                        <div id="portal-breadcrumbs" xmlns="http://www.w3.org/1999/xhtml">
                        <span id="breadcrumbs-you-are-here">You are here: </span>
                        {local:build-breadcrumbs($controller-data)}
                        </div>
                    </crumb>
     let $out := ($main-nav, $sub-nav,$crumb, $node ) 
     return $out
};

(:~ 
:   Builds the breadcrumbs
:)
declare function local:build-breadcrumbs($controller-data as node()?) {
    let $route := cmn:get-route($controller-data/exist-path/text())
    
    return
        	if ($route/navigation/text() eq 'home') then (
                <xh:a class="first" href="{$controller-data/parliament/type}/home"><i18n:text key="home">home</i18n:text></xh:a>
            	    
        	)    
        	else if ($route/navigation and not($route/subnavigation)) then (
                        <xh:a class="first" href="{$controller-data/parliament/type}/home">{$controller-data/parliament/type/text()}</xh:a>
                    ,  				
            	        <xh:a class="last" href="{$route/navigation}">{local:route-title($route/navigation)}</xh:a>
            	    
        	)
        	else (
            	        <xh:a class="first" href="{$controller-data/parliament/type}/home">{$controller-data/parliament/type/text()}</xh:a>
            	    ,    			  				
            	        <xh:a href=".{cmn:get-route($controller-data/exist-path)/navigation}">{local:route-title($route/navigation)}</xh:a>
            	    ,   				
            	        <xh:a class="last" href="{$controller-data/parliament/type}/{$controller-data/exist-res}">{local:route-title($controller-data/exist-path)}</xh:a>
            	    (:
            	       !+FIX_THIS (ao, 8th Aug 2012) adding tertiary menus(tabs) to breadcrumbs need to find out the doctype currently
            	       nowhere to access it as local:route-title() return route info e.g. 'questions' and we need 'question' since that 
            	       is what ui/doctypes/doctype is identified by.
            	    ,
            	    if (1 eq 1) then
            	           <xh:a class="last" href="{$route/subnavigation}?tab={data(cmn:get-listings-config('question')[@id eq 'uc']/@id)}">{data(cmn:get-listings-config('question')[@id eq 'uc']/@name)}</xh:a> 
            	    else
            	       ():)
            	          
           )
};

(:~ 
:   Get the config for maximum range retrievable
:)
declare function cmn:whatson-range-limit() {
    cmn:get-ui-config()//listings/max-range
};

(:~ 
:   Retrieves the corresponding title for the route from <menugroups/>
:)
declare function local:route-title($navroute as xs:string) {
    
    cmn:get-ui-config()//menugroups/menu//xh:a[@name eq $navroute]/i18n:text
    
};

declare function cmn:get-doctype-config($doctype as xs:string) {
   let $config := cmn:get-ui-config()
   let $dc-config := $config/ui/doctypes/doctype[lower-case(@name) eq lower-case($doctype)]
   return 
    if ($dc-config) then (
        $dc-config
      )
    else
        ()
};

(:
 : return <whatsonview/> nodes
 :)
declare function cmn:get-whatsonviews() {
    cmn:get-ui-config()/ui/custom/whatsonviews
};

(:
 : return <doctype/> nodes
 :)
declare function cmn:get-doctypes() {
   cmn:get-ui-config()/ui/doctypes/doctype
};

declare function cmn:get-orderby-config($doctype as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return
    if ($dc-config) then (
       $dc-config/orderbys/orderby
       )
    else
        ()
};

declare function cmn:get-orderby-config-name($doctype as xs:string, $orderby_name as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return
    if ($dc-config and ($orderby_name eq "none")) then (
        $dc-config/orderbys/orderby[@default eq "true"]
    )    
    else if ($dc-config and not(empty($orderby_name))) then (
       $dc-config/orderbys/orderby[@value eq $orderby_name]
       )
    else
        ()
};

declare function cmn:get-searchins-config($doctype as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return 
    if ($dc-config) then (
       $dc-config/searchins/searchin
       )
    else
        ()
};

declare function cmn:get-listings-config($doctype as xs:string)  {
    let $dc-config := cmn:get-doctype-config($doctype)
    return 
    if ($dc-config) then (
       $dc-config/listingfilters/listingfilter
       )
    else
        ()
};

declare function cmn:get-listings-config() {
    cmn:get-ui-config()/ui/listings
};

declare function cmn:get-listings-config-limit() as xs:string {
    data(cmn:get-listings-config()/limit)
};

declare function cmn:get-listings-config-limit() as xs:integer {
    xs:integer(data(cmn:get-listings-config()/limit))
};

declare function cmn:get-listings-config-visiblepages() as xs:integer {
    xs:integer(data(cmn:get-listings-config()/visiblePages))
};



(:~

Retrieve the permissinos for a filter name 'public-view', 'authenticated-view'
   <acl-groups>
        <acl name="public-view" condition="@name='zope.View' and @role='bungeni.Anonymous' and @setting='Allow'" />
        <acl name="authenticated-view" condition="@name='zope.View' and @role='bungeni.Authenticated' and @setting='Allow'" />
    </acl-groups>

:)

declare function cmn:get-acl-group($filter-name as xs:string) {
      let $acl-group := cmn:get-ui-config()/ui/acl-groups/acl[@name eq $filter-name]
      return 
        if ($acl-group) then (
            $acl-group
          )
        else
            ()
};

(:
declare function cmn:get-acl-filter($filter-name as xs:string) as xs:string {
    let $acl-group := cmn:get-acl-group($filter-name)
    return 
        if ($acl-group) then 
            (: Axis not used currently :)
            (: concat($acl-group/@axis, '[', $acl-group/@condition, ']') :)
            data($acl-group/@condition)
         else
            xs:string("")
};
:)


(:~

Retrieve the permissinos for a filter name 'public-view', 'authenticated-view'
   <acl-groups>
        <acl name="public-view"  />
        <acl name="authenticated-view" condition="@name='zope.View' and @role='bungeni.Authenticated' and @setting='Allow'" />
    </acl-groups>

:)

declare function cmn:get-acl-group($filter-name as xs:string) {
      let $acl-group := cmn:get-ui-config()/ui/acl-groups/acl[@name eq $filter-name]
      return 
        if ($acl-group) then (
            $acl-group
          )
        else
            ()
};

declare function cmn:get-acl-filter($filter-name as xs:string) as xs:string {
    let $acl-group := cmn:get-acl-group($filter-name)
    return 
        if ($acl-group) then 
            (: Axis not used currently :)
            (: concat($acl-group/@axis, '[', $acl-group/@condition, ']') :)
            data($acl-group/@condition)
         else
            xs:string("")
};


(:~
:Gets the permission nodes for a named acl
:)
declare function cmn:get-acl-permissions($filter-name as xs:string) as node()+{
    let $acl-group := cmn:get-acl-group($filter-name)
    return
        if ($acl-group) then
            $acl-group/bu:control
        else
            ()
};


(:~
:Gets the permission nodes for a named acl
:)
declare function cmn:get-acl-doctype-permissions($doctype as xs:string, $filter-name as xs:string) as node()+{
    let $acl-doctype := cmn:get-doctype-config($doctype)/acl[@name eq $filter-name]
    return
        if ($acl-doctype) then
            $acl-doctype/bu:control
        else
            ()
};

(:~
: Returns the permission node as a attributed string
:)
declare function cmn:get-acl-permission-attr($permission as node()) {
    fn:concat("@name='",$permission/@name, "' and ", "@role='", $permission/@role, "' and ", "@setting='",$permission/@setting, "'")             
};  


(:~
: Returns the input filters corresponding permission as a attribute condition string
:)
declare function cmn:get-acl-permission-as-attr($filter-name as xs:string) {
    let $acl-perm := cmn:get-acl-permissions($filter-name)
    return cmn:get-acl-permission-attr($acl-perm)
};

(:~
: Returns the input filters corresponding permission as a attribute condition string
: @param $doctype
: @param $filter-name
:)
declare function cmn:get-acl-permission-as-attr($doctype as xs:string, $filter-name as xs:string) {
    let $acl-perm := cmn:get-acl-doctype-permissions($doctype,$filter-name)
    return cmn:get-acl-permission-attr($acl-perm)
};

(:
    similar to cmn:get-acl-permission-as-attr() only that it returns a node
:)
declare function cmn:get-acl-permission-as-node($doctype as xs:string, $filter-name as xs:string) {
    let $acl-perm := cmn:get-acl-doctype-permissions($doctype,$filter-name)
    return $acl-perm
};

(:~
: Returns the input filters corresponding permission as a attribute condition string
: given the @role
:)
declare function cmn:get-acl-permission-as-attr-for-role($role-name as xs:string) {
    let $perm := cmn:get-acl-permissions("role-view")
    return 
        fn:concat("@name='",$perm/@name, "' and ", "@role='", $role-name, "' and ", "@setting='",$perm/@setting, "'")
};

(:~
: Returns the node permissions node condition string given the @role
:)
declare function cmn:get-acl-permission-as-node-for-role($role-name as xs:string) {
    let $perm := cmn:get-acl-permissions("role-view")
    return 
        element {name($perm)} {
             $perm/@name,
             attribute role {$role-name},             
             $perm/@setting
          }
};

(:~
Loads an XSLT file 
:)
declare function cmn:get-xslt($value as xs:string) as document-node()? {
    (: doc(fn:concat($config:fw-app-root, $value)) :)
    local:__get_app_doc__($value)
};

(:~
Generic api to load a document from the application folder
:)
declare function local:__get_app_doc__($value as xs:string) as document-node() {
    doc(fn:concat($config:fw-app-root, $value))
};


(:~
Parses request parameters and returns them as a XML structure
:)
declare function cmn:get-parameters($value as xs:string, $delimiter as xs:string) as node() {
         let $parsed-tokens := tokenize($value ,$delimiter)
         return 
         <tokens>
         {for $parsed-token in $parsed-tokens 
               where string-length($parsed-token) > 0
               return <token name="{$parsed-token}" />
               }
         </tokens>          
};

(:
Returns the server running the current scripts
:)
declare function cmn:get-server() as xs:string {
    let $url := concat("http://" , request:get-server-name(),":" ,request:get-server-port())
    return $url

};
