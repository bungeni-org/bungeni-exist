xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace json="http://www.json.org";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=json media-type=application/json";


let $actinfo := <match>
                {
                let $qs := lower-case(xs:string("Civil"))
                let $qswc := concat($qs,"*")
                for $match in collection('/db/kenyalex')//docTitle[@id='ActTitle'][ft:query(.,$qswc)]
                return 
                    <doc>
                     {$match}
                     {$match/following-sibling::docNumber[@id='ActIdentifier']}
                    </doc>
                }
             </match>
             
         
let $lexjson := json:xml-to-json($actinfo)
return
    $lexjson
