xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
import module namespace json="http://www.json.org";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace lexcommon="http://exist.bungeni.org/lexcommon" at "modules/common.xqm";

declare option exist:serialize "method=text media-type=application/json";
(: Act Identifier 83 JSON seems to be broken :)
let $actinfo := <match>
               {
               for $match in collection(lexcommon:get-lex-db())/akomaNtoso//*[@id='ActTitle'  or @id='ActIdentifier'] 
               group $match as $partition by <name>{util:document-name($match)}</name> as $key1 
                       return 
                          <doc>
                          {$key1, $partition}
                          </doc>
                }
             </match>
return $actinfo
