xquery version "1.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";

(:~
config module - this may need to be customized per module
:)
import module namespace config = "http://bungeni.org/xquery/config" at "config.xqm";
(:~
app controller module - switch between applications by switching  appcontroller modules 
:)
import module namespace appcontroller = "http://bungeni.org/xquery/appcontroller" at "lexapp/appcontroller.xqm";

(: xhtml 1.1 :)
(:
declare option exist:serialize "media-type=text/html method=xhtml doctype-public=-//W3C//DTD&#160;XHTML&#160;1.1//EN doctype-system=http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd";
:)
declare option exist:serialize "media-type=text/html method=xhtml";

(:~
The below are explained here :

http://www.exist-db.org/urlrewrite.html#d1830e343

:)
declare variable $exist:path external;
declare variable $exist:root external;
declare variable $exist:controller external;

(: The REL-PATH variable :)
declare variable $REL-PATH := fn:concat($exist:root, '/', $exist:controller);


 
let $ret := appcontroller:controller(
                $exist:path, 
                $exist:root, 
                $exist:controller, 
                $exist:resource, 
                $REL-PATH
            ) return $ret
    
    

