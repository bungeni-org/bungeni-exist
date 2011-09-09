xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
import module namespace json="http://www.json.org";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "modules/common.xqm";

declare option exist:serialize "method=text media-type=application/json";

let $actinfo := <match>
               {
               for $match in collection(lexcommon:get-lex-db())/akomaNtoso//*[@id='ActIdentifier'  or @id='ActNumber'] 
               group $match as $partition by <name>{util:document-name($match)}</name> as $key1 
                       return 
                          <doc>
                          {$key1, $partition}
                          </doc>
                }
             </match>
let $lexjson := json:xml-to-json($actinfo)
return
    $lexjson