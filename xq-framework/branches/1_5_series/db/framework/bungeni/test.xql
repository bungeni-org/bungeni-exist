xquery version "1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "../common.xqm";
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni.xqm";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare option exist:serialize "method=xhtml media-type=text/html indent=no";

declare function local:get-body() {
    let $doc := collection('/db/bungeni-xml')//bu:ontology/bu:legislativeItem[@uri='/ke/bill/468:39-bill/en']/ancestor::bu:ontology/bu:legislativeItem/bu:body/*,
        $wave1 := fn:replace(fn:replace($doc,'&gt;','dfdf'),'<','&lt;')
    
    return
        <clean>
        {
           
           fn:replace(fn:replace(util:serialize($doc,"method=xhtml"),'>','&gt;'),'<','&lt;')
        }
        </clean>
};


let $coll_rs := bun:xqy-list-documentitems-with-acl("public-view", "question"),
    $coll := bun:ft-search($coll_rs,"text","question")
return 
    (:<batch>
    {
        $coll
    }
    </batch>:)
    local:get-body()
