module namespace style='http://code.google.com/p/xrx/style';
declare namespace request="http://exist-db.org/xquery/request";

(: style.xqm: A context-aware style module 
The purpose of this module is to allow any XRX application to use
the context of the collection to conditionall import a set of server-side
functions that provide web-page styling.

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Style Test</title>
        {style:import-css()}
    </head>
    <body>
        {style:header()}
        {style:breadcrumb()}
        <h1>Style Test</h1>
        {style:footer()}
    </body>
</html>
    
:)

(: returns host and port we are running on :)
declare function style:server-port() as xs:string {
  substring-before(request:get-url(), '/exist/rest/db/')
};

(: returns the base of the xrx application such as /db/org-name/apps :)
declare function style:apps-base-collection() {
(:  substring-before(request:get-url(), '/modules/style-template.xq') :)
    let $host-port := substring-before(request:get-url(), '/exist/rest/db/')
    return concat($host-port,  '/exist/rest/db/xrx/apps')
};

(: returns the base of the web server /exist/rest :)
declare function style:web-base() {
    let $host-port := substring-before(request:get-url(), '/exist/rest/db/')
    return concat($host-port,  '/exist/rest/db/xrx')
};

declare function style:xrx-home-collection() {
    '/exist/rest/db/xrx'
};

(: returns the base of the xrx application such as /db/xrx :)
declare function style:base-uri() {
    '/db/xrx'
};

(: returns the application URI such as http://localhost:8080/exist/rest/db/xrx/apps/faq if you are anywhere inside that
collection :)
declare function style:url-base() as xs:string {
(:  substring-before(request:get-url(), '/modules/style-template.xq') :)
   let $prefix := substring-before(request:get-url(), '/apps/')
   let $suffix := substring-after(request:get-url(), '/apps/')
   let $base1 := substring-before($suffix, '/')
   return concat($prefix, '/apps/', $base1)
};


(: returns the application URI such as http://localhost:8080/exist/rest/db/xrx/apps/faq if you are anywhere inside that
collection :)
declare function style:app-base-url() as xs:string {
   let $prefix := substring-before(request:get-url(), '/apps/')
   let $full-suffix := substring-after(request:get-url(), '/apps/')
   let $app := substring-before($full-suffix, '/')
   return concat($prefix, '/apps/', $app)
};


(: returns the application base collection such as /db/xrx/apps/faq if you are anywhere inside that
collection :)
declare function style:app-base-uri() as xs:string {
   let $db-start := substring-after(request:get-uri(), '/exist/rest')
   let $pre-app := substring-before($db-start, '/apps/')
   let $full-suffix := substring-after($db-start, '/apps/')
   let $app := substring-before($full-suffix, '/')
   return concat($pre-app, '/apps/', $app)
};

(: returns the application base collection such as /db/xrx/apps/faq if you are anywhere inside that
collection :)
declare function style:app-data-uri() as xs:string {
   concat(style:app-base-uri(), '/data')
};

declare function style:import-css() {
   <link type="text/css" rel="stylesheet" href="{concat(style:xrx-home-collection(), '/resources/css/style.css')}"/>
   ,
   <link rel="shortcut icon" href="{concat(style:xrx-home-collection(), '/resources/images/favicon.ico')}" type="image/x-icon" />
};


(: given a URL this function looks up an application name which is the collaction after '/apps/' :)
declare function style:lookup-app-id($input-uri as xs:string) as xs:string {
   let $app-to-end := substring-after($input-uri, '/apps/')
   return substring-before($app-to-end, '/')
};

(: given a URL this function looks up the label from the app-info.xml file and if does not
   exist it just returns the app-id :)
declare function style:lookup-app-label($input-uri as xs:string) as xs:string {
let $app-id := style:lookup-app-id($input-uri)
let $app-labels := doc('/db/xrx/shared-data/app-info.xml')/app-info
let $app-label := $app-labels/app[app-id=$app-id]/app-breadcrumb-label/text()
   return
      string(if ($app-label)
         then ($app-label)
         else ($app-id))
};

(: create a breadcrumb div based on the current application URI :)
declare function style:breadcrumb() {
<span class="breadcrumb">
   <a href="{concat(style:xrx-home-collection(), '/index.xq')}">XRX Home</a>
</span>
};

declare function style:header-hr() {
<div class="footer">
   <img src='{
   concat(style:xrx-home-collection(), '/resources/images/xrx-logo.jpg')
   }' alt-text='XRX Logo' />
   <hr color="#003366"/>
   <hr color="#CC0033"/>
</div>
};

declare function style:header() {
<div class="header2">
   <img src='{
   concat(style:xrx-home-collection(), '/resources/images/xrx-logo.jpg')
   }' alt-text='XRX Logo' height="40px"/>
   <div class="horiz-bar-orange"/>
   <div class="horiz-bar-blue"/>
</div>
};

declare function style:footer() {
<div class="footer">
   <div class="horiz-bar-orange"/>
   <div class="horiz-bar-blue"/>
   <p class="footer-text">XRX Test Stylesheet</p>
</div>
};


