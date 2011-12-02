xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace json="http://www.json.org";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "common.xqm";


(: return pure xhtml :)
declare option exist:serialize "method=get media-type=text/html";


let $actinfo := <div style="margin:20px;">
                {
                let $qs := lower-case(xs:string(request:get-parameter("query","")))
                let $qswc := concat($qs,"*")
                for $match in collection(lexcommon:get-lex-db())//docTitle[@id='ActTitle']
                return 
                    <div>
                     {$match}
                     {$match/following-sibling::docNumber[@id='ActIdentifier']}
                    </div>
                }
             </div>
             
return 
	$actinfo
