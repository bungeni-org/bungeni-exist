xquery version "1.0";

import module namespace actview="http://exist.bungeni.org/actview" at "modules/actview.xqm";
import module namespace lex = "http://exist.bungeni.org/lex" at "modules/lex.xqm";
declare namespace request="http://exist-db.org/xquery/request";

(: import module namespace json="http://www.json.org"; :)

declare option exist:serialize "method=xhtml media-type=text/html";

(: THis page and its module need to be rewritten in the lines of lexpage.xqm and index.xql :)

let $actid := xs:string(request:get-parameter("actid",""))
let $prefid := xs:string(request:get-parameter("pref",""))
let $xslt := xs:string("../xslt/actfull.xsl")
let $doc := lex:get-doc($actid)
let $title := xs:string($doc//docTitle[@id='ActTitle']/text())
let $actnum := xs:string($doc//docNumber[@id='ActNumber']/text())

return
   actview:display-page($doc, $actid, $actnum, $title, $xslt, $prefid)