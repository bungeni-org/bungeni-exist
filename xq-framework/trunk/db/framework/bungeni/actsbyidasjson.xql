xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace json="http://www.json.org";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "common.xqm";


(: We dont need to call xml-to-json anymore - just setting the serialization type returns json :)
declare option exist:serialize "method=json media-type=text/javascript";

(: Act Identifier 83 JSON seems to be broken :)


let $actinfo := <match>
                {
                let $qs := lower-case(xs:string(request:get-parameter("query","")))
                let $qswc := concat($qs,"*")
                for $match in collection(lexcommon:get-lex-db())//docTitle[@id='ActTitle'][ft:query(.,$qswc)]
                return 
                    <doc>
                     {$match}
                     {$match/following-sibling::docNumber[@id='ActIdentifier']}
                    </doc>
                }
             </match>
             
return 
	$actinfo
