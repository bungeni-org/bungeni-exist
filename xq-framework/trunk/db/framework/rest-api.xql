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
 : http://localhost:8088/exist/restxq/ontology?group=document&type=Bill?offset=1&limit=5
 :
:)

declare
    %rest:POST("{$body}")
    %rest:path("/ontology")  
    %rest:form-param("group", "{$group}", "*")    
    %rest:form-param("type", "{$type}", "*")
    %rest:form-param("offset", "{$offset}", 1)
    %rest:form-param("limit", "{$limit}", 0)    
    %rest:form-param("search", "{$search}", "none")
    %rest:form-param("status", "{$status}", "*")
    %rest:form-param("daterange", "{$daterange}", "*")
    %output:method("json")
    
    (: Cascading collection based on parameters given, default apply when not given explicitly by client :)
    function local:documents(
        $body as xs:string*,
        $group as xs:string*,
        $type as xs:string*, 
        $offset as xs:int,
        $limit as xs:int,
        $search as xs:string*,
        $status as xs:string,
        $daterange as xs:string) {
        <docs>
            <group>{$group}</group>           
            <type>{$type}</type>   
            <offset>{$offset}</offset>
            <limit>{$limit}</limit>
            <search>{$search}</search>
            <status>{$status}</status>
            <daterange>{$daterange}</daterange>
            {
                (: get entire collection OR trim by group types mainly: document, group, membership... :)
                let $coll-by-group :=  
                    switch($group)
                        case "*"
                            return collection(cmn:get-lex-db())/bu:ontology
                        default
                            return
                                for $dgroup in tokenize($group,",")
                                return collection(cmn:get-lex-db())/bu:ontology[@for=$dgroup]   
                
                (: from $coll-by-group get collection by docTypes mainly: Bill, Question, Motion... :)
                let $coll-by-doctype := 
                    switch($type)
                        case "*"
                            return $coll-by-group
                        default
                            return
                                for $dtype in tokenize($type,",")
                                return $coll-by-group/child::*/bu:docType[bu:value=$dtype]/ancestor::bu:ontology
                                
                (: trim $coll-by-doctype subset by bu:status :)
                let $coll-by-status := 
                    switch($status)
                        case "*"
                            return $coll-by-doctype
                        default
                            return
                                for $dstatus in $coll-by-doctype
                                where $dstatus/child::*/bu:status/bu:value eq $status 
                                return $dstatus  
                                
                (: trim $coll-by-status subset by bu:statusDate :)
                let $coll-by-statusdate := 
                    switch($daterange)
                        case "*"
                            return $coll-by-status
                        default
                            return
                                for $match in $coll-by-status
                                let $dates := tokenize($daterange,",")
                                return 
                                    $match/child::*[xs:dateTime(bu:statusDate) gt xs:dateTime(concat($dates[1],"T00:00:00"))]
                                    [xs:dateTime(bu:statusDate) lt xs:dateTime(concat($dates[2],"T23:59:59"))]/ancestor::bu:ontology                        
                           
                (: finally search the subset collection if and only if there are is a search param given :)    
                let $ontology_rs := 
                    switch($search)
                        case "none"
                            return $coll-by-statusdate
                        default
                            return
                                bun:adv-ft-search($coll-by-statusdate, $search)                          
                           
                return 
                    subsequence($ontology_rs,$offset,$limit)
                    (:<count>{count($ontology_rs)}</count>:)
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