xquery version "3.0";

import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";
import module namespace template = "http://bungeni.org/xquery/template" at "template.xqm";
import module namespace bun = "http://exist.bungeni.org/bun" at "bungeni/bungeni.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace json="http://www.json.org";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace ex="http://exist-db.org/xquery/ex";
declare namespace bu="http://portal.bungeni.org/1.0/";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:
 : This XQuery script provides a REST API based on RESTXQ extension
 :
 : @author Anthony Oduor <aowino@googlemail.com>
 : 
 : http://localhost:8088/exist/restxq/ontology?type=Bill,Question,AgendaItem,Motion?offset=1&limit=5
 :
:)

declare
    %rest:GET
    %rest:path("/ontology")  
    %rest:query-param("type", "{$type}", "none")
    %rest:query-param("offset", "{$offset}", 1)
    %rest:query-param("limit", "{$limit}", 2)    
    %rest:query-param("search", "{$search}", "none")
    %rest:query-param("status", "{$status}", "first_reading_pending")
    %output:method("xml")
    
    function local:documents(
        $type as xs:string*, 
        $offset as xs:int,
        $limit as xs:int,
        $search as xs:string*,
        $status as xs:string) {
        <docs>
            <type>{$type}</type>   
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <search>{$search}</search>
            <status>{$status}</status>
            {
                let $coll-doctype := 
                    switch($type)
                        case "*"
                            return collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType
                        default
                            return
                                for $dtype in tokenize($type,",")
                                return collection(cmn:get-lex-db())/bu:ontology/bu:document/bu:docType[bu:value=$dtype]
                return 
                    subsequence($coll-doctype,$offset,$limit)
            }
        </docs>
};

declare
    %rest:GET
    %rest:path("/ontology/{$type}/{$docid}")
    
    function local:documents($type as xs:string, $docid as xs:int) {
        <docs>
            <type>{$type}</type>   
            <docid>{$docid}</docid>
            {
                collection(cmn:get-lex-db())/bu:ontology/bu:document[bu:docType/bu:value eq $type][bu:docId = $docid]
            }
        </docs>
};

declare
    %rest:GET
    %rest:path("/unknown/{$name}")
    function local:goodbye($name) {
        (<rest:response>
            <http:response status="404"/>
        </rest:response>,
        <goodbye>{$name}</goodbye>
        )
};
local:goodbye("unknown")