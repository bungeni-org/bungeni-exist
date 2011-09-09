xquery version "1.0";

import module namespace actviewhilite="http://exist.bungeni.org/actviewhilite" at "modules/actviewhilite.xqm";
import module namespace lex = "http://exist.bungeni.org/lex" at "modules/lex.xqm";
import module namespace lexcommon = "http://exist.bungeni.org/lexcommon" at "modules/common.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace request="http://exist-db.org/xquery/request";

(: import module namespace json="http://www.json.org"; :)

declare option exist:serialize "method=xml media-type=application/xml";

(: THis page and its module need to be rewritten in the lines of lexpage.xqm and index.xql :)

(: get request parameters :)
let $actid := xs:string(request:get-parameter("actid",""))
let $searchfor := xs:string(request:get-parameter("searchfor", ""))
let $searchin := xs:string(request:get-parameter("searchin", ""))

(: set the xslt template :)
let $xslt := xs:string("../xslt/actfullhilite.xsl")

(: Run the FT query on the specified act :)
let $doc :=  for $hit in collection(lexcommon:get-lex-db())//akomaNtoso[ft:query(.,$searchfor)]//docNumber[@id='ActIdentifier'][text() = $actid]
               let $expanded := kwic:expand($hit/ancestor::akomaNtoso)
               return $expanded
            
(: Extract the title from the result :)   
let $title := xs:string($doc//docTitle[@id='ActTitle']/string())
(: Extract the act number from the result :)
let $actnum := xs:string($doc//docNumber[@id='ActNumber']/text())

(: Build an element stack to concat the required info :)
let $page_info := <page>
                     <title>{$title}</title>
                     <heading>{$title}</heading>
                     <prefix>ts</prefix>
                     <searchfor>{$searchfor}</searchfor>
                     <actid>{$actid}</actid>
                     <actno>{$actnum}</actno>
                     <xslt>{$xslt}</xslt>
                   </page>

(: Pass the element stack to the page displayer :)
return  
     actviewhilite:display-page($doc, $page_info)
     