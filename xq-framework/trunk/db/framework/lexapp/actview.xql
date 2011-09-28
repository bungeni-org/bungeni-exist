xquery version "1.0";

declare namespace transform="http://exist-db.org/xquery/transform";
import module namespace lex = "http://exist.bungeni.org/lex" at "lex.xqm";
import module namespace lexcommon = "http://exist.bungeni.org/lex" at "common.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare option exist:serialize "method=xml media-type=text/xml";

let $actid := xs:string(request:get-parameter("actid",""))
let $prefid := xs:string(request:get-parameter("pref",""))
let $xslt := lexcommon:get-xslt("actfull.xsl")
let $doc := lex:get-doc($actid)

return
   actview:display-page($doc, $actid, $actnum, $title, $xslt, $prefid)