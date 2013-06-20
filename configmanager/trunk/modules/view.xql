(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace app="http://exist-db.org/apps/configmanager/templates" at "app.xql";
import module namespace type="http://exist.bungeni.org/types" at "type.xql";
import module namespace sysmanager="http://exist.bungeni.org/systemfunctions" at "system.xql";
import module namespace form="http://exist.bungeni.org/formfunctions" at "form.xql";
import module namespace workflow="http://exist.bungeni.org/workflowfunctions" at "workflow.xql";
import module namespace notif="http://exist.bungeni.org/notificationfunctions" at "notification.xql";
import module namespace vocab="http://exist.bungeni.org/vocalularies" at "vocabularies.xql";
import module namespace role="http://exist.bungeni.org/rolefunctions" at "role.xql";

declare option exist:serialize "method=html5 media-type=text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT := $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR := true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    templates:apply($content, $lookup, (), $config),
    (: !+NOTE (ao, 5th Feb 2013) added this to show updated pages on the HTML views :)
    response:set-header( "Cache-Control", 'no-cache, no-store, max-age=0, must-revalidate' ),
    response:set-header( "Expires", "0" )