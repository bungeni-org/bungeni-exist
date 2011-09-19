xquery version "1.0";

import module namespace actview="http://exist.bungeni.org/actview" at "actview.xqm";
import module namespace lex = "http://exist.bungeni.org/lex" at "lex.xqm";
import module namespace lexcommon = "http://exist.bungeni.org/lex" at "common.xqm";

declare namespace request="http://exist-db.org/xquery/request";
declare option exist:serialize "method=xhtml media-type=text/html";

let $actid := xs:string(request:get-parameter("actid",""))
let $prefid := xs:string(request:get-parameter("pref",""))
let $xslt := lexcommon:get-xslt("actfull.xsl")
let $doc := lex:get-doc($actid)
let $title := xs:string($doc//docTitle[@id='ActTitle']/text())
let $actnum := xs:string($doc//docNumber[@id='ActNumber']/text())

return
   actview:display-page($doc, $actid, $actnum, $title, $xslt, $prefid)